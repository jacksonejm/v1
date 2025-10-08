import Foundation
import SwiftUI
import Combine

/// Tracks and analyzes conversation metrics for the AI assistant
@MainActor
class ConversationAnalytics: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var totalConversations: Int = 0
    @Published var completedConversations: Int = 0
    @Published var abandonedConversations: Int = 0
    @Published var averageCompletionTime: TimeInterval = 0
    @Published var currentMetrics = ConversationMetrics()
    @Published var historicalData: [DailyAnalytics] = []
    
    // MARK: - Private Properties
    
    private var activeConversations: [UUID: ConversationSession] = [:]
    private let storage = AnalyticsStorage()
    private var cancellables = Set<AnyCancellable>()
    
    // Metrics cache
    private var phaseCompletionRates: [ConversationPhase: Double] = [:]
    private var fieldExtractionAccuracy: [OnboardingField: Double] = [:]
    private var averageMessagesPerPhase: [ConversationPhase: Double] = [:]
    
    // MARK: - Computed Properties
    
    var completionRate: Double {
        guard totalConversations > 0 else { return 0 }
        return Double(completedConversations) / Double(totalConversations) * 100
    }
    
    var abandonmentRate: Double {
        guard totalConversations > 0 else { return 0 }
        return Double(abandonedConversations) / Double(totalConversations) * 100
    }
    
    var averageSessionDuration: TimeInterval {
        let completedSessions = activeConversations.values.filter { $0.endTime != nil }
        guard !completedSessions.isEmpty else { return 0 }
        
        let totalDuration = completedSessions.compactMap { session -> TimeInterval? in
            guard let endTime = session.endTime else { return nil }
            return endTime.timeIntervalSince(session.startTime)
        }.reduce(0, +)
        
        return totalDuration / Double(completedSessions.count)
    }
    
    // MARK: - Initialization
    
    init() {
        loadHistoricalData()
        setupAutoSave()
    }
    
    // MARK: - Session Management
    
    /// Start tracking a new conversation session
    func startSession(mode: OnboardingMode) -> UUID {
        let sessionId = UUID()
        let session = ConversationSession(
            id: sessionId,
            mode: mode,
            startTime: Date()
        )
        
        activeConversations[sessionId] = session
        totalConversations += 1
        
        // Update current metrics
        currentMetrics.activeSessions = activeConversations.count
        
        return sessionId
    }
    
    /// Track phase transition
    func trackPhaseTransition(
        sessionId: UUID,
        from oldPhase: ConversationPhase,
        to newPhase: ConversationPhase
    ) {
        guard var session = activeConversations[sessionId] else { return }
        
        // Record phase completion time
        let phaseTime = Date().timeIntervalSince(session.lastPhaseChange)
        session.phaseDurations[oldPhase] = phaseTime
        session.lastPhaseChange = Date()
        session.currentPhase = newPhase
        
        // Update phase completion tracking
        session.completedPhases.insert(oldPhase)
        
        activeConversations[sessionId] = session
        
        // Update metrics
        updatePhaseMetrics(oldPhase, duration: phaseTime)
    }
    
    /// Track message exchange
    func trackMessage(
        sessionId: UUID,
        isUser: Bool,
        phase: ConversationPhase,
        extractedFields: [OnboardingField]? = nil
    ) {
        guard var session = activeConversations[sessionId] else { return }
        
        // Increment message counts
        if isUser {
            session.userMessageCount += 1
        } else {
            session.aiMessageCount += 1
        }
        
        // Track messages per phase
        session.messagesPerPhase[phase, default: 0] += 1
        
        // Track field extraction if applicable
        if let fields = extractedFields {
            for field in fields {
                session.extractedFields.insert(field)
            }
        }
        
        activeConversations[sessionId] = session
        
        // Update current metrics
        currentMetrics.totalMessages = activeConversations.values
            .map { $0.userMessageCount + $0.aiMessageCount }
            .reduce(0, +)
    }
    
    /// Track clarification request
    func trackClarification(sessionId: UUID, field: OnboardingField?) {
        guard var session = activeConversations[sessionId] else { return }
        
        session.clarificationCount += 1
        if let field = field {
            session.clarificationsByField[field, default: 0] += 1
        }
        
        activeConversations[sessionId] = session
    }
    
    /// Track correction/backtracking
    func trackCorrection(sessionId: UUID, type: BacktrackingType) {
        guard var session = activeConversations[sessionId] else { return }
        
        session.correctionCount += 1
        session.correctionTypes[type, default: 0] += 1
        
        activeConversations[sessionId] = session
    }
    
    /// Complete a conversation session
    func completeSession(sessionId: UUID, reason: CompletionReason) {
        guard var session = activeConversations[sessionId] else { return }
        
        session.endTime = Date()
        session.completionReason = reason
        
        // Update counters based on reason
        switch reason {
        case .successful:
            completedConversations += 1
        case .abandoned:
            abandonedConversations += 1
        case .switchedMode:
            // Count as completed since user continued in another mode
            completedConversations += 1
        case .error:
            abandonedConversations += 1
        }
        
        // Calculate final metrics
        finalizeSessionMetrics(&session)
        
        // Store completed session
        storage.saveSession(session)
        
        // Remove from active sessions
        activeConversations.removeValue(forKey: sessionId)
        
        // Update current metrics
        updateOverallMetrics()
    }
    
    // MARK: - Metrics Calculation
    
    private func updatePhaseMetrics(_ phase: ConversationPhase, duration: TimeInterval) {
        // Update average time per phase
        let currentAvg = currentMetrics.averageTimePerPhase[phase] ?? 0
        let currentCount = currentMetrics.phaseCompletionCount[phase] ?? 0
        let newCount = currentCount + 1
        let newAvg = (currentAvg * Double(currentCount) + duration) / Double(newCount)
        
        currentMetrics.averageTimePerPhase[phase] = newAvg
        currentMetrics.phaseCompletionCount[phase] = newCount
    }
    
    private func finalizeSessionMetrics(_ session: inout ConversationSession) {
        // Calculate session duration
        if let endTime = session.endTime {
            session.totalDuration = endTime.timeIntervalSince(session.startTime)
        }
        
        // Calculate field extraction success rate
        let expectedFields = ConversationPhase.allCases.flatMap { $0.expectedDataTypes }
        let extractionRate = Double(session.extractedFields.count) / Double(expectedFields.count)
        session.fieldExtractionRate = extractionRate
        
        // Calculate efficiency score
        let messageEfficiency = calculateMessageEfficiency(session)
        let timeEfficiency = calculateTimeEfficiency(session)
        session.efficiencyScore = (messageEfficiency + timeEfficiency) / 2
    }
    
    private func calculateMessageEfficiency(_ session: ConversationSession) -> Double {
        // Ideal messages per phase (based on expected flow)
        let idealMessagesPerPhase: Double = 3
        let totalIdealMessages = idealMessagesPerPhase * Double(session.completedPhases.count)
        let actualMessages = Double(session.userMessageCount + session.aiMessageCount)
        
        // Efficiency decreases as we exceed ideal message count
        return min(1.0, totalIdealMessages / actualMessages)
    }
    
    private func calculateTimeEfficiency(_ session: ConversationSession) -> Double {
        // Ideal time per phase in seconds
        let idealTimePerPhase: TimeInterval = 45
        let totalIdealTime = idealTimePerPhase * Double(session.completedPhases.count)
        let actualTime = session.totalDuration
        
        // Efficiency decreases as we exceed ideal time
        return min(1.0, totalIdealTime / actualTime)
    }
    
    private func updateOverallMetrics() {
        // Update average completion time
        let completedSessions = storage.getAllSessions().filter { $0.completionReason == .successful }
        if !completedSessions.isEmpty {
            averageCompletionTime = completedSessions
                .map { $0.totalDuration }
                .reduce(0, +) / Double(completedSessions.count)
        }
        
        // Update current metrics
        currentMetrics.activeSessions = activeConversations.count
        currentMetrics.successRate = completionRate
        currentMetrics.abandonmentRate = abandonmentRate
    }
    
    // MARK: - Analytics Queries
    
    /// Get metrics for a specific time period
    func getMetrics(for period: AnalyticsPeriod) -> PeriodMetrics {
        let sessions = storage.getSessions(for: period)
        
        return PeriodMetrics(
            period: period,
            totalSessions: sessions.count,
            completedSessions: sessions.filter { $0.completionReason == .successful }.count,
            abandonedSessions: sessions.filter { $0.completionReason == .abandoned }.count,
            averageDuration: calculateAverageDuration(sessions),
            mostCommonDropoffPhase: findMostCommonDropoffPhase(sessions),
            fieldExtractionRates: calculateFieldExtractionRates(sessions)
        )
    }
    
    /// Get phase-specific analytics
    func getPhaseAnalytics(_ phase: ConversationPhase) -> PhaseAnalytics {
        let sessions = storage.getAllSessions()
        let relevantSessions = sessions.filter { $0.completedPhases.contains(phase) }
        
        return PhaseAnalytics(
            phase: phase,
            completionRate: calculatePhaseCompletionRate(phase, from: sessions),
            averageDuration: calculateAveragePhaseTime(phase, from: relevantSessions),
            averageMessages: calculateAverageMessages(phase, from: relevantSessions),
            commonIssues: findCommonIssues(phase, from: relevantSessions)
        )
    }
    
    /// Get user behavior insights
    func getUserInsights() -> UserBehaviorInsights {
        let sessions = storage.getAllSessions()
        
        return UserBehaviorInsights(
            preferredMode: findPreferredMode(sessions),
            averageResponseTime: calculateAverageResponseTime(sessions),
            backtrackingFrequency: calculateBacktrackingFrequency(sessions),
            clarificationRate: calculateClarificationRate(sessions),
            peakUsageHours: findPeakUsageHours(sessions),
            commonTopics: extractCommonTopics(sessions)
        )
    }
    
    // MARK: - Data Export
    
    /// Export analytics data in various formats
    func exportData(format: ExportFormat, period: AnalyticsPeriod) -> Data? {
        let sessions = storage.getSessions(for: period)
        
        switch format {
        case .csv:
            return exportAsCSV(sessions)
        case .json:
            return exportAsJSON(sessions)
        case .summary:
            return exportAsSummaryReport(sessions, period: period)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func calculateAverageDuration(_ sessions: [ConversationSession]) -> TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        let totalDuration = sessions.map { $0.totalDuration }.reduce(0, +)
        return totalDuration / Double(sessions.count)
    }
    
    private func findMostCommonDropoffPhase(_ sessions: [ConversationSession]) -> ConversationPhase? {
        let abandonedSessions = sessions.filter { $0.completionReason == .abandoned }
        guard !abandonedSessions.isEmpty else { return nil }
        
        let dropoffPhases = abandonedSessions.compactMap { $0.currentPhase }
        let phaseCounts = Dictionary(grouping: dropoffPhases, by: { $0 })
            .mapValues { $0.count }
        
        return phaseCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func calculateFieldExtractionRates(_ sessions: [ConversationSession]) -> [OnboardingField: Double] {
        var fieldCounts: [OnboardingField: Int] = [:]
        var fieldAttempts: [OnboardingField: Int] = [:]
        
        for session in sessions {
            for field in OnboardingField.allCases {
                fieldAttempts[field, default: 0] += 1
                if session.extractedFields.contains(field) {
                    fieldCounts[field, default: 0] += 1
                }
            }
        }
        
        var rates: [OnboardingField: Double] = [:]
        for field in OnboardingField.allCases {
            let attempts = fieldAttempts[field] ?? 0
            let successes = fieldCounts[field] ?? 0
            rates[field] = attempts > 0 ? Double(successes) / Double(attempts) : 0
        }
        
        return rates
    }
    
    private func calculatePhaseCompletionRate(_ phase: ConversationPhase, from sessions: [ConversationSession]) -> Double {
        let sessionsReachingPhase = sessions.filter { 
            $0.completedPhases.contains(phase) || $0.currentPhase == phase 
        }
        let sessionsCompletingPhase = sessions.filter { $0.completedPhases.contains(phase) }
        
        guard !sessionsReachingPhase.isEmpty else { return 0 }
        return Double(sessionsCompletingPhase.count) / Double(sessionsReachingPhase.count) * 100
    }
    
    private func calculateAveragePhaseTime(_ phase: ConversationPhase, from sessions: [ConversationSession]) -> TimeInterval {
        let phaseTimes = sessions.compactMap { $0.phaseDurations[phase] }
        guard !phaseTimes.isEmpty else { return 0 }
        return phaseTimes.reduce(0, +) / Double(phaseTimes.count)
    }
    
    private func calculateAverageMessages(_ phase: ConversationPhase, from sessions: [ConversationSession]) -> Double {
        let messageCounts = sessions.compactMap { $0.messagesPerPhase[phase] }
        guard !messageCounts.isEmpty else { return 0 }
        return Double(messageCounts.reduce(0, +)) / Double(messageCounts.count)
    }
    
    private func findCommonIssues(_ phase: ConversationPhase, from sessions: [ConversationSession]) -> [String] {
        // Analyze clarifications and corrections for this phase
        var issues: [String] = []
        
        let clarificationRate = sessions
            .filter { ($0.clarificationsByField.keys.contains { field in
                phase.expectedDataTypes.contains(field)
            }) }
            .count
        
        if Double(clarificationRate) / Double(sessions.count) > 0.3 {
            issues.append("High clarification rate - consider clearer prompts")
        }
        
        return issues
    }
    
    private func findPreferredMode(_ sessions: [ConversationSession]) -> OnboardingMode {
        let modeCounts = Dictionary(grouping: sessions, by: { $0.mode })
            .mapValues { $0.count }
        
        return modeCounts.max(by: { $0.value < $1.value })?.key ?? .conversational
    }
    
    private func calculateAverageResponseTime(_ sessions: [ConversationSession]) -> TimeInterval {
        // This would require more detailed message timing data
        // For now, return a placeholder
        return 5.0
    }
    
    private func calculateBacktrackingFrequency(_ sessions: [ConversationSession]) -> Double {
        let sessionsWithCorrections = sessions.filter { $0.correctionCount > 0 }.count
        return Double(sessionsWithCorrections) / Double(max(sessions.count, 1)) * 100
    }
    
    private func calculateClarificationRate(_ sessions: [ConversationSession]) -> Double {
        let totalMessages = sessions.map { $0.userMessageCount }.reduce(0, +)
        let totalClarifications = sessions.map { $0.clarificationCount }.reduce(0, +)
        
        guard totalMessages > 0 else { return 0 }
        return Double(totalClarifications) / Double(totalMessages) * 100
    }
    
    private func findPeakUsageHours(_ sessions: [ConversationSession]) -> [Int] {
        let hourCounts = Dictionary(grouping: sessions) { session in
            Calendar.current.component(.hour, from: session.startTime)
        }.mapValues { $0.count }
        
        let maxCount = hourCounts.values.max() ?? 0
        let threshold = Double(maxCount) * 0.8
        
        return hourCounts.compactMap { hour, count in
            count >= Int(threshold) ? hour : nil
        }.sorted()
    }
    
    private func extractCommonTopics(_ sessions: [ConversationSession]) -> [String] {
        // This would analyze conversation content
        // For now, return placeholder topics
        return ["Technology", "Healthcare", "Business", "Education"]
    }
    
    // MARK: - Data Export Implementation
    
    private func exportAsCSV(_ sessions: [ConversationSession]) -> Data? {
        var csv = "Session ID,Mode,Start Time,Duration,Completion Status,Messages,Efficiency Score\n"
        
        for session in sessions {
            let row = "\(session.id),\(session.mode.rawValue),\(session.startTime),\(session.totalDuration),\(session.completionReason?.rawValue ?? "active"),\(session.userMessageCount + session.aiMessageCount),\(session.efficiencyScore)\n"
            csv += row
        }
        
        return csv.data(using: .utf8)
    }
    
    private func exportAsJSON(_ sessions: [ConversationSession]) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        return try? encoder.encode(sessions)
    }
    
    private func exportAsSummaryReport(_ sessions: [ConversationSession], period: AnalyticsPeriod) -> Data? {
        let metrics = getMetrics(for: period)
        
        var report = """
        Conversation Analytics Report
        Period: \(period.description)
        Generated: \(Date())
        
        Overview:
        - Total Sessions: \(metrics.totalSessions)
        - Completed: \(metrics.completedSessions)
        - Abandoned: \(metrics.abandonedSessions)
        - Success Rate: \(String(format: "%.1f%%", metrics.successRate))
        
        Performance:
        - Average Duration: \(formatDuration(metrics.averageDuration))
        - Most Common Dropoff: \(metrics.mostCommonDropoffPhase?.rawValue ?? "N/A")
        
        Field Extraction Success Rates:
        """
        
        for (field, rate) in metrics.fieldExtractionRates.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            report += "\n- \(field.rawValue): \(String(format: "%.1f%%", rate * 100))"
        }
        
        return report.data(using: .utf8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    // MARK: - Storage & Persistence
    
    private func loadHistoricalData() {
        historicalData = storage.getHistoricalData()
        
        // Load summary counts
        let allSessions = storage.getAllSessions()
        totalConversations = allSessions.count
        completedConversations = allSessions.filter { $0.completionReason == .successful }.count
        abandonedConversations = allSessions.filter { $0.completionReason == .abandoned }.count
    }
    
    private func setupAutoSave() {
        // Save analytics data periodically
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.saveCurrentMetrics()
            }
            .store(in: &cancellables)
    }
    
    private func saveCurrentMetrics() {
        let daily = DailyAnalytics(
            date: Date(),
            metrics: currentMetrics,
            sessions: Array(activeConversations.values)
        )
        
        storage.saveDailyAnalytics(daily)
    }
}

// MARK: - Supporting Types

struct ConversationSession: Codable, Identifiable {
    let id: UUID
    let mode: OnboardingMode
    let startTime: Date
    var endTime: Date?
    var currentPhase: ConversationPhase = .welcome
    var completedPhases: Set<ConversationPhase> = []
    var lastPhaseChange: Date
    
    // Metrics
    var userMessageCount: Int = 0
    var aiMessageCount: Int = 0
    var clarificationCount: Int = 0
    var correctionCount: Int = 0
    var messagesPerPhase: [ConversationPhase: Int] = [:]
    var phaseDurations: [ConversationPhase: TimeInterval] = [:]
    var extractedFields: Set<OnboardingField> = []
    var clarificationsByField: [OnboardingField: Int] = [:]
    var correctionTypes: [BacktrackingType: Int] = [:]
    
    // Calculated metrics
    var totalDuration: TimeInterval = 0
    var fieldExtractionRate: Double = 0
    var efficiencyScore: Double = 0
    var completionReason: CompletionReason?
    
    init(id: UUID, mode: OnboardingMode, startTime: Date) {
        self.id = id
        self.mode = mode
        self.startTime = startTime
        self.lastPhaseChange = startTime
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, mode, startTime, endTime, currentPhase, completedPhases, lastPhaseChange
        case userMessageCount, aiMessageCount, clarificationCount, correctionCount
        case messagesPerPhase, phaseDurations, extractedFields, clarificationsByField
        case correctionTypes, totalDuration, fieldExtractionRate, efficiencyScore, completionReason
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        mode = try container.decode(OnboardingMode.self, forKey: .mode)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        currentPhase = try container.decode(ConversationPhase.self, forKey: .currentPhase)
        lastPhaseChange = try container.decode(Date.self, forKey: .lastPhaseChange)
        
        // Decode sets as arrays
        let completedPhasesArray = try container.decode([String].self, forKey: .completedPhases)
        completedPhases = Set(completedPhasesArray.compactMap { ConversationPhase(rawValue: $0) })
        
        let extractedFieldsArray = try container.decode([String].self, forKey: .extractedFields)
        extractedFields = Set(extractedFieldsArray.compactMap { OnboardingField(rawValue: $0) })
        
        // Decode metrics
        userMessageCount = try container.decode(Int.self, forKey: .userMessageCount)
        aiMessageCount = try container.decode(Int.self, forKey: .aiMessageCount)
        clarificationCount = try container.decode(Int.self, forKey: .clarificationCount)
        correctionCount = try container.decode(Int.self, forKey: .correctionCount)
        
        // Decode dictionaries with enum keys
        let messagesPerPhaseStrings = try container.decode([String: Int].self, forKey: .messagesPerPhase)
        messagesPerPhase = Dictionary(uniqueKeysWithValues: messagesPerPhaseStrings.compactMap { key, value in
            guard let phase = ConversationPhase(rawValue: key) else { return nil }
            return (phase, value)
        })
        
        let phaseDurationsStrings = try container.decode([String: TimeInterval].self, forKey: .phaseDurations)
        phaseDurations = Dictionary(uniqueKeysWithValues: phaseDurationsStrings.compactMap { key, value in
            guard let phase = ConversationPhase(rawValue: key) else { return nil }
            return (phase, value)
        })
        
        let clarificationsByFieldStrings = try container.decode([String: Int].self, forKey: .clarificationsByField)
        clarificationsByField = Dictionary(uniqueKeysWithValues: clarificationsByFieldStrings.compactMap { key, value in
            guard let field = OnboardingField(rawValue: key) else { return nil }
            return (field, value)
        })
        
        let correctionTypesStrings = try container.decode([String: Int].self, forKey: .correctionTypes)
        correctionTypes = Dictionary(uniqueKeysWithValues: correctionTypesStrings.compactMap { key, value in
            guard let type = BacktrackingType(rawValue: key) else { return nil }
            return (type, value)
        })
        
        // Decode calculated metrics
        totalDuration = try container.decode(TimeInterval.self, forKey: .totalDuration)
        fieldExtractionRate = try container.decode(Double.self, forKey: .fieldExtractionRate)
        efficiencyScore = try container.decode(Double.self, forKey: .efficiencyScore)
        completionReason = try container.decodeIfPresent(CompletionReason.self, forKey: .completionReason)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(mode, forKey: .mode)
        try container.encode(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encode(currentPhase, forKey: .currentPhase)
        try container.encode(lastPhaseChange, forKey: .lastPhaseChange)
        
        // Encode sets as arrays
        try container.encode(completedPhases.map { $0.rawValue }, forKey: .completedPhases)
        try container.encode(extractedFields.map { $0.rawValue }, forKey: .extractedFields)
        
        // Encode metrics
        try container.encode(userMessageCount, forKey: .userMessageCount)
        try container.encode(aiMessageCount, forKey: .aiMessageCount)
        try container.encode(clarificationCount, forKey: .clarificationCount)
        try container.encode(correctionCount, forKey: .correctionCount)
        
        // Encode dictionaries with enum keys as string dictionaries
        let messagesPerPhaseStrings = Dictionary(uniqueKeysWithValues: messagesPerPhase.map { ($0.key.rawValue, $0.value) })
        try container.encode(messagesPerPhaseStrings, forKey: .messagesPerPhase)
        
        let phaseDurationsStrings = Dictionary(uniqueKeysWithValues: phaseDurations.map { ($0.key.rawValue, $0.value) })
        try container.encode(phaseDurationsStrings, forKey: .phaseDurations)
        
        let clarificationsByFieldStrings = Dictionary(uniqueKeysWithValues: clarificationsByField.map { ($0.key.rawValue, $0.value) })
        try container.encode(clarificationsByFieldStrings, forKey: .clarificationsByField)
        
        let correctionTypesStrings = Dictionary(uniqueKeysWithValues: correctionTypes.map { ($0.key.rawValue, $0.value) })
        try container.encode(correctionTypesStrings, forKey: .correctionTypes)
        
        // Encode calculated metrics
        try container.encode(totalDuration, forKey: .totalDuration)
        try container.encode(fieldExtractionRate, forKey: .fieldExtractionRate)
        try container.encode(efficiencyScore, forKey: .efficiencyScore)
        try container.encodeIfPresent(completionReason, forKey: .completionReason)
    }
}

struct ConversationMetrics: Codable {
    var activeSessions: Int = 0
    var totalMessages: Int = 0
    var successRate: Double = 0
    var abandonmentRate: Double = 0
    var averageTimePerPhase: [ConversationPhase: TimeInterval] = [:]
    var phaseCompletionCount: [ConversationPhase: Int] = [:]
    
    enum CodingKeys: String, CodingKey {
        case activeSessions, totalMessages, successRate, abandonmentRate
        case averageTimePerPhase, phaseCompletionCount
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activeSessions = try container.decode(Int.self, forKey: .activeSessions)
        totalMessages = try container.decode(Int.self, forKey: .totalMessages)
        successRate = try container.decode(Double.self, forKey: .successRate)
        abandonmentRate = try container.decode(Double.self, forKey: .abandonmentRate)
        
        // Decode dictionaries with String keys and convert to ConversationPhase
        let timePerPhaseStrings = try container.decode([String: TimeInterval].self, forKey: .averageTimePerPhase)
        averageTimePerPhase = Dictionary(uniqueKeysWithValues: timePerPhaseStrings.compactMap { key, value in
            guard let phase = ConversationPhase(rawValue: key) else { return nil }
            return (phase, value)
        })
        
        let completionCountStrings = try container.decode([String: Int].self, forKey: .phaseCompletionCount)
        phaseCompletionCount = Dictionary(uniqueKeysWithValues: completionCountStrings.compactMap { key, value in
            guard let phase = ConversationPhase(rawValue: key) else { return nil }
            return (phase, value)
        })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activeSessions, forKey: .activeSessions)
        try container.encode(totalMessages, forKey: .totalMessages)
        try container.encode(successRate, forKey: .successRate)
        try container.encode(abandonmentRate, forKey: .abandonmentRate)
        
        // Convert ConversationPhase keys to String for encoding
        let timePerPhaseStrings = Dictionary(uniqueKeysWithValues: averageTimePerPhase.map { ($0.key.rawValue, $0.value) })
        try container.encode(timePerPhaseStrings, forKey: .averageTimePerPhase)
        
        let completionCountStrings = Dictionary(uniqueKeysWithValues: phaseCompletionCount.map { ($0.key.rawValue, $0.value) })
        try container.encode(completionCountStrings, forKey: .phaseCompletionCount)
    }
}

struct DailyAnalytics: Codable {
    let date: Date
    let metrics: ConversationMetrics
    let sessions: [ConversationSession]
}

struct PeriodMetrics {
    let period: AnalyticsPeriod
    let totalSessions: Int
    let completedSessions: Int
    let abandonedSessions: Int
    let averageDuration: TimeInterval
    let mostCommonDropoffPhase: ConversationPhase?
    let fieldExtractionRates: [OnboardingField: Double]
    
    var successRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions) * 100
    }
}

struct PhaseAnalytics {
    let phase: ConversationPhase
    let completionRate: Double
    let averageDuration: TimeInterval
    let averageMessages: Double
    let commonIssues: [String]
}

struct UserBehaviorInsights {
    let preferredMode: OnboardingMode
    let averageResponseTime: TimeInterval
    let backtrackingFrequency: Double
    let clarificationRate: Double
    let peakUsageHours: [Int]
    let commonTopics: [String]
}

enum CompletionReason: String, Codable {
    case successful
    case abandoned
    case switchedMode
    case error
}

enum AnalyticsPeriod: Hashable {
    case today
    case week
    case month
    case quarter
    case year
    case custom(start: Date, end: Date)
    
    var description: String {
        switch self {
        case .today: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        case .quarter: return "This Quarter"
        case .year: return "This Year"
        case .custom(let start, let end):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
}

enum ExportFormat {
    case csv
    case json
    case summary
}

// MARK: - Analytics Storage

class AnalyticsStorage {
    private let documentsDirectory: URL
    private let sessionsFile = "conversation_sessions.json"
    private let dailyAnalyticsFile = "daily_analytics.json"
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveSession(_ session: ConversationSession) {
        var sessions = getAllSessions()
        sessions.append(session)
        saveSessions(sessions)
    }
    
    func getAllSessions() -> [ConversationSession] {
        let url = documentsDirectory.appendingPathComponent(sessionsFile)
        
        guard let data = try? Data(contentsOf: url) else { return [] }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return (try? decoder.decode([ConversationSession].self, from: data)) ?? []
    }
    
    func getSessions(for period: AnalyticsPeriod) -> [ConversationSession] {
        let allSessions = getAllSessions()
        let calendar = Calendar.current
        
        switch period {
        case .today:
            return allSessions.filter { calendar.isDateInToday($0.startTime) }
        case .week:
            let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            return allSessions.filter { $0.startTime >= weekAgo }
        case .month:
            let monthAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
            return allSessions.filter { $0.startTime >= monthAgo }
        case .quarter:
            let quarterAgo = Date().addingTimeInterval(-90 * 24 * 60 * 60)
            return allSessions.filter { $0.startTime >= quarterAgo }
        case .year:
            let yearAgo = Date().addingTimeInterval(-365 * 24 * 60 * 60)
            return allSessions.filter { $0.startTime >= yearAgo }
        case .custom(let start, let end):
            return allSessions.filter { $0.startTime >= start && $0.startTime <= end }
        }
    }
    
    func saveDailyAnalytics(_ analytics: DailyAnalytics) {
        var allAnalytics = getHistoricalData()
        
        // Replace or add today's analytics
        if let index = allAnalytics.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: analytics.date) 
        }) {
            allAnalytics[index] = analytics
        } else {
            allAnalytics.append(analytics)
        }
        
        // Keep only last 90 days
        let cutoffDate = Date().addingTimeInterval(-90 * 24 * 60 * 60)
        allAnalytics = allAnalytics.filter { $0.date >= cutoffDate }
        
        saveHistoricalData(allAnalytics)
    }
    
    func getHistoricalData() -> [DailyAnalytics] {
        let url = documentsDirectory.appendingPathComponent(dailyAnalyticsFile)
        
        guard let data = try? Data(contentsOf: url) else { return [] }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return (try? decoder.decode([DailyAnalytics].self, from: data)) ?? []
    }
    
    private func saveSessions(_ sessions: [ConversationSession]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(sessions) else { return }
        
        let url = documentsDirectory.appendingPathComponent(sessionsFile)
        try? data.write(to: url)
    }
    
    private func saveHistoricalData(_ analytics: [DailyAnalytics]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(analytics) else { return }
        
        let url = documentsDirectory.appendingPathComponent(dailyAnalyticsFile)
        try? data.write(to: url)
    }
}