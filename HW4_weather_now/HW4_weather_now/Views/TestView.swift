//
//  TestApiView.swift
//  HW4_weather_now
//

/**
 This is literally just a visual testbed I use to test that the API is sending info and then for color checking
 */

import SwiftUI

struct TestApiView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Weather Card Previews")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                WeatherPreviewCard(weatherCode: 0, title: "Clear Sky")
                WeatherPreviewCard(weatherCode: 2, title: "Partly Cloudy")
                WeatherPreviewCard(weatherCode: 45, title: "Foggy")
                WeatherPreviewCard(weatherCode: 55, title: "Drizzle")
                WeatherPreviewCard(weatherCode: 65, title: "Rain")
                WeatherPreviewCard(weatherCode: 75, title: "Snow")
                WeatherPreviewCard(weatherCode: 95, title: "Thunderstorm")
            }
            .padding()
        }
    }
}

struct WeatherPreviewCard: View {
    let weatherCode: Int
    let title: String
    
    var colors: WeatherColors {
        WeatherDescriptions.colors(for: weatherCode)
    }
    
    var icon: String {
        WeatherDescriptions.icon(for: weatherCode)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(.white)
                Text("Code: \(weatherCode)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            
            VStack {
                HStack {
                    Text("72°")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                Text(WeatherDescriptions.text(for: weatherCode))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: colors.gradientColors),
                startPoint: colors.startPoint,
                endPoint: colors.endPoint
            )
        )
        .cornerRadius(12)
    }
}

#Preview {
    TestApiView()
}
