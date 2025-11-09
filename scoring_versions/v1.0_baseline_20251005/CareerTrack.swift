import Foundation

/// Represents a career track that a user is following or exploring
/// Can be enhanced with O*NET occupation data for detailed career information
struct CareerTrack: Identifiable, Hashable, Codable {
    var id: UUID
    let title: String
    let progress: Int
    let salary: String
    let education: String
    let match: Int

    // O*NET integration fields
    var onetCode: String?
    var onetDescription: String?
    var primaryRIASEC: String?
    var secondaryRIASEC: String?
    var skills: [CareerSkill]?

    /// Initialize with basic information
    init(
        id: UUID = UUID(),
        title: String,
        progress: Int,
        salary: String,
        education: String,
        match: Int,
        onetCode: String? = nil,
        onetDescription: String? = nil,
        primaryRIASEC: String? = nil,
        secondaryRIASEC: String? = nil,
        skills: [CareerSkill]? = nil
    ) {
        self.id = id
        self.title = title
        self.progress = progress
        self.salary = salary
        self.education = education
        self.match = match
        self.onetCode = onetCode
        self.onetDescription = onetDescription
        self.primaryRIASEC = primaryRIASEC
        self.secondaryRIASEC = secondaryRIASEC
        self.skills = skills
    }

    /// Create a CareerTrack from an O*NET occupation
    static func from(onetOccupation: ONetOccupation, progress: Int = 0) -> CareerTrack {
        return CareerTrack(
            title: onetOccupation.title,
            progress: progress,
            salary: "Data not available", // Salary data would need to be added to O*NET
            education: "Varies", // Education requirements would need to be added
            match: onetOccupation.interestScorePercentage,
            onetCode: onetOccupation.code,
            onetDescription: onetOccupation.description,
            primaryRIASEC: onetOccupation.primaryMatch,
            secondaryRIASEC: onetOccupation.secondaryMatch
        )
    }

    /// Check if this career track has O*NET data
    var hasONetData: Bool {
        onetCode != nil
    }

    /// Get RIASEC match description
    var riasecMatch: String? {
        guard let primary = primaryRIASEC else { return nil }

        if let secondary = secondaryRIASEC {
            return "\(primary) + \(secondary)"
        }
        return primary
    }
}