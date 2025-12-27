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

// MARK: - Team Analysis Event View

struct TeamAnalysisEventView: View {
    let event: FTCEvent
    let teamNumber: Int
    let season: Int
    @ObservedObject var apiService: EventAPIService
    
    @State private var analysis: TeamAnalysis?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    @State private var showAnalysisSheet = false
    
    @State private var matches: [ScheduledMatch] = []
    @State private var selectedTournamentLevel = "qual"
    @State private var isLoadingMatches = false
    @State private var matchErrorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Info Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.secondary)
                        Text(event.displayLocation)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    
                    Text("Team \(String(teamNumber))")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Analyze Button
                Button(action: analyzeTeamPerformance) {
                    HStack {
                        if isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.trailing, 4)
                        } else {
                            Image(systemName: "chart.bar.fill")
                        }
                        Text(isAnalyzing ? "Analyzing..." : "Analyze Team Performance")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.ftcOrange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isAnalyzing)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Divider()
                
                // Tournament Level Picker
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tournament Level")
                        .font(.headline)
                    
                    Picker("Tournament Level", selection: $selectedTournamentLevel) {
                        Text("Qualification").tag("qual")
                        Text("Playoff").tag("playoff")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedTournamentLevel) { _ in
                        fetchMatches()
                    }
                }
                
                // Matches List
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Matches (\(matches.count))")
                            .font(.headline)
                        
                        Spacer()
                        
                        if isLoadingMatches {
                            ProgressView()
                        }
                    }
                    
                    if let error = matchErrorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if matches.isEmpty && !isLoadingMatches {
                        Text("No matches found for this tournament level.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(matches) { match in
                                NavigationLink(destination: MatchScoreViewAnalysis(
                                    match: match,
                                    event: event,
                                    teamNumber: teamNumber,
                                    season: season,
                                    tournamentLevel: selectedTournamentLevel,
                                    apiService: apiService
                                )) {
                                    MatchRowViewAnalysis(match: match, highlightTeam: teamNumber)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Performance Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAnalysisSheet) {
            if let analysis = analysis {
                AnalysisResultsSheet(analysis: analysis, event: event)
            }
        }
        .onAppear {
            fetchMatches()
        }
    }
    
    // MARK: - Analysis Logic
    
    private func analyzeTeamPerformance() {
        guard let eventCode = event.code else {
            errorMessage = "Event code not available"
            return
        }
        
        isAnalyzing = true
        errorMessage = nil
        
        Task {
            do {
                // Fetch all matches for this team
                let matches = try await apiService.fetchMatchesForTeam(
                    season: season,
                    eventCode: eventCode,
                    teamNumber: teamNumber,
                    tournamentLevel: "qual"
                )
                
                // Fetch scores for each match
                var matchDataList: [AnalysisMatchData] = []
                var allTeamRecords: [Int: (wins: Int, losses: Int)] = [:]
                
                for match in matches {
                    // Fetch match score
                    if let matchScore = try? await apiService.fetchMatchScore(
                        season: season,
                        eventCode: eventCode,
                        tournamentLevel: "qual",
                        matchNumber: match.matchNumber
                    ) {
                        // Determine team's alliance
                        guard let teams = match.teams,
                              let teamInfo = teams.first(where: { $0.teamNumber == teamNumber }),
                              let allianceColor = teamInfo.alliance.lowercased() == "red" ? "Red" : (teamInfo.alliance.lowercased() == "blue" ? "Blue" : nil) else {
                            continue
                        }
                        
                        // Get alliance scores
                        guard let alliances = matchScore.alliances else { continue }
                        
                        let teamAlliance = alliances.first(where: { $0.alliance?.lowercased() == allianceColor.lowercased() })
                        let opponentAlliance = alliances.first(where: { $0.alliance?.lowercased() != allianceColor.lowercased() })
                        
                        guard let teamScore = teamAlliance?.totalPoints,
                              let opponentScore = opponentAlliance?.totalPoints else {
                            continue
                        }
                        
                        let won = teamScore > opponentScore
                        
                        // Calculate partner contribution (alliance score minus estimated team contribution)
                        // For now, we'll estimate team contribution as half the alliance score
                        let partnerScore = teamScore / 2
                        
                        // Calculate opponent win rate (we'll need to fetch this from rankings)
                        let opponentWinRate = 0.5 // Placeholder - we'll calculate this properly
                        
                        matchDataList.append(AnalysisMatchData(
                            matchNumber: match.matchNumber,
                            won: won,
                            teamScore: teamScore,
                            opponentScore: opponentScore,
                            partnerScore: partnerScore,
                            opponentWinRate: opponentWinRate
                        ))
                    }
                }
                
                // Fetch rankings to get accurate win rates for opponents
                if let rankings = try? await apiService.fetchEventRankings(season: season, eventCode: eventCode) {
                    for ranking in rankings {
                        let totalMatches = ranking.wins + ranking.losses + ranking.ties
                        if totalMatches > 0 {
                            let winRate = Double(ranking.wins) / Double(totalMatches)
                            allTeamRecords[ranking.teamNumber] = (wins: ranking.wins, losses: ranking.losses)
                            
                            // Update match data with actual opponent win rates
                            for (index, match) in matchDataList.enumerated() {
                                // This is simplified - in reality we'd need to know which teams were opponents
                                matchDataList[index] = AnalysisMatchData(
                                    matchNumber: match.matchNumber,
                                    won: match.won,
                                    teamScore: match.teamScore,
                                    opponentScore: match.opponentScore,
                                    partnerScore: match.partnerScore,
                                    opponentWinRate: winRate
                                )
                            }
                        }
                    }
                }
                
                // Calculate analysis
                let wins = matchDataList.filter { $0.won }.count
                let losses = matchDataList.count - wins
                let ties = 0 // DECODE doesn't have ties
                
                let winRate = matchDataList.isEmpty ? 0.0 : Double(wins) / Double(matchDataList.count)
                
                let averageScore = matchDataList.isEmpty ? 0.0 : Double(matchDataList.map { $0.teamScore }.reduce(0, +)) / Double(matchDataList.count)
                let averageOpponentScore = matchDataList.isEmpty ? 0.0 : Double(matchDataList.map { $0.opponentScore }.reduce(0, +)) / Double(matchDataList.count)
                let scoreDifferential = averageScore - averageOpponentScore
                
                let averagePartnerContribution = matchDataList.isEmpty ? 0.0 : Double(matchDataList.map { $0.partnerScore }.reduce(0, +)) / Double(matchDataList.count)
                let averageScoreWithPartners = averageScore
                let isCarrying = averageScore > averagePartnerContribution + 15 // Carrying if scoring 15+ more than partner
                
                let averageOpponentQuality = matchDataList.isEmpty ? 0.5 : matchDataList.map { $0.opponentWinRate }.reduce(0, +) / Double(matchDataList.count)
                let winsAgainstStrong = matchDataList.filter { $0.won && $0.opponentWinRate > 0.5 }.count
                let winsAgainstWeak = matchDataList.filter { $0.won && $0.opponentWinRate <= 0.5 }.count
                
                let teamAnalysis = TeamAnalysis(
                    teamNumber: teamNumber,
                    eventCode: eventCode,
                    wins: wins,
                    losses: losses,
                    ties: ties,
                    winRate: winRate,
                    averageScore: averageScore,
                    averageOpponentScore: averageOpponentScore,
                    scoreDifferential: scoreDifferential,
                    averageScoreWithPartners: averageScoreWithPartners,
                    averagePartnerContribution: averagePartnerContribution,
                    isCarrying: isCarrying,
                    averageOpponentQuality: averageOpponentQuality,
                    winsAgainstStrongOpponents: winsAgainstStrong,
                    winsAgainstWeakOpponents: winsAgainstWeak
                )
                
                await MainActor.run {
                    analysis = teamAnalysis
                    isAnalyzing = false
                    showAnalysisSheet = true
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = "Analysis failed: \(error.localizedDescription)"
                    isAnalyzing = false
                }
            }
        }
    }
    
    // MARK: - Fetch Matches
    
    private func fetchMatches() {
        guard let eventCode = event.code else {
            matchErrorMessage = "Event code not available"
            return
        }
        
        isLoadingMatches = true
        matchErrorMessage = nil
        
        Task {
            do {
                let fetchedMatches = try await apiService.fetchMatchesForTeam(
                    season: season,
                    eventCode: eventCode,
                    teamNumber: teamNumber,
                    tournamentLevel: selectedTournamentLevel
                )
                
                await MainActor.run {
                    matches = fetchedMatches
                    isLoadingMatches = false
                }
            } catch {
                await MainActor.run {
                    matchErrorMessage = "Error: \(error.localizedDescription)"
                    matches = []
                    isLoadingMatches = false
                }
            }
        }
    }
}
