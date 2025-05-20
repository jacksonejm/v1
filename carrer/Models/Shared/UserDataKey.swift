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
    
    case favoriteSubjects
    case extracurriculars
    case extracurricularOther
    case careerInterests
    case careerInterestsOther
    case careerSuggestions
    case questionBank
    case currentQuestionPage
    case completedSkills
    case completedActivities
    
    // Add the new case for AI Assistant tutorial
    case hasSeenAIAssistantTutorial
}