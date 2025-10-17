//
//  WeatherCardDeets.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/16/25.
//

import SwiftUI

/**
 This is the view for the loaded favorite cities
 */

struct FavCity_WeatherDetailsView: View {
    let info: CityWeatherInfo
    
    @AppStorage("unitSystem") private var unitSystem = "metric"
    
    private var currentUnitSystem: UnitSystem {
        unitSystem == "imperial" ? .imperial : .metric
    }
    
    private var temperatureUnit: TemperatureUnit {
        currentUnitSystem.temperatureUnit
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(info.city.name)
                    .font(.largeTitle)
                    .foregroundColor(Color.wTextHeader)
                if info.city.country == "United States", let admin = info.city.admin1 {
                    Text(admin)
                        .font(.title2)
                        .foregroundColor(Color.wTextSubHeader)
                }
                else{
                    Text(info.city.country)
                        .font(.title2)
                        .foregroundColor(Color.wTextSubHeader)
                }
                Text("\(info.city.latitude), \(info.city.longitude)")
                    .font(.footnote)
                    .foregroundColor(.wTextBody)
            }
            Spacer()
            
            VStack {
                HStack {
                    Text("\(info.currentTemp(unit: temperatureUnit) ?? 0)\(info.unitSymbol(for: temperatureUnit))")
                        .font(.largeTitle)
                        .foregroundColor(.wTextHeader)
                    Image(systemName: info.icon)
                        .foregroundColor(.wTextHeader)
                        .font(.largeTitle)
                }
                Text(info.description)
                    .font(.caption)
                    .foregroundColor(.wTextBody)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: info.colors.gradientColors),
                startPoint: info.colors.startPoint,
                endPoint: info.colors.endPoint
            )
        )
        .cornerRadius(12)
    }
}
    
