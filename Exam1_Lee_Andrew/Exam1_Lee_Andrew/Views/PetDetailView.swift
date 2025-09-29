//
//  PetDetailView.swift
//  Exam1_Lee_Andrew
//
//  Created by Andrew Lee on 9/25/25.
//

import Foundation
import SwiftData
import SwiftUI

struct PetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var pet: PetItem
    
    var body: some View{
        VStack{
            Image(systemName: pet.imageName)
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundStyle(.quaternary)
            
            VStack(spacing: 8){
                Text(pet.name)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                
                Text(pet.species)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                
                Text(pet.petDescription)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
            }//:VStack (inner)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .circular))
            .padding(.horizontal)
            
            Button{
                pet.isFavorite.toggle()
            }label: {
                HStack{
                    if pet.isFavorite {
                        Image(systemName: "heart.fill")
                        Text("Unfavorite")
                            .font(.title3.weight(.medium))
                            .padding(8)
                    }
                    else{
                        Image(systemName: "heart")
                        Text("Favorite")
                            .font(.title3.weight(.medium))
                            .padding(8)
                    }
                }
            }//: Button
            .buttonStyle(.borderedProminent)
            .listRowSeparator(.hidden)
            .padding(.bottom)
        }//:VStack (outer)
    }
}
