import SwiftUI

/// Confirmation sheet for adding a career to tracked list
struct AddToTrackSheet: View {
    let career: CareerTrack
    let isTopMatch: Bool
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header icon
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)
                    .padding(.top, 32)

                // Career info
                VStack(spacing: 12) {
                    Text("Start a track for")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(career.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    // Badges
                    HStack(spacing: 8) {
                        if isTopMatch {
                            TopMatchBadge(size: .small)
                        } else {
                            MatchPill(tier: career.matchTier, size: .small)
                        }

                        if career.isBoosted {
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
                    }
                }

                // What happens
                VStack(alignment: .leading, spacing: 16) {
                    featureRow(
                        icon: "checklist",
                        title: "Guided milestones",
                        description: "Step-by-step tasks to prepare for this career"
                    )

                    featureRow(
                        icon: "chart.bar.fill",
                        title: "Track progress",
                        description: "See how close you are to being career-ready"
                    )

                    featureRow(
                        icon: "arrow.up.circle.fill",
                        title: "Close skill gaps",
                        description: "Get activity recommendations to build key skills"
                    )
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    Button(action: handleConfirm) {
                        Text("Start Track")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }

                    Button(action: { dismiss() }) {
                        Text("Not now")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.primary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func handleConfirm() {
        onConfirm()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AddToTrackSheet(
        career: CareerTrack(
            title: "Software Developer",
            progress: 0,
            salary: "$70,000 - $120,000",
            education: "Bachelor's Degree",
            match: 95,
            onetCode: "15-1252.00",
            onetDescription: "Research, design, and develop computer and network software"
        ),
        isTopMatch: true,
        onConfirm: {
            print("Track started!")
        }
    )
}
