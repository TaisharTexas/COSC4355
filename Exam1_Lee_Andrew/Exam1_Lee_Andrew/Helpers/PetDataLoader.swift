

import Foundation

struct PetItemRaw: Decodable {
    let id: Int
    let name: String
    let species: String
    let petDescription: String
    let imageName: String
    let isFavorite: Bool
}

func loadPetsFromJSON(from fileName: String) -> [PetItem] {
    print("PET LOADER: Looking for file: \(fileName)")
    
    // Debug: List all files in the bundle
//    if let bundlePath = Bundle.main.resourcePath {
//        print("PET LOADER: Bundle path: \(bundlePath)")
//
//        do {
//            let allFiles = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
//            print("PET LOADER: All files in bundle root: \(allFiles)")
//
//            // Look for any JSON files
//            let jsonFiles = allFiles.filter { $0.contains("json") }
//            print("PET LOADER: JSON files found: \(jsonFiles)")
//
//            // Check if there's a Files subdirectory
////            let filesDir = bundlePath + "/Files"
////            if FileManager.default.fileExists(atPath: filesDir) {
////                let filesInSubdir = try FileManager.default.contentsOfDirectory(atPath: filesDir)
////                print("PET LOADER: Files in 'Files' directory: \(filesInSubdir)")
////            } else {
////                print("PET LOADER: No 'Files' directory found in bundle")
////            }
//        } catch {
//            print("PET LOADER: Error reading bundle contents: \(error)")
//        }
//    }
    
    
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("PET LOADER: File: \(fileName) not found")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let dtos = try decoder.decode([PetItemRaw].self, from: data)
        
        return dtos.map { dto in
            PetItem(
                id: dto.id,
                name: dto.name,
                species: dto.species,
                petDescription: dto.petDescription,
                imageName: dto.imageName,
                isFavorite: dto.isFavorite
            )
        }
    } catch {
        print("PET LOADER: Failed to decode JSON: \(error)")
        return []
    }
}
