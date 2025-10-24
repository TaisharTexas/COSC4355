//
//  HomeView.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @Environment(PhotoStore.self) private var photoStore
    @State private var showingImagePicker = false
    @State private var showingCameraPicker = false
    @State private var showingImagePreview = false
    @State private var selectedImage: UIImage?
    @State private var showingSourceSelection = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if photoStore.photos.isEmpty {
                    // Empty state UI - centered in the middle of the screen
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Photos Yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Tap the + button to add your first photo")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 150) // Add top padding to center vertically
                } else {
                    // LazyVGrid only loads visible items for performance
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(photoStore.photos) { photo in
                            NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                PhotoGridItemView(photo: photo)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Photos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSourceSelection = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .confirmationDialog("Add Photo", isPresented: $showingSourceSelection, titleVisibility: .visible) {
                Button("Camera") { showingCameraPicker = true }
                Button("Photo Library") { showingImagePicker = true }
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .navigationDestination(isPresented: $showingCameraPicker) {
                CameraPicker(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { _, newImage in
                if newImage != nil {
                    showingImagePreview = true
                }
            }
            .sheet(isPresented: $showingImagePreview) {
                if let image = selectedImage {
                    NavigationStack {
                        ImagePreviewView(image: image, isPresented: $showingImagePreview)
                    }
                }
            }
        }
    }
}

// MARK: - Photo Grid Item View
struct PhotoGridItemView: View {
    let photo: Photo
    @Environment(PhotoStore.self) private var photoStore
    
    var body: some View {
        // GeometryReader needed to make images square regardless of original aspect ratio
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                if let image = photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .cornerRadius(8)
                }
                
                // Heart overlay positioned in top-right corner
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            photoStore.toggleFavorite(for: photo)
                        }) {
                            Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(photo.isFavorite ? .red : .white)
                                .font(.title2)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                        .frame(width: 30, height: 30)
                                )
                        }
                        .padding(8)
                    }
                    Spacer()
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    HomeView()
        .environment(PhotoStore())
}
