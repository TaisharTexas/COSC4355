//
//  PhotoDetailView.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    let photo: Photo
    @Environment(PhotoStore.self) private var photoStore
    @Environment(\.dismiss) private var dismiss
    @State private var description: String = ""
    @State private var isEditingDescription = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Description")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(isEditingDescription ? "Done" : "Edit") {
                            if isEditingDescription {
                                photoStore.updateDescription(for: photo, newDescription: description)
                            }
                            isEditingDescription.toggle()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    // Conditional UI based on editing state
                    if isEditingDescription {
                        TextField("Add a description...", text: $description, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    } else {
                        Text(photo.description.isEmpty ? "No description added" : photo.description)
                            .foregroundColor(photo.description.isEmpty ? .gray : .primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Date Added")
                        .font(.headline)
                    
                    Text(photo.dateAdded, style: .date)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Photo Details")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                    
                    Button(action: {
                        photoStore.toggleFavorite(for: photo)
                    }) {
                        Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(photo.isFavorite ? .red : .primary)
                            .font(.title2)
                    }
                }
            }
        }
        .confirmationDialog("Delete Photo", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                photoStore.deletePhoto(photo)
                dismiss() // Navigate back after deletion
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this photo? This action cannot be undone.")
        }
        
        .onAppear {
            description = photo.description
        }
    }
}

#Preview {
    NavigationStack {
        PhotoDetailView(photo: Photo(imageData: Data()))
            .environment(PhotoStore())
    }
}
