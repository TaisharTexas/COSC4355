//
//  WeatherCardDeets.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/16/25.
//

import SwiftUI

struct WeatherCardDeets: View {
    let info: CityWeatherInfo
    
    @AppStorage("temperatureUnit") private var tempUnit = "celsius"
    
    private var temperatureUnit: TemperatureUnit {
        tempUnit == "fahrenheit" ? .fahrenheit : .celsius
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(info.city.name)
                    .font(.largeTitle)
                    .foregroundColor(Color.wTextHeader)
                Text(info.city.country)
                    .font(.subheadline)
                    .foregroundColor(Color.wTextDefault)
                Text("\(info.city.latitude), \(info.city.longitude)")
                    .font(.footnote)
                    .foregroundColor(.wTextField)
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
                    .foregroundColor(.wTextDefault)
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
    
