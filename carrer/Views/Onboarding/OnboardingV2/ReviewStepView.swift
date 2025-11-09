import SwiftUI

struct ReviewStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    let onNext: () -> Void
    let onBack: () -> Void
    let onEditStep: (OnbStep) -> Void

    @State private var riasecItems: [RIASECItem] = []
    @State private var valuesData: WorkValuesData?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                step: .review,
                onBack: onBack
            )

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    titleSection

                    // Algorithm Weight Explanation
                    algorithmWeightCard

                    // RIASEC Summary
                    riasecSummaryCard

                    // Work Values Summary
                    workValuesSummaryCard

                    // Subjects & Activities
                    if !draftStore.draft.subjects.isEmpty || !draftStore.draft.activities.isEmpty {
                        subjectsActivitiesSummaryCard
                    }

                    // Career Interests
                    if !draftStore.draft.interests.isEmpty {
                        careerInterestsSummaryCard
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 100)
            }

            Spacer()

            // Generate Button
            generateButton
        }
        .background(Color(.systemBackground))
        .onAppear(perform: loadData)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review Your Profile")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("We'll use these to find your best career matches")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var algorithmWeightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.accentColor)
                Text("How We Match You")
                    .font(.system(size: 17, weight: .semibold))
            }

            VStack(spacing: 8) {
                weightRow(label: "Personality (RIASEC)", weight: "60%", color: .blue)
                weightRow(label: "Work Values", weight: "20%", color: .green)
                weightRow(label: "Skills & Subjects", weight: "10%", color: .orange)
                weightRow(label: "Career Interest Boost", weight: "10%", color: .purple)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func weightRow(label: String, weight: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer()

            Text(weight)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var riasecSummaryCard: some View {
        summaryCard(
            title: "Your Personality Type",
            icon: "person.fill",
            editStep: .riasec_p1
        ) {
            let topCodes = draftStore.draft.topRIASEC(from: riasecItems)
            if !topCodes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(topCodes, id: \.self) { code in
                            if let dimension = RIASECDimensionV2(rawValue: code) {
                                Text(dimension.fullName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.accentColor.opacity(0.15)))
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }

                    Text("These traits shape your ideal work environment")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Not completed")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var workValuesSummaryCard: some View {
        summaryCard(
            title: "Your Work Values",
            icon: "star.fill",
            editStep: .values
        ) {
            let topValues = draftStore.draft.topValues()
            if !topValues.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(topValues, id: \.key) { item in
                        HStack {
                            Text("•")
                                .foregroundColor(.accentColor)
                            Text(valueTitle(for: item.key))
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            Spacer()
                            starRating(count: item.value)
                        }
                    }
                }
            } else {
                Text("Not completed")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var subjectsActivitiesSummaryCard: some View {
        summaryCard(
            title: "Subjects & Activities",
            icon: "lightbulb.fill",
            editStep: .subj_acts
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if !draftStore.draft.subjects.isEmpty {
                    chipList(items: draftStore.draft.subjects)
                }
                if !draftStore.draft.activities.isEmpty {
                    chipList(items: draftStore.draft.activities)
                }
            }
        }
    }

    @ViewBuilder
    private var careerInterestsSummaryCard: some View {
        summaryCard(
            title: "Career Fields",
            icon: "briefcase.fill",
            editStep: .interests
        ) {
            chipList(items: draftStore.draft.interests)
        }
    }

    @ViewBuilder
    private func summaryCard<Content: View>(
        title: String,
        icon: String,
        editStep: OnbStep,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)

                Text(title)
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button(action: {
                    onEditStep(editStep)
                }) {
                    Text("Edit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                }
            }

            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func chipList(items: [String]) -> some View {
        FlowLayout(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(.tertiarySystemFill)))
                    .foregroundColor(.primary)
            }
        }
    }

    @ViewBuilder
    private func starRating(count: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<count, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
            }
        }
    }

    @ViewBuilder
    private var generateButton: some View {
        Button(action: onNext) {
            Text("Generate My Recommendations")
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

    // MARK: - Helpers

    private func loadData() {
        // Load RIASEC items
        if let url = Bundle.main.url(forResource: "RIASECItemBank", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                riasecItems = try JSONDecoder().decode([RIASECItem].self, from: data)
            } catch {
                print("❌ Failed to load RIASEC items: \(error)")
            }
        }

        // Load work values
        if let url = Bundle.main.url(forResource: "WorkValuesData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                valuesData = try JSONDecoder().decode(WorkValuesData.self, from: data)
            } catch {
                print("❌ Failed to load work values: \(error)")
            }
        }
    }

    private func valueTitle(for id: String) -> String {
        guard let data = valuesData else { return id }
        let allValues = data.primary + data.additional
        if let value = allValues.first(where: { $0.id == id }) {
            return value.title
        }
        return id
    }
}

// MARK: - Preview

#Preview {
    ReviewStepView(
        draftStore: OnbDraftStore(),
        onNext: { print("Generate tapped") },
        onBack: { print("Back tapped") },
        onEditStep: { step in print("Edit \(step)") }
    )
}
