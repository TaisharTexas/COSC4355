//
//  ImagePicker.swift
//  XrayClassifier
//
//  Created by Ioannis Pavlidis on 11/12/25.
//

import SwiftUI
import PhotosUI

// UIViewControllerRepresentable = protocol that lets you wrap a UIKit view controller (here: PHPickerViewController) so it can be used inside SwiftUI.
//  @Environment(\.dismiss) gives you a function you can call to dismiss the current sheet / view.
//  @Binding var image: UIImage?: This is a two-way connection to a @State in the parent SwiftUI view (ContentView). When this picker sets image, ContentView immediately sees the new selectedUIImage.
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    // This is called once to create the underlying UIKit controller:
    // PHPickerConfiguration(photoLibrary: .shared()) Uses the shared photo library.
    // configuration.filter = .images. Only images (no videos, etc.).
    // configuration.selectionLimit = 1. User can pick only one image.
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // no update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // This coordinator acts as the delegate for PHPickerViewController.
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        // This is called when the user finishes picking (either selects something or cancels).
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else {
                parent.dismiss()
                return
            }
            // Check if this item can be loaded as a UIImage. Dismiss yourself when done.
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    DispatchQueue.main.async {
                        if let uiImage = object as? UIImage {
                            self.parent.image = uiImage
                        }
                        self.parent.dismiss()
                    }
                }
            } else {
                parent.dismiss()
            }
        }
    }
}


// What SwiftUI does instead: State → View

// SwiftUI is declarative and reactive: “Here is what the UI should look like for this state.

// When state changes, re-render.”

// So instead of “tell me via delegate when something happens,” SwiftUI prefers:
    // • Bindings (@Binding)
    // • State (@State)
    // • Observed objects (@ObservedObject, @StateObject)
    // • Closures (e.g. .onTapGesture {}, button actions)

// The flow is:
    // 1. User taps / changes something.
    // 2. You update some piece of state.
    // 3. SwiftUI recomputes the body based on that state.

// No manual delegate dancing; the view is just a function of state.
