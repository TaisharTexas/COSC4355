//
//  ContentView.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI

// MARK: - Main App View
struct ContentView: View {
    @State private var photoStore = PhotoStore()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Home")
                }
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
        }
        // .environment() shares PhotoStore with all child views
        .environment(photoStore)
    }
}


#Preview {
    ContentView()
}
