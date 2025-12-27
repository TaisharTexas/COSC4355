//
//  TeamAnalysisView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/26/25.
//

import SwiftUI

private struct DataCard: View {
    let title: String
    let data: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(data)
                .font(.title.bold())
                .foregroundColor(.ftcOrange)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.ftcGray)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}//: end DataCard element

struct TeamAnalysisView_Self: View{
    
    @ObservedObject var storageManager: MatchStorageManager
    @State private var selectedSideFilter: SideFilter = .all
    
    enum SideFilter {
        case all, red, blue
    }
    
    private var includedMatches: [MatchRecord] {
        let filtered = storageManager.savedMatches.filter { $0.isIncluded }
        
        switch selectedSideFilter {
        case .all:
            return filtered
        case .red:
            return filtered.filter { $0.matchSide == .red }
        case .blue:
            return filtered.filter { $0.matchSide == .blue }
        }
    }
    
    private var avgAuto: Double {
        guard !includedMatches.isEmpty else { return 0.0 }
        let total = includedMatches.reduce(0) { $0 + $1.autoPhase.score }
        return Double(total) / Double(includedMatches.count)
    }
    
    private var avgTeleop: Double {
        guard !includedMatches.isEmpty else { return 0.0 }
        let total = includedMatches.reduce(0) { $0 + $1.teleopPhase.score }
        return Double(total) / Double(includedMatches.count)
    }
    
    private var avgEndgame: Double {
        guard !includedMatches.isEmpty else { return 0.0 }
        let total = includedMatches.reduce(0) { $0 + $1.endgamePhase.score }
        return Double(total) / Double(includedMatches.count)
    }
    
    private var avgTotal: Double {
        guard !includedMatches.isEmpty else { return 0.0 }
        let total = includedMatches.reduce(0) { $0 + $1.totalScore }
        return Double(total) / Double(includedMatches.count)
    }
    
    private var avgRankingPoints: Double {
        guard !includedMatches.isEmpty else { return 0.0 }
        let total = includedMatches.reduce(0) { $0 + $1.totalRankingPoints }
        return Double(total) / Double(includedMatches.count)
    }
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            HStack(spacing: 0) {
                Button(action: { selectedSideFilter = .all }) {
                    Text("All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedSideFilter == .all ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedSideFilter == .all ? Color.ftcOrange : Color.clear)
                }
                
                Button(action: { selectedSideFilter = .red }) {
                    Text("Red")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedSideFilter == .red ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedSideFilter == .red ? Color.red : Color.clear)
                }
                
                Button(action: { selectedSideFilter = .blue }) {
                    Text("Blue")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedSideFilter == .blue ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedSideFilter == .blue ? Color.blue : Color.clear)
                }
            }//: end match side filter picker
            .background(Color(UIColor.systemGray5))
            .cornerRadius(8)
            .padding(.horizontal)
            
            
            Divider()
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    DataCard(title: "Avg Auto", data: String(format: "%.1f", avgAuto))
                    DataCard(title: "Avg Teleop", data: String(format: "%.1f", avgTeleop))
                    DataCard(title: "Avg Endgame", data: String(format: "%.1f", avgEndgame))
                }//: end Hstack (data cards)
                HStack(spacing: 12){
                    DataCard(title: "Avg Total", data: String(format: "%.1f", avgTotal))
                    DataCard(title: "Avg RP", data: String(format: "%.2f", avgRankingPoints))
                }
                
                // Field map
                Image("ftc_map")
                    .resizable()
                    .scaledToFit()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
            }//: end data dashboard
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
            )
            .padding()
        }//: end outer Vstack
    }//: end body view

}

#Preview{
    TeamAnalysisView_Self(storageManager: MatchStorageManager())
}
