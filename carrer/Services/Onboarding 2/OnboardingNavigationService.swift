import Foundation
import SwiftUI

/// Service responsible for managing onboarding navigation flow and history
class OnboardingNavigationService {

    // MARK: - Properties

    /// Navigation history to track steps
    private var navigationHistory: [OnboardingStep] = []

    /// Callback to access current user data
    private let getUserData: () -> [UserDataKey: AnyHashable]

    /// Callback to update user data
    private let updateUserData: (UserDataKey, AnyHashable) -> Void

    // MARK: - Initialization

    init(
        getUserData: @escaping () -> [UserDataKey: AnyHashable],
        updateUserData: @escaping (UserDataKey, AnyHashable) -> Void
    ) {
        self.getUserData = getUserData
        self.updateUserData = updateUserData
    }

    // MARK: - Public Methods

    /// Calculates the next onboarding step from the current step
    func calculateNextStep(from currentStep: OnboardingStep) -> OnboardingStep {
        let userData = getUserData()

        switch currentStep {
        case .howDidYouHearAboutUs:
            return .countrySelection

        case .countrySelection:
            return .getName

        case .getName:
            if let name = userData[.name] as? String, !name.isEmpty {
                return .welcomeMessage(name: name)
            } else {
                return .welcomeMessage(name: "there")
            }

        case .welcomeMessage:
            return .currentStatus

        case .currentStatus:
            if let status = userData[.currentStatus] as? SelectionOption,
               status.title == "Student" {
                return .studentLevel
            } else {
                // Skip student-specific steps for non-students
                return .interests
            }

        case .studentLevel:
            return .motivationalMessage

        case .motivationalMessage:
            return .interests

        case .interests:
            return .riasecQuestions(dimension: .realistic)

        case .riasecQuestions(let dimension):
            // Progress through RIASEC dimensions
            switch dimension {
            case .realistic:
                return .riasecQuestions(dimension: .investigative)
            case .investigative:
                return .riasecQuestions(dimension: .artistic)
            case .artistic:
                return .riasecQuestions(dimension: .social)
            case .social:
                return .riasecQuestions(dimension: .enterprising)
            case .enterprising:
                return .riasecQuestions(dimension: .conventional)
            case .conventional:
                return .favoriteSubjects
            }

        case .favoriteSubjects:
            return .extracurriculars

        case .extracurriculars:
            return .careerInterests

        case .careerInterests:
            return .workValues

        case .workValues:
            return .loadingScreen

        case .loadingScreen:
            return .completionScreen

        case .completionScreen:
            // Completion handled by AppViewModel
            return .completionScreen
        }
    }

    /// Calculate the previous step based on the current one
    func calculatePreviousStep(from currentStep: OnboardingStep) -> OnboardingStep {
        let userData = getUserData()

        switch currentStep {
        case .countrySelection:
            return .howDidYouHearAboutUs

        case .getName:
            return .countrySelection

        case .welcomeMessage:
            return .getName

        case .currentStatus:
            return .welcomeMessage(name: userData[.name] as? String ?? "there")

        case .studentLevel:
            return .currentStatus

        case .motivationalMessage:
            return .studentLevel

        case .interests:
            // Check if we came from motivationalMessage or directly from currentStatus
            if let status = userData[.currentStatus] as? SelectionOption,
               status.title == "Student" {
                return .motivationalMessage
            } else {
                return .currentStatus
            }

        case .riasecQuestions(let dimension):
            // Go back through RIASEC dimensions
            switch dimension {
            case .investigative:
                return .riasecQuestions(dimension: .realistic)
            case .artistic:
                return .riasecQuestions(dimension: .investigative)
            case .social:
                return .riasecQuestions(dimension: .artistic)
            case .enterprising:
                return .riasecQuestions(dimension: .social)
            case .conventional:
                return .riasecQuestions(dimension: .enterprising)
            case .realistic:
                return .interests
            }

        case .favoriteSubjects:
            return .riasecQuestions(dimension: .conventional)

        case .extracurriculars:
            return .favoriteSubjects

        case .careerInterests:
            return .extracurriculars

        case .workValues:
            return .careerInterests

        case .loadingScreen:
            return .workValues

        case .completionScreen:
            return .loadingScreen

        case .howDidYouHearAboutUs:
            // Signal to return to initial state
            return .howDidYouHearAboutUs
        }
    }

    /// Apply current user data to a step if needed (for steps with associated data)
    func hydrateStep(_ step: OnboardingStep) -> OnboardingStep {
        let userData = getUserData()

        switch step {
        case .welcomeMessage:
            let name = userData[.name] as? String ?? "there"
            return .welcomeMessage(name: name)

        case .riasecQuestions(let dimension):
            // Pre-warm the cache for this dimension to ensure data is consistent
            preloadRIASECResponsesForDimension(dimension)
            return step

        default:
            return step
        }
    }

    /// Add a step to the navigation history
    func addToHistory(_ step: OnboardingStep) {
        // Don't track loading screens in history
        if case .loadingScreen = step {
            return
        }

        // Avoid duplicates - only add if different from last step
        if let lastStep = navigationHistory.last, lastStep.matchesWithoutData(step) {
            return
        }

        navigationHistory.append(step)

        // Cap the history at 20 items to prevent memory issues
        if navigationHistory.count > 20 {
            navigationHistory.removeFirst()
        }

        print("Navigation history updated: \(navigationHistory.count) steps")
    }

    /// Get previous step from navigation history
    func getPreviousStepFromHistory() -> OnboardingStep? {
        return navigationHistory.last
    }

    /// Remove last step from navigation history
    func removeLastFromHistory() {
        if !navigationHistory.isEmpty {
            navigationHistory.removeLast()
        }
    }

    /// Remove specific step from navigation history
    func removeFromHistory(_ step: OnboardingStep) {
        if let lastIndex = navigationHistory.lastIndex(where: { $0.matchesWithoutData(step) }) {
            navigationHistory.remove(at: lastIndex)
        }
    }

    /// Check if history is empty
    var hasHistory: Bool {
        return !navigationHistory.isEmpty
    }

    /// Clear navigation history
    func clearHistory() {
        navigationHistory.removeAll()
        print("Navigation history cleared")
    }

    /// Get a string representation of a step for debugging
    func getStepName(_ step: OnboardingStep) -> String {
        switch step {
        case .howDidYouHearAboutUs: return "How Did You Hear About Us"
        case .countrySelection: return "Country Selection"
        case .getName: return "Get Name"
        case .welcomeMessage(let name): return "Welcome Message (\(name))"
        case .currentStatus: return "Current Status"
        case .studentLevel: return "Student Level"
        case .motivationalMessage: return "Motivational Message"
        case .interests: return "Interests"
        case .riasecQuestions(let dimension): return "RIASEC Questions (\(dimension.rawValue))"
        case .favoriteSubjects: return "Favorite Subjects"
        case .extracurriculars: return "Extracurricular Activities"
        case .careerInterests: return "Career Interests"
        case .workValues: return "Work Values"
        case .loadingScreen: return "Loading Screen"
        case .completionScreen: return "Completion Screen"
        }
    }

    /// Check if step is returning to welcome page
    func isReturningToWelcome(from currentStep: OnboardingStep) -> Bool {
        return currentStep == .howDidYouHearAboutUs
    }

    // MARK: - Private Methods

    /// Pre-loads RIASEC responses for a specific dimension to ensure consistent navigation
    private func preloadRIASECResponsesForDimension(_ dimension: RIASECDimension) {
        let userData = getUserData()

        print("Pre-loading RIASEC responses for \(dimension.rawValue) dimension")

        // Check if we have existing dimension-specific responses
        if let allResponses = userData[.riasecResponses] as? [String: [String: Int]],
           let dimensionResponses = allResponses[dimension.rawValue] {
            print("Found \(dimensionResponses.count) cached responses for \(dimension.rawValue)")
            return // Data is already cached properly
        }

        // If we don't have dimension-specific responses, try to extract them from the flattened format
        if let flatResponses = userData[.riasecResponsesFlat] as? [String: Int] {
            let dimensionQuestions = dimension.questions

            // Extract responses for this dimension from the flattened format
            var dimensionResponses: [String: Int] = [:]
            for question in dimensionQuestions {
                if let rating = flatResponses[question] {
                    dimensionResponses[question] = rating
                }
            }

            if !dimensionResponses.isEmpty {
                print("Extracted \(dimensionResponses.count) responses for \(dimension.rawValue) from flattened data")

                // Save these back to the dimension-specific structure
                var allResponses = userData[.riasecResponses] as? [String: [String: Int]] ?? [:]
                allResponses[dimension.rawValue] = dimensionResponses
                updateUserData(.riasecResponses, allResponses as AnyHashable)

                print("Pre-cached \(dimensionResponses.count) responses for \(dimension.rawValue)")
            }
        }
    }
}
