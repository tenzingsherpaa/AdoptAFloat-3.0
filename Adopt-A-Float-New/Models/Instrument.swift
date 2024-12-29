//
//  Instrument.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 8/30/24.
//
    
import Foundation

// MARK: - Instrument
/// Represents a buoy instrument with a unique name and associated float data.
struct Instrument: Hashable, Equatable {
    // MARK: - Properties
    
    /// The unique name of the instrument.
    let name: String
    
    /// An array of `FloatData` instances representing the data collected by the instrument.
    var floatData: [FloatData]

    // MARK: - Hashable Conformance
    
    /// Hashes the essential components of the `Instrument` to generate a unique hash value.
    /// - Parameter hasher: The hasher to use when combining the components.
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    // MARK: - Equatable Conformance
    
    /// Determines if two `Instrument` instances are equal based on their name and float data.
    /// - Parameters:
    ///   - lhs: The first `Instrument` instance.
    ///   - rhs: The second `Instrument` instance.
    /// - Returns: `true` if both instruments have the same name and float data; otherwise, `false`.
    static func ==(lhs: Instrument, rhs: Instrument) -> Bool {
        return lhs.name == rhs.name && lhs.floatData == rhs.floatData
    }
}
