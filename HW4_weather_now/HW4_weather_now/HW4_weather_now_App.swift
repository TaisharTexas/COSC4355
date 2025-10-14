//
//  HW4_weather_nowApp.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

@main
struct HW4_weather_now_App: App {
    @StateObject private var favorites = FavoritesStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favorites)
        }
    }
}
