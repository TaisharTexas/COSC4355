//
//  ContentView.swift
//  CatExplorer
//
//  Created by Andrew Lee on 10/23/25.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var service: CatAPIService

    var body: some View {
        TabView{
            ExploreView()
                .tabItem{
                    Label("Explore", systemImage: "magnifyingglass")
                }
//                .environmentObject(service)
            
            FavoritesView()
                .tabItem{
                    Label("Favorites", systemImage: "heart")
                }
//                .environmentObject(service)
        }
    }
}
//
//#Preview {
//    ContentView()
//}
