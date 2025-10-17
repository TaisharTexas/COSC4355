//
//  CityDetailView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import SwiftUI

/**
 Full display name
 
 Temp tab, Precip tab, Wind tab (use forcast API)
 Chart matching tab name
 
 Today at a glance
 Min temp, max temp, precip, wind
 
 (all data is hourly)
 */

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
            .frame(maxWidth: .infinity)
        }//: Scrollview
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.wBackgroundGradientTop, Color.wBackgroundGradientBot]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        favorites.toggle(city)
                    }) {
                        Image(systemName: favorites.contains(city) ? "heart.fill" : "heart")
                            .foregroundColor(favorites.contains(city) ? .red : .gray)
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.wAccent)
                    }
                }
            }
            
        }//: toolbar
        .task {
            await service.loadWeather(for: city)
            if let weather = service.weatherCache[city.id] {
                weatherInfo = CityWeatherInfo(city: city, weather: weather)
            }
        }//: task
        
    }//:end body view
}

struct WeatherDetailCard: View {
    let info: CityWeatherInfo
    let temperatureUnit: TemperatureUnit
    
    var body: some View {
        VStack(spacing: 12) {
            Text(info.city.displayName)
                .font(.headline)
                .foregroundColor(.wTextHeader)
            
            Text("\(info.currentTemp(unit: temperatureUnit) ?? 0)\(info.unitSymbol(for: temperatureUnit))")
                .font(.system(size: 60, weight: .thin))
            
            Text(info.description)
                .font(.title3)
                .foregroundColor(.wTextBody)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Lat")
                        .font(.caption)
                        .foregroundColor(.wTextBody)
                    Text(String(format: "%.2f", info.city.latitude))
                        .font(.caption)
                }
                VStack {
                    Text("Lon")
                        .font(.caption)
                        .foregroundColor(.wTextBody)
                    Text(String(format: "%.2f", info.city.longitude))
                        .font(.caption)
                }
                VStack {
                    Text("Timezone")
                        .font(.caption)
                        .foregroundColor(.wTextBody)
                    Text(info.timezone)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: info.colors.gradientColors),
                startPoint: info.colors.startPoint,
                endPoint: info.colors.endPoint
            )
        )
        .cornerRadius(12)
        .padding(.top)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}
