import SwiftUI

struct ContentView: View {
    //  @StateObject: SwiftUI creates and retains this object for the life of the view. If the view reloads, the object persists (it’s not recreated each time). When the object’s data changes, SwiftUI automatically updates the parts of the UI that depend on it.
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var service = DogAPIService()

    var body: some View {
        // Defines a tab-based navigation UI (like the bottom tab bar in many iPhone apps).
        TabView {
            ExploreView()
                // environmentObject(service) and environmentObject(favorites) pass those shared objects down the view hierarchy so ExploreView (and any subviews) can use them.
                .environmentObject(service)
                .environmentObject(favorites)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
            QuizView()
                .environmentObject(service)
                .environmentObject(favorites)
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.square")
                }
            FavoritesView()
                // Only needs access to favorites, not the Dog API service.
                .environmentObject(favorites)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
    }
}

#Preview {
    ContentView()
}
