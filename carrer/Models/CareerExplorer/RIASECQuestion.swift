import Foundation

enum RIASECQuestion: CaseIterable, Hashable {
    case realistic(String, ScaleType)
    case investigative(String, ScaleType)
    case artistic(String, ScaleType)
    case social(String, ScaleType)
    case enterprising(String, ScaleType)
    case conventional(String, ScaleType)

    enum ScaleType {
        case agreement
        case frequency
    }

    var text: String {
        switch self {
        case .realistic(let question, _),
             .investigative(let question, _),
             .artistic(let question, _),
             .social(let question, _),
             .enterprising(let question, _),
             .conventional(let question, _):
            return question
        }
    }

    var category: String {
        switch self {
        case .realistic:
            return "Realistic"
        case .investigative:
            return "Investigative"
        case .artistic:
            return "Artistic"
        case .social:
            return "Social"
        case .enterprising:
            return "Enterprising"
        case .conventional:
            return "Conventional"
        }
    }

    var scaleType: ScaleType {
        switch self {
        case .realistic(_, let scale),
             .investigative(_, let scale),
             .artistic(_, let scale),
             .social(_, let scale),
             .enterprising(_, let scale),
             .conventional(_, let scale):
            return scale
        }
    }

    static var allCases: [RIASECQuestion] {
        return [
            // Realistic
            .realistic("Do you enjoy working with your hands?", .agreement),
            .realistic("Do you like repairing things?", .agreement),
            .realistic("How often do you participate in physical activities?", .frequency),
            // Investigative
            .investigative("Do you enjoy solving puzzles?", .agreement),
            .investigative("Do you like conducting experiments?", .agreement),
            .investigative("How often do you read science articles?", .frequency),
            // Artistic
            .artistic("Do you enjoy creative activities like drawing or painting?", .agreement),
            .artistic("Do you like writing stories or poetry?", .agreement),
            .artistic("How often do you participate in artistic events?", .frequency),
            // Social
            .social("Do you enjoy helping others?", .agreement),
            .social("Do you like teaching or instructing people?", .agreement),
            .social("How often do you volunteer in community services?", .frequency),
            // Enterprising
            .enterprising("Do you enjoy leading groups?", .agreement),
            .enterprising("Do you like persuading others?", .agreement),
            .enterprising("How often do you participate in leadership roles?", .frequency),
            // Conventional
            .conventional("Do you enjoy organizing things?", .agreement),
            .conventional("Do you like working with data or numbers?", .agreement),
            .conventional("How often do you create plans or schedules?", .frequency)
        ]
    }
}