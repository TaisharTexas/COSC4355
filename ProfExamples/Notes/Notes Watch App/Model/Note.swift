//
//  Note.swift
//  Notes Watch App
//
//  Created by Ioannis Pavlidis on 11/5/25.
//

import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    let text: String
}
