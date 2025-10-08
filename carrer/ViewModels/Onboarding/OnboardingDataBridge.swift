import Foundation
import SwiftUI

/// Manages bidirectional data synchronization between conversational and traditional onboarding modes
@MainActor
class OnboardingDataBridge: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isSyncing = false
    @Published var lastSyncTime: Date?
    
    // MARK: - Public Methods
    
    /// Sync data from conversational onboarding to traditional forms
    func syncFromConversation(
        _ conversationData: OnboardingData,
        to formStore: OnboardingStore
    ) {
        isSyncing = true
        defer { isSyncing = false }
        
        // Map basic information
        if let firstName = conversationData.firstName {
            formStore.update(field: .name, value: firstName, source: .ai)
        }
        
        if let status = conversationData.currentStatus {
            formStore.update(field: .currentStatus, value: status, source: .ai)
        }
        
        if let level = conversationData.educationLevel {
            formStore.update(field: .studentLevel, value: level, source: .ai)
        }
        
        // Map interests and subjects
        if !conversationData.interests.isEmpty {
            formStore.update(field: .interests, value: Array(conversationData.interests), source: .ai)
        }
        
        if !conversationData.favoriteSubjects.isEmpty {
            formStore.update(field: .favoriteSubjects, value: Array(conversationData.favoriteSubjects), source: .ai)
        }
        
        // Map career interests
        if !conversationData.careerInterests.isEmpty {
            formStore.update(field: .careerInterests, value: Array(conversationData.careerInterests), source: .ai)
        }
        
        // Map extracurriculars
        if !conversationData.extracurriculars.isEmpty {
            formStore.update(field: .extracurriculars, value: Array(conversationData.extracurriculars), source: .ai)
        }
        
        // Map RIASEC responses
        if !conversationData.riasecResponses.isEmpty {
            // Convert string keys to dimension-based fields
            for (key, value) in conversationData.riasecResponses {
                if key.contains("realistic") {
                    formStore.update(field: .riasecResponses_realistic, value: [value], source: .ai)
                } else if key.contains("investigative") {
                    formStore.update(field: .riasecResponses_investigative, value: [value], source: .ai)
                } else if key.contains("artistic") {
                    formStore.update(field: .riasecResponses_artistic, value: [value], source: .ai)
                } else if key.contains("social") {
                    formStore.update(field: .riasecResponses_social, value: [value], source: .ai)
                } else if key.contains("enterprising") {
                    formStore.update(field: .riasecResponses_enterprising, value: [value], source: .ai)
                } else if key.contains("conventional") {
                    formStore.update(field: .riasecResponses_conventional, value: [value], source: .ai)
                }
            }
        }
        
        // The form store will automatically determine the next step
        // based on the data we've synced
        
        lastSyncTime = Date()
    }
    
    /// Sync data from traditional forms to conversational onboarding
    func syncFromForms(
        _ formStore: OnboardingStore,
        to engine: ConversationalOnboardingEngine
    ) async {
        isSyncing = true
        defer { isSyncing = false }
        
        // Create OnboardingData from form store
        var onboardingData = OnboardingData()
        
        // Map form fields to conversation data
        if let name: String = formStore.value(for: .name) {
            onboardingData.firstName = name
        }
        
        if let status: String = formStore.value(for: .currentStatus) {
            onboardingData.currentStatus = status
        }
        
        if let level: String = formStore.value(for: .studentLevel) {
            onboardingData.educationLevel = level
        }
        
        if let interests: [String] = formStore.value(for: .interests) {
            onboardingData.interests = Set(interests)
        }
        
        if let subjects: [String] = formStore.value(for: .favoriteSubjects) {
            onboardingData.favoriteSubjects = Set(subjects)
        }
        
        if let careers: [String] = formStore.value(for: .careerInterests) {
            onboardingData.careerInterests = Set(careers)
        }
        
        if let activities: [String] = formStore.value(for: .extracurriculars) {
            onboardingData.extracurriculars = Set(activities)
        }
        
        // Map RIASEC responses
        if let realistic: [Int] = formStore.value(for: .riasecResponses_realistic),
           let firstScore = realistic.first {
            onboardingData.riasecResponses["realistic"] = firstScore
        }
        if let investigative: [Int] = formStore.value(for: .riasecResponses_investigative),
           let firstScore = investigative.first {
            onboardingData.riasecResponses["investigative"] = firstScore
        }
        if let artistic: [Int] = formStore.value(for: .riasecResponses_artistic),
           let firstScore = artistic.first {
            onboardingData.riasecResponses["artistic"] = firstScore
        }
        if let social: [Int] = formStore.value(for: .riasecResponses_social),
           let firstScore = social.first {
            onboardingData.riasecResponses["social"] = firstScore
        }
        if let enterprising: [Int] = formStore.value(for: .riasecResponses_enterprising),
           let firstScore = enterprising.first {
            onboardingData.riasecResponses["enterprising"] = firstScore
        }
        if let conventional: [Int] = formStore.value(for: .riasecResponses_conventional),
           let firstScore = conventional.first {
            onboardingData.riasecResponses["conventional"] = firstScore
        }
        
        // Determine conversation phase based on form progress
        let phase = determineConversationPhase(from: formStore)
        
        // Generate appropriate resume prompt
        let resumePrompt = generateResumePrompt(for: phase, with: onboardingData)
        
        // Resume the conversation with the synced data
        await engine.resumeWithContext(
            phase: phase,
            resumePrompt: resumePrompt,
            existingData: onboardingData
        )
        
        lastSyncTime = Date()
    }
    
    // MARK: - Private Methods
    
    private func determineFormStep(from conversationData: OnboardingData) -> OnboardingStep {
        // Determine the next appropriate form step based on what data we have
        
        if conversationData.firstName == nil {
            return .getName
        }
        
        if conversationData.currentStatus == nil {
            return .currentStatus
        }
        
        if conversationData.educationLevel == nil && conversationData.currentStatus == "student" {
            return .studentLevel
        }
        
        if conversationData.careerInterests.isEmpty {
            return .careerInterests
        }
        
        if conversationData.favoriteSubjects.isEmpty {
            return .favoriteSubjects
        }
        
        if conversationData.extracurriculars.isEmpty {
            return .extracurriculars
        }
        
        if conversationData.riasecResponses.isEmpty {
            return .riasecQuestions(dimension: .realistic)
        }
        
        return .completionScreen
    }
    
    private func determineConversationPhase(from formStore: OnboardingStore) -> ConversationPhase {
        // Map form progress to conversation phase
        let completedFields = formStore.values.keys
        
        if completedFields.isEmpty {
            return .welcome
        }
        
        if !completedFields.contains(.name) {
            return .gettingName
        }
        
        if !completedFields.contains(.howDidYouHearAboutUs) {
            return .askingReferralSource
        }
        
        if !completedFields.contains(.currentStatus) {
            return .askingCurrentStatus
        }
        
        if !completedFields.contains(.studentLevel) && formStore.values[.currentStatus] as? String == "student" {
            return .askingEducationLevel
        }
        
        if !completedFields.contains(.interests) {
            return .exploringInterests
        }
        
        let hasAllRiasec = [
            OnboardingField.riasecResponses_realistic,
            .riasecResponses_investigative,
            .riasecResponses_artistic,
            .riasecResponses_social,
            .riasecResponses_enterprising,
            .riasecResponses_conventional
        ].allSatisfy { completedFields.contains($0) }
        
        if !hasAllRiasec {
            return .assessingRIASEC
        }
        
        if !completedFields.contains(.favoriteSubjects) {
            return .discussingSubjects
        }
        
        if !completedFields.contains(.extracurriculars) {
            return .exploringActivities
        }
        
        if !completedFields.contains(.careerInterests) {
            return .exploringCareers
        }
        
        return .completion
    }
    
    private func generateResumePrompt(
        for phase: ConversationPhase,
        with data: OnboardingData
    ) -> String {
        let prompt = "Welcome back! I see you've been working on your profile. "
        
        switch phase {
        case .welcome:
            return "Hi! I'm here to help you create your profile. Let's start fresh - what's your name?"
            
        case .gettingName:
            return "\(prompt)Let's continue getting to know you. What's your name?"
            
        case .confirmingName:
            if let name = data.firstName {
                return "\(prompt)Nice to meet you, \(name)! Let's continue where we left off."
            } else {
                return "\(prompt)Let's confirm your name."
            }
            
        case .askingReferralSource:
            return "\(prompt)How did you hear about MyPath?"
            
        case .askingCurrentStatus:
            return "\(prompt)What are you currently doing - are you in school, working, or something else?"
            
        case .askingEducationLevel:
            return "\(prompt)What level of education are you currently pursuing?"
            
        case .exploringInterests:
            if let name = data.firstName {
                return "\(prompt)\(name), we were talking about your interests. What subjects or activities do you enjoy most?"
            } else {
                return "\(prompt)We were exploring your interests. What subjects or activities excite you?"
            }
            
        case .assessingRIASEC:
            return "\(prompt)Now I'd like to understand your work style preferences. Let me ask you a few questions about how you like to work and what motivates you."
            
        case .discussingSubjects:
            return "\(prompt)What are your favorite subjects to study or learn about?"
            
        case .exploringActivities:
            return "\(prompt)What activities do you participate in outside of academics?"
            
        case .exploringCareers:
            return "\(prompt)Let's talk about your career interests. What kind of work or careers have caught your attention?"
            
        case .reviewingProfile:
            return "\(prompt)Let me summarize what we've learned about you."
            
        case .completion:
            return "\(prompt)It looks like we've gathered all the information we need! Let me summarize what we've learned about you."
        }
    }
}