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
    
    var body: some View {
        Form {
            Section("About") {
                Text("Weather App")
                Text("Version 1.0")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        
        Form {
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $selectedScheme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Settings")
        
        /**
         Will add toggles for dark/light mode and metric/imperial
         */
    }
}
