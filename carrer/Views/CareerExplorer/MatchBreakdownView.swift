import SwiftUI

/// Sheet view showing the numeric breakdown of a career match score
/// Displays the 4-dimensional Recipe D v4.0 scoring breakdown
/// - RIASEC: 40%
/// - Work Values: 30%
/// - Skills: 20%
/// - Career Interests: 10%
struct MatchBreakdownView: View {
    let careerTrack: CareerTrack
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Overall match score
                    overallMatchSection

                    Divider()

                    // Explainer
                    explainerSection

                    Divider()

                    // Breakdown bars
                    breakdownBarsSection

                    Divider()

                    // What the tiers mean
                    tierExplainerSection
                }
                .padding()
            }
            .navigationTitle("Why this match?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Track analytics when breakdown is viewed
            AnalyticsService.shared.trackMatchBreakdownViewed(
                careerTitle: careerTrack.title,
                matchPercentage: careerTrack.match,
                matchBucket: careerTrack.matchTier.analyticsValue
            )
        }
    }

    // MARK: - Sections

    private var overallMatchSection: some View {
        VStack(spacing: 12) {
            Text("\(careerTrack.title)")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                // Match tier pill
                MatchPill(tier: careerTrack.matchTier, size: .large)

                // Numeric score (shown here for transparency)
                Text("\(careerTrack.match)%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var explainerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How we calculate matches")
                .font(.headline)

            Text("Your match score combines four key factors:")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var breakdownBarsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Note: These are placeholder values since we don't have the individual scores
            // In a full implementation, these would come from the ONetOccupation object
            breakdownBar(
                label: "Personality (RIASEC)",
                weight: "40%",
                score: estimatedRIASECScore,
                color: .blue
            )

            breakdownBar(
                label: "Work Values",
                weight: "30%",
                score: estimatedValuesScore,
                color: .purple
            )

            breakdownBar(
                label: "Skills & Abilities",
                weight: "20%",
                score: estimatedSkillsScore,
                color: .green
            )

            breakdownBar(
                label: "Career Interests",
                weight: "10%",
                score: careerTrack.isBoosted ? 100 : 0,
                color: .orange,
                note: careerTrack.isBoosted ? "Boosted by your interests" : "Not boosted"
            )
        }
    }

    private var tierExplainerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What the tiers mean")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                tierRow(
                    tier: .high,
                    range: "80-100%",
                    description: "Strong alignment with your personality, values, and skills"
                )

                tierRow(
                    tier: .medium,
                    range: "70-79%",
                    description: "Good fit with potential for growth and development"
                )

                tierRow(
                    tier: .low,
                    range: "Below 70%",
                    description: "May require significant skill development or career pivoting"
                )
            }
        }
    }

    // MARK: - Helper Views

    private func breakdownBar(
        label: String,
        weight: String,
        score: Int,
        color: Color,
        note: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(weight)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 12)
                        .cornerRadius(6)

                    // Fill
                    Rectangle()
                        .fill(color.opacity(0.8))
                        .frame(
                            width: geometry.size.width * CGFloat(score) / 100,
                            height: 12
                        )
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)

            HStack {
                Text("\(score)%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)

                if let note = note {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption2)

                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func tierRow(tier: MatchTier, range: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            MatchPill(tier: tier, size: .small)

            VStack(alignment: .leading, spacing: 4) {
                Text(range)
                    .font(.caption)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Score Estimations

    // These are rough estimates based on the overall match
    // In a full implementation, store individual scores in CareerTrack
    private var estimatedRIASECScore: Int {
        // RIASEC typically contributes heavily to high scores
        return min(100, careerTrack.match + 5)
    }

    private var estimatedValuesScore: Int {
        // Values usually aligned within a range
        return max(70, careerTrack.match - 5)
    }

    private var estimatedSkillsScore: Int {
        // Skills may vary more
        return max(60, careerTrack.match - 10)
    }
}

// MARK: - Preview

#if DEBUG
struct MatchBreakdownView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MatchBreakdownView(
                careerTrack: CareerTrack(
                    title: "Software Developer",
                    progress: 0,
                    salary: "$110,140",
                    education: "Bachelor's degree",
                    match: 86,
                    onetCode: "15-1252.00"
                )
            )

            MatchBreakdownView(
                careerTrack: CareerTrack(
                    title: "Data Scientist",
                    progress: 0,
                    salary: "$100,910",
                    education: "Master's degree",
                    match: 73,
                    onetCode: "15-2051.00"
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
#endif
