//
//  EventAPIService.swift
//  FTC_Scoring
//
//  Created by Andrew Lee on 10/9/25.
//
import Combine
import Foundation

// MARK: - Data Models

struct EventListingsResponse: Codable {
    let events: [FTCEvent]
    let eventCount: Int
}

struct FTCEvent: Codable, Identifiable {
    let eventId: UUID
    let code: String?
    let divisionCode: String?
    let name: String?
    let remote: Bool
    let hybrid: Bool
    let fieldCount: Int
    let published: Bool
    let type: String?
    let typeName: String?
    let regionCode: String?
    let leagueCode: String?
    let districtCode: String?
    let venue: String?
    let address: String?
    let city: String?
    let stateprov: String?
    let country: String?
    let website: String?
    let liveStreamUrl: String?
    let coordinates: Coordinates?
    let webcasts: [String]?
    let timezone: String?
    let dateStart: Date
    let dateEnd: Date
    
    var id: UUID { eventId }
    
    // Computed property for display
    var displayName: String {
        name ?? "Unknown Event"
    }
    
    var displayLocation: String {
        var parts: [String] = []
        if let city = city { parts.append(city) }
        if let state = stateprov { parts.append(state) }
        if let country = country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
    
    var isInProgress: Bool {
        let now = Date()
        return now >= dateStart && now <= dateEnd
    }
    
    var isPast: Bool {
        Date() > dateEnd
    }
    
    var isFuture: Bool {
        Date() < dateStart
    }
}

struct Coordinates: Codable {
    let type: String?
    let coordinates: [Double]?
    
    var latitude: Double? {
        // GeoJSON format is [longitude, latitude]
        guard let coords = coordinates, coords.count >= 2 else { return nil }
        return coords[1]
    }
    
    var longitude: Double? {
        // GeoJSON format is [longitude, latitude]
        guard let coords = coordinates, coords.count >= 2 else { return nil }
        return coords[0]
    }
}

// MARK: - Match/Schedule Models

struct ScheduleResponse: Codable {
    let schedule: [ScheduledMatch]
}

struct ScheduledMatch: Codable, Identifiable {
    let description: String?
    let field: String?
    let tournamentLevel: String?
    let startTime: String?  // Keep as String to avoid date parsing issues
    let series: Int?
    let matchNumber: Int
    let teams: [ScheduledMatchTeam]?
    let modifiedOn: String?  // Keep as String
    
    var id: Int { matchNumber }
    
    var displayDescription: String {
        description ?? "Match \(matchNumber)"
    }
    
    var displayTournamentLevel: String {
        switch tournamentLevel?.uppercased() {
        case "QUAL", "QUALIFICATION":
            return "Qualification"
        case "PLAYOFF", "PLAYOFFS":
            return "Playoff"
        default:
            return tournamentLevel ?? "Unknown"
        }
    }
    
    var parsedStartTime: Date? {
        guard let startTime = startTime else { return nil }
        
        // Try multiple date formats
        let formatters = [
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm"
        ]
        
        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = formatter.date(from: startTime) {
                return date
            }
        }
        
        return nil
    }
}

struct ScheduledMatchTeam: Codable, Identifiable {
    let teamNumber: Int?
    let displayTeamNumber: String?
    let station: String?
    let team: String?
    let teamName: String?
    let surrogate: Bool
    let noShow: Bool
    
    var id: String {
        "\(teamNumber ?? 0)-\(station ?? "unknown")"
    }
    
    var displayNumber: String {
        displayTeamNumber ?? "\(teamNumber ?? 0)"
    }
    
    var alliance: String {
        guard let station = station else { return "Unknown" }
        if station.lowercased().contains("red") {
            return "Red"
        } else if station.lowercased().contains("blue") {
            return "Blue"
        }
        return "Unknown"
    }
}

// MARK: - Match Score Models

struct MatchScoresResponse: Codable {
    let matchScores: [MatchScore]
}

struct MatchScore: Codable, Identifiable {
    let matchLevel: String?
    let matchSeries: Int?
    let matchNumber: Int
    let randomization: Int?
    let alliances: [AllianceScore]?
    
    var id: Int { matchNumber }
}

struct AllianceScore: Codable, Identifiable {
    // Auto scoring
    let autoClassifiedArtifacts: Int?
    let autoOverflowArtifacts: Int?
    let autoClassifierState: [String]?
    let robot1Auto: Bool?
    let robot2Auto: Bool?
    let autoLeavePoints: Int?
    let autoArtifactPoints: Int?
    let autoPatternPoints: Int?
    
    // Teleop scoring
    let teleopClassifiedArtifacts: Int?
    let teleopOverflowArtifacts: Int?
    let teleopDepotArtifacts: Int?
    let teleopClassifierState: [String]?
    let robot1Teleop: String?
    let robot2Teleop: String?
    let teleopArtifactPoints: Int?
    let teleopDepotPoints: Int?
    let teleopPatternPoints: Int?
    let teleopBasePoints: Int?
    
    // Totals
    let autoPoints: Int?
    let teleopPoints: Int?
    let foulPointsCommitted: Int?
    let preFoulTotal: Int?
    
    // Ranking Points
    let movementRP: Bool?
    let goalRP: Bool?
    let patternRP: Bool?
    
    // Final Score
    let totalPoints: Int?
    let majorFouls: Int?
    let minorFouls: Int?
    
    // Alliance info
    let alliance: String?
    let team: Int?
    
    var id: String {
        "\(alliance ?? "unknown")-\(team ?? 0)"
    }
    
    var isRedAlliance: Bool {
        alliance?.lowercased() == "red"
    }
    
    var isBlueAlliance: Bool {
        alliance?.lowercased() == "blue"
    }
}

// MARK: - API Service

class EventAPIService: ObservableObject {
    private let baseURL = "https://ftc-api.firstinspires.org/v2.0"
    private let username: String
    private let authToken: String
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Cache for team match data to avoid redundant API calls
    // Key format: "season-eventCode-tournamentLevel-teamNumber"
    private var teamMatchCache: [String: [ScheduledMatch]] = [:]
    private var teamScoreCache: [String: [MatchScore]] = [:]
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // The API returns dates without timezone indicator (e.g., "2024-12-07T00:00:00")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    // Initialize with your credentials
    init(username: String = "taishar", authToken: String = "7986FA95-8A60-44FA-897B-ECA76084C77C") {
        self.username = username
        self.authToken = authToken
    }
    
    // MARK: - Authentication
    
    private func createAuthHeader() -> String {
        let credentials = "\(username):\(authToken)"
        let credentialsData = credentials.data(using: .utf8)!
        return "Basic " + credentialsData.base64EncodedString()
    }
    
    // MARK: - Generic API Request
    
    private func makeRequest(endpoint: String) async throws -> Data {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue(createAuthHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }
        
        return data
    }
    
    // Public version for debugging
    func makeRequestPublic(endpoint: String) async throws -> Data {
        return try await makeRequest(endpoint: endpoint)
    }
    
    // MARK: - Event Endpoints (Structured)
    
    /// Fetch all events for a specific season
    func fetchEvents(season: Int) async throws -> [FTCEvent] {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let data = try await makeRequest(endpoint: "/\(season)/events")
            let response = try decoder.decode(EventListingsResponse.self, from: data)
            return response.events
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching events: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    /// Fetch a specific event by code
    func fetchEvent(season: Int, eventCode: String) async throws -> FTCEvent {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let data = try await makeRequest(endpoint: "/\(season)/events?eventCode=\(eventCode)")
            let response = try decoder.decode(EventListingsResponse.self, from: data)
            guard let event = response.events.first else {
                throw NSError(domain: "EventAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Event not found"])
            }
            return event
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching event: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    /// Fetch events for a team
    func fetchEventsForTeam(season: Int, teamNumber: Int) async throws -> [FTCEvent] {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let data = try await makeRequest(endpoint: "/\(season)/events?teamNumber=\(teamNumber)")
            let response = try decoder.decode(EventListingsResponse.self, from: data)
            return response.events
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching team events: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    /// Fetch events within a date range
    func fetchEventsInDateRange(season: Int, startDate: Date, endDate: Date) async throws -> [FTCEvent] {
        let allEvents = try await fetchEvents(season: season)
        
        // Filter events by date range
        return allEvents.filter { event in
            event.dateStart >= startDate && event.dateEnd <= endDate
        }
    }//: end fetchEventsInDateRange func
    
    
    /// Fetch matches for a team at a specific event
    func fetchMatchesForTeam(season: Int, eventCode: String, teamNumber: Int, tournamentLevel: String = "qual") async throws -> [ScheduledMatch] {
        // Check cache first
        let cacheKey = "\(season)-\(eventCode)-\(tournamentLevel)-\(teamNumber)"
        if let cachedMatches = teamMatchCache[cacheKey] {
            print("Using cached matches for team \(teamNumber)")
            return cachedMatches
        }
        
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let endpoint = "/\(season)/schedule/\(eventCode)?tournamentLevel=\(tournamentLevel)&teamNumber=\(teamNumber)"
            let data = try await makeRequest(endpoint: endpoint)
            let response = try decoder.decode(ScheduleResponse.self, from: data)
            
            // Cache the results
            await MainActor.run {
                teamMatchCache[cacheKey] = response.schedule
            }
            
            return response.schedule
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching matches: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchMatchesForTeam func
    
    /// Fetch all matches at a specific event
    func fetchMatchesForEvent(season: Int, eventCode: String, tournamentLevel: String = "qual") async throws -> [ScheduledMatch] {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let endpoint = "/\(season)/schedule/\(eventCode)?tournamentLevel=\(tournamentLevel)"
            let data = try await makeRequest(endpoint: endpoint)
            let response = try decoder.decode(ScheduleResponse.self, from: data)
            return response.schedule
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching matches: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchMatchesForEvent func
    
    // MARK: - Score Endpoints
    
    /// Fetch score for a specific match
    func fetchMatchScore(season: Int, eventCode: String, tournamentLevel: String, matchNumber: Int) async throws -> MatchScore {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let endpoint = "/\(season)/scores/\(eventCode)/\(tournamentLevel)?matchNumber=\(matchNumber)"
            let data = try await makeRequest(endpoint: endpoint)
            let response = try decoder.decode(MatchScoresResponse.self, from: data)
            guard let score = response.matchScores.first else {
                throw NSError(domain: "EventAPI", code: 404, userInfo: [NSLocalizedDescriptionKey: "Score not found"])
            }
            return score
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching score: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchMatchScore func
    
    /// Fetch all scores for a team at an event
    func fetchScoresForTeam(season: Int, eventCode: String, tournamentLevel: String, teamNumber: Int) async throws -> [MatchScore] {
        // Check cache first
        let cacheKey = "\(season)-\(eventCode)-\(tournamentLevel)-\(teamNumber)-scores"
        if let cachedScores = teamScoreCache[cacheKey] {
            print("Using cached scores for team \(teamNumber)")
            return cachedScores
        }
        
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let endpoint = "/\(season)/scores/\(eventCode)/\(tournamentLevel)?teamNumber=\(teamNumber)"
            let data = try await makeRequest(endpoint: endpoint)
            let response = try decoder.decode(MatchScoresResponse.self, from: data)
            
            // Cache the results
            await MainActor.run {
                teamScoreCache[cacheKey] = response.matchScores
            }
            
            return response.matchScores
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching scores: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchScoresForTeam func
    
    /// Fetch raw score JSON for debugging
    func fetchRawScore(season: Int, eventCode: String, tournamentLevel: String, matchNumber: Int) async throws -> String {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let endpoint = "/\(season)/scores/\(eventCode)/\(tournamentLevel)?matchNumber=\(matchNumber)"
            let data = try await makeRequest(endpoint: endpoint)
            return String(data: data, encoding: .utf8) ?? "Unable to decode response"
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching score: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchRawScore func
    
    // MARK: - Scores Endpoints
    
    /// Fetch match scores (raw JSON) - formats vary by year, so return as string
    func fetchMatchScores(season: Int, eventCode: String, tournamentLevel: String = "qual", teamNumber: Int? = nil, matchNumber: Int? = nil) async throws -> String {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            var endpoint = "/\(season)/scores/\(eventCode)/\(tournamentLevel)"
            var queryParams: [String] = []
            
            if let teamNumber = teamNumber {
                queryParams.append("teamNumber=\(teamNumber)")
            }
            
            if let matchNumber = matchNumber {
                queryParams.append("matchNumber=\(matchNumber)")
            }
            
            if !queryParams.isEmpty {
                endpoint += "?" + queryParams.joined(separator: "&")
            }
            
            let data = try await makeRequest(endpoint: endpoint)
            return String(data: data, encoding: .utf8) ?? "Unable to decode response"
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching scores: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchMatchScores func
    
    // MARK: - Raw Response Methods (for debugging)
    
    /// Fetch raw JSON response as string
    func fetchRawEvents(season: Int) async throws -> String {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let data = try await makeRequest(endpoint: "/\(season)/events")
            return String(data: data, encoding: .utf8) ?? "Unable to decode response"
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching events: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchRawEvents func
    
    /// Test the API connection with a lightweight response
    func testConnection() async throws -> String {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let data = try await makeRequest(endpoint: "/2024/events")
            
            // First, let's see what we actually got
            let rawString = String(data: data, encoding: .utf8) ?? "Unable to decode as UTF8"
            
            // Try to decode
            do {
                let response = try decoder.decode(EventListingsResponse.self, from: data)
                
                // Return a summary if successful
                var summary = "Connection Successful!\n\n"
                summary += "API Response Summary:\n"
                summary += "- Total Events: \(response.eventCount)\n"
                summary += "- Events Loaded: \(response.events.count)\n\n"
                
                if let firstEvent = response.events.first {
                    summary += "Sample Event:\n"
                    summary += "- Name: \(firstEvent.displayName)\n"
                    summary += "- Location: \(firstEvent.displayLocation)\n"
                    summary += "- Code: \(firstEvent.code ?? "N/A")\n"
                    summary += "- Type: \(firstEvent.typeName ?? "N/A")\n"
                }
                
                summary += "Switch to 'Structured' view to see all events"
                
                return summary
            } catch {
                // If decoding fails, show us the raw response (first 2000 chars)
                let preview = String(rawString.prefix(2000))
                return """
                Connection succeeded but decoding failed
                
                Error: \(error.localizedDescription)
                
                Raw Response Preview (first 2000 chars):
                \(preview)
                
                This will help debug what format the API is actually returning.
                """
            }
        } catch {
            await MainActor.run {
                errorMessage = "Connection test failed: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end textConnection func
    
    /// Get a single event as raw JSON (lighter than all events)
    func fetchRawEvent(season: Int, eventCode: String) async throws -> String {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        do {
            let data = try await makeRequest(endpoint: "/\(season)/events?eventCode=\(eventCode)")
            return String(data: data, encoding: .utf8) ?? "Unable to decode response"
        } catch {
            await MainActor.run {
                errorMessage = "Error fetching event: \(error.localizedDescription)"
            }
            throw error
        }
    }//: end fetchRawEvent func
    
    
    // MARK: - Match Record Conversion
        
    /// Convert an AllianceScore from the API into a MatchRecord for local storage
    /// - Parameters:
    ///   - allianceScore: The alliance score data from the API
    ///   - matchNumber: The match number this score is from
    ///   - teamNumber: The team number to save this match for
    ///   - session: The session name (e.g., event code or custom session name)
    ///   - motif: The selected motif/pattern (1=GPP, 2=PGP, 3=PPG) - defaults to 1
    /// - Returns: A MatchRecord that can be saved locally
    func convertToMatchRecord(
        allianceScore: AllianceScore,
        matchNumber: Int,
        teamNumber: String,
        session: String,
        motif: Int = 1
    ) -> MatchRecord {
        // Convert classifier state strings to GateState enum
        func parseGateStates(_ states: [String]?) -> [MatchData.GateState] {
            guard let states = states else {
                return Array(repeating: .none, count: 9)
            }
            
            return states.prefix(9).map { state in
                switch state.lowercased() {
                case "green":
                    return .green
                case "purple":
                    return .purple
                default:
                    return .none
                }
            } + Array(repeating: .none, count: max(0, 9 - states.count))
        }
        
        // Parse robot base states from teleop strings
        func parseBaseStates(_ robot1: String?, _ robot2: String?) -> [MatchData.BaseState] {
            let parseState = { (state: String?) -> MatchData.BaseState in
                guard let state = state else { return .none }
                switch state.lowercased() {
                case "partial", "partiallyascended":
                    return .partial
                case "full", "fullyascended":
                    return .full
                default:
                    return .none
                }
            }
            
            return [parseState(robot1), parseState(robot2)]
        }
        
        // Create AutoData from alliance score
        let autoData = AutoData(
            overflowArtifactsAuto: allianceScore.autoOverflowArtifacts ?? 0,
            classifiedArtifactsAuto: allianceScore.autoClassifiedArtifacts ?? 0,
            robot1Leave: allianceScore.robot1Auto ?? false,
            robot2Leave: allianceScore.robot2Auto ?? false,
            gateStates: parseGateStates(allianceScore.autoClassifierState)
        )
        
        // Create TeleData from alliance score
        let teleData = TeleData(
            gateStates: parseGateStates(allianceScore.teleopClassifierState),
            depotArtifactsTele: allianceScore.teleopDepotArtifacts ?? 0,
            overflowArtifactsTele: allianceScore.teleopOverflowArtifacts ?? 0,
            classifiedArtifactsTele: allianceScore.teleopClassifiedArtifacts ?? 0
        )
        
        // Create EndgameData from alliance score
        let endgameData = EndgameData(
            robotBaseState: parseBaseStates(
                allianceScore.robot1Teleop,
                allianceScore.robot2Teleop
            )
        )
        
        // Determine match side from alliance
        let matchSide: MatchSide = allianceScore.isRedAlliance ? .red : .blue
        
        // Create and return the match record
        return MatchRecord(
            teamNumber: teamNumber,
            matchNumber: matchNumber,
            session: session,
            timestamp: Date(),
            matchType: .practice, // API matches are typically practice/qualification
            matchSide: matchSide,
            autoPhase: autoData,
            teleopPhase: teleData,
            endgamePhase: endgameData,
            selectedMotif: motif,
            isIncluded: true // API matches are included by default
        )
    }
    
    // MARK: - Team Performance Analysis
    
    /// Analyze a team's performance at an event by comparing with alliance partners
    func analyzeTeamPerformance(season: Int, eventCode: String, teamNumber: Int) async throws -> TeamEventAnalysis {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }
        
        // Fetch target team's matches for both qual and playoff
        let qualMatches = try await fetchMatchesForTeam(season: season, eventCode: eventCode, teamNumber: teamNumber, tournamentLevel: "qual")
        let playoffMatches = try await fetchMatchesForTeam(season: season, eventCode: eventCode, teamNumber: teamNumber, tournamentLevel: "playoff")
        let allTargetMatches = qualMatches + playoffMatches
        
        // Fetch scores for all target team matches
        let qualScores = try await fetchScoresForTeam(season: season, eventCode: eventCode, tournamentLevel: "qual", teamNumber: teamNumber)
        let playoffScores = try await fetchScoresForTeam(season: season, eventCode: eventCode, tournamentLevel: "playoff", teamNumber: teamNumber)
        let allTargetScores = qualScores + playoffScores
        
        // Calculate target team's stats
        var wins = 0
        var losses = 0
        var ties = 0
        var totalAllianceScore = 0
        var totalOpponentScore = 0
        var matchCount = 0
        
        // Track partners
        var partnerTeamNumbers: Set<Int> = []
        var partnerMatchData: [Int: PartnerMatchData] = [:] // teamNumber -> data
        
        for match in allTargetMatches {
            guard let teams = match.teams else { continue }
            
            // Find which alliance the target team is on
            guard let targetTeam = teams.first(where: { $0.teamNumber == teamNumber }) else { continue }
            let targetAlliance = targetTeam.alliance
            
            // Find partner
            let partners = teams.filter { $0.alliance == targetAlliance && $0.teamNumber != teamNumber }
            for partner in partners {
                if let partnerNum = partner.teamNumber {
                    partnerTeamNumbers.insert(partnerNum)
                }
            }
        }
        
        // Analyze each score
        for score in allTargetScores {
            guard let alliances = score.alliances, alliances.count == 2 else { continue }
            
            // Find target team's alliance
            let targetAlliance = alliances.first { alliance in
                // Check if this alliance contains our team by checking the teams in the corresponding match
                if let match = allTargetMatches.first(where: { $0.matchNumber == score.matchNumber }),
                   let teams = match.teams {
                    let allianceTeams = teams.filter { $0.alliance == alliance.alliance }
                    return allianceTeams.contains { $0.teamNumber == teamNumber }
                }
                return false
            }
            
            let opponentAlliance = alliances.first { $0.alliance != targetAlliance?.alliance }
            
            guard let targetScore = targetAlliance?.totalPoints,
                  let opponentScore = opponentAlliance?.totalPoints else { continue }
            
            matchCount += 1
            totalAllianceScore += targetScore
            totalOpponentScore += opponentScore
            
            if targetScore > opponentScore {
                wins += 1
            } else if targetScore < opponentScore {
                losses += 1
            } else {
                ties += 1
            }
        }
        
        // Now fetch data for each partner
        var partnerAnalyses: [PartnerAnalysis] = []
        
        for partnerNumber in partnerTeamNumbers {
            do {
                // Fetch partner's matches (all matches, not just with target team)
                let partnerQualMatches = try await fetchMatchesForTeam(season: season, eventCode: eventCode, teamNumber: partnerNumber, tournamentLevel: "qual")
                let partnerPlayoffMatches = try await fetchMatchesForTeam(season: season, eventCode: eventCode, teamNumber: partnerNumber, tournamentLevel: "playoff")
                let partnerAllMatches = partnerQualMatches + partnerPlayoffMatches
                
                // Fetch partner's scores
                let partnerQualScores = try await fetchScoresForTeam(season: season, eventCode: eventCode, tournamentLevel: "qual", teamNumber: partnerNumber)
                let partnerPlayoffScores = try await fetchScoresForTeam(season: season, eventCode: eventCode, tournamentLevel: "playoff", teamNumber: partnerNumber)
                let partnerAllScores = partnerQualScores + partnerPlayoffScores
                
                // Calculate stats with and without target team
                var withTargetWins = 0, withTargetLosses = 0, withTargetTies = 0
                var withTargetScore = 0, withTargetMatches = 0
                var withoutTargetWins = 0, withoutTargetLosses = 0, withoutTargetTies = 0
                var withoutTargetScore = 0, withoutTargetMatches = 0
                
                for score in partnerAllScores {
                    guard let alliances = score.alliances, alliances.count == 2 else { continue }
                    
                    // Find if target team is in this match
                    let match = partnerAllMatches.first { $0.matchNumber == score.matchNumber }
                    let hasTargetTeam = match?.teams?.contains { $0.teamNumber == teamNumber } ?? false
                    
                    // Find partner's alliance
                    let partnerAlliance = alliances.first { alliance in
                        if let matchData = match, let teams = matchData.teams {
                            let allianceTeams = teams.filter { $0.alliance == alliance.alliance }
                            return allianceTeams.contains { $0.teamNumber == partnerNumber }
                        }
                        return false
                    }
                    
                    let opponentAlliance = alliances.first { $0.alliance != partnerAlliance?.alliance }
                    
                    guard let partnerScore = partnerAlliance?.totalPoints,
                          let oppScore = opponentAlliance?.totalPoints else { continue }
                    
                    let won = partnerScore > oppScore
                    let lost = partnerScore < oppScore
                    let tied = partnerScore == oppScore
                    
                    if hasTargetTeam {
                        withTargetMatches += 1
                        withTargetScore += partnerScore
                        if won { withTargetWins += 1 }
                        if lost { withTargetLosses += 1 }
                        if tied { withTargetTies += 1 }
                    } else {
                        withoutTargetMatches += 1
                        withoutTargetScore += partnerScore
                        if won { withoutTargetWins += 1 }
                        if lost { withoutTargetLosses += 1 }
                        if tied { withoutTargetTies += 1 }
                    }
                }
                
                let avgWithTarget = withTargetMatches > 0 ? Double(withTargetScore) / Double(withTargetMatches) : 0
                let avgWithoutTarget = withoutTargetMatches > 0 ? Double(withoutTargetScore) / Double(withoutTargetMatches) : 0
                
                partnerAnalyses.append(PartnerAnalysis(
                    teamNumber: partnerNumber,
                    matchesWithTarget: withTargetMatches,
                    winsWithTarget: withTargetWins,
                    lossesWithTarget: withTargetLosses,
                    tiesWithTarget: withTargetTies,
                    avgScoreWithTarget: avgWithTarget,
                    matchesWithoutTarget: withoutTargetMatches,
                    winsWithoutTarget: withoutTargetWins,
                    lossesWithoutTarget: withoutTargetLosses,
                    tiesWithoutTarget: withoutTargetTies,
                    avgScoreWithoutTarget: avgWithoutTarget
                ))
            } catch {
                print("Error fetching data for partner \(partnerNumber): \(error)")
                // Continue with other partners
            }
        }
        
        let avgAllianceScore = matchCount > 0 ? Double(totalAllianceScore) / Double(matchCount) : 0
        let avgOpponentScore = matchCount > 0 ? Double(totalOpponentScore) / Double(matchCount) : 0
        
        return TeamEventAnalysis(
            teamNumber: teamNumber,
            eventCode: eventCode,
            matchCount: matchCount,
            wins: wins,
            losses: losses,
            ties: ties,
            avgAllianceScore: avgAllianceScore,
            avgOpponentScore: avgOpponentScore,
            partnerAnalyses: partnerAnalyses.sorted { $0.matchesWithTarget > $1.matchesWithTarget }
        )
    }
    
}//: end EventAPIService
