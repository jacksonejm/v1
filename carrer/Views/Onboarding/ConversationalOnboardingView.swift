import SwiftUI

struct ConversationalOnboardingView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var onboardingStore: OnboardingStore
    @StateObject private var engine: ConversationalOnboardingEngine
    @StateObject private var conversationStore = ConversationStore()
    
    @State private var inputText = ""
    @State private var showingExitConfirmation = false
    @State private var keyboardHeight: CGFloat = 0
    
    init(onboardingStore: OnboardingStore) {
        _engine = StateObject(wrappedValue: ConversationalOnboardingEngine(onboardingStore: onboardingStore))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                conversationHeader
                
                Divider()
                
                // Messages
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(engine.messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if engine.isProcessing {
                                HStack {
                                    TypingIndicator()
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: engine.messages.count) { _ in
                        withAnimation {
                            scrollProxy.scrollTo(engine.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                Divider()
                
                // Input area
                conversationInputArea
            }
            
            // Loading overlay for phase transitions
            if engine.conversationState == .processing && engine.phase == .completion {
                LoadingOverlay(message: "Creating your profile...")
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                // Check if we're switching from forms mode
                if let modeManager = viewModel.onboardingModeManager,
                   modeManager.previousMode == .traditional,
                   !onboardingStore.values.isEmpty {
                    // We're switching from forms with existing data
                    let dataBridge = OnboardingDataBridge()
                    await dataBridge.syncFromForms(onboardingStore, to: engine)
                } else {
                    // Start fresh onboarding
                    await engine.startOnboarding()
                }
            }
        }
        .onDisappear {
            engine.handleViewDisappear()
        }
        .alert("Leave Conversation?", isPresented: $showingExitConfirmation) {
            Button("Stay", role: .cancel) { }
            Button("Leave", role: .destructive) {
                navigateBack()
            }
        } message: {
            Text("Your progress will be saved. You can continue this conversation later.")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
    
    // MARK: - Header
    
    private var conversationHeader: some View {
        HStack {
            Button(action: { showingExitConfirmation = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Exit")
                        .font(.system(size: 16))
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("MyPath Assistant")
                    .font(.headline)
                
                if let status = engine.conversationState.statusMessage {
                    Text(status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Mode switch button
            Menu {
                Button(action: { switchToForms() }) {
                    Label("Switch to Forms", systemImage: "doc.text")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 8)
            
            // Progress indicator
            ConversationProgressIndicator(phase: engine.phase)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    // MARK: - Input Area
    
    private var conversationInputArea: some View {
        VStack(spacing: 0) {
            // Quick reply suggestions
            if !engine.quickReplySuggestions.isEmpty && engine.conversationState == .waitingForUser {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(engine.quickReplySuggestions, id: \.self) { suggestion in
                            Button(action: {
                                inputText = suggestion
                                sendMessage()
                            }) {
                                Text(suggestion)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(UIColor.tertiarySystemBackground))
            }
            
            // Skip button
            if engine.phase.requiresUserInput && engine.conversationState == .waitingForUser {
                HStack {
                    Button(action: skipCurrentQuestion) {
                        Text("Skip this question")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Spacer()
                }
                .background(Color(UIColor.tertiarySystemBackground))
            }
            
            // Input field
            HStack(spacing: 12) {
                TextField("Type your response...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!engine.conversationState.isInteractive)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(canSendMessage ? .blue : .gray)
                }
                .disabled(!canSendMessage)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    // MARK: - Computed Properties
    
    private var canSendMessage: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        engine.conversationState.isInteractive &&
        !engine.isProcessing
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        inputText = ""
        
        Task {
            if case .waitingForConfirmation(let data) = engine.conversationState {
                // Handle confirmation response
                let isConfirmation = message.lowercased().contains("yes") ||
                                   message.lowercased().contains("correct") ||
                                   message.lowercased().contains("right")
                await engine.handleConfirmation(isConfirmation, for: data)
            } else {
                // Normal message processing
                await engine.processUserMessage(message)
            }
        }
    }
    
    private func skipCurrentQuestion() {
        Task {
            await engine.skipCurrentPhase()
        }
    }
    
    private func navigateBack() {
        // Save progress before leaving
        engine.syncAllDataToStore()
        
        // Navigate back to mode selection
        viewModel.navigateTo(.onboardingModeSelection)
    }
    
    // MARK: - Private Methods
    
    private func switchToForms() {
        // Create data bridge
        let dataBridge = OnboardingDataBridge()
        
        // Sync conversation data to forms
        dataBridge.syncFromConversation(engine.collectedData, to: onboardingStore)
        
        // Update mode manager
        if let modeManager = viewModel.onboardingModeManager {
            modeManager.currentMode = .traditional
        }
        
        // Navigate to traditional forms - determine the right step
        let nextStep = determineNextFormStep()
        viewModel.appFlowState = .onboarding(step: nextStep)
    }
    
    private func determineNextFormStep() -> OnboardingStep {
        let data = engine.collectedData
        
        if data.firstName == nil {
            return .getName
        }
        if data.currentStatus == nil {
            return .currentStatus
        }
        if data.educationLevel == nil && data.currentStatus == "student" {
            return .studentLevel
        }
        if data.careerInterests.isEmpty {
            return .careerInterests
        }
        if data.favoriteSubjects.isEmpty {
            return .favoriteSubjects
        }
        if data.extracurriculars.isEmpty {
            return .extracurriculars
        }
        if data.riasecResponses.isEmpty {
            return .riasecQuestions(dimension: .realistic)
        }
        
        return .completionScreen
    }
}

// MARK: - Progress Indicator

struct ConversationProgressIndicator: View {
    let phase: ConversationPhase
    
    private var progress: Double {
        let allPhases = ConversationPhase.allCases
        guard let currentIndex = allPhases.firstIndex(of: phase) else { return 0 }
        return Double(currentIndex) / Double(allPhases.count - 1)
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            ProgressView(value: progress)
                .frame(width: 60)
                .tint(.blue)
        }
    }
}