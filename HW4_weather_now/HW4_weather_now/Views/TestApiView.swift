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
            
            // Search Box
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
            
            // Loading indicator
            if service.isLoading {
                ProgressView("Loading...")
            }
            
            // Error message
            if let error = service.errorMessage {
                Text("\(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Divider()
            
            // Search Results
            if !service.searchResults.isEmpty {
                Text("Search Results:")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(service.searchResults) { city in
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
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(item: $selectedCity) { city in
            // Weather Detail Sheet
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        if service.isLoading {
                            ProgressView("Loading weather...")
                                .padding()
                        } else if let error = service.errorMessage {
                            Text("\(error)")
                                .foregroundColor(.red)
                                .padding()
                        } else if let weather = service.currentWeather {
                            // Current Weather Card
                            VStack(spacing: 12) {
                                Text("\(city.displayName)")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                
                                if let current = weather.current {
                                    Text("\(Int(current.temperature_2m))°C")
                                        .font(.system(size: 60, weight: .thin))
                                    
                                    Text(service.weatherDescription(code: current.weathercode))
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("Lat")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.2f", weather.latitude))
                                            .font(.caption)
                                    }
                                    VStack {
                                        Text("Lon")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.2f", weather.longitude))
                                            .font(.caption)
                                    }
                                    VStack {
                                        Text("Timezone")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(weather.timezone)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Hourly Forecast
                            VStack(alignment: .leading, spacing: 12) {
                                Text("24-Hour Forecast")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(0..<min(24, weather.hourly.time.count), id: \.self) { i in
                                            VStack(spacing: 8) {
                                                Text(formatTime(weather.hourly.time[i]))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text("\(Int(weather.hourly.temperature_2m[i]))°")
                                                    .font(.title3)
                                                    .bold()
                                                
                                                if let code = weather.hourly.weathercode?[i] {
                                                    Text(service.weatherDescription(code: code))
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
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
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
    }
    
    private func formatTime(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }
}

// Preview
#Preview {
    TestApiView()
}
