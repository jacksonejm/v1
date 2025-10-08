import Foundation

/// Represents a skill required for a specific occupation
/// Returned by Snowflake SP_GET_CAREER_SKILLS procedure
struct CareerSkill: Codable, Identifiable, Hashable {
    let skill: String
    let importance: Double
    let level: Double

    /// Unique identifier (uses skill name as ID)
    var id: String { skill }

    /// Format importance as percentage (0-100)
    var importancePercentage: Int {
        // O*NET importance scale is 0-5, so we normalize to 0-100
        Int((importance / 5.0) * 100)
    }

    /// Format level as percentage (0-100)
    var levelPercentage: Int {
        // O*NET level scale is 0-7, so we normalize to 0-100
        Int((level / 7.0) * 100)
    }

    /// Importance level description
    var importanceLevel: SkillLevel {
        switch importance {
        case 0..<2:
            return .low
        case 2..<3:
            return .medium
        case 3..<4:
            return .high
        case 4...5:
            return .critical
        default:
            return .low
        }
    }

    /// Skill proficiency level description
    var proficiencyLevel: SkillLevel {
        switch level {
        case 0..<2:
            return .low
        case 2..<4:
            return .medium
        case 4..<6:
            return .high
        case 6...7:
            return .critical
        default:
            return .low
        }
    }

    /// Skill level enum
    enum SkillLevel: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"

        var color: String {
            switch self {
            case .low:
                return "gray"
            case .medium:
                return "blue"
            case .high:
                return "orange"
            case .critical:
                return "red"
            }
        }
    }
}
