import SwiftUI

struct GenerateStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    @ObservedObject var appViewModel: AppViewModel
    let onComplete: () -> Void

    @State private var currentMessageIndex = 0
    @State private var isGenerating = true
    @State private var hasError = false

    private let progressMessages = [
        "Analyzing your personality profile...",
        "Matching with career database...",
        "Calculating compatibility scores...",
        "Finding your best matches..."
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if hasError {
                errorView
            } else {
                generatingView
            }

            Spacer()
        }
        .background(Color(.systemBackground))
        .onAppear(perform: startGeneration)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var generatingView: some View {
        VStack(spacing: 24) {
            // Loading animation
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentColor)

            // Messages
            VStack(spacing: 12) {
                Text("Generating Recommendations")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                if currentMessageIndex < progressMessages.count {
                    Text(progressMessages[currentMessageIndex])
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            VStack(spacing: 12) {
                Text("Something Went Wrong")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                Text("We couldn't generate your recommendations. Please check your connection and try again.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: startGeneration) {
                Text("Try Again")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 200, height: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Actions

    private func startGeneration() {
        hasError = false
        isGenerating = true
        currentMessageIndex = 0

        // Animate progress messages
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            if currentMessageIndex < progressMessages.count - 1 {
                withAnimation {
                    currentMessageIndex += 1
                }
            } else {
                timer.invalidate()
            }
        }

        // Perform actual generation
        Task {
            do {
                try await generateRecommendations()

                // Wait a bit for better UX
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5s

                await MainActor.run {
                    onComplete()
                }
            } catch {
                print("❌ Generation failed: \(error)")
                await MainActor.run {
                    hasError = true
                    isGenerating = false
                }
            }
        }
    }

    private func generateRecommendations() async throws {
        // Convert draft to AppViewModel userData format
        let draft = draftStore.draft

        // Load RIASEC items to calculate means
        guard let url = Bundle.main.url(forResource: "RIASECItemBank", withExtension: "json") else {
            throw GenerationError.missingData
        }

        let data = try Data(contentsOf: url)
        let riasecItems = try JSONDecoder().decode([RIASECItem].self, from: data)
        let riasecMeans = draft.riasecMeans(from: riasecItems)

        // Update AppViewModel userData
        await MainActor.run {
            // Set country
            if let country = UserCountry(rawValue: draft.country) {
                appViewModel.userCountry = country
            }

            // Store RIASEC means
            for (dim, mean) in riasecMeans {
                appViewModel.userData[UserDataKey.riasec(dim)] = mean
            }

            // Store work values
            for (valueId, rating) in draft.values {
                appViewModel.userData[UserDataKey.workValue(valueId)] = rating
            }

            // Store subjects (convert to skills for matching)
            appViewModel.userData[.subjects] = draft.subjects

            // Store activities
            appViewModel.userData[.activities] = draft.activities

            // Store career interests
            appViewModel.userData[.careerInterests] = draft.interests
        }

        // Generate career suggestions using existing logic
        try await appViewModel.generateCareerSuggestions()
    }

    enum GenerationError: Error {
        case missingData
    }
}

// MARK: - Preview

#Preview {
    GenerateStepView(
        draftStore: OnbDraftStore(),
        appViewModel: AppViewModel(),
        onComplete: { print("Generation complete") }
    )
}
