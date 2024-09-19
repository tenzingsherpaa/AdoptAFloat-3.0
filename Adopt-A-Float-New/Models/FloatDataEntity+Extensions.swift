//
//  FloatDataEntity+Extensions.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 9/14/24.
//

import Foundation
import CoreData

extension FloatDataEntity {
    func populate(with data: FloatData) {
        self.deviceName = data.deviceName
        self.dateTime = data.dateTime
        self.latitude = data.latitude
        self.longitude = data.longitude
        self.altitude = data.altitude
        self.verticalSpeed = data.verticalSpeed
        self.value1 = Int32(data.value1)
        self.value2 = Int32(data.value2)
        self.value3 = Int32(data.value3)
        self.value4 = Int32(data.value4)
        self.value5 = Int32(data.value5)
        self.value6 = Int32(data.value6)
        self.indicator1 = Int32(data.indicator1)
        self.indicator2 = Int32(data.indicator2)
    }
}
