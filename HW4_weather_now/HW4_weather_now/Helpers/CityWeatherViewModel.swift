//
//  CityWeatherViewModel.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/15/25.
//

import SwiftUI
import Combine

@MainActor
class CityWeatherViewModel: ObservableObject {
    @Published var weatherInfo: CityWeatherInfo?
    
    let city: City
    private let service: WeatherAPIService
    
    init(city: City, service: WeatherAPIService) {
        self.city = city
        self.service = service
        
        // Just check the cache when we init
        updateWeatherInfo()
    }
    
    func updateWeatherInfo() {
        if let weather = service.weatherCache[city.id] {
            self.weatherInfo = CityWeatherInfo(city: city, weather: weather)
        }
    }
    
    func loadWeather() async {
        await service.loadWeather(for: city)
        updateWeatherInfo()
    }
}
