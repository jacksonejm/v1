import Foundation

/// Represents an occupation from the O*NET database
/// Returned by Snowflake SP_GET_CAREER_MATCHES procedure
struct ONetOccupation: Codable, Identifiable, Hashable {
    let code: String
    let title: String
    let description: String
    let interestScore: Double
    let primaryMatch: String
    let secondaryMatch: String

    /// Unique identifier (uses code as ID)
    var id: String { code }

    /// Short description (first 150 characters)
    var shortDescription: String {
        if description.count > 150 {
            return String(description.prefix(150)) + "..."
        }
        return description
    }

    /// Format the interest score as a percentage
    /// O*NET interest scores are on a 0-7 scale
    var interestScorePercentage: Int {
        Int((interestScore / 7.0) * 100)
    }

    /// Primary RIASEC type emoji
    var primaryEmoji: String {
        riasecEmoji(for: primaryMatch)
    }

    /// Secondary RIASEC type emoji
    var secondaryEmoji: String {
        riasecEmoji(for: secondaryMatch)
    }

    /// Combined RIASEC match description
    var matchDescription: String {
        "\(primaryMatch) + \(secondaryMatch)"
    }

    // MARK: - Helper Methods

    private func riasecEmoji(for type: String) -> String {
        switch type.lowercased() {
        case "realistic":
            return "🔧"
        case "investigative":
            return "🔬"
        case "artistic":
            return "🎨"
        case "social":
            return "👥"
        case "enterprising":
            return "💼"
        case "conventional":
            return "📊"
        default:
            return "💡"
        }
    }
}
