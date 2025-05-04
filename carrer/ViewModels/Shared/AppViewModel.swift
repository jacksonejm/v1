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
            nextStep = .studentLevel
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
            // Transition to the loading screen for processing responses
            nextStep = .loadingScreen
        case .loadingScreen:
            // After processing, move to completion
            nextStep = .completionScreen
        case .completionScreen:
            // After completion, move to dashboard
            appFlowState = .dashboard
            return
        }
        
        // Update the app flow state with the next step
        appFlowState = .onboarding(step: nextStep)
    }
    
    /// Updates a specific user data key
    func updateUserData<T: Hashable>(_ key: UserDataKey, value: T) {
        userData[key] = value
    }
    
    /// Navigates to a specific app flow state
    func navigateTo(_ state: AppFlowState) {
        appFlowState = state
    }
    
    /// Goes back to the previous onboarding step
    func previousOnboardingStep() {
        guard case .onboarding(let currentStep) = appFlowState else { return }
        
        // Determine the previous step based on the current one
        let previousStep: OnboardingStep
        
        switch currentStep {
        case .getName:
            previousStep = .howDidYouHearAboutUs
        case .welcomeMessage:
            previousStep = .getName
        case .currentStatus:
            previousStep = .welcomeMessage(name: userData[.name] as? String ?? "there")
        case .studentLevel:
            previousStep = .currentStatus
        case .motivationalMessage:
            previousStep = .studentLevel
        case .interests:
            previousStep = .motivationalMessage
        case .riasecQuestions(let dimension):
            // Go back through RIASEC dimensions
            switch dimension {
            case .investigative:
                previousStep = .riasecQuestions(dimension: .realistic)
            case .artistic:
                previousStep = .riasecQuestions(dimension: .investigative)
            case .social:
                previousStep = .riasecQuestions(dimension: .artistic)
            case .enterprising:
                previousStep = .riasecQuestions(dimension: .social)
            case .conventional:
                previousStep = .riasecQuestions(dimension: .enterprising)
            case .realistic:
                previousStep = .interests
            }
        case .favoriteSubjects:
            previousStep = .riasecQuestions(dimension: .conventional)
        case .extracurriculars:
            previousStep = .favoriteSubjects
        case .careerInterests:
            previousStep = .extracurriculars
        case .loadingScreen:
            previousStep = .careerInterests
        case .completionScreen:
            previousStep = .loadingScreen
        case .howDidYouHearAboutUs:
            // Go back to welcome screen (initial state)
            appFlowState = .initial
            return
        }
        
        // Update the app flow state with the previous step
        appFlowState = .onboarding(step: previousStep)
    }
    
    /// Completes the onboarding process and navigates to the dashboard
    func completeOnboarding() {
        // Save user data
        saveUserData()
        
        // Navigate to dashboard
        appFlowState = .dashboard
    }
    
    /// Generate career suggestions based on user responses
    func generateCareerSuggestions() async {
        isLoading = true
        
        // In a real app, this would analyze the user's responses and generate recommendations
        // For now, we'll simulate a delay and generate some sample career tracks
        
        do {
            // Simulate processing time
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            // Generate some sample career tracks based on user responses
            await MainActor.run {
                careerTracks = [
                    CareerTrack(
                        title: "Software Development",
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
                
                // Store career suggestions in user data
                // Now that CareerTrack conforms to Hashable, we can store it directly
                userData[.careerSuggestions] = careerTracks as AnyHashable
                
                isLoading = false
            }
        } catch {
            await MainActor.run {
                print("Error generating career suggestions: \(error)")
                isLoading = false
            }
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