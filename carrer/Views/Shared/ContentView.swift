import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var isSplashScreenVisible = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main App Flow
                Group {
                    switch viewModel.appFlowState {
                    case .initial:
                        WelcomeView(viewModel: viewModel)
                    case .onboarding(let step):
                        OnboardingView(viewModel: viewModel, step: step)
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
            if case .dashboard = newState {
                DispatchQueue.main.async {
                    // Additional setup if transitioning to dashboard
                }
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