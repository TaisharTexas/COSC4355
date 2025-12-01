//
//  ContentView.swift
//  HW6_MoodApp Watch App
//
//  Created by Andrew Lee on 11/6/25.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var moodStorage = MoodStorage()
    @Environment(\.scenePhase) var scenePhase
    @State private var timer: Timer?
    
    var body: some View {
        ScrollView {
            VStack {
                // Grid of emoji buttons
                VStack(spacing: 10) {
                    // Top Row
                    HStack(spacing: 10) {
                        
                        // Happy
                        Button {
                            moodStorage.addMood(.happy)
                            WKInterfaceDevice.current().play(.success)
                        } label: {
                            VStack(spacing: 2) {
                                Text("😊")
                                    .font(.system(size: 70))
                                Text("Happy")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(minWidth: 44, minHeight: 44)
                        .sensoryFeedback(.selection, trigger: moodStorage.totalToday())
                        
                        // Okay
                        Button {
                            moodStorage.addMood(.okay)
                            WKInterfaceDevice.current().play(.success)
                        } label: {
                            VStack(spacing: 2) {
                                Text("🙂")
                                    .font(.system(size: 70))
                                Text("Okay")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(minWidth: 44, minHeight: 44)
                        .sensoryFeedback(.selection, trigger: moodStorage.totalToday())
                    }//: end top row Hstack
                    
                    // Bottom row
                    HStack(spacing: 10) {
                        
                        // Meh
                        Button {
                            moodStorage.addMood(.meh)
                            WKInterfaceDevice.current().play(.success)
                        } label: {
                            VStack(spacing: 2) {
                                Text("😐")
                                    .font(.system(size: 70))
                                Text("Meh")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(minWidth: 44, minHeight: 44)
                        .sensoryFeedback(.selection, trigger: moodStorage.totalToday())
                        
                        // Sad
                        Button {
                            moodStorage.addMood(.sad)
                            WKInterfaceDevice.current().play(.success)
                        } label: {
                            VStack(spacing: 2) {
                                Text("😢")
                                    .font(.system(size: 70))
                                Text("Sad")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(minWidth: 44, minHeight: 44)
                        .sensoryFeedback(.selection, trigger: moodStorage.totalToday())
                    }//: end bot row Hstack
                }//: end grid Vstack
                .padding(.bottom, 20)
                
                // Graph miniview
                TodayByMood(moodStorage: moodStorage)
            }
            .padding(.top, -8)
        }
        .navigationTitle("Mood Ping")
        .onChange(of: scenePhase) {
            // when the screen is made active refresh the data (checks if the day as reset or not)
            // also checks after a set period of time if the screen is active for a while
            if scenePhase == .active {
                moodStorage.refreshDayIfNeeded()
                startTimer()
            } else if scenePhase == .background {
                stopTimer()
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func startTimer() {
        // Check day every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            moodStorage.refreshDayIfNeeded()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ContentView()
}
