//
//  PetDataItem.swift
//  Pets
//
//  Created by Ioannis Pavlidis on 9/15/25.
//

import Foundation   // General purpose core types & utilities (e.g. Array)
import SwiftData    // Modern persistent framework

@Model              // Data to be stored across app launches (persistent)
final class PetDataItem  {
    var name: String
    @Attribute(.externalStorage) var photo: Data?
    // How a property should be stored in the model container
    // If big data, store it outside the database
    // Data is a general-purpose container of raw bytes
    
    init(name: String, photo: Data? = nil) {
        self.name = name
        self.photo = photo
    }
} // final means no subclassing (for simplicity)
   
// extension to help with previews
// static accesses properties on the data type
extension PetDataItem {
        @MainActor  // Run it on the main thread (not in the background)
        static var preview: ModelContainer {
            let configuation = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try! ModelContainer(for: PetDataItem.self, configurations: configuation)
            container.mainContext.insert(PetDataItem(name: "Max"))
            container.mainContext.insert(PetDataItem(name: "Bella"))
            container.mainContext.insert(PetDataItem(name: "Buddy"))
            container.mainContext.insert(PetDataItem(name: "Daisy"))
            container.mainContext.insert(PetDataItem(name: "Rocky"))
            container.mainContext.insert(PetDataItem(name: "Molly"))
            container.mainContext.insert(PetDataItem(name: "Charlie"))
            container.mainContext.insert(PetDataItem(name: "Lucy"))
            
            return container
        }
        // configuration is a settings file
        // try! = it may fail; crash it then - preview and dosen't matter
    }
    

