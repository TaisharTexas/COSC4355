//
//  ContentView.swift
//  ChartsExample
//
//  Created by Ioannis Pavlidis on 10/9/25.
//

import SwiftUI
import Charts   // Apple's built-in charting framework (iOS 16+)

// MARK: - 1. Define a simple data model
// Each data point represents a day and its high temperature.
struct TempPoint: Identifiable {
    let id = UUID()     // Needed for SwiftUI's ForEach/Chart to uniquely identify each element
    let day: String     // e.g., "Mon", "Tue" — shown along the X-axis
    let high: Double    // Temperature value — plotted along the Y-axis
}

// MARK: - 2. Sample data for the chart
// Normally this would come from your weather API, but here we hard-code it for demonstration.
let sample: [TempPoint] = [
    .init(day: "Mon", high: 72),
    .init(day: "Tue", high: 75),
    .init(day: "Wed", high: 78),
    .init(day: "Thu", high: 70),
    .init(day: "Fri", high: 68),
]

// MARK: - 3. Chart view
struct ContentView: View {
    var body: some View {
        // The Chart view automatically loops through each TempPoint in `sample`
        // and uses the closure below to draw marks for each.
        Chart(sample) { item in
            // A LineMark draws a continuous line connecting each data point.
            LineMark(
                x: .value("Day", item.day),      // X-axis = day of the week
                y: .value("High °F", item.high)  // Y-axis = temperature in Fahrenheit
            )

            // A PointMark draws small dots on top of each data point.
            PointMark(
                x: .value("Day", item.day),
                y: .value("High °F", item.high)
            )
        }
        // MARK: - 4. Chart customization
        .chartYAxisLabel("Temperature (°F)")   // shows visible label on Y axis
        .chartXAxisLabel("Day of Week")        // shows visible label on X axis
        .chartYScale(domain: 60...80)   // Fix Y-axis range so the line doesn’t auto-rescale each time
        .frame(height: 220)             // Give the chart a visible height
        .padding()                      // Add space around it for a clean layout
    }
}
