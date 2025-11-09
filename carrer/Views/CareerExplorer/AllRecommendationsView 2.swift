import SwiftUI

/// Full-screen view showing all career recommendations with filterable career interests
/// Recipe D v4.0 - Allows users to toggle career interest boosts and see updated recommendations
struct AllRecommendationsView: View {
    @ObservedObject var viewModel: AppViewModel
    @StateObject private var tracksViewModel: CareerTracksViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isRefreshing = false
    @State private var showBoostInfo = false
    @State private var activeInterests: Set<String> = []
    @State private var previousCareers: [CareerTrack] = []
    @State private var matchDiffs: [CareerMatchDiff] = []
    @State private var showMatchDiffs = false
    @State private var smartSuggestions: [SmartSuggestion] = []
    @State private var showShareSheet = false
    @State private var shareText = ""
    @State private var topMatchIds: Set<UUID> = []

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        self._tracksViewModel = StateObject(wrappedValue: CareerTracksViewModel(appViewModel: viewModel))
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Filter chips section
                    if hasCareerInterests {
                        filterChipsSection
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }

                    // Match diff banner
                    if !matchDiffs.isEmpty {
                        matchDiffBanner
                            .padding(.horizontal)
                    }

                    // Smart suggestions
                    if !smartSuggestions.isEmpty {
                        smartSuggestionsSection
                            .padding(.horizontal)
                    }

                    // Info banner about filtering
                    if hasCareerInterests {
                        infoBanner
                            .padding(.horizontal)
                    }

                    // Career recommendations list
                    careersList
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }

            // Loading overlay (best practice: show old content with overlay)
            if isRefreshing {
                loadingOverlay
            }
        }
        .navigationTitle("All Recommendations")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        generateAndShareComparison()
                    }) {
                        Label("Share Top Matches", systemImage: "square.and.arrow.up")
                    }

                    if !matchDiffs.isEmpty {
                        Button(action: {
                            generateAndShareDiffComparison()
                        }) {
                            Label("Share Match Changes", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }

                    Button(action: {
                        generateAndShareQuickSummary()
                    }) {
                        Label("Share Quick Summary", systemImage: "text.quote")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(isPresented: $showBoostInfo) {
            boostInfoSheet
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
        .onAppear {
            // Initialize active interests from stored data or original interests
            if let stored = viewModel.userData[.activeCareerInterests] as? Set<String> {
                activeInterests = stored
            } else {
                activeInterests = originalCareerInterests
            }

            // Calculate top 3 matches
            topMatchIds = MatchBucketing.identifyTopMatches(in: viewModel.careerTracks)
        }
    }

    // MARK: - Smart Suggestions Section

    private var smartSuggestionsSection: some View {
        VStack(spacing: 12) {
            ForEach(smartSuggestions.prefix(2)) { suggestion in
                smartSuggestionCard(suggestion)
            }
        }
    }

    private func smartSuggestionCard(_ suggestion: SmartSuggestion) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconForSuggestionType(suggestion.type))
                .font(.title2)
                .foregroundColor(AppColors.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(suggestion.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if let interestToToggle = suggestion.interestToToggle {
                Button(action: {
                    toggleCareerInterest(interestToToggle)
                }) {
                    Text(suggestion.actionText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }

    private func iconForSuggestionType(_ type: SmartSuggestion.SuggestionType) -> String {
        switch type {
        case .turnOffInterest: return "lightbulb.fill"
        case .turnOnInterest: return "plus.circle.fill"
        case .exploreWithout: return "sparkles"
        case .compareAll: return "arrow.left.arrow.right"
        }
    }

    // MARK: - Match Diff Banner

    private var matchDiffBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title3)
                    .foregroundColor(.blue)

                Text("Match Changes")
                    .font(.headline)

                Spacer()

                Button(action: {
                    showMatchDiffs.toggle()
                }) {
                    Text(showMatchDiffs ? "Hide" : "Show Details")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                }
            }

            let summary = CareerMatchDiffCalculator.getSummary(from: matchDiffs)

            HStack(spacing: 16) {
                if summary.increased > 0 {
                    Label("\(summary.increased) up", systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                if summary.decreased > 0 {
                    Label("\(summary.decreased) down", systemImage: "arrow.down.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                if summary.unchanged > 0 {
                    Label("\(summary.unchanged) same", systemImage: "minus.circle.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("Avg: \(summary.formattedAverageChange)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            if showMatchDiffs {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    let topIncreases = CareerMatchDiffCalculator.getTopIncreases(from: matchDiffs, limit: 3)
                    if !topIncreases.isEmpty {
                        Text("Top Increases")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)

                        ForEach(topIncreases) { diff in
                            HStack {
                                Text(diff.careerTitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(diff.previousMatch)% → \(diff.newMatch)%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(diff.formattedDifference)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    let topDecreases = CareerMatchDiffCalculator.getTopDecreases(from: matchDiffs, limit: 3)
                    if !topDecreases.isEmpty {
                        Text("Top Decreases")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .padding(.top, 4)

                        ForEach(topDecreases) { diff in
                            HStack {
                                Text(diff.careerTitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(diff.previousMatch)% → \(diff.newMatch)%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(diff.formattedDifference)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Filter Chips Section

    private var filterChipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Career Interests")
                    .font(.headline)
                    .foregroundColor(.primary)

                Button(action: {
                    AnalyticsService.shared.trackBoostInfoViewed()
                    showBoostInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Reset button
                if hasDeselectedInterests {
                    Button(action: resetToOriginalInterests) {
                        Text("Reset")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.primary)
                    }
                }
            }

            // Scrollable chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(originalCareerInterests), id: \.self) { interest in
                        CareerInterestFilterChip(
                            title: interest,
                            isSelected: activeInterests.contains(interest),
                            action: {
                                toggleCareerInterest(interest)
                            }
                        )
                    }
                }
            }

            // Status text
            if activeInterests.isEmpty {
                Text("Showing recommendations without career interest boost")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if activeInterests.count < originalCareerInterests.count {
                Text("Showing \(activeInterests.count) of \(originalCareerInterests.count) interests")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Info Banner

    private var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundColor(AppColors.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tap to toggle")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Deselecting a career interest will update recommendations without that boost")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(AppColors.primary.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Careers List

    private var careersList: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(viewModel.careerTracks.count) Careers")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                // Sort options (placeholder for future)
                Menu {
                    Button(action: {}) {
                        Label("Best Match", systemImage: "star.fill")
                    }
                    Button(action: {}) {
                        Label("Alphabetical", systemImage: "textformat")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 16)

            // Career cards
            if viewModel.careerTracks.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(sortedCareerTracks.enumerated()), id: \.element.id) { index, track in
                        let isTop = topMatchIds.contains(track.id)
                        NavigationLink(destination: ONetCareerDetailView(
                            careerTrack: track,
                            isTopMatch: isTop,
                            tracksViewModel: tracksViewModel
                        )) {
                            careerCard(track: track, rank: index + 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    private func careerCard(track: CareerTrack, rank: Int) -> some View {
        let isTopMatch = topMatchIds.contains(track.id)

        return HStack(spacing: 16) {
            // Rank number
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(track.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                // Badges: Top match → Boosted → Match tier
                HStack(spacing: 8) {
                    if isTopMatch {
                        TopMatchBadge(size: .small)
                    }

                    if isBoosted(career: track) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.caption2)
                            Text("Boosted")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.primary.opacity(0.15))
                        .cornerRadius(8)
                    }

                    // Only show match tier if NOT a top match
                    if !isTopMatch {
                        MatchPill(tier: track.matchTier, size: .small)
                    }

                    Spacer()
                }

                if let description = track.onetDescription {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Education & Salary
                HStack(spacing: 16) {
                    if !track.education.isEmpty {
                        Label(track.education, systemImage: "graduationcap.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if !track.salary.isEmpty && track.salary != "Data not available" {
                        Label(track.salary, systemImage: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Recommendations")
                .font(.title3)
                .fontWeight(.medium)

            Text("Complete your onboarding to get personalized career matches")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Updating recommendations...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
        }
    }

    // MARK: - Boost Info Sheet

    private var boostInfoSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Career Interest Boosts")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Your selected career interests give a small boost to related careers in your recommendations.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    infoPoint(
                        icon: "slider.horizontal.3",
                        title: "10% Context Weight",
                        description: "Career interests contribute 10% to your overall match score. The other 90% comes from your RIASEC scores, work values, and skills."
                    )

                    infoPoint(
                        icon: "star.fill",
                        title: "Boosted Badge",
                        description: "Careers with a star badge have received a boost from one or more of your selected interests."
                    )

                    infoPoint(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Toggle to Explore",
                        description: "Turn off interests to see how recommendations change. This helps you discover careers you might not have considered."
                    )
                }
                .padding(.top, 8)

                Spacer()

                Button(action: {
                    showBoostInfo = false
                }) {
                    Text("Got it!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showBoostInfo = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func infoPoint(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Helper Functions

    private func toggleCareerInterest(_ interest: String) {
        let wasActive = activeInterests.contains(interest)

        if wasActive {
            activeInterests.remove(interest)
        } else {
            activeInterests.insert(interest)
        }

        // Track analytics
        AnalyticsService.shared.trackCareerInterestToggled(
            interest: interest,
            action: wasActive ? "disabled" : "enabled",
            activeInterestsCount: activeInterests.count,
            totalInterestsCount: originalCareerInterests.count
        )

        // Persist the change
        viewModel.userData[.activeCareerInterests] = activeInterests as AnyHashable

        // Capture current careers before refresh for diff calculation
        previousCareers = viewModel.careerTracks

        // Refresh recommendations with updated interests
        Task {
            await refreshRecommendations()
        }
    }

    private func resetToOriginalInterests() {
        activeInterests = originalCareerInterests
        viewModel.userData[.activeCareerInterests] = activeInterests as AnyHashable

        // Track analytics
        AnalyticsService.shared.trackCareerInterestsReset(totalInterests: originalCareerInterests.count)

        // Capture current careers before refresh
        previousCareers = viewModel.careerTracks

        Task {
            await refreshRecommendations()
        }
    }

    private func refreshRecommendations() async {
        await MainActor.run {
            isRefreshing = true
        }

        // Call Recipe D v4.0 with updated career interests
        await viewModel.refreshRecommendationsWithInterests(Array(activeInterests))

        await MainActor.run {
            // Calculate match diffs if we have previous careers
            if !previousCareers.isEmpty {
                matchDiffs = CareerMatchDiffCalculator.calculateDiffs(
                    previousCareers: previousCareers,
                    newCareers: viewModel.careerTracks
                )
            }

            // Recalculate top 3 matches
            topMatchIds = MatchBucketing.identifyTopMatches(in: viewModel.careerTracks)

            // Generate smart suggestions based on current state
            smartSuggestions = SmartSuggestionEngine.generateSuggestions(
                originalInterests: originalCareerInterests,
                activeInterests: activeInterests,
                topCareers: viewModel.careerTracks
            )

            // Track analytics
            AnalyticsService.shared.trackRecommendationsRefreshed(
                activeInterestsCount: activeInterests.count,
                totalInterestsCount: originalCareerInterests.count,
                resultCount: viewModel.careerTracks.count
            )

            isRefreshing = false
        }
    }

    private func isBoosted(career: CareerTrack) -> Bool {
        // Check if any active career interest would boost this career
        // For now, use simple title matching - can be enhanced with keyword matching
        guard !activeInterests.isEmpty else { return false }

        let careerTitle = career.title.lowercased()
        return activeInterests.contains { interest in
            careerTitle.contains(interest.lowercased()) ||
            interest.lowercased().contains(careerTitle)
        }
    }


    // MARK: - Computed Properties

    private var originalCareerInterests: Set<String> {
        if let interests = viewModel.userData[.careerInterests] as? Set<Career> {
            return Set(interests.map { $0.name })
        } else if let interestStrings = viewModel.userData[.careerInterests] as? Set<String> {
            return interestStrings
        }
        return []
    }

    private var hasCareerInterests: Bool {
        !originalCareerInterests.isEmpty
    }

    private var hasDeselectedInterests: Bool {
        activeInterests.count < originalCareerInterests.count
    }

    /// Careers sorted by match quality: Top matches first, then High/Medium/Low tiers
    private var sortedCareerTracks: [CareerTrack] {
        viewModel.careerTracks.sorted { first, second in
            let firstIsTop = topMatchIds.contains(first.id)
            let secondIsTop = topMatchIds.contains(second.id)

            // Top matches always come first
            if firstIsTop != secondIsTop {
                return firstIsTop
            }

            // If both are top matches, sort by score descending
            if firstIsTop && secondIsTop {
                return first.match > second.match
            }

            // For non-top matches, sort by tier then by score
            let firstTier = first.matchTier
            let secondTier = second.matchTier

            if firstTier != secondTier {
                // High > Medium > Low
                let tierOrder: [MatchTier: Int] = [.high: 0, .medium: 1, .low: 2]
                return tierOrder[firstTier]! < tierOrder[secondTier]!
            }

            // Within same tier, sort by score descending
            return first.match > second.match
        }
    }

    // MARK: - Share Functions

    private func generateAndShareComparison() {
        shareText = CareerComparisonExporter.generateComparisonText(
            topCareers: viewModel.careerTracks,
            activeInterests: activeInterests,
            originalInterests: originalCareerInterests,
            format: .plainText
        )

        AnalyticsService.shared.trackCareerComparisonExported(
            interestsIncluded: Array(activeInterests),
            careerCount: min(10, viewModel.careerTracks.count),
            format: "text"
        )

        showShareSheet = true
    }

    private func generateAndShareDiffComparison() {
        shareText = CareerComparisonExporter.generateDiffComparison(
            diffs: matchDiffs,
            topCount: 10,
            activeInterests: activeInterests,
            originalInterests: originalCareerInterests
        )

        AnalyticsService.shared.trackCareerComparisonExported(
            interestsIncluded: Array(activeInterests),
            careerCount: matchDiffs.count,
            format: "diff_text"
        )

        showShareSheet = true
    }

    private func generateAndShareQuickSummary() {
        shareText = CareerComparisonExporter.generateQuickSummary(
            topCareers: viewModel.careerTracks,
            count: 3
        )

        AnalyticsService.shared.trackCareerComparisonExported(
            interestsIncluded: Array(activeInterests),
            careerCount: 3,
            format: "quick_summary"
        )

        showShareSheet = true
    }
}

// MARK: - ShareSheet UIViewControllerRepresentable

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Preview
#if DEBUG
struct AllRecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AllRecommendationsView(viewModel: AppViewModel())
        }
    }
}
#endif
