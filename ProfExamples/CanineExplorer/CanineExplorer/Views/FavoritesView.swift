import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favorites: FavoritesStore

    let columns = [GridItem(.adaptive(minimum: 120), spacing: 12)]

    var body: some View {
        NavigationStack {
            if favorites.urls.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No favorites yet").font(.headline)
                    Text("Save images from Explore or Quiz.").foregroundStyle(.secondary)
                }
                .padding()
                .navigationTitle("Favorites")
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(favorites.urls, id: \.self) { url in
                            ZStack(alignment: .topTrailing) {
                                AsyncImageView(url: url)
                                    .frame(height: 140)
                                Button {
                                    favorites.toggle(url)
                                } label: {
                                    Image(systemName: "heart.fill")
                                        .padding(6)
                                        .background(.thinMaterial, in: Circle())
                                }
                                .padding(6)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Favorites")
            }
        }
    }
}

#Preview {
    FavoritesView().environmentObject(FavoritesStore())
}
