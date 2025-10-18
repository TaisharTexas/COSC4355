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
            // Left side of card
            VStack(alignment: .leading) {
                //City Name
                Text(info.city.name)
                    .appFont(.title)
                    .foregroundColor(Color.wTextHeader)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                //If city is in US, show state, otherwise show Country
                if info.city.country == "United States", let admin = info.city.admin1 {
                    Text(admin)
                        .appFont(.headline)
                        .foregroundColor(Color.wTextSubHeader)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                else{
                    Text(info.city.country)
                        .appFont(.title2)
                        .foregroundColor(Color.wTextSubHeader)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                // Lat/Lon for city
                Text("\(info.city.latitude), \(info.city.longitude)")
                    .appFont(.coordinates)
                    .foregroundColor(.wTextBody)
            }//: end VStack
            Spacer()
            
            // Right side of card
            VStack {
                HStack {
                    // Current Temp of city
                    Text("\(info.currentTemp(unit: temperatureUnit) ?? 0)\(info.unitSymbol(for: temperatureUnit))")
                        .appFont(.largeTitle)
                        .foregroundColor(.wTextHeader)
                    // icon reflecting current weather (from weathercode)
                    Image(systemName: info.icon)
                        .foregroundColor(.wTextHeader)
                        .appFont(.title)
                }
                // description of weather (from weathercode)
                Text(info.description)
                    .appFont(.caption)
                    .foregroundColor(.wTextBody)
            }//: end VStack
        }//: end HStack
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
    
