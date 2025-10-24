//
//  ImagePicker.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI
import PhotosUI

// MARK: - Image Picker
// UIViewControllerRepresentable bridges UIKit's PHPickerViewController to SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // Required by UIViewControllerRepresentable - creates the UIKit view controller
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Configure picker behavior - only show images, allow single selection
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        // Create picker with configuration and set delegate for callbacks
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    // Called when SwiftUI wants to update the UIKit view - we don't need updates here
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    // Creates the coordinator that handles communication between UIKit and SwiftUI
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator Class
    // Coordinator is the bridge between UIKit delegate callbacks and SwiftUI state
    // NSObject required for UIKit delegate protocols, PHPickerViewControllerDelegate handles picker events
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // Delegate method called when user finishes selecting photos
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // Get the first selected item (we only allow single selection)
            guard let provider = results.first?.itemProvider else { return }
            
            // Check if the selected item can be loaded as UIImage
            if provider.canLoadObject(ofClass: UIImage.self) {
                // Load image asynchronously - this is important for large images
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    // UI updates must happen on main thread - critical for SwiftUI
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        // Auto-dismiss the picker after image is selected
                        self.parent.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ImagePicker(selectedImage: .constant(nil))
}
