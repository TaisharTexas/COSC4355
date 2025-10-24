//
//  PhotoModel.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI
import UIKit

// MARK: - Photo Data Model
struct Photo: Identifiable, Codable {
    let id = UUID()
    var imageData: Data
    var isFavorite: Bool = false
    var description: String = ""
    var dateAdded: Date = Date()
    
    // Computed property converts Data back to UIImage for display
    // UIImage isn't Codable, so we store as Data and convert when needed
    var image: UIImage? {
        UIImage(data: imageData)
    }
}

// MARK: - Photo Store Class
// @Observable macro (iOS 17+) automatically notifies SwiftUI of changes
@Observable
class PhotoStore {
    var photos: [Photo] = []
    
    init() {
        loadPhotos()
    }
    
    // Compress to 80% quality to balance file size and image quality
    func addPhoto(_ image: UIImage, description: String = "") {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let newPhoto = Photo(imageData: imageData, description: description)
        photos.append(newPhoto)
        savePhotos()
    }
    
    func toggleFavorite(for photo: Photo) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index].isFavorite.toggle()
            savePhotos()
        }
    }
    
    func updateDescription(for photo: Photo, newDescription: String) {
        if let index = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[index].description = newDescription
            savePhotos()
        }
    }
    
    // Remove a photo from the collection
    func deletePhoto(_ photo: Photo) {
        photos.removeAll { $0.id == photo.id }
        savePhotos()
    }
    
    // Computed property filters photos - SwiftUI will automatically update when this changes
    var favoritePhotos: [Photo] {
        photos.filter { $0.isFavorite }
    }
    
    // MARK: - Data Persistence
    private func savePhotos() {
        if let encoded = try? JSONEncoder().encode(photos) {
            UserDefaults.standard.set(encoded, forKey: "SavedPhotos")
        }
    }
    
    private func loadPhotos() {
        if let data = UserDefaults.standard.data(forKey: "SavedPhotos"),
           let decoded = try? JSONDecoder().decode([Photo].self, from: data) {
            photos = decoded
        }
    }
}
