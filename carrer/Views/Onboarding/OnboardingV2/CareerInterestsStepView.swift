import SwiftUI

struct CareerInterestsStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    let onNext: () -> Void
    let onBack: () -> Void

    // Career interest categories (matching existing app categories)
    private let careerInterests = [
        ("STEM", "💻", "Science, Technology, Engineering, Math"),
        ("Arts & Design", "🎨", "Creative and artistic careers"),
        ("Business & Finance", "💼", "Business, management, and finance"),
        ("Healthcare", "🏥", "Medical and health services"),
        ("Education", "📚", "Teaching and educational roles"),
        ("Social Services", "🤝", "Helping and community services"),
        ("Trades & Skilled Labor", "🔧", "Hands-on technical work"),
        ("Legal & Public Service", "⚖️", "Law, government, and policy"),
        ("Media & Communication", "📱", "Journalism, marketing, and media"),
        ("Hospitality & Service", "🍽️", "Customer service and hospitality")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                step: .interests,
                onBack: onBack
            )

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    titleSection

                    // Career Interest Cards
                    VStack(spacing: 12) {
                        ForEach(careerInterests, id: \.0) { interest in
                            careerInterestCard(
                                title: interest.0,
                                icon: interest.1,
                                description: interest.2,
                                isSelected: draftStore.draft.interests.contains(interest.0)
                            )
                        }
                    }

                    // Help text
                    Text("These help us prioritize certain career fields for you (optional)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 100)
            }

            Spacer()

            // Continue Button
            continueButton
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Subviews

    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Career Fields")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Which career areas interest you?")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func careerInterestCard(title: String, icon: String, description: String, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                draftStore.toggleInterest(title)
            }
        }) {
            HStack(spacing: 12) {
                // Icon
                Text(icon)
                    .font(.system(size: 32))

                // Title & Description
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        VStack(spacing: 12) {
            // Selection summary
            let count = draftStore.draft.interests.count
            if count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text("\(count) field\(count == 1 ? "" : "s") selected • 10% boost each")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
            } else {
                Text("Optional - skip if unsure")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            Button(action: onNext) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

// MARK: - Preview

#Preview {
    CareerInterestsStepView(
        draftStore: OnbDraftStore(),
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") }
    )
}
