//
//  FloatDataEntity+CoreDataProperties.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 9/14/24.
//

import Foundation
import CoreData

// MARK: - FloatDataEntity Properties
extension FloatDataEntity {

    /// Fetch request for FloatDataEntity.
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FloatDataEntity> {
        return NSFetchRequest<FloatDataEntity>(entityName: "FloatDataEntity")
    }

    // MARK: - Attributes
    
    /// The name of the device (buoy).
    @NSManaged public var deviceName: String?
    
    /// The timestamp of the data point.
    @NSManaged public var dateTime: Date?
    
    /// The latitude coordinate of the buoy.
    @NSManaged public var latitude: Double
    
    /// The longitude coordinate of the buoy.
    @NSManaged public var longitude: Double
    
    /// The altitude of the buoy above sea level.
    @NSManaged public var altitude: Double
    
    /// The vertical speed of the buoy.
    @NSManaged public var verticalSpeed: Double
    
    /// The battery level of the buoy in millivolts.
    @NSManaged public var batteryLevel: Int32
    
    /// The internal pressure of the buoy in Pascals.
    @NSManaged public var internalPressure: Int32
    
    /// The external pressure of the buoy in millibars.
    @NSManaged public var externalPressure: Int32
    
    /// The total distance travelled by the buoy in kilometers.
    @NSManaged public var distanceTravelled: Int32
    
    /// The average speed of the buoy in kilometers per hour.
    @NSManaged public var averageSpeed: Int32
    
    /// The net displacement of the buoy in kilometers.
    @NSManaged public var netDisplacement: Int32
    
    /// The horizontal dilution of precision (HDOP) for GPS accuracy in meters.
    @NSManaged public var gpsAccuracyHdop: Int32
    
    /// The vertical dilution of precision (VDOP) for GPS accuracy in meters.
    @NSManaged public var gpsAccuracyVdop: Int32
}

// MARK: - Identifiable Conformance
extension FloatDataEntity : Identifiable {}
