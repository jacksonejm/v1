import Foundation
import SwiftUI

struct OnboardingRouter {
    let onboardingStore: OnboardingDataStore
    
    init(onboardingStore: OnboardingDataStore = SecureOnboardingStore()) {
        self.onboardingStore = onboardingStore
    }
    
    func determineInitialStep() -> Int {
        if let dto = try? onboardingStore.load() {
            return dto.progressStep
        } else {
            return 0 // fresh flow
        }
    }
    
    func startAt(step: Int) -> OnboardingStep {
        // Convert the numeric step index to an OnboardingStep enum
        switch step {
        case 0:
            return .howDidYouHearAboutUs
        case 1:
            return .getName
        case 2:
            return .welcomeMessage(name: "")
        case 3:
            return .currentStatus
        case 4:
            return .studentLevel
        case 5:
            return .motivationalMessage
        case 6:
            return .interests
        case 7:
            return .riasecQuestions(dimension: .realistic)
        case 8:
            return .riasecQuestions(dimension: .investigative)
        case 9:
            return .riasecQuestions(dimension: .artistic)
        case 10:
            return .riasecQuestions(dimension: .social)
        case 11:
            return .riasecQuestions(dimension: .enterprising)
        case 12:
            return .riasecQuestions(dimension: .conventional)
        case 13:
            return .favoriteSubjects
        case 14:
            return .extracurriculars
        case 15:
            return .careerInterests
        case 16:
            return .loadingScreen
        case 17:
            return .completionScreen
        default:
            return .howDidYouHearAboutUs
        }
    }
}