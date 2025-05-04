import Foundation

public enum UserDataKey: Hashable {
    // Existing cases
    case howDidYouHearAboutUs
    case name
    case personalizeExperience // Added this case
    case currentStatus
    case studentLevel
    case interests
    case riasecResponses
    case favoriteSubjects
    case extracurriculars
    case extracurricularOther
    case careerInterests
    case careerInterestsOther
    case riasecResults
    case careerSuggestions
    case questionBank
    case currentQuestionPage
    case completedSkills
    case completedActivities
    
    // Add the new case for AI Assistant tutorial
    case hasSeenAIAssistantTutorial
    
    // Add the missing riasecDimensions case
    case riasecDimensions
}