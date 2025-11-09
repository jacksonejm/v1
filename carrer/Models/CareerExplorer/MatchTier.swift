import Foundation
import SwiftUI

/// SwiftUI color extensions for MatchTier
extension MatchTier {
    /// Accessibility label
    var accessibilityLabel: String {
        return label
    }

    /// Background color for pill (light mode)
    var backgroundColor: Color {
        switch self {
        case .high: return Color.green.opacity(0.15)
        case .medium: return Color.blue.opacity(0.15)
        case .low: return Color.gray.opacity(0.15)
        }
    }

    /// Foreground color for pill text
    var foregroundColor: Color {
        switch self {
        case .high: return Color.green.opacity(0.9)
        case .medium: return Color.blue.opacity(0.9)
        case .low: return Color.gray.opacity(0.9)
        }
    }
}

/// Bucketing logic for match scores
struct MatchBucketing {

    /// Convert numeric score (0-100) to qualitative tier
    /// - High: score >= 80
    /// - Medium: 70 <= score < 80
    /// - Low: score < 70
    static func bucket(for score: Int) -> MatchTier {
        return MatchTier.from(score: score)
    }

    /// Determine if a career is in the top 3 after sorting by score
    /// - Parameters:
    ///   - careers: Array of career tracks
    ///   - limit: Number of top matches to identify (default: 3)
    /// - Returns: Set of career IDs that are top matches
    static func identifyTopMatches(
        in careers: [CareerTrack],
        limit: Int = 3
    ) -> Set<UUID> {
        // Sort by score descending, stable tiebreak by ID
        let sorted = careers.sorted { first, second in
            if first.match == second.match {
                return first.id.uuidString < second.id.uuidString
            }
            return first.match > second.match
        }

        // Take first N (or fewer if list is shorter)
        let topN = min(limit, sorted.count)
        let topMatches = sorted.prefix(topN)

        return Set(topMatches.map { $0.id })
    }

    /// Enrich careers with derived match tier and top match status
    /// This is the main function to call when preparing careers for display
    static func enrichCareers(_ careers: [CareerTrack]) -> [EnrichedCareer] {
        let topMatchIds = identifyTopMatches(in: careers)

        return careers.map { career in
            EnrichedCareer(
                career: career,
                matchTier: bucket(for: career.match),
                isTopMatch: topMatchIds.contains(career.id),
                topMatchRank: nil // Could calculate if needed
            )
        }
    }
}

/// Enriched career with derived display fields
struct EnrichedCareer: Identifiable {
    let career: CareerTrack
    let matchTier: MatchTier
    let isTopMatch: Bool
    let topMatchRank: Int? // 1, 2, 3, or nil

    var id: UUID { career.id }

    // Convenience accessors
    var title: String { career.title }
    var match: Int { career.match }
    var education: String { career.education }
    var salary: String { career.salary }
    var onetDescription: String? { career.onetDescription }
    var onetCode: String? { career.onetCode }
    var isBoosted: Bool { career.isBoosted }
}
