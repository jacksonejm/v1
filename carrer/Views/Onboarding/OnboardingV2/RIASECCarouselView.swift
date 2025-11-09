import SwiftUI

struct RIASECCarouselView: View {

    @ObservedObject var draftStore: OnbDraftStore
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var allItems: [RIASECItem] = []
    @State private var currentPageIndex: Int = 0
    @State private var focusedItemId: String? = nil

    // Page configuration: [dimensions per page]
    private let pageConfig: [[String]] = [
        ["R", "I"],  // Page 0: Realistic + Investigative
        ["A", "S"],  // Page 1: Artistic + Social
        ["E", "C"]   // Page 2: Enterprising + Conventional
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                step: currentStep,
                onBack: handleBack
            )

            // Content
            VStack(spacing: 0) {
                // Title & Instructions
                titleSection

                // Carousel
                TabView(selection: $currentPageIndex) {
                    ForEach(0..<3, id: \.self) { pageIndex in
                        riasecPage(pageIndex: pageIndex)
                            .tag(pageIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPageIndex) { _, newValue in
                    draftStore.draft.riasecPageIndex = newValue
                }

                // Page Indicator Dots
                pageIndicator
                    .padding(.vertical, 16)
            }

            Spacer()

            // Navigation Buttons
            navigationButtons
        }
        .background(Color(.systemBackground))
        .onAppear(perform: loadItems)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About You")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Rate how much you agree with each statement")
                .font(.system(size: 15))
                .foregroundColor(.secondary)

            // Dimension badges for current page
            HStack(spacing: 8) {
                ForEach(dimensionsForCurrentPage, id: \.self) { dim in
                    if let dimension = RIASECDimensionV2(rawValue: dim) {
                        dimensionBadge(dimension)
                    }
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    private func dimensionBadge(_ dimension: RIASECDimensionV2) -> some View {
        Text(dimension.fullName)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.accentColor.opacity(0.15))
            )
            .foregroundColor(.accentColor)
    }

    @ViewBuilder
    private func riasecPage(pageIndex: Int) -> some View {
        let items = itemsForPage(pageIndex)

        ScrollView {
            VStack(spacing: 16) {
                ForEach(items) { item in
                    riasecItemCard(item: item)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func riasecItemCard(item: RIASECItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Statement text
            Text(item.text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Likert scale
            likertScale(for: item)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func likertScale(for item: RIASECItem) -> some View {
        let selectedValue = draftStore.draft.answers[item.id]

        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { value in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            draftStore.updateRIASECAnswer(itemId: item.id, value: value)
                        }
                    }) {
                        Circle()
                            .fill(selectedValue == value ? Color.accentColor : Color(.tertiarySystemFill))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("\(value)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(selectedValue == value ? .white : .secondary)
                            )
                    }
                }
            }

            // Labels
            HStack {
                Text("Strongly\nDisagree")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Neutral")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Text("Strongly\nAgree")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    @ViewBuilder
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(currentPageIndex == index ? Color.accentColor : Color(.tertiarySystemFill))
                    .frame(width: 8, height: 8)
            }
        }
    }

    @ViewBuilder
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            // Progress text
            if isCurrentPageComplete {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Page \(currentPageIndex + 1) complete")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
            } else {
                let answered = answeredCountForCurrentPage
                let total = itemsForPage(currentPageIndex).count
                Text("\(answered) of \(total) answered")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }

            // Next/Continue button
            Button(action: handleNext) {
                Text(isLastPage ? "Continue" : "Next Page")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(isCurrentPageComplete ? Color.accentColor : Color(.systemGray4))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!isCurrentPageComplete)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Computed Properties

    private var currentStep: OnbStep {
        switch currentPageIndex {
        case 0: return .riasec_p1
        case 1: return .riasec_p2
        case 2: return .riasec_p3
        default: return .riasec_p1
        }
    }

    private var dimensionsForCurrentPage: [String] {
        guard currentPageIndex < pageConfig.count else { return [] }
        return pageConfig[currentPageIndex]
    }

    private var isCurrentPageComplete: Bool {
        draftStore.draft.riasecPageComplete(for: currentPageIndex, items: allItems)
    }

    private var answeredCountForCurrentPage: Int {
        let items = itemsForPage(currentPageIndex)
        return items.filter { draftStore.draft.answers[$0.id] != nil }.count
    }

    private var isLastPage: Bool {
        currentPageIndex == 2
    }

    // MARK: - Actions

    private func handleBack() {
        if currentPageIndex > 0 {
            withAnimation {
                currentPageIndex -= 1
            }
        } else {
            onBack()
        }
    }

    private func handleNext() {
        guard isCurrentPageComplete else { return }

        if isLastPage {
            // Move to next onboarding step
            onNext()
        } else {
            // Go to next page in carousel
            withAnimation {
                currentPageIndex += 1
            }
        }
    }

    // MARK: - Data Helpers

    private func loadItems() {
        guard let url = Bundle.main.url(forResource: "RIASECItemBank", withExtension: "json") else {
            print("❌ RIASECItemBank.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode([RIASECItem].self, from: data)
            allItems = items

            // Restore page index from draft
            currentPageIndex = draftStore.draft.riasecPageIndex

            #if DEBUG
            print("✅ Loaded \(items.count) RIASEC items")
            #endif
        } catch {
            print("❌ Failed to load RIASEC items: \(error)")
        }
    }

    private func itemsForPage(_ page: Int) -> [RIASECItem] {
        guard page < pageConfig.count else { return [] }
        let dims = pageConfig[page]
        return allItems.filter { dims.contains($0.dim) }
    }
}

// MARK: - Preview

#Preview {
    RIASECCarouselView(
        draftStore: OnbDraftStore(),
        onNext: { print("Next tapped") },
        onBack: { print("Back tapped") }
    )
}
