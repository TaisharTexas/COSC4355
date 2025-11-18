//
//  MatchRecod.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import Foundation
import Combine

/**
 this is how I plan on keeping match records that are recorded locally...
 not sure if it will map directly to the api match data or not, may need to make a converter so that local matches and api matches can be both used for analysis
 */

enum MatchType: String, Codable {
    case practice = "Practice"
    case custom = "Custom"
}

struct MatchRecord: Codable, Identifiable{
    var id = UUID()
    let teamNumber: String
    let matchNumber: Int
    let session: String
    let timestamp: Date
    let matchType: MatchType
    let autoPhase: AutoData
    let teleopPhase: TeleData
    let endgamePhase: EndgameData
    let selectedMotif: Int
    
    // Computed properties for scoring
    var totalScore: Int {
        return autoPhase.score + teleopPhase.score + endgamePhase.score
    }
    
    // Computed properties for ranking points
    var movementPoints: Int {
        var points = 0
        
        // Auto movement: 3 points per robot that left
        if autoPhase.robot1Leave { points += 3 }
        if autoPhase.robot2Leave { points += 3 }
        
        // Endgame base scoring
        for baseState in endgamePhase.robotBaseState {
            switch baseState {
            case .partial:
                points += 5
            case .full:
                points += 10
            case .none:
                break
            }
        }
        
        return points
    }
    
    var goalPoints: Int {
        // Auto artifacts
        let autoArtifacts = autoPhase.overflowArtifactsAuto + autoPhase.classifiedArtifactsAuto
        
        // Tele artifacts
        let teleArtifacts = teleopPhase.depotArtifactsTele +
                           teleopPhase.overflowArtifactsTele +
                           teleopPhase.classifiedArtifactsTele
        
        return autoArtifacts + teleArtifacts
    }
    
    var patternPoints: Int {
        var points = 0
        
        // Define the pattern based on motif (1=GPP, 2=PGP, 3=PPG)
        let pattern: [MatchData.GateState]
        switch selectedMotif {
        case 1: // GPP
            pattern = [.green, .purple, .purple]
        case 2: // PGP
            pattern = [.purple, .green, .purple]
        case 3: // PPG
            pattern = [.purple, .purple, .green]
        default:
            pattern = [.purple, .purple, .green]
        }
        
        // Check each position in the pattern (0, 1, 2)
        for position in 0..<3 {
            let expectedColor = pattern[position]
            
            // Check gates at this position (position, position+3, position+6)
            for gateGroup in 0..<3 {
                let gateIndex = position + (gateGroup * 3)
                
                // Score auto and tele separately - 2 points each if correct
                let autoState = autoPhase.gateStates[gateIndex]
                let teleState = teleopPhase.gateStates[gateIndex]
                
                if autoState == expectedColor {
                    points += 2
                }
                if teleState == expectedColor {
                    points += 2
                }
            }
        }
        
        return points
    }
    
    var movementRP: Bool {
        return movementPoints >= 16
    }
    
    
    var goalRP: Bool {
        return goalPoints >= 36
    }
    
    var patternRP: Bool {
        return patternPoints >= 18
    }
    
    var totalRankingPoints: Int {
        var total = 0
        if movementRP { total += 1 }
        if goalRP { total += 1 }
        if patternRP { total += 1 }
        return total
    }
}

class MatchData: ObservableObject{
    //AUTO
    @Published var overflowArtifactsAuto = 0
    @Published var classifiedArtifactsAuto = 0
    @Published var robot1Leave = false
    @Published var robot2Leave = false
    @Published var gateStatesAuto: [GateState] = Array(repeating: .none, count: 9)
    @Published var selectedMotif = 1
    //TELE
    @Published var gateStatesTele: [GateState] = Array(repeating: .none, count: 9)
    @Published var depotArtifactsTele = 0
    @Published var overflowArtifactsTele = 0
    @Published var classifiedArtifactsTele = 0
    //ENDGAME
    @Published var robotBaseState: [BaseState] = Array(repeating: .none, count: 2)
    
    enum GateState: Codable {
        case green, purple, none
    }
    
    enum BaseState: Codable{
        case partial, full, none
    }
    
    func createMatchRecord(teamNumber: String, matchNumber: Int, session: String, matchType: MatchType) -> MatchRecord {
        return MatchRecord(
            teamNumber: teamNumber,
            matchNumber: matchNumber,
            session: session,
            timestamp: Date(),
            matchType: matchType,
            autoPhase: AutoData(
                overflowArtifactsAuto: overflowArtifactsAuto,
                classifiedArtifactsAuto: classifiedArtifactsAuto,
                robot1Leave: robot1Leave,
                robot2Leave: robot2Leave,
                gateStates: gateStatesAuto
            ),
            teleopPhase: TeleData(
                gateStates: gateStatesTele,
                depotArtifactsTele: depotArtifactsTele,
                overflowArtifactsTele: overflowArtifactsTele,
                classifiedArtifactsTele: classifiedArtifactsTele
            ),
            endgamePhase: EndgameData(
                robotBaseState: robotBaseState
            ),
            selectedMotif: selectedMotif
        )
    }
    
    func reset() {
        overflowArtifactsAuto = 0
        classifiedArtifactsAuto = 0
        depotArtifactsTele = 0
        overflowArtifactsTele = 0
        classifiedArtifactsTele = 0
        robot1Leave = false
        robot2Leave = false
        gateStatesAuto = Array(repeating: .none, count: 9)
        gateStatesTele = Array(repeating: .none, count: 9)
        robotBaseState = Array(repeating: .none, count: 2)
    }
}

struct AutoData: Codable {
    let overflowArtifactsAuto: Int
    let classifiedArtifactsAuto: Int
    let robot1Leave: Bool
    let robot2Leave: Bool
    let gateStates: [MatchData.GateState]
    
    var score: Int {
        return (overflowArtifactsAuto * 1) + (classifiedArtifactsAuto * 3) +
               (robot1Leave ? 3 : 0) + (robot2Leave ? 3 : 0)
    }
}

struct TeleData: Codable {
    let gateStates: [MatchData.GateState]
    let depotArtifactsTele: Int
    let overflowArtifactsTele: Int
    let classifiedArtifactsTele: Int
    
    var score: Int {
        let greenCount = gateStates.filter { $0 == .green }.count
        let purpleCount = gateStates.filter { $0 == .purple }.count
        return (depotArtifactsTele) + (overflowArtifactsTele) + (classifiedArtifactsTele * 3)
    }
}

struct EndgameData: Codable {
    let robotBaseState: [MatchData.BaseState]
    
    var score: Int {
        let partialCount = robotBaseState.filter { $0 == .partial}.count
        let fullCount = robotBaseState.filter { $0 == .full}.count
        return (partialCount * 3) + (fullCount * 6)
    }
}
