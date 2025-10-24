//
//  Settings View.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import Foundation
import SwiftUI

/**
 has settings for imperial/metric units, light/dark mode, and data reset (erases all favorites and api caches so I dont have to delete and relaunch app to test stuff)
 */
struct SettingsView: View {
    @AppStorage("unitSystem") private var unitSystem = "metric"
    @StateObject private var service = WeatherAPIService()
    @Environment(WeatherImageStore.self) private var photoStore
    @State private var showResetConfirmation = false
    
    var body: some View {
        VStack{
            Form {
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
                        Text("Reset Weather Pics")
                    }
                }
                
                
            }//: end form
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset Weather Pics?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    photoStore.resetAllImages()
                }
            } message: {
                Text("This will forget the images selected for the weather types and you will have to reselect them.")
            }
        }
        
    }
    
}
