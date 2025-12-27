//
//  SearchTeamsView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee (with Claude) on 12/2/25.
//

import Foundation
import SwiftUI

// MARK: - Main Search Teams View

struct SearchTeamsView: View {
    @StateObject private var apiService = EventAPIService()
    @ObservedObject var storageManager: MatchStorageManager
    @ObservedObject private var teamSettings = TeamSettings.shared
    
    @State private var events: [FTCEvent] = []
    @State private var showingUniversalSearch = false
    @State private var isLoadingEvents = false
    @State private var errorMessage: String?
    
    var currentYear: Int {
        Calendar.current.component(.year, from    : Date())
    }
    
    var currentTeamNumber: Int? {
        Int(teamSettings.teamNumber)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Current Team Display
                    CurrentTeamHeader(
                        teamSettings: teamSettings,
                        onChangeTeam: {
                            showingUniversalSearch = true
                        }
                    )
                    
                    Divider()
                    
                    // Events Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Events (\(events.count))")
                                .font(.headline)
                            
                            Spacer()
                            
                            if isLoadingEvents {
                                ProgressView()
                            } else {
                                Button(action: fetchTeamEvents) {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.ftcOrange)
                                }
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
                        
                        if events.isEmpty && !isLoadingEvents && errorMessage == nil {
                            EmptyEventsView(teamNumber: teamSettings.teamNumber, year: currentYear)
                        } else {
                            EventsList(events: events, teamNumber: currentTeamNumber, season: currentYear, apiService: apiService)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Team Analysis")
            .sheet(isPresented: $showingUniversalSearch) {
                UniversalSearchView(
                    mode: .teamEvents,
                    onTeamSelected: { team in
                        fetchTeamEvents()
                    },
                    onEventSelected: nil
                )
            }
            .onAppear {
                fetchTeamEvents()
            }
        }
    }
    
    private func fetchTeamEvents() {
        guard let teamNumber = Int(teamSettings.teamNumber) else {
            errorMessage = "Invalid team number"
            return
        }
        
        isLoadingEvents = true
        errorMessage = nil
        events = []
        
        Task {
            do {
                let fetchedEvents = try await apiService.fetchEventsForTeam(
                    season: currentYear,
                    teamNumber: teamNumber
                )
                await MainActor.run {
                    events = fetchedEvents.sorted { $0.dateStart > $1.dateStart }
                    isLoadingEvents = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load events: \(error.localizedDescription)"
                    events = []
                    isLoadingEvents = false
                }
            }
        }
    }
}

// MARK: - Current Team Header

struct CurrentTeamHeader: View {
    @ObservedObject var teamSettings: TeamSettings
    let onChangeTeam: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Performance Analysis")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Team \(teamSettings.teamNumber)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ftcOrange)
                    
                    Text(teamSettings.teamName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !teamSettings.displayLocation.isEmpty && teamSettings.displayLocation != "Unknown" {
                        HStack {
                            Image(systemName: "mappin.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(teamSettings.displayLocation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onChangeTeam) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title2)
                        Text("Change")
                            .font(.caption)
                    }
                    .foregroundColor(.ftcOrange)
                    .padding()
                    .background(Color.ftcOrange.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Empty Events View

struct EmptyEventsView: View {
    let teamNumber: String
    let year: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No events found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Team \(teamNumber) hasn't registered for any \(year) events yet")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Events List

struct EventsList: View {
    let events: [FTCEvent]
    let teamNumber: Int?
    let season: Int
    @ObservedObject var apiService: EventAPIService
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(events) { event in
                NavigationLink(destination: TeamAnalysisEventView(
                    event: event,
                    teamNumber: teamNumber ?? 0,
                    season: season,
                    apiService: apiService
                )) {
                    EventRowViewAnalysis(event: event)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Event Row (same as before)

struct EventRowViewAnalysis: View {
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
