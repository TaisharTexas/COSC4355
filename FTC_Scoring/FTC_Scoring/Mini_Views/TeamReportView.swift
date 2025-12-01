//
//  TeamReportView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/26/25.
//

import SwiftUI
import Combine

struct TeamReportView: View{
    
    @ObservedObject var storageManager: MatchStorageManager
    @StateObject private var teamSettings = TeamSettings()
        
    // Group matches by session
    private var groupedMatches: [(session: String, matches: [MatchRecord])] {
        let groups = Dictionary(grouping: storageManager.savedMatches) { match in
            match.session
        }
        return groups.map { (session: $0.key, matches: $0.value.sorted { $0.matchNumber < $1.matchNumber }) }
            .sorted { $0.session > $1.session } // Most recent sessions first
    }

    
    var body: some View {
        NavigationStack {
            
            HStack{
                Text("\(teamSettings.teamNumber):")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(teamSettings.teamName)
                    .font(.headline)
                    .foregroundColor(.ftcOrange)
                    .lineLimit(1)
            }
            
            HStack {
                Text("Import Matches from Event:")
                    .font(.headline)
                    .foregroundColor(.primary)
                NavigationLink(destination: SelectEvent()) {
                    Text("Select Event")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(minWidth: 75, minHeight: 25)
                        .background(Color.ftcOrange)
                        .cornerRadius(20)
                        .font(.headline)
                }
            }
            .padding()
            
            HStack {
                Image(systemName: "pencil")
                    .foregroundColor(.primary)
                    .font(.title3)
                
                Text("Matches")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Button(action: {
                    // Force view refresh by triggering objectWillChange
                    storageManager.objectWillChange.send()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.ftcOrange)
                        .font(.title3)
                }
                
                Spacer()
                
                Text("Include")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            
            ScrollView {
                VStack(spacing: 0) {
                    if storageManager.savedMatches.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No matches recorded yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Record matches in the Score tab")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(groupedMatches.indices, id: \.self) { sessionIndex in
                            let sessionGroup = groupedMatches[sessionIndex]
                            
                            // Session Header
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.ftcOrange)
                                        .font(.caption)
                                    Text("Session: \(sessionGroup.session)")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                Text("\(sessionGroup.matches.count) match\(sessionGroup.matches.count == 1 ? "" : "es")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray5))
                            
                            // Matches in this session
                            ForEach(sessionGroup.matches) { match in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text("Match \(match.matchNumber)")
                                                .font(.system(size: 17))
                                                .foregroundColor(.primary)
                                            
                                            // Match type badge
                                            Text(match.matchType.rawValue)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(match.matchType == .practice ? Color.ftcOrange.opacity(0.2) : Color.purple.opacity(0.2))
                                                .foregroundColor(match.matchType == .practice ? .ftcOrange : .purple)
                                                .cornerRadius(4)
                                            //Match side badge
                                            Text(match.matchSide.rawValue)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(match.matchSide == .blue ? Color.ftcBlue.opacity(0.2) : Color.ftcRed.opacity(0.2))
                                                .foregroundColor(match.matchSide == .blue ? .ftcBlue : .ftcRed)
                                                .cornerRadius(4)
                                        }
                                        
                                        HStack(spacing: 12) {
                                            Text("Score: \(match.totalScore)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("•")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("RP: \(match.totalRankingPoints)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: bindingForMatch(match))
                                        .labelsHidden()
                                        .tint(.orange)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray6))
                                
                                if match.id != sessionGroup.matches.last?.id {
                                    Divider()
                                        .padding(.leading, 20)
                                }
                            }
                            .onDelete { indexSet in
                                deleteMatches(from: sessionGroup.matches, at: indexSet)
                            }
                            
                            // Add spacing between sessions
                            if sessionIndex < groupedMatches.count - 1 {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 8)
                            }
                        }//: end loop
                    }//: end else
                }//: end Vstack
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
            }//: end scrollView
        }//: end NavStack
    }//: end body
    
    private func bindingForMatch(_ match: MatchRecord) -> Binding<Bool> {
        Binding(
            get: {
                if let index = storageManager.savedMatches.firstIndex(where: { $0.id == match.id }) {
                    return storageManager.savedMatches[index].isIncluded
                }
                return false
            },
            set: { newValue in
                if let index = storageManager.savedMatches.firstIndex(where: { $0.id == match.id }) {
                    storageManager.savedMatches[index].isIncluded = newValue
                    _ = storageManager.saveToUserDefaults()
                }
            }
        )
    }//: end binding func
    
    private func deleteMatches(from sessionMatches: [MatchRecord], at indexSet: IndexSet) {
        // Get the IDs of matches to delete from the session group
        let matchesToDelete = indexSet.map { sessionMatches[$0].id }
        
        // Find and delete these matches from the main savedMatches array
        let indicesToDelete = IndexSet(
            storageManager.savedMatches.enumerated()
                .filter { matchesToDelete.contains($0.element.id) }
                .map { $0.offset }
        )
        
        storageManager.deleteMatch(at: indicesToDelete)
    }//: end delete func
}

