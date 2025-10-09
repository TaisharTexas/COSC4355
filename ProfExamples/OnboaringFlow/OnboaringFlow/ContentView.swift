//
//  ContentView.swift
//  OnboaringFlow
//
//  Created by Andrew Lee on 9/4/25.
//

import SwiftUI

let gradientColors: [Color] = [.red, .orange]
    

struct ContentView: View {
    var body: some View {
        TabView{
            WelcomePage()
            FeaturesPage()
        }
        .background(Gradient(colors: gradientColors))
        .tabViewStyle(.page)
        .foregroundStyle(.white)
    }
}

#Preview {
    ContentView()
}
