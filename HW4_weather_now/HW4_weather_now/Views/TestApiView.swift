//
//  TestApiView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/12/25.
//

import SwiftUI

struct TestApiView: View {
    @StateObject private var service = WeatherAPIService()
    @State private var searchText = ""
    @State private var selectedCity: City?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Testing API and functions")
                .font(.largeTitle)
                .bold()
            
            searchSection
            
            if service.isLoading {
                ProgressView("Loading...")
            }
            
            if let error = service.errorMessage {
                Text("\(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Divider()
            
            searchResultsSection
            
            Spacer()
        }
        .padding()
        .sheet(item: $selectedCity) { city in
            WeatherDetailSheet(city: city, service: service, selectedCity: $selectedCity)
        }
    }
    
    private var searchSection: some View {
        HStack {
            TextField("Enter city name", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button("Search") {
                Task {
                    await service.searchCities(query: searchText)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
    }
    
    private var searchResultsSection: some View {
        Group {
            if !service.searchResults.isEmpty {
                Text("Search Results:")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(service.searchResults) { city in
                            searchResultButton(for: city)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func searchResultButton(for city: City) -> some View {
        Button(action: {
            selectedCity = city
        }) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(city.name)")
                    .font(.headline)
                Text("\(city.displayName)")
                    .font(.subheadline)
                Text("\(city.latitude), \(city.longitude)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// Separate view for the weather detail sheet
struct WeatherDetailSheet: View {
    let city: City
    @ObservedObject var service: WeatherAPIService
    @Binding var selectedCity: City?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    contentView
                }
                .padding(.vertical)
            }
            .navigationTitle(city.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedCity = nil
                    }
                }
            }
            .task {
                await service.loadWeather(for: city)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if service.isLoading {
            ProgressView("Loading weather...")
                .padding()
        } else if let error = service.errorMessage {
            Text("\(error)")
                .foregroundColor(.red)
                .padding()
        } else if let weather = service.weatherCache[city.id] {
            currentWeatherCard(weather: weather)
            hourlyForecast(weather: weather)
        }
    }
    
    private func currentWeatherCard(weather: WeatherData) -> some View {
        VStack(spacing: 12) {
            Text("\(city.displayName)")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if let current = weather.current {
                Text("\(Int(current.temperature_2m))°C")
                    .font(.system(size: 60, weight: .thin))
                
                let description = service.weatherDescription(code: current.weathercode)
                Text(description[0])
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                weatherInfoItem(title: "Lat", value: String(format: "%.2f", weather.latitude))
                weatherInfoItem(title: "Lon", value: String(format: "%.2f", weather.longitude))
                weatherInfoItem(title: "Timezone", value: weather.timezone)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func weatherInfoItem(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
        }
    }
    
    private func hourlyForecast(weather: WeatherData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("24-Hour Forecast")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<min(24, weather.hourly.time.count), id: \.self) { i in
                        hourlyForecastCard(weather: weather, index: i)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func hourlyForecastCard(weather: WeatherData, index: Int) -> some View {
        VStack(spacing: 8) {
            Text(formatTime(weather.hourly.time[index]))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(Int(weather.hourly.temperature_2m[index]))°")
                .font(.title3)
                .bold()
            
            if let code = weather.hourly.weathercode?[index] {
                let description = service.weatherDescription(code: code)
                Text(description[0])
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }
}

#Preview {
    TestApiView()
}
