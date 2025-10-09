//
//  ContentView.swift
//  DiceRoller
//
//  Created by Ioannis Pavlidis on 9/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var numberOfDice = 1
    
    var body: some View {
        VStack {
            Text("Dice Roller")
                .font(.largeTitle.lowercaseSmallCaps())
            
            HStack {
                ForEach(1...numberOfDice, id: \.description) { _ in
                    DiceView()
                }
            }
            .padding()
            
            HStack {
                Button("Remove Dice", systemImage: "minus.circle.fill") {
                    withAnimation {
                        numberOfDice -= 1
                    }
                }
                .disabled(numberOfDice == 1)
                .padding()
                
                Button("Add Dice", systemImage: "plus.circle.fill") {
                    withAnimation {
                        numberOfDice += 1
                    }
                    
                }
                .disabled(numberOfDice == 3)
            }
            .padding()
            .labelStyle(.iconOnly)
            .font(.largeTitle)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
