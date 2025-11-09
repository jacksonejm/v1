import SwiftUI

struct WelcomeStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero Section
            VStack(spacing: 24) {
                // Hero Image/Icon
                Image(systemName: "map.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 8)

                // Headline
                Text("Discover Your Path")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)

                // Subheadline
                Text("We'll help you find careers that match your interests, skills, and values")
                    .font(.system(size: 17, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Get Started Button
            Button(action: onNext) {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

#Preview {
    WelcomeStepView(
        draftStore: OnbDraftStore(),
        onNext: { print("Next tapped") }
    )
}
