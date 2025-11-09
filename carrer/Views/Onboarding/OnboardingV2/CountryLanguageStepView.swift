import SwiftUI

struct CountryLanguageStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    let onNext: () -> Void
    let onBack: () -> Void

    // Country options
    private let countries = [
        ("US", "United States 🇺🇸"),
        ("CA", "Canada 🇨🇦")
    ]

    // Language options
    private let languages = [
        ("en", "English"),
        ("fr", "Français")
    ]

    @State private var selectedCountry: String = ""
    @State private var selectedLanguage: String = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            AppGradient.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    step: .country_lang,
                    onBack: onBack
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xxxl) {
                        VStack(alignment: .leading, spacing: Spacing.small) {
                            Text("Where are you located?")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)

                            Text("We’ll tailor salary data, resource links, and visas to match your region.")
                                .font(.system(size: 15))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 16)

                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            Text("Country")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                                .textCase(.uppercase)
                                .padding(.horizontal, 28)

                            VStack(spacing: Spacing.small) {
                                ForEach(countries, id: \.0) { code, name in
                                    countryOption(code: code, name: name)
                                }
                            }
                            .padding(.horizontal, 12)
                        }

                        VStack(alignment: .leading, spacing: Spacing.medium) {
                            Text("Language")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                                .textCase(.uppercase)
                                .padding(.horizontal, 28)

                            VStack(spacing: Spacing.small) {
                                ForEach(languages, id: \.0) { code, name in
                                    languageOption(code: code, name: name)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.bottom, 140)
                }
            }

            continueButton
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
        }
        .onAppear {
            // Initialize from draft or detect defaults
            if selectedCountry.isEmpty {
                selectedCountry = draftStore.draft.country.isEmpty ? Self.detectDefaultCountry() : draftStore.draft.country
            }
            if selectedLanguage.isEmpty {
                selectedLanguage = draftStore.draft.language.isEmpty ? Self.detectDefaultLanguage() : draftStore.draft.language
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func countryOption(code: String, name: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCountry = code
                draftStore.draft.country = code
            }
        }) {
            SelectionCard(isSelected: selectedCountry == code) { isSelected in
                HStack(spacing: Spacing.large) {
                    Text(name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppColors.textPrimary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func languageOption(code: String, name: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedLanguage = code
                draftStore.draft.language = code
            }
        }) {
            SelectionCard(isSelected: selectedLanguage == code) { isSelected in
                HStack(spacing: Spacing.large) {
                    Text(name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppColors.textPrimary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func handleContinue() {
        // Persist selections
        draftStore.draft.country = selectedCountry
        draftStore.draft.language = selectedLanguage
        onNext()
    }

    private var continueButton: some View {
        Button(action: handleContinue) {
            HStack {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, Spacing.xl)
            .background(AppGradient.hero)
            .cornerRadius(AppCornerRadius.pill)
            .shadow(color: AppShadow.subtle, radius: 16, x: 0, y: 12)
        }
        .buttonStyle(.plain)
        .disabled(selectedCountry.isEmpty || selectedLanguage.isEmpty)
        .opacity(selectedCountry.isEmpty || selectedLanguage.isEmpty ? 0.5 : 1)
    }

    // MARK: - Helpers

    private static func detectDefaultCountry() -> String {
        let locale = Locale.current
        let regionCode = locale.region?.identifier ?? "US"
        return ["CA", "US"].contains(regionCode) ? regionCode : "US"
    }

    private static func detectDefaultLanguage() -> String {
        let locale = Locale.current
        let langCode = locale.language.languageCode?.identifier ?? "en"
        return langCode == "fr" ? "fr" : "en"
    }
}

// MARK: - Onboarding Header (Reusable)

struct OnboardingHeaderView: View {
    let step: OnbStep
    let onBack: () -> Void

    var body: some View {
        HStack {
            // Back button
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 17))
                }
                .foregroundColor(.accentColor)
            }

            Spacer()

            // Progress indicator
            Text("Step \(step.stepNumber) of \(step.totalSteps)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

#Preview {
    CountryLanguageStepView(
        draftStore: OnbDraftStore(),
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") }
    )
}
