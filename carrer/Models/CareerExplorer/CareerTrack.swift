import Foundation

// MARK: - Match Tier

/// Match tier for qualitative display of career match strength
/// Replaces numeric percentages in UI while keeping scores for ranking
enum MatchTier: String, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"

    /// Localized display label
    var label: String {
        switch self {
        case .high: return "High match"
        case .medium: return "Medium match"
        case .low: return "Low match"
        }
    }

    /// Analytics string value
    var analyticsValue: String {
        return rawValue
    }

    /// Convert numeric score (0-100) to qualitative tier
    /// - High: score >= 80
    /// - Medium: 70 <= score < 80
    /// - Low: score < 70
    static func from(score: Int) -> MatchTier {
        switch score {
        case 80...100:
            return .high
        case 70..<80:
            return .medium
        default:
            return .low
        }
    }
}

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

    // Career Track (planning) fields
    var trackedAt: Date?
    var tasks: [TrackTask]?
    var userNotes: String?
    var isArchived: Bool

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
        skills: [CareerSkill]? = nil,
        trackedAt: Date? = nil,
        tasks: [TrackTask]? = nil,
        userNotes: String? = nil,
        isArchived: Bool = false
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
        self.trackedAt = trackedAt
        self.tasks = tasks
        self.userNotes = userNotes
        self.isArchived = isArchived
    }

    /// Create a CareerTrack from an O*NET occupation (Recipe D v4.0)
    static func from(onetOccupation: ONetOccupation, progress: Int = 0) -> CareerTrack {
        return CareerTrack(
            title: onetOccupation.title,
            progress: progress,
            salary: onetOccupation.salary ?? "Data not available",
            education: onetOccupation.education ?? "Varies",
            match: onetOccupation.match,  // Overall match percentage from Recipe D v4.0
            onetCode: onetOccupation.onetSocCode,
            onetDescription: onetOccupation.description,
            primaryRIASEC: nil,  // Recipe D v4.0 uses multi-dimensional matching
            secondaryRIASEC: nil,  // Recipe D v4.0 uses multi-dimensional matching
            skills: nil,  // Skills data would need to be fetched separately
            trackedAt: nil,  // Not tracked by default
            tasks: nil,
            userNotes: nil,
            isArchived: false
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

    // MARK: - Match Tier Display (v4.0 Enhancement)

    /// Qualitative match tier based on numeric score
    /// - High: 80-100%
    /// - Medium: 70-79%
    /// - Low: <70%
    var matchTier: MatchTier {
        return MatchTier.from(score: match)
    }

    /// Check if career has career interest boost applied
    /// This is determined by comparing career title with user's career interests
    var isBoosted: Bool {
        // This will be set by the view model based on active interests
        // For now, return false - will be computed in view
        return false
    }

    // MARK: - Career Track (Planning) Computed Properties

    /// Computed progress based on completed tasks
    var trackProgress: Double {
        guard let tasks = tasks, !tasks.isEmpty else { return 0.0 }
        let completed = tasks.filter { $0.isDone }.count
        return Double(completed) / Double(tasks.count)
    }

    /// Whether this career is currently being tracked
    var isTracked: Bool {
        trackedAt != nil && !isArchived
    }

    /// Get next 3 incomplete tasks
    var nextSteps: [TrackTask] {
        guard let tasks = tasks else { return [] }
        return Array(tasks.filter { !$0.isDone }.prefix(3))
    }

    /// Count of completed tasks
    var completedTaskCount: Int {
        tasks?.filter { $0.isDone }.count ?? 0
    }

    /// Total task count
    var totalTaskCount: Int {
        tasks?.count ?? 0
    }
}