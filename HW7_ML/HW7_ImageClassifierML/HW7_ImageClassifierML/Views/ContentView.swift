//
//  ContentView.swift
//  HW7_ImageClassifierML
//
//  Created by Andrew Lee on 11/17/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedUIImage: UIImage?
    @State private var classificationResult: String = "No Image Selected"
    @State private var isShowingImagePicker = false
    @State private var isClassifying = false
    @State private var errorMessage: String?
    
    private let classifier = ClassifierService()
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20){
                ZStack{
                    Rectangle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(3/4, contentMode: .fit)
                    
                    if let uiImage = selectedUIImage{
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    } else{
                        Text("Tap Select Image to choose a picture")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }//: end zstack
                
                Text(classificationResult)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let errorMessage{
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                HStack{
                    Button("Select Image"){
                        isShowingImagePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Classify"){
                        classify()
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectedUIImage == nil || isClassifying)
                }
                
                Spacer()
                
            }//: end vstack
            .padding()
            .navigationTitle("Image Classifer")
            .sheet(isPresented: $isShowingImagePicker){
                ImagePicker(image: $selectedUIImage)
            }
        }//: end NavView
    }//: end body
    
    
    // Copied from prof example
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
            }//: end dispatch queue
        }
    }//: end classify func
}

#Preview {
    ContentView()
}
