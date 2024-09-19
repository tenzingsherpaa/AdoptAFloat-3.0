//
//  DataUtility.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

// DataUtility.swift

import Foundation
import CoreData


struct DataUtility {
    static let baseURL = "https://geoweb.princeton.edu/people/simons/SOM/N0001_all.txt"

    static func createInstruments() -> [Instrument] {
        var instruments: [Instrument] = []

        let instrumentName = "N0001"
        let urlString = baseURL

        print("Constructed URL: \(urlString)")
        if let url = URL(string: urlString) {
            let instrumentData = fetchData(from: url)
            let instrument = Instrument(name: instrumentName, floatData: instrumentData)
            instruments.append(instrument)
        } else {
            print("Invalid URL: \(urlString)")
        }

        return instruments
    }

    static func fetchData(from url: URL) -> [FloatData] {
        // Get the context
        let context = PersistenceController.shared.container.viewContext

        // Check if data already exists
        let fetchRequest: NSFetchRequest<FloatDataEntity> = FloatDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "deviceName == %@", "N0001")

        do {
            let cachedData = try context.fetch(fetchRequest)
            let shouldRefreshData: Bool

            if let lastData = cachedData.last, let lastDate = lastData.dateTime {
                // Determine if data is outdated (e.g., older than 1 day)
                let timeSinceLastFetch = Date().timeIntervalSince(lastDate)
                shouldRefreshData = timeSinceLastFetch > (24 * 60 * 60) // 1 day
            } else {
                shouldRefreshData = true
            }

            if !cachedData.isEmpty && !shouldRefreshData {
                print("Loaded data from Core Data")
                return cachedData.map { entity in
                    FloatData(entity: entity)
                }
            } else {
                // Download new data
                guard let response = downloadString(url: url) else {
                    print("Failed to download data from \(url)")
                    return []
                }

                print("Downloaded data: \(response.prefix(500))")

                var dataSet = [FloatData]()
                let rawRows = splitDataRows(response)

                // Remove old data
                for object in cachedData {
                    context.delete(object)
                }

                for rawData in rawRows {
                    if FloatData.isValidRaw(rawData) {
                        if let floatData = FloatData(raw: rawData) {
                            dataSet.append(floatData)

                            // Save to Core Data
                            let entity = FloatDataEntity(context: context)
                            entity.populate(with: floatData)
                        }
                    }
                }

                // Save the context
                try context.save()
                print("Updated data in Core Data")

                return dataSet
            }
        } catch {
            print("Error fetching or saving data: \(error)")
            return []
        }
    }

    static func splitDataRows(_ rawData: String) -> [[String]] {
        let lines = rawData.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var data = [[String]]()
        for line in lines {
            let values = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            data.append(values)
        }
        return data
    }

    static func downloadString(url: URL) -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: String?

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                result = String(data: data, encoding: .utf8)
            } else if let error = error {
                print("Error downloading data: \(error.localizedDescription)")
            }
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        return result
    }
}
