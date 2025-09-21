//
//  ContentView.swift
//
//  Created by Andrew Lee on 9/18/25.
//

import SwiftUI
import SwiftData



struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var parks: [CatalogItem]
    @State private var path = [CatalogItem]()
//    @State private var isEditing: Bool = false
    
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
                                    .font(.title.weight(.light))
                                    .padding(.vertical)
                                
                                Spacer()
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
            .navigationTitle(parks.isEmpty ? "" : "Parks")
            .navigationDestination(for: CatalogItem.self, destination: ParkDetailView.init)
            .overlay{
                if parks.isEmpty {
//                    print("CONTENT: parks.isEmpty is true...showing no content screen")
                    CustomContentUnavailableView(icon: "tree.circle", title: "no parks", description: "seems like theres nothing here...maybe check outside and touch some grass?")
                }
            }//: .overlay
        }//: Navigation Stack
        // kept just in case, but in theory this is all moved to the app file
//        .onAppear {
//            //only want to seed the database when it needs it, dont want to keep loading it in all the time
//            Task{
//                if parks.isEmpty {
//                    let parksFromJSON = loadParksFromJSON(from: "parks")
//                    for eachPark in parksFromJSON {
//                        modelContext.insert(eachPark)
//                    }
//                    print("CONTENT: Found file and loaded parks into db")
//                    do {
//                        try modelContext.save()
//                        print("CONTENT: save model context")
//
//                    } catch {
//                        print("CONTENT: save failed: \(error)")
//                    }
//                }
//            }
//        }//: On Appear
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
}//: Content View

//#Preview {
//    ContentView()
//}
