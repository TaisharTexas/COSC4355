//
//  FavoritesView.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/22/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
//    @Query private var parks: [CatalogItem]
    @Query(filter: #Predicate<CatalogItem> { $0.isFavorite == true }) private var favoriteParks: [CatalogItem]
    @State private var path = [CatalogItem]()
    
    let layout = [
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack (path: $path){
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(favoriteParks){thePark in
                        NavigationLink(value: thePark) {
                            ZStack {
                                //check if the image name provided matches to an existing image (via imageForPark helper function)
                                if let parkPic = imageForPark(named: thePark.imageName) {
                                    // the return from the helper func
                                    parkPic
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 175)
                                        .clipped()
                                } else {
                                    //no return from helper func so display generic park icon
                                    Image(systemName: "mountain.2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 175)
                                        .padding(40)
                                        .foregroundStyle(.quaternary)
                                }

                                VStack {
                                    Spacer()
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(thePark.name)
                                                .font(.title2)
                                                .bold()
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .foregroundStyle(.primary)
                                            Text(thePark.subtitle)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.forward")
                                            .font(.title2)
                                            .foregroundStyle(.primary)
                                    }//: HStack
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                                    .padding([.horizontal, .bottom], 8)
                                }//: VStack (text block for park)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                            }//: ZStack (main body block)
                            .frame(height: 175)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                        }//: Navigation Link
                        .foregroundStyle(.primary)
                        
                    }//: ForEach
                    
                }//: LazyVGrid
                .padding(.horizontal)
                
            }//: Scroll View
            .navigationTitle(favoriteParks.isEmpty ? "" : "Favorites")
            .navigationDestination(for: CatalogItem.self, destination: ParkDetailView.init)
            .overlay{
                if favoriteParks.isEmpty {
                    //                    print("CONTENT: parks.isEmpty is true...showing no content screen")
                    CustomContentUnavailableView(icon: "tree.circle", title: "no favorite parks :(", description: "seems like theres nothing here...maybe go to a few and see if you like them?")
                }
            }//: .overlay
        }//: Navigation Stack
    }//: Body
    
}//: Favorites View
