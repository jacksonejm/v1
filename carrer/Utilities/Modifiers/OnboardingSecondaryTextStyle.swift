import SwiftUI

struct OnboardingSecondaryTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20))
            .foregroundColor(.primary)
            .padding(.top, 20)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

// Extension for easier usage
extension View {
    func onboardingSecondaryTextStyle() -> some View {
        self.modifier(OnboardingSecondaryTextStyle())
    }
}