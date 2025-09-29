//
//  ContentView.swift
//  Midterm_blank
//
//  Created by Andrew Lee on 9/25/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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

// Check if the image name given matches to an actual image in the assets
// (gets used wherever the park images are shown)
func imageForPark(named imageName: String) -> Image? {
    if UIImage(named: imageName) != nil {
        print("CONTENT: park image found for \(imageName)")
        return Image(imageName)
    } else {
        print("CONTENT: no park image found for \(imageName)...using default")
        return nil
    }
}
