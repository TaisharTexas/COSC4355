//
//  TeamSettingsModel.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 11/18/25.
//

import Foundation
import Combine

// Codable model to match API response
struct FTCTeam: Codable, Identifiable, Equatable {
    let teamNumber: Int
    let displayTeamNumber: String?
    let teamId: Int?
    let teamProfileId: Int?
    let nameFull: String?
    let nameShort: String?
    let schoolName: String?
    let city: String?
    let stateProv: String?
    let country: String?
    let website: String?
    let rookieYear: Int?
    let robotName: String?
    let districtCode: String?
    let homeCMP: String?
    let homeRegion: String?
    let displayLocation: String?
    
    var id: Int { teamNumber }
    
    var displayName: String {
        nameShort ?? nameFull ?? "Team \(teamNumber)"
    }
    
    var fullDisplayName: String {
        if let full = nameFull {
            return full
        } else if let short = nameShort {
            return short
        }
        return "Team \(teamNumber)"
    }
    
    var locationString: String {
        var parts: [String] = []
        if let city = city { parts.append(city) }
        if let state = stateProv { parts.append(state) }
        if let country = country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
    
    var regionInfo: String {
        var parts: [String] = []
        if let region = homeRegion { parts.append("Region: \(region)") }
        if let district = districtCode { parts.append("District: \(district)") }
        return parts.isEmpty ? "No region info" : parts.joined(separator: " • ")
    }
}

struct TeamListingsResponse: Codable {
    let teams: [FTCTeam]
    let teamCountTotal: Int
    let teamCountPage: Int
    let pageCurrent: Int
    let pageTotal: Int
}

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
    
    // Additional team info
    @Published var schoolName: String? {
        didSet {
            if let value = schoolName {
                UserDefaults.standard.set(value, forKey: "schoolName")
            } else {
                UserDefaults.standard.removeObject(forKey: "schoolName")
            }
        }
    }
    
    @Published var city: String? {
        didSet {
            if let value = city {
                UserDefaults.standard.set(value, forKey: "city")
            } else {
                UserDefaults.standard.removeObject(forKey: "city")
            }
        }
    }
    
    @Published var stateProv: String? {
        didSet {
            if let value = stateProv {
                UserDefaults.standard.set(value, forKey: "stateProv")
            } else {
                UserDefaults.standard.removeObject(forKey: "stateProv")
            }
        }
    }
    
    @Published var country: String? {
        didSet {
            if let value = country {
                UserDefaults.standard.set(value, forKey: "country")
            } else {
                UserDefaults.standard.removeObject(forKey: "country")
            }
        }
    }
    
    @Published var homeRegion: String? {
        didSet {
            if let value = homeRegion {
                UserDefaults.standard.set(value, forKey: "homeRegion")
            } else {
                UserDefaults.standard.removeObject(forKey: "homeRegion")
            }
        }
    }
    
    @Published var districtCode: String? {
        didSet {
            if let value = districtCode {
                UserDefaults.standard.set(value, forKey: "districtCode")
            } else {
                UserDefaults.standard.removeObject(forKey: "districtCode")
            }
        }
    }
    
    @Published var rookieYear: Int? {
        didSet {
            if let value = rookieYear {
                UserDefaults.standard.set(value, forKey: "rookieYear")
            } else {
                UserDefaults.standard.removeObject(forKey: "rookieYear")
            }
        }
    }
    
    // Computed properties
    var displayLocation: String {
        var parts: [String] = []
        if let city = city { parts.append(city) }
        if let state = stateProv { parts.append(state) }
        if let country = country { parts.append(country) }
        return parts.isEmpty ? "Unknown" : parts.joined(separator: ", ")
    }
    
    var regionInfo: String {
        var parts: [String] = []
        if let region = homeRegion { parts.append("Region: \(region)") }
        if let district = districtCode { parts.append("District: \(district)") }
        return parts.isEmpty ? "No region info" : parts.joined(separator: " • ")
    }
    
    init() {
        // Load from UserDefaults or use defaults
        self.teamNumber = UserDefaults.standard.string(forKey: "teamNumber") ?? "18140"
        self.teamName = UserDefaults.standard.string(forKey: "teamName") ?? "Thunderbolts in Disguise"
        self.schoolName = UserDefaults.standard.string(forKey: "schoolName")
        self.city = UserDefaults.standard.string(forKey: "city")
        self.stateProv = UserDefaults.standard.string(forKey: "stateProv")
        self.country = UserDefaults.standard.string(forKey: "country")
        self.homeRegion = UserDefaults.standard.string(forKey: "homeRegion")
        self.districtCode = UserDefaults.standard.string(forKey: "districtCode")
        self.rookieYear = UserDefaults.standard.object(forKey: "rookieYear") as? Int
    }
    
    /// Update team settings from an FTCTeam object
    func updateFromTeam(_ team: FTCTeam) {
        self.teamNumber = String(team.teamNumber)
        self.teamName = team.displayName
        self.schoolName = team.schoolName
        self.city = team.city
        self.stateProv = team.stateProv
        self.country = team.country
        self.homeRegion = team.homeRegion
        self.districtCode = team.districtCode
        self.rookieYear = team.rookieYear
    }
}
