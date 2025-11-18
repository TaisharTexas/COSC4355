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
            HStack{
                
                Button("Save Match", action: {
                    print("save match button pressed")
                    //eventually need to pop up match summary/confirm save button and then save a match record to the memory (non volitile)
                })
                .buttonStyle(.glassProminent)
                .font(.title2)
            }
            Spacer()
            
        }//: end Vstack
    }
    
    private func getMatchType() -> MatchType {
        return matchMode == .standard ? .practice : .custom
    }
    
    // Calculate Movement Points using MatchRecord logic
    private func calculateMovementPoints() -> Int {
        // Create a temporary match record to use its calculation logic
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType())
        return tempRecord.movementPoints
    }
    
    // Calculate Goal Points using MatchRecord logic
    private func calculateGoalPoints() -> Int {
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType())
        return tempRecord.goalPoints
    }
    
    // Calculate Pattern Points using MatchRecord logic
    private func calculatePatternPoints() -> Int {
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType())
        return tempRecord.patternPoints
    }
    
    // Calculate total ranking points earned
    private func calculateTotalRankingPoints() -> Int {
        let tempRecord = matchData.createMatchRecord(teamNumber: "", matchNumber: 0, session: "", matchType: getMatchType())
        return tempRecord.totalRankingPoints
    }
}
