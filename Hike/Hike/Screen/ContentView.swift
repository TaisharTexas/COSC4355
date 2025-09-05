
import SwiftUI

struct HikePage: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageName: String
    let bgTop: Color
    let bgBottom: Color
    let prefersLightText: Bool
}

let hikePages: [HikePage] = [
    HikePage(
        title: "John hikes in the Rockies.",
        imageName: "rockies",
        bgTop: Color(red: 0.83, green: 0.92, blue: 0.98),
        bgBottom: Color(red: 0.74, green: 0.86, blue: 0.78),
        prefersLightText: false
    ),
    HikePage(
        title: "Jane hikes in Arizona.",
        imageName: "arizona",
        bgTop: Color(red: 0.99, green: 0.93, blue: 0.82),
        bgBottom: Color(red: 0.96, green: 0.82, blue: 0.64),
        prefersLightText: false
    ),
    HikePage(
        title: "John and Jane by the campfire in the Sonora desert.",
        imageName: "campfire",
        bgTop: Color(red: 0.10, green: 0.14, blue: 0.22),
        bgBottom: Color(red: 0.18, green: 0.20, blue: 0.24),
        prefersLightText: true
    )
]

struct ContentView: View {
    @State private var showInfo = false
    @State private var index = 0

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [hikePages[index].bgTop, hikePages[index].bgBottom], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    Text(hikePages[index].title)
                        .font(.title2).bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundStyle(hikePages[index].prefersLightText ? Color.white : Color.primary)
                        .shadow(color: hikePages[index].prefersLightText ? Color.black.opacity(0.6) : Color.clear, radius: 2, x: 0, y: 1)
                        .padding(.top, 8)
                        .background(hikePages[index].prefersLightText ? Color.black.opacity(0.15) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Image(hikePages[index].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 600)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(radius: 6)
                        .padding(.horizontal)
                        .accessibilityLabel(hikePages[index].title)

                    Button(action: {
                        withAnimation {
                            index = (index + 1) % hikePages.count
                        }
                    }) {
                        Text("Next Adventure")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    Spacer(minLength: 24)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("Hike-App")
            .navigationBarTitleDisplayMode(.inline)
            // Make the navigation bar title readable against backgrounds.
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(hikePages[index].prefersLightText ? .dark : .light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Hiking Benefits")
                }
            }
            .sheet(isPresented: $showInfo) {
                InfoView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: - Info Sheet with App Icon choices
struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Capsule().fill(.secondary.opacity(0.4))
                    .frame(width: 48, height: 6)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                Text("Why Hiking Is Great")
                    .font(.title2).bold()

                Text("Hiking is a simple way to improve cardiovascular health, strengthen muscles and bones, and boost balance. Time on the trail reduces stress hormones and can lift mood and focus—especially in natural settings. It’s also a social, low-cost activity that builds confidence as you tackle new terrain and distances. Start with comfortable shoes, water, and sun protection, and enjoy the benefits at your own pace.")
                    .font(.body)
                    .foregroundStyle(.primary)

                Divider().padding(.vertical, 8)

                Text("Choose App Icon")
                    .font(.headline)

                IconPickerRow()
                    .padding(.bottom, 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 4)
            )
            .padding(.horizontal)
            .padding(.bottom, 24)
            .background(
                LinearGradient(
                    colors: [Color(.secondarySystemBackground), Color(.systemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

struct IconPickerRow: View {
    @State private var currentIcon: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            IconButton(title: "Rockies", iconName: "IconRockies", previewImage: "rockies", currentIcon: $currentIcon)
            IconButton(title: "Arizona", iconName: "IconArizona", previewImage: "arizona", currentIcon: $currentIcon)
            IconButton(title: "Campfire", iconName: "IconCampfire", previewImage: "campfire", currentIcon: $currentIcon)
        }
        .onAppear {
            currentIcon = UIApplication.shared.alternateIconName
        }
    }
}

struct IconButton: View {
    let title: String
    let iconName: String
    let previewImage: String
    @Binding var currentIcon: String?

    var body: some View {
        VStack(spacing: 8) {
            Image(previewImage)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14).stroke(currentIcon == iconName ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 3)
                )
            Button(action: {
                setAppIcon(name: iconName)
            }) {
                Text(title)
                    .font(.footnote).bold()
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }

    private func setAppIcon(name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error = error {
                print("Icon error:", error.localizedDescription)
            } else {
                currentIcon = name
            }
        }
    }
}