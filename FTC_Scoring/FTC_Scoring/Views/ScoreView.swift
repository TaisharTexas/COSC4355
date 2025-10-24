//
//  ScoreView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI



struct ScoreView: View {
    @StateObject private var matchData = MatchData()
    
    @State private var matchMode: GameMode = .standard
    @State private var gamePhase: GamePhase = .auto
    
    //timer vars
    @State private var timeRemaining: TimeInterval = 150 // 2:30
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    private var TeamNum: String = "17355"
    private var SessionID: String = "10.24.25"
    private var MatchID: Int = 2
    
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
            VStack{
                Text("Team: \(TeamNum)")
                    .font(.title2)
                HStack{
                    VStack(alignment: .leading){
                        Text("Session: \(SessionID)")
                        Text("Match: \(MatchID)")
                    }
                    Spacer()
                    Button(action: {
                        print("edit button pressed")
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title)
                            .foregroundColor(.ftcOrange)
                    }
                }
                .padding(.top, 3)

            }//: end header VStack
            .padding()
            
            
            
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
                    ScoreEndgame(matchData: matchData)
                }
            }//: end phase switcher
            Spacer()
            
            
        }
            
    }// end Body View
    
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

