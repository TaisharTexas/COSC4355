//
//  MatchRecod.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/24/25.
//

import Foundation
import Combine

struct MatchRecord: Codable, Identifiable{
    let id = UUID()
    let teamNumber: String
    let matchNumber: Int
    let session: String
    let timestamp: Date
    let autoPhase: AutoData
    let teleopPhase: TeleData
    let endgamePhase: EndgameData
    
    // Computed properties for scoring
    var totalScore: Int {
        return autoPhase.score + teleopPhase.score + endgamePhase.score
    }
}

class MatchData: ObservableObject{
    //AUTO
    @Published var overflowArtifacts = 1
    @Published var classifiedArtifacts = 0
    @Published var robot1Leave = true
    @Published var robot2Leave = false
    @Published var gateStatesAuto: [GateState] = Array(repeating: .none, count: 8)
    //TELE
    @Published var gateStatesTele: [GateState] = Array(repeating: .none, count: 8)
    @Published var depotArtifacts = 0
    //ENDGAME
    @Published var robotBaseState: [BaseState] = Array(repeating: .none, count: 2)
    
    enum GateState: Codable {
        case green, purple, none
    }
    
    enum BaseState: Codable{
        case partial, full, none
    }
    
    func createMatchRecord(teamNumber: String, matchNumber: Int, session: String) -> MatchRecord {
        return MatchRecord(
            teamNumber: teamNumber,
            matchNumber: matchNumber,
            session: session,
            timestamp: Date(),
            autoPhase: AutoData(
                overflowArtifacts: overflowArtifacts,
                classifiedArtifacts: classifiedArtifacts,
                robot1Leave: robot1Leave,
                robot2Leave: robot2Leave,
                gateStates: gateStatesAuto
            ),
            teleopPhase: TeleData(
                gateStates: gateStatesTele,
                depotArtifacts: depotArtifacts
            ),
            endgamePhase: EndgameData(
                robotBaseState: robotBaseState
            )
        )
    }
    
    func reset() {
        overflowArtifacts = 0
        classifiedArtifacts = 0
        depotArtifacts = 0
        robot1Leave = false
        robot2Leave = false
        gateStatesAuto = Array(repeating: .none, count: 8)
        gateStatesTele = Array(repeating: .none, count: 8)
        robotBaseState = Array(repeating: .none, count: 2)
    }
}

struct AutoData: Codable {
    let overflowArtifacts: Int
    let classifiedArtifacts: Int
    let robot1Leave: Bool
    let robot2Leave: Bool
    let gateStates: [MatchData.GateState]
    
    var score: Int {
        return (overflowArtifacts * 5) + (classifiedArtifacts * 10) +
               (robot1Leave ? 5 : 0) + (robot2Leave ? 5 : 0)
    }
}

struct TeleData: Codable {
    let gateStates: [MatchData.GateState]
    let depotArtifacts: Int
    
    var score: Int {
        let greenCount = gateStates.filter { $0 == .green }.count
        let purpleCount = gateStates.filter { $0 == .purple }.count
        return (greenCount * 3) + (purpleCount * 5) + (depotArtifacts * 5)
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


