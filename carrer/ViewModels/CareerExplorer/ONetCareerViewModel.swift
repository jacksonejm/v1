import Foundation
import SwiftUI

/// ViewModel for managing O*NET career data and interactions
@MainActor
class ONetCareerViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var occupations: [ONetOccupation] = []
    @Published var selectedOccupation: ONetOccupation?
    @Published var skills: [CareerSkill] = []
    @Published var jobSearchStrategy: JobSearchStrategy?
    @Published var isLoadingMatches = false
    @Published var isLoadingSkills = false
    @Published var isLoadingJobSearch = false
    @Published var error: Error?
    @Published var lastRIASECScores: [String: Float]?

    // MARK: - Private Properties
    private let snowflakeService = SnowflakeService.shared

    // MARK: - Public Methods

    /// Fetch career matches based on RIASEC scores
    /// - Parameter scores: Dictionary with keys R, I, A, S, E, C and Float values (0-5 scale)
    func fetchCareerMatches(scores: [String: Float]) async {
        isLoadingMatches = true
        error = nil
        lastRIASECScores = scores

        do {
            let matches = try await snowflakeService.getCareerMatches(scores: scores)
            occupations = matches
            print("✅ Fetched \(matches.count) O*NET career matches")
        } catch {
            self.error = error
            print("❌ Error fetching career matches: \(error.localizedDescription)")
        }

        isLoadingMatches = false
    }

    /// Fetch detailed skills for a specific occupation
    /// - Parameter occupationCode: O*NET SOC code
    func fetchCareerSkills(occupationCode: String) async {
        isLoadingSkills = true
        error = nil

        do {
            let fetchedSkills = try await snowflakeService.getCareerSkills(occupationCode: occupationCode)
            skills = fetchedSkills
            print("✅ Fetched \(fetchedSkills.count) skills for \(occupationCode)")
        } catch {
            self.error = error
            print("❌ Error fetching skills: \(error.localizedDescription)")
        }

        isLoadingSkills = false
    }

    /// Fetch job search strategy for a specific occupation
    /// - Parameter occupationCode: O*NET SOC code
    func fetchJobSearchStrategy(occupationCode: String) async {
        isLoadingJobSearch = true
        error = nil

        do {
            let strategy = try await snowflakeService.getJobSearchStrategy(occupationCode: occupationCode)
            jobSearchStrategy = strategy
            print("✅ Fetched job search strategy for \(occupationCode)")
        } catch {
            self.error = error
            print("❌ Error fetching job search strategy: \(error.localizedDescription)")
        }

        isLoadingJobSearch = false
    }

    /// Select an occupation and fetch its details
    /// - Parameter occupation: The occupation to select
    func selectOccupation(_ occupation: ONetOccupation) async {
        selectedOccupation = occupation

        // Fetch skills and job search strategy in parallel
        async let skillsTask = fetchCareerSkills(occupationCode: occupation.code)
        async let jobSearchTask = fetchJobSearchStrategy(occupationCode: occupation.code)

        await skillsTask
        await jobSearchTask
    }

    /// Clear all data
    func clearData() {
        occupations = []
        selectedOccupation = nil
        skills = []
        jobSearchStrategy = nil
        error = nil
    }

    /// Get top N occupations
    func topOccupations(limit: Int = 10) -> [ONetOccupation] {
        Array(occupations.prefix(limit))
    }

    /// Check if we have career matches loaded
    var hasMatches: Bool {
        !occupations.isEmpty
    }

    /// Get error message for display
    var errorMessage: String? {
        error?.localizedDescription
    }
}
