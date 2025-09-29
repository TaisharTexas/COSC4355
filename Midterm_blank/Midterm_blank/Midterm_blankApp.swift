//
//  Midterm_blankApp.swift
//  Midterm_blank
//
//  Created by Andrew Lee on 9/25/25.
//

import SwiftUI
import SwiftData

@main
struct Midterm_blankApp: App {
    
    //need to make the container here because we're seeding the DB on launch before any views are called
    var sharedModelContainer: ModelContainer = {
        let container = try! ModelContainer(for: CatalogItem.self)
        let context = ModelContext(container)
        
        // Check if CatalogItems already exist in the DB (ie, JSON file already parsed on a past app launch)
        let descriptor = FetchDescriptor<CatalogItem>()
        let existingParks = (try? context.fetch(descriptor)) ?? []
        
        if existingParks.isEmpty {
            print("APP: No existing parks found, loading from JSON...")
            // Load JSON data only if DB is empty
            let parks = loadParksFromJSON(from: "parks")
            for park in parks {
                context.insert(park)
            }
            try! context.save()
            print("APP: Loaded \(parks.count) parks from JSON")
        } else {
            print("APP: Found \(existingParks.count) existing parks, skipping JSON load")
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
