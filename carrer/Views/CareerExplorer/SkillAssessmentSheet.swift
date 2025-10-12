import SwiftUI

/// Bottom sheet for quick skill self-assessment when starting a career track
struct SkillAssessmentSheet: View {
    let skills: [CareerSkill]
    let onComplete: ([String: UserSkillLevel]) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var assessments: [String: UserSkillLevel] = [:]
    @State private var showSkipConfirmation = false

    private var topSkills: [CareerSkill] {
        Array(skills.prefix(7))  // Top 7 most important skills
    }

    private var canComplete: Bool {
        assessments.count >= 3  // Require at least 3 assessments
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection

                    // Skill assessment items
                    VStack(spacing: 16) {
                        ForEach(topSkills, id: \.skill) { skill in
                            skillAssessmentRow(skill)
                        }
                    }

                    // Footer note
                    footerNote
                }
                .padding()
            }
            .navigationTitle("Quick Skill Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip for now") {
                        showSkipConfirmation = true
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        completeAssessment()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canComplete)
                }
            }
            .confirmationDialog(
                "Skip skill assessment?",
                isPresented: $showSkipConfirmation,
                titleVisibility: .visible
            ) {
                Button("Skip") {
                    dismiss()
                }
                Button("Continue assessing", role: .cancel) {}
            } message: {
                Text("You can assess skills later from your track detail page.")
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Components

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Rate your current level")
                        .font(.headline)

                    Text("Assess at least 3 skills to continue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text("This helps identify which skills you need to develop for this career.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(AppColors.primary.opacity(0.1))
        .cornerRadius(12)
    }

    private func skillAssessmentRow(_ skill: CareerSkill) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Skill name and importance
            HStack {
                Text(skill.skill)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if skill.importancePercentage >= 75 {
                    Text("High priority")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            // Level selector
            HStack(spacing: 8) {
                ForEach(UserSkillLevel.allCases, id: \.self) { level in
                    levelButton(skill: skill.skill, level: level)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    assessments[skill.skill] != nil ? AppColors.primary : Color.clear,
                    lineWidth: 2
                )
        )
    }

    private func levelButton(skill: String, level: UserSkillLevel) -> some View {
        let isSelected = assessments[skill] == level

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                assessments[skill] = level
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: level.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : AppColors.primary)

                Text(level.label)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.primary : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var footerNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundColor(.orange)

            Text("Be honest! This helps us suggest the right activities to build these skills.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - Actions

    private func completeAssessment() {
        onComplete(assessments)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    SkillAssessmentSheet(
        skills: [
            CareerSkill(
                skill: "Communication",
                importance: 4.25,  // 0-5 scale
                level: 4.9         // 0-7 scale
            ),
            CareerSkill(
                skill: "Critical Thinking",
                importance: 4.0,
                level: 5.25
            ),
            CareerSkill(
                skill: "Active Listening",
                importance: 3.75,
                level: 4.55
            ),
            CareerSkill(
                skill: "Reading Comprehension",
                importance: 3.5,
                level: 4.9
            ),
            CareerSkill(
                skill: "Writing",
                importance: 3.25,
                level: 4.2
            )
        ],
        onComplete: { assessments in
            print("Assessed \(assessments.count) skills")
        }
    )
}
