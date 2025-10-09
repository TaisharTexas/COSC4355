//
//  DataItemModel.swift
//  Grettings
//
//  Created by Andrew Lee on 8/28/25.
//

import SwiftUI

struct DataItemModel: Identifiable{
    let id = UUID()
    
    let text: String
    let fgColor: Color
    let bgColor: Color
    let shadowColor: Color
}
