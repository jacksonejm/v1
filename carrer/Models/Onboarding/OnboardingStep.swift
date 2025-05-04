import Foundation

enum OnboardingStep: Hashable, CaseIterable, Identifiable {
    case howDidYouHearAboutUs
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
    case loadingScreen
    case completionScreen
    
    static var allCases: [OnboardingStep] {
        return [
            .howDidYouHearAboutUs,
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
            .loadingScreen,
            .completionScreen
        ]
    }
    
    var id: Self { self }
}