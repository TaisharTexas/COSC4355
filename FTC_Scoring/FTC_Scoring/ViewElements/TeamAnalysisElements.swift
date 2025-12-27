//
//  TeamAnalysisSubViews.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 12/27/25.
//

import Foundation
import SwiftUI


// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Analysis Results Sheet

struct AnalysisResultsSheet: View {
    let analysis: TeamAnalysis
    let event: FTCEvent
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Event Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Team \(analysis.teamNumberString)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text(event.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Overall Record
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overall Record")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            StatCard(title: "Wins", value: "\(analysis.wins)", color: .green)
                            StatCard(title: "Losses", value: "\(analysis.losses)", color: .red)
                            StatCard(title: "Ties", value: "\(analysis.ties)", color: .gray)
                        }
                        
                        StatCard(
                            title: "Win Rate",
                            value: "\(String(format: "%.0f", analysis.winRate * 100))%",
                            color: .ftcOrange
                        )
                    }
                    
                    Divider()
                    
                    // Scoring Stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scoring Statistics")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            StatCard(title: "Avg Score", value: String(format: "%.0f", analysis.averageScore), color: .blue)
                            StatCard(title: "Opponent Avg", value: String(format: "%.0f", analysis.averageOpponentScore), color: .purple)
                        }
                        
                        StatCard(
                            title: "Score Differential",
                            value: String(format: "%+.0f", analysis.scoreDifferential),
                            color: analysis.scoreDifferential > 0 ? .green : .red
                        )
                    }
                    
                    Divider()
                    
                    // Partner Analysis
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Alliance Partnership")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            StatCard(title: "Alliance Avg", value: String(format: "%.0f", analysis.averageScoreWithPartners), color: .teal)
                            StatCard(title: "Partner Contribution", value: String(format: "%.0f", analysis.averagePartnerContribution), color: .cyan)
                        }
                    }
                    
                    Divider()
                    
                    // Opponent Quality
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Opponent Analysis")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Avg Opponent Quality:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(String(format: "%.0f", analysis.averageOpponentQuality * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Wins vs Strong (>50%):")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(analysis.winsAgainstStrongOpponents)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("Wins vs Weak (<50%):")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(analysis.winsAgainstWeakOpponents)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Insights
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Insights")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(analysis.insights, id: \.self) { insight in
                                HStack(alignment: .top, spacing: 8) {
                                    Text(insight)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Performance Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.ftcOrange)
                }
            }
        }
    }
}

// MARK: - Match Row View for Analysis

struct MatchRowViewAnalysis: View {
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
                            TeamBadgeAnalysis(team: team, highlightTeam: highlightTeam)
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
                            TeamBadgeAnalysis(team: team, highlightTeam: highlightTeam)
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

// MARK: - Team Badge for Analysis

struct TeamBadgeAnalysis: View {
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

// MARK: - Match Score View for Analysis

struct MatchScoreViewAnalysis: View {
    let match: ScheduledMatch
    let event: FTCEvent
    let teamNumber: Int
    let season: Int
    let tournamentLevel: String
    @ObservedObject var apiService: EventAPIService
    
    @State private var matchScore: MatchScore?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
                            AllianceScoreCardAnalysis(alliance: alliance, highlightTeam: teamNumber)
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
        
        Task {
            do {
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

// MARK: - Alliance Score Card for Analysis

struct AllianceScoreCardAnalysis: View {
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
                
                ScoreRowAnalysis(label: "Classified Artifacts", value: alliance.autoClassifiedArtifacts)
                ScoreRowAnalysis(label: "Overflow Artifacts", value: alliance.autoOverflowArtifacts)
                ScoreRowAnalysis(label: "Leave Points", value: alliance.autoLeavePoints)
                ScoreRowAnalysis(label: "Pattern Points", value: alliance.autoPatternPoints)
                
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
                
                ScoreRowAnalysis(label: "Classified Artifacts", value: alliance.teleopClassifiedArtifacts)
                ScoreRowAnalysis(label: "Overflow Artifacts", value: alliance.teleopOverflowArtifacts)
                ScoreRowAnalysis(label: "Depot Artifacts", value: alliance.teleopDepotArtifacts)
                ScoreRowAnalysis(label: "Pattern Points", value: alliance.teleopPatternPoints)
                ScoreRowAnalysis(label: "Base Points", value: alliance.teleopBasePoints)
                
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
                RankingPointBadgeAnalysis(label: "Movement", achieved: alliance.movementRP ?? false)
                RankingPointBadgeAnalysis(label: "Goal", achieved: alliance.goalRP ?? false)
                RankingPointBadgeAnalysis(label: "Pattern", achieved: alliance.patternRP ?? false)
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

// MARK: - Score Row for Analysis

struct ScoreRowAnalysis: View {
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

// MARK: - Ranking Point Badge for Analysis

struct RankingPointBadgeAnalysis: View {
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
