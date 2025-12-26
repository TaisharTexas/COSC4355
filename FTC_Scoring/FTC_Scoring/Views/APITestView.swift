//
//  APITestView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee (Claude) on 12/1/25.
//

import Foundation
import SwiftUI

struct APITestView: View {
    @StateObject private var apiService = EventAPIService()
    @State private var events: [FTCEvent] = []
    @State private var teamNumberText = "18140"
    @State private var connectionStatus = ""
    @State private var currentTeamNumber: Int?
    
    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Team Events Lookup
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Search Team Events")
                            .font(.headline)
                        
                        HStack {
                            TextField("Team Number (e.g., 18140)", text: $teamNumberText)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            
                            Button(action: fetchTeamEvents) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.ftcOrange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(apiService.isLoading || teamNumberText.isEmpty)
                        }
                        
                    }
                    
                    Divider()
                    
                    // Response Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Events (\(events.count))")
                                .font(.headline)
                            
                            Spacer()
                            
                            if apiService.isLoading {
                                ProgressView()
                            }
                        }
                        
                        if let error = apiService.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        if events.isEmpty && !apiService.isLoading {
                            Text("No events found. Try searching for a team.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(events) { event in
                                    NavigationLink(destination: APITestEventMatchesView(
                                        event: event,
                                        teamNumber: currentTeamNumber ?? 0,
                                        season: currentYear,
                                        apiService: apiService
                                    )) {
                                        APITestEventRowView(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("API Test")
            .onAppear() {
                fetchTeamEvents()
            }
        }
    }
    
    private func fetchTeamEvents() {
        guard let teamNumber = Int(teamNumberText) else {
            return
        }
        
        currentTeamNumber = teamNumber
        
        Task {
            do {
                let fetchedEvents = try await apiService.fetchEventsForTeam(
                    season: currentYear,
                    teamNumber: teamNumber
                )
                await MainActor.run {
                    // Sort events by start date, most recent first
                    events = fetchedEvents.sorted { $0.dateStart > $1.dateStart }
                    if fetchedEvents.isEmpty {
                        connectionStatus = "No events found for team \(teamNumber) in \(currentYear)"
                    } else {
                        connectionStatus = "found \(fetchedEvents.count) event(s) for team \(teamNumber)"
                    }
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "\(error.localizedDescription)"
                    events = []
                }
            }
        }
    }
}

// MARK: - Event Row View

struct APITestEventRowView: View {
    let event: FTCEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.displayName)
                    .font(.headline)
                
                Spacer()
                
                if event.isInProgress {
                    Text("LIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                } else if event.isPast {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.ftcOrange)
                } else {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(event.displayLocation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.ftcGray)
                Text(formatDateRange(start: event.dateStart, end: event.dateEnd))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let code = event.code {
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Code: \(code)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let type = event.typeName {
                Text(type)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(3)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        
        return "\(startStr) - \(endStr)"
    }
}

// MARK: - Event Matches View

struct APITestEventMatchesView: View {
    let event: FTCEvent
    let teamNumber: Int
    let season: Int
    @ObservedObject var apiService: EventAPIService
    
    @State private var matches: [ScheduledMatch] = []
    @State private var selectedTournamentLevel = "qual"
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
                    
                    Text("Team \(teamNumber)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
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
                        
                        if isLoading {
                            ProgressView()
                        }
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if matches.isEmpty && !isLoading {
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
                                APITestMatchRowView(
                                    match: match,
                                    highlightTeam: teamNumber,
                                    event: event,
                                    season: season,
                                    tournamentLevel: selectedTournamentLevel,
                                    apiService: apiService
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Event Matches")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchMatches()
        }
    }
    
    private func fetchMatches() {
        guard let eventCode = event.code else {
            errorMessage = "Event code not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let endpoint = "/\(season)/schedule/\(eventCode)?tournamentLevel=\(selectedTournamentLevel)&teamNumber=\(teamNumber)"
                let data = try await apiService.makeRequestPublic(endpoint: endpoint)
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(ScheduleResponse.self, from: data)
                
                await MainActor.run {
                    matches = response.schedule
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    matches = []
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Match Row View with Import Button

struct APITestMatchRowView: View {
    let match: ScheduledMatch
    let highlightTeam: Int
    let event: FTCEvent
    let season: Int
    let tournamentLevel: String
    @ObservedObject var apiService: EventAPIService
    
    @State private var showingJSONSheet = false
    @State private var rawJSON: String = ""
    @State private var isLoadingJSON = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Match Card (NavigationLink)
            NavigationLink(destination: APITestMatchDetailView(
                match: match,
                event: event,
                teamNumber: highlightTeam,
                season: season,
                tournamentLevel: tournamentLevel,
                apiService: apiService
            )) {
                matchCardContent
            }
            .buttonStyle(PlainButtonStyle())
            
            // Import Button
            Button(action: fetchAndShowJSON) {
                VStack(spacing: 4) {
                    if isLoadingJSON {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.ftcOrange)
                            .font(.title2)
                    }
                    
                    Text("Import")
                        .font(.caption2)
                        .foregroundColor(.ftcOrange)
                }
                .frame(width: 70)
                .padding(.vertical, 8)
            }
            .disabled(isLoadingJSON)
        }
        .sheet(isPresented: $showingJSONSheet) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Match \(match.matchNumber) - Raw Score JSON")
                            .font(.headline)
                        
                        Text(rawJSON)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        Button(action: {
                            #if os(iOS)
                            UIPasteboard.general.string = rawJSON
                            #endif
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy JSON")
                            }
                            .font(.caption)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(5)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Score JSON")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingJSONSheet = false
                        }
                    }
                }
            }
        }
    }
    
    private var matchCardContent: some View {
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
                            APITestTeamBadge(team: team, highlightTeam: highlightTeam)
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
                            APITestTeamBadge(team: team, highlightTeam: highlightTeam)
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
    
    private func fetchAndShowJSON() {
        guard let eventCode = event.code else { return }
        
        isLoadingJSON = true
        
        Task {
            do {
                let json = try await apiService.fetchRawScore(
                    season: season,
                    eventCode: eventCode,
                    tournamentLevel: tournamentLevel,
                    matchNumber: match.matchNumber
                )
                
                await MainActor.run {
                    rawJSON = json
                    isLoadingJSON = false
                    showingJSONSheet = true
                }
            } catch {
                await MainActor.run {
                    rawJSON = "Error fetching score: \(error.localizedDescription)"
                    isLoadingJSON = false
                    showingJSONSheet = true
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

// MARK: - Team Badge View

struct APITestTeamBadge: View {
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

// MARK: - Match Detail View (optional, for clicking on the match card)

struct APITestMatchDetailView: View {
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
                            APITestAllianceScoreCard(alliance: alliance, highlightTeam: teamNumber)
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

// MARK: - Alliance Score Card

struct APITestAllianceScoreCard: View {
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
                
                APITestScoreRow(label: "Classified Artifacts", value: alliance.autoClassifiedArtifacts)
                APITestScoreRow(label: "Overflow Artifacts", value: alliance.autoOverflowArtifacts)
                APITestScoreRow(label: "Leave Points", value: alliance.autoLeavePoints)
                APITestScoreRow(label: "Pattern Points", value: alliance.autoPatternPoints)
                
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
                
                APITestScoreRow(label: "Classified Artifacts", value: alliance.teleopClassifiedArtifacts)
                APITestScoreRow(label: "Overflow Artifacts", value: alliance.teleopOverflowArtifacts)
                APITestScoreRow(label: "Depot Artifacts", value: alliance.teleopDepotArtifacts)
                APITestScoreRow(label: "Pattern Points", value: alliance.teleopPatternPoints)
                APITestScoreRow(label: "Base Points", value: alliance.teleopBasePoints)
                
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
                APITestRankingPointBadge(label: "Movement", achieved: alliance.movementRP ?? false)
                APITestRankingPointBadge(label: "Goal", achieved: alliance.goalRP ?? false)
                APITestRankingPointBadge(label: "Pattern", achieved: alliance.patternRP ?? false)
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

struct APITestScoreRow: View {
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

struct APITestRankingPointBadge: View {
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

#Preview {
    APITestView()
}
