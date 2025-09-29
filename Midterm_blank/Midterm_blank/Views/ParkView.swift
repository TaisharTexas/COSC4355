//
//  ParkView.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/22/25.
//

import SwiftUI
import SwiftData

struct ParkView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var parks: [CatalogItem]
    @State private var path = [CatalogItem]()
    
    let layout = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        NavigationStack (path: $path){
            ScrollView {
                LazyVGrid(columns: layout) {
                    ForEach(parks){thePark in
                        NavigationLink(value: thePark){
                            VStack{
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
                                    .font(.title)
                                    .padding(.vertical, 4)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                                Text("\(thePark.subtitle)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                            }//: VStack
                            .padding(8)
                            .padding(.bottom, 28)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                            .aspectRatio(3/4, contentMode: .fit)   // keep all cards same height
                            .overlay(alignment: .bottomTrailing){
                                let favVal = thePark.isFavorite ? "heart.fill" : "heart"
                                Image(systemName: favVal)   
                                        .foregroundColor(.blue)
                                        .padding(8)
                                        .background(.ultraThinMaterial, in: Circle())
                                        .padding(8)
                            }//: Overlay
                            
                        }//: Navigation Link (inside ForEach)
                        .foregroundStyle(.primary)
                        
                    }//: ForEach
                    
                }//: LazyVGrid
                .padding(.horizontal)
                
            }//: Scroll View
            .navigationTitle(parks.isEmpty ? "" : "Parks")
            .navigationDestination(for: CatalogItem.self, destination: ParkDetailView.init)
            .overlay{
                if parks.isEmpty {
                    //                    print("CONTENT: parks.isEmpty is true...showing no content screen")
                    CustomContentUnavailableView(icon: "tree.circle", title: "no parks", description: "seems like theres nothing here...maybe check outside and touch some grass?")
                }
            }//: .overlay
        }//: Navigation Stack
    }//: View
}
