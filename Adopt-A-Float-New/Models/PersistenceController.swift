//
//  PersistenceController.swift
//  Adopt-A-Float-New
//
//  Created by Tenzing Sherpa on 9/14/24.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "AdoptAFloatModel") // Use the name of your data model file
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
}
