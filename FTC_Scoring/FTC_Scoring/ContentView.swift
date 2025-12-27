//
//  ContentView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 9/29/25.
//

import SwiftUI


struct ContentView: View {
    
    @StateObject private var storageManager = MatchStorageManager()
    
    var body: some View {
        TabView{
            Tab("Score Match", systemImage: "slider.horizontal.2.square"){
                ScoreView(storageManager: storageManager)
            }
            Tab("Team Data", systemImage: "list.bullet.rectangle.fill"){
                TeamView(storageManager: storageManager)
            }
            Tab("Search Teams", systemImage: "magnifyingglass"){
                SearchTeamsView(storageManager: storageManager)
            }
            Tab("Event Data", systemImage: "globe.fill"){
                EventView()
            }
            Tab("Settings", systemImage: "gearshape.fill"){
                SettingsView()
            }
//            Tab("API Test", systemImage: "flask.fill"){
//                APITestView(storageManager: storageManager)
//            }
        }
        .tint(Color("ftc_orange"))
    }
}

#Preview {
    ContentView()
}
