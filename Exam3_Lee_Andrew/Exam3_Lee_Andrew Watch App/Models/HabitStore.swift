//
//  HabitStore.swift
//  Exam3_Lee_Andrew Watch App
//
//  Created by Andrew Lee on 11/20/25.
//

import Foundation
import SwiftUI
import Combine

struct HabitCounts: Codable {
    var byDate: [String:[Int:Int]] = [:]
}

final class HabitStore: ObservableObject {
    @Published var data = HabitCounts()
    
    private let key = "habits"
    private let df: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    init() {
        load()
    }
    
    var todayKey: String { df.string(from: Date()) }
    
    func lastNDaysKeys(_ n: Int) -> [String] {
        let cal = Calendar.current
        return (0..<n).map { i in
            if let d = cal.date(byAdding: .day, value: -i, to: Date()) {
                return df.string(from: d)
            }
            return todayKey
        }.reversed()
    }
    
    private func load() {
        guard let raw = UserDefaults.standard.data(forKey: key) else { return }
        if let decoded = try? JSONDecoder().decode(HabitCounts.self, from: raw) {
            self.data = decoded
        }
    }
    private func save() {
        if let raw = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(raw, forKey: key)
        }
    }
    
    func add(_ habit: Habit) {
        data.byDate[todayKey, default: [:]][habit.rawValue, default: 0] += 1
        save()
    }
    
    func count(forDay key: String) -> Int {
        guard let dict = data.byDate[key] else { return 0 }
        return dict.values.reduce(0, +)
    }
    
    func count(forDay key: String, habit: Habit) -> Int {
        data.byDate[key]?[habit.rawValue] ?? 0
    }
    
}
