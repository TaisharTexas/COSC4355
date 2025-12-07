//
//  TeamSettings.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 11/18/25.
//

import Foundation
import Combine

class TeamSettings: ObservableObject {
    @Published var teamNumber: String {
        didSet {
            UserDefaults.standard.set(teamNumber, forKey: "teamNumber")
        }
    }
    
    @Published var teamName: String {
        didSet {
            UserDefaults.standard.set(teamName, forKey: "teamName")
        }
    }
    
    init() {
        // Load from UserDefaults or use defaults
        self.teamNumber = UserDefaults.standard.string(forKey: "teamNumber") ?? "18140"
        self.teamName = UserDefaults.standard.string(forKey: "teamName") ?? "Thunderbolts in Disguise"
    }
}
