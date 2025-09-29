//
//  CatalogItemModel.swift
//  HW3_national_parks
//
//  Created by Andrew Lee on 9/19/25.
//

import Foundation
import SwiftData

@Model
class CatalogItem {
    var id: Int
    var name: String
    var subtitle: String
    var details: String
    var imageName: String
    var isFavorite: Bool = false
    
    
    init(id: Int, name: String, subtitle: String, details: String, imageName: String, isFavorite: Bool) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.details = details
        self.imageName = imageName
        self.isFavorite = isFavorite
    }
    
}
