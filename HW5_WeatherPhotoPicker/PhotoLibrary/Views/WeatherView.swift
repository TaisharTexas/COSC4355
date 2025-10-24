//
//  WeatherView.swift
//  HW5_WeatherPhotoPicker
//
//  Created by Andrew Lee on 10/18/25.
//

import SwiftUI

struct WeatherView: View {
    @Environment(WeatherImageStore.self) private var photoStore
    @StateObject private var service = WeatherAPIService()
    @State private var showingImagePicker = false
    @State private var showingWeatherPicSetup = false
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var isSearching = false
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View{
        /**
         If all four weather types dont have assigned images{
            show image assign-er/selector
         }
         else{
            show weather search page
         }
         */
        NavigationStack{
            //check which version of the page to show
            if(!photoStore.allImagesSet){
                //MARK: -- NEED TO ADD WEATHER PICS DISPLAY
                //missing photo categories
                let missingPics = photoStore.missingCategories
                VStack{
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                    Text("Default Images Not Set")
                        .font(.title.bold())
                        .padding(.bottom, 20)
                    //tells which categories missing
                    HStack{
                        Text("~ Missing")
                            .font(.caption)
                            .foregroundColor(.gray)
                        ForEach(missingPics, id: \.self) { eachPic in
                            Text(eachPic.rawValue)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Text("~")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }//: end Hstack
                    Text("You need to set images for all weather types before you can search for weather")
                        .padding(.vertical, 20)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing], 25)
                        .multilineTextAlignment(.center)
                    Button(action:{
                        showingWeatherPicSetup = true
                    }){
                        Text("Set Images")
                    }
                    .buttonStyle(.glassProminent)
                    
                    
                }//: end Vstack
                
            } else{
                //MARK: -- SEARCH CITY WEATHER DISPLAY
                //has all 4 weather pics
                VStack{
                    
                    // Search Field (cmd+v'd straight from hw4 lol)
                    HStack {
                        HStack{
                            ZStack(alignment: .leading) {
                                if searchText.isEmpty {
                                    Text("Enter city name")
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 4)
                                }
                                TextField("", text: $searchText)
                                    .autocapitalization(.none)
                                    .focused($isSearchFieldFocused)
                                    .onSubmit {
                                        Task {
                                            await service.searchCities(query: searchText)
                                        }
                                    }
                            }
                            .overlay(
                                HStack {
                                    Spacer()
                                    if !searchText.isEmpty {
                                        Button(action: {
                                            searchText = ""
                                            service.searchResults = []
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .padding(.trailing, 8)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            )
                        }//: Inner Hstack
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        
                        //                    // X button to close entire search sheet
                        //                    Button(action: {
                        //                        searchText = ""
                        //                        service.searchResults = []
                        //                        isSearchFieldFocused = false
                        //                        isSearching = false
                        //                    }) {
                        //                        Image(systemName: "xmark.circle")
                        //                    }
                    }//: Outer Hstack (search block)
                    .padding()
                    
                    // Loading indicator
                    if service.isLoading {
                        ProgressView("Loading...")
                            .padding()
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
                        //MARK: active search, show results
                        Text("Search Results:")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(service.searchResults) { city in
                                    NavigationLink(value: city) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(city.name)")
                                            Text("\(city.displayName)")
                                            Text("\(city.latitude), \(city.longitude)")
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
                        //MARK: active search but waiting on results
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No results found")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    } else {
                        //MARK: no search active - placeholder screen (also default screen)
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("Search a City to see the Weather!")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }//: end VStack
                .navigationDestination(for: City.self) { city in
                    CityDetailView(city: city, service: service)
                }
                
            }//: end ELSE
            
        }//: end NavStack
        .navigationTitle("Weather")
        .sheet(isPresented: $showingWeatherPicSetup) {
            WeatherImageSetupSheet(isPresented: $showingWeatherPicSetup)
        }

        
    }//: end body view
}//: end WeatherView


/**
 ok this got a bit out of hand but it works so im not touching it more lol
 Basically when I use the mert's imagePicker method, when an image is picked the method calls dismiss on itself and its parent. On my page this closes both the image picker and also the sheet im using to set the 4 weather pics (which I didnt want). I didnt want to mess with mert's funtions so I made this monster of nested checks that checks if the user dismissed the weather pic picker or if something else did. If the user dismissed (with the done button or a gesture) then keep it closed, if the image picker closed it (because an image was selected) then reopen it....I probably shouldve just made another method in ImagePicker but oh well im trying to do this fast cause I have a 3 exams next week im needa prepare for so im turning this in sunday
 */
struct WeatherImageSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(WeatherImageStore.self) private var imageStore
    @Binding var isPresented: Bool
    @State private var userDismissed = false
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Tap each card to select an image")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    // Cards for each weather category
                    LazyVGrid(columns: layout, spacing: 16) {
                        ForEach(WeatherCategory.allCases, id: \.self) { category in
                            WeatherImageCard(category: category)
                        }
                    }
                    .padding(.horizontal)
                }
            }//: end ScrollView
            .navigationTitle("Set Weather Images")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        userDismissed = true
                        dismiss()
                    }
                }
            }//: end Toolbar
            .onChange(of: isPresented) { oldValue, newValue in
                // When sheet is being dismissed (isPresented changes from true to false)
                if oldValue && !newValue {
                    // If user swiped down, userDismissed will still be false
                    // Mark it as user dismissed since swipe is a valid dismissal
                    if !userDismissed {
                        userDismissed = true
                    }
                }
                // When sheet is presented, reset userDismissed
                if newValue {
                    userDismissed = false
                }
            }//: end onChange
            //Want to reopen if the user didnt dismiss it UNLESS it was the 4th pic which then its fine to leave closed
            .onDisappear {
                // When sheet disappears, check if user explicitly dismissed it (also check if all 4 pic are set)
                if !userDismissed && !imageStore.allImagesSet{
                    // User didn't dismiss it and theres still missing pics - reopen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPresented = true
                    }
                }
            }//: end onDisappear
        }//: end NavStack
    }//: end body view
}//: end Struct

struct WeatherImageCard: View {
    @Environment(WeatherImageStore.self) private var imageStore
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    let category: WeatherCategory
    
    var body: some View {
        Button(action: {
            showingImagePicker = true
        }) {
            VStack(spacing: 8) {
                // Image or placeholder
                ZStack {
                    if let image = imageStore.getImage(for: category) {
                        // Show selected image
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 175, height: 150)
                            .clipped()
                    } else {
                        // Show placeholder
                        ZStack {
                            Color.gray.opacity(0.2)
                            VStack(spacing: 8) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 175, height: 150)
                    }
                }//: end ZStack
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Category label
                HStack {
                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if imageStore.hasImage(for: category) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }//: end HStack
            }//: end Vstack
        }//: end button
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(imageStore.hasImage(for: category) ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                imageStore.setImage(image, for: category)
                selectedImage = nil
            }
        }//: end onChange
    }//: end body view
}//: end Struct


#Preview {
    WeatherView()
        .environment(WeatherImageStore())
}
