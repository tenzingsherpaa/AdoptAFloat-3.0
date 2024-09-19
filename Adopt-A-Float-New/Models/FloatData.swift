//
//  FloatData.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

// FloatData.swift

import Foundation

struct FloatData: Hashable, Equatable {
    let deviceName: String
    let dateTime: Date
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let verticalSpeed: Double
    let value1: Int
    let value2: Int
    let value3: Int
    let value4: Int
    let value5: Int
    let value6: Int
    let indicator1: Int
    let indicator2: Int

    init?(raw: [String]) {
        guard raw.count == 15 else {
            print("Expected 15 elements, got \(raw.count)")
            return nil
        }

        // Device Name
        self.deviceName = raw[0]

        // Parse Date and Time
        let dateString = raw[1]
        let timeString = raw[2]
        let dateTimeString = "\(dateString) \(timeString)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let dateTime = dateFormatter.date(from: dateTimeString) else {
            print("Failed to parse date and time: \(dateTimeString)")
            return nil
        }
        self.dateTime = dateTime

        // Parse Numerical Values
        guard let latitude = Double(raw[3]),
              let longitude = Double(raw[4]),
              let altitude = Double(raw[5]),
              let verticalSpeed = Double(raw[6]),
              let value1 = Int(raw[7]),
              let value2 = Int(raw[8]),
              let value3 = Int(raw[9]),
              let value4 = Int(raw[10]),
              let value5 = Int(raw[11]),
              let value6 = Int(raw[12]),
              let indicator1 = Int(raw[13]),
              let indicator2 = Int(raw[14]) else {
            print("Failed to parse numerical values in row: \(raw)")
            return nil
        }

        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.verticalSpeed = verticalSpeed
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        self.value4 = value4
        self.value5 = value5
        self.value6 = value6
        self.indicator1 = indicator1
        self.indicator2 = indicator2
    }

    static func isValidRaw(_ raw: [String]) -> Bool {
        return raw.count == 15
    }
}
extension FloatData {
    init(entity: FloatDataEntity) {
        self.deviceName = entity.deviceName ?? ""
        self.dateTime = entity.dateTime ?? Date()
        self.latitude = entity.latitude
        self.longitude = entity.longitude
        self.altitude = entity.altitude
        self.verticalSpeed = entity.verticalSpeed
        self.value1 = Int(entity.value1)
        self.value2 = Int(entity.value2)
        self.value3 = Int(entity.value3)
        self.value4 = Int(entity.value4)
        self.value5 = Int(entity.value5)
        self.value6 = Int(entity.value6)
        self.indicator1 = Int(entity.indicator1)
        self.indicator2 = Int(entity.indicator2)
    }
}
