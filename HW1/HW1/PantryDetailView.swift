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
    
    @State private var currentItem = 0
    @State private var showInfo = false
    
    var body: some View {
        VStack{
            ZStack{
                // rounded rectangle
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white)
                    .opacity(0.25)
                    .brightness(0.1)
                    .frame(height: 80)
                // {PantryOwner}'s pantry
                Text("\(PantryOwner)'s Pantry")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            VStack{
                ZStack{
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.white)
    //                    .opacity(0.25)
    //                    .brightness(-0.4)
                        .frame(width: 225, height: 260)
                        .shadow(radius: 5)
                    VStack{
                        Image(systemName: ItemIcon[currentItem])
                            .font(.system(size: 130))
                            .foregroundColor(PersonalColor)
                        Text(ItemDescrip[currentItem])
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                            .padding(.top,8)
                    } //VStack end
                    
                } //ZStack end
                HStack{
                    //left arrow button
                    Button(action: {
                        withAnimation {
                            currentItem = abs((currentItem - 1) % ItemIcon.count)
                        }
                    }) {
                        ZStack{
                            Circle()
                                .foregroundStyle(.white)
                                .opacity(0.25)
                                .brightness(0.3)
                                .frame(height: 40)
                                
                            Image(systemName: "chevron.left.circle")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                            
                        }

                    }
                    Spacer()
                    //item num (use array length)
                    Text("\(currentItem + 1) of \(ItemIcon.count)")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    Spacer()
                    //right arrow button
                    Button(action: {
                        withAnimation {
                            currentItem = abs((currentItem + 1) % ItemIcon.count)
                        }
                    }) {
                        ZStack{
                            Circle()
                                .foregroundStyle(.white)
                                .opacity(0.25)
                                .brightness(0.3)
                                .frame(height: 40)
                                
                            Image(systemName: "chevron.right.circle")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        }
                        
                        
                    }
                } //HStack end
                .frame(width: 175)
            } //VStack end
            
            Spacer()
            
            HStack{
                //detail icon button
                Button(action:{
                    showInfo = true
                }){
                    ZStack{
                        Circle()
                            .foregroundStyle(.white)
                            .opacity(0.25)
                            .brightness(0.1)
                            .frame(height: 40)
                        Image(systemName: "info.circle")
                            .foregroundColor(.black)
                    }
                }
                .accessibilityLabel("Show Information")
                
                //randomize button
                Button(action:{
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentItem = Int.random(in: 0..<ItemIcon.count)
                    }
                }){
                    ZStack{
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(PersonalColor)
                            .shadow(radius: 5)
                            .frame(width: 300, height: 40)
                        Text("Randomize")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            } //HStack end
            .sheet(isPresented: $showInfo) { InfoView(
                PantryOwner: PantryOwner,
                PersonalColor: PersonalColor,
                InfoIcon: InfoIcon,
                InfoDescrip: InfoDescrip
            ).presentationDetents([.medium, .large]) }
            Spacer()
        }
        
//        .background(Color.blue.opacity(1))
    }
}

//yoinked from the Hike example
struct InfoView: View {
    let PantryOwner: String
    let PersonalColor: Color
    let InfoIcon: String
    let InfoDescrip: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Capsule().fill(.secondary.opacity(0.4))
                    .frame(width: 48, height: 6)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                
                HStack{
                    Image(systemName: InfoIcon)
                        .foregroundColor(PersonalColor)
                        .frame(width: 35, height: 35)
                    Text("\(PantryOwner)'s Pantry")
                        .font(.title3).bold()
                        .foregroundColor(.black)
                }
                

                Text(InfoDescrip)
                    .font(.body)
                    .foregroundStyle(.black)

                Divider().padding(.vertical, 8)

            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 4)
            )
            .padding(.horizontal)
            .padding(.bottom, 24)
            .background(
                LinearGradient(
                    colors: [Color(.secondarySystemBackground), Color(.systemBackground)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    PantryDetailView(
        PantryOwner: "Jane",
        ItemIcon: ["leaf.fill", "cart.fill", "fish.fill", "laurel.trailing", "carrot.fill"],
        ItemDescrip: ["Herbal Tea", "Cereal", "Fish", "Fresh Bread", "Vegitables"],
        PersonalColor: Color.purple,
        InfoIcon: "person.fill",
        InfoDescrip: "A description about the pantry and what sort of things are in it"
    )
}
