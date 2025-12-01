//
//  Habit.swift
//  Exam3_Lee_Andrew Watch App
//
//  Created by Andrew Lee on 11/20/25.
//

import Foundation
import SwiftUI

enum Habit: Int, CaseIterable, Identifiable, Codable {
    case water, move, breath
    var id: Int { rawValue }
    var icon: String { ["drop.fill","figure.walk","wind"][rawValue] }
    var label: String { ["Water","Move","Breath"][rawValue] }
    var color: Color { [.blue, .orange, .green][rawValue] }
    
}
