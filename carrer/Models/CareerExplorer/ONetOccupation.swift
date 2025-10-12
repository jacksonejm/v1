import Foundation

/// Represents an occupation from the O*NET database with Recipe D v4.0 multi-dimensional matching
/// Returned by Snowflake SP_GET_CAREER_MATCHES_V4 procedure
struct ONetOccupation: Codable, Identifiable, Hashable {
    let onetSocCode: String
    let title: String
    let description: String
    let match: Int  // Overall match percentage (0-100)
    let education: String?
    let outlook: String?
    let salary: String?

    // Recipe D v4.0: Multi-dimensional match scores
    let matchExplanation: String?  // "I:85% V:75% S:80% C:90%"
    let interestsMatch: Double?  // RIASEC interests match (0.0-1.0)
    let valuesMatch: Double?  // Work values match (0.0-1.0)
    let skillsMatch: Double?  // Skills match from subjects/activities (0.0-1.0)
    let contextScore: Double?  // Context boost from education/interests (0.0-1.0)

    /// Unique identifier (uses code as ID)
    var id: String { onetSocCode }

    /// Short description (first 150 characters)
    var shortDescription: String {
        if description.count > 150 {
            return String(description.prefix(150)) + "..."
        }
        return description
    }

    /// Overall match percentage (already 0-100 scale)
    var matchPercentage: Int {
        match
    }

    /// Individual dimension match percentages
    var interestsPercentage: Int {
        Int((interestsMatch ?? 0) * 100)
    }

    var valuesPercentage: Int {
        Int((valuesMatch ?? 0) * 100)
    }

    var skillsPercentage: Int {
        Int((skillsMatch ?? 0) * 100)
    }

    var contextPercentage: Int {
        Int((contextScore ?? 0) * 100)
    }

    /// Match quality description
    var matchQuality: String {
        switch match {
        case 90...100: return "Excellent Match"
        case 80..<90: return "Great Match"
        case 70..<80: return "Good Match"
        case 60..<70: return "Moderate Match"
        default: return "Fair Match"
        }
    }

    /// Match quality color
    var matchColor: String {
        switch match {
        case 90...100: return "green"
        case 80..<90: return "blue"
        case 70..<80: return "purple"
        case 60..<70: return "orange"
        default: return "gray"
        }
    }

    // MARK: - Initializer

    init(
        onetSocCode: String,
        title: String,
        description: String,
        match: Int,
        education: String? = nil,
        outlook: String? = nil,
        salary: String? = nil,
        matchExplanation: String? = nil,
        interestsMatch: Double? = nil,
        valuesMatch: Double? = nil,
        skillsMatch: Double? = nil,
        contextScore: Double? = nil
    ) {
        self.onetSocCode = onetSocCode
        self.title = title
        self.description = description
        self.match = match
        self.education = education
        self.outlook = outlook
        self.salary = salary
        self.matchExplanation = matchExplanation
        self.interestsMatch = interestsMatch
        self.valuesMatch = valuesMatch
        self.skillsMatch = skillsMatch
        self.contextScore = contextScore
    }
}
