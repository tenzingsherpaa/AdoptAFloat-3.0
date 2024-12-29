//
 //  PersistenceController.swift
 //  Adopt-A-Float-New
 //
 //  Created by Tenzing Sherpa on 9/14/24.
 //
    
import Foundation
import CoreData

// MARK: - PersistenceController
/// Manages the Core Data stack for the application.
struct PersistenceController {
    /// Singleton instance for shared access throughout the app.
    static let shared = PersistenceController()

    /// The persistent container that encapsulates the Core Data stack.
    let container: NSPersistentContainer

    /// Initializes the persistent container and loads the persistent stores.
    init() {
        container = NSPersistentContainer(name: "AdoptAFloatModel") // Ensure this matches your .xcdatamodeld filename
        container.loadPersistentStores { description, error in
            if let error = error {
                // Replace this implementation with error handling as appropriate for your app.
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
