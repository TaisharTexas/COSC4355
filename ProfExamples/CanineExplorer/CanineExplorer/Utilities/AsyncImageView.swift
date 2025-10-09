import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader = ImageLoader()
    let url: URL?

    var body: some View {
        Group {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity)          // nice fade-in
            } else {
                ZStack {
                    // More contrast than secondarySystemBackground
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .overlay(                            // subtle border so it “reads”
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        )

                    // Make the spinner larger and clearly visible
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)                 // bigger
                        .scaleEffect(1.2)                    // even bigger
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)                   // guarantees height
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .onAppear { loader.load(from: url) }
        .onChange(of: url) { loader.load(from: url) }
        .onDisappear { loader.cancel() }
    }
}
