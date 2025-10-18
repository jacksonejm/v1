//
//  AppViewModelTests.swift
//  carrerTests
//
//  Created for v5.0 Phase 0
//

import XCTest
@testable import carrer

/// Unit tests for AppViewModel - core business logic and state management
final class AppViewModelTests: XCTestCase {

    var viewModel: AppViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = AppViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Initialization Tests

    func testInitialState() throws {
        XCTAssertEqual(viewModel.userCountry, .usa, "Default country should be USA")
        XCTAssertTrue(viewModel.userData.isEmpty, "User data should be empty on init")
        XCTAssertTrue(viewModel.careerTracks.isEmpty, "Career tracks should be empty on init")
        XCTAssertEqual(viewModel.appFlowState, .initial, "App should start in initial state")
    }

    // MARK: - User Data Tests

    func testSetUserData() throws {
        // Test setting string data
        viewModel.userData[.name] = "John Doe"
        XCTAssertEqual(viewModel.userData[.name] as? String, "John Doe")

        // Test setting country
        viewModel.userData[.country] = UserCountry.canada
        XCTAssertEqual(viewModel.userData[.country] as? UserCountry, .canada)

        // Test setting array data
        let subjects: Set<String> = ["Math", "Science", "Art"]
        viewModel.userData[.favoriteSubjects] = subjects
        XCTAssertEqual(viewModel.userData[.favoriteSubjects] as? Set<String>, subjects)
    }

    func testUserCountryChange() throws {
        XCTAssertEqual(viewModel.userCountry, .usa)

        viewModel.userCountry = .canada
        XCTAssertEqual(viewModel.userCountry, .canada)
        XCTAssertTrue(viewModel.userCountry.usesNOC)

        viewModel.userCountry = .usa
        XCTAssertFalse(viewModel.userCountry.usesNOC)
    }

    // MARK: - RIASEC Data Storage Tests

    func testRIASECResponsesStorage() throws {
        // Test storing RIASEC responses (flattened format)
        let responses: [String: Int] = [
            "work_with_hands": 5,
            "operate_machinery": 4,
            "build_things": 5,
            "analyze_data": 3,
            "conduct_research": 2,
            "creative_projects": 4
        ]

        viewModel.userData[.riasecResponsesFlat] = responses

        // Verify storage
        let storedResponses = viewModel.userData[.riasecResponsesFlat] as? [String: Int]
        XCTAssertNotNil(storedResponses)
        XCTAssertEqual(storedResponses?["work_with_hands"], 5)
        XCTAssertEqual(storedResponses?["creative_projects"], 4)
        XCTAssertEqual(storedResponses?.count, 6)
    }

    func testUpdateRIASECResponses() throws {
        // Test dimension-specific RIASEC storage
        let realisticResponses: [String: Int] = [
            "work_with_hands": 5,
            "operate_machinery": 4,
            "build_things": 5
        ]

        viewModel.updateRIASECResponses(dimension: .realistic, responses: realisticResponses)

        // Verify flattened responses were updated
        let flatResponses = viewModel.userData[.riasecResponsesFlat] as? [String: Int]
        XCTAssertNotNil(flatResponses)
        XCTAssertEqual(flatResponses?["work_with_hands"], 5)
        XCTAssertEqual(flatResponses?["operate_machinery"], 4)

        // Verify dimension-specific responses were stored
        if let allResponses = viewModel.userData[.riasecResponses] as? [String: [String: Int]],
           let realisticData = allResponses["R"] {
            XCTAssertEqual(realisticData.count, 3)
        } else {
            XCTFail("RIASEC responses not stored correctly")
        }
    }

    // MARK: - Onboarding Navigation Tests

    func testOnboardingStepProgression() throws {
        viewModel.appFlowState = .onboarding(step: .howDidYouHearAboutUs)

        // Set required data for first step
        viewModel.userData[.howDidYouHearAboutUs] = "Friend"

        // Move to next step
        viewModel.nextOnboardingStep()

        // Should advance to country selection
        if case .onboarding(let step) = viewModel.appFlowState {
            XCTAssertTrue(step.matchesWithoutData(.countrySelection))
        } else {
            XCTFail("Should be in onboarding state")
        }
    }

    func testOnboardingStepBackNavigation() throws {
        viewModel.appFlowState = .onboarding(step: .getName)

        viewModel.previousOnboardingStep()

        // Should go back to country selection
        if case .onboarding(let step) = viewModel.appFlowState {
            XCTAssertTrue(step.matchesWithoutData(.countrySelection))
        } else {
            XCTFail("Should be in onboarding state")
        }
    }

    // MARK: - Career Track Tests

    func testAddCareerTrack() throws {
        let career = CareerTrack(
            title: "Software Developer",
            progress: 0,
            salary: "$80,000 - $120,000",
            education: "Bachelor's degree",
            match: 92,
            onetCode: "15-1252.00"
        )

        XCTAssertTrue(viewModel.careerTracks.isEmpty)

        viewModel.careerTracks.append(career)

        XCTAssertEqual(viewModel.careerTracks.count, 1)
        XCTAssertEqual(viewModel.careerTracks.first?.title, "Software Developer")
        XCTAssertEqual(viewModel.careerTracks.first?.match, 92)
    }

    func testRemoveCareerTrack() throws {
        let career1 = CareerTrack(
            title: "Software Developer",
            progress: 0,
            salary: "$80,000 - $120,000",
            education: "Bachelor's degree",
            match: 92
        )

        let career2 = CareerTrack(
            title: "Data Analyst",
            progress: 0,
            salary: "$60,000 - $90,000",
            education: "Bachelor's degree",
            match: 88
        )

        viewModel.careerTracks = [career1, career2]
        XCTAssertEqual(viewModel.careerTracks.count, 2)

        viewModel.careerTracks.removeAll { $0.id == career1.id }

        XCTAssertEqual(viewModel.careerTracks.count, 1)
        XCTAssertEqual(viewModel.careerTracks.first?.title, "Data Analyst")
    }

    // MARK: - Match Tier Tests

    func testMatchTierClassification() throws {
        let highMatch = CareerTrack(title: "Test", progress: 0, salary: "$50K", education: "BS", match: 92)
        XCTAssertEqual(highMatch.matchTier, .high)

        let mediumMatch = CareerTrack(title: "Test", progress: 0, salary: "$50K", education: "BS", match: 75)
        XCTAssertEqual(mediumMatch.matchTier, .medium)

        let lowMatch = CareerTrack(title: "Test", progress: 0, salary: "$50K", education: "BS", match: 65)
        XCTAssertEqual(lowMatch.matchTier, .low)
    }

    // MARK: - App Flow State Tests

    func testAppFlowStateTransitions() throws {
        // Start at initial
        XCTAssertEqual(viewModel.appFlowState, .initial)

        // Navigate to onboarding
        viewModel.appFlowState = .onboarding(step: .howDidYouHearAboutUs)
        if case .onboarding = viewModel.appFlowState {
            // Success
        } else {
            XCTFail("Should be in onboarding state")
        }

        // Complete onboarding and go to dashboard
        viewModel.navigateTo(.dashboard)
        XCTAssertEqual(viewModel.appFlowState, .dashboard)
    }

    // MARK: - Data Validation Tests

    func testValidateOnboardingData() throws {
        // Empty data should not be valid
        XCTAssertFalse(viewModel.hasCompletedOnboarding())

        // Add required data
        viewModel.userData[.name] = "John"
        viewModel.userData[.country] = UserCountry.usa
        viewModel.userData[.currentStatus] = "Student"
        viewModel.userData[.studentLevel] = "College Junior"

        // Mock RIASEC responses
        let responses: [String: Int] = [
            "q1": 5, "q2": 4, "q3": 5, "q4": 3, "q5": 5, "q6": 4,
            "q7": 2, "q8": 3, "q9": 2, "q10": 4, "q11": 3, "q12": 2,
            "q13": 4, "q14": 5, "q15": 4, "q16": 3, "q17": 4, "q18": 5,
            "q19": 5, "q20": 4, "q21": 5, "q22": 3, "q23": 4, "q24": 5,
            "q25": 3, "q26": 4, "q27": 3, "q28": 5, "q29": 4, "q30": 3,
            "q31": 2, "q32": 3, "q33": 2, "q34": 4, "q35": 3, "q36": 2
        ]
        viewModel.userData[.riasecResponsesFlat] = responses

        // Should now be valid
        XCTAssertTrue(viewModel.hasCompletedOnboarding())
    }

    // MARK: - Performance Tests

    func testRIASECDataStoragePerformance() throws {
        // Prepare large response set
        var responses: [String: Int] = [:]
        for i in 1...100 {
            responses["q\(i)"] = Int.random(in: 1...5)
        }

        measure {
            viewModel.userData[.riasecResponsesFlat] = responses

            // Verify storage
            let stored = viewModel.userData[.riasecResponsesFlat] as? [String: Int]
            XCTAssertNotNil(stored)
        }
    }

    func testCareerTrackManipulationPerformance() throws {
        var tracks: [CareerTrack] = []
        for i in 1...100 {
            tracks.append(CareerTrack(
                title: "Career \(i)",
                progress: 0,
                salary: "$50K",
                education: "BS",
                match: Int.random(in: 60...100)
            ))
        }

        measure {
            viewModel.careerTracks = tracks
            _ = viewModel.careerTracks.filter { $0.match >= 80 }
            viewModel.careerTracks.removeAll()
        }
    }
}

// MARK: - Helper Extensions for Testing

extension AppViewModel {
    /// Check if onboarding is complete (simplified for testing)
    func hasCompletedOnboarding() -> Bool {
        guard userData[.name] != nil,
              userData[.country] != nil,
              userData[.currentStatus] != nil,
              userData[.studentLevel] != nil,
              let riasecResponses = userData[.riasecResponsesFlat] as? [String: Int],
              riasecResponses.count >= 36 else {
            return false
        }
        return true
    }
}
