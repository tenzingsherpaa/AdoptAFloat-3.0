//
 //  FloatDataEntity+Extensions.swift
 //  Adopt-A-Float-New
 //
 //  Created by Tenzing Sherpa on 9/14/24.
 //
    
import Foundation
import CoreData

// MARK: - FloatDataEntity Extension
/// Provides additional functionality for the `FloatDataEntity` managed object.
extension FloatDataEntity {
    
    /// Populates the `FloatDataEntity` with data from a `FloatData` instance.
    /// - Parameter data: The `FloatData` instance containing the data to populate.
    func populate(with data: FloatData) {
        self.deviceName = data.deviceName
        self.dateTime = data.dateTime
        self.latitude = data.latitude
        self.longitude = data.longitude
        self.altitude = data.altitude
        self.verticalSpeed = data.verticalSpeed
        self.batteryLevel = Int32(data.batteryLevel)
        self.internalPressure = Int32(data.internalPressure)
        self.externalPressure = Int32(data.externalPressure)
        self.distanceTravelled = Int32(data.distanceTravelled)
        self.averageSpeed = Int32(data.averageSpeed)
        self.netDisplacement = Int32(data.netDisplacement)
        self.gpsAccuracyHdop = Int32(data.gpsAccuracyHdop)
        self.gpsAccuracyVdop = Int32(data.gpsAccuracyVdop)
    }
}
