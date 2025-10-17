//
//  SnowflakeServiceTests.swift
//  carrerTests
//
//  Created for v5.0 Phase 0
//

import XCTest
@testable import carrer

/// Unit tests for SnowflakeService - API integration and data parsing
final class SnowflakeServiceTests: XCTestCase {

    var service: SnowflakeService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        service = SnowflakeService.shared
    }

    override func tearDownWithError() throws {
        service = nil
        try super.tearDownWithError()
    }

    // MARK: - Model Tests

    func testONetOccupationModel() throws {
        let occupation = ONetOccupation(
            onetSocCode: "15-1252.00",
            title: "Software Developers",
            description: "Research, design, and develop computer and network software",
            match: 92,
            education: "Bachelor's degree",
            outlook: "Much faster than average",
            salary: "$110,140",
            matchExplanation: "I:85% V:90% S:88% C:95%",
            interestsMatch: 0.85,
            valuesMatch: 0.90,
            skillsMatch: 0.88,
            contextScore: 0.95
        )

        XCTAssertEqual(occupation.id, "15-1252.00")
        XCTAssertEqual(occupation.title, "Software Developers")
        XCTAssertEqual(occupation.match, 92)
        XCTAssertEqual(occupation.matchPercentage, 92)
        XCTAssertEqual(occupation.interestsPercentage, 85)
        XCTAssertEqual(occupation.valuesPercentage, 90)
        XCTAssertEqual(occupation.skillsPercentage, 88)
        XCTAssertEqual(occupation.contextPercentage, 95)
    }

    func testONetOccupationMatchQuality() throws {
        let excellent = ONetOccupation(
            onetSocCode: "1",
            title: "Test",
            description: "Test",
            match: 95
        )
        XCTAssertEqual(excellent.matchQuality, "Excellent Match")

        let great = ONetOccupation(
            onetSocCode: "2",
            title: "Test",
            description: "Test",
            match: 85
        )
        XCTAssertEqual(great.matchQuality, "Great Match")

        let good = ONetOccupation(
            onetSocCode: "3",
            title: "Test",
            description: "Test",
            match: 75
        )
        XCTAssertEqual(good.matchQuality, "Good Match")

        let moderate = ONetOccupation(
            onetSocCode: "4",
            title: "Test",
            description: "Test",
            match: 65
        )
        XCTAssertEqual(moderate.matchQuality, "Moderate Match")

        let fair = ONetOccupation(
            onetSocCode: "5",
            title: "Test",
            description: "Test",
            match: 55
        )
        XCTAssertEqual(fair.matchQuality, "Fair Match")
    }

    func testONetOccupationShortDescription() throws {
        let shortDesc = ONetOccupation(
            onetSocCode: "1",
            title: "Test",
            description: "Short description",
            match: 80
        )
        XCTAssertEqual(shortDesc.shortDescription, "Short description")

        let longDesc = ONetOccupation(
            onetSocCode: "2",
            title: "Test",
            description: String(repeating: "a", count: 200),
            match: 80
        )
        XCTAssertEqual(longDesc.shortDescription.count, 153) // 150 + "..."
        XCTAssertTrue(longDesc.shortDescription.hasSuffix("..."))
    }

    // MARK: - Canadian Occupation Model Tests

    func testCanadianOccupationModel() throws {
        let canadianOcc = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers",
            nocCode: "21232",
            canadianTitle: "Software developers and programmers",
            canadianTitleFr: "Développeurs de logiciels et programmeurs",
            description: "Write, modify, integrate and test software code",
            descriptionFr: "Écrire, modifier, intégrer et tester du code logiciel",
            hollandCodes: "IRC",
            requirements: "Bachelor's degree • Professional license may be required",
            requirementsFr: "Baccalauréat • Permis professionnel peut être requis",
            exampleTitles: "application developer, software engineer, mobile app developer",
            exampleTitlesFr: "développeur d'applications, ingénieur logiciel",
            duties: "Maintain existing programs • Write documentation • Test software",
            dutiesFr: "Maintenir les programmes existants • Rédiger documentation",
            mappingConfidence: "HIGH"
        )

        XCTAssertTrue(canadianOcc.hasCanadianMapping)
        XCTAssertEqual(canadianOcc.nocCode, "21232")
        XCTAssertTrue(canadianOcc.supportsBilingual)
        XCTAssertEqual(canadianOcc.hollandCodesArray, ["I", "R", "C"])
        XCTAssertEqual(canadianOcc.confidenceColor, "green")
    }

    func testCanadianOccupationWithoutMapping() throws {
        let noMapping = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers"
        )

        XCTAssertFalse(noMapping.hasCanadianMapping)
        XCTAssertNil(noMapping.nocCode)
        XCTAssertNil(noMapping.canadianTitle)
    }

    func testCanadianOccupationParsing() throws {
        let occ = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers",
            requirements: "Bachelor's degree • 3 years experience • Professional certification",
            exampleTitles: "developer, programmer, software engineer",
            duties: "Write code • Test software • Debug applications"
        )

        // Test requirements parsing
        XCTAssertEqual(occ.requirementsArray.count, 3)
        XCTAssertTrue(occ.requirementsArray.contains("Bachelor's degree"))
        XCTAssertTrue(occ.requirementsArray.contains("3 years experience"))

        // Test titles parsing
        XCTAssertEqual(occ.exampleTitlesArray.count, 3)
        XCTAssertTrue(occ.exampleTitlesArray.contains("developer"))

        // Test duties parsing
        XCTAssertEqual(occ.dutiesArray.count, 3)
        XCTAssertTrue(occ.dutiesArray.contains("Write code"))
    }

    // MARK: - Match Tier Tests

    func testMatchTierFromScore() throws {
        XCTAssertEqual(MatchTier.from(score: 95), .high)
        XCTAssertEqual(MatchTier.from(score: 80), .high)
        XCTAssertEqual(MatchTier.from(score: 75), .medium)
        XCTAssertEqual(MatchTier.from(score: 70), .medium)
        XCTAssertEqual(MatchTier.from(score: 65), .low)
        XCTAssertEqual(MatchTier.from(score: 50), .low)
    }

    func testMatchTierLabels() throws {
        XCTAssertEqual(MatchTier.high.label, "High match")
        XCTAssertEqual(MatchTier.medium.label, "Medium match")
        XCTAssertEqual(MatchTier.low.label, "Low match")

        XCTAssertEqual(MatchTier.high.analyticsValue, "high")
        XCTAssertEqual(MatchTier.medium.analyticsValue, "medium")
        XCTAssertEqual(MatchTier.low.analyticsValue, "low")
    }

    // MARK: - Career Track Model Tests

    func testCareerTrackCreation() throws {
        let track = CareerTrack(
            title: "Software Developer",
            progress: 25,
            salary: "$80K-$120K",
            education: "Bachelor's",
            match: 92,
            onetCode: "15-1252.00"
        )

        XCTAssertEqual(track.title, "Software Developer")
        XCTAssertEqual(track.progress, 25)
        XCTAssertEqual(track.match, 92)
        XCTAssertEqual(track.matchTier, .high)
        XCTAssertTrue(track.hasONetData)
        XCTAssertFalse(track.isTracked)
    }

    func testCareerTrackFromONetOccupation() throws {
        let occupation = ONetOccupation(
            onetSocCode: "15-1252.00",
            title: "Software Developers",
            description: "Develop software",
            match: 88,
            education: "Bachelor's",
            salary: "$110,140"
        )

        let track = CareerTrack.from(onetOccupation: occupation, progress: 15)

        XCTAssertEqual(track.title, "Software Developers")
        XCTAssertEqual(track.match, 88)
        XCTAssertEqual(track.progress, 15)
        XCTAssertEqual(track.onetCode, "15-1252.00")
        XCTAssertEqual(track.education, "Bachelor's")
        XCTAssertEqual(track.salary, "$110,140")
        XCTAssertTrue(track.hasONetData)
    }

    func testCareerTrackTaskManagement() throws {
        var track = CareerTrack(
            title: "Software Developer",
            progress: 0,
            salary: "$80K",
            education: "BS",
            match: 90
        )

        let tasks = [
            TrackTask(title: "Complete coding bootcamp", isDone: true, category: .learning),
            TrackTask(title: "Build portfolio project", isDone: false, category: .project),
            TrackTask(title: "Apply to internships", isDone: false, category: .application)
        ]

        track.tasks = tasks

        XCTAssertEqual(track.totalTaskCount, 3)
        XCTAssertEqual(track.completedTaskCount, 1)
        XCTAssertEqual(track.trackProgress, 1.0 / 3.0, accuracy: 0.01)
        XCTAssertEqual(track.nextSteps.count, 2)
    }

    // MARK: - Mock Data Response Parsing Tests

    func testMockCareerMatchResponseParsing() throws {
        // Simulate JSON response from SP_GET_CAREER_MATCHES_V4
        let mockJSON = """
        [
            {
                "ONET_SOC_CODE": "15-1252.00",
                "JOB_TITLE": "Software Developers",
                "DESCRIPTION": "Research, design, and develop computer software",
                "INTERESTS_MATCH": 0.85,
                "VALUES_MATCH": 0.90,
                "SKILLS_MATCH": 0.88,
                "CONTEXT_SCORE": 0.95,
                "FINAL_SCORE": 6.2,
                "MATCH_EXPLANATION": "I:85% V:90% S:88% C:95%"
            }
        ]
        """

        let data = mockJSON.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]

        XCTAssertEqual(json.count, 1)
        let career = json[0]

        XCTAssertEqual(career["ONET_SOC_CODE"] as? String, "15-1252.00")
        XCTAssertEqual(career["JOB_TITLE"] as? String, "Software Developers")
        XCTAssertEqual(career["INTERESTS_MATCH"] as? Double, 0.85)
        XCTAssertEqual(career["FINAL_SCORE"] as? Double, 6.2)

        // Test score conversion (0-7 scale → 0-100%)
        let finalScore = career["FINAL_SCORE"] as! Double
        let matchPercentage = Int(finalScore * 100 / 7.0)
        XCTAssertEqual(matchPercentage, 88) // 6.2/7 * 100 ≈ 88%
    }

    // MARK: - Performance Tests

    func testOccupationModelCreationPerformance() throws {
        measure {
            for i in 1...1000 {
                _ = ONetOccupation(
                    onetSocCode: "15-1252.\(i % 100)",
                    title: "Career \(i)",
                    description: "Description for career \(i)",
                    match: Int.random(in: 60...100)
                )
            }
        }
    }

    func testCareerTrackFilteringPerformance() throws {
        var tracks: [CareerTrack] = []
        for i in 1...500 {
            tracks.append(CareerTrack(
                title: "Career \(i)",
                progress: Int.random(in: 0...100),
                salary: "$\(i * 1000)",
                education: "Bachelor's",
                match: Int.random(in: 50...100)
            ))
        }

        measure {
            let highMatches = tracks.filter { $0.matchTier == .high }
            let mediumMatches = tracks.filter { $0.matchTier == .medium }
            let lowMatches = tracks.filter { $0.matchTier == .low }

            _ = highMatches.count + mediumMatches.count + lowMatches.count
        }
    }

    // MARK: - Edge Case Tests

    func testOccupationWithNilValues() throws {
        let occupation = ONetOccupation(
            onetSocCode: "15-1252.00",
            title: "Software Developers",
            description: "Develop software",
            match: 85
        )

        XCTAssertNil(occupation.education)
        XCTAssertNil(occupation.salary)
        XCTAssertNil(occupation.matchExplanation)
        XCTAssertEqual(occupation.interestsPercentage, 0)
        XCTAssertEqual(occupation.valuesPercentage, 0)
    }

    func testCareerTrackWithEmptyTasks() throws {
        let track = CareerTrack(
            title: "Test",
            progress: 0,
            salary: "$50K",
            education: "BS",
            match: 80,
            tasks: []
        )

        XCTAssertEqual(track.trackProgress, 0.0)
        XCTAssertEqual(track.nextSteps.count, 0)
        XCTAssertEqual(track.completedTaskCount, 0)
    }

    func testCanadianOccupationEmptyStrings() throws {
        let occ = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Test",
            requirements: "",
            exampleTitles: "",
            duties: ""
        )

        XCTAssertTrue(occ.requirementsArray.isEmpty)
        XCTAssertTrue(occ.exampleTitlesArray.isEmpty)
        XCTAssertTrue(occ.dutiesArray.isEmpty)
    }
}

// MARK: - Mock Models for Testing

struct TrackTask: Codable, Identifiable {
    let id = UUID()
    let title: String
    var isDone: Bool
    let category: TaskCategory

    enum TaskCategory: String, Codable {
        case learning
        case project
        case networking
        case application
    }
}
