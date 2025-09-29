//
//  ContentView.swift
//  Exam1_Lee_Andrew
//
//  Created by Andrew Lee on 9/25/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView{
            Tab("Pets", systemImage: "square.grid.2x2.fill"){
                PetsView()
            }
            Tab("Favorites", systemImage: "heart.fill"){
                FavoritesView()
            }
            Tab("About", systemImage: "info.circle"){
                AboutView()
            }
        }//: Tab View
    }
}

//#Preview {
//    ContentView()
//}
