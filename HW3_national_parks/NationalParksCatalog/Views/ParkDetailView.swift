//
//  DetailView.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/19/25.
//

import Foundation
import SwiftUI
import SwiftData

struct ParkDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var park: CatalogItem
    
    var body: some View {
        //just show all the properties to make sure its parsing
        VStack{
            if let parkPic = imageForPark(named: park.imageName) {
                // the return from the helper func
                parkPic
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                    .overlay(alignment: .bottomLeading) {
                        Text("Img Credit © Wikipedia")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(4)
                    }//: Overlay
            } else {
                //no return from helper func so display generic park icon
                Image(systemName: "mountain.2")
                    .resizable()
                    .scaledToFit()
                    .padding(40)
                    .foregroundStyle(.quaternary)
            }
            VStack(spacing: 8) {
                Text(park.name)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                
                Text(park.subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                
                Text(park.details)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)
            }//: VStack (name, subtitle, detail blocks)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .circular))
            .padding(.horizontal)
        }//: VStack (main page body block)
        
        //Favorite/unfavorite button
        Button{
            park.isFavorite.toggle()
        }label: {
            HStack{
                if park.isFavorite {
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
    }//: Body
    
}//: ParkDetailView

