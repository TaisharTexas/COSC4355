//
//  EditPetView.swift
//  Pets
//
//  Created by Ioannis Pavlidis on 9/17/25.
//

import SwiftUI
import SwiftData
import PhotosUI // Photo picker

struct EditPetView: View {
    // Function to close current view
    @Environment(\.dismiss) private var dismiss
    // Edit in UI and changes reflected in model context
    @Bindable var pet: PetDataItem
    @State private var photosPickerItem: PhotosPickerItem?
    
    var body: some View {
        // A Form is like a specialized, multimodal list designed for editing data. Its purpose is to host different kinds of input controls, each of which may bring up a different modality (keyboard, switches, date pickers, photo pickers, etc.).
        Form {
            // MARK: - IMAGE
            if let imageData = pet.photo {
                if let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .padding(.top)
                }
            } else {
                CustomContentUnavailableView(icon: "pawprint.circle", title: "No Photo", description: "Add a photo for your favorite pet.")
                    .padding(.top)
            }
                
            // MARK: - PHOTO PICKER
            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                Label("Select a photo", systemImage: "photo.badge.plus")
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            
            
            
            // MARK: - TEXT FIELD
            TextField("Name", text: $pet.name)
                .textFieldStyle(.roundedBorder)
                .font(.largeTitle.weight(.light))
                .padding(.vertical)
            
            // MARK: - BUTTON
            Button {
                dismiss()
            } label: {
                Text("Save")
                    .font(.title3.weight(.medium))
                    .padding(8)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .listRowSeparator(.hidden)
            .padding(.bottom)
            
        } //: FORM
        .listStyle(.plain)
        .navigationTitle("Edit \(pet.name)")
        .navigationBarTitleDisplayMode(.inline) // Small title
        .navigationBarBackButtonHidden()
        .onChange(of: photosPickerItem) {
            // Runs off the main thread
            Task {
            pet.photo = try? await photosPickerItem?.loadTransferable(type: Data.self)
        }
            
        }
    }
}

#Preview {
    NavigationStack {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: PetDataItem.self, configurations: configuration)
                
            let sampleData = PetDataItem(name: "Daisy")
            
            return EditPetView(pet: sampleData)
                .modelContainer(container)
        } catch {
            fatalError("Could not load preview data: \(error.localizedDescription)")
        }
    }
}
