//
//  PantryDetailView.swift
//  HW1
//
//  Created by Andrew Lee on 9/4/25.
//

import SwiftUI

struct PantryDetailView: View {
    let PantryOwner: String
    let ItemIcon: [String]
    let ItemDescrip: [String]
    
    let PersonalColor: Color
    
    let InfoIcon: String
    let InfoDescrip: String
    
    var body: some View {
        VStack{
            ZStack{
                // rounded rectangle
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.tint)
                    .opacity(0.25)
                    .brightness(-0.4)
                    .frame(height: 80)
                // {PantryOwner}'s pantry
                Text("\(PantryOwner)'s Pantry")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            VStack{
                ZStack{
                    //rounded rectangle
                    //ItemIcon[itemNum]
                }
                //ItemDescrip[itemNum]
            }
            HStack{
                //left arrow button
                //item num (use array length)
                //right arrow button
            }
            HStack{
                //detail icon button
                //randomize button
            }
            Spacer()
        }
    }
}

#Preview {
    PantryDetailView(
        PantryOwner: "Jane",
        ItemIcon: ["leaf.fill", "cart.fill", "fish.fill", "laurel.trailing", "carrot.fill"],
        ItemDescrip: ["Herbal Tea", "Cereal", "Fish", "Fresh Bread", "Vegitables"],
        PersonalColor: Color.purple,
        InfoIcon: "person.crop.circle",
        InfoDescrip: "A description about the pantry and what sort of things are in it"
    )
}
