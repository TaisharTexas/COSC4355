//
//  CatAPIService.swift
//  CatExplorer
//
//  Created by Andrew Lee on 10/23/25.
//

import Combine
import Foundation

struct BreedRecord: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
//    let imageURL: String?
}

struct myStruct: Identifiable, Codable, Hashable{
    let id: String
    let name: String
    let description: String
}

@MainActor
final class CatAPIService: ObservableObject{
    @Published var allBreeds: [BreedRecord] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }()

    func loadBreeds() async {
        print("load breeds")
        do {
            errorMessage = nil
            let url = URL(string: "https://api.thecatapi.com/v1/breeds")!
            let (data, _) = try await session.data(from: url)

            print("got data")
            print(data)
            
            
            let decoded = try JSONDecoder().decode([BreedRecord].self, from: data)
            print("decode finished?")
//            print(decoded)
            
            for eachThing in decoded{
//                print("\(eachThing.id) \n")
                var tempRecord = BreedRecord(id: eachThing.id, name: eachThing.name, description: eachThing.description)
                
                allBreeds.append(tempRecord)
                
            }
            print("appended everything")
            print(allBreeds.count)
            

        } catch {
            // On failure, sets a human-readable errorMessage that views can display
            self.errorMessage = "Failed to load breeds: \(error.localizedDescription)"
        }
    }
    
}



