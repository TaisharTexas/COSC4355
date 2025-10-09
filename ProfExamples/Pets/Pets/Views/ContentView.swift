//
//  ContentView.swift
//  Pets
//
//  Created by Ioannis Pavlidis on 9/15/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // Environment is everything (db+colors+...)
    // Doorway to your database
    @Environment(\.modelContext) var modelContext
    // Runs queries & updates modelContext
    @Query private var pets: [PetDataItem]
    
    // Navigation path to stack of PetDataItems
    @State private var path = [PetDataItem]()
    // Controls view's editin mode
    @State private var isEditing: Bool = false
    
    // Grid with two columns
    let layout = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    func addPet() {
        isEditing = false                   // close any editor UI
        let pet = PetDataItem(name: "Best Friend")
        modelContext.insert(pet)            // persist in the current context
        path = [pet]                        // navigate to the new pet's detail
    }
    
    var body: some View {
        NavigationStack (path: $path) {     // array of screens atop the navigation root
            ScrollView {
                LazyVGrid(columns: layout) {
                        ForEach(pets) { PetDataItem in
                            NavigationLink(value: PetDataItem) {
                                VStack {
                                    if let imageData = PetDataItem.photo {
                                        // Convert data to UIImage
                                        if let image = UIImage(data: imageData) {
                                            // Convert UIImage to SwiftUI Image
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                                        }
                                    } else {
                                            // If no photo show SF
                                            Image(systemName: "pawprint.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .padding(40)
                                                .foregroundStyle(.quaternary)
                                    }
                                    Spacer()
                                    
                                    Text("\(PetDataItem.name)")
                                        .font(.title.weight(.light))
                                        .padding(.vertical)
                                    
                                    Spacer()
                                } //: VSTACK
                                .padding(8)
                                // Creates a frosted  background that adapts to light/dark mode
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                                .aspectRatio(3/4, contentMode: .fit)   // keep all cards same height
                                .overlay(alignment: .topTrailing) {
                                    if isEditing {
                                        Menu {
                                            Button("Delete", systemImage: "trash", role: .destructive) {
                                                withAnimation {
                                                    self.modelContext.delete(PetDataItem)
                                                    try? modelContext.save()
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "trash.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 36, height: 36)
                                                .foregroundStyle(.red)
                                                .symbolRenderingMode(.multicolor)
                                                .padding()
                                        }
                                    }
                                }
                            } //: NAVLINK
                            .foregroundStyle(.primary)
                        }
                } //: GRID LAYOUT
                .padding(.horizontal)
            } //: SCROLVIEW
            .navigationTitle(pets.isEmpty ? "" : "Pets")
            .navigationDestination(for: PetDataItem.self, destination: EditPetView.init)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                        
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add a New Pet", systemImage: "plus.circle", action: addPet)
                }
            }
            .overlay{
              if pets.isEmpty {
                    CustomContentUnavailableView(icon: "dog.circle", title: "No Pets", description: "Add a new pet to get started.")
                }
            }
        } //: NAVSTACK
    }
}

#Preview("Sample Data") {
    ContentView()
        .modelContainer(PetDataItem.preview)
}

#Preview("No Data") {
    ContentView()
        .modelContainer(for: PetDataItem.self, inMemory: true)
}
