//
//  WeatherColors.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/15/25.
//

import SwiftUI

/**
 This is all the variables and helper methods to get data in the needed formats from the API queries
 */
struct CityWeatherInfo {
    let city: City
    let weather: WeatherData
    
    /**
     Grabs current Temp (handles metric and imperial)
     */
    var currentTempCelsius: Int? {
        guard let current = weather.current else { return nil }
        return Int(current.temperature_2m)
    }
    var currentTempFahrenheit: Int? {
        guard let celsius = currentTempCelsius else { return nil }
        return Int(Double(celsius) * 9/5 + 32)
    }
    func currentTemp(unit: TemperatureUnit) -> Int? {
        switch unit {
        case .celsius: return currentTempCelsius
        case .fahrenheit: return currentTempFahrenheit
        }
    }
    
    func unitSymbol(for unit: TemperatureUnit) -> String {
        switch unit {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
    
    var weatherCode: Int {
        weather.current?.weathercode ?? 0
    }
    
    var description: String {
        WeatherDescriptions.text(for: weatherCode)
    }
    
    var icon: String {
        WeatherDescriptions.icon(for: weatherCode)
    }
    
    var colors: WeatherColors {
        WeatherDescriptions.colors(for: weatherCode)
    }
    
    var timezone: String {
        weather.timezone
    }
    
    // Hourly forecast helpers
    /**
     hours temps from the forecast api + handling for imperial and metric
     */
    func hourlyTempsCelsius(count: Int = 24) -> [Int] {
            Array(weather.hourly.temperature_2m.prefix(count)).map { Int($0) }
    }
    func hourlyTempsFahrenheit(count: Int = 24) -> [Int] {
        hourlyTempsCelsius(count: count).map { Int(Double($0) * 9/5 + 32) }
    }
    func hourlyTemps(unit: TemperatureUnit, count: Int = 24) -> [Int] {
        switch unit {
        case .celsius: return hourlyTempsCelsius(count: count)
        case .fahrenheit: return hourlyTempsFahrenheit(count: count)
        }
    }
    
    /**
     Grabs the non-unit-specific values like time and the weather code
     */
    func hourlyTimes(count: Int = 24) -> [String] {
        Array(weather.hourly.time.prefix(count))
    }
    
    func hourlyWeatherCodes(count: Int = 24) -> [Int]? {
        guard let codes = weather.hourly.weathercode else { return nil }
        return Array(codes.prefix(count))
    }
    
    /**
     Grabs precip probability from the API
     */
    func hourlyPrecipitationProbability(count: Int = 24) -> [Int] {
        guard let precipProb = weather.hourly.precipitation_probability else { return [] }
        return Array(precipProb.prefix(count))
    }

    /**
     hourly wind predictions from forecase api + stuff to handle imperial vs metric
     */
    func hourlyWindSpeedKmh(count: Int = 24) -> [Double] {
        guard let wind = weather.hourly.windspeed_10m else { return [] }
        return Array(wind.prefix(count))
    }
    func hourlyWindSpeedMph(count: Int = 24) -> [Double] {
        // Convert km/h to mph (1 km/h = 0.621371 mph)
        hourlyWindSpeedKmh(count: count).map { $0 * 0.621371 }
    }
    func hourlyWindSpeed(unitSystem: UnitSystem, count: Int = 24) -> [Double] {
        switch unitSystem {
        case .metric: return hourlyWindSpeedKmh(count: count)
        case .imperial: return hourlyWindSpeedMph(count: count)
        }
    }
    
    /**
     Handles getting today's temps for the Today ata Glance part
     */
    var todayMinTempCelsius: Int? {
        guard let daily = weather.daily,
              !daily.temperature_2m_min.isEmpty else { return nil }
        return Int(daily.temperature_2m_min[0])
    }

    var todayMaxTempCelsius: Int? {
        guard let daily = weather.daily,
              !daily.temperature_2m_max.isEmpty else { return nil }
        return Int(daily.temperature_2m_max[0])
    }

    // Convert to Fahrenheit
    var todayMinTempFahrenheit: Int? {
        guard let celsius = todayMinTempCelsius else { return nil }
        return Int(Double(celsius) * 9/5 + 32)
    }

    var todayMaxTempFahrenheit: Int? {
        guard let celsius = todayMaxTempCelsius else { return nil }
        return Int(Double(celsius) * 9/5 + 32)
    }
    
    func todayMinTemp(unit: TemperatureUnit) -> Int? {
        switch unit {
        case .celsius: return todayMinTempCelsius
        case .fahrenheit: return todayMinTempFahrenheit
        }
    }

    func todayMaxTemp(unit: TemperatureUnit) -> Int? {
        switch unit {
        case .celsius: return todayMaxTempCelsius
        case .fahrenheit: return todayMaxTempFahrenheit
        }
    }
    
    /**
     Handles getting current precip prob and wind spd for Today ata Glace
     */
    // Current precipitation probability
    var currentPrecipitationProbability: Int? {
        weather.current?.precipitation_probability
    }

    // Current wind speed (in km/h from API)
    var currentWindSpeedKmh: Double? {
        weather.current?.windspeed_10m
    }

    var currentWindSpeedMph: Double? {
        guard let kmh = currentWindSpeedKmh else { return nil }
        return kmh * 0.621371
    }

    func currentWindSpeed(unitSystem: UnitSystem) -> Double? {
        switch unitSystem {
        case .metric: return currentWindSpeedKmh
        case .imperial: return currentWindSpeedMph
        }
    }

    func windSpeedUnit(for unitSystem: UnitSystem) -> String {
        switch unitSystem {
        case .metric: return "km/h"
        case .imperial: return "mph"
        }
    }

}//:end struct CityWeatherInfo

enum TemperatureUnit: String {
    case celsius
    case fahrenheit
}

enum UnitSystem: String {
    case metric
    case imperial
    
    var temperatureUnit: TemperatureUnit {
        switch self {
        case .metric: return .celsius
        case .imperial: return .fahrenheit
        }
    }
    
    var windSpeedLabel: String {
        switch self {
        case .metric: return "Wind Speed (km/h)"
        case .imperial: return "Wind Speed (mph)"
        }
    }
    
    var precipitationLabel: String {
        return "Chance of Rain (%)"
    }
}

/**
 Converts the weather codes to descriptions, icons, and color gradients for the display cards
 */
enum WeatherDescriptions {
    static func text(for code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1, 2, 3: return "Partly cloudy"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 56, 57: return "Freezing Drizzle"
        case 61, 63, 65: return "Rain"
        case 66, 67: return "Freezing Rain"
        case 71, 73, 75, 77: return "Snow"
        case 80, 81, 82: return "Rain Showers"
        case 85, 86: return "Snow Showers"
        case 95, 96, 99: return "Thunderstorm"
        default: return "Unknown"
        }//: end switch
    }//:end text func
    
    static func icon(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1, 2, 3: return "cloud.sun.fill"
        case 45, 48: return "cloud.fill"
        case 51, 53, 55: return "cloud.sun.rain.fill"
        case 61, 63, 65, 80, 81, 82: return "cloud.heavyrain.fill"
        case 71, 73, 75, 77, 85, 86, 66, 67, 56, 57: return "cloud.snow.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default: return "questionmark.circle.dashed"
        }//:end switch
    }//:end icon func
    
    static func colors(for code: Int) -> WeatherColors {
        switch code {
            // Sunny
        case 0: return WeatherColors(
            topColor: .wClearSky1.opacity(0.6),
            middleColor: .wClearSky1.opacity(0.5),
            bottomColor: .wClearSky2.opacity(0.7),
            accentColor: .red,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
            //partly cloudy
        case 1, 2, 3: return WeatherColors(
            topColor: .wPCloudy1.opacity(0.8),
            middleColor: .wPCloudy2.opacity(0.7),
            bottomColor: .wPCloudy3.opacity(0.5),
            accentColor: .red,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
            //foggy
        case 45, 48: return WeatherColors(
            topColor: .wFoggy1.opacity(0.8),
            middleColor: .wFoggy2.opacity(0.7),
            bottomColor: .wFoggy3.opacity(0.5),
            accentColor: .gray,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
            //rain
        case 51, 53, 55, 61, 63, 65: return WeatherColors(
            topColor: .wRain1.opacity(0.6),
            middleColor: .wRain1.opacity(0.5),
            bottomColor: .wRain2.opacity(0.7),
            accentColor: .blue,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
            //Snow
        case 71, 73, 75: return WeatherColors(
            topColor: .wSnow1.opacity(0.6),
            middleColor: .wSnow2.opacity(0.5),
            bottomColor: .wSnow3.opacity(0.7),
            accentColor: .cyan,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
            //T Storm
        case 95: return WeatherColors(
            topColor: .wTRain1.opacity(0.8),
            middleColor: .wTRain2.opacity(0.7),
            bottomColor: .wTRain3.opacity(0.5),
            accentColor: .purple,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
            //default
        default: return WeatherColors(
            topColor: .wTRain1.opacity(0.8),
            middleColor: .wTRain2.opacity(0.7),
            bottomColor: .wTRain3.opacity(0.5),
            accentColor: .gray,
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
        }//:end swtich
    }//:end colors func
}//: end enum

//: define the colors types for each type of weather so I can customize the cards based on the weather code
struct WeatherColors {
    let topColor: Color
    let middleColor: Color?
    let bottomColor: Color
    let accentColor: Color
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    // I dont always want 3 colors for the gradient on the fav city cards
    // This allows me to use either 2 or 3 for the cards
    var gradientColors: [Color] {
        if let middle = middleColor {
            return [topColor, middle, bottomColor]
        } else {
            return [topColor, bottomColor]
        }
    }//: end var
    
    // Just the constructor basically
    init(topColor: Color, middleColor: Color? = nil, bottomColor: Color, accentColor: Color, startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
        self.topColor = topColor
        self.middleColor = middleColor
        self.bottomColor = bottomColor
        self.accentColor = accentColor
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
}//: end weather colors struct
