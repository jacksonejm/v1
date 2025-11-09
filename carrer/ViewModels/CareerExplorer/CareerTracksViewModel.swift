import Foundation
import SwiftUI

/// Manages career tracks, tasks, and skill assessments
@MainActor
class CareerTracksViewModel: ObservableObject {
    @Published var trackedCareers: [CareerTrack] = []
    @Published var skillsData: UserSkillsData = UserSkillsData()

    let appViewModel: AppViewModel  // Made internal for Canadian context access
    private let maxActiveTracks = 3
    private let analytics = AnalyticsService.shared

    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        loadTrackedCareers()
        loadSkillsData()
    }

    // MARK: - Track Management

    /// Add a career to tracked list with generated tasks
    func addTrack(career: CareerTrack) throws -> CareerTrack {
        // Check limit
        let activeTracks = trackedCareers.filter { $0.isTracked && !$0.isArchived }
        guard activeTracks.count < maxActiveTracks else {
            throw TrackError.limitReached(max: maxActiveTracks)
        }

        // Check if already tracked
        guard !isTracked(careerId: career.id) else {
            throw TrackError.alreadyTracked
        }

        // Create tracked version with tasks
        var tracked = career
        tracked.trackedAt = Date()
        tracked.tasks = generateDefaultTasks(for: career)
        tracked.isArchived = false

        // Add to list and persist
        trackedCareers.append(tracked)
        saveTrackedCareers()

        // Track analytics
        analytics.trackCareerAdded(
            careerTitle: career.title,
            matchPercentage: career.match,
            matchTier: career.matchTier.rawValue,
            isTopMatch: career.match >= 85,  // Top match threshold
            activeTracksCount: activeTracks.count + 1
        )

        return tracked
    }

    /// Remove a career from tracked list
    func removeTrack(careerId: UUID) {
        trackedCareers.removeAll { $0.id == careerId }
        saveTrackedCareers()
    }

    /// Archive a track (mark as completed/abandoned but keep history)
    func archiveTrack(careerId: UUID) {
        if let index = trackedCareers.firstIndex(where: { $0.id == careerId }) {
            let track = trackedCareers[index]

            // Calculate days tracked
            let daysTracked = Calendar.current.dateComponents(
                [.day],
                from: track.trackedAt ?? Date(),
                to: Date()
            ).day ?? 0

            trackedCareers[index].isArchived = true
            saveTrackedCareers()

            // Track analytics
            analytics.trackCareerArchived(
                careerTitle: track.title,
                completionPercentage: Int(track.trackProgress * 100),
                tasksCompleted: track.completedTaskCount,
                totalTasks: track.totalTaskCount,
                daysTracked: daysTracked
            )
        }
    }

    /// Check if a career is currently tracked
    func isTracked(careerId: UUID) -> Bool {
        trackedCareers.contains { $0.id == careerId && $0.isTracked }
    }

    /// Get a specific tracked career
    func getTrack(careerId: UUID) -> CareerTrack? {
        trackedCareers.first { $0.id == careerId }
    }

    /// Get all active (non-archived) tracks
    var activeTracks: [CareerTrack] {
        trackedCareers.filter { $0.isTracked && !$0.isArchived }
    }

    // MARK: - Task Management

    /// Mark a task as complete
    func completeTask(taskId: String, careerId: UUID) {
        guard let trackIndex = trackedCareers.firstIndex(where: { $0.id == careerId }),
              let taskIndex = trackedCareers[trackIndex].tasks?.firstIndex(where: { $0.id == taskId }) else {
            return
        }

        let task = trackedCareers[trackIndex].tasks![taskIndex]
        let track = trackedCareers[trackIndex]

        trackedCareers[trackIndex].tasks?[taskIndex].status = .done
        trackedCareers[trackIndex].tasks?[taskIndex].completedAt = Date()
        saveTrackedCareers()

        // Track analytics
        analytics.trackTaskCompleted(
            careerTitle: track.title,
            milestone: task.milestone.rawValue,
            taskType: task.type.rawValue,
            taskTitle: task.title,
            completionPercentage: Int(trackedCareers[trackIndex].trackProgress * 100)
        )

        // Check if milestone was just completed
        checkMilestoneCompletion(
            milestone: task.milestone,
            trackIndex: trackIndex
        )
    }

    /// Check if a milestone was just completed and track analytics
    private func checkMilestoneCompletion(milestone: TrackMilestone, trackIndex: Int) {
        let milestoneTasks = trackedCareers[trackIndex].tasks?.filter { $0.milestone == milestone } ?? []
        let allCompleted = milestoneTasks.allSatisfy { $0.isDone }

        if allCompleted && !milestoneTasks.isEmpty {
            analytics.trackMilestoneCompleted(
                careerTitle: trackedCareers[trackIndex].title,
                milestone: milestone.rawValue,
                tasksInMilestone: milestoneTasks.count
            )
        }
    }

    /// Mark a task as in progress
    func startTask(taskId: String, careerId: UUID) {
        guard let trackIndex = trackedCareers.firstIndex(where: { $0.id == careerId }),
              let taskIndex = trackedCareers[trackIndex].tasks?.firstIndex(where: { $0.id == taskId }) else {
            return
        }

        trackedCareers[trackIndex].tasks?[taskIndex].status = .inProgress
        saveTrackedCareers()
    }

    /// Add a custom task to a track
    func addTask(_ task: TrackTask, to careerId: UUID) {
        guard let index = trackedCareers.firstIndex(where: { $0.id == careerId }) else {
            return
        }

        if trackedCareers[index].tasks == nil {
            trackedCareers[index].tasks = []
        }
        trackedCareers[index].tasks?.append(task)
        saveTrackedCareers()
    }

    // MARK: - Skill Assessment

    /// Assess user's level for a specific skill
    func assessSkill(skillName: String, level: UserSkillLevel, careerContext: String? = nil) {
        skillsData.assess(skill: skillName, level: level)
        saveSkillsData()

        // Track analytics
        analytics.trackSkillAssessed(
            skillName: skillName,
            level: level.label,
            careerContext: careerContext
        )
    }

    /// Get user's assessed level for a skill
    func getSkillLevel(skillName: String) -> UserSkillLevel? {
        skillsData.level(for: skillName)
    }

    /// Check if user has assessed a skill
    func hasAssessedSkill(_ skillName: String) -> Bool {
        skillsData.hasAssessed(skillName)
    }

    /// Calculate skill gaps for a career
    func calculateSkillGaps(for career: CareerTrack) -> [SkillGap] {
        guard let skills = career.skills else { return [] }

        return skills
            .filter { $0.importancePercentage >= 50 } // Focus on important skills
            .map { skill in
                let userLevel = skillsData.level(for: skill.skill)
                return SkillGap(skill: skill, userLevel: userLevel)
            }
            .filter { $0.isSignificant } // Only significant gaps
            .sorted { $0.gapSize > $1.gapSize } // Largest gaps first
    }

    /// Get top N skill gaps
    func topSkillGaps(for career: CareerTrack, limit: Int = 5) -> [SkillGap] {
        Array(calculateSkillGaps(for: career).prefix(limit))
    }

    // MARK: - Task Generation

    /// Generate default tasks for a new track
    private func generateDefaultTasks(for career: CareerTrack) -> [TrackTask] {
        var tasks: [TrackTask] = []

        // Milestone 1: Understand the role
        tasks.append(TrackTask(
            milestone: .understandRole,
            type: .learn,
            title: "Read career overview",
            payload: ["section": "overview"]
        ))

        tasks.append(TrackTask(
            milestone: .understandRole,
            type: .learn,
            title: "Review top required skills",
            payload: ["section": "skills"]
        ))

        // Milestone 2: Assess gaps
        tasks.append(TrackTask(
            milestone: .assessGaps,
            type: .learn,
            title: "Complete skill self-assessment",
            payload: ["action": "assess_skills"]
        ))

        tasks.append(TrackTask(
            milestone: .assessGaps,
            type: .compare,
            title: "Identify 2-3 skills to develop",
            payload: ["action": "identify_gaps"]
        ))

        // Milestone 3: Plan education
        let education = career.education
        if !education.isEmpty {
            tasks.append(TrackTask(
                milestone: .planEducation,
                type: .plan,
                title: "Confirm education requirement: \(education)",
                payload: ["education_level": education]
            ))
        }

        tasks.append(TrackTask(
            milestone: .planEducation,
            type: .plan,
            title: "Research relevant programs or courses",
            payload: ["action": "research_programs"]
        ))

        // Milestone 4: Do activities
        tasks.append(TrackTask(
            milestone: .doActivities,
            type: .closeGap,
            title: "Complete an activity for a gap skill",
            payload: ["action": "close_gap"]
        ))

        // Milestone 5: Prepare job search (conditional on data availability)
        if career.onetCode != nil {
            tasks.append(TrackTask(
                milestone: .prepareJobSearch,
                type: .prepare,
                title: "Review job search strategy",
                payload: ["action": "review_job_strategy"]
            ))
        }

        return tasks
    }

    // MARK: - Persistence

    private func loadTrackedCareers() {
        if let data = appViewModel.userData[.trackedCareers] as? Data {
            do {
                let decoder = JSONDecoder()
                trackedCareers = try decoder.decode([CareerTrack].self, from: data)
            } catch {
                print("Failed to decode tracked careers: \(error)")
                trackedCareers = []
            }
        }
    }

    private func saveTrackedCareers() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(trackedCareers)
            appViewModel.userData[.trackedCareers] = data
        } catch {
            print("Failed to encode tracked careers: \(error)")
        }
    }

    private func loadSkillsData() {
        if let data = appViewModel.userData[.userSkillsData] as? Data {
            do {
                let decoder = JSONDecoder()
                skillsData = try decoder.decode(UserSkillsData.self, from: data)
            } catch {
                print("Failed to decode skills data: \(error)")
                skillsData = UserSkillsData()
            }
        }
    }

    private func saveSkillsData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(skillsData)
            appViewModel.userData[.userSkillsData] = data
        } catch {
            print("Failed to encode skills data: \(error)")
        }
    }

    // MARK: - Helpers

    /// Update track notes
    func updateNotes(_ notes: String, for careerId: UUID) {
        guard let index = trackedCareers.firstIndex(where: { $0.id == careerId }) else {
            return
        }

        let track = trackedCareers[index]
        trackedCareers[index].userNotes = notes
        saveTrackedCareers()

        // Track analytics (only if notes have content)
        if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            analytics.trackNotesUpdated(
                careerTitle: track.title,
                notesLength: notes.count
            )
        }
    }
}

// MARK: - Errors

enum TrackError: LocalizedError {
    case limitReached(max: Int)
    case alreadyTracked
    case notFound

    var errorDescription: String? {
        switch self {
        case .limitReached(let max):
            return "You can track up to \(max) careers at once. Archive a current track to add a new one."
        case .alreadyTracked:
            return "This career is already in your tracks."
        case .notFound:
            return "Track not found."
        }
    }
}
