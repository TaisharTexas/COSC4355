//
//  ForcastChartView.swift
//  HW4_WeatherNow
//
//  Created by Andrew Lee on 10/17/25.
//

import SwiftUI
import Charts

/**
 this is the generic chart view (calls the specific chart which is defined farther down)
 */
struct ForecastChartView: View {
    let info: CityWeatherInfo
    let forecastType: CityDetailView.Forecast
    let unitSystem: UnitSystem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(chartTitle)
                .appFont(.headline)
                .foregroundColor(.wTextHeader)
            
            if hasData {
                switch forecastType {
                case .temp:
                    TemperatureChart(info: info, unitSystem: unitSystem)
                case .precip:
                    PrecipitationChart(info: info, unitSystem: unitSystem)
                case .wind:
                    WindChart(info: info, unitSystem: unitSystem)
                }
            } else {
                Text("Data not available")
                    .foregroundColor(.wTextBody)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
    
    private var hasData: Bool {
        switch forecastType {
        case .temp:
            return !info.hourlyTemps(unit: unitSystem.temperatureUnit, count: 24).isEmpty
        case .precip:
            return info.weather.hourly.precipitation_probability != nil // Changed field name
        case .wind:
            return info.weather.hourly.windspeed_10m != nil
        }
    }
    
    private var chartTitle: String {
        switch forecastType {
        case .temp:
            return "Temperature Forecast"
        case .precip:
            return "Precipitation Forecast"
        case .wind:
            return "Wind Speed Forecast"
        }
    }
}

/**
 TEMP CHART
 */
struct TemperatureChart: View {
    let info: CityWeatherInfo
    let unitSystem: UnitSystem
    
    private var chartData: [TempDataPoint] {
        // 1. Get 72 hours (3 days) of data
        let temps = info.hourlyTemps(unit: unitSystem.temperatureUnit, count: 72)
        let times = info.hourlyTimes(count: 72)
        
//        print("DEBUG TEMP: Got \(temps.count) temps and \(times.count) times")
//        print("DEBUG TEMP: First 3 temps: \(temps.prefix(3))")
//        print("DEBUG TEMP: First 3 times: \(times.prefix(3))")
        
        let now = Date()
//        print("DEBUG TEMP: Current time is \(now)")
        
        // Create a custom date formatter for the API's format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        var dataPoints: [TempDataPoint] = []
        
        for (index, (timeString, temp)) in zip(times, temps).enumerated() {
            // Parse the time string to a Date
            guard let timeDate = formatter.date(from: timeString) else {
//                print("DEBUG TEMP: Failed to parse time: \(timeString)")
                continue
            }
            
            let hoursDifference = timeDate.timeIntervalSince(now) / 3600
            
            if index < 3 {
//                print("DEBUG TEMP: Time[\(index)]: \(timeString) -> \(timeDate), hours diff: \(hoursDifference)")
            }
            
            if hoursDifference >= 0 && hoursDifference < 12 {
                // Extract just the hour for the chart axies (like "14" for 2pm)
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: timeDate)
                let hourString = String(format: "%02d", hour)
                
//                print("DEBUG TEMP: Adding point - Hour: \(hourString), Temp: \(temp)")
                
                dataPoints.append(TempDataPoint(
                    index: index,
                    hour: hourString,
                    temperature: Double(temp)
                ))
            }
        }
        
//        print("DEBUG TEMP: Total data points created: \(dataPoints.count)")
        
        return dataPoints
    }
    
    // Calculate min and max temperatures (going to scale the chart off the min and max)
    private var minTemp: Double {
        chartData.map { $0.temperature }.min() ?? 0
    }
    private var maxTemp: Double {
        chartData.map { $0.temperature }.max() ?? 100
    }
    
    // Create range with some padding for better visualization
    private var tempRange: ClosedRange<Double> {
        let padding = (maxTemp - minTemp) * 0.25 // 25% padding
        let lower = minTemp - padding
        let upper = maxTemp + padding
//        print("DEBUG TEMP: Temp range: \(lower)...\(upper)")
        return lower...upper
    }
    
    var body: some View {
//        print("DEBUG TEMP: Rendering chart with \(chartData.count) points")
        
        if chartData.isEmpty {
            return AnyView(
                Text("No temperature data available")
                    .foregroundColor(.wTextBody)
                    .frame(height: 200)
                    .onAppear {
//                        print("DEBUG TEMP: Chart data is empty!")
                    }
            )
        } else {
            return AnyView(
                Chart(chartData) { point in
                    LineMark(
                        x: .value("Hour", point.hour),
                        y: .value("Temp", point.temperature)
                    )
                    .foregroundStyle(Color.red.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Hour", point.hour),
                        y: .value("Temp", point.temperature)
                    )
                    .foregroundStyle(Color.red)
                }
                .chartYScale(domain: tempRange) // Apply the temperature range
                .chartYAxisLabel(unitSystem == .metric ? "Temperature (°C)" : "Temperature (°F)")
                .chartXAxisLabel("Hour")
                .frame(height: 200)
                .onAppear {
//                    print(" DEBUG: Chart appeared with \(chartData.count) points")
                }
            )
        }
    }
}
/**
PRECIP CHART
*/
struct PrecipitationChart: View {
    let info: CityWeatherInfo
    let unitSystem: UnitSystem
    
    private var chartData: [PrecipDataPoint] {
        // Get 72 hours (3 days) of data
        let precipProb = info.hourlyPrecipitationProbability(count: 72)
        let times = info.hourlyTimes(count: 72)
        
//        print("DEBUG PRECIP: Got \(precipProb.count) precipitation probabilities and \(times.count) times")
//        print("DEBUG PRECIP: First 3 precipitation %: \(precipProb.prefix(3))")
//        print("DEBUG PRECIP: First 3 times: \(times.prefix(3))")
        
        let now = Date()
//        print("DEBUG PRECIP: Current time is \(now)")
        
        // Create a custom date formatter for the API's format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        // Combine precipitation probability and times, filter to next 12 hours
        var dataPoints: [PrecipDataPoint] = []
        
        for (index, (timeString, probability)) in zip(times, precipProb).enumerated() {
            // Parse the time string to a Date
            guard let timeDate = formatter.date(from: timeString) else {
//                print("DEBUG PRECIP: Failed to parse time: \(timeString)")
                continue
            }
            
            // Only include if it's in the future and within 12 hours
            let hoursDifference = timeDate.timeIntervalSince(now) / 3600
            
            if index < 3 {
//                print("DEBUG PRECIP: Time[\(index)]: \(timeString) -> \(timeDate), hours diff: \(hoursDifference)")
            }
            
            if hoursDifference >= 0 && hoursDifference < 12 {
                // Extract just the hour (like "14" for 2pm)
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: timeDate)
                let hourString = String(format: "%02d", hour)
                
//                print("DEBUG PRECIP: Adding point - Hour: \(hourString), Precipitation %: \(probability)")
                
                dataPoints.append(PrecipDataPoint(
                    index: index,
                    hour: hourString,
                    precipitation: Double(probability)
                ))
            }
        }
        
//        print("DEBUG PRECIP: Total data pts created: \(dataPoints.count)")
        
        return dataPoints
    }
    
    // Fixed range for percentage (0-100%)
    private var precipRange: ClosedRange<Double> {
        return 0...100
    }
    
    var body: some View {
//        print("DEBUG PRECIP: showing precipitation chart with \(chartData.count) points")
        
        if chartData.isEmpty {
            return AnyView(
                Text("No precipitation data available")
                    .foregroundColor(.wTextBody)
                    .frame(height: 200)
                    .onAppear {
//                        print("DEBUG PRECIP: Precipitation chart data is empty!")
                    }
            )
        } else {
            return AnyView(
                Chart(chartData) { point in
                    BarMark(
                        x: .value("Hour", point.hour),
                        y: .value("Probability", max(point.precipitation, 2)) // Minimum value of 2% for visibility
                    )
                    .foregroundStyle(point.precipitation == 0 ? Color.gray.opacity(0.6).gradient : Color.blue.gradient)
                }
                .chartYScale(domain: precipRange)
                .chartYAxisLabel(unitSystem.precipitationLabel)
                .chartXAxisLabel("Hour")
                .frame(height: 200)
                .onAppear {
//                    print("DEBUG PRECIP: Precipitation chart appeared with \(chartData.count) points")
                }
            )
        }
    }
}

/**
 WIND CHART
 */
struct WindChart: View {
    let info: CityWeatherInfo
    let unitSystem: UnitSystem
    
    private var chartData: [WindDataPoint] {
        // Get 72 hours (3 days) of data
        let windSpeeds = info.hourlyWindSpeed(unitSystem: unitSystem, count: 72)
        let times = info.hourlyTimes(count: 72)
        
//        print("DEBUG WIND: Got \(windSpeeds.count) wind speeds and \(times.count) times")
//        print("DEBUG WIND: First 3 wind speeds: \(windSpeeds.prefix(3))")
//        print("DEBUG WIND: First 3 times: \(times.prefix(3))")
        
        let now = Date()
//        print("DEBUG WIND: Current time is \(now)")
        
        // Create a custom date formatter for the API's format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        var dataPoints: [WindDataPoint] = []
        
        for (index, (timeString, speed)) in zip(times, windSpeeds).enumerated() {
            // Parse the time string to a Date
            guard let timeDate = formatter.date(from: timeString) else {
//                print("DEBUG WIND: Failed to parse time: \(timeString)")
                continue
            }
            
            // Only include if it's in the future and within 12 hours
            let hoursDifference = timeDate.timeIntervalSince(now) / 3600
            
            if index < 3 {
//                print("DEBUG WIND: Time[\(index)]: \(timeString) -> \(timeDate), hours diff: \(hoursDifference)")
            }
            
            if hoursDifference >= 0 && hoursDifference < 12 {
                // Extract just the hour (like "14" for 2pm)
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: timeDate)
                let hourString = String(format: "%02d", hour)
                
//                print("DEBUG WIND: Adding point - Hour: \(hourString), Wind: \(speed)")
                
                dataPoints.append(WindDataPoint(
                    index: index,
                    hour: hourString,
                    windSpeed: speed
                ))
            }
        }
        
//        print("DEBUG WIND: Total data points created: \(dataPoints.count)")
        
        return dataPoints
    }
    
    // Calculate min and max wind speeds (to scale chart from)
    private var minWind: Double {
        chartData.map { $0.windSpeed }.min() ?? 0
    }
    
    private var maxWind: Double {
        chartData.map { $0.windSpeed }.max() ?? 50
    }
    
    // Create range with some padding for better visualization
    private var windRange: ClosedRange<Double> {
        let padding = (maxWind - minWind) * 0.1 // 10% padding
        // Keep minimum at 0 for wind speed (can't be negative)
        let upper = maxWind + padding
//        print("DEBUG WIND: Wind range: 0...\(upper)")
        return 0...upper
    }
    
    var body: some View {
//        print("DEBUG WIND: Rendering wind chart with \(chartData.count) points")
        
        if chartData.isEmpty {
            return AnyView(
                Text("No wind data available")
                    .foregroundColor(.wTextBody)
                    .frame(height: 200)
                    .onAppear {
//                        print("DEBUG WIND: Wind chart data is empty!")
                    }
            )
        } else {
            return AnyView(
                Chart(chartData) { point in
                    LineMark(
                        x: .value("Hour", point.hour),
                        y: .value("Speed", point.windSpeed)
                    )
                    .foregroundStyle(Color.green.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Hour", point.hour),
                        y: .value("Speed", point.windSpeed)
                    )
                    .foregroundStyle(Color.green.gradient.opacity(0.3))
                }
                .chartYScale(domain: windRange)
                .chartYAxisLabel(unitSystem.windSpeedLabel)
                .chartXAxisLabel("Hour")
                .frame(height: 200)
                .onAppear {
//                    print("DEBUG WIND: Wind chart appeared with \(chartData.count) points")
                }
            )
        }
    }
}


struct TempDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let hour: String
    let temperature: Double
}
struct PrecipDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let hour: String
    let precipitation: Double
}
struct WindDataPoint: Identifiable {
    let id = UUID()
    let index: Int
    let hour: String
    let windSpeed: Double
}
