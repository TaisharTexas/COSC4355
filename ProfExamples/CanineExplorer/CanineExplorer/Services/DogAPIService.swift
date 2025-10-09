import Combine
import Foundation

// lets you use it in ForEach/lists and store in sets/dicts.
struct BreedRecord: Identifiable, Hashable {
    var id: String { key }// derived from key (stable unique string)
    let key: String       // e.g., "hound-basset" or "retriever"
    let breed: String     // top-level breed (e.g. "hound")
    let subBreed: String? // optional sub-breed (e.g. "basset")
    let label: String     // "hound / basset" or "retriever"
}

// guarantees everything inside runs on the main thread by default—safe for updating @Published properties that SwiftUI observes.
@MainActor
// ObservableObject + @Published: when properties change, SwiftUI views that observe this service automatically re-render
final class DogAPIService: ObservableObject {
    @Published var allBreeds: [BreedRecord] = []
    @Published var lastImageURL: URL?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // Custom URLSession with a 20s request timeout (UX safeguard). It is encapsulated so all network calls share the same config.
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }()

    // Uses Swift concurrency (async/await) for a clean, non-blocking fetch
    func loadBreeds() async {
        do {
            errorMessage = nil
            let url = URL(string: "https://dog.ceo/api/breeds/list/all")!
            let (data, _) = try await session.data(from: url)
            // Decodes JSON into DogListResponse
            let decoded = try JSONDecoder().decode(DogListResponse.self, from: data)
            // Validates the Dog API’s custom status == "success" (in addition to HTTP status)
            guard decoded.status == "success" else { throw URLError(.badServerResponse) }
            // Transforms the raw dictionary into friendly BreedRecords via toBreedRecords, then sorts them for the UI
            self.allBreeds = toBreedRecords(from: decoded.message).sorted { $0.label < $1.label }
        } catch {
            // On failure, sets a human-readable errorMessage that views can display
            self.errorMessage = "Failed to load breeds: \(error.localizedDescription)"
        }
    }

    // Random image for a selected breed (and optional sub-breed)
    func fetchRandomAny() async {
        await fetchImage(url: URL(string: "https://dog.ceo/api/breeds/image/random")!)
    }

    // Random image for a selected breed (and optional sub-breed)
    func fetchRandom(breed: String, sub: String?) async {
        var path = "https://dog.ceo/api/breed/\(breed)"
        if let sub, !sub.isEmpty { path += "/\(sub)" }
        path += "/images/random"
        guard let url = URL(string: path) else { return }
        await fetchImage(url: url)
    }

    // Shared image fetcher
    private func fetchImage(url: URL) async {
        // isLoading flips on entry and is guaranteed to flip off with defer, even if an error occurs
        isLoading = true
        defer { isLoading = false }
        
        do {
            errorMessage = nil
            let (data, _) = try await session.data(from: url)
            // Decodes DogImageResponse and extracts the image URL string
            let decoded = try JSONDecoder().decode(DogImageResponse.self, from: data)
            guard decoded.status == "success", let u = URL(string: decoded.message) else {
                throw URLError(.badServerResponse)
            }
            // On success, publishes lastImageURL which your view can bind to
            self.lastImageURL = u
        } catch {
            self.errorMessage = "Failed to fetch image: \(error.localizedDescription)"
            self.lastImageURL = nil
        }
    }
}

// Transforming the breed dictionary into records
private func toBreedRecords(from dict: [String: [String]]) -> [BreedRecord] {
    var out: [BreedRecord] = []
    for (breed, subs) in dict {
        if subs.isEmpty {
            out.append(BreedRecord(key: breed, breed: breed, subBreed: nil, label: breed))
        } else {
            for s in subs {
                out.append(BreedRecord(key: "\(breed)-\(s)", breed: breed, subBreed: s, label: "\(breed) / \(s)"))
            }
        }
    }
    return out
}

// Mirror the JSON envelopes the Dog API uses: { status, message }
struct DogListResponse: Decodable {
    let message: [String: [String]]
    let status: String
}

struct DogImageResponse: Decodable {
    let message: String
    let status: String
}
