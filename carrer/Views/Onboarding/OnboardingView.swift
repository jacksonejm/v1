import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: AppViewModel
    let step: OnboardingStep
    @State var showAccountCreationPrompt = false
    @State var showAIAssistant = false
    @StateObject var aiAssistantViewModel = AIAssistantViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ───────────────────────────────────────────────────────────
                // 1) Main onboarding content
                VStack(alignment: .leading, spacing: 0) {
                    // Navigation bar
                    if showNavigationBar {
                        navigationBar
                    }
                    
                    // Title
                    if !stepTitle.isEmpty {
                        Text(stepTitle)
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 24)
                    }
                    
                    // Step content
                    VStack(alignment: .leading, spacing: 10) {
                        stepContent
                    }
                    .padding(.top, 8) // Reduced from 20pt to 8pt to match Apple HIG
                    
                    Spacer()
                    
                    // ───────────────────────────────────────────────────────────
                    // 2) Help Button (presents AI Assistant as a sheet)
                    if shouldShowHelpButton {
                        Button {
                            presentAIAssistant()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18))
                                Text("Assistant")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(AppColors.primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 12)
                        .accessibilityLabel("AI Assistant")
                        .accessibilityHint("Get help with this step from the AI assistant")
                    }
                    
                    // ───────────────────────────────────────────────────────────
                    // 3) Next Button
                    if showNextButton {
                        Button {
                            navigateToNextStep()
                        } label: {
                            Text(nextButtonTitle)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isNextButtonDisabled ? Color.gray : AppColors.primary)
                                .cornerRadius(25)
                        }
                        .disabled(isNextButtonDisabled)
                        .sheet(isPresented: $showAccountCreationPrompt) {
                            AccountCreationPromptView(viewModel: viewModel)
                                .presentationDetents([.fraction(0.35)])
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // ───────────────────────────────────────────────────────────
                // 4) Network status indicator (when offline)
                if !NetworkMonitor.shared.isConnected {
                    VStack {
                        HStack {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.white)
                            Text("Offline Mode")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                    .animation(.easeInOut, value: NetworkMonitor.shared.isConnected)
                }
            }
            .fullScreenCover(isPresented: $showAIAssistant) {
                AIAssistantOverlay(
                    viewModel: aiAssistantViewModel,
                    isPresented: $showAIAssistant,
                    currentStep: step
                )
            }
            .onChange(of: step) { newStep in
                // Update assistant context when step changes
                if showAIAssistant {
                    aiAssistantViewModel.initialize(for: newStep)
                }
            }
        }
    }
    
    // Method to present AI Assistant safely
    func presentAIAssistant() {
        // Initialize the chat with contextual information before showing the overlay
        aiAssistantViewModel.initialize(for: step)
        
        // Pass relevant form data to the assistant if needed
        updateAssistantWithFormData()
        
        // Use async to avoid view update conflicts
        DispatchQueue.main.async {
            showAIAssistant = true
        }
        
        // Log assistant usage for analytics (in a real app)
        logAssistantUsage()
    }
    
    // Helper method to update the assistant with current form data
    private func updateAssistantWithFormData() {
        // This would pass current form state to the assistant
        // For demonstration purposes, we'll populate some basic information
        
        switch step {
        case .howDidYouHearAboutUs:
            if let selection = viewModel.userData[.howDidYouHearAboutUs] as? SelectionOption {
                let message = "The user has selected: \(selection.title)"
                Task {
                    await aiAssistantViewModel.conversationStore.sendMessage(message, forStep: "system_context")
                }
            }
            
        case .getName:
            if let name = viewModel.userData[.name] as? String, !name.isEmpty {
                let message = "The user has entered name: \(name)"
                Task {
                    await aiAssistantViewModel.conversationStore.sendMessage(message, forStep: "system_context")
                }
            }
            
        case .interests:
            if let interests = viewModel.userData[.interests] as? Set<InterestOption>, !interests.isEmpty {
                let interestNames = interests.map { $0.name }.joined(separator: ", ")
                let message = "The user has selected these interests: \(interestNames)"
                Task {
                    await aiAssistantViewModel.conversationStore.sendMessage(message, forStep: "system_context")
                }
            }
            
        default:
            // For other steps, we might not need to pass additional context
            break
        }
    }
    
    // Log assistant usage for analytics
    private func logAssistantUsage() {
        // In a real app, this would send analytics data
        print("AI Assistant invoked for step: \(getStepName(step))")
    }
    
    // Helper to get the step name for analytics
    private func getStepName(_ step: OnboardingStep) -> String {
        switch step {
        case .howDidYouHearAboutUs:
            return "referral"
        case .getName:
            return "name"
        case .welcomeMessage:
            return "welcome"
        case .currentStatus:
            return "currentStatus"
        case .studentLevel:
            return "education"
        case .motivationalMessage:
            return "motivation"
        case .interests:
            return "interests"
        case .riasecQuestions(let dimension):
            return "riasec_\(dimension.rawValue.lowercased())"
        case .favoriteSubjects:
            return "subjects"
        case .extracurriculars:
            return "activities"
        case .careerInterests:
            return "careers"
        case .loadingScreen:
            return "loading"
        case .completionScreen:
            return "completion"
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: 16) {
            BackButton(viewModel: viewModel)
                .frame(width: 32, height: 32)
            
            ProgressBar(currentStep: determineCurrentStep(for: step), totalSteps: 18)
        }
        .padding(.top)
    }
    
    // Determine whether to show help button based on the step
    private var shouldShowHelpButton: Bool {
        // Show help button for all steps except welcome and completion screen
        switch step {
        case .completionScreen:
            return false
        default:
            return true
        }
    }
    
    private var isNextButtonDisabled: Bool {
        switch step {
        case .howDidYouHearAboutUs:
            return viewModel.userData[.howDidYouHearAboutUs] == nil
            
        case .getName:
            return (viewModel.userData[.name] as? String)?.isEmpty ?? true
            
        case .currentStatus:
            return viewModel.userData[.currentStatus] == nil
            
        case .studentLevel:
            return viewModel.userData[.studentLevel] == nil
            
        case .interests:
            if let selectedInterests = viewModel.userData[.interests] as? Set<InterestOption> {
                return selectedInterests.count < 1 || selectedInterests.count > 5
            } else if let selectedInterests = viewModel.userData[.interests] as? [InterestOption] {
                return selectedInterests.count < 1 || selectedInterests.count > 5
            }
            return true
            
        case .riasecQuestions(let dimension):
            // Questions come from the dimension itself
            let dimensionQuestions = dimension.questions
            
            // Try checking dimension-specific responses first
            if let riasecResponses = viewModel.userData[.riasecResponses] as? [String: Any] {
                if let dimensionObj = riasecResponses[dimension.rawValue] {
                    // Handle different formats
                    if let dimensionResponses = dimensionObj as? [String: Int] {
                        return dimensionResponses.count < dimensionQuestions.count
                    } else if let dimensionAny = dimensionObj as? [String: Any] {
                        return dimensionAny.count < dimensionQuestions.count
                    }
                }
            }
            
            // Fall back to checking flattened responses
            if let flattenedResponses = viewModel.userData[.riasecResponsesFlat] as? [String: Int] {
                // Count how many of this dimension's questions are answered
                let answeredCount = dimensionQuestions.filter { flattenedResponses[$0] != nil }.count
                return answeredCount < dimensionQuestions.count
            }
            
            // If we can't find responses in any format, disable the button
            return true
            
        case .favoriteSubjects:
            if let subjects = viewModel.userData[.favoriteSubjects] as? Set<SchoolSubject> {
                return subjects.isEmpty || subjects.count > 3
            }
            return true
            
        case .extracurriculars, .careerInterests:
            return false
            
        default:
            return false
        }
    }
    
    private var showNextButton: Bool {
        switch step {
        case .loadingScreen:
            return false // No manual navigation from loading screen
        default:
            return true
        }
    }
    
    private var showNavigationBar: Bool {
        switch step {
        case .completionScreen:
            return false
        default:
            return true
        }
    }
    
    private var nextButtonTitle: String {
        switch step {
        case .completionScreen:
            return "Create Account"
        case .motivationalMessage:
            return "Let's Go"
        default:
            return "Next"
        }
    }
    
    private var stepTitle: String {
        switch step {
        case .howDidYouHearAboutUs:
            return "Welcome! How Did You Hear About Us?"
        case .getName:
            return "Let's Get to Know You"
        case .welcomeMessage(let name):
            return "Welcome, \(name)!"
        case .currentStatus:
            return "What's Your Current Status?"
        case .studentLevel:
            return "What's Your Student Level?"
        case .motivationalMessage:
            return ""
        case .interests:
            return "What Best Describes You?"
        case .riasecQuestions(let dimension):
            return dimension.title
        case .favoriteSubjects:
            return "What Are Your Favorite School Subjects?"
        case .extracurriculars:
            return "What Activities Do You Enjoy Outside of School?"
        case .careerInterests:
            return "What Careers Interest You the Most?"
        case .loadingScreen:
            return ""
        case .completionScreen:
            return ""
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .howDidYouHearAboutUs:
            HowDidYouHearAboutUsView(viewModel: viewModel)
        case .getName:
            GetNameView(viewModel: viewModel)
        case .welcomeMessage(let name):
            WelcomeMessageView(name: name)
        case .currentStatus:
            CurrentStatusView(viewModel: viewModel)
        case .studentLevel:
            StudentLevelView(viewModel: viewModel)
        case .motivationalMessage:
            MotivationalMessageView(viewModel: viewModel)
        case .interests:
            InterestProfileView(viewModel: viewModel)
        case .riasecQuestions(let dimension):
            RIASECQuestionView(viewModel: viewModel, dimension: dimension)
        case .favoriteSubjects:
            FavoriteSubjectsView(viewModel: viewModel)
        case .extracurriculars:
            ExtracurricularActivitiesView(viewModel: viewModel)
        case .careerInterests:
            CareerInterestsView(viewModel: viewModel)
        case .loadingScreen:
            LoadingScreenView(viewModel: viewModel)
        case .completionScreen:
            CompletionScreenView(viewModel: viewModel)
        }
    }
    
    private func determineCurrentStep(for step: OnboardingStep) -> Int {
        switch step {
        case .howDidYouHearAboutUs: return 1
        case .getName: return 2
        case .welcomeMessage: return 3
        case .currentStatus: return 4
        case .studentLevel: return 5
        case .motivationalMessage: return 6
        case .interests: return 7
        case .riasecQuestions(let dimension):
            return 8 + RIASECDimension.allCases.firstIndex(of: dimension)!
        case .favoriteSubjects: return 14
        case .extracurriculars: return 15
        case .careerInterests: return 16
        case .loadingScreen: return 17
        case .completionScreen: return 18
        }
    }
    
    private func navigateToNextStep() {
        // Use the centralized navigation method in the view model
        // This ensures consistent forward navigation with proper history tracking
        viewModel.nextOnboardingStep()
        
        // Special case for loading screen to start career suggestion generation
        if case .onboarding(.loadingScreen) = viewModel.appFlowState {
            // Start career suggestion generation immediately
            Task {
                print("Starting career suggestion generation")
                await viewModel.generateCareerSuggestions()
                print("Career suggestion generation complete, moving to completion screen")
                // Ensure we're on the main thread and move to the completion screen
                await MainActor.run {
                    viewModel.appFlowState = .onboarding(step: .completionScreen)
                }
            }
        }
        
        // Special case for completion screen to show account creation prompt
        if case .onboarding(.completionScreen) = viewModel.appFlowState {
            showAccountCreationPrompt = true
        }
    }
    
    private func getNextRIASECDimension(after current: RIASECDimension) -> RIASECDimension? {
        let all = RIASECDimension.allCases
        guard let currentIndex = all.firstIndex(of: current),
              currentIndex < all.count - 1 else {
            return nil
        }
        return all[currentIndex + 1]
    }
    
}

// MARK: - Supporting Views
// We'll need to implement these views that are referenced in the OnboardingView

// MARK: - Account Creation Prompt
struct AccountCreationPromptView: View {
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Spacer()
                Text("Create an Account")
                    .font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .padding(.bottom)
            
            // Content
            VStack(spacing: 16) {
                Text("Save your progress and recommendations")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Create an account to access your personalized career recommendations anytime, anywhere.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        // Sign up action
                        viewModel.navigateTo(.login)
                        dismiss()
                    } label: {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        // Skip action - go to dashboard
                        viewModel.navigateTo(.dashboard)
                        dismiss()
                    } label: {
                        Text("Continue as Guest")
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Back Button
struct BackButton: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showConfirmation = false
    
    var body: some View {
        Button(action: handleBackPress) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primary)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Return to Welcome?"),
                message: Text("Going back will reset all your progress in the onboarding process. This cannot be undone."),
                primaryButton: .destructive(Text("Reset & Go Back")) {
                    // Proceed with navigation which will reset data and go to welcome
                    viewModel.previousOnboardingStep()
                },
                secondaryButton: .cancel(Text("Stay Here"))
            )
        }
    }
    
    private func handleBackPress() {
        // Check if going back would return to welcome page
        if wouldReturnToWelcome() {
            // Show confirmation since this will reset all progress
            showConfirmation = true
        } else {
            // Just regular back navigation within the flow
            viewModel.previousOnboardingStep()
        }
    }
    
    // Determines if pressing back would return to the welcome/initial screen
    // This is where we decide when to show the confirmation and reset data
    private func wouldReturnToWelcome() -> Bool {
        guard case .onboarding(let currentStep) = viewModel.appFlowState else { return false }
        
        // Special case for the first screen
        if case .howDidYouHearAboutUs = currentStep {
            return true
        }
        
        // For other screens, check if they directly navigate to welcome
        // This covers cases where other screens might go straight to welcome
        // due to special navigation rules or errors
        let previousStep = calculatePreviousStepLocally(from: currentStep)
        return previousStep == nil // nil previous step means we'd go to welcome
    }
    
    // Simplified local version to avoid circular dependencies
    private func calculatePreviousStepLocally(from currentStep: OnboardingStep) -> OnboardingStep? {
        switch currentStep {
        case .getName:
            return .howDidYouHearAboutUs
        case .howDidYouHearAboutUs:
            return nil // Indicates return to welcome
        case .riasecQuestions(let dimension):
            // For RIASEC questions, we need to handle going back through dimensions
            // or back to interests for the first dimension
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
        default:
            // For other steps, we don't need exact calculation since we just want
            // to know if it returns to welcome, which only happens with .howDidYouHearAboutUs
            return .howDidYouHearAboutUs // Default non-nil value for other steps
        }
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 4) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // Filled progress
                    Rectangle()
                        .fill(AppColors.primary)
                        .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
}

// MARK: - Placeholder Onboarding Step Views
// These would need to be replaced with actual implementations

struct HowDidYouHearAboutUsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selection: String?
    @State private var otherText: String = ""
    
    // 6 common options + Other
    private let options = [
        "Friend or Family",
        "School or Teacher",
        "Social Media", 
        "Search Engine",
        "App Store",
        "Advertisement",
        "Other"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Removed duplicate header - already provided by OnboardingView
            
            Text("We'd love to know how you discovered MyPath.")
                .foregroundColor(.secondary)
                .padding(.bottom, 24) // Better breathing room before options
            
            VStack(spacing: 0) {
                ForEach(options, id: \.self) { opt in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = opt
                            if opt != "Other" {
                                viewModel.userData[.howDidYouHearAboutUs] = opt
                            } else {
                                // If other is selected but no text, don't update yet
                                if !otherText.isEmpty {
                                    viewModel.userData[.howDidYouHearAboutUs] = otherText
                                }
                            }
                        }
                    }) {
                        HStack {
                            Text(opt)
                                .foregroundColor(.primary)
                                .font(.body)
                            
                            Spacer()
                            
                            if selection == opt {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selection == opt ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selection == opt ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.bottom, selection == "Other" && opt == "Other" ? 0 : 12)
                    
                    // Insert inline TextField under "Other"
                    if opt == "Other", selection == "Other" {
                        TextField("Please specify…", text: $otherText)
                            .font(.body)
                            .padding(.vertical, 12)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.3)),
                                alignment: .bottom
                            )
                            .onChange(of: otherText) { newValue in
                                if !newValue.isEmpty {
                                    viewModel.userData[.howDidYouHearAboutUs] = newValue
                                }
                            }
                            .padding(.bottom, 12)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            // Handle loading existing data
            if let savedValue = viewModel.userData[.howDidYouHearAboutUs] as? String {
                if options.contains(savedValue) {
                    selection = savedValue
                } else {
                    selection = "Other"
                    otherText = savedValue
                }
            }
        }
    }
}

struct GetNameView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var name: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Removed duplicate header - already provided by OnboardingView
            
            Text("We'll use this to personalize your experience.")
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextField("Enter your name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .onChange(of: name) { newValue in
                        viewModel.userData[.name] = newValue
                    }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            name = viewModel.userData[.name] as? String ?? ""
        }
    }
}

struct WelcomeMessageView: View {
    let name: String
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.fill.checkmark")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding()
                .background(Circle().fill(Color.blue.opacity(0.1)))
                .padding(.bottom, 10)
            
            Text("Welcome, \(name)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("We're excited to help you explore your career options and plan your future.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Let's get started with a few questions to personalize your experience.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

struct CurrentStatusView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedStatus: String?
    
    private let statusOptions = [
        "High School Student",
        "College Student",
        "Recent Graduate",
        "Working Professional",
        "Career Changer",
        "Taking a Gap Year",
        "Other"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Removed duplicate header - already provided by OnboardingView
            
            Text("This helps us tailor recommendations to your situation.")
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(statusOptions, id: \.self) { option in
                        Button(action: {
                            selectedStatus = option
                            viewModel.userData[.currentStatus] = option
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                
                                Spacer()
                                
                                if selectedStatus == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedStatus == option ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedStatus == option ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    if selectedStatus == "Other" {
                        TextField("Please specify", text: Binding(
                            get: { viewModel.userData[.currentStatus] as? String ?? "" },
                            set: { viewModel.userData[.currentStatus] = $0 }
                        ))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            selectedStatus = viewModel.userData[.currentStatus] as? String
        }
    }
}

struct StudentLevelView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedLevel: String?
    
    private let levelOptions = [
        "High School Freshman",
        "High School Sophomore",
        "High School Junior",
        "High School Senior",
        "College Freshman",
        "College Sophomore",
        "College Junior",
        "College Senior",
        "Graduate Student",
        "Not Currently a Student"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Removed duplicate header - already provided by OnboardingView
            
            Text("This helps us recommend appropriate resources and opportunities.")
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(levelOptions, id: \.self) { option in
                        Button(action: {
                            selectedLevel = option
                            viewModel.userData[.studentLevel] = option
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                
                                Spacer()
                                
                                if selectedLevel == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedLevel == option ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedLevel == option ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            selectedLevel = viewModel.userData[.studentLevel] as? String
        }
    }
}

struct MotivationalMessageView: View {
    @ObservedObject var viewModel: AppViewModel
    
    // Get name from userData if available
    private var userName: String {
        viewModel.userData[.name] as? String ?? "there"
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .padding()
                .background(Circle().fill(Color.yellow.opacity(0.2)))
                .padding(.bottom, 20)
            
            Text("You're doing great, \(userName)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Text("Your journey to finding the perfect career path is well underway.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("The next few questions will help us understand your interests and strengths better.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Remember, there are no wrong answers! We're here to help you explore what's possible.")
                .font(.callout)
                .foregroundColor(.gray)
                .italic()
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

struct InterestProfileView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedInterests: Set<InterestOption> = []
    
    private let interestCategories = [
        InterestOption(name: "Technology & Computing"),
        InterestOption(name: "Science & Research"),
        InterestOption(name: "Arts & Design"),
        InterestOption(name: "Business & Finance"),
        InterestOption(name: "Healthcare & Medicine"),
        InterestOption(name: "Education & Teaching"),
        InterestOption(name: "Engineering"),
        InterestOption(name: "Communication & Media"),
        InterestOption(name: "Helping & Social Services"),
        InterestOption(name: "Nature & Environment"),
        InterestOption(name: "Sports & Athletics")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Removed duplicate header - already provided by OnboardingView
            
            Text("Select up to 5 categories that appeal to you.")
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            Text("Selected: \(selectedInterests.count)/5")
                .font(.subheadline)
                .foregroundColor(selectedInterests.count == 5 ? .blue : .gray)
                .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(interestCategories, id: \.id) { interest in
                        Button(action: {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else if selectedInterests.count < 5 {
                                selectedInterests.insert(interest)
                            }
                            viewModel.userData[.interests] = selectedInterests
                        }) {
                            HStack {
                                Text(interest.name)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                
                                Spacer()
                                
                                if selectedInterests.contains(interest) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedInterests.contains(interest) ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedInterests.contains(interest) ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(selectedInterests.count >= 5 && !selectedInterests.contains(interest))
                    }
                }
            }
            
            if selectedInterests.isEmpty {
                Text("Please select at least one interest to continue")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            } else if selectedInterests.count > 5 {
                Text("Please select no more than 5 interests")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .padding()
        .onAppear {
            if let savedInterests = viewModel.userData[.interests] as? Set<InterestOption> {
                selectedInterests = savedInterests
            }
        }
    }
}


struct LoadingScreenView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Larger progress view
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Processing your responses...")
                .font(.title3)
                .foregroundColor(.secondary)
                .padding()
                
            // Start generation as soon as view appears
            Text("Analyzing your interests and skills...")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Safety mechanism: move to completion screen after 5 seconds max
            // in case the async task somehow gets stuck
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if case .onboarding(let currentStep) = viewModel.appFlowState, 
                   currentStep == .loadingScreen {
                    print("Safety timeout triggered for loading screen")
                    viewModel.appFlowState = .onboarding(step: .completionScreen)
                }
            }
        }
    }
}

struct CompletionScreenView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack {
            Text("All done!")
                .font(.title)
            
            Text("Your career profile is complete.")
                .padding()
        }
    }
}

// MARK: - Helper Structs for Onboarding

struct SchoolSubject: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static let allSubjects: [SchoolSubject] = [
        SchoolSubject(name: "Math"),
        SchoolSubject(name: "Science"),
        SchoolSubject(name: "Art"),
        SchoolSubject(name: "History"),
        SchoolSubject(name: "English"),
        SchoolSubject(name: "Technology"),
        SchoolSubject(name: "Physical Education"),
        SchoolSubject(name: "Other")
    ]
}

struct FavoriteSubjectsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedSubjects: Set<SchoolSubject> = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select up to 3 subjects you enjoy the most.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(SchoolSubject.allSubjects) { subject in
                        SelectionButton(
                            title: subject.name,
                            isSelected: selectedSubjects.contains(subject),
                            action: {
                                if selectedSubjects.contains(subject) {
                                    selectedSubjects.remove(subject)
                                } else if selectedSubjects.count < 3 {
                                    selectedSubjects.insert(subject)
                                }
                            }
                        )
                    }
                }
            }
            
            // Selection Counter
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index < selectedSubjects.count ? AppColors.primary : Color.gray.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text("\(selectedSubjects.count)/3 selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
        }
        .padding()
        .onChange(of: selectedSubjects) { newValue in
            viewModel.userData[.favoriteSubjects] = newValue
        }
        .onAppear {
            if let saved = viewModel.userData[.favoriteSubjects] as? Set<SchoolSubject> {
                selectedSubjects = saved
            }
        }
    }
}

struct SelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(isSelected ? AppColors.primary : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct Activity: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static let allActivities: [Activity] = [
        Activity(name: "Robotics Club"),
        Activity(name: "Drama or Theatre"),
        Activity(name: "Sports"),
        Activity(name: "Debate Team"),
        Activity(name: "Volunteering"),
        Activity(name: "Music or Band"),
        Activity(name: "Other")
    ]
}

struct Career: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static let suggestedCareers: [Career] = [
        Career(name: "Doctor"),
        Career(name: "Engineer"),
        Career(name: "Artist"),
        Career(name: "Entrepreneur"),
        Career(name: "Research Scientist"),
        Career(name: "Teacher"),
        Career(name: "Other")
    ]
}

struct ExtracurricularActivitiesView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedActivities: Set<Activity> = []
    @State private var otherActivity: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select any activities that interest you.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Activity.allActivities) { activity in
                        SelectionButton(
                            title: activity.name,
                            isSelected: selectedActivities.contains(activity),
                            action: {
                                if selectedActivities.contains(activity) {
                                    selectedActivities.remove(activity)
                                    if activity.name == "Other" {
                                        otherActivity = ""
                                    }
                                } else {
                                    selectedActivities.insert(activity)
                                }
                            }
                        )
                        
                        if activity.name == "Other" && selectedActivities.contains(activity) {
                            TextField("Enter your activity", text: $otherActivity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .padding()
        .onChange(of: selectedActivities) { newValue in
            viewModel.userData[.extracurriculars] = newValue
        }
        .onChange(of: otherActivity) { newValue in
            viewModel.userData[.extracurricularOther] = newValue
        }
        .onAppear {
            if let saved = viewModel.userData[.extracurriculars] as? Set<Activity> {
                selectedActivities = saved
            }
            if let savedOther = viewModel.userData[.extracurricularOther] as? String {
                otherActivity = savedOther
            }
        }
    }
}

struct CareerInterestsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedCareers: Set<Career> = []
    @State private var otherCareer: String = ""
    @State private var showCustomCareerField = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select or type any careers or jobs that excite you.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Career.suggestedCareers) { career in
                        SelectionButton(
                            title: career.name,
                            isSelected: selectedCareers.contains(career),
                            action: {
                                if selectedCareers.contains(career) {
                                    selectedCareers.remove(career)
                                    if career.name == "Other" {
                                        otherCareer = ""
                                        showCustomCareerField = false
                                    }
                                } else {
                                    selectedCareers.insert(career)
                                    if career.name == "Other" {
                                        showCustomCareerField = true
                                    }
                                }
                            }
                        )
                    }
                    
                    if showCustomCareerField {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What career interests you?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter career", text: $otherCareer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding()
        .onChange(of: selectedCareers) { newValue in
            viewModel.userData[.careerInterests] = newValue
        }
        .onChange(of: otherCareer) { newValue in
            viewModel.userData[.careerInterestsOther] = newValue
        }
        .onAppear {
            if let saved = viewModel.userData[.careerInterests] as? Set<Career> {
                selectedCareers = saved
            }
            if let savedOther = viewModel.userData[.careerInterestsOther] as? String {
                otherCareer = savedOther
            }
        }
    }
}

struct HelpSheetView: View {
    let step: OnboardingStep
    @Environment(\.dismiss) var dismiss
    
    init(for step: OnboardingStep) {
        self.step = step
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(helpTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text(helpContent)
                        .font(.body)
                    
                    if let tips = helpTips {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tips:")
                                .font(.headline)
                            
                            ForEach(tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                    
                                    Text(tip)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var helpTitle: String {
        switch step {
        case .getName:
            return "About Your Name"
        case .welcomeMessage:
            return "Getting Started"
        case .currentStatus:
            return "About Your Status"
        case .studentLevel:
            return "About Education Level"
        case .motivationalMessage:
            return "Your Journey"
        case .interests:
            return "About Interests"
        case .riasecQuestions:
            return "About RIASEC Questions"
        case .favoriteSubjects:
            return "About Subject Selection"
        case .extracurriculars:
            return "About Activities"
        case .careerInterests:
            return "About Career Interests"
        default:
            return "Help & Information"
        }
    }
    
    private var helpContent: String {
        switch step {
        case .getName:
            return "We use your first name to personalize your experience throughout the app. This helps us make recommendations that feel more relevant to you."
        case .currentStatus:
            return "Understanding your current status helps us tailor our career recommendations and learning content to your specific situation."
        case .studentLevel:
            return "Your educational background helps us suggest career paths that align with your qualifications and academic interests."
        case .interests:
            return "Your interests help us identify career paths that you're likely to find fulfilling and engaging. Select what resonates most with you."
        case .riasecQuestions:
            return "These questions help us understand your personality and work preferences through the RIASEC model, which categorizes career interests into six types: Realistic, Investigative, Artistic, Social, Enterprising, and Conventional."
        case .favoriteSubjects:
            return "Your favorite subjects provide insights into the fields where you might excel and find satisfaction in your career."
        case .extracurriculars:
            return "Activities outside of school or work reveal additional skills and interests that can inform your career path recommendations."
        case .careerInterests:
            return "Sharing careers you're already interested in helps us refine our recommendations and provide relevant information about those fields."
        default:
            return "This section helps us understand your preferences better. The more information you provide, the more personalized your career recommendations will be."
        }
    }
    
    private var helpTips: [String]? {
        switch step {
        case .riasecQuestions:
            return [
                "Answer honestly based on your preferences, not what you think you should say",
                "Don't overthink - your first instinct is often most accurate",
                "There are no right or wrong answers - this is about your unique interests"
            ]
        case .interests:
            return [
                "Choose what genuinely interests you, not what seems practical",
                "Think about activities you enjoy even when they're challenging",
                "Consider what fields you naturally read about or discuss with others"
            ]
        case .careerInterests:
            return [
                "Include careers you're curious about, even if you're not sure yet",
                "Don't limit yourself based on your current qualifications",
                "Think broadly about industries and roles that appeal to you"
            ]
        default:
            return nil
        }
    }
}

struct InterestOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static func == (lhs: InterestOption, rhs: InterestOption) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
