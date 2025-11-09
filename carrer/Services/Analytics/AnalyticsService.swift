import Foundation
import FirebaseAnalytics

/// Analytics service for tracking user behavior and engagement
/// Recipe D v4.0 - Enhanced with career interest filtering analytics
class AnalyticsService {

    static let shared = AnalyticsService()

    private init() {}

    // MARK: - Career Interest Filtering Analytics

    /// Track when a user toggles a career interest filter
    func trackCareerInterestToggled(
        interest: String,
        action: String, // "enabled" or "disabled"
        activeInterestsCount: Int,
        totalInterestsCount: Int
    ) {
        let parameters: [String: Any] = [
            "interest": interest,
            "action": action,
            "active_count": activeInterestsCount,
            "total_count": totalInterestsCount,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("career_interest_toggled", parameters: parameters)
        print("📊 Analytics: Interest '\(interest)' \(action) (\(activeInterestsCount)/\(totalInterestsCount) active)")
    }

    /// Track when a user resets all career interests
    func trackCareerInterestsReset(totalInterests: Int) {
        let parameters: [String: Any] = [
            "total_interests": totalInterests,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("career_interests_reset", parameters: parameters)
        print("📊 Analytics: All \(totalInterests) interests reset")
    }

    /// Track when recommendations are refreshed with new interests
    func trackRecommendationsRefreshed(
        activeInterestsCount: Int,
        totalInterestsCount: Int,
        resultCount: Int
    ) {
        let parameters: [String: Any] = [
            "active_interests": activeInterestsCount,
            "total_interests": totalInterestsCount,
            "result_count": resultCount,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("recommendations_refreshed", parameters: parameters)
        print("📊 Analytics: Recommendations refreshed with \(activeInterestsCount) interests → \(resultCount) results")
    }

    /// Track when user views the boost info sheet
    func trackBoostInfoViewed() {
        Analytics.logEvent("boost_info_viewed", parameters: nil)
        print("📊 Analytics: Boost info sheet viewed")
    }

    /// Track career detail views from recommendations
    func trackCareerDetailViewed(
        careerTitle: String,
        matchPercentage: Int,
        matchBucket: String,
        isTopMatch: Bool,
        rank: Int,
        isBoosted: Bool
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "match_percentage": matchPercentage,
            "match_bucket": matchBucket,
            "is_top_match": isTopMatch,
            "rank": rank,
            "is_boosted": isBoosted,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("career_detail_viewed", parameters: parameters)
        print("📊 Analytics: Career '\(careerTitle)' viewed (rank #\(rank), \(matchBucket) match, top: \(isTopMatch), boosted: \(isBoosted))")
    }

    /// Track when user views the match breakdown sheet
    func trackMatchBreakdownViewed(
        careerTitle: String,
        matchPercentage: Int,
        matchBucket: String
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "match_percentage": matchPercentage,
            "match_bucket": matchBucket,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("match_breakdown_viewed", parameters: parameters)
        print("📊 Analytics: Match breakdown viewed for '\(careerTitle)' (\(matchBucket) match, \(matchPercentage)%)")
    }

    /// Track when user exports/shares career comparison
    func trackCareerComparisonExported(
        interestsIncluded: [String],
        careerCount: Int,
        format: String // "text", "pdf", etc.
    ) {
        let parameters: [String: Any] = [
            "interests_count": interestsIncluded.count,
            "career_count": careerCount,
            "format": format,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("career_comparison_exported", parameters: parameters)
        print("📊 Analytics: Comparison exported (\(careerCount) careers, format: \(format))")
    }

    // MARK: - Career Tracking Analytics

    /// Track when a user adds a career to their tracked list
    func trackCareerAdded(
        careerTitle: String,
        matchPercentage: Int,
        matchTier: String,
        isTopMatch: Bool,
        activeTracksCount: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "match_percentage": matchPercentage,
            "match_tier": matchTier,
            "is_top_match": isTopMatch,
            "active_tracks_count": activeTracksCount,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("track_career_added", parameters: parameters)
        print("📊 Analytics: Career '\(careerTitle)' added to tracks (\(matchTier), \(matchPercentage)%)")
    }

    /// Track when a user archives a career track
    func trackCareerArchived(
        careerTitle: String,
        completionPercentage: Int,
        tasksCompleted: Int,
        totalTasks: Int,
        daysTracked: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "completion_percentage": completionPercentage,
            "tasks_completed": tasksCompleted,
            "total_tasks": totalTasks,
            "days_tracked": daysTracked,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("track_career_archived", parameters: parameters)
        print("📊 Analytics: Career '\(careerTitle)' archived (\(completionPercentage)% complete)")
    }

    /// Track when a user completes a task
    func trackTaskCompleted(
        careerTitle: String,
        milestone: String,
        taskType: String,
        taskTitle: String,
        completionPercentage: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "milestone": milestone,
            "task_type": taskType,
            "task_title": taskTitle,
            "completion_percentage": completionPercentage,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("track_task_completed", parameters: parameters)
        print("📊 Analytics: Task completed in '\(careerTitle)' - \(taskTitle) (\(completionPercentage)% complete)")
    }

    /// Track when a milestone is fully completed
    func trackMilestoneCompleted(
        careerTitle: String,
        milestone: String,
        tasksInMilestone: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "milestone": milestone,
            "tasks_count": tasksInMilestone,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("track_milestone_completed", parameters: parameters)
        print("📊 Analytics: Milestone '\(milestone)' completed in '\(careerTitle)'")
    }

    /// Track when a user assesses a skill
    func trackSkillAssessed(
        skillName: String,
        level: String,
        careerContext: String?
    ) {
        var parameters: [String: Any] = [
            "skill_name": skillName,
            "level": level,
            "timestamp": Date().timeIntervalSince1970
        ]

        if let context = careerContext {
            parameters["career_context"] = context
        }

        Analytics.logEvent("skill_assessed", parameters: parameters)
        print("📊 Analytics: Skill '\(skillName)' assessed as '\(level)'")
    }

    /// Track when skill assessment sheet is opened
    func trackSkillAssessmentOpened(
        careerTitle: String,
        skillsCount: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "skills_count": skillsCount,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("skill_assessment_opened", parameters: parameters)
        print("📊 Analytics: Skill assessment opened for '\(careerTitle)' (\(skillsCount) skills)")
    }

    /// Track when skill assessment is completed
    func trackSkillAssessmentCompleted(
        careerTitle: String,
        skillsAssessed: Int,
        totalSkills: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "skills_assessed": skillsAssessed,
            "total_skills": totalSkills,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("skill_assessment_completed", parameters: parameters)
        print("📊 Analytics: Skill assessment completed for '\(careerTitle)' (\(skillsAssessed)/\(totalSkills))")
    }

    /// Track when user updates notes for a track
    func trackNotesUpdated(
        careerTitle: String,
        notesLength: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "notes_length": notesLength,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("track_notes_updated", parameters: parameters)
        print("📊 Analytics: Notes updated for '\(careerTitle)' (\(notesLength) characters)")
    }

    /// Track when user views track detail page
    func trackDetailViewed(
        careerTitle: String,
        completionPercentage: Int,
        tasksCompleted: Int,
        totalTasks: Int
    ) {
        let parameters: [String: Any] = [
            "career_title": careerTitle,
            "completion_percentage": completionPercentage,
            "tasks_completed": tasksCompleted,
            "total_tasks": totalTasks,
            "timestamp": Date().timeIntervalSince1970
        ]

        Analytics.logEvent("track_detail_viewed", parameters: parameters)
        print("📊 Analytics: Track detail viewed for '\(careerTitle)' (\(completionPercentage)% complete)")
    }

    // MARK: - General Analytics

    /// Track screen views
    func trackScreenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            "timestamp": Date().timeIntervalSince1970
        ])
        print("📊 Analytics: Screen viewed - \(screenName)")
    }

    /// Track user actions
    func trackAction(action: String, parameters: [String: Any]? = nil) {
        var params = parameters ?? [:]
        params["timestamp"] = Date().timeIntervalSince1970

        Analytics.logEvent(action, parameters: params)
        print("📊 Analytics: Action - \(action)")
    }
}
