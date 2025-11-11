import Foundation
import SwiftUI

/// Service responsible for generating and refreshing career recommendations
class CareerRecommendationService {

    // MARK: - Properties

    private let snowflakeService: SnowflakeService
    private let getUserData: () -> [UserDataKey: AnyHashable]

    // MARK: - Initialization

    init(
        snowflakeService: SnowflakeService = .shared,
        getUserData: @escaping () -> [UserDataKey: AnyHashable]
    ) {
        self.snowflakeService = snowflakeService
        self.getUserData = getUserData
    }

    // MARK: - Public Methods

    /// Generate career suggestions based on user responses using O*NET data (Recipe D v4.0)
    func generateCareerRecommendations(
        for userCountry: UserCountry
    ) async throws -> (careers: [CareerTrack], riasecScores: [String: Float], canadianData: [String: CanadianOccupation]) {
        print("🚀 generateCareerRecommendations started - Recipe D v4.0 Multi-Dimensional Matching")

        let userData = getUserData()

        // Calculate RIASEC scores from user responses
        let riasecScores = calculateRIASECScores(from: userData)

        guard !riasecScores.isEmpty else {
            print("⚠️ No RIASEC scores available, falling back to sample data")
            let sampleTracks = generateSampleCareerTracks()
            return (careers: sampleTracks, riasecScores: [:], canadianData: [:])
        }

        print("📊 RIASEC Scores calculated:")
        for (dimension, score) in riasecScores.sorted(by: { $0.key < $1.key }) {
            print("  \(dimension): \(String(format: "%.2f", score))")
        }

        // Extract all Recipe D v4.0 parameters
        let parameters = extractRecommendationParameters(from: userData)

        print("\n🎯 Recipe D v4.0 Input Summary:")
        print("  RIASEC: \(riasecScores.count) dimensions")
        print("  Work Values: \(parameters.workValues?.count ?? 0) values")
        print("  Subjects: \(parameters.subjects?.count ?? 0)")
        print("  Activities: \(parameters.activities?.count ?? 0)")
        print("  Career Interests: \(parameters.careerInterests?.count ?? 0)")
        print("  Student Level: \(parameters.studentLevel ?? "not set")")
        print("  Current Status: \(parameters.currentStatus ?? "not set")")

        // Fetch career matches from Snowflake O*NET (Recipe D v4.0)
        let onetOccupations = try await snowflakeService.getCareerMatches(
            scores: riasecScores,
            workValues: parameters.workValues,
            subjects: parameters.subjects,
            activities: parameters.activities,
            careerInterests: parameters.careerInterests,
            studentLevel: parameters.studentLevel,
            currentStatus: parameters.currentStatus
        )

        print("✅ Received \(onetOccupations.count) O*NET career matches from Recipe D v4.0")

        // If user is Canadian, enrich with NOC data
        var canadianData: [String: CanadianOccupation] = [:]
        if userCountry.usesNOC {
            print("🇨🇦 Enriching careers with Canadian NOC context...")
            let onetCodes = onetOccupations.map { $0.onetSocCode }
            canadianData = try await snowflakeService.getCanadianOccupations(onetCodes: onetCodes)
            print("✅ Enriched \(canadianData.filter { $0.value.hasCanadianMapping }.count)/\(onetCodes.count) careers with Canadian data")
        }

        // Convert O*NET occupations to CareerTrack objects
        let careerTracks = onetOccupations.map { occupation in
            CareerTrack.from(onetOccupation: occupation, progress: 0)
        }

        print("✅ Recipe D v4.0 complete with \(careerTracks.count) multi-dimensional matches")

        return (careers: careerTracks, riasecScores: riasecScores, canadianData: canadianData)
    }

    /// Refresh career recommendations with updated career interests (Recipe D v4.0)
    func refreshRecommendationsWithInterests(
        _ updatedInterests: [String]
    ) async throws -> [CareerTrack] {
        print("🔄 Refreshing recommendations with updated interests - Recipe D v4.0")

        let userData = getUserData()

        // Use existing RIASEC scores
        let riasecScores = calculateRIASECScores(from: userData)

        guard !riasecScores.isEmpty else {
            print("⚠️ No RIASEC scores available")
            throw RecommendationError.noRIASECScores
        }

        // Extract existing parameters
        var parameters = extractRecommendationParameters(from: userData)

        // Use the UPDATED career interests
        parameters.careerInterests = updatedInterests.isEmpty ? nil : updatedInterests

        print("🔄 Updated interests: \(parameters.careerInterests?.joined(separator: ", ") ?? "none")")

        // Fetch updated career matches from Snowflake
        let onetOccupations = try await snowflakeService.getCareerMatches(
            scores: riasecScores,
            workValues: parameters.workValues,
            subjects: parameters.subjects,
            activities: parameters.activities,
            careerInterests: parameters.careerInterests,
            studentLevel: parameters.studentLevel,
            currentStatus: parameters.currentStatus
        )

        print("✅ Received \(onetOccupations.count) updated career matches")

        // Convert to CareerTrack objects
        let careerTracks = onetOccupations.map { occupation in
            CareerTrack.from(onetOccupation: occupation, progress: 0)
        }

        print("✅ Recommendations refreshed with updated interests")

        return careerTracks
    }

    // MARK: - Private Methods

    /// Calculate normalized RIASEC scores from user responses
    private func calculateRIASECScores(from userData: [UserDataKey: AnyHashable]) -> [String: Float] {
        // Try to get RIASEC responses from userData
        if let riasecResponses = userData[.riasecResponses] as? [String: [String: Int]] {
            // Use structured responses
            return RIASECScoreCalculator.calculateNormalized(from: riasecResponses)
        } else if let flatResponses = userData[.riasecResponsesFlat] as? [String: Int] {
            // Use flattened responses
            return RIASECScoreCalculator.calculateNormalizedFromFlat(from: flatResponses)
        } else {
            print("⚠️ No RIASEC responses found in userData")
            return [:]
        }
    }

    /// Extract all recommendation parameters from user data
    private func extractRecommendationParameters(from userData: [UserDataKey: AnyHashable]) -> RecommendationParameters {
        var parameters = RecommendationParameters()

        // Extract work values (Recipe C v3.0)
        if let workValuesData = userData[.workValues] as? [String: Double] {
            parameters.workValues = [
                "achievement": Float(workValuesData["achievement"] ?? 3.0),
                "independence": Float(workValuesData["independence"] ?? 3.0),
                "recognition": Float(workValuesData["recognition"] ?? 3.0),
                "relationships": Float(workValuesData["relationships"] ?? 3.0),
                "support": Float(workValuesData["support"] ?? 3.0),
                "working_conditions": Float(workValuesData["working_conditions"] ?? 3.0)
            ]

            print("📊 Work Values extracted:")
            for (value, score) in parameters.workValues!.sorted(by: { $0.key < $1.key }) {
                print("  \(value): \(String(format: "%.2f", score))")
            }
        } else {
            print("ℹ️ No work values provided, using defaults (3.0 = moderate importance)")
        }

        // Extract subjects
        if let subjectsSet = userData[.favoriteSubjects] as? Set<SchoolSubject> {
            parameters.subjects = subjectsSet.map { $0.name }
            print("📚 Subjects extracted: \(parameters.subjects!.joined(separator: ", "))")
        }

        // Extract activities
        if let activitiesSet = userData[.extracurriculars] as? Set<Activity> {
            parameters.activities = activitiesSet.map { $0.name }
            print("🎭 Activities extracted: \(parameters.activities!.joined(separator: ", "))")
        }

        // Extract career interests
        if let interestsSet = userData[.careerInterests] as? Set<String> {
            parameters.careerInterests = Array(interestsSet)
            print("💼 Career Interests extracted: \(parameters.careerInterests!.joined(separator: ", "))")
        }

        // Extract student level
        parameters.studentLevel = userData[.studentLevel] as? String
        if let level = parameters.studentLevel {
            print("🎓 Student Level: \(level)")
        }

        // Extract current status
        if let status = userData[.currentStatus] as? SelectionOption {
            parameters.currentStatus = status.title
            print("👤 Current Status: \(status.title)")
        }

        return parameters
    }

    /// Generate sample career tracks as fallback
    private func generateSampleCareerTracks() -> [CareerTrack] {
        let sampleTracks = [
            CareerTrack(
                title: "Software Developer",
                progress: 0,
                salary: "$70,000 - $120,000",
                education: "Bachelor's Degree",
                match: 95
            ),
            CareerTrack(
                title: "UX/UI Designer",
                progress: 0,
                salary: "$65,000 - $110,000",
                education: "Bachelor's Degree",
                match: 87
            ),
            CareerTrack(
                title: "Data Scientist",
                progress: 0,
                salary: "$80,000 - $130,000",
                education: "Master's Degree",
                match: 82
            )
        ]

        print("⚠️ Using sample career tracks (Snowflake unavailable)")
        return sampleTracks
    }
}

// MARK: - Supporting Types

/// Container for recommendation parameters
private struct RecommendationParameters {
    var workValues: [String: Float]? = nil
    var subjects: [String]? = nil
    var activities: [String]? = nil
    var careerInterests: [String]? = nil
    var studentLevel: String? = nil
    var currentStatus: String? = nil
}

/// Errors that can occur during recommendation generation
enum RecommendationError: Error {
    case noRIASECScores
    case snowflakeUnavailable
    case invalidParameters

    var localizedDescription: String {
        switch self {
        case .noRIASECScores:
            return "No RIASEC scores available for career matching"
        case .snowflakeUnavailable:
            return "Unable to connect to career database"
        case .invalidParameters:
            return "Invalid parameters provided for career matching"
        }
    }
}
