//
//  ScoreView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI



struct ScoreView: View {
    
    /**
     Need to add way to track phases in the match for standard game match
        probably parallel timers to track when auto ends, when teleop ends, and when whole game ends to unlock the tabs
        unlock save button when match ends
     For custom, let all the tabs be unlocked and save button available.
     
     Need edit button to actually edit
     */
    
    
    @StateObject private var matchData = MatchData()
    @StateObject private var teamSettings = TeamSettings()
    
    @State private var matchMode: GameMode = .standard
    @State private var gamePhase: GamePhase = .auto
    
    //timer vars
    @State private var timeRemaining: TimeInterval = 150 // 2:30
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    @State private var showingEditSheet = false
    @State private var sessionID: String = "10.24.25"
    @State private var matchID: Int = 2

    enum GameMode {
        case standard, custom
    }

    enum GamePhase{
        case auto, teleop, endgame
    }

    enum GateState{
        case green, purple, none
    }
    
    var body: some View {
        VStack{
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("\(teamSettings.teamNumber):")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(teamSettings.teamName)
                            .font(.headline)
                            .foregroundColor(.ftcOrange)
                            .lineLimit(1)
                    }
                    HStack(spacing: 8) {
                        Text("Session: \(sessionID)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Match: \(matchID)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }//: end info Vstack
                
                Spacer()
                
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.ftcOrange)
                }//: end edit button
                
                Button(action: {
                    matchData.reset()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.red)
                }//: end reset button
            }//: end header Hstack
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            
            
            Picker("Match Type", selection: $matchMode) {
                Text("Practice Match").tag(GameMode.standard)
                Text("Custom Match").tag(GameMode.custom)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Timer Section
            HStack(spacing: 30) {
                Button(action: startTimer) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text("Start")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        )
                }//: start timer button
                
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 48, weight: .regular))
                
                Button(action: {
                       if isTimerRunning {
                           stopTimer()
                       } else {
                           resetTimer()
                       }
                   }) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text(isTimerRunning ? "Stop" : "Reset")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        )
                }//: stop timer button
            }//: end Timer HStack
            .padding(.vertical, 10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider()
            
            HStack(spacing: 13) {
                Text("Motif:")
                    .font(.headline)
                
                Button(action: { matchData.selectedMotif = 1 }) {
                    Text("ID 21")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(width: 50, height: 30)
                        .background(matchData.selectedMotif == 1 ? Color.ftcOrange : Color.gray.opacity(0.2))
                        .foregroundColor(matchData.selectedMotif == 1 ? .white : .primary)
                        .cornerRadius(8)
                }
                
                Button(action: { matchData.selectedMotif = 2 }) {
                    Text("ID 22")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(width: 50, height: 30)
                        .background(matchData.selectedMotif == 2 ? Color.ftcOrange : Color.gray.opacity(0.2))
                        .foregroundColor(matchData.selectedMotif == 2 ? .white : .primary)
                        .cornerRadius(8)
                }
                
                Button(action: { matchData.selectedMotif = 3 }) {
                    Text("ID 23")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(width: 50, height: 30)
                        .background(matchData.selectedMotif == 3 ? Color.ftcOrange : Color.gray.opacity(0.2))
                        .foregroundColor(matchData.selectedMotif == 3 ? .white : .primary)
                        .cornerRadius(8)
                }
                
                if(matchData.selectedMotif == 1){// G-P-P
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(.purple)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(.purple)
                        .frame(width: 20, height: 20)
                }
                else if(matchData.selectedMotif == 2){// P-G-P
                    Circle()
                        .fill(.purple)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(.purple)
                        .frame(width: 20, height: 20)
                }
                else{// P-P-G
                    Circle()
                        .fill(.purple)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(.purple)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                }
                
                
            }//: end motif selector
            .padding(.horizontal, 8)
            
            Picker("Game Phase", selection: $gamePhase) {
                Text("Autonomous").tag(GamePhase.auto)
                Text("Teleop").tag(GamePhase.teleop)
                Text("Endgame").tag(GamePhase.endgame)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top, 8)
            
            //change which game phase scoring stuff is shown
            Group{
                switch gamePhase {
                case .auto:
                    ScoreAuto(matchData: matchData)
                case .teleop:
                    ScoreTele(matchData: matchData)
                case .endgame:
                    ScoreEndgame(matchData: matchData, matchMode: $matchMode)
                }
            }//: end phase switcher
            Spacer()
            
            
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Team Information")) {
                        HStack {
                            Text("Team Number")
                            Spacer()
                            TextField("Team #", text: $teamSettings.teamNumber)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Team Name")
                            Spacer()
                            TextField("Team Name", text: $teamSettings.teamName)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Section(header: Text("Match Information")) {
                        HStack {
                            Text("Session ID")
                            Spacer()
                            TextField("Session", text: $sessionID)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Stepper("Match: \(matchID)", value: $matchID, in: 1...999)
                    }
                }//: end form
                .navigationTitle("Edit Match Info")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingEditSheet = false
                        }
                        .foregroundColor(.ftcOrange)
                    }
                }//: end toolbar
            }//: end NavView
        }//: end sheet
            
        
    }// end Body View
    
    
    // TIMER HELPER FUNCTIONS
    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }//: end start timer
    
    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }//: end stop timer
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }//: end time data format
    
    func resetTimer() {
       stopTimer()
       timeRemaining = 150 // Reset to 2:30
   }//: end reset timer
    
}//: end ScoreView View

#Preview {
    ScoreView()
}

