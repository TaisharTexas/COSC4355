//
//  FavoritesView.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI

// MARK: - Favorites View
struct FavoritesView: View {
    @Environment(PhotoStore.self) private var photoStore
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if photoStore.favoritePhotos.isEmpty {
                    // Empty state UI - centered in the middle of the screen
                    VStack(spacing: 20) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Favorites Yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Tap the heart icon on photos to add them to your favorites")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 150) // Add top padding to center vertically
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(photoStore.favoritePhotos) { photo in
                            NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                PhotoGridItemView(photo: photo)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    FavoritesView()
        .environment(PhotoStore())
}
