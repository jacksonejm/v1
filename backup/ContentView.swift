import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @EnvironmentObject var onboardingStore: OnboardingStore
    @State private var isSplashScreenVisible = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main App Flow
                Group {
                    switch viewModel.appFlowState {
                    case .initial:
                        // Use the standard welcome view with no debugging buttons
                        WelcomeView(viewModel: viewModel)
                    case .onboarding(let step):
                        // Use OnboardingRouter for the flow
                        OnboardingRouter()
                            .onAppear {
                                // Make sure the OnboardingStore is showing the correct step
                                if let stepIndex = onboardingStore.stepFieldSpec.order.firstIndex(of: step.toStepID()) {
                                    onboardingStore.currentStepIndex = stepIndex
                                }
                            }
                    case .onboardingHelp(let step):
                        // Handle the help state - either show help directly or let OnboardingView handle it
                        OnboardingView(viewModel: viewModel, step: step)
                    case .login:
                        LoginView(viewModel: viewModel)
                    case .dashboard:
                        MainAppView(viewModel: viewModel)
                    }
                }
                .opacity(isSplashScreenVisible ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: isSplashScreenVisible)
                
                // Splash Screen
                if isSplashScreenVisible {
                    SplashScreen(isPresented: $isSplashScreenVisible)
                        .zIndex(1)
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }
            }
        }
        .onChange(of: viewModel.appFlowState) { newState in
            // Handle different state transitions
            switch newState {
            case .onboarding(let step):
                // When transitioning to onboarding, sync the OnboardingStore
                if let stepIndex = onboardingStore.stepFieldSpec.order.firstIndex(of: step.toStepID()) {
                    onboardingStore.currentStepIndex = stepIndex
                }
            case .dashboard:
                DispatchQueue.main.async {
                    // Additional setup if transitioning to dashboard
                }
            default:
                break
            }
        }
        .onChange(of: onboardingStore.currentStep) { newStep in
            // Keep AppViewModel in sync with OnboardingStore
            if case .onboarding = viewModel.appFlowState {
                viewModel.appFlowState = .onboarding(step: newStep)
            }
        }
        .onAppear {
            // Automatically dismiss Splash Screen after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isSplashScreenVisible = false
                }
            }
        }
    }
}