//
//  TodayByMood.swift
//  HW6_MoodApp Watch App
//
//  Created by Andrew Lee on 11/6/25.
//

import SwiftUI

struct TodayByMood: View {
    @ObservedObject var moodStorage: MoodStorage
    
    var moodCounts: [Mood: Int] {
        moodStorage.todayCounts()
    }
    
    var maxCount: Int {
        max(moodCounts.values.max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Total today: \(moodStorage.totalToday())")
                .font(.headline)
                .monospacedDigit()
                .padding(.bottom, 5)
            
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 15) {
                    // Happy bar - YELLOW
                    MoodBar(
                        emoji: "😊",
                        count: moodCounts[.happy] ?? 0,
                        color: .yellow,
                        maxCount: maxCount,
                        width: (geometry.size.width - 45) / 4,
                        maxHeight: geometry.size.height - 40
                    )
                    
                    // Okay bar - ORANGE
                    MoodBar(
                        emoji: "🙂",
                        count: moodCounts[.okay] ?? 0,
                        color: .orange,
                        maxCount: maxCount,
                        width: (geometry.size.width - 45) / 4,
                        maxHeight: geometry.size.height - 40
                    )
                    
                    // Meh bar - LIGHT GRAY
                    MoodBar(
                        emoji: "😐",
                        count: moodCounts[.meh] ?? 0,
                        color: Color(.lightGray),
                        maxCount: maxCount,
                        width: (geometry.size.width - 45) / 4,
                        maxHeight: geometry.size.height - 40
                    )
                    
                    // Sad bar - BLUE
                    MoodBar(
                        emoji: "😢",
                        count: moodCounts[.sad] ?? 0,
                        color: .blue,
                        maxCount: maxCount,
                        width: (geometry.size.width - 45) / 4,
                        maxHeight: geometry.size.height - 40
                    )
                }//: end graph box hstack
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }//: end geo reader
            .frame(height: 150)
        }//: end VStack
        .padding()
    }
}

struct MoodBar: View {
    let emoji: String
    let count: Int
    let color: Color
    let maxCount: Int
    let width: CGFloat
    let maxHeight: CGFloat
    
    var barHeight: CGFloat {
        if maxCount == 0 { return 2 }
        let calculatedHeight = CGFloat(count) / CGFloat(maxCount) * maxHeight
        return max(calculatedHeight, 2)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.caption)
                .monospacedDigit()
            
            Rectangle()
                .fill(color)
                .frame(width: width, height: barHeight)
                .animation(.easeInOut(duration: 0.3), value: count) 
            
            Text(emoji)
                .font(.caption)
        }
    }
}

