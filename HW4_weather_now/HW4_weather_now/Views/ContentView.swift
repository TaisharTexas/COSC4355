//
//  ContentView.swift
//  HW4_weather_now
//
//  Created by Andrew Lee on 10/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var favorites: FavoritesStore
    @StateObject private var service = WeatherAPIService()
    @State private var selectedCity: City?
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isSearching = false
    
    let layout = [
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        /**
         Modeling after weather iOS app.
            Want Title (use grid view like for exam 1 but just one column, next to title have settings cog) -- outside scrollable
            list favorites as cards in the grid (non-volitile storage, card background reflects weather for city) -- make scrollable
            search bar at the bottom -- outside scrollable
                on click, have a sheet slide up/maybe go full screen fade in for search
                on select, go to detail screen
                on deselect, fade back to favorites screen
         */
        
        NavigationStack{
            VStack{
                //Title and Settings
                HStack{
                    Text("Weather App")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }//: Title HStack Block
                
                //Favorites Grid
                if favorites.cities.isEmpty{
                    Text("empty fav list")
                }//: Empty fav list Block
                else{
                    ScrollView{
                        LazyVGrid(columns: layout) {
                            ForEach(favorites.cities){favCity in
                                NavigationLink(value: favCity){
                                    VStack {
                                        Text(favCity.name)
                                            .font(.headline)
                                        Text(favCity.country)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(12)
                                }//:FavCity Card Block
                            }//: ForEach
                        }//:Lazy VStack
                    }//:Scroll View
                }//:Fav List Block
                Spacer()
                
                //Search Field (is really just a button that looks like a search field that brings up the search sheet)
                Button(action: {
                    isSearching = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Search for a city")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
            }//:Outer Vstack
            .padding()
            .navigationDestination(for: City.self) { city in
                CityDetailView(city: city, service: service)
            }
            .sheet(isPresented: $isSearching, onDismiss: {
                searchText = ""
                service.searchResults = []
                isSearchFieldFocused = false
            }) {
                NavigationStack {
                    VStack {
                        // Search Field
                        HStack {
                            TextField("Enter city name", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .focused($isSearchFieldFocused)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        if !searchText.isEmpty {
                                            Button(action: {
                                                searchText = ""
                                                service.searchResults = []
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                                    .padding(.trailing, 8)
                                            }
                                        }
                                    }
                                )
                                .onSubmit {
                                    Task {
                                        await service.searchCities(query: searchText)
                                    }
                                }
                            
                            // X button to close entire search sheet
                            Button(action: {
                                searchText = ""
                                service.searchResults = []
                                isSearchFieldFocused = false
                                isSearching = false
                            }) {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .font(.headline)
                            }
                        }
                        .padding()
                        
                        // Loading indicator
                        if service.isLoading {
                            ProgressView("Loading...")
                        }
                        
                        // Error message
                        if let error = service.errorMessage {
                            Text("\(error)")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        
                        // Search Results
                        if !service.searchResults.isEmpty {
                            Text("Search Results:")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(service.searchResults) { city in
                                        NavigationLink(value: city) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(city.name)")
                                                    .font(.headline)
                                                Text("\(city.displayName)")
                                                    .font(.subheadline)
                                                Text("\(city.latitude), \(city.longitude)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else if !searchText.isEmpty && !service.isLoading {
                            Spacer()
                            Text("No results found")
                                .foregroundColor(.gray)
                            Spacer()
                        } else {
                            Spacer()
                        }
                    }
                    .navigationTitle("Search Cities")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: City.self) { city in
                        CityDetailView(city: city, service: service)
                    }
                    .onAppear {
                        isSearchFieldFocused = true
                    }
                }
                .presentationDetents([.large])
            }//: Search Sheet
        }//:Nav Stack
    }//:Body View
}//:Struct View

#Preview {
    
    ContentView()
        .environmentObject(FavoritesStore())
}
