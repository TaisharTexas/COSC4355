//
//  SettingsView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack{
            Form{
                Section("About Scoring"){
                    Text("Practice match locks teleop and endgame scoring tabs until correct time")
                    Text("Custom match leaves all scoring tabs accessible at all times")
                }//: end section: about scoring
                Section("Team Info"){
                    HStack{
                        VStack{
                            Text("Team Number: 8668")
                        }
                        Spacer()
                        Button(action: {
                            print("edit button pressed")
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.title)
                                .foregroundColor(.ftcOrange)
                        }//: end button
                    }//: end hstack
                    
                }//: end section: team info
                
            }

        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}


