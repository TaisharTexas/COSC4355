//
//  Settings View.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedColorScheme") private var selectedScheme = "light"
    @AppStorage("temperatureUnit") private var tempUnit = "celsius"
    @StateObject private var service = WeatherAPIService()
    @EnvironmentObject var favorites: FavoritesStore
    @State private var showResetConfirmation = false
    
    var body: some View {
        Form {
            Section("About") {
                Text("Weather App")
                Text("Version 1.0")
            }
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $selectedScheme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Units")) {
                Picker("Temperature", selection: $tempUnit) {
                    Text("Celsius").tag("celsius")
                    Text("Fahrenheit").tag("fahrenheit")
                }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Data")) {
                Button(role: .destructive, action: {
                    showResetConfirmation = true
                }) {
                    Text("Clear All Data")
                }
            }
            
            
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear All Data?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                service.clearAllData()
                favorites.clear()
            }
        } message: {
            Text("This will delete all saved favorites and cached weather data. This cannot be undone.")
        }
        
        
        
        /**
         Will add toggles for dark/light mode and metric/imperial
         */
    }
}
