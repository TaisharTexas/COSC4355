//
//  ContentView.swift
//  Greetings2
//
//  Created by Ioannis Pavlidis on 8/27/25.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        
        
        ZStack {
            BackgroundView()
            
            VStack (alignment: .leading){
                TitleView()
                    .padding()
                MessagesView()
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
