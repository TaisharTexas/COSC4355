//
//  FavoritesView.swift
//  Exam1_Lee_Andrew
//
//  Created by Andrew Lee on 9/25/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(filter: #Predicate<PetItem> { $0.isFavorite == true }) private var favoritePets: [PetItem]
    @State private var path = [PetItem]()
    
    let layout = [
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack(path: $path){
            ScrollView{
                LazyVStack(spacing: 16){
                    ForEach(favoritePets){ thePet in
                        NavigationLink(value: thePet){
                            HStack{
                                
                                Image(systemName: thePet.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 175)
                                    .padding(10)
                                    .foregroundStyle(.quaternary)
                                Spacer()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(thePet.name)
                                        .font(.title2)
                                        .bold()
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                    Text(thePet.species)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.center)
                                }//:VStack (text block)
                                .padding(8)
                                .frame(minWidth: 200)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
//                                .padding([.horizontal, .bottom], 8)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.forward")
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                                
                            }//:HStack (main block for card)
                            .frame(height: 175)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                            
                        }//: NavLink
                        .foregroundStyle(.primary)
                    }//:For loop
                }//:LazyVStack
                .padding(.horizontal)
            }//:ScrollView
            .navigationTitle(favoritePets.isEmpty ? "" : "Favorites")
            .navigationDestination(for: PetItem.self, destination: PetDetailView.init)
            .overlay{
                if favoritePets.isEmpty {
                    CustomContentUnavailableView(icon: "pawprint", title: "no favorite pets :(", description: "seems like theres nothing here...maybe go look at a few and favorite them?")
                }
            }//: .overlay
        }//:NavStack
    }//: Body
}//: Fav View
