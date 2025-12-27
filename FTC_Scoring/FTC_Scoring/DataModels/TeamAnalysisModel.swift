//
//  TeamAnalysisModel.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 12/26/25.
//

import Foundation

// MARK: - Team Analysis Data Structures

struct TeamEventAnalysis {
    let teamNumber: Int
    let eventCode: String
    let matchCount: Int
    let wins: Int
    let losses: Int
    let ties: Int
    let avgAllianceScore: Double
    let avgOpponentScore: Double
    let partnerAnalyses: [PartnerAnalysis]
    
    var winRate: Double {
        let total = wins + losses + ties
        return total > 0 ? Double(wins) / Double(total) : 0.0
    }
    
    var record: String {
        "\(wins)-\(losses)-\(ties)"
    }
    
    var scoreDifferential: Double {
        avgAllianceScore - avgOpponentScore
    }
}

struct PartnerAnalysis {
    let teamNumber: Int
    let matchesWithTarget: Int
    let winsWithTarget: Int
    let lossesWithTarget: Int
    let tiesWithTarget: Int
    let avgScoreWithTarget: Double
    let matchesWithoutTarget: Int
    let winsWithoutTarget: Int
    let lossesWithoutTarget: Int
    let tiesWithoutTarget: Int
    let avgScoreWithoutTarget: Double
    
    var winRateWithTarget: Double {
        let total = winsWithTarget + lossesWithTarget + tiesWithTarget
        return total > 0 ? Double(winsWithTarget) / Double(total) : 0.0
    }
    
    var winRateWithoutTarget: Double {
        let total = winsWithoutTarget + lossesWithoutTarget + tiesWithoutTarget
        return total > 0 ? Double(winsWithoutTarget) / Double(total) : 0.0
    }
    
    var scoreDifferential: Double {
        avgScoreWithTarget - avgScoreWithoutTarget
    }
    
    var winRateDifferential: Double {
        winRateWithTarget - winRateWithoutTarget
    }
}

struct PartnerMatchData {
    var matchesWithTarget = 0
    var matchesWithoutTarget = 0
}

struct TeamAnalysis {
    let teamNumber: Int
    let eventCode: String
    let wins: Int
    let losses: Int
    let ties: Int
    let winRate: Double
    let averageScore: Double
    let averageOpponentScore: Double
    let scoreDifferential: Double
    
    // Partner analysis
    let averageScoreWithPartners: Double
    let averagePartnerContribution: Double
    let isCarrying: Bool // true if team scores significantly more than partners
    
    // Opponent analysis
    let averageOpponentQuality: Double // based on opponent win rates
    let winsAgainstStrongOpponents: Int // opponents with >50% win rate
    let winsAgainstWeakOpponents: Int // opponents with <50% win rate
    
    var teamNumberString: String {
        "\(teamNumber)"
    }
    
    var insights: [String] {
        var results: [String] = []
        
        // Win rate insight
        if winRate >= 0.7 {
            results.append("🔥 Dominant performance with \(String(format: "%.0f", winRate * 100))% win rate")
        } else if winRate >= 0.5 {
            results.append("✅ Solid performance with \(String(format: "%.0f", winRate * 100))% win rate")
        } else if winRate >= 0.3 {
            results.append("⚠️ Struggling with \(String(format: "%.0f", winRate * 100))% win rate")
        } else {
            results.append("❌ Difficult event with \(String(format: "%.0f", winRate * 100))% win rate")
        }
        
        // Carrying analysis
        if isCarrying {
            results.append("💪 Carrying alliance partners (scoring \(String(format: "%.0f", averageScore - averagePartnerContribution)) more points than partners)")
        } else if averagePartnerContribution > averageScore + 10 {
            results.append("🤝 Being carried by strong partners (partners score \(String(format: "%.0f", averagePartnerContribution - averageScore)) more points)")
        } else {
            results.append("⚖️ Balanced alliance partnerships")
        }
        
        // Opponent quality analysis
        if averageOpponentQuality > 0.6 {
            results.append("🎯 Facing tough competition (opponents avg \(String(format: "%.0f", averageOpponentQuality * 100))% win rate)")
        } else if averageOpponentQuality < 0.4 {
            results.append("📉 Facing weaker competition (opponents avg \(String(format: "%.0f", averageOpponentQuality * 100))% win rate)")
        }
        
        // Win distribution
        if winsAgainstStrongOpponents > winsAgainstWeakOpponents && wins > 0 {
            results.append("🏆 Winning against strong opponents (\(winsAgainstStrongOpponents) vs tough teams)")
        } else if winsAgainstWeakOpponents > 0 && winsAgainstStrongOpponents == 0 {
            results.append("⚡ Winning mainly against weaker opponents")
        }
        
        // Score differential
        if scoreDifferential > 20 {
            results.append("📊 Outscoring opponents by \(String(format: "%.0f", scoreDifferential)) points on average")
        } else if scoreDifferential < -20 {
            results.append("📉 Being outscored by \(String(format: "%.0f", abs(scoreDifferential))) points on average")
        }
        
        return results
    }
}

struct AnalysisMatchData {
    let matchNumber: Int
    let won: Bool
    let teamScore: Int
    let opponentScore: Int
    let partnerScore: Int
    let opponentWinRate: Double
}

struct EventRankingsModel: Codable {
    let rankings: [TeamRankingModel]?
}

struct TeamRankingModel: Codable {
    let rank: Int
    let teamNumber: Int
    let wins: Int
    let losses: Int
    let ties: Int
}
