import SwiftUI
import Combine

@MainActor
class AIAssistantViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isProcessing = false
    @Published var isVoiceMode: Bool = false
    @Published var error: Error?
    @Published var isOfflineMode: Bool = false
    @Published var showConnectionAlert: Bool = false
    
    // MARK: - Private Properties
    let conversationStore: ConversationStore
    private let onboardingStore: OnboardingStore
    private var currentStep: OnboardingStep?
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NetworkMonitor.shared
    
    // MARK: - Initialization
    init(onboardingStore: OnboardingStore, conversation: Conversation? = nil) {
        self.onboardingStore = onboardingStore
        self.conversationStore = ConversationStore(conversation: conversation)
        ToolRegistry.shared.registerTool(UpdateFieldTool(onboardingStore: onboardingStore))
        setupBindings()
        
        // Subscribe to network status changes
        networkMonitor.$isConnected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)   // make sure we're on the main thread
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                
                // 1) Update sync state for your UI
                self.isOfflineMode = !isConnected
                if self.isOfflineMode {
                    self.showConnectionAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.showConnectionAlert = false
                    }
                }
                
                // 2) Fire off any async syncing
                if !self.isOfflineMode && !self.messages.isEmpty {
                    Task {
                        await self.conversationStore.synchronizeOfflineConversations()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Initialize the assistant with context for the current step
    func initialize(for step: OnboardingStep) {
        self.currentStep = step
        
        // Update conversation store with step information
        let stepName = getStepName(step)
        self.conversationStore.currentConversation?.step = stepName
        
        // Add initial welcome message based on the step
        let initialPrompt = getContextAwarePrompt(for: step)
        let welcomeMessage = ChatMessage(
            id: UUID(),
            content: initialPrompt,
            isUser: false,
            timestamp: Date()
        )
        
        conversationStore.messages = [welcomeMessage]
        
        // Log assistant invocation for analytics
        logAssistantInvocation(step: step)
    }
    
    /// Send a message and get a response
    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Get step name for the conversation context
        let stepName = currentStep.map { getStepName($0) } ?? "unknown"
        
        // Store the input text and clear the field
        let message = inputText
        inputText = ""
        
        // Send through conversation store
        await conversationStore.sendMessage(message, forStep: stepName)
    }
    
    /// Process voice input
    func processVoiceInput(_ text: String?) {
        guard let text = text, !text.isEmpty else { return }
        inputText = text
        
        // Auto-send voice message
        Task {
            await sendMessage()
        }
        
        // Exit voice mode
        isVoiceMode = false
    }
    
    /// Toggle voice mode
    func toggleVoiceMode() {
        isVoiceMode.toggle()
    }
    
    // MARK: - Private Methods
    
    /// Set up data bindings
    private func setupBindings() {
        // Bind conversation store properties to view model
        conversationStore.$messages
            .assign(to: &$messages)
        
        conversationStore.$isLoading
            .assign(to: &$isProcessing)
        
        conversationStore.$error
            .assign(to: &$error)
    }
    
    /// Get step name for the conversation context
    private func getStepName(_ step: OnboardingStep) -> String {
        switch step {
        case .howDidYouHearAboutUs:
            return "referral"
        case .countrySelection:
            return "country"
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
        case .workValues:
            return "workValues"
        case .loadingScreen:
            return "loading"
        case .completionScreen:
            return "completion"
        }
    }
    
    /// Get a context-aware welcome prompt based on the step
    private func getContextAwarePrompt(for step: OnboardingStep) -> String {
        switch step {
        case .howDidYouHearAboutUs:
            return "Need help with how you heard about us? I can explain the options and why we're asking."

        case .countrySelection:
            return "Need help choosing your country? I can explain how we use this information to provide relevant career information."

        case .getName:
            return "Hi! Need help entering your name? I'm here to assist you with the onboarding process."
            
        case .welcomeMessage:
            return "Welcome to MyPath! I'm here to help you get started with the app."
            
        case .currentStatus:
            return "Need help choosing your current status? I can explain what each option means for your career journey."
            
        case .studentLevel:
            return "Choosing your education level helps us tailor recommendations. Need help with this step?"
            
        case .motivationalMessage:
            return "I'm here to support you on your career journey. How can I help motivate you?"
            
        case .interests:
            return "Selecting interests helps us understand what motivates you. Need help choosing interests that align with your career goals?"
            
        case .riasecQuestions(let dimension):
            return "These questions help us understand your \(dimension.rawValue) preferences. Need help answering them?"
            
        case .favoriteSubjects:
            return "Your favorite subjects can reveal potential career paths. Need help selecting subjects that align with your interests?"
            
        case .extracurriculars:
            return "Activities outside school/work can reveal important skills. Need help selecting relevant activities?"
            
        case .careerInterests:
            return "What careers interest you most? I can help you explore options and understand different paths."

        case .workValues:
            return "Work values help us understand what matters most to you in a career. Need help rating what's important to you?"

        case .loadingScreen:
            return "I'm here while your profile is being processed. Do you have any questions about what happens next?"

        case .completionScreen:
            return "Congratulations on completing your profile! I can help you understand your results or next steps."
        }
    }
    
    /// Log the assistant invocation for analytics
    private func logAssistantInvocation(step: OnboardingStep) {
        // In a real app, this would send analytics data
        print("AI Assistant invoked for step: \(getStepName(step))")
    }
}
