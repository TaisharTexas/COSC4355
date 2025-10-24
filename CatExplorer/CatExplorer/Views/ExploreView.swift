//
//  ExploreView.swift
//  CatExplorer
//
//  Created by Andrew Lee on 10/23/25.
//

import SwiftUI

struct ExploreView: View{
    
    @StateObject var service = CatAPIService()
    @State private var search: String = ""
    @State private var currentLabel: String? = nil
//    let searchMatchResult: BreedRecord
    
    var suggestions: [BreedRecord] {
        // Takes the current search text (search), removes spaces/newlines, and converts it to lowercase for case-insensitive matching.
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // If the user hasn’t typed anything (the query is empty), just return an empty list — no suggestions to show.
        guard !q.isEmpty else { return [] }
        //Filters all available breeds (service.allBreeds) to find those whose names start with the query text.
        let prefix = service.allBreeds.filter { $0.name.lowercased().hasPrefix(q) }
        // Finds breeds that contain the query anywhere else (not at the start). That second condition (!hasPrefix) avoids duplicates between the two lists.
        let contains = service.allBreeds.filter { $0.name.lowercased().contains(q) && !$0.name.lowercased().hasPrefix(q) }
        // Combines both lists — prefix results first (because they’re better matches) — then takes only the first 5 total suggestions for neatness.
        return Array((prefix + contains).prefix(5))
    }
    
    var bestMatch: BreedRecord? { suggestions.first }
        
    var body: some View{
        NavigationStack{
            VStack(spacing: 12) {
                HStack(alignment: .center) {
                    TextField("Type a breed", text: $search)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit{
                            Task {
                                await fetchForBestMatch()
                            }
                        }

                }
                
                if !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions) { s in
                                Button {
                                    // Autocomplete and fetch immediately
                                    search = s.name
                                    currentLabel = s.name
//                                    Task { await service.fetchRandom(breed: s.breed, sub: s.subBreed) }
                                } label: {
                                    Text(s.name.capitalized)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(.secondarySystemBackground), in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                if let msg = service.errorMessage {
                    Text(msg).foregroundStyle(.red)
                }

            }
            
        }
        
        
        
    }
    
    @MainActor
    private func fetchForBestMatch() async {
        if let match = bestMatch {
            currentLabel = match.name
//            await service.fetchRandom(breed: match.breed, sub: match.subBreed)
        } else {
            service.errorMessage = search.isEmpty ? "Type a breed name to search." : "No breed matched “\(search)”. Try a different term."
        }
    }
    
    
//    private func doesBreedExist(searchedBreed: String)->BreedRecord {
//        let breeds = service.allBreeds
//        
//        for eachBreed in breeds{
//            if searchedBreed.lowercased() == eachBreed.name.lowercased(){
//                print("found match for \(searchedBreed) + \(eachBreed.name)")
//                return eachBreed
//            }
//        }
//
//        return nil
//    }
}
//
//#Preview {
//    ExploreView()
//}
