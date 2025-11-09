import SwiftUI

/// Main coordinator view for Onboarding v2 - streamlined 10-step flow with autosave
struct OnboardingV2View: View {

    @StateObject private var draftStore = OnbDraftStore()
    @ObservedObject var appViewModel: AppViewModel

    @Environment(\.scenePhase) private var scenePhase

    let onComplete: () -> Void

    // Current step is derived from draft store
    private var currentStep: OnbStep {
        draftStore.draft.lastStep
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            // Step content
            stepView
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .onChange(of: scenePhase) { _, newPhase in
            draftStore.handleScenePhase(newPhase)
        }
    }

    // MARK: - Step Router

    @ViewBuilder
    private var stepView: some View {
        switch currentStep {
        case .welcome:
            WelcomeStepView(
                draftStore: draftStore,
                onNext: { goToStep(.country_lang) }
            )

        case .country_lang:
            CountryLanguageStepView(
                draftStore: draftStore,
                onNext: { goToStep(.riasec_p1) },
                onBack: { goToStep(.welcome) }
            )

        case .riasec_p1, .riasec_p2, .riasec_p3:
            RIASECCarouselView(
                draftStore: draftStore,
                onNext: { goToStep(.values) },
                onBack: { goToStep(.country_lang) }
            )

        case .values:
            WorkValuesStepView(
                draftStore: draftStore,
                onNext: {
                    if validateValues() {
                        goToStep(.subj_acts)
                    }
                },
                onBack: { goToStep(.riasec_p3) }
            )

        case .subj_acts:
            SubjectsActivitiesStepView(
                draftStore: draftStore,
                onNext: { goToStep(.interests) },
                onBack: { goToStep(.values) }
            )

        case .interests:
            CareerInterestsStepView(
                draftStore: draftStore,
                onNext: { goToStep(.review) },
                onBack: { goToStep(.subj_acts) }
            )

        case .review:
            ReviewStepView(
                draftStore: draftStore,
                onNext: { goToStep(.generate) },
                onBack: { goToStep(.interests) },
                onEditStep: { step in
                    goToStep(step)
                }
            )

        case .generate:
            GenerateStepView(
                draftStore: draftStore,
                appViewModel: appViewModel,
                onComplete: { goToStep(.done) }
            )

        case .done:
            DoneStepView(
                draftStore: draftStore,
                appViewModel: appViewModel,
                onViewResults: handleCompletion
            )
        }
    }

    // MARK: - Navigation

    private func goToStep(_ step: OnbStep) {
        withAnimation(.easeInOut(duration: 0.3)) {
            draftStore.goToStep(step)
        }
    }

    private func handleCompletion() {
        // Mark onboarding as complete in AppViewModel
        appViewModel.userData[.hasCompletedOnboarding] = true

        // Call completion handler
        onComplete()
    }

    // MARK: - Validation

    private func validateValues() -> Bool {
        guard draftStore.draft.valuesComplete() else {
            // Could show alert here if needed
            return false
        }
        return true
    }
}

// MARK: - Preview

#Preview {
    OnboardingV2View(
        appViewModel: AppViewModel(),
        onComplete: { print("Onboarding complete") }
    )
}
