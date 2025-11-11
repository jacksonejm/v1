import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var appFlowState: AppFlowState = .initial
    @Published var userData: [UserDataKey: AnyHashable] = [:]
    @Published var isLoading = false
    @Published var favoriteItems: [String] = []
    @Published var careerTracks: [CareerTrack] = []
    @Published var showCompletion: Bool = false
    @Published var userCountry: UserCountry = .usa  // Default to USA
    @Published var canadianOccupationData: [String: CanadianOccupation] = [:]  // O*NET code → Canadian occupation

    // MARK: - Services
    private let navigationService: OnboardingNavigationService
    private let recommendationService: CareerRecommendationService
    private let persistenceService: UserDataPersistenceService

    // MARK: - Public Properties
    var onboardingModeManager: OnboardingModeManager?

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        navigationService: OnboardingNavigationService? = nil,
        recommendationService: CareerRecommendationService? = nil,
        persistenceService: UserDataPersistenceService? = nil
    ) {
        // Initialize services with dependency injection (or defaults)
        self.navigationService = navigationService ?? OnboardingNavigationService(
            getUserData: { [weak self] in self?.userData ?? [:] },
            updateUserData: { [weak self] key, value in self?.userData[key] = value }
        )

        self.recommendationService = recommendationService ?? CareerRecommendationService(
            getUserData: { [weak self] in self?.userData ?? [:] }
        )

        self.persistenceService = persistenceService ?? UserDataPersistenceService()
    }

    // MARK: - Public Methods - Navigation

    /// Advances to the next onboarding step
    func nextOnboardingStep() {
        guard case .onboarding(let currentStep) = appFlowState else { return }

        // Add current step to history BEFORE we navigate away from it
        navigationService.addToHistory(currentStep)

        // Calculate next step
        let nextStep = navigationService.calculateNextStep(from: currentStep)

        // Check for completion
        if case .completionScreen = currentStep {
            appFlowState = .dashboard
            return
        }

        print("Navigating forward from \(navigationService.getStepName(currentStep)) to \(navigationService.getStepName(nextStep))")

        // RIASEC Navigation Fix: Hydrate step to ensure state preservation
        if case .riasecQuestions = nextStep {
            let hydratedStep = navigationService.hydrateStep(nextStep)
            appFlowState = .onboarding(step: hydratedStep)
            print("Using hydrated step for RIASEC forward navigation to ensure state preservation")
        } else {
            appFlowState = .onboarding(step: nextStep)
        }
    }

    /// Goes back to the previous onboarding step
    func previousOnboardingStep() {
        guard case .onboarding(let currentStep) = appFlowState else { return }

        // Check if returning to welcome page
        if navigationService.isReturningToWelcome(from: currentStep) {
            print("Returning to welcome page - resetting all onboarding data")
            resetAllOnboardingData()
            appFlowState = .initial
            return
        }

        // Try to use navigation history first
        if navigationService.hasHistory {
            navigationService.removeFromHistory(currentStep)

            if let previousStep = navigationService.getPreviousStepFromHistory() {
                print("Using navigation history to go back to: \(navigationService.getStepName(previousStep))")
                navigationService.removeLastFromHistory()

                let hydratedStep = navigationService.hydrateStep(previousStep)
                appFlowState = .onboarding(step: hydratedStep)
                return
            }
        }

        // Fall back to calculating the previous step
        print("Navigation history not available, using calculated previous step")
        let previousStep = navigationService.calculatePreviousStep(from: currentStep)
        appFlowState = .onboarding(step: previousStep)
    }

    /// Navigates to a specific app flow state
    func navigateTo(_ state: AppFlowState) {
        print("AppViewModel: Navigating to \(state)")
        guard appFlowState != state else {
            print("AppViewModel: Already in state \(state), skipping")
            return
        }
        appFlowState = state
    }

    /// Completes the onboarding process and navigates to the dashboard
    func completeOnboarding() {
        // Save user data asynchronously
        Task {
            do {
                try await persistenceService.saveUserData(userData)
            } catch {
                print("❌ Error saving user data: \(error.localizedDescription)")
            }
        }

        // Navigate to dashboard
        appFlowState = .dashboard
    }

    // MARK: - Public Methods - User Data

    /// Updates a specific user data key
    func updateUserData<T: Hashable>(_ key: UserDataKey, value: T) {
        userData[key] = value

        // Special handling for RIASEC responses to ensure they're properly preserved
        if key == .riasecResponses {
            flattenRIASECResponses(value)
        }
    }

    /// Helper method to update RIASEC responses for a specific dimension
    func updateRIASECResponses(dimension: RIASECDimension, responses: [String: Int]) {
        // Get existing responses
        var allResponses: [String: [String: Int]] = [:]

        if let existing = userData[.riasecResponses] as? [String: [String: Int]] {
            allResponses = existing
        } else if let existingAny = userData[.riasecResponses] as? [String: Any] {
            allResponses = convertRIASECResponses(existingAny)
        }

        // Update the responses for this dimension
        allResponses[dimension.rawValue] = responses
        userData[.riasecResponses] = allResponses as AnyHashable

        // Update the flattened version
        var flatResponses = userData[.riasecResponsesFlat] as? [String: Int] ?? [:]
        for (question, rating) in responses {
            flatResponses[question] = rating
        }
        userData[.riasecResponsesFlat] = flatResponses

        // Update tracking of completed dimensions
        var completedDimensions = userData[.riasecDimensions] as? [String] ?? []
        let dimensionQuestions = dimension.questions

        if !completedDimensions.contains(dimension.rawValue) && responses.count >= dimensionQuestions.count {
            completedDimensions.append(dimension.rawValue)
            userData[.riasecDimensions] = completedDimensions
        }

        // Ensure UI updates
        objectWillChange.send()
    }

    /// Resets all onboarding data to provide a fresh start
    func resetAllOnboardingData() {
        print("Resetting all onboarding data")

        // Clear all onboarding-related user data
        let onboardingKeys: [UserDataKey] = [
            .howDidYouHearAboutUs, .country, .name, .personalizeExperience,
            .currentStatus, .studentLevel, .interests, .riasecResponses,
            .riasecResponsesFlat, .riasecResults, .riasecDimensions,
            .favoriteSubjects, .extracurriculars, .extracurricularOther,
            .careerInterests, .careerInterestsOther, .workValues
        ]

        for key in onboardingKeys {
            userData[key] = nil
        }

        // Clear navigation history
        navigationService.clearHistory()

        print("Onboarding data successfully reset")
    }

    /// Removes an item from favorites
    func removeFromFavorites(_ item: String) {
        favoriteItems.removeAll { $0 == item }
    }

    // MARK: - Public Methods - Career Recommendations

    /// Generate career suggestions based on user responses using O*NET data (Recipe D v4.0)
    func generateCareerSuggestions() async {
        print("🚀 generateCareerSuggestions started - Recipe D v4.0")
        isLoading = true

        do {
            let result = try await recommendationService.generateCareerRecommendations(for: userCountry)

            await MainActor.run {
                careerTracks = result.careers
                canadianOccupationData = result.canadianData
                userData[.careerSuggestions] = result.careers as AnyHashable
                userData[.riasecResults] = result.riasecScores as AnyHashable
                isLoading = false
            }

            print("✅ Recipe D v4.0 complete with \(result.careers.count) multi-dimensional matches")

        } catch {
            await MainActor.run {
                print("❌ Error generating career suggestions: \(error.localizedDescription)")
                print("⚠️ Falling back to sample career data")

                // The service already returns sample data on failure
                isLoading = false
            }
        }
    }

    /// Refresh career recommendations with updated career interests (Recipe D v4.0)
    func refreshRecommendationsWithInterests(_ updatedInterests: [String]) async {
        print("🔄 Refreshing recommendations with updated interests - Recipe D v4.0")

        do {
            let updatedCareers = try await recommendationService.refreshRecommendationsWithInterests(updatedInterests)

            await MainActor.run {
                careerTracks = updatedCareers
                userData[.careerSuggestions] = updatedCareers as AnyHashable
            }

            print("✅ Recommendations refreshed with updated interests")

        } catch {
            print("❌ Error refreshing recommendations: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods

    /// Flatten RIASEC responses for easier access
    private func flattenRIASECResponses<T>(_ value: T) {
        guard let riasecData = value as? [String: Any] else { return }

        var flattenedResponses: [String: Int] = [:]

        for (_, dimensionData) in riasecData {
            if let dimensionDict = dimensionData as? [String: Int] {
                for (question, rating) in dimensionDict {
                    flattenedResponses[question] = rating
                }
            } else if let dimensionAny = dimensionData as? [String: Any] {
                for (question, anyValue) in dimensionAny {
                    if let intValue = anyValue as? Int {
                        flattenedResponses[question] = intValue
                    }
                }
            }
        }

        userData[.riasecResponsesFlat] = flattenedResponses
    }

    /// Convert RIASEC responses from Any format
    private func convertRIASECResponses(_ existingAny: [String: Any]) -> [String: [String: Int]] {
        var allResponses: [String: [String: Int]] = [:]

        for (dimKey, dimValue) in existingAny {
            if let typedDict = dimValue as? [String: Int] {
                allResponses[dimKey] = typedDict
            } else if let anyDict = dimValue as? [String: Any] {
                var convertedDict: [String: Int] = [:]
                for (qKey, qValue) in anyDict {
                    if let intValue = qValue as? Int {
                        convertedDict[qKey] = intValue
                    }
                }
                if !convertedDict.isEmpty {
                    allResponses[dimKey] = convertedDict
                }
            }
        }

        return allResponses
    }
}
