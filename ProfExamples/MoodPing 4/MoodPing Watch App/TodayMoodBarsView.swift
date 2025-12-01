//
//  TodayMoodBarsView.swift
//  MoodPing Watch App
//
//  Created by Ioannis Pavlidis on 11/5/25.
//

import SwiftUI

struct TodayMoodBarsView: View {
    let countsByMood: [Mood:Int]

    private var moods: [Mood] { Mood.allCases }
    private var maxVal: Double {
        max(1, Double(moods.map { countsByMood[$0] ?? 0 }.max() ?? 0))
    }

    private func color(for mood: Mood) -> Color {
        switch mood {
        case .happy: return .yellow       // Happy
        case .ok:    return .orange       // Ok
        case .meh:   return .gray.opacity(0.6) // Meh (light gray)
        case .sad:   return .blue         // Sad
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today by mood").font(.headline)

            GeometryReader { geo in
                let barCount = CGFloat(moods.count)
                let spacing: CGFloat = 8
                let barWidth = (geo.size.width - spacing * (barCount - 1)) / barCount

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(moods) { mood in
                        let value = Double(countsByMood[mood] ?? 0)
                        let height = CGFloat(value / maxVal) * geo.size.height

                        VStack(spacing: 4) {
                            // Bar
                            RoundedRectangle(cornerRadius: 3)
                                .fill(color(for: mood))
                                .frame(width: barWidth, height: max(2, height))
                                .accessibilityLabel(Text(mood.label))
                                .accessibilityValue(Text("\(Int(value))"))

                            // Emoji legend under each bar
                            Text(mood.emoji).font(.title3)
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
    TodayMoodBarsView(countsByMood: [.sad:1, .meh:2, .ok:3, .happy:4])
        .padding()
}
