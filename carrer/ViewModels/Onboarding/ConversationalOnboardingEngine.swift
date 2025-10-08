import SwiftUI
import Combine

/// Manages the conversational onboarding flow
@MainActor
class ConversationalOnboardingEngine: ObservableObject {
    // MARK: - Published Properties
    @Published var phase: ConversationPhase = .welcome
    @Published var conversationState: ConversationState = .idle
    @Published var collectedData = OnboardingData()
    @Published var messages: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var quickReplySuggestions: [String] = []
    
    // MARK: - Private Properties
    private let dataExtractor: ConversationalDataExtractor
    private let responseGenerator: ContextualResponseGenerator
    private let onboardingStore: OnboardingStore
    private let conversationManager: MultiTurnConversationManager
    private let analytics: ConversationAnalytics
    private var sessionId: UUID?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(onboardingStore: OnboardingStore) {
        self.onboardingStore = onboardingStore
        self.dataExtractor = ConversationalDataExtractor()
        self.responseGenerator = ContextualResponseGenerator()
        self.conversationManager = MultiTurnConversationManager()
        self.analytics = ConversationAnalytics()
    }
    
    // MARK: - Public Methods
    
    /// Start the onboarding conversation
    func startOnboarding() async {
        // Reset all data for a fresh start
        resetConversation()
        
        conversationState = .active
        phase = .welcome
        
        // Start analytics session
        sessionId = analytics.startSession(mode: .conversational)
        
        // Send welcome message
        await sendMessage(phase.promptTemplate, isUser: false)
        
        // Move to first input phase
        await transitionToNextPhase()
    }
    
    /// Reset the conversation to start fresh
    private func resetConversation() {
        phase = .welcome
        conversationState = .idle
        collectedData = OnboardingData()
        messages = []
        isProcessing = false
        quickReplySuggestions = []
        conversationManager.reset()
    }
    
    /// Resume onboarding with existing data from forms
    func resumeWithContext(phase: ConversationPhase, resumePrompt: String, existingData: OnboardingData) async {
        // Update state with existing data
        self.collectedData = existingData
        self.phase = phase
        conversationState = .active
        
        // Start analytics session for mode switch
        sessionId = analytics.startSession(mode: .conversational)
        
        // Clear existing messages if any
        messages.removeAll()
        
        // Send resume prompt
        await sendMessage(resumePrompt, isUser: false)
        
        // Set state to wait for user input
        conversationState = .waitingForUser
    }
    
    /// Process a user message
    func processUserMessage(_ message: String) async {
        // Add user message to conversation
        await sendMessage(message, isUser: true)
        
        // Update state
        conversationState = .processing
        isProcessing = true
        
        // Track user message
        if let sessionId = sessionId {
            analytics.trackMessage(sessionId: sessionId, isUser: true, phase: phase)
        }
        
        // Check for backtracking intent
        if let backtrackingIntent = conversationManager.detectBacktrackingIntent(in: message) {
            // Track correction
            if let sessionId = sessionId {
                analytics.trackCorrection(sessionId: sessionId, type: backtrackingIntent.type)
            }
            
            let response = conversationManager.handleCorrection(backtrackingIntent)
            await sendMessage(response, isUser: false)
            conversationState = .waitingForUser
            isProcessing = false
            return
        }
        
        // Extract data based on current phase
        let extractedData = await dataExtractor.extract(
            from: message,
            expecting: phase.expectedDataTypes,
            context: collectedData
        )
        
        // Add turn to conversation history
        let turn = ConversationTurn(
            message: message,
            isUser: true,
            phase: phase,
            relatedField: phase.expectedDataTypes.first,
            extractedData: extractedData.all.first?.toDictionary()
        )
        conversationManager.addTurn(turn)
        
        // Handle extracted data
        if !extractedData.isEmpty {
            // Check if confirmation is needed
            if extractedData.needsConfirmation {
                await handleConfirmationNeeded(extractedData)
            } else {
                // Apply extracted data
                await applyExtractedData(extractedData)
                
                // Track field extractions
                let extractedFields = extractedData.all.map { $0.field }
                if !extractedFields.isEmpty, let sessionId = sessionId {
                    analytics.trackMessage(
                        sessionId: sessionId,
                        isUser: false,
                        phase: phase,
                        extractedFields: extractedFields
                    )
                }
                
                // Get context-aware response
                let context = conversationManager.getRelevantContext(for: phase)
                let response = await responseGenerator.generate(
                    for: phase,
                    with: collectedData,
                    basedOn: extractedData,
                    context: context
                )
                await sendMessage(response, isUser: false)
                
                // Track AI response
                if let sessionId = sessionId {
                    analytics.trackMessage(
                        sessionId: sessionId,
                        isUser: false,
                        phase: phase,
                        extractedFields: nil
                    )
                }
                
                // Add AI response to history
                let aiTurn = ConversationTurn(
                    message: response,
                    isUser: false,
                    phase: phase
                )
                conversationManager.addTurn(aiTurn)
                
                // Generate follow-up if appropriate
                if let followUp = conversationManager.generateFollowUp(for: response, in: phase) {
                    await sendMessage(followUp, isUser: false)
                }
                
                // Check if we should transition to next phase
                await checkAndTransitionPhase()
            }
        } else {
            // No data extracted, ask for clarification
            await handleClarificationNeeded(message)
        }
        
        isProcessing = false
        conversationState = .waitingForUser
    }
    
    /// Handle user confirmation response
    func handleConfirmation(_ confirmed: Bool, for data: ExtractedData) async {
        if confirmed {
            var collection = ExtractedDataCollection()
            collection.add(data)
            await applyExtractedData(collection)
            await sendMessage("Great! Let's continue.", isUser: false)
            await checkAndTransitionPhase()
        } else {
            await sendMessage("No problem! Let's try again. \(phase.promptTemplate)", isUser: false)
        }
        conversationState = .waitingForUser
    }
    
    /// Skip current phase
    func skipCurrentPhase() async {
        await sendMessage("No problem, we can skip this for now.", isUser: false)
        await transitionToNextPhase()
    }
    
    /// Go back to previous phase
    func goToPreviousPhase() async {
        // This would need to track phase history
        // For now, just acknowledge the request
        await sendMessage("Let me help you with the previous question.", isUser: false)
    }
    
    // MARK: - Private Methods
    
    private func sendMessage(_ content: String, isUser: Bool) async {
        let message = ChatMessage(
            id: UUID(),
            content: content,
            isUser: isUser,
            timestamp: Date()
        )
        messages.append(message)
    }
    
    private func applyExtractedData(_ extractedData: ExtractedDataCollection) async {
        for data in extractedData.all {
            switch data.field {
            case .name:
                if let name = data.value as? String {
                    // Try to parse first and last name
                    let components = name.split(separator: " ")
                    collectedData.firstName = String(components.first ?? "")
                    if components.count > 1 {
                        collectedData.lastName = components.dropFirst().joined(separator: " ")
                    }
                }
            case .howDidYouHearAboutUs:
                collectedData.referralSource = data.value as? String
            case .currentStatus:
                collectedData.currentStatus = data.value as? String
            case .studentLevel:
                collectedData.educationLevel = data.value as? String
            case .interests:
                if let interests = data.value as? [String] {
                    collectedData.interests.formUnion(interests)
                }
            case .favoriteSubjects:
                if let subjects = data.value as? [String] {
                    collectedData.favoriteSubjects.formUnion(subjects)
                }
            case .extracurriculars:
                if let activities = data.value as? [String] {
                    collectedData.extracurriculars.formUnion(activities)
                }
            case .careerInterests:
                if let careers = data.value as? [String] {
                    collectedData.careerInterests.formUnion(careers)
                }
            default:
                break
            }
            
            // Update onboarding store
            updateOnboardingStore(field: data.field, value: data.value)
        }
    }
    
    private func updateOnboardingStore(field: OnboardingField, value: Any) {
        // Update the onboarding store with collected data
        onboardingStore.update(field: field, value: value, source: .ai)
    }
    
    private func handleConfirmationNeeded(_ extractedData: ExtractedDataCollection) async {
        if let firstData = extractedData.all.first {
            conversationState = .waitingForConfirmation(data: firstData)
            await sendMessage(firstData.confirmationMessage(), isUser: false)
        }
    }
    
    private func handleClarificationNeeded(_ originalMessage: String) async {
        let clarification = "I didn't quite understand that. Could you please rephrase or provide more details?"
        await sendMessage(clarification, isUser: false)
        
        // Track clarification request
        if let sessionId = sessionId {
            analytics.trackClarification(sessionId: sessionId, field: nil)
        }
    }
    
    private func handleError(_ error: Error) async {
        conversationState = .error(message: error.localizedDescription)
        await sendMessage("I encountered an issue. Let's try again.", isUser: false)
    }
    
    private func checkAndTransitionPhase() async {
        // Check if current phase requirements are met
        let requiredFields = phase.expectedDataTypes
        let allFieldsCollected = requiredFields.allSatisfy { field in
            collectedData.hasData(for: field)
        }
        
        if allFieldsCollected {
            await transitionToNextPhase()
        }
    }
    
    private func transitionToNextPhase() async {
        if let nextPhase = phase.nextPhase {
            // Track phase completion
            if let sessionId = sessionId {
                analytics.trackPhaseTransition(sessionId: sessionId, from: phase, to: nextPhase)
            }
            
            phase = nextPhase
            
            // Update quick reply suggestions for the new phase
            updateQuickReplySuggestions()
            
            // Send the prompt for the new phase
            if phase.requiresUserInput {
                let prompt = personalizePrompt(phase.promptTemplate)
                await sendMessage(prompt, isUser: false)
                conversationState = .waitingForUser
            } else {
                // Handle non-input phases (like completion)
                if phase == .completion {
                    await completeOnboarding()
                }
            }
        }
    }
    
    private func updateQuickReplySuggestions() {
        // Get context-aware suggestions
        let context = conversationManager.getRelevantContext(for: phase)
        
        // Base suggestions on phase and context
        switch phase {
        case .askingReferralSource:
            quickReplySuggestions = ["Friend", "Family", "School", "Social Media", "Google Search"]
        case .askingCurrentStatus:
            quickReplySuggestions = ["Student", "Working", "Both", "Neither"]
        case .askingEducationLevel:
            quickReplySuggestions = ["High School", "College", "Graduate School", "Other"]
        case .confirmingName:
            quickReplySuggestions = ["Yes", "No"]
        case .reviewingProfile:
            quickReplySuggestions = ["Everything looks good", "Make changes"]
        default:
            quickReplySuggestions = []
        }
    }
    
    private func personalizePrompt(_ template: String) -> String {
        var prompt = template
        
        // Replace placeholders with actual data
        if let name = collectedData.firstName {
            prompt = prompt.replacingOccurrences(of: "{name}", with: name)
        }
        
        return prompt
    }
    
    private func completeOnboarding() async {
        conversationState = .completed
        await sendMessage("🎉 " + phase.promptTemplate, isUser: false)
        
        // Track session completion
        if let sessionId = sessionId {
            analytics.completeSession(sessionId: sessionId, reason: .successful)
        }
        
        // Sync final data to onboarding store
        syncAllDataToStore()
    }
    
    func syncAllDataToStore() {
        // Sync all collected data to the onboarding store
        let dataDict = collectedData.toDictionary()
        for (key, value) in dataDict {
            if let field = OnboardingField(rawValue: key) {
                onboardingStore.update(field: field, value: value, source: .ai)
            }
        }
    }
    
    /// Cancel the onboarding process
    func cancelOnboarding() {
        if let sessionId = sessionId {
            analytics.completeSession(sessionId: sessionId, reason: .abandoned)
        }
        conversationState = .idle
    }
    
    /// Clean up when view disappears (potential abandonment)
    func handleViewDisappear() {
        if conversationState != .completed && conversationState != .idle {
            if let sessionId = sessionId {
                analytics.completeSession(sessionId: sessionId, reason: .abandoned)
            }
        }
    }
}

// MARK: - Supporting Types

//private struct ExtractedDataCollection {
//    let items: [ExtractedData]
//    
//    var all: [ExtractedData] { items }
//    var isEmpty: Bool { items.isEmpty }
//    var needsConfirmation: Bool { items.contains { !$0.isHighConfidence } }
//}
