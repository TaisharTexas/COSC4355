import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var service: DogAPIService
    @EnvironmentObject var favorites: FavoritesStore

    @State private var search: String = ""
    @State private var currentLabel: String? = nil   // label under the photo

    // MARK: - Suggestions (prefix first, then contains)
    // Produces up to 5 suggestions, prioritizing prefix matches over contains.
    // It declares a computed property named suggestions that returns an array of BreedRecord objects. It’s “computed” — not stored — meaning it recalculates every time it’s accessed.
    var suggestions: [BreedRecord] {
        // Takes the current search text (search), removes spaces/newlines, and converts it to lowercase for case-insensitive matching.
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        // If the user hasn’t typed anything (the query is empty), just return an empty list — no suggestions to show.
        guard !q.isEmpty else { return [] }
        //Filters all available breeds (service.allBreeds) to find those whose names start with the query text.
        let prefix = service.allBreeds.filter { $0.label.lowercased().hasPrefix(q) }
        // Finds breeds that contain the query anywhere else (not at the start). That second condition (!hasPrefix) avoids duplicates between the two lists.
        let contains = service.allBreeds.filter { $0.label.lowercased().contains(q) && !$0.label.lowercased().hasPrefix(q) }
        // Combines both lists — prefix results first (because they’re better matches) — then takes only the first 5 total suggestions for neatness.
        return Array((prefix + contains).prefix(5))
    }

    // bestMatch is simply the first suggestion (used when pressing Return).
    var bestMatch: BreedRecord? { suggestions.first }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Search + Random (no Show button)
                HStack(alignment: .center) {
                    // TextField Return triggers fetchForBestMatch() (async).
                    // Displays a text input field with placeholder text
                    // The text: parameter takes a binding — $search — which connects the field to the @State var search variable.
                    TextField("Type a breed (e.g., Golden Retriever, Hound Basset)", text: $search)
                    //This applies a visual style — the standard iOS text field with rounded corners and a border.
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    //This attaches an action that runs when the user hits Return on the keyboard.
                        .onSubmit { Task { await fetchForBestMatch() } }

                    Button("Random") {
                        Task {
                            // Clear search per request, fetch random, then infer label
                            search = ""
                            await service.fetchRandomAny()
                            currentLabel = inferBreedLabel(from: service.lastImageURL) ?? "Random dog"
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Suggestions as tappable chips
                // Suggestion chips act as autocomplete + immediate fetch for that breed.
                if !suggestions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions) { s in
                                Button {
                                    // Autocomplete and fetch immediately
                                    search = s.label
                                    currentLabel = s.label
                                    Task { await service.fetchRandom(breed: s.breed, sub: s.subBreed) }
                                } label: {
                                    Text(s.label.capitalized)
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

                // Image + centered label
                VStack(spacing: 6) {
                    AsyncImageView(url: service.lastImageURL)
                        .frame(maxWidth: .infinity, maxHeight: 420)

                    if let label = currentLabel {
                        Text(label.capitalized)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 2)

                HStack {
                    // Favorites toggles the current image (heart button reflects state).
                    Button {
                        favorites.toggle(service.lastImageURL)
                    } label: {
                        Label(favorites.contains(service.lastImageURL) ? "Unfavorite" : "Save Favorite",
                              systemImage: favorites.contains(service.lastImageURL) ? "heart.fill" : "heart")
                    }.buttonStyle(.bordered)

                    // Copy URL puts the image URL on the pasteboard (needs import UIKit in SwiftUI app targets that access UIPasteboard).
                    Button {
                        if let url = service.lastImageURL {
                            UIPasteboard.general.string = url.absoluteString
                        }
                    } label: {
                        Label("Copy URL", systemImage: "doc.on.doc")
                    }.buttonStyle(.bordered)
                }

                Text("Data source: Dog CEO (public JSON).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Canine Explorer")
            .task {
                if service.allBreeds.isEmpty {
                    await service.loadBreeds()
                    // Initial pleasant random
                    await service.fetchRandomAny()
                    currentLabel = inferBreedLabel(from: service.lastImageURL) ?? "Random dog"
                }
            }
        }
    }

    // MARK: - Actions

    // This annotation ensures the entire function runs on the main thread, which is required for:
    //      * Updating UI-related properties (currentLabel)
    //      * Avoiding concurrency issues (SwiftUI must always update         its state on the main actor)
    //  So, this guarantees that all state changes here are UI-safe.
    @MainActor
    private func fetchForBestMatch() async {
        if let match = bestMatch {
            currentLabel = match.label
            await service.fetchRandom(breed: match.breed, sub: match.subBreed)
        } else {
            service.errorMessage = search.isEmpty ? "Type a breed name to search." : "No breed matched “\(search)”. Try a different term."
        }
    }

    // MARK: - Breed inference from Dog CEO image URL
    // Dog CEO encodes breed/sub-breed in the path. This function extracts it and formats a readable label; e.g., hound-basset → Hound / Basset
    private func inferBreedLabel(from url: URL?) -> String? {
        guard let url else { return nil }
        // Example: https://images.dog.ceo/breeds/hound-basset/n02088238_11136.jpg
        let comps = url.pathComponents
        if let breedsIndex = comps.firstIndex(of: "breeds"), comps.count > breedsIndex + 1 {
            let breedComponent = comps[breedsIndex + 1] // e.g., "hound-basset" or "retriever-golden"
            let parts = breedComponent.split(separator: "-").map(String.init)
            if parts.count == 1 {
                return parts[0].replacingOccurrences(of: "/", with: " ").capitalized
            } else if parts.count >= 2 {
                let breed = parts[0]
                let sub = parts[1]
                return "\(breed) / \(sub)".capitalized
            }
        }
        return nil
    }
}
