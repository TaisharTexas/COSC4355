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
            Text(String(park.id))
            Text(park.name)
            Text(park.subtitle)
            Text(park.details)
            Text(park.imageName)
            Text(park.isFavorite.description)
        }
    }//: Body
    
}//: ParkDetailView

