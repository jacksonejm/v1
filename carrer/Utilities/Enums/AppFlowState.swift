import Foundation

enum AppFlowState: Hashable {
    case initial
    case login
    case dashboard
    case onboarding(step: OnboardingStep)
    case onboardingHelp(step: OnboardingStep) // New state to track when help is being shown
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .initial:
            hasher.combine(0)
        case .login:
            hasher.combine(1)
        case .dashboard:
            hasher.combine(2)
        case .onboarding(let step):
            hasher.combine(3)
            hasher.combine(step)
        case .onboardingHelp(let step):
            hasher.combine(4)
            hasher.combine(step)
        }
    }
    
    static func == (lhs: AppFlowState, rhs: AppFlowState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.login, .login):
            return true
        case (.dashboard, .dashboard):
            return true
        case (.onboarding(let step1), .onboarding(let step2)):
            return step1 == step2
        case (.onboardingHelp(let step1), .onboardingHelp(let step2)):
            return step1 == step2
        default:
            return false
        }
    }
}