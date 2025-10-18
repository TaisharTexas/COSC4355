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
    let daily: DailyData?
    
    struct HourlyData: Codable {
        let time: [String]
        let temperature_2m: [Double]
        let precipitation_probability: [Int]?
        let weathercode: [Int]?
        let windspeed_10m: [Double]?
    }
    
    struct CurrentData: Codable {
        let temperature_2m: Double
        let weathercode: Int
        let precipitation_probability: Int?
        let windspeed_10m: Double?
    }
    
    struct DailyData: Codable {
        let time: [String]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
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
    @Published var weatherCache: [Int: WeatherData] = [:] {
        didSet {
            print("DEBUG API: weatherCache didSet triggered, now contains \(weatherCache.count) cities")
        }
    }
    private var loadingCities: Set<Int> = []
    
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
        // Check if already cached
        if weatherCache[city.id] != nil {
            print("DEBUG API: Using cached weather for \(city.name)")
            return
        }
        
        print(" DEBUG API: Fetching weather from API for \(city.name)")
        // Check if already loading
        guard !loadingCities.contains(city.id) else {
            return
        }
        
        loadingCities.insert(city.id)
        defer { loadingCities.remove(city.id) }
        
        do {
            errorMessage = nil
            var components = URLComponents(string: "\(weatherBase)/forecast")!
            components.queryItems = [
                URLQueryItem(name: "latitude", value: String(city.latitude)),
                URLQueryItem(name: "longitude", value: String(city.longitude)),
                URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,weathercode,windspeed_10m"),
                URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min"),
                URLQueryItem(name: "current", value: "temperature_2m,weathercode,weathercode,precipitation_probability,windspeed_10m"),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "forecast_days", value: "7")
            ]
            
            let (data, _) = try await session.data(from: components.url!)
            let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
            self.weatherCache[city.id] = decoded
        } catch {
            self.errorMessage = "Failed to load weather: \(error.localizedDescription)"
        }
    }
    
    // Helper to decode weather codes
    //OLD
    func weatherDescription(code: Int) -> [String] {
        switch code {
        case 0: return ["Clear sky", "sun.max.fill"]
        case 1, 2, 3: return ["Partly cloudy", "cloud.sun.fill"]
        case 45, 48: return ["Foggy", "cloud.fill"]
        case 51, 53, 55: return ["Drizzle", "cloud.sun.rain.fillcloud.heavyrain.fill"]
        case 61, 63, 65: return ["Rain", "cloud.heavyrain.fill"]
        case 71, 73, 75: return ["Snow", "cloud.snow.fill"]
        case 95: return ["Thunderstorm", "cloud.bolt.rain.fill"]
        default: return ["Unknown", "questionmark.circle.dashed"]
        }
    }
    
    func loadWeatherForCities(_ cities: [City]) async {
        await withTaskGroup(of: Void.self) { group in
            for city in cities {
                group.addTask {
                    await self.loadWeather(for: city)
                }
            }
        }
    }
    
    func clearAllData() {
        // Clear weather cache
        weatherCache.removeAll()
        searchResults = []
        errorMessage = nil
        
        // Clear UserDefaults (persistent storage)
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
    func clearFavorites() {
        // If your FavoritesStore uses UserDefaults, add this to that class instead:
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
