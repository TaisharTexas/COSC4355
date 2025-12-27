//
//  TeamSearchView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee (with Claude) on 12/27/25.
//

import SwiftUI

struct TeamSearchCard: View {
    @ObservedObject var teamSettings: TeamSettings
    @StateObject private var apiService = EventAPIService()
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var searchMode: SearchMode = .number
    @State private var searchResults: [FTCTeam] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var selectedTeam: FTCTeam?
    @State private var showConfirmation = false
    
    enum SearchMode {
        case number, name
    }
    
    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Mode Picker
                Picker("Search By", selection: $searchMode) {
                    Text("Team Number").tag(SearchMode.number)
                    Text("Team Name").tag(SearchMode.name)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField(
                        searchMode == .number ? "Enter team number (e.g., 18140)" : "Enter team or school name",
                        text: $searchText
                    )
                    .textFieldStyle(.plain)
                    .keyboardType(searchMode == .number ? .numberPad : .default)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit {
                        performSearch()
                    }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                            errorMessage = nil
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
                
                Divider()
                
                // Results Section
                ScrollView {
                    VStack(spacing: 16) {
                        if isSearching {
                            HStack {
                                ProgressView()
                                Text("Searching...")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        
                        if let error = errorMessage {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                            .padding()
                        }
                        
                        if !searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Found \(searchResults.count) team\(searchResults.count == 1 ? "" : "s")")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(searchResults) { team in
                                    TeamResultRow(team: team) {
                                        selectedTeam = team
                                        showConfirmation = true
                                    }
                                }
                            }
                            .padding(.vertical)
                        } else if !isSearching && errorMessage == nil && !searchText.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No teams found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Try a different search term")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Search Teams")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.ftcOrange)
                }
            }
            .alert("Set as Default Team?", isPresented: $showConfirmation, presenting: selectedTeam) { team in
                Button("Cancel", role: .cancel) { }
                Button("Confirm") {
                    teamSettings.updateFromTeam(team)
                    dismiss()
                }
            } message: { team in
                Text("Set team \(team.teamNumber) - \(team.displayName) as your default team?")
            }
        }
    }
    
    // MARK: - Search Logic
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        errorMessage = nil
        searchResults = []
        isSearching = true
        
        Task {
            do {
                if searchMode == .number {
                    // Search by team number
                    guard let teamNumber = Int(searchText) else {
                        await MainActor.run {
                            errorMessage = "Please enter a valid team number"
                            isSearching = false
                        }
                        return
                    }
                    
                    if let team = try await apiService.searchTeamByNumber(season: currentYear, teamNumber: teamNumber) {
                        await MainActor.run {
                            searchResults = [team]
                            isSearching = false
                        }
                    } else {
                        await MainActor.run {
                            errorMessage = "Team \(teamNumber) not found in \(currentYear) season"
                            isSearching = false
                        }
                    }
                } else {
                    // Search by name
                    let teams = try await apiService.searchTeamsByName(
                        season: currentYear,
                        searchText: searchText,
                        maxPages: 5
                    )
                    
                    await MainActor.run {
                        searchResults = teams
                        if teams.isEmpty {
                            errorMessage = "No teams found matching '\(searchText)'"
                        }
                        isSearching = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Search failed: \(error.localizedDescription)"
                    isSearching = false
                }
            }
        }
    }
}

// MARK: - Team Result Row

struct TeamResultRow: View {
    let team: FTCTeam
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(team.teamNumber)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ftcOrange)
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.ftcOrange)
                        .font(.title3)
                }
                
                Text(team.fullDisplayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let school = team.schoolName {
                    HStack {
                        Image(systemName: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(school)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                HStack {
                    Image(systemName: "mappin.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(team.locationString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let region = team.homeRegion {
                    HStack {
                        Image(systemName: "flag")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Region: \(region)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let rookie = team.rookieYear {
                    HStack {
                        Image(systemName: "star")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Rookie Year: \(rookie)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    TeamSearchCard(teamSettings: TeamSettings())
}
