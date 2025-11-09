import SwiftUI

struct WorkValuesStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var valuesData: WorkValuesData?
    @State private var showAdditional: Bool = false

    private let minimumRequired = 6

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                step: .values,
                onBack: onBack
            )

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    titleSection

                    // Primary Values
                    if let primary = valuesData?.primary {
                        VStack(spacing: 12) {
                            ForEach(primary) { value in
                                valueCard(value: value)
                            }
                        }
                    }

                    // Show More Button
                    if !showAdditional {
                        showMoreButton
                    }

                    // Additional Values
                    if showAdditional, let additional = valuesData?.additional {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Additional Values")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)

                            VStack(spacing: 12) {
                                ForEach(additional) { value in
                                    valueCard(value: value)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 120)
            }

            Spacer()

            // Continue Button
            continueButton
        }
        .background(Color(.systemBackground))
        .onAppear(perform: loadValues)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What Matters to You?")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Rate how important each work value is to you")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func valueCard(value: WorkValueItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title & Description
            VStack(alignment: .leading, spacing: 4) {
                Text(value.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                Text(value.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            // Star Rating
            starRating(for: value)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func starRating(for value: WorkValueItem) -> some View {
        let selectedRating = draftStore.draft.values[value.id] ?? 0

        HStack(spacing: 12) {
            ForEach(1...5, id: \.self) { rating in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        draftStore.updateWorkValue(valueId: value.id, rating: rating)
                    }
                }) {
                    Image(systemName: rating <= selectedRating ? "star.fill" : "star")
                        .font(.system(size: 24))
                        .foregroundColor(rating <= selectedRating ? .yellow : Color(.systemGray4))
                }
            }

            Spacer()

            // Rating label
            if selectedRating > 0 {
                Text(ratingLabel(for: selectedRating))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var showMoreButton: some View {
        Button(action: {
            withAnimation {
                showAdditional = true
            }
        }) {
            HStack {
                Text("Show More Values")
                    .font(.system(size: 16, weight: .semibold))
                Image(systemName: "chevron.down")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(.accentColor)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.1))
            )
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        VStack(spacing: 12) {
            // Progress indicator
            let ratedCount = draftStore.draft.values.count
            let totalAvailable = (valuesData?.primary.count ?? 0) + (valuesData?.additional.count ?? 0)

            if ratedCount >= minimumRequired {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(ratedCount) values rated")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
            } else {
                Text("\(ratedCount) of \(minimumRequired) required values rated")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            Button(action: onNext) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canContinue ? Color.accentColor : Color(.systemGray4))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!canContinue)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Computed Properties

    private var canContinue: Bool {
        draftStore.draft.valuesComplete()
    }

    // MARK: - Helpers

    private func loadValues() {
        guard let url = Bundle.main.url(forResource: "WorkValuesData", withExtension: "json") else {
            print("❌ WorkValuesData.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            valuesData = try JSONDecoder().decode(WorkValuesData.self, from: data)

            #if DEBUG
            print("✅ Loaded work values data")
            #endif
        } catch {
            print("❌ Failed to load work values: \(error)")
        }
    }

    private func ratingLabel(for rating: Int) -> String {
        switch rating {
        case 1: return "Not Important"
        case 2: return "Slightly Important"
        case 3: return "Moderately Important"
        case 4: return "Very Important"
        case 5: return "Extremely Important"
        default: return ""
        }
    }
}

// MARK: - Preview

#Preview {
    WorkValuesStepView(
        draftStore: OnbDraftStore(),
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") }
    )
}
