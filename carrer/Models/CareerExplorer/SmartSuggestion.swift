import Foundation

/// Smart suggestions for discovering new career matches
/// Recipe D v4.0 - Helps users explore beyond their stated interests
struct SmartSuggestion: Identifiable, Equatable {
    let id = UUID()
    let type: SuggestionType
    let title: String
    let description: String
    let actionText: String
    let interestToToggle: String?

    enum SuggestionType {
        case turnOffInterest // Suggest turning off a dominant interest
        case turnOnInterest  // Suggest turning on a disabled interest
        case exploreWithout  // Suggest exploring without specific interest
        case compareAll      // Suggest comparing with all/no interests
    }

    static func == (lhs: SmartSuggestion, rhs: SmartSuggestion) -> Bool {
        lhs.id == rhs.id
    }
}

/// Generates smart suggestions based on user's career interests and behavior
class SmartSuggestionEngine {

    /// Generate suggestions based on current state
    static func generateSuggestions(
        originalInterests: Set<String>,
        activeInterests: Set<String>,
        topCareers: [CareerTrack]
    ) -> [SmartSuggestion] {
        var suggestions: [SmartSuggestion] = []

        // Suggestion 1: If all interests are active, suggest exploring without one
        if activeInterests.count == originalInterests.count && originalInterests.count > 1 {
            if let dominantInterest = identifyDominantInterest(
                interests: Array(originalInterests),
                topCareers: topCareers
            ) {
                suggestions.append(SmartSuggestion(
                    type: .turnOffInterest,
                    title: "Discover Hidden Matches",
                    description: "Try turning off '\(dominantInterest)' to see careers you might not have considered.",
                    actionText: "Turn off \(dominantInterest)",
                    interestToToggle: dominantInterest
                ))
            }
        }

        // Suggestion 2: If some interests are disabled, suggest trying them
        if activeInterests.count < originalInterests.count && activeInterests.count > 0 {
            let disabledInterests = originalInterests.subtracting(activeInterests)
            if let firstDisabled = disabledInterests.first {
                suggestions.append(SmartSuggestion(
                    type: .turnOnInterest,
                    title: "Include '\(firstDisabled)' Again",
                    description: "Re-enable '\(firstDisabled)' to see how it affects your top matches.",
                    actionText: "Turn on \(firstDisabled)",
                    interestToToggle: firstDisabled
                ))
            }
        }

        // Suggestion 3: If user has 1-2 interests active, suggest comparing extremes
        if activeInterests.count <= 2 && originalInterests.count >= 3 {
            suggestions.append(SmartSuggestion(
                type: .compareAll,
                title: "Compare Full vs Focused",
                description: "See how your recommendations change with all interests enabled vs disabled.",
                actionText: "View Comparison",
                interestToToggle: nil
            ))
        }

        // Suggestion 4: If all interests are disabled, suggest exploring pure matches
        if activeInterests.isEmpty && !originalInterests.isEmpty {
            suggestions.append(SmartSuggestion(
                type: .exploreWithout,
                title: "Viewing Pure Matches",
                description: "These careers match your skills and personality without any interest bias. Explore unexpected options!",
                actionText: "Learn More",
                interestToToggle: nil
            ))
        }

        // Suggestion 5: Educational tip about the 10% context weight
        if activeInterests.count == originalInterests.count && !originalInterests.isEmpty {
            suggestions.append(SmartSuggestion(
                type: .exploreWithout,
                title: "Did You Know?",
                description: "Career interests only account for 10% of your match score. 90% comes from your personality, skills, and values.",
                actionText: "See Breakdown",
                interestToToggle: nil
            ))
        }

        return suggestions
    }

    /// Identify which interest appears most in top careers (likely dominant)
    private static func identifyDominantInterest(
        interests: [String],
        topCareers: [CareerTrack]
    ) -> String? {
        var interestCounts: [String: Int] = [:]

        // Count how many top careers match each interest (simple keyword matching)
        for interest in interests {
            let count = topCareers.prefix(10).filter { career in
                career.title.lowercased().contains(interest.lowercased()) ||
                interest.lowercased().contains(career.title.lowercased())
            }.count

            interestCounts[interest] = count
        }

        // Return the interest with most matches in top careers
        return interestCounts.max(by: { $0.value < $1.value })?.key
    }

    /// Generate insight about how toggling would affect recommendations
    static func generateToggleInsight(
        interest: String,
        topCareers: [CareerTrack]
    ) -> String {
        let affectedCareers = topCareers.prefix(10).filter { career in
            career.title.lowercased().contains(interest.lowercased())
        }.count

        if affectedCareers > 0 {
            return "This will affect ~\(affectedCareers) of your top 10 careers"
        } else {
            return "This may reveal new career opportunities"
        }
    }
}
