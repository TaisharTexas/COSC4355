//
//  ImagePreviewView.swift
//  PhotoLibrary
//
//  Created by Mert on 10/14/25.
//

import SwiftUI

// MARK: - Image Preview View
struct ImagePreviewView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @Environment(PhotoStore.self) private var photoStore
    @State private var description: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Description")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("Add a description for this photo...", text: $description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
            
            Spacer()
        }
        .padding()
        
        .navigationTitle("Add Photo")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Discard") {
                    isPresented = false
                }
                .foregroundColor(.red)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    photoStore.addPhoto(image, description: description)
                    isPresented = false
                }
                .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ImagePreviewView(image: UIImage(systemName: "photo")!, isPresented: .constant(true))
            .environment(PhotoStore())
    }
}
