//
//  PetItem.swift
//  Exam1_Lee_Andrew
//
//  Created by Andrew Lee on 9/25/25.
//

import Foundation
import SwiftData

@Model
class PetItem{
    var id: Int
    var name: String
    var species: String
    var petDescription: String
    var imageName: String
    var isFavorite: Bool = false
    
    init(id: Int, name: String, species: String, petDescription: String, imageName: String, isFavorite: Bool){
        self.id = id
        self.name = name
        self.species = species
        self.petDescription = petDescription
        self.imageName = imageName
        self.isFavorite = isFavorite
    }
}
