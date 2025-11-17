//
//  ContentView.swift
//  XrayClassifier
//
//  Created by Ioannis Pavlidis on 11/12/25.
//

import SwiftUI

// This is the main screen of the X-ray classifier app. It lets the user pick an image, run the ML model, show the result, and then schedule a repeating notification with the last classification.
struct ContentView: View {
    @State private var selectedUIImage: UIImage?
    @State private var classificationResult: String = "No image selected"
    @State private var isShowingImagePicker = false
    @State private var isClassifying = false
    @State private var errorMessage: String?

    private let classifier = XrayClassifierService()

    // Wraps everything in a NavigationView with a vertical stack.
        // First, a ZStack with: A dashed rectangle as a placeholder frame for the image.
        // If an image is selected, it shows the X-ray inside that rectangle.
        // Otherwise, it shows helper text telling the user to select an image.

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image preview
                ZStack {
                    Rectangle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(3/4, contentMode: .fit)

                    if let uiImage = selectedUIImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    } else {
                        Text("Tap “Select Image” to choose an X-ray")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }

                // Result
                // Shows the current status/result:
                    // • “No image selected”,
                    // • “Classifying…”, or “Prediction: knee (93.2%)”, etc.
                Text(classificationResult)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Error (if any)
                // If errorMessage is not nil, it displays that text in red below.
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Buttons
                // Select Image: Sets isShowingImagePicker = true, which presents the image picker sheet.
                //  Classify:
                    // • Calls classify().
                    // • Disabled if: No image has been picked, or a classification is already running.
                HStack {
                    Button("Select Image") {
                        isShowingImagePicker = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Classify") {
                        classify()
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectedUIImage == nil || isClassifying)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("X-ray Classifier")
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $selectedUIImage)
            }
        }
    }

    private func classify() {
        guard let image = selectedUIImage else { return }

        isClassifying = true
        errorMessage = nil
        classificationResult = "Classifying…"

        // Calls classifier.classify(image:) asynchronously.
        // When the callback returns:
            // • Hop back to the main thread (important for UI updates).
            // • Set isClassifying = false.
            // • On success, show the prediction label.
        classifier.classify(image: image) { result in
            DispatchQueue.main.async {
                self.isClassifying = false
                switch result {
                case .success(let label):
                    self.classificationResult = "Prediction: \(label)"

                    // Extract a cleaner label, e.g. "knee" from "knee (93.2%)"
                    let cleanLabel = label.components(separatedBy: "(").first?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? label

                    let message = "Last time I classified a \(cleanLabel) X-ray!"

                    // Schedule / update repeating notification once per minute
                    NotificationManager.shared.scheduleLastClassificationNotification(text: message)
                case .failure(let error):
                    self.classificationResult = "Classification failed"
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }//: end classify func
}
