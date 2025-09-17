//
//  ContentView.swift
//  HW2_packingList
//
//  Created by Andrew Lee on 9/11/25.
//

import SwiftUI
import SwiftData
import TipKit

struct ContentView: View {
    
    @Query private var packingList: [PackingItemModel] = []
    @Environment(\.modelContext) private var modelContext
    
    @State private var itemToPack: String = ""
    @State private var itemQuantity = 1
    @FocusState private var isFocused: Bool
    
    let buttonTip = ButtonTip()
    
    init() {
        try? Tips.configure()
    }
    
    
    func addEssentialItems() {
        modelContext.insert(PackingItemModel(title: "Passport", isPacked: false, numberOfItems: 1))
        modelContext.insert(PackingItemModel(title: "Deoderant", isPacked: true, numberOfItems: 1))
        modelContext.insert(PackingItemModel(title: "Socks", isPacked: .random(), numberOfItems: 4))
        modelContext.insert(PackingItemModel(title: "Toothbrush", isPacked: .random(), numberOfItems: 1))
        modelContext.insert(PackingItemModel(title: "Cell phone charger", isPacked: .random(), numberOfItems: 2))
    }
    
    var body: some View {
        NavigationStack {
            List{
                if packingList.isEmpty {
                    VStack{
                        Image(systemName: "suitcase.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Empty Suitcase")
                            .font(.headline)
                        Text("Add items you need to pack.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                else {
                    ForEach(packingList){ eachItem in
                        Text(eachItem.numberOfItems > 1 ? "\(eachItem.title) x\(eachItem.numberOfItems)" : eachItem.title)
                            .font(.title.weight(.light))
                            .padding(.vertical, 2)
                            .foregroundStyle(eachItem.isPacked == false ? Color.primary: Color.accentColor)
                            .strikethrough(eachItem.isPacked)
                            .italic(eachItem.isPacked)
                            .swipeActions {
                                Button(role: .destructive) {
                                    withAnimation {
                                        modelContext.delete(eachItem)
                                    }
                                } label: { Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button("Done", systemImage: eachItem.isPacked == false ? "checkmark.circle": "x.circle"){
                                    eachItem.isPacked.toggle()
                                }
                                .tint(eachItem.isPacked == false ? .green: .accentColor)
                            }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .navigationTitle(Text("Packing List"))
            .toolbar {
                if packingList.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addEssentialItems()
                    } label: {
                        Image(systemName: "suitcase.fill")
                    }
                    .popoverTip(buttonTip)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack (spacing:10) {
                    VStack (spacing:10) {
                        TextField("Add item", text: $itemToPack)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.tertiary)
                            .cornerRadius(8)
                            .font(.title.weight(.light))
                            .focused($isFocused)
                            .frame(height: 65)
                        Button {
                            guard !itemToPack.isEmpty else { return }
                            
                            let newItem = PackingItemModel(
                                title: itemToPack,
                                isPacked: false,
                                numberOfItems: itemQuantity
                            )
                            modelContext.insert(newItem)
                            itemToPack = ""
                            itemQuantity = 1
                            isFocused = false
                        } label: {
                            Text("Save")
                                .font(.title2.weight(.medium))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        .controlSize(.extraLarge)
                        .frame(height: 65)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack (spacing:10) {
                        TextField("Qty", value: $itemQuantity, format: .number)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.tertiary)
                            .cornerRadius(8)
                            .font(.title.weight(.light))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(height: 65)
                            .focused($isFocused)
                        HStack (spacing:6) {
                            Button {
                                if itemQuantity > 1 {
                                    itemQuantity -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(itemQuantity > 1 ? .red : .gray)
                            }
                            .disabled(itemQuantity <= 1)
                            .controlSize(.extraLarge)
                            .font(.title)
                            
                            Button {
                                itemQuantity += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .font(.title)
                            .controlSize(.extraLarge)
                        }
                        .frame(height: 65)
                        
                    }
                    .frame(width: 80)
                    
                }
                .padding()
                .background(.bar)
            }
        }
    }
}

#Preview("Sample List") {
    let sampleData: [PackingItemModel] = [
        PackingItemModel(title: "Passport", isPacked: .random(), numberOfItems: 1),
        PackingItemModel(title: "Jeans", isPacked: false, numberOfItems: 3),
        PackingItemModel(title: "Socks", isPacked: .random(), numberOfItems: 4),
        PackingItemModel(title: "Charging Cable", isPacked: false, numberOfItems: 1),
    ]
    
    let container = try! ModelContainer(for: PackingItemModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    for item in sampleData {
        container.mainContext.insert(item)
    }
    
    return ContentView()
        .modelContainer(container)
}

#Preview("Empty List") {
    ContentView()
        .modelContainer(for: PackingItemModel.self, inMemory: true)
}
