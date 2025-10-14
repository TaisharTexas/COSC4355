//
//  Settings View.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("About") {
                Text("Weather App")
                Text("Version 1.0")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        
        /**
         Will add toggles for dark/light mode and metric/imperial
         */
    }
}
