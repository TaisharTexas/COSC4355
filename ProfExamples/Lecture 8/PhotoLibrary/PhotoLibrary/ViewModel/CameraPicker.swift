//
//  CameraPicker.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI
import UIKit

// MARK: - Camera Picker
// UIImagePickerController configured for camera access (not photo library)
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // Required by UIViewControllerRepresentable - creates the UIKit view controller
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Set source type to camera (not photo library)
        picker.sourceType = .camera
        // Set delegate to handle camera interactions
        picker.delegate = context.coordinator
        return picker
    }
    
    // Called when SwiftUI wants to update the UIKit view - we don't need updates here
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // Creates the coordinator that handles communication between UIKit and SwiftUI
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator Class
    // Coordinator is the bridge between UIKit delegate callbacks and SwiftUI state
    // NSObject required for UIKit delegate protocols, UIImagePickerControllerDelegate handles camera events
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        // Delegate method called when user takes a photo or selects from camera roll
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Extract the captured image from the info dictionary
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                // Auto-dismiss the camera after photo is taken
                parent.dismiss()
            }
        }
        
        // Delegate method called when user cancels without taking a photo
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CameraPicker(selectedImage: .constant(nil))
}
