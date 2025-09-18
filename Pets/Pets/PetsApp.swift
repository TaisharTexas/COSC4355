//
//  PetsApp.swift
//  Pets
//
//  Created by Ioannis Pavlidis on 9/15/25.
//

import SwiftUI
import SwiftData

@main
struct PetsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: PetDataItem.self)
        }
    }
}
