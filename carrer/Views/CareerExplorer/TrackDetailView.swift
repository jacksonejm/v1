import SwiftUI

/// Detailed view of a tracked career showing progress, milestones, tasks, and skill gaps
struct TrackDetailView: View {
    let track: CareerTrack
    let isTopMatch: Bool

    @ObservedObject var tracksViewModel: CareerTracksViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showSkillAssessment = false
    @State private var showArchiveConfirmation = false
    @State private var expandedMilestone: TrackMilestone? = nil
    @State private var notes: String = ""

    private let analytics = AnalyticsService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                headerSection

                // Overall progress
                overallProgressSection

                // Milestones & Tasks
                milestonesSection

                // Skill Gaps
                if let skills = track.skills, !skills.isEmpty {
                    skillGapsSection
                }

                // Notes section
                notesSection

                // Archive button
                archiveSection
            }
            .padding()
        }
        .navigationTitle(track.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSkillAssessment = true

                    // Track analytics
                    if let skills = track.skills {
                        analytics.trackSkillAssessmentOpened(
                            careerTitle: track.title,
                            skillsCount: skills.count
                        )
                    }
                }) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(isPresented: $showSkillAssessment) {
            if let skills = track.skills {
                SkillAssessmentSheet(skills: skills) { assessments in
                    // Save skill assessments
                    for (skillName, level) in assessments {
                        tracksViewModel.assessSkill(
                            skillName: skillName,
                            level: level,
                            careerContext: track.title
                        )
                    }

                    // Track analytics
                    analytics.trackSkillAssessmentCompleted(
                        careerTitle: track.title,
                        skillsAssessed: assessments.count,
                        totalSkills: skills.count
                    )
                }
            }
        }
        .confirmationDialog(
            "Archive this track?",
            isPresented: $showArchiveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Archive", role: .destructive) {
                tracksViewModel.archiveTrack(careerId: track.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can always start tracking this career again later.")
        }
        .onAppear {
            notes = track.userNotes ?? ""

            // Track analytics
            analytics.trackDetailViewed(
                careerTitle: track.title,
                completionPercentage: Int(track.trackProgress * 100),
                tasksCompleted: track.completedTaskCount,
                totalTasks: track.totalTaskCount
            )
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Badges
            HStack(spacing: 8) {
                if isTopMatch {
                    TopMatchBadge(size: .medium)
                } else {
                    MatchPill(tier: track.matchTier, size: .medium)
                }

                if track.isBoosted {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption)
                        Text("Boosted")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.15))
                    .cornerRadius(8)
                }
            }

            // Career info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                    Text(track.salary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 6) {
                    Image(systemName: "graduationcap.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                    Text(track.education)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let onetCode = track.onetCode {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                        Text("O*NET: \(onetCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Overall Progress Section

    private var overallProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Progress")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(track.completedTaskCount) of \(track.totalTaskCount) tasks completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(track.trackProgress * 100))%")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .cornerRadius(6)

                        Rectangle()
                            .fill(AppColors.primary)
                            .frame(width: geometry.size.width * track.trackProgress, height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
            }
            .padding()
            .background(AppColors.primary.opacity(0.1))
            .cornerRadius(12)
        }
    }

    // MARK: - Milestones Section

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
                .font(.headline)

            ForEach(TrackMilestone.allCases, id: \.self) { milestone in
                milestoneCard(milestone)
            }
        }
    }

    private func milestoneCard(_ milestone: TrackMilestone) -> some View {
        let milestoneTasks = track.tasks?.filter { $0.milestone == milestone } ?? []
        let completedCount = milestoneTasks.filter { $0.isDone }.count
        let totalCount = milestoneTasks.count
        let isExpanded = expandedMilestone == milestone
        let isComplete = totalCount > 0 && completedCount == totalCount

        return VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedMilestone = isExpanded ? nil : milestone
                }
            }) {
                HStack(spacing: 12) {
                    // Icon
                    Image(systemName: milestone.icon)
                        .font(.title3)
                        .foregroundColor(isComplete ? .green : AppColors.primary)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(milestone.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        if totalCount > 0 {
                            Text("\(completedCount)/\(totalCount) tasks completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No tasks yet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            // Tasks list (expanded)
            if isExpanded && !milestoneTasks.isEmpty {
                VStack(spacing: 8) {
                    ForEach(milestoneTasks) { task in
                        taskRow(task)
                    }
                }
                .padding(.leading, 52)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isComplete ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }

    private func taskRow(_ task: TrackTask) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                if task.isDone {
                    // Can't un-complete tasks in this version
                } else {
                    tracksViewModel.completeTask(taskId: task.id, careerId: track.id)
                }
            }) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isDone ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .foregroundColor(task.isDone ? .secondary : .primary)
                    .strikethrough(task.isDone)

                if task.isDone, let completedAt = task.completedAt {
                    Text("Completed \(completedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: task.type.icon)
                .font(.caption)
                .foregroundColor(AppColors.primary.opacity(0.6))
        }
        .padding(.vertical, 8)
    }

    // MARK: - Skill Gaps Section

    private var skillGapsSection: some View {
        let gaps = tracksViewModel.topSkillGaps(for: track, limit: 5)

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Top Skill Gaps")
                    .font(.headline)

                Spacer()

                Button(action: {
                    showSkillAssessment = true

                    // Track analytics
                    if let skills = track.skills {
                        analytics.trackSkillAssessmentOpened(
                            careerTitle: track.title,
                            skillsCount: skills.count
                        )
                    }
                }) {
                    Text("Assess Skills")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            if gaps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)

                    Text("Great job!")
                        .font(.headline)

                    Text("You haven't assessed your skills yet, or you're meeting all the requirements.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(gaps) { gap in
                        skillGapRow(gap)
                    }
                }
            }
        }
    }

    private func skillGapRow(_ gap: SkillGap) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(gap.skill.skill)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(gap.gapDescription)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(gapColor(for: gap))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(gapColor(for: gap).opacity(0.1))
                    .cornerRadius(8)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Required")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(gap.skill.importancePercentage)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Your level")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if let userLevel = gap.userLevel {
                        Text(userLevel.label)
                            .font(.caption)
                            .fontWeight(.semibold)
                    } else {
                        Text("Not assessed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private func gapColor(for gap: SkillGap) -> Color {
        if gap.gapSize >= 40 {
            return .red
        } else if gap.gapSize >= 20 {
            return .orange
        } else {
            return .green
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)

            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .onChange(of: notes) { _, newValue in
                    tracksViewModel.updateNotes(newValue, for: track.id)
                }

            if notes.isEmpty {
                Text("Add personal notes, goals, or reminders for this career track")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, -90)
                    .padding(.leading, 12)
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Archive Section

    private var archiveSection: some View {
        VStack(spacing: 16) {
            Divider()

            Button(action: { showArchiveConfirmation = true }) {
                HStack {
                    Image(systemName: "archivebox.fill")
                    Text("Archive This Track")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Text("Archiving removes this from your active tracks but keeps your progress history.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TrackDetailView(
            track: CareerTrack(
                title: "Software Developer",
                progress: 45,
                salary: "$70,000 - $120,000",
                education: "Bachelor's Degree",
                match: 95,
                onetCode: "15-1252.00",
                onetDescription: "Research, design, and develop computer and network software",
                skills: [
                    CareerSkill(
                        skill: "Programming",
                        importance: 4.5,
                        level: 5.25
                    ),
                    CareerSkill(
                        skill: "Problem Solving",
                        importance: 4.25,
                        level: 4.9
                    )
                ],
                trackedAt: Date(),
                tasks: [
                    TrackTask(
                        milestone: .understandRole,
                        type: .learn,
                        title: "Read career overview",
                        status: .done
                    ),
                    TrackTask(
                        milestone: .understandRole,
                        type: .learn,
                        title: "Review top required skills",
                        status: .todo
                    ),
                    TrackTask(
                        milestone: .assessGaps,
                        type: .learn,
                        title: "Complete skill self-assessment",
                        status: .todo
                    )
                ]
            ),
            isTopMatch: true,
            tracksViewModel: CareerTracksViewModel(appViewModel: AppViewModel())
        )
    }
}
