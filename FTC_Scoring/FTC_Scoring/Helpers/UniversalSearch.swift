//
//  UniversalSearchView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee (with Claude) on 12/27/25.
//

import SwiftUI

// MARK: - Search Mode Definition

enum SearchMode {
    case teamEvents        // Find events by team â†’ Navigate to analysis
    case teamInfo          // Find team info â†’ Set as default
    case eventDirectory    // Browse/filter events â†’ Import matches or view details
    
    var title: String {
        switch self {
        case .teamEvents: return "Team Performance"
        case .teamInfo: return "Find Team"
        case .eventDirectory: return "Event Directory"
        }
    }
    
    var icon: String {
        switch self {
        case .teamEvents: return "chart.bar.fill"
        case .teamInfo: return "person.text.rectangle"
        case .eventDirectory: return "calendar"
        }
    }
    
    var placeholder: String {
        switch self {
        case .teamEvents: return "Team number or name"
        case .teamInfo: return "Team number or name"
        case .eventDirectory: return "Event name or location"
        }
    }
}

// MARK: - Search Filter Type

enum SearchFilterType {
    case teamNumber
    case teamName
    case eventName
    case eventRegion
    case eventState
    case eventDateRange
}

// MARK: - Universal Search View

struct UniversalSearchView: View {
    let mode: SearchMode
    let onTeamSelected: ((FTCTeam) -> Void)?
    let onEventSelected: ((FTCEvent) -> Void)?
    
    @StateObject private var apiService = EventAPIService()
    @ObservedObject private var teamSettings = TeamSettings.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var selectedFilter: SearchFilterType = .teamNumber
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    // Results
    @State private var teamResults: [FTCTeam] = []
    @State private var eventResults: [FTCEvent] = []
    
    // Event filters
    @State private var selectedRegion: String = "All"
    @State private var showPastEvents = true
    @State private var showFutureEvents = true
    @State private var showCurrentEvents = true
    
    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mode Switcher (if you want to allow switching between modes)
                // Otherwise, this can be removed if each mode is always separate
                
                // Filter Selector
                filterSelector
                
                // Search Bar
                searchBar
                
                Divider()
                
                // Additional Filters (for event directory)
                if mode == .eventDirectory {
                    eventFilters
                }
                
                // Results Section
                ScrollView {
                    VStack(spacing: 16) {
                        if isSearching {
                            ProgressView("Searching...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if let error = errorMessage {
                            errorView(error)
                        } else {
                            resultsView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(mode.title)
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
    
    // MARK: - Filter Selector
    
    @ViewBuilder
    private var filterSelector: some View {
        switch mode {
        case .teamEvents, .teamInfo:
            Picker("Search By", selection: $selectedFilter) {
                Text("Number").tag(SearchFilterType.teamNumber)
                Text("Name").tag(SearchFilterType.teamName)
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedFilter) { _ in
                searchText = ""
                clearResults()
            }
            
        case .eventDirectory:
            Picker("Search By", selection: $selectedFilter) {
                Text("Name").tag(SearchFilterType.eventName)
                Text("Region").tag(SearchFilterType.eventRegion)
                Text("State").tag(SearchFilterType.eventState)
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedFilter) { _ in
                searchText = ""
                clearResults()
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(mode.placeholder, text: $searchText)
                .textFieldStyle(.plain)
                .keyboardType(selectedFilter == .teamNumber ? .numberPad : .default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onSubmit {
                    performSearch()
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    clearResults()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: performSearch) {
                Text("Search")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.ftcOrange)
                    .cornerRadius(8)
            }
            .disabled(searchText.isEmpty || isSearching)
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - Event Filters
    
    private var eventFilters: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter Events")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Toggle("Show Past Events", isOn: $showPastEvents)
                Toggle("Show Current Events", isOn: $showCurrentEvents)
                Toggle("Show Future Events", isOn: $showFutureEvents)
            }
            .padding(.horizontal)
            .onChange(of: showPastEvents) { _ in filterEventResults() }
            .onChange(of: showCurrentEvents) { _ in filterEventResults() }
            .onChange(of: showFutureEvents) { _ in filterEventResults() }
            
            Divider()
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.3))
    }
    
    // MARK: - Results View
    
    @ViewBuilder
    private var resultsView: some View {
        switch mode {
        case .teamEvents, .teamInfo:
            if teamResults.isEmpty && !searchText.isEmpty {
                emptyStateView
            } else {
                teamResultsList
            }
            
        case .eventDirectory:
            if eventResults.isEmpty && !searchText.isEmpty {
                emptyStateView
            } else {
                eventResultsList
            }
        }
    }
    
    private var teamResultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !teamResults.isEmpty {
                Text("Found \(teamResults.count) team\(teamResults.count == 1 ? "" : "s")")
                    .font(.headline)
            }
            
            ForEach(teamResults) { team in
                TeamResultCard(
                    team: team,
                    mode: mode,
                    onSelect: {
                        handleTeamSelection(team)
                    }
                )
            }
        }
    }
    
    private var eventResultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !eventResults.isEmpty {
                Text("Found \(eventResults.count) event\(eventResults.count == 1 ? "" : "s")")
                    .font(.headline)
            }
            
            ForEach(eventResults) { event in
                EventResultCard(
                    event: event,
                    onSelect: {
                        handleEventSelection(event)
                    }
                )
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Try a different search term or filter")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Search Failed")
                .font(.headline)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Search Logic
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        clearResults()
        isSearching = true
        errorMessage = nil
        
        Task {
            do {
                switch mode {
                case .teamEvents, .teamInfo:
                    try await searchTeams()
                case .eventDirectory:
                    try await searchEvents()
                }
                
                await MainActor.run {
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSearching = false
                }
            }
        }
    }
    
    private func searchTeams() async throws {
        switch selectedFilter {
        case .teamNumber:
            guard let teamNumber = Int(searchText) else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid team number"])
            }
            let team = try await apiService.searchTeamByNumber(season: currentYear, teamNumber: teamNumber)
            await MainActor.run {
                if let team = team {
                    teamResults = [team]
                } else {
                    teamResults = []
                }
            }
            
        case .teamName:
            let teams = try await apiService.searchTeamsByName(
                season: currentYear,
                searchText: searchText,
                maxPages: 5
            )
            await MainActor.run {
                teamResults = teams
            }
            
        default:
            break
        }
    }
    
    private func searchEvents() async throws {
        var events: [FTCEvent] = []
        
        switch selectedFilter {
        case .eventName:
            // Get all events and filter by name
            let allEvents = try await apiService.fetchEvents(season: currentYear)
            events = allEvents.filter { event in
                event.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
            
        case .eventRegion:
            // Get all events and filter by region
            let allEvents = try await apiService.fetchEvents(season: currentYear)
            events = allEvents.filter { event in
                event.regionCode?.lowercased().contains(searchText.lowercased()) ?? false
            }
            
        case .eventState:
            // Get all events and filter by state
            let allEvents = try await apiService.fetchEvents(season: currentYear)
            events = allEvents.filter { event in
                event.stateprov?.lowercased().contains(searchText.lowercased()) ?? false
            }
            
        default:
            break
        }
        
        await MainActor.run {
            eventResults = events
            filterEventResults()
        }
    }
    
    private func filterEventResults() {
        let now = Date()
        eventResults = eventResults.filter { event in
            let isPast = event.dateEnd < now
            let isCurrent = event.dateStart <= now && event.dateEnd >= now
            let isFuture = event.dateStart > now
            
            return (isPast && showPastEvents) ||
                   (isCurrent && showCurrentEvents) ||
                   (isFuture && showFutureEvents)
        }
    }
    
    private func clearResults() {
        teamResults = []
        eventResults = []
        errorMessage = nil
    }
    
    // MARK: - Selection Handlers
    
    private func handleTeamSelection(_ team: FTCTeam) {
        switch mode {
        case .teamInfo:
            // Set as default team in settings
            teamSettings.updateFromTeam(team)
            onTeamSelected?(team)
            dismiss()
            
        case .teamEvents:
            // Navigate to team analysis
            teamSettings.updateFromTeam(team)
            onTeamSelected?(team)
            dismiss()
            
        default:
            break
        }
    }
    
    private func handleEventSelection(_ event: FTCEvent) {
        onEventSelected?(event)
        dismiss()
    }
}

// MARK: - Team Result Card

struct TeamResultCard: View {
    let team: FTCTeam
    let mode: SearchMode
    let onSelect: () -> Void
    
    var actionText: String {
        switch mode {
        case .teamInfo: return "Select"
        case .teamEvents: return "Analyze"
        case .eventDirectory: return ""
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(team.teamNumberString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ftcOrange)
                    
                    Spacer()
                    
                    Text(actionText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.ftcOrange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.ftcOrange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(team.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let school = team.schoolName {
                    Label(school, systemImage: "building.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Label(team.locationString, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let region = team.homeRegion {
                    Label("Region: \(region)", systemImage: "flag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Event Result Card

struct EventResultCard: View {
    let event: FTCEvent
    let onSelect: () -> Void
    
    var statusBadge: some View {
        Group {
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
                    .foregroundColor(.green)
            } else {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
            }
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    statusBadge
                }
                
                Label(event.displayLocation, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label(formatDateRange(start: event.dateStart, end: event.dateEnd),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let region = event.regionCode {
                    Label("Region: \(region)", systemImage: "flag")
                        .font(.caption)
                        .foregroundColor(.ftcOrange)
                }
                
                if let code = event.code {
                    Label("Code: \(code)", systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let calendar = Calendar.current
        if calendar.isDate(start, inSameDayAs: end) {
            return formatter.string(from: start)
        } else {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
}

// MARK: - Preview

#Preview {
    UniversalSearchView(
        mode: .teamEvents,
        onTeamSelected: nil,
        onEventSelected: nil
    )
}
