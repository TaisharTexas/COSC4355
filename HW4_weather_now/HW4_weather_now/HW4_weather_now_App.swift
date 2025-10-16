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
    @StateObject private var service = WeatherAPIService()
    @AppStorage("selectedColorScheme") private var selectedScheme = "light"
    
    var colorScheme: ColorScheme? {
        switch selectedScheme {
            case "light": return .light
            case "dark": return .dark
            default: return .light
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favorites)
                .environmentObject(service)
                .preferredColorScheme(colorScheme)
        }
    }
}
