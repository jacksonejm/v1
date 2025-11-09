import SwiftUI

private struct OnboardingStoreKey: EnvironmentKey {
    static let defaultValue: OnboardingDataStore = SecureOnboardingStore()
}

extension EnvironmentValues {
    var onboardingStore: OnboardingDataStore {
        get { self[OnboardingStoreKey.self] }
        set { self[OnboardingStoreKey.self] = newValue }
    }
}