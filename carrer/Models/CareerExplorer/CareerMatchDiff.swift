import Foundation

/// Represents the difference in match percentage before and after toggling career interests
/// Recipe D v4.0 - Shows users how interest boosts affect recommendations
struct CareerMatchDiff: Identifiable {
    let id = UUID()
    let careerTitle: String
    let onetCode: String
    let previousMatch: Int
    let newMatch: Int

    /// The change in match percentage (can be negative)
    var difference: Int {
        newMatch - previousMatch
    }

    /// Whether the match improved, stayed same, or decreased
    var changeType: ChangeType {
        if difference > 0 {
            return .increased
        } else if difference < 0 {
            return .decreased
        } else {
            return .unchanged
        }
    }

    /// Formatted difference string with + or - sign
    var formattedDifference: String {
        if difference > 0 {
            return "+\(difference)%"
        } else if difference < 0 {
            return "\(difference)%"
        } else {
            return "—"
        }
    }

    /// Color for displaying the difference
    var differenceColor: String {
        switch changeType {
        case .increased: return "green"
        case .decreased: return "red"
        case .unchanged: return "gray"
        }
    }

    enum ChangeType {
        case increased
        case decreased
        case unchanged
    }
}

/// Helper to calculate match diffs between two career lists
struct CareerMatchDiffCalculator {

    /// Calculate diffs between previous and new career matches
    static func calculateDiffs(
        previousCareers: [CareerTrack],
        newCareers: [CareerTrack]
    ) -> [CareerMatchDiff] {
        var diffs: [CareerMatchDiff] = []

        // Create lookup dictionary for quick access
        let newCareersDict = Dictionary(uniqueKeysWithValues: newCareers.map { ($0.onetCode ?? $0.title, $0) })

        for previousCareer in previousCareers {
            let key = previousCareer.onetCode ?? previousCareer.title
            if let newCareer = newCareersDict[key] {
                let diff = CareerMatchDiff(
                    careerTitle: previousCareer.title,
                    onetCode: previousCareer.onetCode ?? "",
                    previousMatch: previousCareer.match,
                    newMatch: newCareer.match
                )
                diffs.append(diff)
            }
        }

        return diffs
    }

    /// Get top N careers with biggest increases
    static func getTopIncreases(from diffs: [CareerMatchDiff], limit: Int = 5) -> [CareerMatchDiff] {
        diffs
            .filter { $0.difference > 0 }
            .sorted { $0.difference > $1.difference }
            .prefix(limit)
            .map { $0 }
    }

    /// Get top N careers with biggest decreases
    static func getTopDecreases(from diffs: [CareerMatchDiff], limit: Int = 5) -> [CareerMatchDiff] {
        diffs
            .filter { $0.difference < 0 }
            .sorted { $0.difference < $1.difference }
            .prefix(limit)
            .map { $0 }
    }

    /// Summary statistics for the diff
    static func getSummary(from diffs: [CareerMatchDiff]) -> DiffSummary {
        let increased = diffs.filter { $0.difference > 0 }.count
        let decreased = diffs.filter { $0.difference < 0 }.count
        let unchanged = diffs.filter { $0.difference == 0 }.count

        let averageChange = diffs.isEmpty ? 0 : Double(diffs.map { $0.difference }.reduce(0, +)) / Double(diffs.count)

        return DiffSummary(
            totalCareers: diffs.count,
            increased: increased,
            decreased: decreased,
            unchanged: unchanged,
            averageChange: averageChange
        )
    }

    struct DiffSummary {
        let totalCareers: Int
        let increased: Int
        let decreased: Int
        let unchanged: Int
        let averageChange: Double

        var formattedAverageChange: String {
            if averageChange > 0 {
                return String(format: "+%.1f%%", averageChange)
            } else {
                return String(format: "%.1f%%", averageChange)
            }
        }
    }
}
