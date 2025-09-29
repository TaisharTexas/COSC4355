//
//  PetsView.swift
//  Exam1_Lee_Andrew
//
//  Created by Andrew Lee on 9/25/25.
//

import SwiftData
import SwiftUI

struct PetsView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query private var pets: [PetItem]
    @State private var path = [PetItem]()
    
    let layout = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack(path: $path){
            ScrollView{
                LazyVGrid(columns: layout){
                    ForEach(pets){thePet in
                        NavigationLink(value: thePet){
                            VStack{
                                Image(systemName: thePet.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(15)
                                    .foregroundStyle(.quaternary)
                                    .frame(maxWidth: 150, maxHeight: 150)
                                Spacer()
                                Text("\(thePet.name)")
                                    .font(.title)
                                    .padding(.vertical, 4)
                                Text("\(thePet.species)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }//:VStack
                            .padding(20)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                            .aspectRatio(4/4, contentMode: .fit)
                            .overlay(alignment: .bottomTrailing){
                                let favVal = thePet.isFavorite ? "heart.fill" : "heart"
                                Image(systemName: favVal)
                                        .foregroundColor(.blue)
                                        .padding(5)
                                        .background(.ultraThinMaterial, in: Circle())
                            }//: Overlay
                        }//:NavLink
                        .foregroundStyle(.primary)
                    }//:For loop
                }//:LazyVGrid
                .padding(.horizontal)
            }//:ScrollView
            .navigationTitle(pets.isEmpty ? "" : "Pets")
            .navigationDestination(for: PetItem.self, destination: PetDetailView.init)
            .overlay{
                if pets.isEmpty {
                    CustomContentUnavailableView(icon: "pawprint", title: "no pets", description: "seems like theres nothing here...maybe check your local pet shelter?")
                }
            }//: .overlay
        }//:NavStack
    }
}
