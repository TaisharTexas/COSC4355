import SwiftUI
import WatchKit
import Combine

fileprivate func playProminentTap() {
    // A slightly stronger, more noticeable pattern:
    // small pre-tap then a success tap
    let dev = WKInterfaceDevice.current()
    dev.play(.start)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
        dev.play(.success)
    }
}

struct ContentView: View {
    @StateObject private var store = MoodStore()

    
    
    @State private var lastHaptic = Date.distantPast
    @Environment(\.scenePhase) private var scenePhase
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    @State private var _tick = Date()
    
    var body: some View {
        List {
            // Mood buttons
            Section {
                HStack(spacing: 6) {
                    ForEach(Mood.allCases) { mood in
                        Button {
                            store.add(mood)
                            if Date().timeIntervalSince(lastHaptic) > 0.12 { lastHaptic = Date(); playProminentTap() }
                        } label: {
                            VStack(spacing: 6) {
                                Text(mood.emoji).font(.system(size: 28))
                                Text(mood.label)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .allowsTightening(true)
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(mood.label))
                    }
                }
            }

            // Total today
            Section {
                let today = store.todayKey
                Text("Total today: \(store.count(forDay: today))")
                    .font(.subheadline)
                    .monospacedDigit()
            }

            // NEW: 4 bars for today's per-mood counts
            Section {
                let today = store.todayKey
                let counts: [Mood:Int] = Dictionary(uniqueKeysWithValues:
                    Mood.allCases.map { ($0, store.count(forDay: today, mood: $0)) }
                )
                TodayMoodBarsView(countsByMood: counts)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 4)
        }
        .listStyle(.plain)        // watchOS-friendly
        .navigationTitle("Mood Ping")
        .onReceive(timer) { _ in _tick = Date() }
        .onChange(of: scenePhase) { phase in if phase == .active { _tick = Date() } }
    }
}

