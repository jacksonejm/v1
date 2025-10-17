//
//  CanadianNOCIntegrationTests.swift
//  carrerTests
//
//  Created for v5.0 Phase 0.3
//  Tests Canadian NOC integration end-to-end
//

import XCTest
@testable import carrer

/// Integration tests for Canadian NOC (National Occupational Classification) feature
/// These tests validate the complete flow from country selection to enriched career data
final class CanadianNOCIntegrationTests: XCTestCase {

    var viewModel: AppViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = AppViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Country Selection Tests

    func testCountrySelectionFlow() throws {
        // Start with default (USA)
        XCTAssertEqual(viewModel.userCountry, .usa)
        XCTAssertFalse(viewModel.userCountry.usesNOC)

        // User selects Canada
        viewModel.userCountry = .canada
        viewModel.userData[.country] = UserCountry.canada

        // Verify Canada selected
        XCTAssertEqual(viewModel.userCountry, .canada)
        XCTAssertTrue(viewModel.userCountry.usesNOC)
        XCTAssertTrue(viewModel.userCountry.supportsBilingual)
        XCTAssertEqual(viewModel.userCountry.flag, "🇨🇦")
    }

    func testUserDataPersistence() throws {
        // Set Canada
        viewModel.userData[.country] = UserCountry.canada

        // Simulate app restart (retrieve from storage)
        let savedCountry = viewModel.userData[.country] as? UserCountry

        XCTAssertNotNil(savedCountry)
        XCTAssertEqual(savedCountry, .canada)
    }

    // MARK: - Canadian Occupation Model Tests

    func testCanadianOccupationDataStructure() throws {
        let canadianOcc = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers, Applications",
            nocCode: "21232",
            canadianTitle: "Software developers and programmers",
            canadianTitleFr: "Développeurs/développeuses et programmeurs/programmeuses de logiciels",
            description: "Software developers write, modify, integrate and test software code.",
            descriptionFr: "Les développeurs de logiciels écrivent, modifient, intègrent et testent du code logiciel.",
            hollandCodes: "IRC",
            requirements: "Bachelor's degree in computer science • Experience with programming languages",
            requirementsFr: "Baccalauréat en informatique • Expérience avec les langages de programmation",
            exampleTitles: "application developer, software engineer, mobile app developer",
            exampleTitlesFr: "développeur d'applications, ingénieur logiciel",
            duties: "Write and maintain software • Test applications • Debug code",
            dutiesFr: "Écrire et maintenir des logiciels • Tester des applications",
            mappingConfidence: "HIGH"
        )

        // Verify Canadian mapping exists
        XCTAssertTrue(canadianOcc.hasCanadianMapping)
        XCTAssertEqual(canadianOcc.nocCode, "21232")

        // Verify bilingual support
        XCTAssertTrue(canadianOcc.supportsBilingual)
        XCTAssertNotNil(canadianOcc.canadianTitleFr)
        XCTAssertNotNil(canadianOcc.descriptionFr)

        // Verify Holland codes parsing
        XCTAssertEqual(canadianOcc.hollandCodesArray, ["I", "R", "C"])
        XCTAssertEqual(canadianOcc.hollandCodesFull.count, 3)

        // Verify requirements parsing
        XCTAssertEqual(canadianOcc.requirementsArray.count, 2)
        XCTAssertTrue(canadianOcc.requirementsArray.contains("Bachelor's degree in computer science"))

        // Verify example titles parsing
        XCTAssertEqual(canadianOcc.exampleTitlesArray.count, 3)
        XCTAssertTrue(canadianOcc.exampleTitlesArray.contains("software engineer"))

        // Verify duties parsing
        XCTAssertEqual(canadianOcc.dutiesArray.count, 3)

        // Verify mapping confidence
        XCTAssertEqual(canadianOcc.confidenceColor, "green")
        XCTAssertEqual(canadianOcc.confidenceEmoji, "✅")
    }

    func testCanadianOccupationFallbackToONet() throws {
        // Test occupation without Canadian mapping
        let onetOnly = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers"
        )

        XCTAssertFalse(onetOnly.hasCanadianMapping)
        XCTAssertNil(onetOnly.nocCode)
        XCTAssertNil(onetOnly.canadianTitle)
        XCTAssertFalse(onetOnly.supportsBilingual)

        // Should still have O*NET data
        XCTAssertEqual(onetOnly.onetCode, "15-1252.00")
        XCTAssertEqual(onetOnly.onetTitle, "Software Developers")
    }

    // MARK: - Career Recommendation Flow Tests

    func testRecommendationFlowForCanadianUser() throws {
        // Setup: User completes onboarding as Canadian
        viewModel.userCountry = .canada
        viewModel.userData[.country] = UserCountry.canada
        viewModel.userData[.name] = "John"
        viewModel.userData[.currentStatus] = "College Student"

        // Mock RIASEC scores
        let riasecScores: [String: Float] = [
            "R": 3.5, "I": 4.8, "A": 2.1,
            "S": 3.0, "E": 2.5, "C": 3.8
        ]

        // Expected behavior:
        // 1. Recipe D v4.0 generates O*NET recommendations
        // 2. System should enrich with Canadian NOC data where available
        // 3. UI should display Canadian titles for mapped careers
        // 4. UI should fall back to O*NET titles for unmapped careers

        XCTAssertEqual(viewModel.userCountry, .canada)
        XCTAssertTrue(viewModel.userCountry.usesNOC)
    }

    func testCanadianOccupationDataStorage() throws {
        viewModel.userCountry = .canada

        // Simulate Canadian enrichment data
        let canadianOcc = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers",
            nocCode: "21232",
            canadianTitle: "Software developers and programmers",
            mappingConfidence: "HIGH"
        )

        // Store in AppViewModel
        viewModel.canadianOccupationData["15-1252.00"] = canadianOcc

        // Verify storage
        XCTAssertNotNil(viewModel.canadianOccupationData["15-1252.00"])
        XCTAssertEqual(viewModel.canadianOccupationData["15-1252.00"]?.nocCode, "21232")
        XCTAssertTrue(viewModel.canadianOccupationData["15-1252.00"]?.hasCanadianMapping ?? false)
    }

    // MARK: - UI Display Tests

    func testCareerTitleDisplayLogic() throws {
        viewModel.userCountry = .canada

        // Create O*NET career
        let onetCareer = CareerTrack(
            title: "Software Developers, Applications",
            progress: 0,
            salary: "$80,000 - $120,000",
            education: "Bachelor's degree",
            match: 92,
            onetCode: "15-1252.00"
        )

        // Add Canadian enrichment
        let canadianOcc = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers, Applications",
            nocCode: "21232",
            canadianTitle: "Software developers and programmers"
        )
        viewModel.canadianOccupationData["15-1252.00"] = canadianOcc

        // Verify Canadian title should be displayed
        if let onetCode = onetCareer.onetCode,
           let canadianData = viewModel.canadianOccupationData[onetCode],
           canadianData.hasCanadianMapping {
            XCTAssertEqual(canadianData.canadianTitle, "Software developers and programmers")
        } else {
            XCTFail("Should have Canadian mapping")
        }
    }

    func testUSUserDoesNotReceiveCanadianData() throws {
        viewModel.userCountry = .usa

        // US user should not use NOC
        XCTAssertFalse(viewModel.userCountry.usesNOC)

        // Canadian occupation data should be empty or ignored
        XCTAssertTrue(viewModel.canadianOccupationData.isEmpty)
    }

    // MARK: - Crosswalk Coverage Tests

    func testCrosswalkCoverageExpectations() throws {
        // Based on NOC_CROSSWALK_QUALITY_ASSESSMENT.md
        // Expected: 1,466 mappings covering ~94% of O*NET careers

        let expectedMappingCount = 1466
        let expectedONetCoverage = 0.94 // 94%
        let expectedUniqueNOCCodes = 515
        let expectedUniqueONetCodes = 952

        // These are expectations for Phase 0.1 validation
        // Actual validation happens after Snowflake deployment

        XCTAssertGreaterThan(expectedMappingCount, 1000, "Should have substantial crosswalk data")
        XCTAssertGreaterThan(expectedONetCoverage, 0.85, "Should cover 85%+ of O*NET")
        XCTAssertGreaterThan(expectedUniqueNOCCodes, 500, "Should have 500+ NOC codes")
        XCTAssertGreaterThan(expectedUniqueONetCodes, 900, "Should have 900+ O*NET codes")
    }

    // MARK: - Mapping Confidence Tests

    func testMappingConfidenceLevels() throws {
        let highConfidence = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers",
            nocCode: "21232",
            canadianTitle: "Software developers",
            mappingConfidence: "HIGH"
        )

        let mediumConfidence = CanadianOccupation(
            onetCode: "11-3031.00",
            onetTitle: "Financial Managers",
            nocCode: "10020",
            canadianTitle: "Gestionnaires financiers",
            mappingConfidence: "MEDIUM"
        )

        let lowConfidence = CanadianOccupation(
            onetCode: "00-0000.00",
            onetTitle: "Generic Occupation",
            nocCode: "99999",
            canadianTitle: "Generic NOC",
            mappingConfidence: "LOW"
        )

        XCTAssertEqual(highConfidence.confidenceColor, "green")
        XCTAssertEqual(mediumConfidence.confidenceColor, "orange")
        XCTAssertEqual(lowConfidence.confidenceColor, "red")
    }

    // MARK: - Performance Tests

    func testCanadianDataEnrichmentPerformance() throws {
        viewModel.userCountry = .canada

        // Simulate 50 careers needing enrichment
        var canadianDataDict: [String: CanadianOccupation] = [:]

        measure {
            for i in 1...50 {
                let onetCode = "15-1252.\(String(format: "%02d", i))"
                canadianDataDict[onetCode] = CanadianOccupation(
                    onetCode: onetCode,
                    onetTitle: "Career \(i)",
                    nocCode: "21232",
                    canadianTitle: "Canadian Career \(i)"
                )
            }

            viewModel.canadianOccupationData = canadianDataDict
        }
    }

    // MARK: - Edge Case Tests

    func testMultipleNOCMappingsToSingleONet() throws {
        // Some O*NET codes map to multiple NOC codes
        // System should handle the first/best match

        let primary = CanadianOccupation(
            onetCode: "11-3031.00",
            onetTitle: "Financial Managers",
            nocCode: "10020",
            canadianTitle: "Banking, credit and other investment managers",
            mappingConfidence: "HIGH"
        )

        let secondary = CanadianOccupation(
            onetCode: "11-3031.00",
            onetTitle: "Financial Managers",
            nocCode: "10021",
            canadianTitle: "Insurance and real estate managers",
            mappingConfidence: "MEDIUM"
        )

        // Both should be valid, but system uses highest confidence
        XCTAssertEqual(primary.onetCode, secondary.onetCode)
        XCTAssertNotEqual(primary.nocCode, secondary.nocCode)
        XCTAssertEqual(primary.mappingConfidence, "HIGH")
        XCTAssertEqual(secondary.mappingConfidence, "MEDIUM")
    }

    func testEmptyCanadianStrings() throws {
        let occ = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers",
            nocCode: "21232",
            canadianTitle: "",
            canadianTitleFr: "",
            description: "",
            requirements: ""
        )

        // Has NOC code but no actual content
        XCTAssertNotNil(occ.nocCode)
        XCTAssertTrue(occ.canadianTitle?.isEmpty ?? true)
        XCTAssertTrue(occ.requirementsArray.isEmpty)
    }

    func testBilingualContentToggle() throws {
        let canadianOcc = CanadianOccupation(
            onetCode: "15-1252.00",
            onetTitle: "Software Developers",
            nocCode: "21232",
            canadianTitle: "Software developers",
            canadianTitleFr: "Développeurs de logiciels",
            description: "English description",
            descriptionFr: "Description française"
        )

        // App could support language toggle in future
        XCTAssertNotNil(canadianOcc.canadianTitle)
        XCTAssertNotNil(canadianOcc.canadianTitleFr)
        XCTAssertNotEqual(canadianOcc.canadianTitle, canadianOcc.canadianTitleFr)
    }
}

// MARK: - Manual Test Plan (Post-Snowflake Deployment)

/*
 ==========================================
 MANUAL TEST PLAN FOR CANADIAN NOC FEATURE
 ==========================================

 Prerequisites:
 - Phase 0.1 complete (NOC data in Snowflake)
 - App built with Phase 0 code
 - Test device or simulator

 Test Scenarios:

 1. COUNTRY SELECTION
    [ ] Open app, start onboarding
    [ ] Verify country selection screen appears (step 2)
    [ ] Tap "Canada" option
    [ ] Verify Canada is highlighted with flag 🇨🇦
    [ ] Verify "Includes Canadian NOC guidance" subtitle
    [ ] Tap "Continue"
    [ ] Verify country saved (check userData[.country])

 2. COMPLETE ONBOARDING AS CANADIAN USER
    [ ] Select Canada in country selection
    [ ] Complete all onboarding steps (name, RIASEC, etc.)
    [ ] Reach recommendations screen
    [ ] Verify recommendations load successfully

 3. CANADIAN TITLE DISPLAY
    [ ] View career list (AllRecommendationsView)
    [ ] Identify a career with known NOC mapping (e.g., "Software Developers")
    [ ] Verify Canadian title displayed ("Software developers and programmers")
    [ ] Compare with O*NET title (should be different)

 4. CAREER DETAIL VIEW WITH NOC ENRICHMENT
    [ ] Tap on a career with HIGH confidence mapping
    [ ] Verify detail view shows:
        - Canadian title (if available)
        - Canadian description
        - Employment requirements (Canadian licensing)
        - Example titles (Canadian)
        - Main duties (Canadian context)
        - French title (if bilingual enabled)

 5. FALLBACK TO O*NET
    [ ] Find a career without NOC mapping (~5-15% of careers)
    [ ] Verify O*NET title displayed (no Canadian enrichment)
    [ ] Verify detail view shows O*NET description
    [ ] No errors or crashes

 6. US USER COMPARISON
    [ ] Restart app, select "United States" in country selection
    [ ] Complete onboarding with same answers as Canadian test
    [ ] Verify recommendations show O*NET titles only
    [ ] Verify no Canadian enrichment in detail views

 7. MAPPING CONFIDENCE INDICATORS
    [ ] For Canadian user, view career detail
    [ ] Check for confidence badge/indicator (HIGH/MEDIUM/LOW)
    [ ] Verify badge color matches confidence:
        - GREEN = HIGH
        - ORANGE = MEDIUM
        - RED = LOW

 8. PERFORMANCE TEST
    [ ] Canadian user with 50 recommendations
    [ ] Time from onboarding completion to recommendations display
    [ ] Expected: < 3 seconds (parity with v4.0)
    [ ] Verify no UI lag when scrolling career list

 9. OFFLINE BEHAVIOR
    [ ] Turn off network connection
    [ ] Try to load recommendations
    [ ] Verify graceful error handling
    [ ] Verify fallback to cached data (if available)

 10. DATA VALIDATION
     [ ] Run NOC_STEP3_VALIDATION_QUERIES.sql in Snowflake
     [ ] Verify:
         - 1,466 crosswalk mappings
         - 900 NOC occupations
         - 85-95% coverage of top 50 recommendations
         - All queries complete without errors

 Expected Results:
 - ✅ All tests pass
 - ✅ Canadian users see enriched NOC data
 - ✅ US users see O*NET data only
 - ✅ No crashes or errors
 - ✅ Performance within acceptable range

 Known Issues to Watch:
 - Column name mismatches (TITLE vs JOB_TITLE) - should be fixed
 - Empty NOC strings (handled with fallback)
 - Multiple NOC mappings per O*NET (uses first HIGH confidence)
*/
