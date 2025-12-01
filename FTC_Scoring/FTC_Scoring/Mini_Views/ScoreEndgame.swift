//
//  ScoreEndgame.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct ScoreEndgame: View{
    @ObservedObject var matchData: MatchData
    @Binding var matchMode: ScoreView.GameMode
    @Binding var matchSide: MatchSide
    @ObservedObject var storageManager: MatchStorageManager
    @ObservedObject var teamSettings: TeamSettings
    
    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    
//    @State private var currentMatchNumber: Int = 1
//    @State private var currentSession: String = ""
    
    @Binding var currentSession: String
    @Binding var currentMatchNumber: Int
    
    var body: some View{
        VStack(spacing: 12) {
            ForEach(0..<2, id: \.self) { index in
                HStack {
                    Text("Robot \(index + 1) Base")
                        .font(.headline)
                        .frame(width: 80, alignment: .leading)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { matchData.robotBaseState[index] = .partial }) {
                            Text("Partial")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(matchData.robotBaseState[index] == .partial ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(matchData.robotBaseState[index] == .partial ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { matchData.robotBaseState[index] = .full }) {
                            Text("Full")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(matchData.robotBaseState[index] == .full ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(matchData.robotBaseState[index] == .full ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { matchData.robotBaseState[index] = .none }) {
                            Text("None")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(matchData.robotBaseState[index] == .none ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(matchData.robotBaseState[index] == .none ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }//: end hstack
                .padding(.horizontal)
            }//: end for loop
            
            Divider()
            
            VStack(spacing: 16) {
                Text("Ranking Points")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    // Movement RP
                    VStack(spacing: 4) {
                        Text("\(calculateMovementPoints())/16")
                            .font(.title.bold())
                            .foregroundColor(calculateMovementPoints() >= 16 ? .ftcOrange : .primary)
                        Text("Movement")
                            .font(.caption)
                            .foregroundColor(.ftcGray)
                        Image(systemName: calculateMovementPoints() >= 16 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(calculateMovementPoints() >= 16 ? .ftcOrange : .gray)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Goal RP
                    VStack(spacing: 4) {
                        Text("\(calculateGoalPoints())/36")
                            .font(.title.bold())
                            .foregroundColor(calculateGoalPoints() >= 36 ? .ftcOrange : .primary)
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.ftcGray)
                        Image(systemName: calculateGoalPoints() >= 36 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(calculateGoalPoints() >= 36 ? .ftcOrange : .gray)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Pattern RP
                    VStack(spacing: 4) {
                        Text("\(calculatePatternPoints())/18")
                            .font(.title.bold())
                            .foregroundColor(calculatePatternPoints() >= 18 ? .ftcOrange : .primary)
                        Text("Pattern")
                            .font(.caption)
                            .foregroundColor(.ftcGray)
                        Image(systemName: calculatePatternPoints() >= 18 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(calculatePatternPoints() >= 18 ? .ftcOrange : .gray)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                
                // Total Ranking Points
                HStack {
                    Text("Total Ranking Points:")
                        .font(.headline)
                    Spacer()
                    Text("\(calculateTotalRankingPoints())")
                        .font(.title.bold())
                        .foregroundColor(.ftcOrange)
                }
                .padding(.horizontal, 8)
                
            }//: end RP Vstack
            .padding(.horizontal)
            
            Divider()
            Spacer()
            VStack(spacing: 8) {
                Button(action: saveMatch) {
                    Text("Save Match")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.ftcOrange)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Success/Error messages
                if showSaveSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Match saved successfully!")
                            .foregroundColor(.green)
                    }
                    .font(.subheadline)
                    .transition(.scale.combined(with: .opacity))
                }
                
                if showSaveError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Error saving match. Please try again.")
                            .foregroundColor(.red)
                    }
                    .font(.subheadline)
                    .transition(.scale.combined(with: .opacity))
                }
            }//: end save button VStack
            Spacer()
            
        }//: end Vstack
    }
    
    private func getMatchType() -> MatchType {
        return matchMode == .standard ? .practice : .custom
    }
    
    private func getMatchSide() ->   MatchSide {
        return matchSide
    }
    
    // Calculate Movement Points using MatchRecord logic
    private func calculateMovementPoints() -> Int {
        // Create a temporary match record to use its calculation logic
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType(), matchSide: .red)
        return tempRecord.movementPoints
    }
    
    // Calculate Goal Points using MatchRecord logic
    private func calculateGoalPoints() -> Int {
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType(), matchSide: .red)
        return tempRecord.goalPoints
    }
    
    // Calculate Pattern Points using MatchRecord logic
    private func calculatePatternPoints() -> Int {
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType(), matchSide: .red)
        return tempRecord.patternPoints
    }
    
    // Calculate total ranking points earned
    private func calculateTotalRankingPoints() -> Int {
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType(), matchSide: .red)
        return tempRecord.totalRankingPoints
    }
    
    // Save the current match
    private func saveMatch() {
        // Generate session ID if empty (format: MM.DD.YY)
        if currentSession.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM.dd.yy"
            currentSession = dateFormatter.string(from: Date())
        }
        
        // Create the match record
        let matchRecord = matchData.createMatchRecord(
            teamNumber: teamSettings.teamNumber,
            matchNumber: currentMatchNumber,
            session: currentSession,
            matchType: getMatchType(),
            matchSide: getMatchSide()
        )
        print("session saved: \(matchRecord.session)")
        
        // Save to storage
        let success = storageManager.saveMatch(matchRecord)
        
        // Show feedback
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if success {
                showSaveSuccess = true
                showSaveError = false
                
                // Increment match number for next match
                currentMatchNumber += 1
                
                // Hide success message after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        showSaveSuccess = false
                    }
                }
                
                // Reset match data for next match
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    matchData.reset()
                }
            } else {
                showSaveError = true
                showSaveSuccess = false
                
                // Hide error message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        showSaveError = false
                    }
                }
            }
        }
    }//: end saveMatch func
}
