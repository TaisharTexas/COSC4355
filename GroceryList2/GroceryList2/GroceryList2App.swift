//
//  GroceryList2App.swift
//  GroceryList2
//
//  Created by Ioannis Pavlidis on 9/11/25.
//

import SwiftUI
import SwiftData

@main
struct GroceryList2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: DataItemModel.self)
        }
    }
}
