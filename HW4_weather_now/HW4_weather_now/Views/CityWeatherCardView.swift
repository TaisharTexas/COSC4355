//
//  CityWeatherCardView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/15/25.
//

import SwiftUI

struct CityWeatherCardView: View {
    let city: City
    @ObservedObject var service: WeatherAPIService
    
    @State private var weatherInfo: CityWeatherInfo?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let info = weatherInfo {
                // Weather loaded - show full card with transition
                //basically just the async card from canine explorer
                WeatherCardDeets(info: info)
                    .transition(.opacity)
            } else {
                // Loading state - placeholder card
                WeatherCardLoading(city: city, isLoading: isLoading)
            }
        }
        .onAppear {
            loadWeather()
        }
        .onChange(of: city.id) {
            loadWeather()
        }
    }
    
    private func loadWeather() {
        // Check cache first
        if let weather = service.weatherCache[city.id] {
            weatherInfo = CityWeatherInfo(city: city, weather: weather)
            return
        }
        
        // Load from API
        isLoading = true
        Task {
            await service.loadWeather(for: city)
            if let weather = service.weatherCache[city.id] {
                withAnimation {
                    weatherInfo = CityWeatherInfo(city: city, weather: weather)
                }
            }
            isLoading = false
        }
    }
}
