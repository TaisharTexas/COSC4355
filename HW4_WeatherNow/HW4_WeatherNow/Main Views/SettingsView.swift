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
    @AppStorage("unitSystem") private var unitSystem = "metric"
    @StateObject private var service = WeatherAPIService()
    @EnvironmentObject var favorites: FavoritesStore
    @State private var showResetConfirmation = false
    
    var body: some View {
        VStack{
            Form {
                Section("About") {
                    Text("Weather Now App")
                    Text("Version 1.0")
                    Text("Built by Andrew Lee")
                }
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedScheme) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Units")) {
                    Picker("Unit System", selection: $unitSystem) {
                        Text("Metric").tag("metric")
                        Text("Imperial").tag("imperial")
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
                
                
            }//: end form
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
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
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.wBackgroundGradientTop, Color.wBackgroundGradientBot]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        
    }
    
}
