//
//  EventAPIService.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//

import Foundation

// MARK: - API Service
class EventAPIService {
    static let shared = EventAPIService()
    
    private let baseURL = "https://ftc-api.firstinspires.org/v2.0"
    private let username: String
    private let authToken: String
    
    // Initialize with your credentials
    init(username: String = "taishar", authToken: String = "7986FA95-8A60-44FA-897B-ECA76084C77C") {
        self.username = username
        self.authToken = authToken
    }
    
    // MARK: - Generic API Request
    private func makeRequest<T: Decodable>(
        endpoint: String,
        parameters: [String: String] = [:]
    ) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)
        
        // Add query parameters if any
        if !parameters.isEmpty {
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header
        let credentials = "\(username):\(authToken)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - API Endpoints
    
    /// Get current season
    func getCurrentSeason() async throws -> SeasonResponse {
        try await makeRequest(endpoint: "/season")
    }
    
    /// Get events for a season
    func getEvents(season: Int) async throws -> EventsResponse {
        try await makeRequest(endpoint: "/\(season)/events")
    }
    
    /// Get specific event details
    func getEvent(season: Int, eventCode: String) async throws -> EventDetailResponse {
        try await makeRequest(endpoint: "/\(season)/events", parameters: ["eventCode": eventCode])
    }
    
    /// Get teams at an event
    func getTeamsAtEvent(season: Int, eventCode: String) async throws -> TeamsResponse {
        try await makeRequest(endpoint: "/\(season)/teams", parameters: ["eventCode": eventCode])
    }
    
    /// Get team details
    func getTeam(season: Int, teamNumber: Int) async throws -> TeamResponse {
        try await makeRequest(endpoint: "/\(season)/teams", parameters: ["teamNumber": "\(teamNumber)"])
    }
    
    /// Get match schedule for an event
    func getMatches(season: Int, eventCode: String) async throws -> MatchesResponse {
        try await makeRequest(endpoint: "/\(season)/schedule/\(eventCode)")
    }
    
    /// Get match results
    func getMatchResults(season: Int, eventCode: String) async throws -> MatchResultsResponse {
        try await makeRequest(endpoint: "/\(season)/scores/\(eventCode)/qual")
    }
    
    /// Get event rankings
    func getRankings(season: Int, eventCode: String) async throws -> RankingsResponse {
        try await makeRequest(endpoint: "/\(season)/rankings/\(eventCode)")
    }
    
    /// Get awards at an event
    func getAwards(season: Int, eventCode: String) async throws -> AwardsResponse {
        try await makeRequest(endpoint: "/\(season)/awards/\(eventCode)")
    }
}

// MARK: - Error Handling
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

// MARK: - Response Models (Add more as needed)
struct SeasonResponse: Codable {
    let season: Int
    let eventCount: Int?
}

struct EventsResponse: Codable {
    let events: [Event]
    let eventCount: Int
}

struct Event: Codable, Identifiable {
    let eventCode: String
    let name: String
    let dateStart: String
    let dateEnd: String
    let address: String?
    let city: String?
    let stateprov: String?
    let country: String?
    let website: String?
    
    var id: String { eventCode }
}

struct EventDetailResponse: Codable {
    let events: [Event]
}

struct TeamsResponse: Codable {
    let teams: [Team]
    let teamCountTotal: Int
}

struct Team: Codable, Identifiable {
    let teamNumber: Int
    let nameFull: String?
    let nameShort: String?
    let city: String?
    let stateProv: String?
    let country: String?
    let rookieYear: Int?
    let robotName: String?
    let schoolName: String?
    
    var id: Int { teamNumber }
}

struct TeamResponse: Codable {
    let teams: [Team]
}

struct MatchesResponse: Codable {
    let schedule: [Match]
}

struct Match: Codable, Identifiable {
    let tournamentLevel: String
    let matchNumber: Int
    let startTime: String?
    let teams: [MatchTeam]?
    
    var id: String { "\(tournamentLevel)-\(matchNumber)" }
}

struct MatchTeam: Codable {
    let teamNumber: Int
    let station: String
}

struct MatchResultsResponse: Codable {
    let matches: [MatchResult]
}

struct MatchResult: Codable {
    let matchNumber: Int
    let teams: [MatchResultTeam]?
}

struct MatchResultTeam: Codable {
    let teamNumber: Int
    let alliance: String
}

struct RankingsResponse: Codable {
    let rankings: [Ranking]
}

struct Ranking: Codable, Identifiable {
    let rank: Int
    let team: Int
    let wins: Int?
    let losses: Int?
    let ties: Int?
    
    var id: Int { team }
}

struct AwardsResponse: Codable {
    let awards: [Award]
}

struct Award: Codable, Identifiable {
    let awardId: Int
    let name: String
    let teamNumber: Int?
    let personName: String?
    
    var id: Int { awardId }
}

// MARK: - Usage Example
struct ExampleUsage {
    let api = EventAPIService.shared
    
    func fetchCurrentEvents() async {
        do {
            // Get current season
            let season = try await api.getCurrentSeason()
            print("Current season: \(season.season)")
            
            // Get all events
            let events = try await api.getEvents(season: season.season)
            print("Found \(events.eventCount) events")
            
            // Get specific event
            if let firstEvent = events.events.first {
                let teams = try await api.getTeamsAtEvent(
                    season: season.season,
                    eventCode: firstEvent.eventCode
                )
                print("Teams at event: \(teams.teamCountTotal)")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
