//
//  FunFactsView.swift
//  AboutMe
//
//  Created by Ioannis Pavlidis on 9/14/25.
//

import SwiftUI

struct FunFactsView: View {
    
    @State private var funFact = ""
    
    var body: some View {
        VStack {
            Text("Fun Facts")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(funFact)
                .padding()
                .font(.body)
                .frame(minHeight: 400)
            
            Button("Show Random Fact") {
                funFact = information.funFacts.randomElement()!
            }
        }
        .padding()
    }
}

#Preview {
    FunFactsView()
}
