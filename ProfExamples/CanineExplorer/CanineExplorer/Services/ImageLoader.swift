// Inside SwiftUI views (@StateObject, @ObservedObject)
import SwiftUI
/*
 Combine is Apple’s framework for handling asynchronous events — things that happen over time, like:
     •    downloading data from the internet,
     •    waiting for text input to change,
     •    reacting to timers or notifications,
     •    or updating a view whenever some value changes.

 Think of it as a “conveyor belt” of values that your code can subscribe to and react to whenever something new comes along.
 
 With Combine, you subscribe to a stream (a “publisher”) that sends values over time, and you attach operators that transform or filter them — all in one declarative chain:
 */
import Combine

// final -> Class cannot be subclassed (clear intent)
// ObservableObject -> Lets SwiftUI re-render any view that observes this loader when image changes
final class ImageLoader: ObservableObject {
    // @Published -> Whenever the loader assigns to image, SwiftUI automatically updates the UI (e.g., an Image(uiImage:) view)
    @Published var image: UIImage?
    // Holds the subscription to the Combine publisher (the network request)
    private var cancellable: AnyCancellable?
    // Avoids re-downloading the same image multiple times
    private static let cache = NSCache<NSURL, UIImage>()

    func load(from url: URL?) {
        guard let url else { image = nil; return }
        self.image = nil
        //  If the image is already in memory, use it immediately — no network request
        if let cached = Self.cache.object(forKey: url as NSURL) {
            image = cached
            return
        }
        // Fetch from network
        // This creates a publisher that starts a network request to download data from the URL.
        // Think of it like: “When I get data from the internet, I’ll send it down the pipeline.”
        cancellable?.cancel()
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            // The .map operator transforms what comes from before. The $0 here is the (data, response) tuple. We only care about the .data part and turn it into a UIImage. “Turn the downloaded bytes into a picture.”
            .map { UIImage(data: $0.data) }
            // If the network request fails (e.g. bad URL, no internet), this replaces any error with the value nil instead of crashing. “If anything goes wrong, just send me nil.”
            .replaceError(with: nil)
            // Combine runs network work on background threads by default, but SwiftUI updates must happen on the main thread. “From now on, send results back on the main thread.”
            .delay(for: .seconds(0.6), scheduler: DispatchQueue.main) // <- demo delay
            .receive(on: DispatchQueue.main)
            // sink is where you subscribe to the publisher — it’s the endpoint of the chain. The closure runs when an image (or nil) is received. If we got a real image, save it in the static cache for reuse; then assign it to self.image so SwiftUI can update the UI. sink returns an AnyCancellable object — basically a token representing this subscription. If we later call cancellable?.cancel(), the download stops.
            .sink { [weak self] img in
                if let img { Self.cache.setObject(img, forKey: url as NSURL) }
                self?.image = img
            }
    }

    func cancel() { cancellable?.cancel() }
}
