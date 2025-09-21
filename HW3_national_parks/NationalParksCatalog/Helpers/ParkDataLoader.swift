//
//  ParkDataLoader.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/21/25.
//

import Foundation

struct CatalogItemRaw: Decodable {
    let id: Int
    let name: String
    let subtitle: String
    let details: String
    let imageName: String
    let isFavorite: Bool
}

func loadParksFromJSON(from fileName: String) -> [CatalogItem] {
    print("PARK LOADER: Looking for file: \(fileName)")
    
    // Debug: List all files in the bundle
//    if let bundlePath = Bundle.main.resourcePath {
//        print("PARK LOADER: Bundle path: \(bundlePath)")
//
//        do {
//            let allFiles = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
//            print("PARK LOADER: All files in bundle root: \(allFiles)")
//
//            // Look for any JSON files
//            let jsonFiles = allFiles.filter { $0.contains("json") }
//            print("PARK LOADER: JSON files found: \(jsonFiles)")
//
//            // Check if there's a Files subdirectory
//            let filesDir = bundlePath + "/Files"
//            if FileManager.default.fileExists(atPath: filesDir) {
//                let filesInSubdir = try FileManager.default.contentsOfDirectory(atPath: filesDir)
//                print("PARK LOADER: Files in 'Files' directory: \(filesInSubdir)")
//            } else {
//                print("PARK LOADER: No 'Files' directory found in bundle")
//            }
//        } catch {
//            print("PARK LOADER: Error reading bundle contents: \(error)")
//        }
//    }
    
    
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("PARK LOADER: File: \(fileName) not found")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let dtos = try decoder.decode([CatalogItemRaw].self, from: data)
        
        return dtos.map { dto in
            CatalogItem(
                id: dto.id,
                name: dto.name,
                subtitle: dto.subtitle,
                details: dto.details,
                imageName: dto.imageName,
                isFavorite: dto.isFavorite
            )
        }
    } catch {
        print("PARK LOADER: Failed to decode JSON: \(error)")
        return []
    }
}
