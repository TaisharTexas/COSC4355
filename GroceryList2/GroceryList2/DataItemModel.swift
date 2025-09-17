//
//  DataItemModel.swift
//  GroceryList2
//
//  Created by Ioannis Pavlidis on 9/11/25.
//

import Foundation
import SwiftData

@Model
class DataItemModel {
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool) {
        self.title = title
        self.isCompleted = isCompleted
    }
}
