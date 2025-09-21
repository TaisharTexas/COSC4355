//
//  UserData.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/19/25.
//

import SwiftUI
import SwiftData
import Combine

class UserData: ObservableObject {
    @Published var favoriteIDs: Set<Int> = []
    
    init() {
        load()
    }
    
    func toggleFavorite(for park: CatalogItem) {
        if favoriteIDs.contains(park.id) {
            favoriteIDs.remove(park.id)
        } else {
            favoriteIDs.insert(park.id)
        }
        save()
    }
    
    private func save() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: "favorites")
    }
    
    private func load() {
        if let saved = UserDefaults.standard.array(forKey: "favorites") as? [Int] {
            favoriteIDs = Set(saved)
        }
    }
}
