import SwiftUI
import Combine

struct OnboardingModeSelectionView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var onboardingStore: OnboardingStore
    @State private var selectedMode: OnboardingMode?
    @State private var animateIn = false
    
    // Error handling states
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Loading state
    @State private var isNavigating = false
    
    // Network monitoring
    @State private var isNetworkAvailable = true
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                // Header Section
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
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
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                // Mode selection cards
                VStack(spacing: 16) {
                    // AI Conversation option (Primary)
                    ModeSelectionCard(
                        mode: .conversational,
                        isSelected: selectedMode == .conversational,
                        isPrimary: true,
                        animateIn: animateIn,
                        isNetworkAvailable: isNetworkAvailable
                    ) {
                        selectMode(.conversational)
                    }
                    .offset(x: animateIn ? 0 : -50)
                    
                    // Traditional Forms option (Secondary)
                    ModeSelectionCard(
                        mode: .traditional,
                        isSelected: selectedMode == .traditional,
                        isPrimary: false,
                        animateIn: animateIn,
                        isNetworkAvailable: true // Always available
                    ) {
                        selectMode(.traditional)
                    }
                    .offset(x: animateIn ? 0 : 50)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    if let selected = selectedMode {
                        startOnboarding(with: selected)
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(selectedMode != nil ? "Continue with \(selectedMode!.displayName)" : "Continue")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedMode != nil ? Color.blue : Color.gray.opacity(0.6))
                    .cornerRadius(12)
                }
                .disabled(selectedMode == nil)
                .opacity(animateIn ? 1 : 0)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { navigateBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            // Check network status
            checkNetworkAvailability()
            
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
        .onReceive(NetworkMonitor.shared.$isConnected) { isConnected in
            isNetworkAvailable = isConnected
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isNavigating {
                LoadingOverlay()
            }
        }
    }
    
    private func navigateBack() {
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
        // Validate mode selection
        guard validateModeSelection(mode) else { return }
        
        // Show loading state
        isNavigating = true
        
        // Save mode selection
        UserDefaults.standard.set(mode.rawValue, forKey: "selectedOnboardingMode")
        
        // Navigate immediately to avoid concurrency issues
        switch mode {
        case .conversational:
            viewModel.navigateTo(.conversationalOnboarding)
        case .traditional:
            viewModel.navigateTo(.onboarding(step: .howDidYouHearAboutUs))
        case .unselected:
            break
        }
        
        // Reset loading state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isNavigating = false
        }
    }
    
    private func validateModeSelection(_ mode: OnboardingMode) -> Bool {
        // Check network availability for AI mode
        if mode == .conversational && !isNetworkAvailable {
            showError = true
            errorMessage = "AI conversation mode requires an internet connection. Please check your connection and try again."
            return false
        }
        
        return true
    }
    
    private func checkNetworkAvailability() {
        // Check if NetworkMonitor is available
        isNetworkAvailable = NetworkMonitor.shared.isConnected
    }
}

// MARK: - Mode Selection Card

struct ModeSelectionCard: View {
    let mode: OnboardingMode
    let isSelected: Bool
    let isPrimary: Bool
    let animateIn: Bool
    let isNetworkAvailable: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: mode.iconName)
                    .font(.system(size: isPrimary ? 48 : 40))
                    .foregroundColor(iconColor)
                
                // Title
                Text(mode.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                // Description
                Text(mode.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Badges
                HStack(spacing: 8) {
                    // Network status for AI mode
                    if mode == .conversational && !isNetworkAvailable {
                        HStack(spacing: 4) {
                            Image(systemName: "wifi.slash")
                                .font(.caption2)
                            Text("OFFLINE")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                    
                    // Primary badge
                    if isPrimary && isNetworkAvailable {
                        Text("RECOMMENDED")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
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
        .disabled(mode == .conversational && !isNetworkAvailable)
        .opacity(mode == .conversational && !isNetworkAvailable ? 0.7 : 1.0)
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

// MARK: - Supporting Views

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Loading Overlay
//
//struct LoadingOverlay: View {
//    @State private var isAnimating = false
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4)
//                .ignoresSafeArea()
//            
//            VStack(spacing: 20) {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    .scaleEffect(1.5)
//                
//                Text("Starting...")
//                    .font(.headline)
//                    .foregroundColor(.white)
//            }
//            .padding(40)
//            .background(Color.black.opacity(0.7))
//            .cornerRadius(20)
//            .scaleEffect(isAnimating ? 1.05 : 0.95)
//            .onAppear {
//                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
//                    isAnimating = true
//                }
//            }
//        }
//    }
//}
