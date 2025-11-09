import Foundation

enum RIASECDimension: String, CaseIterable, Codable, Hashable {
    case realistic = "Realistic"
    case investigative = "Investigative"
    case artistic = "Artistic"
    case social = "Social"
    case enterprising = "Enterprising"
    case conventional = "Conventional"
    
    var title: String {
        switch self {
        case .realistic: return "Do You Enjoy Hands-On Work?"
        case .investigative: return "Are You Analytical?"
        case .artistic: return "Do You Like Creative Activities?"
        case .social: return "Do You Enjoy Helping Others?"
        case .enterprising: return "Are You a Natural Leader?"
        case .conventional: return "Do You Like Structure?"
        }
    }
    
    var prompt: String {
        switch self {
        case .realistic: return "Do you enjoy activities like fixing or building things?"
        case .investigative: return "Do you like solving complex problems and researching?"
        case .artistic: return "Do you enjoy expressing yourself creatively?"
        case .social: return "Do you prefer working with and helping others?"
        case .enterprising: return "Do you like leading and persuading others?"
        case .conventional: return "Do you enjoy organizing and following procedures?"
        }
    }

    /// The three questions used for this RIASEC dimension
    var questions: [String] {
        switch self {
        case .realistic:
            return [
                "I enjoy working with my hands or tools",
                "I like repairing things",
                "I prefer practical, hands-on problems over abstract ones",
            ]
        case .investigative:
            return [
                "I enjoy solving puzzles or complex problems",
                "I like to analyze information and data",
                "I'm curious about how things work",
            ]
        case .artistic:
            return [
                "I appreciate creativity and self-expression",
                "I enjoy artistic activities like writing, music, or design",
                "I tend to think outside the box",
            ]
        case .social:
            return [
                "I enjoy helping others learn or grow",
                "I'm good at understanding how people feel",
                "I like working in groups or teams",
            ]
        case .enterprising:
            return [
                "I enjoy persuading or leading others",
                "I like starting or organizing activities",
                "I'm comfortable taking risks",
            ]
        case .conventional:
            return [
                "I enjoy working with clear rules and structure",
                "I'm good at organizing information or data",
                "I pay attention to details and accuracy",
            ]
        }
    }
}