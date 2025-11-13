//
//  DetailView.swift
//  Notes Watch App
//
//  Created by Ioannis Pavlidis on 11/5/25.
//

// Purpose
// DetailView shows one note in large text, plus a footer with:
//    •    a gear button to open Settings
//    •    an info button to open Credits
//    •    a position indicator (e.g., “2 / 5”             meaning “second of five notes”)


import SwiftUI

struct DetailView: View {
  // MARK: - PROPERTY
  
  let note: Note // the note to display
  let count: Int // total number of notes
  let index: Int // zero based index of the current note
    
  // Booleans that drive the two sheet modals
  @State private var isCreditsPresented: Bool = false
  @State private var isSetingsPresented: Bool = false

  // MARK: - BODY

  var body: some View {
    VStack(alignment: .center, spacing: 3) {
      // HEADER
      HeaderView(title: "")
      
      // CONTENT
      Spacer()
      
      // A ScrollView(.vertical) wraps the note text so long notes can be scrolled. The text is centered and styled with .title3 and .semibold.
      ScrollView(.vertical) {
        Text(note.text)
          .font(.title3)
          .fontWeight(.semibold)
          .multilineTextAlignment(.center)
      }
      
      Spacer()
      
      // FOOTER
      //  • Gear icon: taps toggle isSetingsPresented, which presents SettingsView() via .sheet.
      //  • Middle text: Text("\(count) / \(index + 1)") shows a counter.
      //  • Info icon: taps toggle isCreditsPresented, which presents CreditsView() via .sheet.
      HStack(alignment: .center) {
        Image(systemName: "gear")
          .imageScale(.large)
          .onTapGesture {
              isSetingsPresented.toggle()
          }
          .sheet(isPresented: $isSetingsPresented, content: {
              SettingsView()
          })
        
        Spacer()
        
        Text("\(count) / \(index + 1)")
        
        Spacer()
        
        Image(systemName: "info.circle")
          .imageScale(.large)
          .onTapGesture {
              isCreditsPresented.toggle()
          }
          .sheet(isPresented: $isCreditsPresented, content: {
              CreditsView()
          })
      } //: HSTACK
      .foregroundColor(.secondary)
    } //: VSTACK
    .padding(3) // keeps content from hugging the watch’s edges
  }
}

// MARK: - PREVIEW

struct DetailView_Previews: PreviewProvider {
  static var sampleData: Note = Note(id: UUID(), text: "Hello, World!")
  
  static var previews: some View {
    DetailView(note: sampleData, count: 5, index: 1)
  }
}
