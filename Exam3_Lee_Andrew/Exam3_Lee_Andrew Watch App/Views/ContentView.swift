//
//  ContentView.swift
//  Exam3_Lee_Andrew Watch App
//
//  Created by Andrew Lee on 11/20/25.
//

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
    
    @AppStorage("recentLimit") var recentLimit: Int = 5
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = HabitStore()
    @State private var _tick = Date()
    @State private var lastHaptic = Date.distantPast
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    @State var mostRecent: String = ""
    @State var bufferLogs: [String] = []
    
    
    var body: some View {
        NavigationStack{
            List{
                // Most Recent Habit Record
                Section{
                    //
                    VStack(alignment: .leading){
                        Text("Last Habit:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(mostRecent.isEmpty ? "No recent habits yet" : mostRecent)")
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                }//: end most recent habit section
                
                // Log Habits Buttons
                Section{
                    VStack{
                        Text("Log Habits")
                            .font(.caption)
                        Divider()
                        
                        HStack(spacing: 6){
                            ForEach(Habit.allCases) { habit in
                                Button {
                                    store.add(habit)
                                    if Date().timeIntervalSince(lastHaptic) > 0.12 { lastHaptic = Date(); playProminentTap() }
                                    mostRecent = habit.label
                                    bufferLogs.append(habit.label)
                                    print(habit)
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: habit.icon)
                                            .font(.system(size: 28))
                                            .foregroundColor(habit.color)
                                        Text(habit.label)
                                            .font(.caption2)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                            .allowsTightening(true)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(Text(habit.label))
                                .padding()
                            }
                        }
                    }
                }//: end log button section
                
                // Graph of today's habit records
                Section{
                    let today = store.todayKey
                    let counts: [Habit:Int] = Dictionary(uniqueKeysWithValues: Habit.allCases.map { ($0, store.count(forDay: today, habit: $0)) }
                    )
                    TodayHabitGraph(countsByHabit: counts)
                        .frame(maxWidth: .infinity)
                        .padding()
                }//: end habits graph section
                
                // List of Recents
                Section{
                    
                    VStack{
                        Text("Last \(recentLimit) Habit Logs:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Divider()
                        
                        ForEach(0..<recentLimit, id: \.self) { index in
                            if(index >= bufferLogs.count){
                                Text("\(index+1): not enough recent logs")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            } else {
                                Text("\(index+1): \(bufferLogs[index])")
                            }
                            
                        }
                        
                        
                        
                    }
                }//: end recent logs section (adjustable number)
                
                // Settings
                Section{
                    //WHY WONT IT CENTERRRR
                    VStack(alignment: .center){
                        NavigationLink(destination: SettingsView()){
                            Image(systemName: "gearshape.fill")
                                .font(.title)
                        }
                    }
                    
                    
                }//: end settings section
                
            }//: end List
            .navigationTitle("MicroHabits")
            .onReceive(timer) { _ in _tick = Date() }
            .onChange(of: scenePhase) { phase in if phase == .active { _tick = Date() } }
            
        }//: end NavStack
    }
}

#Preview {
    ContentView()
}
