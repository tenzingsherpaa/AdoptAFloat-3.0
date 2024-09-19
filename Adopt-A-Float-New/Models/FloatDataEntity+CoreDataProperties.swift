//
//  FloatDataEntity+CoreDataProperties.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 9/14/24.
//
//

import Foundation
import CoreData


extension FloatDataEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FloatDataEntity> {
        return NSFetchRequest<FloatDataEntity>(entityName: "FloatDataEntity")
    }

    @NSManaged public var deviceName: String?
    @NSManaged public var dateTime: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var verticalSpeed: Double
    @NSManaged public var value1: Int32
    @NSManaged public var value2: Int32
    @NSManaged public var value3: Int32
    @NSManaged public var value4: Int32
    @NSManaged public var value5: Int32
    @NSManaged public var value6: Int32
    @NSManaged public var indicator1: Int32
    @NSManaged public var indicator2: Int32

}

extension FloatDataEntity : Identifiable {

}
