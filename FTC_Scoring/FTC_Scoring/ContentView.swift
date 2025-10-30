//
//  ContentView.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 9/29/25.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        TabView{
            Tab("Score Match", systemImage: "slider.horizontal.2.square"){
                ScoreView()
            }
            Tab("Team Data", systemImage: "list.bullet.rectangle.fill"){
                TeamView()
            }
            Tab("Event Data", systemImage: "globe.fill"){
                EventView()
            }
            Tab("Settings", systemImage: "gearshape.fill"){
                SettingsView()
            }
        }
        .tint(Color("ftc_orange"))
    }
}

#Preview {
    ContentView()
}
