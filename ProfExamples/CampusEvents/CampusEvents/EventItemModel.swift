//
//  EventItemModel.swift
//  CampusEvents
//
//  Created by Andrew Lee on 8/28/25.
//

import SwiftUI

struct EventItemModel: Identifiable{
    let id = UUID()
    
    let title: String
    let location: String
    let time: String
    let accent: Color
    let fill: Color
    let shadow: Color
}
