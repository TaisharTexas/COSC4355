//
//  ContentView.swift
//
//  Created by Andrew Lee on 9/18/25.
//

import SwiftUI
import SwiftData



struct ContentView: View {
//    @Environment(\.modelContext) var modelContext
//    @Query private var parks: [CatalogItem]
//    @State private var path = [CatalogItem]()
//    @State private var isEditing: Bool = false
    
//    let layout = [
//        GridItem(.flexible(minimum: 120)),
//        GridItem(.flexible(minimum: 120))
//    ]
    
    var body: some View {
        TabView{
            Tab("Parks", systemImage: "tree.fill"){
                ParkView()
            }
            Tab("Favorites", systemImage: "heart.fill"){
                FavoritesView()
            }
            Tab("About", systemImage: "info.circle"){
                AboutView()
            }
        }//: Tab View
        
    }//: Body
    
}//: Content View

//#Preview {
//    ContentView()
//}
