import SwiftUI

/// Full-screen view showing all career recommendations with filterable career interests
/// Recipe D v4.0 - Allows users to toggle career interest boosts and see updated recommendations
struct AllRecommendationsView: View {
    @ObservedObject var viewModel: AppViewModel
    @StateObject private var tracksViewModel: CareerTracksViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isRefreshing = false
    @State private var showBoostInfo = false

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
        .sheet(isPresented: $showBoostInfo) {
            boostInfoSheet
        }
    }

    // MARK: - Filter Chips Section

    private var filterChipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Career Interests")
                    .font(.headline)
                    .foregroundColor(.primary)

                Button(action: {
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
                    ForEach(originalCareerInterests, id: \.self) { interest in
                        CareerInterestFilterChip(
                            title: interest,
                            isSelected: activeCareerInterests.contains(interest),
                            action: {
                                toggleCareerInterest(interest)
                            }
                        )
                    }
                }
            }

            // Status text
            if activeCareerInterests.isEmpty {
                Text("Showing recommendations without career interest boost")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if activeCareerInterests.count < originalCareerInterests.count {
                Text("Showing \(activeCareerInterests.count) of \(originalCareerInterests.count) interests")
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
                    ForEach(Array(viewModel.careerTracks.enumerated()), id: \.element.id) { index, track in
                        // This view doesn't use badge system, so isTopMatch is always false
                        NavigationLink(destination: ONetCareerDetailView(
                            careerTrack: track,
                            isTopMatch: false,
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
        HStack(spacing: 16) {
            // Rank number
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(track.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // Boost indicator
                    if isBoosted(career: track) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
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

                    // Match percentage
                    Text("\(track.match)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(matchColor(for: track.match))
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
        if activeCareerInterests.contains(interest) {
            activeCareerInterests.remove(interest)
        } else {
            activeCareerInterests.insert(interest)
        }

        // Persist the change
        viewModel.userData[.activeCareerInterests] = activeCareerInterests as AnyHashable

        // Refresh recommendations with updated interests
        Task {
            await refreshRecommendations()
        }
    }

    private func resetToOriginalInterests() {
        activeCareerInterests = originalCareerInterests
        viewModel.userData[.activeCareerInterests] = activeCareerInterests as AnyHashable

        Task {
            await refreshRecommendations()
        }
    }

    private func refreshRecommendations() async {
        await MainActor.run {
            isRefreshing = true
        }

        // Call Recipe D v4.0 with updated career interests
        await viewModel.refreshRecommendationsWithInterests(Array(activeCareerInterests))

        await MainActor.run {
            isRefreshing = false
        }
    }

    private func isBoosted(career: CareerTrack) -> Bool {
        // Check if any active career interest would boost this career
        // For now, use simple title matching - can be enhanced with keyword matching
        guard !activeCareerInterests.isEmpty else { return false }

        let careerTitle = career.title.lowercased()
        return activeCareerInterests.contains { interest in
            careerTitle.contains(interest.lowercased()) ||
            interest.lowercased().contains(careerTitle)
        }
    }

    private func matchColor(for percentage: Int) -> Color {
        switch percentage {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return AppColors.primary
        case 60..<70: return .orange
        default: return .gray
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

    private var activeCareerInterests: Set<String> {
        get {
            if let active = viewModel.userData[.activeCareerInterests] as? Set<String> {
                return active
            }
            // If not set yet, initialize from original interests
            return originalCareerInterests
        }
        set {
            viewModel.userData[.activeCareerInterests] = newValue as AnyHashable
        }
    }

    private var hasCareerInterests: Bool {
        !originalCareerInterests.isEmpty
    }

    private var hasDeselectedInterests: Bool {
        activeCareerInterests.count < originalCareerInterests.count
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
