import SwiftUI

struct SubjectsActivitiesStepView: View {

    @ObservedObject var draftStore: OnbDraftStore
    let onNext: () -> Void
    let onBack: () -> Void

    // Available subjects
    private let subjects = [
        "Math", "Science", "English", "History", "Arts",
        "Music", "Physical Education", "Languages", "Technology",
        "Business", "Psychology", "Social Studies"
    ]

    // Available activities
    private let activities = [
        "Coding", "Sports", "Drawing", "Writing", "Reading",
        "Building Things", "Playing Music", "Video Games",
        "Volunteering", "Debating", "Performing", "Experimenting"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                step: .subj_acts,
                onBack: onBack
            )

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Title
                    titleSection

                    // Subjects Section
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(
                            title: "Subjects You Enjoy",
                            icon: "book.fill",
                            count: draftStore.draft.subjects.count
                        )

                        FlowLayout(spacing: 8) {
                            ForEach(subjects, id: \.self) { subject in
                                selectionChip(
                                    text: subject,
                                    isSelected: draftStore.draft.subjects.contains(subject),
                                    action: { draftStore.toggleSubject(subject) }
                                )
                            }
                        }
                    }

                    // Activities Section
                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(
                            title: "Activities You Like",
                            icon: "figure.run",
                            count: draftStore.draft.activities.count
                        )

                        FlowLayout(spacing: 8) {
                            ForEach(activities, id: \.self) { activity in
                                selectionChip(
                                    text: activity,
                                    isSelected: draftStore.draft.activities.contains(activity),
                                    action: { draftStore.toggleActivity(activity) }
                                )
                            }
                        }
                    }

                    // Help text
                    Text("Don't worry if you're not sure - you can always change these later!")
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
            Text("Your Interests")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Select subjects and activities you enjoy (optional)")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func sectionHeader(title: String, icon: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.accentColor)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            if count > 0 {
                Text("(\(count))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func selectionChip(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                action()
            }
        }) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }

                Text(text)
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        VStack(spacing: 12) {
            // Selection summary
            let total = draftStore.draft.subjects.count + draftStore.draft.activities.count
            if total > 0 {
                Text("\(total) item\(total == 1 ? "" : "s") selected")
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

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    // Move to next line
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    SubjectsActivitiesStepView(
        draftStore: OnbDraftStore(),
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") }
    )
}
