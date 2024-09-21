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

    // Fetch the Base URL from the plist file
    static func getBaseURL() -> String? {
        guard let path = Bundle.main.path(forResource: "source", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: path),
              let baseURL = plistDict["BaseURL"] as? String else {
            print("Failed to load BaseURL from source.plist")
            return nil
        }
        return baseURL
    }

    // Create instruments by scanning the base URL directory
    static func createInstruments() -> [Instrument] {
        var instruments: [Instrument] = []

        guard let baseURL = getBaseURL() else {
            print("Base URL not found.")
            return instruments
        }

        // Use the correct pattern to match files like N0001_all.txt, P0006_all.txt, etc.
        let pattern = "^[A-Z]\\d{4}_all\\.txt$"

        // Fetch the directory listing and filter filenames using the regex pattern
        if let fileNames = fetchFileNames(from: baseURL, matching: pattern) {
            for fileName in fileNames {
                let instrumentName = fileName.replacingOccurrences(of: "_all.txt", with: "")
                let urlString = "\(baseURL)\(fileName)"

                if let url = URL(string: urlString) {
                    let instrumentData = fetchData(from: url, for: instrumentName)
                    let instrument = Instrument(name: instrumentName, floatData: instrumentData)
                    instruments.append(instrument)
                } else {
                    print("Invalid URL: \(urlString)")
                }
            }
        }

        return instruments
    }

    // Fetch filenames based on regex pattern from the directory
    static func fetchFileNames(from baseURL: String, matching pattern: String) -> [String]? {
        guard let url = URL(string: baseURL) else {
            print("Invalid base URL")
            return nil
        }

        var matchedFiles: [String] = []

        // Fetch directory listing from the server
        guard let directoryHTML = downloadString(url: url) else {
            print("Failed to download directory listing")
            return nil
        }

        // Extract file names from the HTML (assuming links with href)
        let fileNames = extractFileNames(from: directoryHTML)

        let regex = try? NSRegularExpression(pattern: pattern)

        for fileName in fileNames {
            if let regex = regex, regex.firstMatch(in: fileName, options: [], range: NSRange(location: 0, length: fileName.count)) != nil {
                matchedFiles.append(fileName)
            }
        }

        print("Matched Files: \(matchedFiles)")
        return matchedFiles
    }

    // Function to extract filenames from an HTML string (assuming links with href)
    static func extractFileNames(from html: String) -> [String] {
        var fileNames: [String] = []
        
        // Simple regex to find href attributes with filenames
        let pattern = "href=\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern)

        let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
        regex?.enumerateMatches(in: html, options: [], range: nsRange) { match, _, _ in
            if let matchRange = match?.range(at: 1),
               let swiftRange = Range(matchRange, in: html) {
                let fileName = String(html[swiftRange])
                
                // Filter out unwanted paths (e.g., directories, parent folder links)
                if fileName.hasSuffix(".txt") {
                    fileNames.append(fileName)
                }
            }
        }
        
        return fileNames
    }

    // Fetch the data for each instrument from the given URL
    static func fetchData(from url: URL, for deviceName: String) -> [FloatData] {
        // Get the context
        let context = PersistenceController.shared.container.viewContext

        // Check if data already exists
        let fetchRequest: NSFetchRequest<FloatDataEntity> = FloatDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "deviceName == %@", deviceName)

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
                return dataSet
            }
        } catch {
            print("Error fetching or saving data: \(error)")
            return []
        }
    }

    // Helper function to split raw data into rows and values
    static func splitDataRows(_ rawData: String) -> [[String]] {
        let lines = rawData.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var data = [[String]]()
        for line in lines {
            let values = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            data.append(values)
        }
        return data
    }

    // Helper function to download raw data from URL
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
