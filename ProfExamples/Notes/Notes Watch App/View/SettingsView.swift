//
//  SettingsView.swift
//  Notes Watch App
//
//  Created by Ioannis Pavlidis on 11/5/25.
//

// • @AppStorage("lineCount") var lineCount: Int = 1
//   A UserDefaults-backed integer. Changing it here   immediately updates any other view that reads the same key (e.g., ContentView uses it in .lineLimit(lineCount)).
// • @State private var value: Float = 1.0
//   A local slider value. You convert it to an Int and write it into lineCount via update().
// • update()
//   Simple bridge from the slider’s floating-point value to the stored integer:

import SwiftUI

struct SettingsView: View {
    // MARK: - PROPERTY
    
    @AppStorage("lineCount") var lineCount: Int = 1
    @State private var value: Float = 1.0
    
    
    // MARK: - FUNCTION
    
    func update() {
        lineCount = Int(value)
    }
    
    // MARK: - BODY
    
    var body: some View {
        VStack(spacing: 8) {
            // HEADER
            HeaderView(title: "Settings")
            
            // ACTUAL LINE COUNT
            Text("Lines: \(lineCount)".uppercased())
                .fontWeight(.bold)
            
            // SLIDER
            // What changes per platform is the rendering and interaction:
            // • watchOS: compact slider styling sized for the watch.
            // • iOS/iPadOS: standard horizontal track with a draggable thumb.
            Slider(value: Binding(get: {
                self.value
            }, set: {
                (newValue) in
                self.value = newValue
                self.update()
            }), in: 1...4, step: 1)
                .accentColor(.accentColor)
        } //: VSTACK
    }
}

#Preview {
    SettingsView()
}
