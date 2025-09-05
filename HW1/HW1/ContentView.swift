//
//  ContentView.swift
//  HW1
//
//  Created by Andrew Lee on 9/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            PantryDetailView(
                PantryOwner: "Jane",
                ItemIcon: ["leaf.fill", "cart.fill", "fish.fill", "laurel.trailing", "carrot.fill"],
                ItemDescrip: ["Herbal Tea", "Cereal", "Fish", "Fresh Bread", "Vegitables"],
                PersonalColor: Color.purple,
                InfoIcon: "person.crop.circle",
                InfoDescrip: "A description about the pantry and what sort of things are in it"
            )
            PantryDetailView(
                PantryOwner: "John",
                ItemIcon: ["leaf.fill", "cart.fill", "fish.fill", "laurel.trailing", "carrot.fill"],
                ItemDescrip: ["Herbal Tea", "Cereal", "Fish", "Fresh Bread", "Vegitables"],
                PersonalColor: Color.teal,
                InfoIcon: "person.crop.circle",
                InfoDescrip: "A description about the pantry and what sort of things are in it"
            )
        }
//        .background(Gradient(colors: gradientColors))
        .tabViewStyle(.page)
        .foregroundStyle(.white)
    }
}

#Preview {
    ContentView()
}
