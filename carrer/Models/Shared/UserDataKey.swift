import Foundation

public enum UserDataKey: Hashable {
    // Existing cases
    case howDidYouHearAboutUs
    case name
    case personalizeExperience // Added this case
    case currentStatus
    case studentLevel
    case interests
    
    // RIASEC data
    case riasecResponses        // Stores responses by dimension
    case riasecResponsesFlat    // Stores all responses in a flattened format
    case riasecResults          // Stores computed results
    case riasecDimensions       // Tracks available dimensions
    case riasec(String)         // Individual RIASEC dimension mean (e.g., riasec("R") = 3.5)
    
    case favoriteSubjects
    case subjects                // OnboardingV2 subjects array
    case extracurriculars
    case activities              // OnboardingV2 activities array
    case extracurricularOther
    case careerInterests
    case careerInterestsOther
    case activeCareerInterests   // Currently active career interests for filtering (Recipe D v4.0)
    case workValues              // Work Values scores (Recipe C)
    case workValue(String)       // Individual work value rating (e.g., workValue("balance") = 4)
    case careerSuggestions
    case questionBank
    case currentQuestionPage
    case completedSkills
    case completedActivities
    
    // Add the new case for AI Assistant tutorial
    case hasSeenAIAssistantTutorial

    // Career Tracks & Skills (Career Planning)
    case userSkillsData         // UserSkillsData - user's skill self-assessments
    case trackedCareers         // [CareerTrack] - careers being actively tracked

    // Canadian NOC Integration (Hybrid Approach)
    case country                // UserCountry - user's country (USA or Canada)

    // Onboarding completion tracking
    case hasCompletedOnboarding // Bool - whether user completed onboarding
}