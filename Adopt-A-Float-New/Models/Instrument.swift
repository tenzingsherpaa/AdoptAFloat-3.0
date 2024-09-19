//
//  Instrument.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//

import Foundation

struct Instrument: Hashable, Equatable {
    let name: String
    var floatData: [FloatData]

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func ==(lhs: Instrument, rhs: Instrument) -> Bool {
        return lhs.name == rhs.name && lhs.floatData == rhs.floatData
    }
}
