//
//  MoodModel.swift
//  HW6_MoodApp Watch App
//
//  Created by Andrew Lee on 11/6/25.
//

import SwiftUI
import Foundation
import Combine

enum Mood: String, Codable, CaseIterable {
    case happy, okay, meh, sad
}

class MoodStorage: ObservableObject {
    @Published var moodData: [String: [String: Int]] = [:]
    
    init() {
        loadMoods()
    }
    
    // today's date in yyyy-mm-dd format
    func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // Get counts for each mood for today
    func todayCounts() -> [Mood: Int] {
        let key = todayKey()
        var counts: [Mood: Int] = [:]
        
        if let todayData = moodData[key] {
            for mood in Mood.allCases {
                counts[mood] = todayData[mood.rawValue] ?? 0
            }
        } else {
            for mood in Mood.allCases {
                counts[mood] = 0
            }
        }
        
        return counts
    }
    
    func refreshDayIfNeeded() {
        // Force UI to refresh by notifying observers
        // This ensures views update if the day changed while app was running
        objectWillChange.send()
    }
    
    // Add mood for today
    func addMood(_ mood: Mood) {
        let key = todayKey()
        
        if moodData[key] == nil {
            moodData[key] = [:]
        }
        
        let currentCount = moodData[key]?[mood.rawValue] ?? 0
        moodData[key]?[mood.rawValue] = currentCount + 1
        
        saveMoods()
    }
    
    // Total count of mood entries for today
    func totalToday() -> Int {
        return todayCounts().values.reduce(0, +)
    }
    
    // Save to user default (persistant storage)
    func saveMoods() {
        if let encoded = try? JSONEncoder().encode(moodData) {
            UserDefaults.standard.set(encoded, forKey: "moodData")
        }
    }
    
    // Load moods from user defaults
    func loadMoods() {
        guard let savedData = UserDefaults.standard.data(forKey: "moodData") else {
            moodData = [:]
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([String: [String: Int]].self, from: savedData)
            moodData = decoded
        } catch {
            print("Failed to decode moods: \(error)")
            UserDefaults.standard.removeObject(forKey: "moodData")
            moodData = [:]
        }
    }
}
