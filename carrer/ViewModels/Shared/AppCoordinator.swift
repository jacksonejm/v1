import SwiftUI
import Combine

/// Manages app-wide navigation and state flow
class AppCoordinator: ObservableObject {
    // Navigation paths
    @Published var mainNavigationPath = NavigationPath()
    @Published var currentTab: AppTab = .home
    
    // Global app state
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var activeOnboardingStep: OnboardingStep?
    
    // Dependencies
    private let persistenceController = PersistenceController.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init() {
        setupObservers()
        checkInitialState()
    }
    
    private func setupObservers() {
        // Listen for auth state changes, onboarding completion, etc.
    }
    
    private func checkInitialState() {
        // Determine if user is logged in and has completed onboarding
    }
    
    // MARK: - Navigation
    
    func navigateTo(_ destination: any Hashable) {
        mainNavigationPath.append(destination)
    }
    
    func navigateBack() {
        if !mainNavigationPath.isEmpty {
            mainNavigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        mainNavigationPath = NavigationPath()
    }
    
    // MARK: - App State Management
    
    func signOut() {
        // Handle sign out logic
        isAuthenticated = false
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        activeOnboardingStep = nil
    }
    
    // MARK: - App Tabs
    
    enum AppTab: String, CaseIterable {
        case home
        case explore
        case aiCoach
        case profile
    }
}