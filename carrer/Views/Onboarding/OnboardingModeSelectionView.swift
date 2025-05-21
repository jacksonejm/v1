import SwiftUI

struct OnboardingModeSelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    @ObservedObject var onboardingStore: OnboardingStore
    @StateObject private var modeManager: OnboardingModeManager
    @State private var selectedMode: OnboardingMode?
    @State private var showingConversationalPreview = false
    @State private var animateIn = false
    
    init(viewModel: AppViewModel, onboardingStore: OnboardingStore) {
        self.viewModel = viewModel
        self.onboardingStore = onboardingStore
        _modeManager = StateObject(wrappedValue: OnboardingModeManager(onboardingStore: onboardingStore))
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Navigation bar with back button
                HStack {
                    Button(action: { navigateBack() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.blue)
                    }
                    .opacity(animateIn ? 1 : 0)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .scaleEffect(animateIn ? 1 : 0.5)
                        .opacity(animateIn ? 1 : 0)
                    
                    Text("Welcome to MyPath")
                        .font(.largeTitle)
                        .bold()
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                    
                    Text("How would you like to get started?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Mode selection cards
                VStack(spacing: 20) {
                    // AI Conversation option (Primary)
                    ModeSelectionCard(
                        mode: .conversational,
                        isSelected: selectedMode == .conversational,
                        isPrimary: true,
                        animateIn: animateIn
                    ) {
                        selectMode(.conversational)
                    }
                    .offset(x: animateIn ? 0 : -50)
                    
                    // Traditional Forms option (Secondary)
                    ModeSelectionCard(
                        mode: .traditional,
                        isSelected: selectedMode == .traditional,
                        isPrimary: false,
                        animateIn: animateIn
                    ) {
                        selectMode(.traditional)
                    }
                    .offset(x: animateIn ? 0 : 50)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                if let selected = selectedMode {
                    Button(action: { startOnboarding(with: selected) }) {
                        HStack {
                            Text("Continue with \(selected.displayName)")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Learn more link
                Button(action: { showingConversationalPreview = true }) {
                    Text("Learn more about AI conversation mode")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 40)
                .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
        .sheet(isPresented: $showingConversationalPreview) {
            ConversationalModePreview()
        }
    }
    
    private func navigateBack() {
        // Navigate back to welcome view
        viewModel.navigateTo(.initial)
    }
    
    private func selectMode(_ mode: OnboardingMode) {
        withAnimation(.spring()) {
            selectedMode = mode
        }
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func startOnboarding(with mode: OnboardingMode) {
        modeManager.selectMode(mode)
        
        // Update app flow state through view model
        switch mode {
        case .conversational:
            viewModel.navigateTo(.conversationalOnboarding)
        case .traditional:
            viewModel.navigateTo(.onboarding(step: .howDidYouHearAboutUs))
        case .unselected:
            break
        }
    }
}

// MARK: - Mode Selection Card

struct ModeSelectionCard: View {
    let mode: OnboardingMode
    let isSelected: Bool
    let isPrimary: Bool
    let animateIn: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: mode.iconName)
                    .font(.system(size: isPrimary ? 50 : 40))
                    .foregroundColor(iconColor)
                
                // Title
                Text(mode.displayName)
                    .font(.headline)
                    .foregroundColor(textColor)
                
                // Description
                Text(mode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Primary badge
                if isPrimary {
                    Text("RECOMMENDED")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
            )
            .scaleEffect(isSelected ? 1.02 : 1)
            .shadow(
                color: shadowColor,
                radius: isPrimary ? 8 : 4,
                y: isPrimary ? 4 : 2
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .opacity(animateIn ? 1 : 0)
        .scaleEffect(animateIn ? 1 : 0.8)
    }
    
    private var iconColor: Color {
        if isSelected {
            return .blue
        } else if isPrimary {
            return .blue
        } else {
            return .gray
        }
    }
    
    private var textColor: Color {
        isSelected ? .primary : .primary.opacity(0.9)
    }
    
    private var backgroundColor: Color {
        if isPrimary && !isSelected {
            return Color.blue.opacity(0.08)
        } else {
            return Color(UIColor.systemBackground)
        }
    }
    
    private var borderColor: Color {
        isSelected ? .blue : .clear
    }
    
    private var shadowColor: Color {
        if isSelected {
            return .blue.opacity(0.3)
        } else if isPrimary {
            return .black.opacity(0.1)
        } else {
            return .black.opacity(0.05)
        }
    }
}

// MARK: - Conversational Mode Preview

struct ConversationalModePreview: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero image
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    
                    // Title
                    Text("AI Conversation Mode")
                        .font(.largeTitle)
                        .bold()
                    
                    // Description
                    Text("Experience a natural, engaging way to create your profile. Our AI assistant will guide you through a friendly conversation, making the onboarding process feel less like filling out forms and more like chatting with a helpful career counselor.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "mic.fill",
                            title: "Voice Support",
                            description: "Speak naturally with voice input, or type your responses"
                        )
                        
                        FeatureRow(
                            icon: "brain",
                            title: "Smart Understanding",
                            description: "Our AI understands context and asks relevant follow-up questions"
                        )
                        
                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Flexible Flow",
                            description: "Switch between conversation and forms anytime"
                        )
                        
                        FeatureRow(
                            icon: "checkmark.shield.fill",
                            title: "Data Validation",
                            description: "Automatic validation ensures accurate information"
                        )
                    }
                    .padding(.vertical)
                    
                    // Sample conversation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Example Conversation")
                            .font(.headline)
                        
                        ChatBubblePreview(
                            text: "Hi! I'm your MyPath assistant. What should I call you?",
                            isUser: false
                        )
                        
                        ChatBubblePreview(
                            text: "I'm Sarah",
                            isUser: true
                        )
                        
                        ChatBubblePreview(
                            text: "Nice to meet you, Sarah! Are you currently in school, working, or doing something else?",
                            isUser: false
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
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
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ChatBubblePreview: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }
            
            Text(text)
                .padding(12)
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(16)
            
            if !isUser { Spacer(minLength: 60) }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

