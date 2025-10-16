//
//  CityDetailView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import SwiftUI

struct CityDetailView: View {
    let city: City
    @ObservedObject var service: WeatherAPIService
    @EnvironmentObject var favorites: FavoritesStore
    @AppStorage("temperatureUnit") private var tempUnit = "celsius"
    
    @State private var weatherInfo: CityWeatherInfo?
    
    private var temperatureUnit: TemperatureUnit {
        tempUnit == "fahrenheit" ? .fahrenheit : .celsius
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let info = weatherInfo {
                    WeatherDetailCard(info: info, temperatureUnit: temperatureUnit)
                } else {
                    ProgressView("Loading weather...")
                }
            }
        }
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    favorites.toggle(city)
                }) {
                    Image(systemName: favorites.contains(city) ? "star.fill" : "star")
                        .foregroundColor(favorites.contains(city) ? .yellow : .gray)
                }
            }
        }
        .task {
            await service.loadWeather(for: city)
            if let weather = service.weatherCache[city.id] {
                weatherInfo = CityWeatherInfo(city: city, weather: weather)
            }
        }
    }
}

struct WeatherDetailCard: View {
    let info: CityWeatherInfo
    let temperatureUnit: TemperatureUnit
    
    var body: some View {
        VStack(spacing: 12) {
            Text(info.city.displayName)
                .font(.headline)
            
            Text("\(info.currentTemp(unit: temperatureUnit) ?? 0)\(info.unitSymbol(for: temperatureUnit))")
                .font(.system(size: 60, weight: .thin))
            
            Text(info.description)
                .font(.title3)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Lat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f", info.city.latitude))
                        .font(.caption)
                }
                VStack {
                    Text("Lon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f", info.city.longitude))
                        .font(.caption)
                }
                VStack {
                    Text("Timezone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(info.timezone)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
