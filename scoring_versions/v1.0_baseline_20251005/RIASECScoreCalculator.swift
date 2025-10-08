import Foundation

class RIASECScoreCalculator {
    /// Calculate raw scores from RIASEC question responses
    static func calculate(from responses: [RIASECQuestion: Int]) -> [String: Int] {
        return responses.reduce(into: [:]) { scores, response in
            let ratingValue = response.value
            scores[response.key.category, default: 0] += ratingValue
        }
    }

    /// Calculate normalized RIASEC scores (0-5 scale) for Snowflake O*NET agent
    /// - Parameter responses: Dictionary with RIASEC dimension keys and response arrays
    /// - Returns: Dictionary with dimension codes (R, I, A, S, E, C) and Float scores (0-5)
    static func calculateNormalized(from responses: [String: [String: Int]]) -> [String: Float] {
        var normalizedScores: [String: Float] = [:]

        // Map full dimension names to single-letter codes
        let dimensionMap: [String: String] = [
            "Realistic": "R",
            "Investigative": "I",
            "Artistic": "A",
            "Social": "S",
            "Enterprising": "E",
            "Conventional": "C"
        ]

        for (dimension, code) in dimensionMap {
            if let dimensionResponses = responses[dimension] {
                // Calculate average of all responses for this dimension
                let values = Array(dimensionResponses.values)
                guard !values.isEmpty else {
                    normalizedScores[code] = 0.0
                    continue
                }

                let sum = values.reduce(0, +)
                let average = Float(sum) / Float(values.count)
                normalizedScores[code] = average
            } else {
                // Default to 0 if no responses for this dimension
                normalizedScores[code] = 0.0
            }
        }

        return normalizedScores
    }

    /// Calculate normalized scores from flattened responses (UserDataKey format)
    /// - Parameter flatResponses: Dictionary with question strings as keys and ratings as values
    /// - Returns: Dictionary with dimension codes (R, I, A, S, E, C) and Float scores (0-5)
    static func calculateNormalizedFromFlat(from flatResponses: [String: Int]) -> [String: Float] {
        // Group responses by dimension based on question text matching
        var dimensionResponses: [String: [Int]] = [
            "R": [],
            "I": [],
            "A": [],
            "S": [],
            "E": [],
            "C": []
        ]

        // Map questions to dimensions by matching keywords
        for (question, rating) in flatResponses {
            let lowercased = question.lowercased()

            if lowercased.contains("hands") || lowercased.contains("tools") ||
               lowercased.contains("repair") || lowercased.contains("practical") ||
               lowercased.contains("build") || lowercased.contains("outdoors") {
                dimensionResponses["R"]?.append(rating)
            } else if lowercased.contains("puzzle") || lowercased.contains("analyze") ||
                      lowercased.contains("curious") || lowercased.contains("research") ||
                      lowercased.contains("data") || lowercased.contains("how things work") {
                dimensionResponses["I"]?.append(rating)
            } else if lowercased.contains("creative") || lowercased.contains("artistic") ||
                      lowercased.contains("express") || lowercased.contains("design") ||
                      lowercased.contains("music") || lowercased.contains("writing") {
                dimensionResponses["A"]?.append(rating)
            } else if lowercased.contains("help") || lowercased.contains("teach") ||
                      lowercased.contains("people") || lowercased.contains("team") ||
                      lowercased.contains("care") || lowercased.contains("understand") {
                dimensionResponses["S"]?.append(rating)
            } else if lowercased.contains("lead") || lowercased.contains("persuade") ||
                      lowercased.contains("business") || lowercased.contains("risk") ||
                      lowercased.contains("compete") || lowercased.contains("influence") {
                dimensionResponses["E"]?.append(rating)
            } else if lowercased.contains("organize") || lowercased.contains("rules") ||
                      lowercased.contains("detail") || lowercased.contains("structure") ||
                      lowercased.contains("record") || lowercased.contains("procedure") {
                dimensionResponses["C"]?.append(rating)
            }
        }

        // Calculate averages
        var normalizedScores: [String: Float] = [:]
        for (dimension, ratings) in dimensionResponses {
            if !ratings.isEmpty {
                let sum = ratings.reduce(0, +)
                let average = Float(sum) / Float(ratings.count)
                normalizedScores[dimension] = average
            } else {
                normalizedScores[dimension] = 0.0
            }
        }

        return normalizedScores
    }

    /// Calculate normalized scores from RIASECDimension-based structure
    /// - Parameter dimensionResponses: Dictionary with RIASECDimension keys and question-rating dictionaries
    /// - Returns: Dictionary with dimension codes (R, I, A, S, E, C) and Float scores (0-5)
    static func calculateNormalizedFromDimensions(from dimensionResponses: [RIASECDimension: [String: Int]]) -> [String: Float] {
        var normalizedScores: [String: Float] = [:]

        let dimensionMap: [RIASECDimension: String] = [
            .realistic: "R",
            .investigative: "I",
            .artistic: "A",
            .social: "S",
            .enterprising: "E",
            .conventional: "C"
        ]

        for dimension in RIASECDimension.allCases {
            if let responses = dimensionResponses[dimension], !responses.isEmpty {
                let sum = responses.values.reduce(0, +)
                let average = Float(sum) / Float(responses.count)
                normalizedScores[dimensionMap[dimension]!] = average
            } else {
                normalizedScores[dimensionMap[dimension]!] = 0.0
            }
        }

        return normalizedScores
    }
}