//
//  WeatherImages.swift
//  HW5_WeatherPhotoPicker
//
//  Created by Andrew Lee on 10/19/25.
//

import SwiftUI
import UIKit

enum WeatherCategory: String, CaseIterable, Codable {
    case sunny = "Sunny"
    case foggy = "Foggy"
    case rainy = "Rainy"
    case snowy = "Snowy"
    
    // Map weather codes to categories
    static func from(weatherCode: Int) -> WeatherCategory {
        switch weatherCode {
        case 51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99: return .rainy
        case 71, 73, 75, 77, 85, 86: return .snowy
        case 45, 48: return .foggy
        default: return .sunny
        }//: end switch
    }
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .foggy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        }
    }
}

/**
 Weather Image helper functions and vars -- specifically for my weather image picker screen
 */
@Observable
class WeatherImageStore {
    // Store images as Data for persistence
    private var imageData: [WeatherCategory: Data] = [:]
    
    init() {
        loadImages()
    }
    
    // MARK: - Set Image
    func setImage(_ image: UIImage, for category: WeatherCategory) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        imageData[category] = data
        saveImages()
    }
    
    // MARK: - Get Image
    func getImage(for category: WeatherCategory) -> UIImage? {
        guard let data = imageData[category] else { return nil }
        return UIImage(data: data)
    }
    
    func getImage(forWeatherCode code: Int) -> UIImage? {
        let category = WeatherCategory.from(weatherCode: code)
        return getImage(for: category)
    }
    
    // MARK: - Check if Image Exists
    func hasImage(for category: WeatherCategory) -> Bool {
        imageData[category] != nil
    }
    
    // MARK: - Check if All Images Set
    var allImagesSet: Bool {
        WeatherCategory.allCases.allSatisfy { hasImage(for: $0) }
    }
    
    var missingCategories: [WeatherCategory] {
        WeatherCategory.allCases.filter { !hasImage(for: $0) }
    }
    
    // MARK: - Remove Image
    func removeImage(for category: WeatherCategory) {
        imageData[category] = nil
        saveImages()
    }
    
    // MARK: - Reset All
    func resetAllImages() {
        imageData.removeAll()
        saveImages()
    }
    
    // MARK: - Persistence
    private func saveImages() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(imageData) {
            UserDefaults.standard.set(encoded, forKey: "WeatherImages")
        }
    }
    
    private func loadImages() {
        guard let data = UserDefaults.standard.data(forKey: "WeatherImages"),
              let decoded = try? JSONDecoder().decode([WeatherCategory: Data].self, from: data) else {
            return
        }
        imageData = decoded
    }
}

// MARK: - Extension for CityWeatherInfo
extension CityWeatherInfo {
    var weatherCategory: WeatherCategory {
        WeatherCategory.from(weatherCode: weatherCode)
    }
    
    func customImage(from store: WeatherImageStore) -> UIImage? {
        store.getImage(for: weatherCategory)
    }
}
