//
//  SearchTeamsSubViews.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 12/26/25.
//

import Foundation
import SwiftUI

// MARK: - Match Row View

struct MatchRowView: View {
    let match: ScheduledMatch
    let highlightTeam: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.displayDescription)
                        .font(.headline)
                    
                    if let startTime = match.parsedStartTime {
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(formatTime(startTime))
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let field = match.field {
                    VStack {
                        Image(systemName: "square.grid.2x2")
                            .font(.caption)
                        Text(field)
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Teams
            if let teams = match.teams {
                HStack(spacing: 20) {
                    // Red Alliance
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Red Alliance")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        ForEach(teams.filter { $0.alliance == "Red" }) { team in
                            TeamBadge(team: team, highlightTeam: highlightTeam)
                        }
                    }
                    
                    Spacer()
                    
                    // Blue Alliance
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Blue Alliance")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        ForEach(teams.filter { $0.alliance == "Blue" }) { team in
                            TeamBadge(team: team, highlightTeam: highlightTeam)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Team Badge View

struct TeamBadge: View {
    let team: ScheduledMatchTeam
    let highlightTeam: Int
    
    var isHighlighted: Bool {
        team.teamNumber == highlightTeam
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(team.displayNumber)
                .font(.caption)
                .fontWeight(isHighlighted ? .bold : .regular)
            
            if team.surrogate {
                Text("*")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            if team.noShow {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isHighlighted ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Import Match Button

struct ImportMatchButton: View {
    let match: ScheduledMatch
    let event: FTCEvent
    let teamNumber: Int
    let season: Int
    let tournamentLevel: String
    @ObservedObject var apiService: EventAPIService
    @ObservedObject var storageManager: MatchStorageManager
    
    @State private var isImporting = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        Button(action: importMatch) {
            VStack(spacing: 4) {
                if isImporting {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if showingSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.ftcOrange)
                        .font(.title2)
                }
                
                Text(showingSuccess ? "Imported" : "Import")
                    .font(.caption2)
                    .foregroundColor(showingSuccess ? .green : .ftcOrange)
            }
            .frame(width: 70)
            .padding(.vertical, 8)
        }
        .disabled(isImporting || showingSuccess)
        .alert("Import Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func importMatch() {
        guard let eventCode = event.code else {
            errorMessage = "Event code not available"
            return
        }
        
        isImporting = true
        errorMessage = nil
        
        Task {
            do {
                // First, determine which alliance team 18140 is on from the scheduled match
                guard let teams = match.teams,
                      let teamInfo = teams.first(where: { $0.teamNumber == teamNumber }),
                      let allianceColor = teamInfo.alliance.lowercased() == "red" ? "Red" : (teamInfo.alliance.lowercased() == "blue" ? "Blue" : nil) else {
                    await MainActor.run {
                        errorMessage = "Could not determine team's alliance"
                        isImporting = false
                    }
                    return
                }
                
                // Fetch the match score
                let matchScore = try await apiService.fetchMatchScore(
                    season: season,
                    eventCode: eventCode,
                    tournamentLevel: tournamentLevel,
                    matchNumber: match.matchNumber
                )
                
                // Find the alliance score for the team's alliance color
                guard let alliances = matchScore.alliances,
                      let teamAlliance = alliances.first(where: {
                          $0.alliance?.lowercased() == allianceColor.lowercased()
                      }) else {
                    await MainActor.run {
                        errorMessage = "Could not find alliance score data"
                        isImporting = false
                    }
                    return
                }
                
                // Convert to MatchRecord
                let matchRecord = apiService.convertToMatchRecord(
                    allianceScore: teamAlliance,
                    matchNumber: match.matchNumber,
                    teamNumber: String(teamNumber),
                    session: eventCode,
                    motif: 1 // Default motif
                )
                
                // Save the match
                let success = await MainActor.run {
                    storageManager.saveMatch(matchRecord)
                }
                
                await MainActor.run {
                    if success {
                        withAnimation {
                            showingSuccess = true
                        }
                        // Reset after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showingSuccess = false
                            }
                        }
                    } else {
                        errorMessage = "Failed to save match"
                    }
                    isImporting = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Import failed: \(error.localizedDescription)"
                    isImporting = false
                }
            }
        }
    }
}

// MARK: - Match Score View

struct MatchScoreView: View {
    let match: ScheduledMatch
    let event: FTCEvent
    let teamNumber: Int
    let season: Int
    let tournamentLevel: String
    @ObservedObject var apiService: EventAPIService
    
    @State private var matchScore: MatchScore?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var rawJSON: String = ""
    @State private var showRawJSON = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Match Info Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(match.displayDescription)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        if let field = match.field {
                            Label("Field \(field)", systemImage: "square.grid.2x2")
                        }
                        
                        if let startTime = match.parsedStartTime {
                            Label(formatTime(startTime), systemImage: "clock")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(event.displayName)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading score...")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                
                // Score Display
                if let score = matchScore, let alliances = score.alliances {
                    VStack(spacing: 16) {
                        ForEach(alliances) { alliance in
                            AllianceScoreCard(alliance: alliance, highlightTeam: teamNumber)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Match Score")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchScore()
        }
    }
    
    private func fetchScore() {
        guard let eventCode = event.code else {
            errorMessage = "Event code not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        rawJSON = ""
        
        Task {
            do {
                // Fetch raw JSON first for debugging
                let rawResponse = try await apiService.fetchRawScore(
                    season: season,
                    eventCode: eventCode,
                    tournamentLevel: tournamentLevel,
                    matchNumber: match.matchNumber
                )
                
                await MainActor.run {
                    rawJSON = rawResponse
                }
                
                // Fetch structured data
                let score = try await apiService.fetchMatchScore(
                    season: season,
                    eventCode: eventCode,
                    tournamentLevel: tournamentLevel,
                    matchNumber: match.matchNumber
                )
                
                await MainActor.run {
                    matchScore = score
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Alliance Score Card

struct AllianceScoreCard: View {
    let alliance: AllianceScore
    let highlightTeam: Int
    
    var isHighlighted: Bool {
        alliance.team == highlightTeam
    }
    
    var allianceColor: Color {
        alliance.isRedAlliance ? .red : .blue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Alliance Header
            HStack {
                Text("\(alliance.alliance?.capitalized ?? "Unknown") Alliance")
                    .font(.headline)
                    .foregroundColor(allianceColor)
                
                Spacer()
                
                if let total = alliance.totalPoints {
                    Text("\(total)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(allianceColor)
                }
            }
            
            Divider()
            
            // Auto Scoring
            VStack(alignment: .leading, spacing: 4) {
                Text("Autonomous")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ScoreRow(label: "Classified Artifacts", value: alliance.autoClassifiedArtifacts)
                ScoreRow(label: "Overflow Artifacts", value: alliance.autoOverflowArtifacts)
                ScoreRow(label: "Leave Points", value: alliance.autoLeavePoints)
                ScoreRow(label: "Pattern Points", value: alliance.autoPatternPoints)
                
                HStack {
                    Text("Auto Total:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    if let points = alliance.autoPoints {
                        Text("\(points)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 4)
            }
            
            Divider()
            
            // Teleop Scoring
            VStack(alignment: .leading, spacing: 4) {
                Text("TeleOp")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ScoreRow(label: "Classified Artifacts", value: alliance.teleopClassifiedArtifacts)
                ScoreRow(label: "Overflow Artifacts", value: alliance.teleopOverflowArtifacts)
                ScoreRow(label: "Depot Artifacts", value: alliance.teleopDepotArtifacts)
                ScoreRow(label: "Pattern Points", value: alliance.teleopPatternPoints)
                ScoreRow(label: "Base Points", value: alliance.teleopBasePoints)
                
                HStack {
                    Text("Teleop Total:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    if let points = alliance.teleopPoints {
                        Text("\(points)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 4)
            }
            
            Divider()
            
            // Ranking Points
            HStack(spacing: 16) {
                RankingPointBadge(label: "Movement", achieved: alliance.movementRP ?? false)
                RankingPointBadge(label: "Goal", achieved: alliance.goalRP ?? false)
                RankingPointBadge(label: "Pattern", achieved: alliance.patternRP ?? false)
            }
            
            // Fouls
            if let major = alliance.majorFouls, let minor = alliance.minorFouls, (major > 0 || minor > 0) {
                Divider()
                HStack {
                    Text("Fouls:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Major: \(major), Minor: \(minor)")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(isHighlighted ? allianceColor.opacity(0.1) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isHighlighted ? allianceColor : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Score Row

struct ScoreRow: View {
    let label: String
    let value: Int?
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            if let value = value {
                Text("\(value)")
                    .font(.caption)
            } else {
                Text("-")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Ranking Point Badge

struct RankingPointBadge: View {
    let label: String
    let achieved: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: achieved ? "checkmark.circle.fill" : "circle")
                .foregroundColor(achieved ? .green : .gray)
                .font(.caption)
            Text(label)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(achieved ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}
