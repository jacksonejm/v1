import Foundation

/// Represents the available onboarding modes
enum OnboardingMode: String, CaseIterable, Codable {
    case unselected = "unselected"
    case conversational = "conversational"
    case traditional = "traditional"
    
    var displayName: String {
        switch self {
        case .unselected:
            return "Choose Mode"
        case .conversational:
            return "AI Conversation"
        case .traditional:
            return "Traditional Forms"
        }
    }
    
    var description: String {
        switch self {
        case .unselected:
            return "Select how you'd like to get started"
        case .conversational:
            return "Have a natural conversation with our AI assistant"
        case .traditional:
            return "Fill out step-by-step forms"
        }
    }
    
    var iconName: String {
        switch self {
        case .unselected:
            return "questionmark.circle"
        case .conversational:
            return "bubble.left.and.bubble.right.fill"
        case .traditional:
            return "doc.text.fill"
        }
    }
}