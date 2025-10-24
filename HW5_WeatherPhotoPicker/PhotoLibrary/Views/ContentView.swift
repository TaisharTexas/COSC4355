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
    @State private var imageStore = WeatherImageStore()
    
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
            
            WeatherView()
                .tabItem{
                    Image(systemName: "cloud.sun.fill")
                    Text("Weather")
                }
            
            SettingsView()
                .tabItem{
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        // .environment() shares PhotoStore with all child views
        .environment(photoStore)
        // adding in my own just for weather pics
        .environment(imageStore)
    }
}


#Preview {
    ContentView()
}
