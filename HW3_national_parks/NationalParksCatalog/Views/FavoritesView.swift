//
//  FavoritesView.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/22/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query private var parks: [CatalogItem]
    @State private var path = [CatalogItem]()
    
    let layout = [
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack (path: $path){
            ScrollView {
                LazyVGrid(columns: layout) {
                    ForEach(parks){thePark in
                        NavigationLink(value: thePark){
                            VStack{
                                //only process the park if its a favorite
                                if thePark.isFavorite == true{
                                    //check if the image name provided matches to an existing image (via imageForPark helper function)
                                    if let parkPic = imageForPark(named: thePark.imageName) {
                                        // the return from the helper func
                                        parkPic
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                                    } else {
                                        //no return from helper func so display generic park icon
                                        Image(systemName: "mountain.2")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(40)
                                            .foregroundStyle(.quaternary)
                                    }
                                    Spacer()
                                    
                                    Text("\(thePark.name)")
                                        .font(.title.weight(.light))
                                        .padding(.vertical)
                                    
                                    Spacer()
                                }
                                
                            }//: VStack
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                            .aspectRatio(3/4, contentMode: .fit)   // keep all cards same height
                        }//: Navigation Link (inside ForEach)
                        .foregroundStyle(.primary)
                        
                    }//: ForEach
                    
                }//: LazyVGrid
                .padding(.horizontal)
                
            }//: Scroll View
            .navigationTitle(parks.isEmpty ? "" : "Favorites")
            .navigationDestination(for: CatalogItem.self, destination: ParkDetailView.init)
            .overlay{
                if parks.isEmpty {
                    //                    print("CONTENT: parks.isEmpty is true...showing no content screen")
                    CustomContentUnavailableView(icon: "tree.circle", title: "no favorite parks", description: "seems like theres nothing here...maybe check outside and touch some grass?")
                }
            }//: .overlay
        }//: Navigation Stack
    }//: Body
    
    // Check if the image name given matches to an actual image in the assets
    private func imageForPark(named imageName: String) -> Image? {
        if UIImage(named: imageName) != nil {
            print("CONTENT: park image found for \(imageName)")
            return Image(imageName)
        } else {
            print("CONTENT: no park image found for \(imageName)...using default")
            return nil
        }
    }
}//: Favorites View
