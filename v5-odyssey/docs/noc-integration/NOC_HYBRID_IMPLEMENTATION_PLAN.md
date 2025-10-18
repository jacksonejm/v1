# MyPath Canadian Support - Hybrid Approach Implementation Plan
## O*NET Matching + NOC Display Layer

**Version:** 2.0 (Revised)
**Date:** 2025-10-12
**Status:** ✅ APPROVED - Ready for Implementation
**Git Backup:** Commit `15dc0c3`

---

## Executive Summary

**Approach:** Match using O*NET data (100% accuracy), display using NOC context (94% coverage)

**Timeline:** 3-4 weeks to production
**Complexity:** Low-Medium (simpler than original parallel tables)
**Quality:** No degradation (100% match effectiveness + 94% Canadian context)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Canadian User Flow                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: Match using O*NET (Recipe D v4.0)                  │
│  - CAREER_FULL_VECTORS table (existing)                     │
│  - SP_GET_CAREER_MATCHES_V4 (no changes!)                   │
│  - Returns: 50 O*NET careers with match scores              │
│  Quality: ✅ 100% (same as U.S. users)                      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: Map O*NET → NOC via Crosswalk                      │
│  - NOC_ONET_CROSSWALK table (new, 1,466 rows)              │
│  - Simple JOIN on O*NET code                                 │
│  - Returns: NOC codes for 94% of matches                     │
│  Coverage: ✅ 94% (6% fallback to O*NET title)              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Enrich with Canadian Context                       │
│  - NOC_OCCUPATIONS table (new, 900 rows)                    │
│  - JOIN on NOC code                                          │
│  - Returns: Canadian titles, descriptions, requirements     │
│  Quality: ✅ High (OaSIS 2023 v1.0 data)                    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: Display to User                                     │
│  - "Software engineers and designers (NOC 21231) - 91%"     │
│  - Canadian salary from Job Bank API                         │
│  - Canadian education requirements                           │
│  - Link to Job Bank job postings                            │
└─────────────────────────────────────────────────────────────┘
```

**Key Insight:** We're NOT changing the matching algorithm. We're just adding a display translation layer for Canadian users.

---

## Phase 1: Database Setup (Week 1)

### 1.1 Create Snowflake Tables

**New Tables: 2** (vs 5 in original plan)

```sql
-- Table 1: NOC-to-O*NET Crosswalk (Brookfield Institute)
CREATE TABLE IF NOT EXISTS NOC_ONET_CROSSWALK (
    ID INT AUTOINCREMENT PRIMARY KEY,
    NOC_CODE VARCHAR(5) NOT NULL,              -- e.g., "21231"
    NOC_TITLE VARCHAR(255),                    -- Canadian title
    ONET_CODE VARCHAR(10) NOT NULL,            -- e.g., "15-1252.00"
    ONET_TITLE VARCHAR(255),                   -- U.S. title
    MAPPING_SOURCE VARCHAR(50) DEFAULT 'BROOKFIELD_2021',
    MAPPING_CONFIDENCE VARCHAR(10) DEFAULT 'HIGH',  -- HIGH, MEDIUM, LOW
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_onet_lookup (ONET_CODE),         -- Fast O*NET → NOC lookup
    INDEX idx_noc_lookup (NOC_CODE)            -- Fast NOC → O*NET lookup
);

-- Table 2: NOC Display Data (OaSIS 2023 v1.0)
CREATE TABLE IF NOT EXISTS NOC_OCCUPATIONS (
    NOC_CODE VARCHAR(10) PRIMARY KEY,          -- e.g., "21231.00"
    NOC_PARENT VARCHAR(5),                     -- e.g., "21231" (parent unit group)
    TITLE_EN VARCHAR(255) NOT NULL,            -- English title
    TITLE_FR VARCHAR(255),                     -- French title (for future)

    -- RIASEC Codes (for reference/validation)
    HOLLAND_CODE_1 VARCHAR(1),                 -- Primary interest
    HOLLAND_CODE_2 VARCHAR(1),                 -- Secondary interest
    HOLLAND_CODE_3 VARCHAR(1),                 -- Tertiary interest

    -- Descriptive Data (from OaSIS)
    DESCRIPTION_EN VARCHAR(5000),              -- Lead Statement (English)
    DESCRIPTION_FR VARCHAR(5000),              -- Lead Statement (French)
    EMPLOYMENT_REQUIREMENTS VARCHAR(5000),     -- Education, licensing, etc.
    MAIN_DUTIES ARRAY,                         -- Array of duty descriptions
    EXAMPLE_TITLES ARRAY,                      -- Alternate job titles

    -- Metadata
    DATA_SOURCE VARCHAR(50) DEFAULT 'OASIS_2023_V1',
    DATA_VERSION VARCHAR(20) DEFAULT '1.0',
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_parent_lookup (NOC_PARENT)       -- Fast parent code lookup
);
```

**Storage Cost:** Minimal (~3,000 rows total, < $1/month)

### 1.2 Import Crosswalk Data

**Source:** `/Users/eddym/Downloads/app/carrer/NOC/Cross/noc2021_onet26.csv`

**Script:** `NOC_STEP1_IMPORT_CROSSWALK.sql`

```sql
-- Create stage for CSV upload
CREATE STAGE IF NOT EXISTS NOC_STAGE;

-- Upload CSV (via SnowSQL or Snowsight UI)
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/Cross/noc2021_onet26.csv @NOC_STAGE;

-- Create staging table
CREATE TEMPORARY TABLE CROSSWALK_STAGING (
    noc VARCHAR(10),
    noc_title VARCHAR(255),
    onet VARCHAR(10),
    onet_title VARCHAR(255)
);

-- Load CSV data
COPY INTO CROSSWALK_STAGING
FROM @NOC_STAGE/noc2021_onet26.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
);

-- Transform and load into final table
INSERT INTO NOC_ONET_CROSSWALK (NOC_CODE, NOC_TITLE, ONET_CODE, ONET_TITLE)
SELECT
    TRIM(noc) AS NOC_CODE,
    TRIM(noc_title) AS NOC_TITLE,
    TRIM(onet) AS ONET_CODE,
    TRIM(onet_title) AS ONET_TITLE
FROM CROSSWALK_STAGING;

-- Validation
SELECT
    COUNT(*) AS total_mappings,
    COUNT(DISTINCT NOC_CODE) AS unique_noc_codes,
    COUNT(DISTINCT ONET_CODE) AS unique_onet_codes
FROM NOC_ONET_CROSSWALK;
-- Expected: 1466 mappings, 515 NOC codes, 952 O*NET codes

-- Test key mappings
SELECT * FROM NOC_ONET_CROSSWALK
WHERE ONET_CODE = '15-1252.00'  -- Software Developers
OR ONET_CODE = '25-2031.00'     -- Teachers
OR ONET_CODE = '11-3031.00';    -- Financial Managers
```

### 1.3 Import OaSIS Display Data

**Source:** `/Users/eddym/Downloads/app/carrer/NOC/*.csv` (32 files)

**Script:** `NOC_STEP2_IMPORT_OASIS_DISPLAY.sql`

```sql
-- Upload all OaSIS files to stage
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/0131ca04-*.csv @NOC_STAGE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/8cc1bd89-*.csv @NOC_STAGE;
-- ... (upload all 32 files)

-- Create staging tables for each OaSIS component
CREATE TEMPORARY TABLE OASIS_INTERESTS_STAGING (
    oasis_code VARCHAR(10),
    oasis_label VARCHAR(255),
    holland_code_1 VARCHAR(1),
    holland_code_2 VARCHAR(1),
    holland_code_3 VARCHAR(1)
);

CREATE TEMPORARY TABLE OASIS_LEAD_STATEMENT_STAGING (
    oasis_code VARCHAR(10),
    lead_statement VARCHAR(5000)
);

CREATE TEMPORARY TABLE OASIS_EMPLOYMENT_REQ_STAGING (
    oasis_code VARCHAR(10),
    employment_requirement VARCHAR(5000)
);

CREATE TEMPORARY TABLE OASIS_EXAMPLE_TITLES_STAGING (
    oasis_code VARCHAR(10),
    example_title VARCHAR(255)
);

-- Load interests (Holland Codes)
COPY INTO OASIS_INTERESTS_STAGING
FROM @NOC_STAGE/0131ca04-0379-4c1f-b814-05fb139b9718.csv  -- Interests file
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load lead statements (descriptions)
COPY INTO OASIS_LEAD_STATEMENT_STAGING
FROM @NOC_STAGE/8cc1bd89-afa1-4cfe-b45a-d6511d9318d7.csv  -- Lead Statement file
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load employment requirements
COPY INTO OASIS_EMPLOYMENT_REQ_STAGING
FROM @NOC_STAGE/053f7e1c-e629-432e-a70f-ed043e028f65.csv  -- Employment Requirements file
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load example titles (one title per row, aggregate into array)
COPY INTO OASIS_EXAMPLE_TITLES_STAGING
FROM @NOC_STAGE/66414d34-029e-4d0e-b6e5-ae3d99a73fac.csv  -- Example Titles file
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Combine into final NOC_OCCUPATIONS table
INSERT INTO NOC_OCCUPATIONS (
    NOC_CODE,
    NOC_PARENT,
    TITLE_EN,
    HOLLAND_CODE_1,
    HOLLAND_CODE_2,
    HOLLAND_CODE_3,
    DESCRIPTION_EN,
    EMPLOYMENT_REQUIREMENTS,
    EXAMPLE_TITLES
)
SELECT
    i.oasis_code AS NOC_CODE,
    CASE
        WHEN POSITION('.' IN i.oasis_code) > 0
        THEN SUBSTRING(i.oasis_code, 1, POSITION('.' IN i.oasis_code) - 1)
        ELSE i.oasis_code
    END AS NOC_PARENT,
    i.oasis_label AS TITLE_EN,
    i.holland_code_1,
    i.holland_code_2,
    i.holland_code_3,
    ls.lead_statement AS DESCRIPTION_EN,
    er.employment_requirement AS EMPLOYMENT_REQUIREMENTS,
    ARRAY_AGG(et.example_title) AS EXAMPLE_TITLES
FROM OASIS_INTERESTS_STAGING i
LEFT JOIN OASIS_LEAD_STATEMENT_STAGING ls ON i.oasis_code = ls.oasis_code
LEFT JOIN OASIS_EMPLOYMENT_REQ_STAGING er ON i.oasis_code = er.oasis_code
LEFT JOIN OASIS_EXAMPLE_TITLES_STAGING et ON i.oasis_code = et.oasis_code
GROUP BY
    i.oasis_code, i.oasis_label, i.holland_code_1, i.holland_code_2,
    i.holland_code_3, ls.lead_statement, er.employment_requirement;

-- Validation
SELECT
    COUNT(*) AS total_occupations,
    COUNT(DISTINCT NOC_PARENT) AS unique_parent_codes,
    COUNT(DESCRIPTION_EN) AS has_description,
    COUNT(EMPLOYMENT_REQUIREMENTS) AS has_requirements
FROM NOC_OCCUPATIONS;
-- Expected: 900 occupations, 516 parent codes

-- Test key occupations
SELECT
    NOC_CODE,
    TITLE_EN,
    HOLLAND_CODE_1,
    HOLLAND_CODE_2,
    HOLLAND_CODE_3,
    SUBSTRING(DESCRIPTION_EN, 1, 100) AS description_preview
FROM NOC_OCCUPATIONS
WHERE NOC_PARENT IN ('21231', '41220', '10010')  -- Software, Teachers, Finance
ORDER BY NOC_CODE;
```

**Deliverables:**
- ✅ 2 SQL scripts for imports
- ✅ Validation queries
- ✅ ~1,466 + 900 = 2,366 total rows

---

## Phase 2: Swift Service Layer (Week 2)

### 2.1 Add CountryCode Enum

**File:** `SnowflakeService.swift` (add at top)

```swift
// MARK: - Country Support

enum CountryCode: String, Codable, CaseIterable {
    case unitedStates = "US"
    case canada = "CA"

    var displayName: String {
        switch self {
        case .unitedStates: return "United States"
        case .canada: return "Canada"
        }
    }

    var flag: String {
        switch self {
        case .unitedStates: return "🇺🇸"
        case .canada: return "🇨🇦"
        }
    }

    var occupationSystem: String {
        switch self {
        case .unitedStates: return "O*NET"
        case .canada: return "NOC (OaSIS)"
        }
    }
}
```

### 2.2 Update CareerTrack Model

**File:** `CareerTrack.swift` (add fields)

```swift
struct CareerTrack: Identifiable, Codable {
    let id: UUID
    let title: String
    let progress: Double
    let salary: String
    let education: String
    let match: Int

    // Existing O*NET fields
    let onetCode: String?
    let onetDescription: String?
    let primaryRIASEC: String?
    let secondaryRIASEC: String?

    // NEW: NOC fields for Canadian display
    let nocCode: String?              // e.g., "21231"
    let nocTitle: String?              // Canadian title if different
    let dataSource: String?            // "ONET", "NOC", or "HYBRID"
    let countryContext: CountryCode?   // Which country this result is for

    // NEW: Match breakdown fields
    let interestsMatch: Double?
    let valuesMatch: Double?
    let skillsMatch: Double?
    let contextScore: Double?
    let isBoosted: Bool
    let matchTier: MatchTier

    // Display helpers
    var displayTitle: String {
        // For Canadian users, prefer NOC title
        if countryContext == .canada, let nocTitle = nocTitle {
            return nocTitle
        }
        return title
    }

    var displayCode: String? {
        if countryContext == .canada, let nocCode = nocCode {
            return "NOC \(nocCode)"
        }
        return onetCode.map { "O*NET \($0)" }
    }
}
```

### 2.3 Add NOC Enrichment Method

**File:** `SnowflakeService.swift` (add new method)

```swift
// MARK: - NOC Enrichment for Canadian Users

/// Enrich O*NET matches with Canadian NOC context
/// - Parameters:
///   - onetMatches: Array of O*NET occupation matches
///   - country: User's country (only enriches for Canada)
/// - Returns: Array of matches enriched with NOC data
func enrichWithNOCContext(
    _ onetMatches: [ONetOccupation],
    country: CountryCode
) async throws -> [ONetOccupation] {
    // Only enrich for Canadian users
    guard country == .canada else {
        return onetMatches
    }

    print("🇨🇦 Enriching \(onetMatches.count) matches with Canadian NOC context...")

    var enriched: [ONetOccupation] = []

    for match in onetMatches {
        // Lookup NOC equivalent via crosswalk
        if let nocData = try await lookupNOCForONet(match.onetSocCode) {
            // Create enriched match with Canadian context
            var enrichedMatch = match
            enrichedMatch.nocCode = nocData.nocCode
            enrichedMatch.nocTitle = nocData.title
            enrichedMatch.description = nocData.description ?? match.description
            enrichedMatch.dataSource = "HYBRID"
            enrichedMatch.countryContext = .canada

            enriched.append(enrichedMatch)

            print("  ✅ \(match.onetSocCode) → NOC \(nocData.nocCode): \(nocData.title)")
        } else {
            // No NOC mapping found (6% of cases)
            // Keep O*NET data but mark as U.S.-focused
            var fallbackMatch = match
            fallbackMatch.dataSource = "ONET_UNMAPPED"
            fallbackMatch.countryContext = .canada

            enriched.append(fallbackMatch)

            print("  ⚠️  \(match.onetSocCode) - No NOC mapping, using O*NET title")
        }
    }

    print("🎉 Enriched \(enriched.count) matches with NOC context")

    return enriched
}

/// Lookup NOC occupation data for an O*NET code
private func lookupNOCForONet(_ onetCode: String) async throws -> NOCOccupation? {
    let sql = """
    SELECT
        c.NOC_CODE,
        n.TITLE_EN AS NOC_TITLE,
        n.DESCRIPTION_EN,
        n.EMPLOYMENT_REQUIREMENTS,
        n.HOLLAND_CODE_1,
        n.HOLLAND_CODE_2,
        n.HOLLAND_CODE_3
    FROM \(database).\(schema).NOC_ONET_CROSSWALK c
    LEFT JOIN \(database).\(schema).NOC_OCCUPATIONS n
        ON c.NOC_CODE = n.NOC_PARENT OR c.NOC_CODE = n.NOC_CODE
    WHERE c.ONET_CODE = '\(onetCode)'
    LIMIT 1
    """

    let response = try await executeSQLStatement(sql)

    guard let resultArray = response["data"] as? [[Any]],
          let firstRow = resultArray.first,
          firstRow.count >= 4 else {
        return nil
    }

    return NOCOccupation(
        nocCode: firstRow[0] as? String ?? "",
        title: firstRow[1] as? String ?? "",
        description: firstRow[2] as? String,
        employmentRequirements: firstRow[3] as? String,
        hollandCode1: firstRow[4] as? String,
        hollandCode2: firstRow[5] as? String,
        hollandCode3: firstRow[6] as? String
    )
}

// MARK: - NOC Data Model

struct NOCOccupation {
    let nocCode: String
    let title: String
    let description: String?
    let employmentRequirements: String?
    let hollandCode1: String?
    let hollandCode2: String?
    let hollandCode3: String?
}
```

### 2.4 Update getCareerMatches Method

**File:** `SnowflakeService.swift` (modify existing method)

```swift
func getCareerMatches(
    scores: [String: Float],
    workValues: [String: Float]? = nil,
    subjects: [String]? = nil,
    activities: [String]? = nil,
    careerInterests: [String]? = nil,
    studentLevel: String? = nil,
    currentStatus: String? = nil,
    country: CountryCode = .unitedStates  // NEW PARAMETER
) async throws -> [ONetOccupation] {
    // ... existing RIASEC/values/skills prep code ...

    // Call Recipe D v4.0 (unchanged - still uses O*NET data)
    let sql = """
    CALL \(database).\(schema).SP_GET_CAREER_MATCHES_V4(
        \(r), \(i), \(a), \(s), \(e), \(c),
        \(achievement), \(independence), \(recognition), \(relationships), \(support), \(workingConditions),
        '\(subjectsStr.replacingOccurrences(of: "'", with: "''"))',
        '\(activitiesStr.replacingOccurrences(of: "'", with: "''"))',
        '\(interestsStr.replacingOccurrences(of: "'", with: "''"))',
        '\(level)',
        '\(status)'
    )
    """

    let response = try await executeSQLStatement(sql)

    // Parse response (existing code)
    var occupations = try parseONetResponse(response)

    // NEW: Enrich with NOC context for Canadian users
    if country == .canada {
        occupations = try await enrichWithNOCContext(occupations, country: country)
    }

    print("✅ Recipe D v4.0 returned \(occupations.count) matches (country: \(country.rawValue))")

    return occupations
}
```

### 2.5 Update AppViewModel

**File:** `AppViewModel.swift` (add country property)

```swift
class AppViewModel: ObservableObject {
    // ... existing properties ...

    // NEW: User's country preference
    var userCountry: CountryCode {
        get {
            if let countryStr = userData[.userCountry] as? String,
               let country = CountryCode(rawValue: countryStr) {
                return country
            }
            return .unitedStates  // Default to US
        }
        set {
            userData[.userCountry] = newValue.rawValue as AnyHashable
            objectWillChange.send()
        }
    }

    // Update fetchCareerMatches to pass country
    func fetchCareerMatches() async {
        isLoadingCareers = true

        do {
            // ... existing RIASEC/values/skills code ...

            // NEW: Pass country to matching
            let recommendations = try await SnowflakeService.shared.getCareerMatches(
                scores: riasecScores,
                workValues: workValuesScores,
                subjects: subjectsList,
                activities: activitiesList,
                careerInterests: careerInterestsList,
                studentLevel: studentLevel,
                currentStatus: currentStatus,
                country: userCountry  // NEW
            )

            // ... rest of existing code ...
        } catch {
            print("❌ Error fetching matches: \(error)")
        }

        isLoadingCareers = false
    }
}
```

### 2.6 Add UserDataKey

**File:** `UserDataKey.swift` (add new case)

```swift
enum UserDataKey: String, CaseIterable {
    // ... existing keys ...
    case userCountry = "user_country"  // NEW: "US" or "CA"
}
```

**Deliverables:**
- ✅ CountryCode enum (30 lines)
- ✅ CareerTrack NOC fields (20 lines)
- ✅ NOC enrichment method (100 lines)
- ✅ Updated getCareerMatches (10 lines changed)
- ✅ AppViewModel country property (20 lines)
- ✅ UserDataKey entry (1 line)

---

## Phase 3: UI Implementation (Week 2-3)

### 3.1 Country Selection View

**New File:** `CountrySelectionView.swift`

```swift
import SwiftUI

/// Country selection screen during onboarding
/// Allows users to choose between U.S. (O*NET) and Canadian (NOC) occupational data
struct CountrySelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedCountry: CountryCode
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        self._selectedCountry = State(initialValue: viewModel.userCountry)
    }

    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 12) {
                Text("Where are you located?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("We'll personalize career recommendations for your region")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 32)

            // Country options
            VStack(spacing: 16) {
                ForEach([CountryCode.unitedStates, CountryCode.canada], id: \.self) { country in
                    CountryButton(
                        country: country,
                        isSelected: selectedCountry == country,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCountry = country
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)

            // Info text
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppColors.primary)
                    Text("About career data")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Text(infoText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(AppColors.primary.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal, 24)

            Spacer()

            // Continue button
            Button(action: {
                viewModel.userCountry = selectedCountry
                // Navigate to next onboarding step
                dismiss()
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationTitle("Country")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoText: String {
        switch selectedCountry {
        case .unitedStates:
            return "U.S. recommendations use O*NET data from the Department of Labor. You'll see occupational titles, salaries, and requirements based on the U.S. labor market."
        case .canada:
            return "Canadian recommendations use NOC/OaSIS data from Employment and Social Development Canada. You'll see Canadian occupational titles, regional salaries, and local requirements."
        }
    }
}

// MARK: - Country Button Component

struct CountryButton: View {
    let country: CountryCode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag
                Text(country.flag)
                    .font(.system(size: 44))

                // Country info
                VStack(alignment: .leading, spacing: 6) {
                    Text(country.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Data: \(country.occupationSystem)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.title2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColors.primary.opacity(0.08) : Color.gray.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? AppColors.primary : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CountrySelectionView(viewModel: AppViewModel())
    }
}
```

### 3.2 Update OnboardingView

**File:** `OnboardingView.swift` (insert country selection page)

```swift
struct OnboardingView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            // Page 0: Welcome
            WelcomeView(viewModel: viewModel, currentPage: $currentPage)
                .tag(0)

            // Page 1: Country Selection (NEW)
            CountrySelectionView(viewModel: viewModel)
                .tag(1)

            // Page 2: RIASEC Questions (was page 1)
            RIASECQuestionView(viewModel: viewModel, currentPage: $currentPage)
                .tag(2)

            // Page 3: Work Values (was page 2)
            WorkValuesView(viewModel: viewModel, currentPage: $currentPage)
                .tag(3)

            // ... rest of pages ...
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
```

### 3.3 Update Career Detail View Attribution

**File:** `ONetCareerDetailView.swift` (update attribution section)

```swift
private var attributionSection: some View {
    VStack(spacing: 4) {
        // Show appropriate attribution based on data source
        if careerTrack.dataSource == "HYBRID" || careerTrack.dataSource == "NOC" {
            Text("Powered by NOC/OaSIS")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Employment and Social Development Canada")
                .font(.caption2)
                .foregroundColor(.secondary)

            Text("Match quality: O*NET algorithm")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        } else {
            Text("Powered by O*NET")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("U.S. Department of Labor")
                .font(.caption2)
                .foregroundColor(.secondary)
        }

        // Show occupation codes
        if let displayCode = careerTrack.displayCode {
            Text(displayCode)
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.7))
                .padding(.top, 2)
        }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 24)
}
```

### 3.4 Add Settings Section (Optional)

**New File:** `SettingsView.swift` (or update existing)

```swift
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showCountryChangeWarning = false

    var body: some View {
        List {
            // ... other settings sections ...

            Section(header: Text("Region")) {
                Picker("Country", selection: $viewModel.userCountry) {
                    ForEach(CountryCode.allCases, id: \.self) { country in
                        HStack {
                            Text(country.flag)
                            Text(country.displayName)
                        }
                        .tag(country)
                    }
                }
                .onChange(of: viewModel.userCountry) { _, _ in
                    showCountryChangeWarning = true
                }

                Text("Career data source: \(viewModel.userCountry.occupationSystem)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
        .alert("Country Changed", isPresented: $showCountryChangeWarning) {
            Button("Refresh Recommendations") {
                Task {
                    await viewModel.fetchCareerMatches()
                }
            }
            Button("Later", role: .cancel) { }
        } message: {
            Text("Your career recommendations will be updated to reflect \(viewModel.userCountry.displayName) occupational data.")
        }
    }
}
```

**Deliverables:**
- ✅ CountrySelectionView.swift (150 lines)
- ✅ Updated OnboardingView.swift (10 lines changed)
- ✅ Updated ONetCareerDetailView.swift (20 lines)
- ✅ SettingsView.swift (50 lines, optional)

---

## Phase 4: Testing & Validation (Week 3)

### 4.1 Database Validation Queries

**File:** `NOC_VALIDATION_QUERIES.sql`

```sql
-- Query 1: Verify crosswalk coverage
SELECT
    'Crosswalk Coverage' AS test,
    COUNT(*) AS total_mappings,
    COUNT(DISTINCT NOC_CODE) AS unique_noc,
    COUNT(DISTINCT ONET_CODE) AS unique_onet,
    ROUND(COUNT(DISTINCT ONET_CODE) / 1016.0 * 100, 1) AS onet_coverage_pct
FROM NOC_ONET_CROSSWALK;
-- Expected: ~1466 mappings, ~515 NOC, ~952 O*NET (94% coverage)

-- Query 2: Test key occupation lookups
SELECT
    'Test Key Occupations' AS test,
    c.ONET_CODE,
    c.ONET_TITLE,
    c.NOC_CODE,
    n.TITLE_EN AS NOC_TITLE,
    n.HOLLAND_CODE_1,
    n.HOLLAND_CODE_2,
    n.HOLLAND_CODE_3
FROM NOC_ONET_CROSSWALK c
LEFT JOIN NOC_OCCUPATIONS n ON c.NOC_CODE = n.NOC_PARENT
WHERE c.ONET_CODE IN (
    '15-1252.00',  -- Software Developers
    '25-2031.00',  -- Secondary Teachers
    '11-3031.00',  -- Financial Managers
    '29-1141.00'   -- Registered Nurses
)
ORDER BY c.ONET_CODE;
-- Expected: All 4 occupations found with NOC mappings

-- Query 3: Check for unmapped O*NET codes (6% expected)
SELECT
    'Unmapped O*NET Check' AS test,
    o.ONET_SOC_CODE,
    o.JOB_TITLE,
    CASE
        WHEN c.ONET_CODE IS NULL THEN 'UNMAPPED'
        ELSE 'MAPPED'
    END AS mapping_status
FROM CAREER_FULL_VECTORS o
LEFT JOIN NOC_ONET_CROSSWALK c ON o.ONET_SOC_CODE = c.ONET_CODE
WHERE c.ONET_CODE IS NULL
LIMIT 10;
-- Review unmapped titles (should be U.S.-specific roles)

-- Query 4: Simulate hybrid lookup (like Swift will do)
WITH test_matches AS (
    -- Simulate Recipe D v4.0 returning top matches
    SELECT
        ONET_SOC_CODE,
        JOB_TITLE,
        95 AS match_percentage  -- Simulated match score
    FROM CAREER_FULL_VECTORS
    WHERE ONET_SOC_CODE IN ('15-1252.00', '25-2031.00', '11-3031.00')
)
SELECT
    t.ONET_SOC_CODE AS onet_code,
    t.JOB_TITLE AS onet_title,
    t.match_percentage,
    c.NOC_CODE AS noc_code,
    n.TITLE_EN AS canadian_title,
    COALESCE(n.DESCRIPTION_EN, t.JOB_TITLE) AS display_description
FROM test_matches t
LEFT JOIN NOC_ONET_CROSSWALK c ON t.ONET_SOC_CODE = c.ONET_CODE
LEFT JOIN NOC_OCCUPATIONS n ON c.NOC_CODE = n.NOC_PARENT
ORDER BY t.match_percentage DESC;
-- Expected: All 3 occupations show Canadian titles

-- Query 5: Performance test
SELECT
    'Performance Test' AS test,
    COUNT(*) AS total_joins_needed
FROM CAREER_FULL_VECTORS o
LEFT JOIN NOC_ONET_CROSSWALK c ON o.ONET_SOC_CODE = c.ONET_CODE
LEFT JOIN NOC_OCCUPATIONS n ON c.NOC_CODE = n.NOC_PARENT
WHERE o.ONET_SOC_CODE IN (
    SELECT ONET_SOC_CODE FROM CAREER_FULL_VECTORS LIMIT 50
);
-- Should complete in < 100ms
```

### 4.2 Swift Unit Tests

**New File:** `SnowflakeServiceNOCTests.swift`

```swift
import XCTest
@testable import MyPathApp

class SnowflakeServiceNOCTests: XCTestCase {
    var service: SnowflakeService!

    override func setUp() {
        super.setUp()
        service = SnowflakeService.shared
    }

    // Test 1: U.S. user gets O*NET data
    func testUSUserGetsONetData() async throws {
        let matches = try await service.getCareerMatches(
            scores: ["R": 2.0, "I": 5.0, "A": 2.5, "S": 3.0, "E": 3.0, "C": 4.0],
            country: .unitedStates
        )

        XCTAssertFalse(matches.isEmpty, "Should return O*NET matches")
        XCTAssertNil(matches.first?.nocCode, "U.S. users should not have NOC codes")
        XCTAssertEqual(matches.first?.dataSource, "ONET", "Data source should be O*NET")
    }

    // Test 2: Canadian user gets NOC-enriched data
    func testCanadianUserGetsNOCData() async throws {
        let matches = try await service.getCareerMatches(
            scores: ["R": 2.0, "I": 5.0, "A": 2.5, "S": 3.0, "E": 3.0, "C": 4.0],
            country: .canada
        )

        XCTAssertFalse(matches.isEmpty, "Should return matches")

        // Most matches should have NOC codes (94% coverage)
        let withNOC = matches.filter { $0.nocCode != nil }.count
        let coverage = Double(withNOC) / Double(matches.count)
        XCTAssertGreaterThan(coverage, 0.85, "Should have >85% NOC coverage")

        // Check first match has Canadian title
        if let firstMatch = matches.first, firstMatch.nocCode != nil {
            XCTAssertNotNil(firstMatch.nocTitle, "Should have Canadian title")
            XCTAssertEqual(firstMatch.dataSource, "HYBRID", "Should be hybrid data")
        }
    }

    // Test 3: NOC lookup for Software Developers
    func testSoftwareDeveloperNOCLookup() async throws {
        let nocData = try await service.lookupNOCForONet("15-1252.00")

        XCTAssertNotNil(nocData, "Should find NOC mapping")
        XCTAssertEqual(nocData?.nocCode, "21231", "Should map to NOC 21231")
        XCTAssertTrue(
            nocData?.title.lowercased().contains("software") ?? false,
            "Title should contain 'software'"
        )
    }

    // Test 4: Match scores preserved after NOC enrichment
    func testMatchScoresPreservedAfterEnrichment() async throws {
        let matches = try await service.getCareerMatches(
            scores: ["R": 2.0, "I": 5.0, "A": 2.5, "S": 3.0, "E": 3.0, "C": 4.0],
            workValues: ["achievement": 5.0, "independence": 5.0],
            country: .canada
        )

        // Match scores should still be present and valid
        for match in matches {
            XCTAssertGreaterThan(match.match, 0, "Match score should be > 0")
            XCTAssertLessThanOrEqual(match.match, 100, "Match score should be <= 100")

            // Match breakdown should exist
            XCTAssertNotNil(match.interestsMatch, "Should have interests match")
            XCTAssertNotNil(match.valuesMatch, "Should have values match")
        }
    }

    // Test 5: Fallback for unmapped O*NET codes
    func testUnmappedONetFallback() async throws {
        // This test requires a known unmapped O*NET code
        // For now, just verify the enrichment handles nil gracefully

        let testMatch = ONetOccupation(
            onetSocCode: "99-9999.00",  // Fake code
            title: "Test Unmapped Occupation",
            description: "Test",
            match: 85,
            education: nil,
            outlook: nil,
            salary: nil,
            matchExplanation: nil,
            interestsMatch: 0.9,
            valuesMatch: 0.8,
            skillsMatch: 0.7,
            contextScore: 0.5
        )

        let enriched = try await service.enrichWithNOCContext([testMatch], country: .canada)

        XCTAssertEqual(enriched.count, 1, "Should return the match")
        XCTAssertEqual(enriched.first?.dataSource, "ONET_UNMAPPED", "Should mark as unmapped")
    }
}
```

### 4.3 Integration Test Cases

**Manual Test Scenarios:**

| Test ID | User Profile | Country | Expected Result | Success Criteria |
|---------|--------------|---------|-----------------|-------------------|
| **IT-1** | High Investigative/STEM | Canada | Software engineer NOC 21231 in top 3 | ✅ 91%+ match, Canadian title shown |
| **IT-2** | High Social/Teaching | Canada | Teacher NOC 41220 in top 3 | ✅ 88%+ match, education requirements shown |
| **IT-3** | High Enterprising/Business | Canada | Financial manager NOC 10010 in top 5 | ✅ 85%+ match, Canadian salary shown |
| **IT-4** | Same as IT-1 | U.S. | Software developer O*NET 15-1252.00 | ✅ Same match score, O*NET title |
| **IT-5** | Toggle U.S. → Canada | Both | Recommendations refresh | ✅ Titles change, scores stay same |
| **IT-6** | All career types | Canada | 94%+ have NOC codes | ✅ Count NOC codes in top 50 |

**Test Execution:**
```bash
# Run Swift tests
xcodebuild test -scheme MyPathApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Expected: All tests pass (6/6)
```

### 4.4 Performance Benchmarks

**Target Metrics:**

| Metric | U.S. (Baseline) | Canada (Hybrid) | Max Acceptable |
|--------|-----------------|-----------------|----------------|
| Recipe D v4.0 call | 1.5s | 1.5s (same) | 2.0s |
| NOC enrichment | N/A | 0.3s | 0.5s |
| Total latency | 1.5s | 1.8s | 2.5s |
| Database queries | 1 | 3 (recipe + 2 joins) | 5 |

**Performance Test Query:**
```sql
-- Time the hybrid lookup for 50 matches
SET start_time = CURRENT_TIMESTAMP();

WITH top_50_matches AS (
    SELECT ONET_SOC_CODE FROM CAREER_FULL_VECTORS LIMIT 50
)
SELECT
    o.ONET_SOC_CODE,
    c.NOC_CODE,
    n.TITLE_EN
FROM top_50_matches m
JOIN CAREER_FULL_VECTORS o ON m.ONET_SOC_CODE = o.ONET_SOC_CODE
LEFT JOIN NOC_ONET_CROSSWALK c ON o.ONET_SOC_CODE = c.ONET_CODE
LEFT JOIN NOC_OCCUPATIONS n ON c.NOC_CODE = n.NOC_PARENT;

SET end_time = CURRENT_TIMESTAMP();
SELECT DATEDIFF('millisecond', :start_time, :end_time) AS query_time_ms;
-- Expected: < 100ms
```

**Deliverables:**
- ✅ Validation SQL script (5 queries)
- ✅ Swift unit tests (5 test cases)
- ✅ Integration test plan (6 scenarios)
- ✅ Performance benchmarks

---

## Phase 5: Deployment (Week 4)

### 5.1 Database Deployment Checklist

```
□ Run NOC_STEP1_IMPORT_CROSSWALK.sql in production
  - Verify 1,466 mappings loaded
  - Check indexes created
  - Test lookup query performance

□ Run NOC_STEP2_IMPORT_OASIS_DISPLAY.sql in production
  - Verify 900 occupations loaded
  - Check display data quality
  - Test JOIN queries

□ Run NOC_VALIDATION_QUERIES.sql
  - All 5 validation queries pass
  - Performance < 100ms per query

□ Backup database before deployment
  - Export current CAREER_FULL_VECTORS
  - Document rollback procedure
```

### 5.2 Swift Deployment Checklist

```
□ Merge country selection branch
  - Code review complete
  - All tests passing
  - UI reviewed and approved

□ Update API config (if needed)
  - Snowflake credentials unchanged
  - No new environment variables

□ Test on devices
  - iPhone SE (small screen)
  - iPhone 15 Pro (standard)
  - iPad (large screen)

□ Verify analytics
  - Track country_selected event
  - Track noc_enrichment_success/failure events
```

### 5.3 Beta Rollout Plan

**Week 4 (Beta)**

**Day 1-2: Internal Testing**
- Deploy to TestFlight (internal testers only)
- Test all onboarding flows
- Verify both U.S. and Canada modes

**Day 3-5: Beta Users (100 users)**
- 50 Canadian users
- 50 U.S. users (control group)
- Collect feedback via in-app survey

**Day 6-7: Iterate**
- Fix any bugs found
- Adjust UI based on feedback
- Prepare for production

**Metrics to Monitor:**
| Metric | Target | Alert If |
|--------|--------|----------|
| Country selection rate (Canada) | 15-30% | < 10% or > 50% |
| NOC enrichment success rate | > 92% | < 85% |
| Match quality feedback | > 4.0/5.0 | < 3.5/5.0 |
| App crash rate | < 0.1% | > 0.5% |
| API latency (p95) | < 2.5s | > 3.0s |

### 5.4 Production Rollout

**Week 5 (Production)**

**Phased Rollout:**
- Day 1: 10% of users
- Day 2: 25% of users
- Day 3: 50% of users
- Day 4: 75% of users
- Day 5: 100% of users

**Feature Flag:**
```swift
// Add to AppViewModel
var nocFeatureEnabled: Bool {
    // Check remote config or local override
    return RemoteConfig.shared.getBool("noc_feature_enabled", defaultValue: true)
}
```

**Rollback Plan:**
- Set feature flag to false
- Users see O*NET data only (existing behavior)
- No database changes needed (tables remain)

**Deliverables:**
- ✅ Deployment checklists (2)
- ✅ Beta rollout plan (7 days)
- ✅ Production rollout plan (5 days)
- ✅ Monitoring metrics (5 KPIs)

---

## Success Metrics

### Launch Targets (Week 4)

| Metric | Target | Measurement |
|--------|--------|-------------|
| ✅ NOC coverage | 94% | Crosswalk validation query |
| ✅ Enrichment latency | < 0.5s | Swift performance test |
| ✅ Match quality preserved | 100% | Compare U.S. vs Canada scores |
| ✅ User satisfaction | > 4.0/5.0 | In-app survey |
| ✅ Error rate | < 0.5% | Snowflake query logs |

### Growth Targets (Month 1)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Canadian user adoption | 20-30% | Country selection analytics |
| Completion rate (onboarding) | > 80% | Funnel analysis |
| Session time (Canadian users) | +10% vs U.S. | Engagement metrics |
| App Store rating (Canada) | > 4.5 stars | App Store Connect |

---

## Risk Mitigation

| Risk | Probability | Mitigation |
|------|------------|------------|
| **6% unmapped O*NET codes** | High | Show O*NET title with note; skip in worst case |
| **Crosswalk becomes outdated** | Low | Update annually; NOC releases slowly |
| **Performance degradation** | Low | Indexes on lookup tables; monitor latency |
| **User confusion (2 systems)** | Medium | Clear explanation in onboarding; help docs |
| **Missing Canadian salary data** | High | Integrate Job Bank API (optional Phase 2) |

---

## Future Enhancements (Backlog)

### Phase 2: Job Bank Integration (Month 2-3)

- Real-time Canadian job postings
- Regional salary data by province
- Labor market trends (growing/declining)

### Phase 3: Bilingual Support (Month 4-6)

- French language support
- Toggle between English/French NOC titles
- Bilingual onboarding

### Phase 4: Provincial Filters (Month 6+)

- Filter by province (ON, QC, BC, AB, etc.)
- Province-specific licensing requirements
- Regional demand indicators

---

## Questions & Support

**During Implementation:**

1. **Snowflake Access Issues?**
   - Verify credentials in APIConfig
   - Check warehouse is running
   - Test with simple SELECT query

2. **CSV Upload Fails?**
   - Use Snowsight web UI instead of SnowSQL
   - Verify file encoding (UTF-8)
   - Check for special characters in data

3. **NOC Lookup Returns Null?**
   - Verify O*NET code format (e.g., "15-1252.00")
   - Check crosswalk table loaded correctly
   - Test with known mapping (Software Developers)

4. **Match Scores Seem Off?**
   - Recipe D v4.0 is unchanged (O*NET data)
   - Scores should be identical to U.S. users
   - Only titles/descriptions differ

5. **Performance Too Slow?**
   - Check indexes exist on lookup tables
   - Monitor Snowflake query history
   - Consider caching frequent lookups

---

## Appendix: File Checklist

### Snowflake SQL Scripts (3 files)
- ✅ `NOC_STEP1_IMPORT_CROSSWALK.sql` (crosswalk import)
- ✅ `NOC_STEP2_IMPORT_OASIS_DISPLAY.sql` (display data import)
- ✅ `NOC_VALIDATION_QUERIES.sql` (5 validation queries)

### Swift Files (7 files)
- ✅ `SnowflakeService.swift` (add CountryCode enum, NOC methods)
- ✅ `CareerTrack.swift` (add NOC fields)
- ✅ `AppViewModel.swift` (add country property)
- ✅ `UserDataKey.swift` (add country key)
- ✅ `CountrySelectionView.swift` (NEW - 150 lines)
- ✅ `OnboardingView.swift` (update - add country page)
- ✅ `ONetCareerDetailView.swift` (update attribution)

### Test Files (2 files)
- ✅ `SnowflakeServiceNOCTests.swift` (NEW - 5 test cases)
- ✅ Integration test plan document

### Documentation (3 files)
- ✅ `NOC_HYBRID_IMPLEMENTATION_PLAN.md` (this file)
- ✅ `NOC_DATA_COMPLETENESS_ANALYSIS.md` (reference)
- ✅ `NOC_CROSSWALK_QUALITY_ASSESSMENT.md` (reference)

---

## Timeline Summary

| Week | Phase | Tasks | Deliverables |
|------|-------|-------|--------------|
| **1** | Database | Snowflake imports, validation | 2 new tables, 2,366 rows |
| **2** | Swift | Service layer, models | 6 files updated, 1 new file |
| **2-3** | UI | Country selection, onboarding | 2 new views, 2 updated views |
| **3** | Testing | Unit tests, integration tests | Test suite, validation queries |
| **4** | Beta | Internal + 100 beta users | Metrics, feedback, bug fixes |
| **5** | Production | Phased rollout 10%→100% | Full deployment, monitoring |

**Total Time:** 3-4 weeks (faster than original 4-5 week plan!)

---

## Getting Started

**Next Step:** Generate the Snowflake import scripts

Ready to proceed? I'll create:
1. `NOC_STEP1_IMPORT_CROSSWALK.sql`
2. `NOC_STEP2_IMPORT_OASIS_DISPLAY.sql`
3. `NOC_VALIDATION_QUERIES.sql`

These will be production-ready scripts you can run directly in Snowflake.

Should I proceed with generating these scripts? 🚀

---

*Plan Version: 2.0*
*Status: Approved for Implementation*
*Created: 2025-10-12*
