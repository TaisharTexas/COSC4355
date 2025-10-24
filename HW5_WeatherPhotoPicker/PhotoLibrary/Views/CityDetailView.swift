//
//  CityDetailView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import SwiftUI
import Charts

struct CityDetailView: View {
    let city: City
    @ObservedObject var service: WeatherAPIService
    @Environment(WeatherImageStore.self) private var photoStore
    @AppStorage("unitSystem") private var unitSystem = "metric"
    @State private var weatherInfo: CityWeatherInfo?
    
    private var currentUnitSystem: UnitSystem {
        unitSystem == "imperial" ? .imperial : .metric
    }
    
    private var temperatureUnit: TemperatureUnit {
        currentUnitSystem.temperatureUnit
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let info = weatherInfo {
                    WeatherDetailCard(info: info, temperatureUnit: temperatureUnit)

                    Divider()
                    
                    // Today ata Glance
                    HStack(spacing: 12){
                        //min temp
                        if let minTemp = info.todayMinTemp(unit: temperatureUnit) {
                            TodayGlanceCard(info: info, title: "Min Temp", data: String(minTemp), unit: temperatureUnit == .celsius ? "°C" : "°F")
                        } else {
                            TodayGlanceCard(info: info, title: "Min Temp", data: "--", unit: temperatureUnit == .celsius ? "°C" : "°F")
                        }
                        //max temp
                        if let maxTemp = info.todayMaxTemp(unit: temperatureUnit) {
                            TodayGlanceCard(info: info, title: "Max Temp", data: String(maxTemp), unit: temperatureUnit == .celsius ? "°C" : "°F")
                        } else {
                            TodayGlanceCard(info: info, title: "Max Temp", data: "--", unit: temperatureUnit == .celsius ? "°C" : "°F")
                        }
                        //precip chance
                        if let precipProb = info.currentPrecipitationProbability{
                            TodayGlanceCard(info: info, title: "Precip", data: String(precipProb), unit: "%")
                        }
                        else{
                            TodayGlanceCard(info: info, title: "Precip", data: "--", unit: "%")
                        }
                        //wind spd
                        if let windSpeed = info.currentWindSpeed(unitSystem: currentUnitSystem){
                            TodayGlanceCard(info: info, title: "Wind", data: String(format: "%.0f", windSpeed), unit: currentUnitSystem == .metric ? "km/h" : "mph")
                        }
                        else{
                            TodayGlanceCard(info: info, title: "Wind", data: "--", unit: currentUnitSystem == .metric ? "km/h" : "mph")
                        }
                        
                        
                    }//: end today ata glance hstack
                    .padding(.horizontal)
                        
                } else {
                    ProgressView("Loading weather...")
                }
                
//                Divider()
                
                
            }
            .frame(maxWidth: .infinity)
        }//: Scrollview
        .navigationTitle(city.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
            }
            
        }//: toolbar
        .task {
            await service.loadWeather(for: city)
            if let weather = service.weatherCache[city.id] {
                weatherInfo = CityWeatherInfo(city: city, weather: weather)
                print("DEBUG DETAILVIEW: Weather code for \(city.name): \(weatherInfo?.weatherCode ?? -1)")
                print("DEBUG DETAILVIEW: Weather description: \(weatherInfo?.description ?? "unknown")")
            }
        }//: task
        
    }//:end body view
}

/**
 Small single data point cards that together are used to give a quick glance of the current weather
 */
struct TodayGlanceCard: View{
    let info: CityWeatherInfo //ended up having to pass info to get the colors to sync
    let title: String // temp/precip/wind
    let data: String // the associated value
    let unit: String // metric/imperial
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            VStack(spacing: 2) {
                Text(data)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

/**
 A larger version of the favorite-city card on the home screen. Also syncs background from the weather code
 */
struct WeatherDetailCard: View {
    @Environment(WeatherImageStore.self) private var photoStore
    let info: CityWeatherInfo
    let temperatureUnit: TemperatureUnit
    
    var body: some View {
        VStack(spacing: 12) {
//            Text(info.city.displayName)
            VStack(spacing: 8) {
                Text("\(info.currentTemp(unit: temperatureUnit) ?? 0)\(info.unitSymbol(for: temperatureUnit))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(info.description)
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background {
                if let image = photoStore.getImage(forWeatherCode: info.weatherCode) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay {
                            Color.black.opacity(0.3)
                        }
                } else {
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .blue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .clipped()

            
            HStack(spacing: 20) {
                VStack {
                    Text("Lat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f", info.city.latitude))
                        .font(.subheadline)
                }
                
                VStack {
                    Text("Lon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.2f", info.city.longitude))
                        .font(.subheadline)
                }
                
                VStack {
                    Text("Timezone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(info.timezone)
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.2))
        }//: Vstack
        .cornerRadius(12)
        .padding(.horizontal)
    }//: view body
}
