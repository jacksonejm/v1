import SwiftUI

/// Detailed view for a specific O*NET occupation
/// Shows skills, technologies, job search links, and full description
struct ONetCareerDetailView: View {
    let careerTrack: CareerTrack
    let isTopMatch: Bool
    @ObservedObject var tracksViewModel: CareerTracksViewModel
    @StateObject private var viewModel = ONetCareerViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showMatchBreakdown = false
    @State private var showAddToTrack = false

    // Access to app state for Canadian context
    private var appViewModel: AppViewModel {
        tracksViewModel.appViewModel
    }

    private var canadianOccupation: CanadianOccupation? {
        guard let onetCode = careerTrack.onetCode else { return nil }
        return appViewModel.canadianOccupationData[onetCode]
    }

    private var isAlreadyTracked: Bool {
        tracksViewModel.isTracked(careerId: careerTrack.id)
    }

    // Seamless data accessors that blend Canadian and O*NET data
    private var displayTitle: String {
        if appViewModel.userCountry.usesNOC, let canadianTitle = canadianOccupation?.canadianTitle {
            return canadianTitle
        }
        return careerTrack.title
    }

    private var displayDescription: String? {
        if appViewModel.userCountry.usesNOC, let canadianDesc = canadianOccupation?.description {
            return canadianDesc
        }
        return careerTrack.onetDescription
    }

    private var displayCode: String? {
        if appViewModel.userCountry.usesNOC, let nocCode = canadianOccupation?.nocCode {
            return "NOC " + nocCode
        }
        if let onetCode = careerTrack.onetCode {
            return "O*NET " + onetCode
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                headerSection

                // Add to Track CTA
                addToTrackButton

                // Match Information
                if let riasecMatch = careerTrack.riasecMatch {
                    matchSection(riasecMatch: riasecMatch)
                }

                // Description
                if let description = displayDescription {
                    descriptionSection(description: description)
                }

                // Additional Canadian sections (seamlessly integrated)
                if appViewModel.userCountry.usesNOC, let canadianOcc = canadianOccupation {
                    // French title
                    if let frenchTitle = canadianOcc.canadianTitleFr {
                        frenchTitleSection(title: frenchTitle)
                    }

                    // Employment Requirements
                    if !canadianOcc.requirementsArray.isEmpty {
                        requirementsSection(requirements: canadianOcc.requirementsArray)
                    }

                    // Main Duties
                    if !canadianOcc.dutiesArray.isEmpty {
                        dutiesSection(duties: canadianOcc.dutiesArray)
                    }
                }

                // Skills Section
                if !viewModel.skills.isEmpty {
                    skillsSection
                } else if viewModel.isLoadingSkills {
                    loadingSkillsSection
                }

                // Technologies Section
                if let jobSearch = viewModel.jobSearchStrategy,
                   !jobSearch.technologies.isEmpty {
                    technologiesSection(technologies: jobSearch.technologies)
                }

                // Alternate Job Titles (blend Canadian and O*NET)
                alternateTitlesSection

                // Job Search Links
                if let jobSearch = viewModel.jobSearchStrategy {
                    jobSearchSection(links: jobSearch.jobSearchLinks)
                }

                // O*NET Attribution
                attributionSection
            }
            .padding()
        }
        .navigationTitle(displayTitle)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showMatchBreakdown) {
            MatchBreakdownView(careerTrack: careerTrack)
        }
        .sheet(isPresented: $showAddToTrack) {
            AddToTrackSheet(
                career: careerTrack,
                isTopMatch: isTopMatch,
                onConfirm: {
                    do {
                        _ = try tracksViewModel.addTrack(career: careerTrack)
                        showAddToTrack = false
                    } catch {
                        // Handle error (track limit reached or already tracked)
                        print("Error adding track: \(error.localizedDescription)")
                    }
                }
            )
        }
        .task {
            // Load career details when view appears
            if let onetCode = careerTrack.onetCode {
                await viewModel.fetchCareerSkills(occupationCode: onetCode)
                await viewModel.fetchJobSearchStrategy(occupationCode: onetCode)
            }
        }
    }

    // MARK: - View Components

    private var addToTrackButton: some View {
        Group {
            if isAlreadyTracked {
                // Already tracking - show status and link to track detail
                if let track = tracksViewModel.getTrack(careerId: careerTrack.id) {
                    NavigationLink(destination: TrackDetailView(
                        track: track,
                        isTopMatch: isTopMatch,
                        tracksViewModel: tracksViewModel
                    )) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Currently Tracking")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text("Tap to view your progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Not tracking yet - show Add to Track CTA
                Button(action: {
                    showAddToTrack = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add to Track")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("Start planning your path to this career")
                                .font(.caption)
                        }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(displayTitle)
                .font(.title)
                .fontWeight(.bold)

            // Badges row
            HStack(spacing: 8) {
                // Show top match badge if in top 3, otherwise show match tier
                if isTopMatch {
                    TopMatchBadge(size: .medium)
                } else {
                    MatchPill(tier: careerTrack.matchTier, size: .medium)
                }

                if careerTrack.isBoosted {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption)
                        Text("Boosted")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.15))
                    .cornerRadius(999)
                }
            }

            if let code = displayCode {
                Text(code)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // "Why this match?" button - shows numeric breakdown
            Button(action: {
                showMatchBreakdown = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "questionmark.circle")
                        .font(.caption)
                    Text("Why this match?")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("See breakdown")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private func matchSection(riasecMatch: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Personality Match")
                .font(.headline)

            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(AppColors.primary)

                Text(riasecMatch)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private func descriptionSection(description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About This Career")
                .font(.headline)

            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Required Skills")
                .font(.headline)

            ForEach(viewModel.skills.prefix(10)) { skill in
                SkillRowView(skill: skill)
            }
        }
    }

    private var loadingSkillsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Required Skills")
                .font(.headline)

            ProgressView()
                .padding()
        }
    }

    private func technologiesSection(technologies: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Technologies & Tools")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(technologies.prefix(10), id: \.self) { tech in
                        TechnologyChip(name: tech)
                    }
                }
            }
        }
    }

    private func jobSearchSection(links: JobBoardLinks) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Find Jobs")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach([JobBoardLinks.JobBoard.linkedin, .indeed, .google], id: \.name) { board in
                    JobBoardButton(board: board, url: links.url(for: board))
                }
            }
        }
    }

    private func frenchTitleSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Titre français")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(title)
                .font(.body)
                .italic()
                .foregroundColor(.secondary)
        }
    }

    private func requirementsSection(requirements: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Employment Requirements")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(requirements.enumerated()), id: \.offset) { _, requirement in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.body)
                            .foregroundColor(AppColors.primary)
                        Text(requirement)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func dutiesSection(duties: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Main Duties")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(duties.prefix(5).enumerated()), id: \.offset) { _, duty in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.body)
                            .foregroundColor(AppColors.primary)
                        Text(duty)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var alternateTitlesSection: some View {
        let titles = blendedAlternateTitles
        if !titles.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Also Known As")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(titles.prefix(5).enumerated()), id: \.offset) { index, title in
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(AppColors.primary)
                                .font(.caption)

                            Text(title)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }

    private var blendedAlternateTitles: [String] {
        var titles: [String] = []

        // Add Canadian example titles if available
        if appViewModel.userCountry.usesNOC, let canadianOcc = canadianOccupation {
            titles.append(contentsOf: canadianOcc.exampleTitlesArray)
        }

        // Add O*NET alternate titles
        if let jobSearch = viewModel.jobSearchStrategy {
            titles.append(contentsOf: jobSearch.alternateTitles)
        }

        // Clean up titles: trim whitespace, filter invalid entries, remove duplicates
        let cleanedTitles = titles
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count >= 3 } // Must be at least 3 characters
            .filter { !$0.allSatisfy { $0.isNumber } } // Exclude numeric-only strings like "1", "2"
            .filter { $0 != careerTrack.title } // Exclude the main career title

        return Array(Set(cleanedTitles)).sorted() // Remove duplicates and sort
    }

    private var attributionSection: some View {
        VStack(spacing: 4) {
            if appViewModel.userCountry.usesNOC, canadianOccupation != nil {
                Text("Data from Canadian OaSIS & O*NET")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Employment and Social Development Canada • U.S. Department of Labor")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Powered by O*NET")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("U.S. Department of Labor")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }
}

// MARK: - Supporting Views

/// Row displaying a skill with importance and level bars
struct SkillRowView: View {
    let skill: CareerSkill

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(skill.skill)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                // Importance bar
                VStack(alignment: .leading, spacing: 4) {
                    Text("Importance")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)

                            Rectangle()
                                .fill(AppColors.primary)
                                .frame(width: geometry.size.width * CGFloat(skill.importancePercentage) / 100, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }

                // Level bar
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)

                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(skill.levelPercentage) / 100, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .frame(height: 30)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

/// Chip displaying a technology/tool name
struct TechnologyChip: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.primary.opacity(0.1))
            .foregroundColor(AppColors.primary)
            .cornerRadius(16)
    }
}

/// Button to open a job board search
struct JobBoardButton: View {
    let board: JobBoardLinks.JobBoard
    let url: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Image(systemName: board.icon)
                    .font(.title3)

                Text("Search on \(board.name)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .foregroundColor(.primary)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ONetCareerDetailView(
            careerTrack: CareerTrack(
                title: "Software Developer",
                progress: 0,
                salary: "$70,000 - $120,000",
                education: "Bachelor's Degree",
                match: 95,
                onetCode: "15-1252.00",
                onetDescription: "Research, design, and develop computer and network software or specialized utility programs. Analyze user needs and develop software solutions, applying principles and techniques of computer science, engineering, and mathematical analysis.",
                primaryRIASEC: "Investigative",
                secondaryRIASEC: "Conventional"
            ),
            isTopMatch: true,
            tracksViewModel: CareerTracksViewModel(appViewModel: AppViewModel())
        )
    }
}
