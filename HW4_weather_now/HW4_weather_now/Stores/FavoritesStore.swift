//
//  FavoritesStore.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/12/25.
//

import Combine
import Foundation

@MainActor
final class FavoritesStore: ObservableObject{
    @Published private(set) var cities: [City] = []
    private let key = "favoriteCities"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([City].self, from: data) {
            self.cities = decoded
        }
    }
    
    //Toggle a city in or out of favorites
    func toggle(_ city: City) {
        // Use the city's id (which is unique from the API) to find it
        if let idx = cities.firstIndex(where: { $0.id == city.id }) {
            cities.remove(at: idx)
        } else {
            cities.append(city)
        }
        persist()
    }
    
    // Check if a city is favorited
    func contains(_ city: City) -> Bool {
        cities.contains(where: { $0.id == city.id })
    }
    
    // Save to UserDefaults
    private func persist() {
        if let data = try? JSONEncoder().encode(cities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
}
