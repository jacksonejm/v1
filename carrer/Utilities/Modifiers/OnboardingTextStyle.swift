import SwiftUI

struct OnboardingTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.top, 10)
    }
}

// Extension for easier usage
extension View {
    func onboardingTextStyle() -> some View {
        self.modifier(OnboardingTextStyle())
    }
}