// Combine — needed for @Published and ObservableObject (so SwiftUI can react when data changes).
import Combine
// Foundation — gives us URL, UserDefaults, JSONEncoder, etc.
import Foundation

// @MainActor means: all of this runs on the main thread (UI-safe).
// final means: this class can’t be subclassed.
// ObservableObject — lets SwiftUI observe it and automatically refresh any views that depend on it.
@MainActor
final class FavoritesStore: ObservableObject {
    // @Published tells SwiftUI: “Whenever this array changes, update the UI.”
    // private(set) means: Code inside the class can modify urls. Code outside can only read it. It starts empty.
    // key: This is just the UserDefaults key under which the list will be saved.
    @Published private(set) var urls: [URL] = []
    private let key = "favoriteImageURLs"

    // When the app starts: It checks if UserDefaults already has saved data for that key. If yes: It decodes it from JSON back into [String] (array of URL strings). Then converts those strings into real URL objects with URL.init(string:). Saves that array into self.urls. In short, this restores the favorites from last time the app ran.
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let strings = try? JSONDecoder().decode([String].self, from: data) {
            self.urls = strings.compactMap(URL.init(string:))
        }
    }

    func toggle(_ url: URL?) {
        guard let url else { return }
        if let idx = urls.firstIndex(of: url) {
            urls.remove(at: idx)
        } else {
            urls.append(url)
        }
        persist()
    }

    func contains(_ url: URL?) -> Bool {
        guard let url else { return false }
        return urls.contains(url)
    }

    private func persist() {
        let strings = urls.map { $0.absoluteString }
        if let data = try? JSONEncoder().encode(strings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
