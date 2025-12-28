//
//  EventView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

struct EventView: View {
    @StateObject private var apiService = EventAPIService()
    @StateObject private var teamSettings = TeamSettings()
    
    @State private var events: [FTCEvent] = []
    @State private var filteredEvents: [FTCEvent] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var searchText = ""
    @State private var selectedRegion: String = ""
    @State private var showAllRegions = false
    
    @State private var showPastEvents = false
    @State private var showCurrentEvents = true
    @State private var showFutureEvents = true
    
    @State private var showFiltersSheet = false
    
    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var uniqueRegions: [String] {
        let regions = Set(events.compactMap { $0.regionCode })
        return regions.sorted()
    }
    
    var activeFiltersCount: Int {
        var count = 0
        if !showAllRegions { count += 1 }
        if !searchText.isEmpty { count += 1 }
        if !showPastEvents { count += 1 }
        if !showCurrentEvents { count += 1 }
        if !showFutureEvents { count += 1 }
        return count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar with Filters Button
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search events...", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: searchText) { _ in
                                applyFilters()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                applyFilters()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    
                    // Filters Button
                    Button(action: {
                        showFiltersSheet = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.title2)
                                .foregroundColor(.ftcOrange)
                            
                            // Badge showing active filter count
                            if activeFiltersCount > 0 {
                                Text("\(activeFiltersCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                Divider()
                
                // Events List
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading events...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error Loading Events")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: fetchEvents) {
                            Text("Retry")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.ftcOrange)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredEvents.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No Events Found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(searchText.isEmpty ? "No events match your filters" : "No events match '\(searchText)'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event, season: currentYear)) {
                                    EventRowCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: fetchEvents) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.ftcOrange)
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showFiltersSheet) {
                EventFiltersSheet(
                    showAllRegions: $showAllRegions,
                    selectedRegion: $selectedRegion,
                    showPastEvents: $showPastEvents,
                    showCurrentEvents: $showCurrentEvents,
                    showFutureEvents: $showFutureEvents,
                    uniqueRegions: uniqueRegions,
                    teamRegion: teamSettings.homeRegion ?? "",
                    onApply: {
                        applyFilters()
                    },
                    onReset: {
                        resetFilters()
                    }
                )
            }
            .onAppear {
                if events.isEmpty {
                    // Set initial region from team settings
                    selectedRegion = teamSettings.homeRegion ?? ""
                    fetchEvents()
                }
            }
        }
    }
    
    // MARK: - Fetch Events
    
    private func fetchEvents() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedEvents = try await apiService.fetchEvents(season: currentYear)
                await MainActor.run {
                    events = fetchedEvents.sorted { $0.dateStart > $1.dateStart }
                    applyFilters()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Apply Filters
    
    private func applyFilters() {
        var filtered = events
        
        // Filter by region (if not showing all)
        if !showAllRegions && !selectedRegion.isEmpty {
            filtered = filtered.filter { event in
                event.regionCode == selectedRegion
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { event in
                let nameMatch = event.name?.lowercased().contains(searchText.lowercased()) ?? false
                let locationMatch = event.displayLocation.lowercased().contains(searchText.lowercased())
                let regionMatch = event.regionCode?.lowercased().contains(searchText.lowercased()) ?? false
                let codeMatch = event.code?.lowercased().contains(searchText.lowercased()) ?? false
                return nameMatch || locationMatch || regionMatch || codeMatch
            }
        }
        
        // Filter by date range
        let now = Date()
        filtered = filtered.filter { event in
            let isPast = event.dateEnd < now
            let isCurrent = event.dateStart <= now && event.dateEnd >= now
            let isFuture = event.dateStart > now
            
            return (isPast && showPastEvents) ||
                   (isCurrent && showCurrentEvents) ||
                   (isFuture && showFutureEvents)
        }
        
        filteredEvents = filtered
    }
    
    // MARK: - Reset Filters
    
    private func resetFilters() {
        showAllRegions = false
        selectedRegion = teamSettings.homeRegion ?? ""
        showPastEvents = false
        showCurrentEvents = true
        showFutureEvents = true
        searchText = ""
        applyFilters()
    }
}

// MARK: - Event Filters Sheet

struct EventFiltersSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var showAllRegions: Bool
    @Binding var selectedRegion: String
    @Binding var showPastEvents: Bool
    @Binding var showCurrentEvents: Bool
    @Binding var showFutureEvents: Bool
    
    let uniqueRegions: [String]
    let teamRegion: String
    let onApply: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Region Filter")) {
                    Toggle("Show All Regions", isOn: $showAllRegions)
                        .tint(.ftcOrange)
                    
                    if !showAllRegions {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Region")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !teamRegion.isEmpty {
                                Button(action: {
                                    selectedRegion = teamRegion
                                }) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(.ftcOrange)
                                        Text("\(teamRegion) (Team Region)")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if selectedRegion == teamRegion {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.ftcOrange)
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider()
                            }
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(uniqueRegions, id: \.self) { region in
                                        if region != teamRegion {
                                            Button(action: {
                                                selectedRegion = region
                                            }) {
                                                HStack {
                                                    Text(region)
                                                        .foregroundColor(.primary)
                                                    Spacer()
                                                    if selectedRegion == region {
                                                        Image(systemName: "checkmark")
                                                            .foregroundColor(.ftcOrange)
                                                    }
                                                }
                                                .padding(.vertical, 8)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            if region != uniqueRegions.last {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                }
                
                Section(header: Text("Date Range")) {
                    Toggle("Show Past Events", isOn: $showPastEvents)
                        .tint(.ftcOrange)
                    Toggle("Show Current Events", isOn: $showCurrentEvents)
                        .tint(.ftcOrange)
                    Toggle("Show Future Events", isOn: $showFutureEvents)
                        .tint(.ftcOrange)
                }
                
                Section {
                    Button(action: {
                        onReset()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Defaults")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filter Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.ftcOrange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .foregroundColor(.ftcOrange)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Event Row Card

struct EventRowCard: View {
    let event: FTCEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let type = event.typeName {
                        Text(type)
                            .font(.caption)
                            .foregroundColor(.ftcOrange)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    statusBadge
                    
                    if let code = event.code {
                        Text(code)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Label(event.displayLocation, systemImage: "mappin.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(formatDateRange(start: event.dateStart, end: event.dateEnd), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let region = event.regionCode {
                HStack {
                    Label("Region: \(region)", systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(.ftcOrange)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private var statusBadge: some View {
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
            HStack(spacing: 2) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                Text("Completed")
                    .font(.caption)
            }
            .foregroundColor(.green)
        } else {
            HStack(spacing: 2) {
                Image(systemName: "calendar")
                    .font(.caption)
                Text("Upcoming")
                    .font(.caption)
            }
            .foregroundColor(.blue)
        }
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

// MARK: - Event Detail View

struct EventDetailView: View {
    let event: FTCEvent
    let season: Int
    
    @StateObject private var apiService = EventAPIService()
    @State private var teams: [FTCTeam] = []
    @State private var isLoadingTeams = false
    @State private var teamErrorMessage: String?
    @State private var searchText = ""
    
    var filteredTeams: [FTCTeam] {
        if searchText.isEmpty {
            return teams
        } else {
            return teams.filter { team in
                let numberMatch = String(team.teamNumber).contains(searchText)
                let nameMatch = team.nameFull?.lowercased().contains(searchText.lowercased()) ?? false
                let shortNameMatch = team.nameShort?.lowercased().contains(searchText.lowercased()) ?? false
                return numberMatch || nameMatch || shortNameMatch
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Event Header
            VStack(alignment: .leading, spacing: 12) {
                Text(event.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let type = event.typeName {
                    Text(type)
                        .font(.subheadline)
                        .foregroundColor(.ftcOrange)
                }
                
                Divider()
                
                // Event Details
                VStack(alignment: .leading, spacing: 6) {
                    if let venue = event.venue {
                        Label(venue, systemImage: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Label(event.displayLocation, systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(formatDateRange(start: event.dateStart, end: event.dateEnd), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        if let region = event.regionCode {
                            Label("Region: \(region)", systemImage: "flag.fill")
                                .font(.caption)
                                .foregroundColor(.ftcOrange)
                        }
                        
                        if let code = event.code {
                            Label("Code: \(code)", systemImage: "tag.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if event.remote || event.hybrid {
                        HStack(spacing: 12) {
                            if event.remote {
                                Label("Remote", systemImage: "wifi")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            if event.hybrid {
                                Label("Hybrid", systemImage: "arrow.triangle.merge")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Search Bar for Teams
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search teams...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray5))
            
            Divider()
            
            // Teams List
            if isLoadingTeams {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading teams...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = teamErrorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Error Loading Teams")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: fetchTeams) {
                        Text("Retry")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.ftcOrange)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredTeams.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: searchText.isEmpty ? "person.3" : "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No Teams Registered" : "No Teams Found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    if !searchText.isEmpty {
                        Text("No teams match '\(searchText)'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredTeams.indices, id: \.self) { index in
                            let team = filteredTeams[index]
                            
                            NavigationLink(destination: TeamAnalysisEventView(
                                event: event,
                                teamNumber: team.teamNumber,
                                season: season,
                                apiService: apiService
                            )) {
                                TeamRowCard(team: team)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if index < filteredTeams.count - 1 {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .navigationTitle("Event Teams")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchTeams()
        }
    }
    
    private func fetchTeams() {
        guard let eventCode = event.code else {
            teamErrorMessage = "Event code not available"
            return
        }
        
        isLoadingTeams = true
        teamErrorMessage = nil
        
        Task {
            do {
                // Fetch teams for this event
                let data = try await apiService.makeRequestPublic(endpoint: "/\(season)/teams?eventCode=\(eventCode)")
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(TeamListingsResponse.self, from: data)
                
                await MainActor.run {
                    teams = response.teams.sorted { $0.teamNumber < $1.teamNumber }
                    isLoadingTeams = false
                }
            } catch {
                await MainActor.run {
                    teamErrorMessage = error.localizedDescription
                    teams = []
                    isLoadingTeams = false
                }
            }
        }
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

// MARK: - Team Row Card

struct TeamRowCard: View {
    let team: FTCTeam
    
    var body: some View {
        HStack(spacing: 12) {
            // Team Number Badge
            Text(team.displayTeamNumber ?? "\(team.teamNumber)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(Color.ftcOrange)
                .cornerRadius(10)
            
            // Team Info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let school = team.schoolName {
                    Text(school)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if !team.locationString.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle")
                            .font(.caption2)
                        Text(team.locationString)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

#Preview {
    EventView()
}
