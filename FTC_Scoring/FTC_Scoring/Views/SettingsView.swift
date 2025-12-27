//
//  SettingsView.swift (Updated for UniversalSearchView)
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var teamSettings = TeamSettings()
    @StateObject private var matchStorage = MatchStorageManager()
    @State private var showingTeamSearch = false
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack{
            Form{
                Section("About Scoring"){
                    Text("Practice matches will be used during team analysis (use when running actual scrims you want to analize)")
                    Text("Custom match will not be used for internal team analysis (use when scoring other teams or when testing stuff)")
                }//: end section: about scoring
                
                Section("Team Info"){
                    VStack(alignment: .leading, spacing: 12) {
                        // Team Number and Name
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Team \(teamSettings.teamNumber)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.ftcOrange)
                                
                                Text(teamSettings.teamName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 8) {
                                Button(action: {
                                    showingTeamSearch = true
                                }) {
                                    Label("Change Default", systemImage: "magnifyingglass")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.ftcOrange)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Additional Info
                        if let school = teamSettings.schoolName {
                            HStack {
                                Image(systemName: "building.2")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                Text(school)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "mappin.circle")
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            Text(teamSettings.displayLocation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if teamSettings.homeRegion != nil || teamSettings.districtCode != nil {
                            HStack {
                                Image(systemName: "flag")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                Text(teamSettings.regionInfo)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let rookie = teamSettings.rookieYear {
                            HStack {
                                Image(systemName: "star")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                Text("Rookie Year: \(rookie)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }//: end section: team info
                
                Section("Data Management") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                Text("Reset All Data")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Text("This will permanently delete all saved matches and sessions. This action cannot be undone.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }//: end section: data management
                
            }//: end form

        }//: end vstack
        .navigationTitle("Settings")
        .sheet(isPresented: $showingTeamSearch) {
            UniversalSearchView(
                mode: .teamInfo,
                onTeamSelected: nil,
                onEventSelected: nil
            )
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                matchStorage.deleteAllMatches()
            }
        } message: {
            Text("This will permanently delete all \(matchStorage.savedMatches.count) saved match(es). This action cannot be undone.")
        }//: end delete button alert
    }//: end body
}

#Preview {
    SettingsView()
}
