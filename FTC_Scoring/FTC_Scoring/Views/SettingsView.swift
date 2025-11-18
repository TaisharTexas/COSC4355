//
//  SettingsView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var teamSettings = TeamSettings()
    @State private var showingEditSheet = false
    
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
    }//: end body
}

#Preview {
    SettingsView()
}


