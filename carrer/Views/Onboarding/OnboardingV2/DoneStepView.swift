import SwiftUI

struct DoneStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    @ObservedObject var appViewModel: AppViewModel
    let onViewResults: () -> Void

    private var recommendationCount: Int {
        appViewModel.careerTracks.count
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Success content
            VStack(spacing: 32) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }

                // Messages
                VStack(spacing: 12) {
                    Text("You're All Set!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))

                    if recommendationCount > 0 {
                        Text("We found \(recommendationCount) career matches tailored to your profile")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    } else {
                        Text("Your personalized career recommendations are ready")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }

                // View Results Button
                Button(action: handleViewResults) {
                    Text("View My Recommendations")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }

            Spacer()
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Actions

    private func handleViewResults() {
        // Mark onboarding as completed
        draftStore.markCompleted()

        // Clear the draft
        draftStore.clear()

        // Notify completion
        onViewResults()
    }
}

// MARK: - Preview

#Preview {
    DoneStepView(
        draftStore: OnbDraftStore(),
        appViewModel: AppViewModel(),
        onViewResults: { print("View results tapped") }
    )
}
