//
//  SearchTeamsView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee (with lots of Claude) on 12/2/25.
//

import Foundation
import SwiftUI

struct SearchTeamsView: View {
    @StateObject private var apiService = EventAPIService()
    @ObservedObject var storageManager: MatchStorageManager
    @State private var events: [FTCEvent] = []
    @State private var teamNumberText = "18140"
    @State private var connectionStatus = ""
    @State private var selectedEvent: FTCEvent?
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
                                    NavigationLink(destination: EventMatchesView(
                                        event: event,
                                        teamNumber: currentTeamNumber ?? 0,
                                        season: currentYear,
                                        apiService: apiService,
                                        storageManager: storageManager
                                    )) {
                                        EventRowView(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("View Team Match Data")
            .onAppear() {
                fetchTeamEvents()
            }
        }
    }
    
    // MARK: - Actions
    
    private func testConnection() {
        connectionStatus = ""
        Task {
            do {
                let result = try await apiService.testConnection()
                await MainActor.run {
                    connectionStatus = result
                }
            } catch {
                await MainActor.run {
                    connectionStatus = "Connection failed: \(error.localizedDescription)"
                }
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

struct EventRowView: View {
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

struct EventMatchesView: View {
    let event: FTCEvent
    let teamNumber: Int
    let season: Int
    @ObservedObject var apiService: EventAPIService
    @ObservedObject var storageManager: MatchStorageManager
    
    @State private var matches: [ScheduledMatch] = []
    @State private var selectedTournamentLevel = "qual"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var rawJSON: String = ""
    @State private var showRawJSON = false
    
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
                                HStack(spacing: 0) {
                                    // Match card as NavigationLink
                                    NavigationLink(destination: MatchScoreView(
                                        match: match,
                                        event: event,
                                        teamNumber: teamNumber,
                                        season: season,
                                        tournamentLevel: selectedTournamentLevel,
                                        apiService: apiService
                                    )) {
                                        MatchRowView(match: match, highlightTeam: teamNumber)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
//                                    // Import button for team 18140
//                                    if teamNumber == 18140 {
//                                        ImportMatchButton(
//                                            match: match,
//                                            event: event,
//                                            teamNumber: teamNumber,
//                                            season: season,
//                                            tournamentLevel: selectedTournamentLevel,
//                                            apiService: apiService,
//                                            storageManager: storageManager
//                                        )
//                                        .padding(.leading, 8)
//                                    }
                                }
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
        rawJSON = ""
        
        Task {
            do {
                // Fetch raw JSON first for debugging
                let endpoint = "/\(season)/schedule/\(eventCode)?tournamentLevel=\(selectedTournamentLevel)&teamNumber=\(teamNumber)"
                let data = try await apiService.makeRequestPublic(endpoint: endpoint)
                
                await MainActor.run {
                    // Store raw JSON
                    if let jsonString = String(data: data, encoding: .utf8) {
                        rawJSON = jsonString
                    } else {
                        rawJSON = "Unable to decode response as UTF-8"
                    }
                }
                
                // Try to decode with simple decoder
                let decoder = JSONDecoder()
                let response = try decoder.decode(ScheduleResponse.self, from: data)
                
                await MainActor.run {
                    matches = response.schedule
                    isLoading = false
                }
            } catch let decodingError as DecodingError {
                await MainActor.run {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        errorMessage = "Missing key '\(key.stringValue)' – \(context.debugDescription)"
                    case .typeMismatch(let type, let context):
                        errorMessage = "Type mismatch for type \(type) – \(context.debugDescription)"
                    case .valueNotFound(let type, let context):
                        errorMessage = "Value not found for type \(type) – \(context.debugDescription)"
                    case .dataCorrupted(let context):
                        errorMessage = "Data corrupted – \(context.debugDescription)"
                    @unknown default:
                        errorMessage = "Decoding error: \(decodingError.localizedDescription)"
                    }
                    matches = []
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





