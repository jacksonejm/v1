import Foundation
import SwiftUI

/// Manages multi-turn conversations with context awareness and follow-up handling
@MainActor
class MultiTurnConversationManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var conversationHistory: [ConversationTurn] = []
    @Published var currentContext: ConversationContext
    @Published var pendingClarifications: [ClarificationRequest] = []
    @Published var isProcessingContext = false
    
    // MARK: - Private Properties
    
    private let maxHistorySize = 20
    private let contextWindow = 5 // Number of recent turns to consider for context
    private var topicTracker = TopicTracker()
    
    // MARK: - Initialization
    
    init() {
        self.currentContext = ConversationContext()
    }
    
    // MARK: - Public Methods
    
    /// Add a new turn to the conversation
    func addTurn(_ turn: ConversationTurn) {
        conversationHistory.append(turn)
        
        // Maintain history size
        if conversationHistory.count > maxHistorySize {
            conversationHistory.removeFirst()
        }
        
        // Update context
        updateContext()
        
        // Track topics
        topicTracker.analyze(turn)
    }
    
    /// Reset the conversation manager for a fresh start
    func reset() {
        conversationHistory = []
        currentContext = ConversationContext()
        pendingClarifications = []
        topicTracker = TopicTracker()
        isProcessingContext = false
    }
    
    /// Get relevant context for the current conversation state
    func getRelevantContext(for phase: ConversationPhase) -> ConversationContext {
        isProcessingContext = true
        defer { isProcessingContext = false }
        
        // Get recent turns
        let recentTurns = Array(conversationHistory.suffix(contextWindow))
        
        // Extract relevant information based on phase
        var context = ConversationContext()
        context.phase = phase
        context.recentTurns = recentTurns
        context.currentTopic = topicTracker.currentTopic
        context.mentionedTopics = topicTracker.allTopics
        context.extractedEntities = extractEntities(from: recentTurns)
        context.userPreferences = extractPreferences(from: conversationHistory)
        context.clarificationNeeded = determineClarificationNeeds(recentTurns)
        
        return context
    }
    
    /// Handle follow-up questions based on context
    func generateFollowUp(for response: String, in phase: ConversationPhase) -> String? {
        let context = getRelevantContext(for: phase)
        
        // Check if we need clarification
        if let clarification = context.clarificationNeeded.first {
            return clarification.question
        }
        
        // Generate contextual follow-up based on phase
        switch phase {
        case .exploringInterests:
            return generateInterestFollowUp(context: context)
        case .assessingRIASEC:
            return generateAssessmentFollowUp(context: context)
        case .discussingSubjects:
            return generateSubjectFollowUp(context: context)
        case .exploringCareers:
            return generateCareerFollowUp(context: context)
        default:
            return nil
        }
    }
    
    /// Check if the user is trying to go back or change a previous answer
    func detectBacktrackingIntent(in message: String) -> BacktrackingIntent? {
        let lowercased = message.lowercased()
        
        // Check for explicit backtracking phrases
        let backtrackPhrases = [
            "actually", "wait", "i meant", "let me change", "go back",
            "can we go back", "i want to change", "correction", "sorry, i meant"
        ]
        
        for phrase in backtrackPhrases {
            if lowercased.contains(phrase) {
                return analyzeBacktrackingIntent(message)
            }
        }
        
        return nil
    }
    
    /// Handle user corrections or changes to previous answers
    func handleCorrection(_ intent: BacktrackingIntent) -> String {
        switch intent.type {
        case .correctPreviousAnswer:
            return "No problem! Let me update that. \(intent.suggestedResponse)"
        case .addMoreDetail:
            return "Thanks for adding more detail! \(intent.suggestedResponse)"
        case .changePreference:
            return "I'll update your preference. \(intent.suggestedResponse)"
        case .clarifyMisunderstanding:
            return "Thank you for clarifying! \(intent.suggestedResponse)"
        }
    }
    
    // MARK: - Private Methods
    
    private func updateContext() {
        currentContext = getRelevantContext(for: currentContext.phase)
    }
    
    private func extractEntities(from turns: [ConversationTurn]) -> [String: Any] {
        var entities: [String: Any] = [:]
        
        for turn in turns {
            // Extract names
            if let names = extractNames(from: turn.message) {
                entities["names"] = names
            }
            
            // Extract numbers/ages
            if let numbers = extractNumbers(from: turn.message) {
                entities["numbers"] = numbers
            }
            
            // Extract locations
            if let locations = extractLocations(from: turn.message) {
                entities["locations"] = locations
            }
        }
        
        return entities
    }
    
    private func extractPreferences(from history: [ConversationTurn]) -> UserPreferences {
        var preferences = UserPreferences()
        
        // Analyze communication style
        let averageMessageLength = history
            .filter { $0.isUser }
            .map { $0.message.count }
            .reduce(0, +) / max(history.filter { $0.isUser }.count, 1)
        
        preferences.communicationStyle = averageMessageLength > 50 ? .detailed : .concise
        
        // Detect formality level
        let formalWords = ["please", "thank you", "would", "could", "appreciate"]
        let formalCount = history
            .filter { $0.isUser }
            .map { turn in
                formalWords.filter { turn.message.lowercased().contains($0) }.count
            }
            .reduce(0, +)
        
        preferences.formalityLevel = formalCount > 5 ? .formal : .casual
        
        return preferences
    }
    
    private func determineClarificationNeeds(_ turns: [ConversationTurn]) -> [ClarificationRequest] {
        var clarifications: [ClarificationRequest] = []
        
        // Check for ambiguous responses in recent turns
        for turn in turns where turn.isUser {
            if isAmbiguousResponse(turn.message) {
                let clarification = ClarificationRequest(
                    originalMessage: turn.message,
                    question: generateClarificationQuestion(for: turn.message),
                    field: turn.relatedField
                )
                clarifications.append(clarification)
            }
        }
        
        return clarifications
    }
    
    private func isAmbiguousResponse(_ message: String) -> Bool {
        let ambiguousTerms = ["maybe", "kind of", "sort of", "i guess", "not sure", "possibly"]
        let lowercased = message.lowercased()
        return ambiguousTerms.contains { lowercased.contains($0) }
    }
    
    private func generateClarificationQuestion(for message: String) -> String {
        if message.lowercased().contains("maybe") {
            return "It sounds like you're not entirely sure. Could you tell me more about what you're considering?"
        } else if message.lowercased().contains("kind of") || message.lowercased().contains("sort of") {
            return "I'd love to understand better. Can you be more specific?"
        } else {
            return "Could you elaborate on that a bit more?"
        }
    }
    
    // MARK: - Follow-up Generators
    
    private func generateInterestFollowUp(context: ConversationContext) -> String? {
        guard let lastInterest = context.mentionedTopics.last else { return nil }
        
        let followUps = [
            "What specifically about \(lastInterest) interests you?",
            "How long have you been interested in \(lastInterest)?",
            "Have you had any experiences with \(lastInterest) that you'd like to share?"
        ]
        
        return followUps.randomElement()
    }
    
    private func generateAssessmentFollowUp(context: ConversationContext) -> String? {
        let followUps = [
            "Can you tell me more about why you chose that answer?",
            "What experiences have shaped your preference?",
            "Is there a specific example that comes to mind?"
        ]
        
        return followUps.randomElement()
    }
    
    private func generateSubjectFollowUp(context: ConversationContext) -> String? {
        guard let lastSubject = context.mentionedTopics.last else { return nil }
        
        return "What do you enjoy most about \(lastSubject)?"
    }
    
    private func generateCareerFollowUp(context: ConversationContext) -> String? {
        return "What aspects of that career appeal to you most?"
    }
    
    // MARK: - Entity Extraction
    
    private func extractNames(from text: String) -> [String]? {
        // Simple name extraction - in production, use NLP
        let words = text.split(separator: " ").map { String($0) }
        let capitalizedWords = words.filter { $0.first?.isUppercase == true }
        return capitalizedWords.isEmpty ? nil : capitalizedWords
    }
    
    private func extractNumbers(from text: String) -> [Int]? {
        let numbers = text.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
        return numbers.isEmpty ? nil : numbers
    }
    
    private func extractLocations(from text: String) -> [String]? {
        // Simple location detection - in production, use NLP
        let locationKeywords = ["school", "college", "university", "city", "state", "country"]
        let words = text.lowercased().split(separator: " ").map { String($0) }
        let locations = words.filter { word in
            locationKeywords.contains { word.contains($0) }
        }
        return locations.isEmpty ? nil : locations
    }
    
    private func analyzeBacktrackingIntent(_ message: String) -> BacktrackingIntent {
        let lowercased = message.lowercased()
        
        if lowercased.contains("i meant") || lowercased.contains("correction") {
            return BacktrackingIntent(
                type: .correctPreviousAnswer,
                suggestedResponse: "What would you like to change it to?"
            )
        } else if lowercased.contains("also") || lowercased.contains("add") {
            return BacktrackingIntent(
                type: .addMoreDetail,
                suggestedResponse: "What else would you like to add?"
            )
        } else if lowercased.contains("actually prefer") || lowercased.contains("change") {
            return BacktrackingIntent(
                type: .changePreference,
                suggestedResponse: "What would you prefer instead?"
            )
        } else {
            return BacktrackingIntent(
                type: .clarifyMisunderstanding,
                suggestedResponse: "Let me make sure I understand correctly."
            )
        }
    }
}

// MARK: - Supporting Types

struct ConversationTurn {
    let id = UUID()
    let message: String
    let isUser: Bool
    let timestamp: Date
    let phase: ConversationPhase
    let relatedField: OnboardingField?
    let extractedData: [String: Any]?
    
    init(
        message: String,
        isUser: Bool,
        phase: ConversationPhase,
        relatedField: OnboardingField? = nil,
        extractedData: [String: Any]? = nil
    ) {
        self.message = message
        self.isUser = isUser
        self.timestamp = Date()
        self.phase = phase
        self.relatedField = relatedField
        self.extractedData = extractedData
    }
}

struct ConversationContext {
    var phase: ConversationPhase = .welcome
    var recentTurns: [ConversationTurn] = []
    var currentTopic: String?
    var mentionedTopics: [String] = []
    var extractedEntities: [String: Any] = [:]
    var userPreferences = UserPreferences()
    var clarificationNeeded: [ClarificationRequest] = []
}

struct ClarificationRequest {
    let originalMessage: String
    let question: String
    let field: OnboardingField?
}

struct UserPreferences {
    var communicationStyle: CommunicationStyle = .balanced
    var formalityLevel: FormalityLevel = .casual
    var responseLength: ResponseLength = .medium
}

enum CommunicationStyle {
    case concise
    case detailed
    case balanced
}

enum FormalityLevel {
    case casual
    case formal
}

enum ResponseLength {
    case short
    case medium
    case long
}

struct BacktrackingIntent {
    let type: BacktrackingType
    let suggestedResponse: String
}

enum BacktrackingType: String {
    case correctPreviousAnswer
    case addMoreDetail
    case changePreference
    case clarifyMisunderstanding
}

// MARK: - Topic Tracker

class TopicTracker {
    private var topics: [String: Int] = [:]
    
    var currentTopic: String? {
        topics.max { $0.value < $1.value }?.key
    }
    
    var allTopics: [String] {
        Array(topics.keys).sorted { topics[$0]! > topics[$1]! }
    }
    
    func analyze(_ turn: ConversationTurn) {
        // Extract topics from the message
        let words = turn.message
            .lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 4 } // Only consider words longer than 4 characters
        
        // Update topic counts
        for word in words {
            topics[word, default: 0] += 1
        }
    }
}