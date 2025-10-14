//
//  WeatherAPIService.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/12/25.
//

import Combine
import Foundation

struct City: Identifiable, Codable, Hashable {
    var id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let admin1: String?
    
    var displayName: String {
        if let admin = admin1 {
            return "\(name), \(admin), \(country)"
        }
        return "\(name), \(country)"
    }
}

struct WeatherData: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let hourly: HourlyData
    let current: CurrentData?
    
    struct HourlyData: Codable {
        let time: [String]
        let temperature_2m: [Double]
        let precipitation: [Double]?
        let weathercode: [Int]?
    }
    
    struct CurrentData: Codable {
        let temperature_2m: Double
        let weathercode: Int
    }
}

struct GeocodingResponse: Codable {
    let results: [City]?
}

@MainActor
final class WeatherAPIService: ObservableObject {
    // Published properties that views observe
    @Published var searchResults: [City] = []
    @Published var currentWeather: WeatherData?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // Custom session with timeout
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }()
    
    private let geocodingBase = "https://geocoding-api.open-meteo.com/v1"
    private let weatherBase = "https://api.open-meteo.com/v1"
    
    // Search for cities
    func searchCities(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            errorMessage = nil
            var components = URLComponents(string: "\(geocodingBase)/search")!
            components.queryItems = [
                URLQueryItem(name: "name", value: query),
                URLQueryItem(name: "count", value: "10"),
                URLQueryItem(name: "language", value: "en"),
                URLQueryItem(name: "format", value: "json")
            ]
            
            let (data, _) = try await session.data(from: components.url!)
            let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
            self.searchResults = decoded.results ?? []
        } catch {
            self.errorMessage = "Search failed: \(error.localizedDescription)"
            self.searchResults = []
        }
    }
    
    // Load weather for a city
    func loadWeather(for city: City) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            errorMessage = nil
            var components = URLComponents(string: "\(weatherBase)/forecast")!
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(city.latitude)),
                URLQueryItem(name: "longitude", value: String(city.longitude)),
                URLQueryItem(name: "hourly", value: "temperature_2m,precipitation,weathercode"),
                URLQueryItem(name: "current", value: "temperature_2m,weathercode"),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "forecast_days", value: "7")
            ]
            
            let (data, _) = try await session.data(from: components.url!)
            let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
            self.currentWeather = decoded
        } catch {
            self.errorMessage = "Failed to load weather: \(error.localizedDescription)"
            self.currentWeather = nil
        }
    }
    
    // Helper to decode weather codes
    func weatherDescription(code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1, 2, 3: return "Partly cloudy"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 95: return "Thunderstorm"
        default: return "Unknown"
        }
    }
}
