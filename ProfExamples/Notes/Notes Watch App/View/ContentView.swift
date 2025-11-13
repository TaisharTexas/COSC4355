//
//  ContentView.swift
//  Notes Watch App
//
//  Created by Ioannis Pavlidis on 11/5/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - PROPERTY
    
    // A user-defaults–backed value (persists across launches) controlling how many text lines to show per note in the list.
    @AppStorage("lineCount") var lineCount: Int = 1
    
    // View-local state: the in-memory notes array and the text field’s current input.
    @State private var notes: [Note] = [Note]()
    @State private var text: String = ""
    
    
    // MARK: FUNCTION
    
    // Finds your app’s sandboxed Documents folder on watchOS.
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    // Encodes [Note] to JSON and writes it to Documents/notes. This persists the whole array whenever you add/delete.
    func save() {
        // dump(notes)
        do {
            // 1. Convert the notes array to data using JSONEncoder
            let data = try JSONEncoder().encode(notes)
            
            // 2. Create a new URL to save the file using the getDocumentDirectory
            let url = getDocumentsDirectory().appendingPathComponent("notes")
            
            // 3. Write the data to the given URL
            try data.write(to: url)
        } catch {
            print("Saving failed.")
        }
    }
    
    // Reads Documents/notes, decodes back into [Note], and assigns it to notes. (You’re dispatching to the main queue; since it touches UI state, assignment must indeed happen on the main actor.)
    func load() {
        DispatchQueue.main.async {
            do {
                // 1. Get the notes URL path
                let url = getDocumentsDirectory().appendingPathComponent("notes")
                
                // 2. Create a new property for the data
                let data = try Data(contentsOf: url)
                
                // 3. Decode the data
                notes = try JSONDecoder().decode([Note].self, from: data)
            } catch {
                // Do nothing
            }
        }
    }
    
    // Removes the selected rows with animation and calls save().
    func delete(offsets: IndexSet) {
        withAnimation {
            notes.remove(atOffsets: offsets)
            save()
        }
        
    }
    
    
    // MARK: BODY
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 6) {
                // Captures input
                TextField("Add New Note", text: $text)
                    
                Button {
                    // 1. Only run the button's action when the text field is not empty
                    guard text.isEmpty == false else { return }
                    
                    // 2. Create a new note item and initialize it with the text value
                    let note = Note(id: UUID(), text: text)
                    
                    // 3. Add the new note item to the notes array (append)
                    notes.append(note)

                    // 4. Make the text field empty
                    text = ""
                    
                    // 5. Save the notes (function)
                    save()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 42, weight: .semibold))
                }
                .fixedSize()
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.accentColor)
            } //: HSTACK
            Spacer()
            
            //  Notes list (or empty state)
                // If there are notes: a List with a ForEach of indices 0..<notes.count. Each row:
                // A thin Capsule() tinted with .accentColor as a leading marker
                // The note text, limited by lineCount
                // Wrapped in a NavigationLink to DetailView(note: notes[i], count: notes.count, index: i)
                // If there are no notes: a large, faint note.text system image as a placeholder.
            if notes.count >= 1 {
                List {
                    ForEach (0..<notes.count, id: \.self) {i in
                        NavigationLink(destination: DetailView(note: notes[i], count: notes.count, index: i)){
                            HStack {
                                Capsule()
                                    .frame(width: 4)
                                    .foregroundColor(.accentColor)
                                Text(notes[i].text)
                                    .lineLimit(lineCount)
                                    .padding(.leading, 5)
                            }
                        } //: HSTACK
                    } //: LOOP
                    .onDelete(perform: delete)
                } //: LIST
            } else {
                Spacer()
                Image(systemName: "note.text")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .opacity(0.25)
                    .padding(25)
                Spacer()
            }
        } //: VSTACK
        .navigationTitle("Notes")
        .onAppear(perform: {
            load()
        })
    }
}


// MARK: PREVIEW

#Preview {
    NavigationStack {
        ContentView()
    }
}
