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
    
    var teamNumberString: String {
        displayTeamNumber ?? String(teamNumber)
    }
    
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
        return parts.isEmpty ? "No region info" : parts.joined(separator: " â€¢ ")
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
    static let shared = TeamSettings()
    
    @Published var teamNumber: String
    
    @Published var teamName: String
    
    // Additional team info
    @Published var schoolName: String?
    
    @Published var city: String?
    
    @Published var stateProv: String?
    
    @Published var country: String?
    
    @Published var homeRegion: String?
    
    @Published var districtCode: String?
    
    @Published var rookieYear: Int?
    
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
        // NOTE: This init is public to allow the singleton creation,
        // but you should ONLY use TeamSettings.shared, not create new instances
        self.teamNumber = UserDefaults.standard.string(forKey: "teamNumber") ?? "18140"
        self.teamName = UserDefaults.standard.string(forKey: "teamName") ?? "Thunderbolts in Disguise"
        self.schoolName = UserDefaults.standard.string(forKey: "schoolName")
        self.city = UserDefaults.standard.string(forKey: "city")
        self.stateProv = UserDefaults.standard.string(forKey: "stateProv")
        self.country = UserDefaults.standard.string(forKey: "country")
        self.homeRegion = UserDefaults.standard.string(forKey: "homeRegion")
        self.districtCode = UserDefaults.standard.string(forKey: "districtCode")
        self.rookieYear = UserDefaults.standard.object(forKey: "rookieYear") as? Int
        
        // Set up observers for UserDefaults saving
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe changes and save to UserDefaults
        $teamNumber.sink { UserDefaults.standard.set($0, forKey: "teamNumber") }.store(in: &cancellables)
        $teamName.sink { UserDefaults.standard.set($0, forKey: "teamName") }.store(in: &cancellables)
        $schoolName.sink { value in
            if let value = value {
                UserDefaults.standard.set(value, forKey: "schoolName")
            } else {
                UserDefaults.standard.removeObject(forKey: "schoolName")
            }
        }.store(in: &cancellables)
        $city.sink { value in
            if let value = value {
                UserDefaults.standard.set(value, forKey: "city")
            } else {
                UserDefaults.standard.removeObject(forKey: "city")
            }
        }.store(in: &cancellables)
        $stateProv.sink { value in
            if let value = value {
                UserDefaults.standard.set(value, forKey: "stateProv")
            } else {
                UserDefaults.standard.removeObject(forKey: "stateProv")
            }
        }.store(in: &cancellables)
        $country.sink { value in
            if let value = value {
                UserDefaults.standard.set(value, forKey: "country")
            } else {
                UserDefaults.standard.removeObject(forKey: "country")
            }
        }.store(in: &cancellables)
        $homeRegion.sink { value in
            if let value = value {
                UserDefaults.standard.set(value, forKey: "homeRegion")
            } else {
                UserDefaults.standard.removeObject(forKey: "homeRegion")
            }
        }.store(in: &cancellables)
        $districtCode.sink { value in
            if let value = value {
                UserDefaults.standard.set(value, forKey: "districtCode")
            } else {
                UserDefaults.standard.removeObject(forKey: "districtCode")
            }
        }.store(in: &cancellables)
        $rookieYear.sink { value in
            if let value = value {
                UserDefaults.standard.set(value, forKey: "rookieYear")
            } else {
                UserDefaults.standard.removeObject(forKey: "rookieYear")
            }
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
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
