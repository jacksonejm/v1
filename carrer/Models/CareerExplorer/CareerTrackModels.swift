import Foundation

// MARK: - User Skill Assessment

/// User's self-assessed skill level (for students/early career)
enum UserSkillLevel: Int, Codable, CaseIterable {
    case noExperience = 0    // Maps to 0-25 on O*NET scale
    case someExposure = 1    // Maps to 26-50
    case confident = 2       // Maps to 51-75
    case veryStrong = 3      // Maps to 76-100

    var label: String {
        switch self {
        case .noExperience: return "No experience"
        case .someExposure: return "Some exposure"
        case .confident: return "Confident"
        case .veryStrong: return "Very strong"
        }
    }

    var description: String {
        switch self {
        case .noExperience: return "I haven't done this"
        case .someExposure: return "I've tried this in class/projects"
        case .confident: return "I'm comfortable with this"
        case .veryStrong: return "This is a strength of mine"
        }
    }

    /// Convert to 0-100 scale for comparison with O*NET importance
    var numericValue: Int {
        switch self {
        case .noExperience: return 12    // midpoint of 0-25
        case .someExposure: return 38    // midpoint of 26-50
        case .confident: return 63       // midpoint of 51-75
        case .veryStrong: return 88      // midpoint of 76-100
        }
    }

    var icon: String {
        switch self {
        case .noExperience: return "circle"
        case .someExposure: return "circle.lefthalf.filled"
        case .confident: return "circle.righthalf.filled"
        case .veryStrong: return "circle.fill"
        }
    }
}

/// User's assessment of a specific skill
struct UserSkillAssessment: Codable, Hashable {
    let skillName: String
    let level: UserSkillLevel
    let assessedAt: Date

    init(skillName: String, level: UserSkillLevel, assessedAt: Date = Date()) {
        self.skillName = skillName
        self.level = level
        self.assessedAt = assessedAt
    }
}

/// Collection of user skill assessments (persisted)
struct UserSkillsData: Codable {
    var assessments: [String: UserSkillAssessment]  // skillName -> assessment

    init() {
        self.assessments = [:]
    }

    mutating func assess(skill: String, level: UserSkillLevel) {
        assessments[skill] = UserSkillAssessment(skillName: skill, level: level)
    }

    func level(for skill: String) -> UserSkillLevel? {
        assessments[skill]?.level
    }

    func hasAssessed(_ skill: String) -> Bool {
        assessments[skill] != nil
    }

    /// Get all assessed skills sorted by assessment date (newest first)
    var recentAssessments: [UserSkillAssessment] {
        assessments.values.sorted { $0.assessedAt > $1.assessedAt }
    }
}

/// Represents a gap between required skill level and user's current level
struct SkillGap: Identifiable {
    let id = UUID()
    let skill: CareerSkill
    let userLevel: UserSkillLevel?

    /// Gap size (0-100), positive means user needs to improve
    var gapSize: Int {
        guard let userLevel = userLevel else {
            // No assessment yet - assume beginner level for students
            return max(0, skill.importancePercentage - 25)
        }
        return max(0, skill.importancePercentage - userLevel.numericValue)
    }

    /// Whether this is a significant gap worth addressing
    var isSignificant: Bool {
        gapSize >= 20  // 20+ point gap is significant
    }

    var gapDescription: String {
        if gapSize >= 40 {
            return "Large gap"
        } else if gapSize >= 20 {
            return "Moderate gap"
        } else {
            return "Small gap"
        }
    }

    var gapColor: String {
        if gapSize >= 40 {
            return "red"
        } else if gapSize >= 20 {
            return "orange"
        } else {
            return "green"
        }
    }
}

// MARK: - Track Milestones

/// Major milestones in a career track journey
enum TrackMilestone: String, Codable, CaseIterable {
    case understandRole = "understand_role"
    case assessGaps = "assess_gaps"
    case planEducation = "plan_education"
    case doActivities = "do_activities"
    case prepareJobSearch = "prepare_job_search"

    var title: String {
        switch self {
        case .understandRole: return "Understand the role"
        case .assessGaps: return "Assess my gaps"
        case .planEducation: return "Plan education"
        case .doActivities: return "Do activities"
        case .prepareJobSearch: return "Prepare job search"
        }
    }

    var description: String {
        switch self {
        case .understandRole:
            return "Learn about the career's daily work, required skills, and work environment"
        case .assessGaps:
            return "Identify skills you need to develop for this career"
        case .planEducation:
            return "Confirm education requirements and plan your learning path"
        case .doActivities:
            return "Complete activities to build experience and close skill gaps"
        case .prepareJobSearch:
            return "Get ready to search and apply for positions"
        }
    }

    var icon: String {
        switch self {
        case .understandRole: return "book.fill"
        case .assessGaps: return "chart.bar.fill"
        case .planEducation: return "graduationcap.fill"
        case .doActivities: return "list.bullet.clipboard.fill"
        case .prepareJobSearch: return "briefcase.fill"
        }
    }
}

// MARK: - Task Types

/// Types of actionable tasks within a track
enum TaskType: String, Codable {
    case learn
    case compare
    case closeGap
    case plan
    case prepare

    var icon: String {
        switch self {
        case .learn: return "book.fill"
        case .compare: return "arrow.left.arrow.right"
        case .closeGap: return "arrow.up.circle.fill"
        case .plan: return "calendar"
        case .prepare: return "checklist"
        }
    }
}

/// Status of a task
enum TaskStatus: String, Codable {
    case todo
    case inProgress = "in_progress"
    case done
}

// MARK: - Track Task

/// An actionable task within a career track
struct TrackTask: Codable, Identifiable, Hashable {
    let id: String
    let milestone: TrackMilestone
    let type: TaskType
    let title: String
    let payload: [String: String]?
    var status: TaskStatus
    var completedAt: Date?

    init(
        id: String = UUID().uuidString,
        milestone: TrackMilestone,
        type: TaskType,
        title: String,
        payload: [String: String]? = nil,
        status: TaskStatus = .todo
    ) {
        self.id = id
        self.milestone = milestone
        self.type = type
        self.title = title
        self.payload = payload
        self.status = status
        self.completedAt = nil
    }

    var isDone: Bool {
        status == .done
    }
}
