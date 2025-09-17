//
//  PackingItem.swift
//  HW2_packingList
//
//  Created by Andrew Lee on 9/14/25.
//

import SwiftData
import SwiftUI

@Model
class PackingItemModel {
    var title: String
    var isPacked: Bool = false
    var numberOfItems: Int = 1
    
    init(title: String, isPacked: Bool, numberOfItems: Int = 1) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isPacked = isPacked
        self.numberOfItems = numberOfItems
    }
}
