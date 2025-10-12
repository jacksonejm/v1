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
    
    // MARK: - Public Properties
    var onboardingModeManager: OnboardingModeManager?
    
    // MARK: - Private Properties
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Removes an item from favorites
    func removeFromFavorites(_ item: String) {
        favoriteItems.removeAll { $0 == item }
    }
    
    /// Advances to the next onboarding step
    func nextOnboardingStep() {
        guard case .onboarding(let currentStep) = appFlowState else { return }
        
        // Add current step to history BEFORE we navigate away from it
        addToNavigationHistory(currentStep)
        
        // Determine the next step based on the current one
        let nextStep: OnboardingStep
        
        switch currentStep {
        case .howDidYouHearAboutUs:
            nextStep = .getName
        case .getName:
            if let name = userData[.name] as? String, !name.isEmpty {
                nextStep = .welcomeMessage(name: name)
            } else {
                nextStep = .welcomeMessage(name: "there")
            }
        case .welcomeMessage:
            nextStep = .currentStatus
        case .currentStatus:
            if let status = userData[.currentStatus] as? SelectionOption,
               status.title == "Student" {
                nextStep = .studentLevel
            } else {
                // Skip student-specific steps for non-students
                nextStep = .interests
            }
        case .studentLevel:
            nextStep = .motivationalMessage
        case .motivationalMessage:
            nextStep = .interests
        case .interests:
            nextStep = .riasecQuestions(dimension: .realistic)
        case .riasecQuestions(let dimension):
            // Progress through RIASEC dimensions
            switch dimension {
            case .realistic:
                nextStep = .riasecQuestions(dimension: .investigative)
            case .investigative:
                nextStep = .riasecQuestions(dimension: .artistic)
            case .artistic:
                nextStep = .riasecQuestions(dimension: .social)
            case .social:
                nextStep = .riasecQuestions(dimension: .enterprising)
            case .enterprising:
                nextStep = .riasecQuestions(dimension: .conventional)
            case .conventional:
                nextStep = .favoriteSubjects
            }
        case .favoriteSubjects:
            nextStep = .extracurriculars
        case .extracurriculars:
            nextStep = .careerInterests
        case .careerInterests:
            // Transition to work values assessment (Recipe C v3.0)
            nextStep = .workValues
        case .workValues:
            // After work values, transition to loading screen for processing
            nextStep = .loadingScreen
        case .loadingScreen:
            // After processing, move to completion
            nextStep = .completionScreen
        case .completionScreen:
            // After completion, move to dashboard
            appFlowState = .dashboard
            return
        }
        
        print("Navigating forward from \(getStepName(currentStep)) to \(getStepName(nextStep))")
        
        // RIASEC Navigation Fix: When navigating between RIASEC questions,
        // make sure to preserve the state by using a hydrated step
        if case .riasecQuestions = nextStep {
            // Get any existing data for this step and create a properly hydrated version
            let hydratedStep = hydrateStep(nextStep)
            
            // Update the app flow state with the hydrated step to ensure state preservation
            appFlowState = .onboarding(step: hydratedStep)
            
            // Log the navigation to help with debugging
            print("Using hydrated step for RIASEC forward navigation to ensure state preservation")
        } else {
            // For non-RIASEC steps, use the standard navigation
            appFlowState = .onboarding(step: nextStep)
        }
    }
    
    /// Updates a specific user data key
    func updateUserData<T: Hashable>(_ key: UserDataKey, value: T) {
        userData[key] = value
        
        // Special handling for RIASEC responses to ensure they're properly preserved
        if key == .riasecResponses {
            // When RIASEC responses are updated, ensure we update the flattened version too
            if let riasecData = value as? [String: Any] {
                var flattenedResponses: [String: Int] = [:]
                
                // Flatten all dimension responses into a single dictionary
                for (_, dimensionData) in riasecData {
                    if let dimensionDict = dimensionData as? [String: Int] {
                        // Direct [String: Int] format
                        for (question, rating) in dimensionDict {
                            flattenedResponses[question] = rating
                        }
                    } else if let dimensionAny = dimensionData as? [String: Any] {
                        // Convert [String: Any] to [String: Int] format
                        for (question, value) in dimensionAny {
                            if let intValue = value as? Int {
                                flattenedResponses[question] = intValue
                            }
                        }
                    }
                }
                
                // Save the flattened responses
                userData[.riasecResponsesFlat] = flattenedResponses
            }
        }
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
    
    /// Navigation history to track steps
    private var navigationHistory: [OnboardingStep] = []
    
    /// Resets all onboarding data to provide a fresh start
    func resetAllOnboardingData() {
        print("Resetting all onboarding data")
        
        // Clear all onboarding-related user data
        let onboardingKeys: [UserDataKey] = [
            .howDidYouHearAboutUs,
            .name,
            .personalizeExperience,
            .currentStatus,
            .studentLevel,
            .interests,
            .riasecResponses,
            .riasecResponsesFlat,
            .riasecResults,
            .riasecDimensions,
            .favoriteSubjects,
            .extracurriculars,
            .extracurricularOther,
            .careerInterests,
            .careerInterestsOther,
            .workValues,
            .riasecResults
        ]
        
        // Clear each key from userData
        for key in onboardingKeys {
            userData[key] = nil
        }
        
        // Clear navigation history
        navigationHistory.removeAll()
        
        print("Onboarding data successfully reset")
    }
    
    /// Helper method to update RIASEC responses for a specific dimension
    /// This centralizes the logic to ensure consistent state across the app
    func updateRIASECResponses(dimension: RIASECDimension, responses: [String: Int]) {
        // Get existing responses
        var allResponses: [String: [String: Int]] = [:]
        
        if let existing = userData[.riasecResponses] as? [String: [String: Int]] {
            allResponses = existing
        } else if let existingAny = userData[.riasecResponses] as? [String: Any] {
            // Convert from Any-based dictionary
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
        }
        
        // Update the responses for this dimension
        allResponses[dimension.rawValue] = responses
        
        // Store back in userData
        userData[.riasecResponses] = allResponses as AnyHashable
        
        // Update the flattened version
        var flatResponses = userData[.riasecResponsesFlat] as? [String: Int] ?? [:]
        
        // Add/update this dimension's responses in the flattened structure
        for (question, rating) in responses {
            flatResponses[question] = rating
        }
        
        userData[.riasecResponsesFlat] = flatResponses
        
        // Update tracking of completed dimensions
        var completedDimensions = userData[.riasecDimensions] as? [String] ?? []
        
        // Use the canonical questions for this dimension
        let dimensionQuestions = dimension.questions
        
        // Mark dimension as completed if all questions are answered
        if !completedDimensions.contains(dimension.rawValue) && responses.count >= dimensionQuestions.count {
            completedDimensions.append(dimension.rawValue)
            userData[.riasecDimensions] = completedDimensions
        }
        
        // Ensure UI updates
        objectWillChange.send()
    }
    
    /// Goes back to the previous onboarding step
    func previousOnboardingStep() {
        guard case .onboarding(let currentStep) = appFlowState else { return }
        
        // Calculate the previous step first to determine if we're going to the welcome page
        let previousStep = calculatePreviousStep(from: currentStep)
        
        // Special cases for returning to welcome/initial page
        let isReturningToWelcome = 
            // Explicit return to welcome from first onboarding screen
            (currentStep == .howDidYouHearAboutUs) ||
            
                // Check if this would take us to the welcome page based on our calculation
            false // Simplified for now to fix compilation - we only need the first condition
        
        if isReturningToWelcome {
            print("Returning to welcome page - resetting all onboarding data")
            
            // Show confirmation dialog via the BackButton component
            
            // Clear all entered data for fresh start
            resetAllOnboardingData()
            
            // Navigate back to the welcome/initial state
            appFlowState = .initial
            return
        }
        
        // For all other screens, use the navigation history
        if !navigationHistory.isEmpty {
            // Remove current step from history
            if let lastIndex = navigationHistory.lastIndex(where: { $0.matchesWithoutData(currentStep) }) {
                navigationHistory.remove(at: lastIndex)
            }
            
            // Go to previous step in history if available
            if let previousStep = navigationHistory.last {
                print("Using navigation history to go back to: \(getStepName(previousStep))")
                // Remove the step we're navigating to from history as well (since we're going there)
                navigationHistory.removeLast()
                
                // Apply any current data to the step if needed
                let hydratedStep = hydrateStep(previousStep)
                appFlowState = .onboarding(step: hydratedStep)
                return
            }
        }
        
        // Fall back to calculating the previous step if history isn't available
        print("Navigation history not available, using calculated previous step")
        
        // Update the app flow state with the previous step
        appFlowState = .onboarding(step: previousStep)
    }
    
    /// Add a step to the navigation history
    func addToNavigationHistory(_ step: OnboardingStep) {
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
    
    /// Calculate the previous step based on the current one (fallback method)
    private func calculatePreviousStep(from currentStep: OnboardingStep) -> OnboardingStep {
        switch currentStep {
        case .getName:
            return .howDidYouHearAboutUs
            
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
            // Go back to welcome screen (initial state)
            appFlowState = .initial
            return .howDidYouHearAboutUs
        }
    }
    
    /// Apply current user data to a step if needed (for steps with associated data)
    private func hydrateStep(_ step: OnboardingStep) -> OnboardingStep {
        switch step {
        case .welcomeMessage:
            let name = userData[.name] as? String ?? "there"
            return .welcomeMessage(name: name)
            
        case .riasecQuestions(let dimension):
            // For RIASEC questions, we want to ensure we're passing the same step
            // but also ensure that the responses are already loaded in the cache
            
            // Pre-warm the cache for this dimension to ensure data is consistent
            // This is only needed for forward navigation, as backward navigation
            // already uses this approach
            preloadRIASECResponsesForDimension(dimension)
            
            // Return the same step - the data is already in the central store
            return step
            
        default:
            return step
        }
    }
    
    /// Pre-loads RIASEC responses for a specific dimension to ensure consistent navigation
    private func preloadRIASECResponsesForDimension(_ dimension: RIASECDimension) {
        // This function ensures that state is consistent between forward and backward navigation
        // It makes sure the responses for this dimension are ready in the cache
        
        print("Pre-loading RIASEC responses for \(dimension.rawValue) dimension")
        
        // Check if we have existing dimension-specific responses
        if let allResponses = userData[.riasecResponses] as? [String: [String: Int]],
           let dimensionResponses = allResponses[dimension.rawValue] {
            print("Found \(dimensionResponses.count) cached responses for \(dimension.rawValue)")
            return // Data is already cached properly
        }
        
        // If we don't have dimension-specific responses, try to extract them from the flattened format
        if let flatResponses = userData[.riasecResponsesFlat] as? [String: Int] {
            // Get questions for this dimension (simplified version of what's in RIASECQuestionView)
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
                userData[.riasecResponses] = allResponses as AnyHashable
                
                // Log for debugging
                print("Pre-cached \(dimensionResponses.count) responses for \(dimension.rawValue)")
            }
        }
    }
    
    /// Get a string representation of a step for debugging
    private func getStepName(_ step: OnboardingStep) -> String {
        switch step {
        case .howDidYouHearAboutUs: return "How Did You Hear About Us"
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
    
    /// Completes the onboarding process and navigates to the dashboard
    func completeOnboarding() {
        // Save user data
        saveUserData()
        
        // Navigate to dashboard
        appFlowState = .dashboard
    }
    
    /// Generate career suggestions based on user responses using O*NET data
    func generateCareerSuggestions() async {
        print("🚀 generateCareerSuggestions started - Recipe D v4.0 Multi-Dimensional Matching")
        await MainActor.run {
            isLoading = true
        }

        do {
            // Calculate RIASEC scores from user responses
            let riasecScores = calculateRIASECScores()

            guard !riasecScores.isEmpty else {
                print("⚠️ No RIASEC scores available, falling back to sample data")
                await generateSampleCareerTracks()
                return
            }

            print("📊 RIASEC Scores calculated:")
            for (dimension, score) in riasecScores.sorted(by: { $0.key < $1.key }) {
                print("  \(dimension): \(String(format: "%.2f", score))")
            }

            // Extract work values from userData (Recipe C v3.0)
            var workValuesDict: [String: Float]? = nil
            if let workValuesData = userData[.workValues] as? [String: Double] {
                workValuesDict = [
                    "achievement": Float(workValuesData["achievement"] ?? 3.0),
                    "independence": Float(workValuesData["independence"] ?? 3.0),
                    "recognition": Float(workValuesData["recognition"] ?? 3.0),
                    "relationships": Float(workValuesData["relationships"] ?? 3.0),
                    "support": Float(workValuesData["support"] ?? 3.0),
                    "working_conditions": Float(workValuesData["working_conditions"] ?? 3.0)
                ]

                print("📊 Work Values extracted:")
                for (value, score) in workValuesDict!.sorted(by: { $0.key < $1.key }) {
                    print("  \(value): \(String(format: "%.2f", score))")
                }
            } else {
                print("ℹ️ No work values provided, using defaults (3.0 = moderate importance)")
            }

            // ⭐ NEW Recipe D v4.0: Extract subjects
            var subjects: [String]? = nil
            if let subjectsSet = userData[.favoriteSubjects] as? Set<SchoolSubject> {
                subjects = subjectsSet.map { $0.name }
                print("📚 Subjects extracted: \(subjects!.joined(separator: ", "))")
            }

            // ⭐ NEW Recipe D v4.0: Extract activities
            var activities: [String]? = nil
            if let activitiesSet = userData[.extracurriculars] as? Set<Activity> {
                activities = activitiesSet.map { $0.name }
                print("🎭 Activities extracted: \(activities!.joined(separator: ", "))")
            }

            // ⭐ NEW Recipe D v4.0: Extract career interests
            var careerInterests: [String]? = nil
            if let interestsSet = userData[.careerInterests] as? Set<String> {
                careerInterests = Array(interestsSet)
                print("💼 Career Interests extracted: \(careerInterests!.joined(separator: ", "))")
            }

            // ⭐ NEW Recipe D v4.0: Extract student level
            let studentLevel = userData[.studentLevel] as? String
            if let level = studentLevel {
                print("🎓 Student Level: \(level)")
            }

            // ⭐ NEW Recipe D v4.0: Extract current status
            var currentStatus: String? = nil
            if let status = userData[.currentStatus] as? SelectionOption {
                currentStatus = status.title
                print("👤 Current Status: \(status.title)")
            }

            print("\n🎯 Recipe D v4.0 Input Summary:")
            print("  RIASEC: \(riasecScores.count) dimensions")
            print("  Work Values: \(workValuesDict?.count ?? 0) values")
            print("  Subjects: \(subjects?.count ?? 0)")
            print("  Activities: \(activities?.count ?? 0)")
            print("  Career Interests: \(careerInterests?.count ?? 0)")
            print("  Student Level: \(studentLevel ?? "not set")")
            print("  Current Status: \(currentStatus ?? "not set")")

            // Fetch career matches from Snowflake O*NET (Recipe D v4.0 with all dimensions)
            let snowflakeService = SnowflakeService.shared
            let onetOccupations = try await snowflakeService.getCareerMatches(
                scores: riasecScores,
                workValues: workValuesDict,
                subjects: subjects,
                activities: activities,
                careerInterests: careerInterests,
                studentLevel: studentLevel,
                currentStatus: currentStatus
            )

            print("✅ Received \(onetOccupations.count) O*NET career matches from Recipe D v4.0")

            // Convert O*NET occupations to CareerTrack objects
            await MainActor.run {
                careerTracks = onetOccupations.map { occupation in
                    CareerTrack.from(onetOccupation: occupation, progress: 0)
                }

                // Store career suggestions in user data
                userData[.careerSuggestions] = careerTracks as AnyHashable
                userData[.riasecResults] = riasecScores as AnyHashable

                print("✅ Recipe D v4.0 complete with \(careerTracks.count) multi-dimensional matches")
                isLoading = false
            }

        } catch {
            await MainActor.run {
                print("❌ Error generating career suggestions: \(error.localizedDescription)")
                print("⚠️ Falling back to sample career data")

                // Fallback to sample data if Snowflake fails
                generateSampleCareerTracksSync()

                isLoading = false
            }
        }
    }

    /// Refresh career recommendations with updated career interests (Recipe D v4.0)
    /// Used by AllRecommendationsView when toggling interest filters
    func refreshRecommendationsWithInterests(_ updatedInterests: [String]) async {
        print("🔄 Refreshing recommendations with updated interests - Recipe D v4.0")

        do {
            // Use existing RIASEC scores
            let riasecScores = calculateRIASECScores()

            guard !riasecScores.isEmpty else {
                print("⚠️ No RIASEC scores available")
                return
            }

            // Extract existing work values
            var workValuesDict: [String: Float]? = nil
            if let workValuesData = userData[.workValues] as? [String: Double] {
                workValuesDict = [
                    "achievement": Float(workValuesData["achievement"] ?? 3.0),
                    "independence": Float(workValuesData["independence"] ?? 3.0),
                    "recognition": Float(workValuesData["recognition"] ?? 3.0),
                    "relationships": Float(workValuesData["relationships"] ?? 3.0),
                    "support": Float(workValuesData["support"] ?? 3.0),
                    "working_conditions": Float(workValuesData["working_conditions"] ?? 3.0)
                ]
            }

            // Extract subjects
            var subjects: [String]? = nil
            if let subjectsSet = userData[.favoriteSubjects] as? Set<SchoolSubject> {
                subjects = subjectsSet.map { $0.name }
            }

            // Extract activities
            var activities: [String]? = nil
            if let activitiesSet = userData[.extracurriculars] as? Set<Activity> {
                activities = activitiesSet.map { $0.name }
            }

            // Use the UPDATED career interests
            let careerInterests = updatedInterests.isEmpty ? nil : updatedInterests

            // Extract student level and status
            let studentLevel = userData[.studentLevel] as? String
            var currentStatus: String? = nil
            if let status = userData[.currentStatus] as? SelectionOption {
                currentStatus = status.title
            }

            print("🔄 Updated interests: \(careerInterests?.joined(separator: ", ") ?? "none")")

            // Fetch updated career matches from Snowflake
            let snowflakeService = SnowflakeService.shared
            let onetOccupations = try await snowflakeService.getCareerMatches(
                scores: riasecScores,
                workValues: workValuesDict,
                subjects: subjects,
                activities: activities,
                careerInterests: careerInterests,
                studentLevel: studentLevel,
                currentStatus: currentStatus
            )

            print("✅ Received \(onetOccupations.count) updated career matches")

            // Update career tracks
            await MainActor.run {
                careerTracks = onetOccupations.map { occupation in
                    CareerTrack.from(onetOccupation: occupation, progress: 0)
                }

                // Update stored career suggestions
                userData[.careerSuggestions] = careerTracks as AnyHashable

                print("✅ Recommendations refreshed with updated interests")
            }

        } catch {
            print("❌ Error refreshing recommendations: \(error.localizedDescription)")
        }
    }

    /// Calculate normalized RIASEC scores from user responses
    private func calculateRIASECScores() -> [String: Float] {
        // Try to get RIASEC responses from userData
        if let riasecResponses = userData[.riasecResponses] as? [String: [String: Int]] {
            // Use structured responses
            return RIASECScoreCalculator.calculateNormalized(from: riasecResponses)
        } else if let flatResponses = userData[.riasecResponsesFlat] as? [String: Int] {
            // Use flattened responses
            return RIASECScoreCalculator.calculateNormalizedFromFlat(from: flatResponses)
        } else {
            print("⚠️ No RIASEC responses found in userData")
            return [:]
        }
    }

    /// Generate sample career tracks as fallback (private, synchronous)
    private func generateSampleCareerTracksSync() {
        careerTracks = [
            CareerTrack(
                title: "Software Developer",
                progress: 0,
                salary: "$70,000 - $120,000",
                education: "Bachelor's Degree",
                match: 95
            ),
            CareerTrack(
                title: "UX/UI Designer",
                progress: 0,
                salary: "$65,000 - $110,000",
                education: "Bachelor's Degree",
                match: 87
            ),
            CareerTrack(
                title: "Data Scientist",
                progress: 0,
                salary: "$80,000 - $130,000",
                education: "Master's Degree",
                match: 82
            )
        ]

        userData[.careerSuggestions] = careerTracks as AnyHashable
        print("⚠️ Using sample career tracks (Snowflake unavailable)")
    }

    /// Generate sample career tracks as fallback (async wrapper)
    private func generateSampleCareerTracks() async {
        await MainActor.run {
            generateSampleCareerTracksSync()
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    /// Saves user data to Firestore
    private func saveUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            return
        }
        
        // Convert userData to dictionary for Firestore
        var userDataDict: [String: Any] = [:]
        
        for (key, value) in userData {
            // Handle different value types
            if let stringValue = value as? String {
                userDataDict["\(key)"] = stringValue
            } else if let intValue = value as? Int {
                userDataDict["\(key)"] = intValue
            } else if let boolValue = value as? Bool {
                userDataDict["\(key)"] = boolValue
            } else if let arrayValue = value as? [String] {
                userDataDict["\(key)"] = arrayValue
            } else if let dictValue = value as? [String: Any] {
                userDataDict["\(key)"] = dictValue
            } else {
                // Fallback to string representation
                userDataDict["\(key)"] = "\(value)"
            }
        }
        
        // Add timestamp
        userDataDict["lastUpdated"] = FieldValue.serverTimestamp()
        
        // Save to Firestore
        db.collection("users").document(userId).setData(userDataDict, merge: true) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully")
            }
        }
    }
}
