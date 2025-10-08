import SwiftUI

/// Detailed view for a specific O*NET occupation
/// Shows skills, technologies, job search links, and full description
struct ONetCareerDetailView: View {
    let careerTrack: CareerTrack
    @StateObject private var viewModel = ONetCareerViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                headerSection

                // Match Information
                if let riasecMatch = careerTrack.riasecMatch {
                    matchSection(riasecMatch: riasecMatch)
                }

                // Description
                if let description = careerTrack.onetDescription {
                    descriptionSection(description: description)
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

                // Alternate Job Titles
                if let jobSearch = viewModel.jobSearchStrategy,
                   !jobSearch.alternateTitles.isEmpty {
                    alternateTitlesSection(titles: jobSearch.alternateTitles)
                }

                // Job Search Links
                if let jobSearch = viewModel.jobSearchStrategy {
                    jobSearchSection(links: jobSearch.jobSearchLinks)
                }

                // O*NET Attribution
                attributionSection
            }
            .padding()
        }
        .navigationTitle(careerTrack.title)
        .navigationBarTitleDisplayMode(.large)
        .task {
            // Load career details when view appears
            if let onetCode = careerTrack.onetCode {
                await viewModel.fetchCareerSkills(occupationCode: onetCode)
                await viewModel.fetchJobSearchStrategy(occupationCode: onetCode)
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(careerTrack.title)
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                Text("\(careerTrack.match)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(12)
            }

            if let onetCode = careerTrack.onetCode {
                Text("O*NET Code: \(onetCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

    private func alternateTitlesSection(titles: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Also Known As")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(titles.prefix(5), id: \.self) { title in
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

    private var attributionSection: some View {
        VStack(spacing: 4) {
            Text("Powered by O*NET")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("U.S. Department of Labor")
                .font(.caption2)
                .foregroundColor(.secondary)
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
            )
        )
    }
}
