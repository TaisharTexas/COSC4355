//
//  ContentView.swift
//  CampusEvents
//
//  Created by Andrew Lee on 8/28/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            BackgroundView()
            VStack (alignment: .leading){
                TitleView()
                    .padding()
                EventsView()

            }
        }
    }
}

#Preview {
    ContentView()
}
