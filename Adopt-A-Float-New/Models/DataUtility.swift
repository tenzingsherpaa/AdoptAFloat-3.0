//
//  DataUtility.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import Foundation
import CoreData

// MARK: - DataUtility
/// A utility struct providing methods to fetch and manage instrument data.
struct DataUtility {

    // MARK: - Base URL Retrieval

    /// Fetches the base URL from the `source.plist` file.
    /// - Returns: The base URL as a `String` if available, otherwise `nil`.
    static func getBaseURL() -> String? {
        guard let path = Bundle.main.path(forResource: "source", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: path),
              let baseURL = plistDict["BaseURL"] as? String else {
            print("Failed to load BaseURL from source.plist")
            return nil
        }
        return baseURL
    }

    // MARK: - Instrument Creation

    /// Creates an array of `Instrument` by scanning the base URL directory for matching files.
    /// - Returns: An array of `Instrument` instances.
    static func createInstruments() -> [Instrument] {
        var instruments: [Instrument] = []

        guard let baseURL = getBaseURL() else {
            print("Base URL not found.")
            return instruments
        }

        // Regex pattern to match filenames like N0001_030.txt, P0006_030.txt, etc.
        let pattern = "^[A-Z]\\d{4}_030\\.txt$"

        // Fetch and filter filenames using the regex pattern
        if let fileNames = fetchFileNames(from: baseURL, matching: pattern) {
            for fileName in fileNames {
                let instrumentName = fileName.replacingOccurrences(of: "_030.txt", with: "")
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

    // MARK: - File Name Fetching

    /// Fetches filenames from the base URL that match the given regex pattern.
    /// - Parameters:
    ///   - baseURL: The base URL string.
    ///   - pattern: The regex pattern to match filenames.
    /// - Returns: An array of matching filenames if successful, otherwise `nil`.
    static func fetchFileNames(from baseURL: String, matching pattern: String) -> [String]? {
        guard let url = URL(string: baseURL) else {
            print("Invalid base URL")
            return nil
        }

        var matchedFiles: [String] = []

        guard let directoryHTML = downloadString(url: url) else {
            print("Failed to download directory listing")
            return nil
        }

        let fileNames = extractFileNames(from: directoryHTML)
        let regex = try? NSRegularExpression(pattern: pattern)

        for fileName in fileNames {
            if let regex = regex, regex.firstMatch(in: fileName, options: [], range: NSRange(location: 0, length: fileName.utf16.count)) != nil {
                matchedFiles.append(fileName)
            }
        }
        return matchedFiles
    }

    // MARK: - File Name Extraction

    /// Extracts filenames ending with `.txt` from the provided HTML string.
    /// - Parameter html: The HTML content as a `String`.
    /// - Returns: An array of `.txt` filenames.
    static func extractFileNames(from html: String) -> [String] {
        var fileNames: [String] = []
        let pattern = "href=\"([^\"]+)\""
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
        regex?.enumerateMatches(in: html, options: [], range: nsRange) { match, _, _ in
            if let matchRange = match?.range(at: 1),
               let swiftRange = Range(matchRange, in: html) {
                let fileName = String(html[swiftRange])
                if fileName.hasSuffix(".txt") {
                    fileNames.append(fileName)
                }
            }
        }
        return fileNames
    }

    // MARK: - Data Fetching

    /// Fetches float data for a specific instrument from Core Data or downloads it if outdated.
    /// - Parameters:
    ///   - url: The URL to fetch data from.
    ///   - deviceName: The name of the device (instrument).
    /// - Returns: An array of `FloatData` instances.
    static func fetchData(from url: URL, for deviceName: String) -> [FloatData] {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<FloatDataEntity> = FloatDataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "deviceName == %@", deviceName)

        do {
            let cachedData = try context.fetch(fetchRequest)
            let shouldRefreshData: Bool

            if let lastData = cachedData.last, let lastDate = lastData.dateTime {
                let timeSinceLastFetch = Date().timeIntervalSince(lastDate)
                shouldRefreshData = timeSinceLastFetch > (24 * 60 * 60) // 1 day
            } else {
                shouldRefreshData = true
            }

            // Use cached data if it's recent
            if !cachedData.isEmpty && !shouldRefreshData {
                print("Loaded data from Core Data")
                return cachedData.map { FloatData(entity: $0) }
            } else {
                guard let response = downloadString(url: url) else {
                    print("Failed to download data from \(url)")
                    return []
                }

                var dataSet = [FloatData]()
                let rawRows = splitDataRows(response)

                // Delete old cached data
                for object in cachedData {
                    context.delete(object)
                }

                // Parse and save new data
                for rawData in rawRows {
                    if FloatData.isValidRaw(rawData), let floatData = FloatData(raw: rawData) {
                        dataSet.append(floatData)
                        let entity = FloatDataEntity(context: context)
                        entity.populate(with: floatData)
                    }
                }

                try context.save()
                return dataSet
            }
        } catch {
            print("Error fetching or saving data: \(error)")
            return []
        }
    }

    // MARK: - Data Parsing

    /// Splits raw data string into rows and columns.
    /// - Parameter rawData: The raw data as a single `String`.
    /// - Returns: A two-dimensional array representing rows and their respective columns.
    static func splitDataRows(_ rawData: String) -> [[String]] {
        let lines = rawData.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var data = [[String]]()
        for line in lines {
            let values = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            data.append(values)
        }
        return data
    }

    // MARK: - Data Downloading

    /// Downloads the content of a URL as a `String`.
    /// - Parameter url: The URL to download data from.
    /// - Returns: The downloaded content as a `String` if successful, otherwise `nil`.
    static func downloadString(url: URL) -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: String?

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, _, error in
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
