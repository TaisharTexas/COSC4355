//
//  SettingsView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var teamSettings = TeamSettings()
    @StateObject private var matchStorage = MatchStorageManager()
    @State private var showingEditSheet = false
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack{
            Form{
                Section("About Scoring"){
                    Text("Practice matches will be used during team analysis (use when running actual scrims you want to analize)")
                    Text("Custom match will not be used for internal team analysis (use when scoring other teams or when testing stuff)")
                }//: end section: about scoring
                Section("Team Info"){
                    HStack{
                        VStack(alignment: .leading){
                            Text("Team Number: \(teamSettings.teamNumber)")
                            Text("Team Name: \(teamSettings.teamName)")
                        }
                        Spacer()
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.title)
                                .foregroundColor(.ftcOrange)
                        }//: end button
                    }//: end hstack
                    
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
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Team Information")) {
                        HStack {
                            Text("Team Number")
                            Spacer()
                            TextField("Team #", text: $teamSettings.teamNumber)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Team Name")
                            Spacer()
                            TextField("Team Name", text: $teamSettings.teamName)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }//: end form
                .navigationTitle("Edit Team Info")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingEditSheet = false
                        }
                        .foregroundColor(.ftcOrange)
                    }
                }//: end toolbar
            }//: end NavView
        }//: end sheet
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


