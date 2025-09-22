//
//  AboutView.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/22/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack{
            Text("About")
                .font(.largeTitle)
            Image(systemName: "leaf.circle")
                .font(.largeTitle)
            Text("About This App")
                .font(.title2)
            Text("This sample showcases a grid-based catalog of U.S. National Parks using SwiftUI. It demonstrates TabView, NavigationStack, LazyVGrid, and basic state management for favorites.")
                .font(.default)
        }
        
    }
}
