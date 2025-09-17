//
//  HW2_packingListApp.swift
//  HW2_packingList
//
//  Created by Andrew Lee on 9/11/25.
//

import SwiftUI
import SwiftData

@main
struct HW2_packingListApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: PackingItemModel.self)
        }
    }
}
