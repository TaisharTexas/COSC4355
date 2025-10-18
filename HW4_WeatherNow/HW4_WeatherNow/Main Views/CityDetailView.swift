//
//  CityDetailView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import SwiftUI
import Charts

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
    @AppStorage("unitSystem") private var unitSystem = "metric"
    @State private var selectForcast: Forecast = .temp
    
    @State private var weatherInfo: CityWeatherInfo?
    
    private var currentUnitSystem: UnitSystem {
        unitSystem == "imperial" ? .imperial : .metric
    }
    
    private var temperatureUnit: TemperatureUnit {
        currentUnitSystem.temperatureUnit
    }
    
    enum Forecast: String, CaseIterable {
        case temp = "Temperature"
        case precip = "Precipitation"
        case wind = "Wind"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let info = weatherInfo {
                    WeatherDetailCard(info: info, temperatureUnit: temperatureUnit)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Picker
                    Picker("Forecast", selection: $selectForcast) {
                        ForEach(Forecast.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Chart based on selection
                    ForecastChartView(
                        info: info,
                        forecastType: selectForcast,
                        unitSystem: currentUnitSystem
                    )
                    .padding(.horizontal)
                    Divider()
                        .padding(.horizontal)
                    
                    
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
                .appFont(.caption)
                .foregroundColor(Color.wTextSubHeader)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            VStack(spacing: 2) {
                Text(data)
                    .appFont(.temperatureSmall)
                    .foregroundColor(Color.wTextHeader)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Text(unit)
                    .appFont(.caption2)
                    .foregroundColor(Color.wTextSubHeader)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            LinearGradient(
                gradient: Gradient(colors: info.colors.gradientColors),
                startPoint: info.colors.startPoint,
                endPoint: info.colors.endPoint
            )
        )
        .cornerRadius(8)
    }
}

/**
 A larger version of the favorite-city card on the home screen. Also syncs background from the weather code
 */
struct WeatherDetailCard: View {
    let info: CityWeatherInfo
    let temperatureUnit: TemperatureUnit
    
    var body: some View {
        VStack(spacing: 12) {
            Text(info.city.displayName)
                .appFont(.title3)
                .foregroundColor(.wTextHeader)
            
            Text("\(info.currentTemp(unit: temperatureUnit) ?? 0)\(info.unitSymbol(for: temperatureUnit))")
                .appFont(.temperature)
            
            Text(info.description)
                .appFont(.callout)
                .foregroundColor(.wTextBody)
            
            HStack(spacing: 20) {
                //lat
                VStack {
                    Text("Lat")
                        .appFont(.caption)
                        .foregroundColor(.wTextBody)
                    Text(String(format: "%.2f", info.city.latitude))
                        .appFont(.coordinates)
                }
                //lon
                VStack {
                    Text("Lon")
                        .appFont(.caption)
                        .foregroundColor(.wTextBody)
                    Text(String(format: "%.2f", info.city.longitude))
                        .appFont(.coordinates)
                }
                //timezone
                VStack {
                    Text("Timezone")
                        .appFont(.caption)
                        .foregroundColor(.wTextBody)
                    Text(info.timezone)
                        .appFont(.caption)
                }
            }//: Hstack
            .frame(maxWidth: .infinity)
        }//: Vstack
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
    }//: view body
}
