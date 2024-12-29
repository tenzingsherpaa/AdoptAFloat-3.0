//
//  FloatData.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import SwiftUI

// MARK: - FloatData
/// A struct representing the data collected from a buoy float.
struct FloatData: Hashable, Equatable {
    // MARK: - Properties
    let deviceName: String          // Name of the buoy device
    let dateTime: Date              // Timestamp of the data point
    let latitude: Double            // Latitude coordinate
    let longitude: Double           // Longitude coordinate
    let altitude: Double            // Altitude above sea level
    let verticalSpeed: Double       // Vertical speed in meters per second
    let batteryLevel: Int           // Battery level in millivolts
    let internalPressure: Int       // Internal pressure in Pascals
    let externalPressure: Int       // External pressure in millibars
    let distanceTravelled: Int      // Distance travelled in kilometers
    let averageSpeed: Int           // Average speed in kilometers per hour
    let netDisplacement: Int        // Net displacement in kilometers
    let gpsAccuracyHdop: Int        // Horizontal Dilution of Precision for GPS accuracy
    let gpsAccuracyVdop: Int        // Vertical Dilution of Precision for GPS accuracy

    // MARK: - Initializer from Raw Data
    /// Initializes a `FloatData` instance from an array of raw string data.
    /// - Parameter raw: An array of strings representing raw data fields.
    init?(raw: [String]) {
        // Ensure the raw data has exactly 15 elements
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

        // Convert the date and time string to a Date object
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
              let batteryLevel = Int(raw[7]),
              let internalPressure = Int(raw[8]),
              let externalPressure = Int(raw[9]),
              let distanceTravelled = Int(raw[10]),
              let averageSpeed = Int(raw[11]),
              let netDisplacement = Int(raw[12]),
              let gpsAccuracyHdop = Int(raw[13]),
              let gpsAccuracyVdop = Int(raw[14]) else {
            print("Failed to parse numerical values in row: \(raw)")
            return nil
        }

        // Assign parsed numerical values to properties
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.verticalSpeed = verticalSpeed
        self.batteryLevel = batteryLevel
        self.internalPressure = internalPressure
        self.externalPressure = externalPressure
        self.distanceTravelled = distanceTravelled
        self.averageSpeed = averageSpeed
        self.netDisplacement = netDisplacement
        self.gpsAccuracyHdop = gpsAccuracyHdop
        self.gpsAccuracyVdop = gpsAccuracyVdop
    }

    // MARK: - Raw Data Validation
    /// Checks if the raw data array has the expected number of elements.
    /// - Parameter raw: An array of strings representing raw data fields.
    /// - Returns: A Boolean indicating whether the raw data is valid.
    static func isValidRaw(_ raw: [String]) -> Bool {
        return raw.count == 15
    }
}

// MARK: - FloatData Entity Initialization
extension FloatData {
    /// Initializes a `FloatData` instance from a `FloatDataEntity` managed object.
    /// - Parameter entity: The `FloatDataEntity` from Core Data.
    init(entity: FloatDataEntity) {
        self.deviceName = entity.deviceName ?? ""
        self.dateTime = entity.dateTime ?? Date()
        self.latitude = entity.latitude
        self.longitude = entity.longitude
        self.altitude = entity.altitude
        self.verticalSpeed = entity.verticalSpeed
        self.batteryLevel = Int(entity.batteryLevel)
        self.internalPressure = Int(entity.internalPressure)
        self.externalPressure = Int(entity.externalPressure)
        self.distanceTravelled = Int(entity.distanceTravelled)
        self.averageSpeed = Int(entity.averageSpeed)
        self.netDisplacement = Int(entity.netDisplacement)
        self.gpsAccuracyHdop = Int(entity.gpsAccuracyHdop)
        self.gpsAccuracyVdop = Int(entity.gpsAccuracyVdop)
    }
}
