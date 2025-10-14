//
//  CityDetailView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/13/25.
//

import Foundation
import SwiftUI
import SwiftData

struct CityDetailView: View {
    
    let city: City
    @ObservedObject var service: WeatherAPIService
    @EnvironmentObject var favorites: FavoritesStore
    
    var body: some View {
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
                }
            }//: VStack
            .padding(.vertical)
        }//: Scroll View
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    favorites.toggle(city)
                }) {
                    Image(systemName: favorites.contains(city) ? "star.fill" : "star")
                        .foregroundColor(favorites.contains(city) ? .yellow : .gray)
                }
            }
        }//: Favorite toggle
        .task {
            await service.loadWeather(for: city)
        }//: Task
    }//: Body View
}//: Struct View



