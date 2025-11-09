import Foundation

/// Represents the user's country for occupation data localization
enum UserCountry: String, Codable, CaseIterable, Identifiable {
    case usa = "United States"
    case canada = "Canada"

    var id: String { rawValue }

    /// Flag emoji for the country
    var flag: String {
        switch self {
        case .usa: return "🇺🇸"
        case .canada: return "🇨🇦"
        }
    }

    /// Short code for the country
    var code: String {
        switch self {
        case .usa: return "US"
        case .canada: return "CA"
        }
    }

    /// Whether this country uses NOC (Canadian occupational data)
    var usesNOC: Bool {
        self == .canada
    }

    /// Whether this country supports bilingual content (English/French)
    var supportsBilingual: Bool {
        self == .canada
    }

    /// Display name with flag
    var displayName: String {
        "\(flag) \(rawValue)"
    }
}
