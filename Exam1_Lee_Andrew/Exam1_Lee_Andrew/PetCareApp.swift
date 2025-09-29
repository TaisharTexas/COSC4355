//
//  Exam1_Lee_AndrewApp.swift
//  Exam1_Lee_Andrew
//
//  Created by Andrew Lee on 9/25/25.
//

import SwiftUI
import SwiftData

@main
struct PetCareApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let container = try! ModelContainer(for: PetItem.self)
        let context = ModelContext(container)
        
        // Check if CatalogItems already exist in the DB (ie, JSON file already parsed on a past app launch)
        let descriptor = FetchDescriptor<PetItem>()
        let existingPets = (try? context.fetch(descriptor)) ?? []
        
        if existingPets.isEmpty {
            print("APP: No existing pets found, loading from JSON...")
            // Load JSON data only if DB is empty
            let pets = loadPetsFromJSON(from: "pets")
            for pet in pets {
                context.insert(pet)
            }
            try! context.save()
            print("APP: Loaded \(pets.count) pets from JSON")
        } else {
            print("APP: Found \(existingPets.count) existing pets, skipping JSON load")
        }
        
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
        
}
