import Foundation

enum OnboardingStep: Hashable, CaseIterable, Identifiable {
    case howDidYouHearAboutUs
    case countrySelection
    case getName
    case welcomeMessage(name: String)
    case currentStatus
    case studentLevel
    case motivationalMessage
    case interests
    case riasecQuestions(dimension: RIASECDimension)
    case favoriteSubjects
    case extracurriculars
    case careerInterests
    case workValues              // Recipe C: Work Values assessment
    case loadingScreen
    case completionScreen
    
    static var allCases: [OnboardingStep] {
        return [
            .howDidYouHearAboutUs,
            .countrySelection,
            .getName,
            .welcomeMessage(name: ""),
            .currentStatus,
            .studentLevel,
            .motivationalMessage,
            .interests,
            .riasecQuestions(dimension: .realistic),
            .favoriteSubjects,
            .extracurriculars,
            .careerInterests,
            .workValues,
            .loadingScreen,
            .completionScreen
        ]
    }
    
    var id: Self { self }
    
    /// Compare two OnboardingSteps ignoring associated data
    /// This helps with navigation history to identify steps regardless of their data
    func matchesWithoutData(_ other: OnboardingStep) -> Bool {
        switch (self, other) {
        case (.howDidYouHearAboutUs, .howDidYouHearAboutUs),
             (.countrySelection, .countrySelection),
             (.getName, .getName),
             (.welcomeMessage, .welcomeMessage),
             (.currentStatus, .currentStatus),
             (.studentLevel, .studentLevel),
             (.motivationalMessage, .motivationalMessage),
             (.interests, .interests),
             (.favoriteSubjects, .favoriteSubjects),
             (.extracurriculars, .extracurriculars),
             (.careerInterests, .careerInterests),
             (.workValues, .workValues),
             (.loadingScreen, .loadingScreen),
             (.completionScreen, .completionScreen):
            return true
            
        case (.riasecQuestions(let dim1), .riasecQuestions(let dim2)):
            return dim1 == dim2
            
        default:
            return false
        }
    }
    
    /// Get a step without associated data for history tracking
    var withoutData: OnboardingStep {
        switch self {
        case .welcomeMessage:
            return .welcomeMessage(name: "")
        default:
            return self
        }
    }
}