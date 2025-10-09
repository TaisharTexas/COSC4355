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
            Tab("Score Match", systemImage: "list.bullet.below.rectangle"){
                ScoreView()
            }
            Tab("Team Data", systemImage: "list.clipboard.fill"){
                TeamView()
            }
            Tab("Event Data", systemImage: "globe.fill"){
                EventView()
            }
        }
        .tint(Color("ftc_orange"))
    }
}

#Preview {
    ContentView()
}
