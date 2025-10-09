//
//  ContentView.swift
//  Grettings
//
//  Created by Andrew Lee on 8/28/25.
//

import SwiftUI

struct ContentView2: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello there!")
                .font(.largeTitle)
                .foregroundColor(Color("1E93AB"))
                .fontWeight(.semibold)
                .padding()
                .background(Color("DCDCDC"))
                .cornerRadius(10)
                .shadow(color: Color("C59560"), radius: 5, x: 5, y: 5)
            
            Text("Yo wassup")
                .font(.largeTitle)
                .foregroundColor(Color("1E93AB"))
                .fontWeight(.semibold)
                .padding()
                .background(Color("DCDCDC"))
                .cornerRadius(10)
                .shadow(color: Color("C59560"), radius: 5, x: 5, y: 5)
            
            Text("Nothing much wyd")
                .font(.largeTitle)
                .foregroundColor(Color("1E93AB"))
                .fontWeight(.semibold)
                .padding()
                .background(Color("DCDCDC"))
                .cornerRadius(10)
                .shadow(color: Color("C59560"), radius: 5, x: 5, y: 5)
        }
        .padding()
    }
}

#Preview {
    ContentView2()
}
