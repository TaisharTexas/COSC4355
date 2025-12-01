//
//  TodayHabitGraph.swift
//  MoodPing Watch App
//
//  Created by Andrew Lee on 11/20/25.
//

import SwiftUI

struct TodayHabitGraph: View {
    let countsByHabit: [Habit:Int]

    private var habits: [Habit] { Habit.allCases }
    private var maxVal: Double {
        max(1, Double(habits.map { countsByHabit[$0] ?? 0 }.max() ?? 0))
    }

    private func color(for habit: Habit) -> Color {
        switch habit {
        case .water:   return .blue
        case .move:    return .orange
        case .breath:  return .green
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Today Summary").font(.headline)
            
            Divider()

            GeometryReader { geo in
                let barCount = CGFloat(habits.count)
                let spacing: CGFloat = 8
                let barHeight = (geo.size.height - spacing * (barCount - 1)) / barCount

                    
                VStack(alignment: .leading){
                    ForEach(habits) { habit in
                        let value = Double(countsByHabit[habit] ?? 0)
                        let width = CGFloat(value / maxVal) * (geo.size.width * 0.7)
                        
                        HStack(alignment: .center, spacing: 6){
                            Image(systemName: habit.icon)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(color(for: habit))
                                .frame(width: max(2, width), height: barHeight)
                                .accessibilityLabel(Text(habit.label))
                                .accessibilityValue(Text("\(Int(value))"))
                            Text("\(Int(value))")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
            }
            .frame(height: 90)
        }
    }
}

#Preview {
    TodayHabitGraph(countsByHabit: [.water:5, .move:2, .breath:3])
        .padding()
}
