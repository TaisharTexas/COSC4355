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
                InfoDescrip: "Jane likes to be health conscious and likes to eat fresh and healthy items. Part of what Jane enjoys about eating is making sure she is getting all the nutrients she needs and making the meals herself."
            )
            PantryDetailView(
                PantryOwner: "John",
                ItemIcon: ["cart.fill", "takeoutbag.and.cup.and.straw.fill", "cup.and.saucer.fill", "fork.knife", "drop.fill"],
                ItemDescrip: ["Quick Meals", "Takeout", "Coffee", "Ready to Eat Meals", "Water"],
                PersonalColor: Color.teal,
                InfoIcon: "person.crop.square",
                InfoDescrip: "John likes quick easy meals and tasty items that dont take a lot of preparing or time. The nutrition content is not something he thinks about much."
            )
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [Color("GradientTop"), Color("GradientBottom")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )

    }
}

#Preview {
    ContentView()
}
