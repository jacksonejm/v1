import Foundation

/// Represents the different phases of the conversational onboarding flow
enum ConversationPhase: String, CaseIterable, Codable {
    case welcome
    case gettingName
    case confirmingName
    case askingReferralSource
    case askingCurrentStatus
    case askingEducationLevel
    case exploringInterests
    case assessingRIASEC
    case discussingSubjects
    case exploringActivities
    case exploringCareers
    case reviewingProfile
    case completion
    
    /// The expected data fields for this phase
    var expectedDataTypes: [OnboardingField] {
        switch self {
        case .welcome:
            return []
        case .gettingName, .confirmingName:
            return [.name]
        case .askingReferralSource:
            return [.howDidYouHearAboutUs]
        case .askingCurrentStatus:
            return [.currentStatus]
        case .askingEducationLevel:
            return [.studentLevel]
        case .exploringInterests:
            return [.interests]
        case .assessingRIASEC:
            return [.riasecResponses_realistic, .riasecResponses_investigative,
                    .riasecResponses_artistic, .riasecResponses_social,
                    .riasecResponses_enterprising, .riasecResponses_conventional]
        case .discussingSubjects:
            return [.favoriteSubjects]
        case .exploringActivities:
            return [.extracurriculars]
        case .exploringCareers:
            return [.careerInterests]
        case .reviewingProfile, .completion:
            return []
        }
    }
    
    /// The initial prompt template for this phase
    var promptTemplate: String {
        switch self {
        case .welcome:
            return "Hi! I'm your MyPath assistant. I'll help you create your profile through a friendly conversation. What should I call you?"
        case .gettingName:
            return "What's your name?"
        case .confirmingName:
            return "Nice to meet you, {name}! Did I get your name right?"
        case .askingReferralSource:
            return "Great! Before we dive in, I'm curious - how did you hear about MyPath?"
        case .askingCurrentStatus:
            return "Thanks for sharing that! Now, to help me understand your situation better, are you currently a student, working, or doing something else?"
        case .askingEducationLevel:
            return "What level of education are you currently pursuing?"
        case .exploringInterests:
            return "Let's talk about what interests you! What kind of activities or subjects do you find yourself drawn to?"
        case .assessingRIASEC:
            return "I'd like to understand your preferences better. Let me ask you a few quick questions about activities you might enjoy."
        case .discussingSubjects:
            return "What are your favorite subjects to study or learn about?"
        case .exploringActivities:
            return "Outside of academics, what activities do you participate in? This could be clubs, sports, hobbies, or anything else you enjoy doing."
        case .exploringCareers:
            return "Based on what you've told me, I'm curious - have you thought about what kind of career might interest you?"
        case .reviewingProfile:
            return "Great! Let me summarize what I've learned about you. Please let me know if I should change anything."
        case .completion:
            return "Perfect! I've created your personalized career exploration profile. You're all set to start discovering career paths that match your interests and strengths!"
        }
    }
    
    /// The next phase in the conversation flow
    var nextPhase: ConversationPhase? {
        switch self {
        case .welcome: return .gettingName
        case .gettingName: return .confirmingName
        case .confirmingName: return .askingReferralSource
        case .askingReferralSource: return .askingCurrentStatus
        case .askingCurrentStatus: return .askingEducationLevel
        case .askingEducationLevel: return .exploringInterests
        case .exploringInterests: return .assessingRIASEC
        case .assessingRIASEC: return .discussingSubjects
        case .discussingSubjects: return .exploringActivities
        case .exploringActivities: return .exploringCareers
        case .exploringCareers: return .reviewingProfile
        case .reviewingProfile: return .completion
        case .completion: return nil
        }
    }
    
    /// Whether this phase requires user input
    var requiresUserInput: Bool {
        switch self {
        case .welcome, .completion:
            return false
        default:
            return true
        }
    }
}