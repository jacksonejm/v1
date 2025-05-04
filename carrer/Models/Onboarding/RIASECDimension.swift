import Foundation

enum RIASECDimension: String, CaseIterable {
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
}