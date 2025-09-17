//
//  ContentView.swift
//  GroceryList2
//
//  Created by Ioannis Pavlidis on 9/11/25.
//

import SwiftUI
import SwiftData
import TipKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [DataItemModel]
    
    @State private var item: String = ""
    
    @FocusState private var isFocused: Bool
    
    let buttonTip = ButtonTip()
    
    init() {
        try? Tips.configure()
    }
    
    func addEssentailFoods() {
        modelContext.insert(DataItemModel(title: "Bakery & Bread", isCompleted: false))
        modelContext.insert(DataItemModel(title: "Meat & Seafood", isCompleted: true))
        modelContext.insert(DataItemModel(title: "Cereals", isCompleted: .random()))
        modelContext.insert(DataItemModel(title: "Pasta & Rice", isCompleted: .random()))
        modelContext.insert(DataItemModel(title: "Cheese & Eggs", isCompleted: .random()))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { DataItemModel in
                    Text(DataItemModel.title)
                        .font(.title.weight(.light))
                        .padding(.vertical, 2)
                        .foregroundStyle(DataItemModel.isCompleted == false ? Color.primary: Color.accentColor)
                        .strikethrough(DataItemModel.isCompleted)
                        .italic(DataItemModel.isCompleted)
                        .swipeActions {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(DataItemModel)
                                }
                            } label: { Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button("Done", systemImage: DataItemModel.isCompleted == false ? "checkmark.circle": "x.circle"){
                                DataItemModel.isCompleted.toggle()
                            }
                            .tint(DataItemModel.isCompleted == false ? .green: .accentColor)
                        }
                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                if items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addEssentailFoods()
                    } label: {
                        Image(systemName: "carrot")
                    }
                    .popoverTip(buttonTip)
                    }
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("Empty Cart", systemImage: "cart.circle", description: Text("Add some items to the shopping list!"))
                }
            }
            .safeAreaInset(edge: .bottom)   {
                VStack (spacing: 12){
                    TextField("", text: $item)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(.tertiary)
                        .cornerRadius(8)
                        .font(.title.weight(.light))
                        .focused($isFocused)
                    
                    Button {
                        guard !item.isEmpty else { return }
                        
                        let newItem = DataItemModel(title: item, isCompleted: false)
                        modelContext.insert(newItem)
                        item = ""
                        isFocused = false
                    } label: {
                        Text("Save")
                            .font(.title2.weight(.medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.extraLarge)
                }
                .padding()
                .background(.bar)
            }
        }
    }
}

#Preview ("Sample Data"){
    let sampleData: [DataItemModel] = [
        DataItemModel(title: "Bakery & Bread", isCompleted: false),
        DataItemModel(title: "Meat & Seafood", isCompleted: true),
        DataItemModel(title: "Cereals", isCompleted: .random()),
        DataItemModel(title: "Pasta & Rice", isCompleted: .random()),
        DataItemModel(title: "Cheese & Eggs", isCompleted: .random())]
    
    let container = try! ModelContainer(for: DataItemModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    for item in sampleData {
        container.mainContext.insert(item)
    }
    
    return ContentView()
        .modelContainer(container)
}

#Preview ("Empty List") {
    ContentView()
        .modelContainer(for: DataItemModel.self, inMemory: true)
}
