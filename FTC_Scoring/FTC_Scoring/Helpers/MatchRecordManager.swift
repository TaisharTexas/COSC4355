//
//  MatchRecordManager.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 11/19/25.
//

import Foundation
import Combine
import SwiftUI

class MatchStorageManager: ObservableObject {
    @Published var savedMatches: [MatchRecord] = []
    
    private let matchesKey = "savedMatches"
    
    init() {
        loadMatches()
    }
    
    func saveMatch(_ match: MatchRecord) -> Bool {
        savedMatches.append(match)
        return saveToUserDefaults()
    }
    
    func saveToUserDefaults() -> Bool {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedMatches)
            UserDefaults.standard.set(data, forKey: matchesKey)
            return true
        } catch {
            print("Error encoding matches: \(error)")
            return false
        }
    }
    
    func loadMatches() {
        guard let data = UserDefaults.standard.data(forKey: matchesKey) else {
            savedMatches = []
            return
        }
        
        do {
            let decoder = JSONDecoder()
            savedMatches = try decoder.decode([MatchRecord].self, from: data)
        } catch {
            print("Error decoding matches: \(error)")
            savedMatches = []
        }
    }
    
    func deleteMatch(at offsets: IndexSet) {
        savedMatches.remove(atOffsets: offsets)
        _ = saveToUserDefaults()
    }
    
    func deleteAllMatches() {
        savedMatches = []
        _ = saveToUserDefaults()
    }
}
