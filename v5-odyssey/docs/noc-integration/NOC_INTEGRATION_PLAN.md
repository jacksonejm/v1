# MyPath Canadian O*NET Integration Plan
## OaSIS/NOC to O*NET Mapping Strategy

**Version:** 1.0
**Date:** 2025-10-12
**Pre-Integration Backup:** Git commit `15dc0c3`
**Status:** ⚠️ AWAITING USER APPROVAL

---

## Executive Summary

This document outlines a comprehensive plan to integrate Canadian occupational data (OaSIS/NOC) into the MyPath career matching app, enabling support for both U.S. (O*NET) and Canadian (OaSIS/NOC) users through a unified architecture.

### Goals
1. **Maintain O*NET as Primary**: Keep existing U.S. O*NET functionality unchanged
2. **Add Canadian Support**: Enable NOC/OaSIS data for Canadian users
3. **Unified Matching**: Use same Recipe D v4.0 algorithm for both datasets
4. **User Toggle**: Allow users to select country preference (U.S./Canada)
5. **Data Quality**: Map 900 NOC occupations to O*NET with 80%+ coverage

### Key Benefits
- **Market Expansion**: Support Canadian user base (~38M population)
- **Improved Accuracy**: Use region-specific occupational data
- **RIASEC Alignment**: Both systems use Holland Codes (perfect compatibility!)
- **Open Data**: OaSIS is free, CC BY 4.0 licensed (no API costs)

---

## Phase 1: Discovery & Analysis (COMPLETED ✅)

### 1.1 NOC/OaSIS Files Examined

**Location:** `/Users/eddym/Downloads/app/carrer/NOC/`

**Crosswalk File:**
- `noc2021_onet26.csv` (141KB, 1,900+ mappings)
- Format: `noc,noc_title,onet,onet_title`
- Example: NOC `10010` (Financial managers) → O*NET `11-3031.00`
- Note: Not 1:1 mapping (one NOC can map to multiple O*NETs)

**OaSIS Data Files** (32 resources, 88,011 total lines):

| Category | File ID | Rows | Scale | Notes |
|----------|---------|------|-------|-------|
| **Guide** | `0ee24456` | - | - | Data dictionary |
| **Skills** | `38932102` | 900 | 0-5 | 35 skills (Reading, Writing, Numeracy, etc.) |
| **Abilities** | `9a7e1f06` | 900 | 1-5 | Physical/cognitive abilities |
| **Interests** | `0131ca04` | 900 | RIASEC | **Holland Codes 1-3** ⭐ |
| **Knowledge** | `5dae7457` | 900 | 1-3 | Subject matter knowledge |
| **Personal Attributes** | `0958eaa1` | 900 | 1-5 | Work style importance |
| **Work Activities** | `52063d66` | 900 | 1-5 | Task complexity |
| **Work Context** | `93a88c2d` | 900 | Various | Frequency, duration, etc. |
| **Lead Statement** | `8cc1bd89` | 900 | Text | Job descriptions |
| **Main Duties** | `79361933` | 900 | Text | Task descriptions |
| **Example Titles** | `66414d34` | 15,000+ | Text | Alternate job titles |
| **Employment Requirements** | `053f7e1c` | 900 | Text | Education/licensing |

**Key Finding:** 🎯 **RIASEC codes are identical between O*NET and OaSIS!**
- Both use Holland Codes (R,I,A,S,E,C)
- OaSIS provides top 3 codes ranked by predominance
- Perfect alignment for interests matching in Recipe D v4.0

### 1.2 Current O*NET Schema

**Snowflake Database:**
```
Database: ONET_CAREER_DB
Schema: CAREER_SCHEMA
Warehouse: ONET_CAREER_AGENT_WH
```

**Main Table: `CAREER_FULL_VECTORS`**
```sql
Columns:
- ONET_SOC_CODE VARCHAR       -- e.g., "15-1252.00"
- JOB_TITLE VARCHAR            -- e.g., "Software Developer"
- REALISTIC FLOAT              -- 0-5 scale
- INVESTIGATIVE FLOAT          -- 0-5 scale
- ARTISTIC FLOAT               -- 0-5 scale
- SOCIAL FLOAT                 -- 0-5 scale
- ENTERPRISING FLOAT           -- 0-5 scale
- CONVENTIONAL FLOAT           -- 0-5 scale
- ACHIEVEMENT FLOAT            -- 0-1 scale (work values)
- INDEPENDENCE FLOAT           -- 0-1 scale
- RECOGNITION FLOAT            -- 0-1 scale
- RELATIONSHIPS FLOAT          -- 0-1 scale
- SUPPORT FLOAT                -- 0-1 scale
- WORKING_CONDITIONS FLOAT     -- 0-1 scale
- SKILLS_VECTOR ARRAY          -- JSON: [{skill_id, importance}]
- DESCRIPTION VARCHAR          -- Job description
```

**Mapping Tables:**
- `SUBJECT_SKILLS_MAPPING`: Maps academic subjects → O*NET skills
- `ACTIVITY_SKILLS_MAPPING`: Maps activities → O*NET skills

**Stored Procedures:**
- `SP_GET_CAREER_MATCHES_V4`: Recipe D v4.0 (17 parameters)
- `SP_GET_CAREER_SKILLS`: Returns skills for occupation
- `SP_GET_JOB_SEARCH_STRATEGY`: Returns job search guidance

### 1.3 Recipe D v4.0 Algorithm

**Matching Formula:**
```javascript
blended_match = (0.40 * interests_match)     // RIASEC cosine similarity
              + (0.30 * values_match)        // Work values cosine similarity
              + (0.20 * skills_match)        // Weighted skill overlap
              + (0.10 * context_score)       // Career interest boost
```

**Weights:**
- 40% Personality/Interests (RIASEC)
- 30% Work Values
- 20% Skills (subjects/activities)
- 10% Context (career interests, education level)

**Output:** 50 careers ranked by `final_score` (0-7 scale, converted to 0-100%)

---

## Phase 2: Architecture Design

### 2.1 Database Schema Changes

#### Option A: Parallel Tables (RECOMMENDED ✅)

**Pros:**
- Clean separation of O*NET vs NOC data
- Easy rollback if issues arise
- No risk to existing O*NET data
- Simpler queries (no JOIN complexity)

**Cons:**
- Some data duplication for mapped occupations
- Need to maintain two sets of mappings

**New Tables:**

```sql
-- 1. NOC Occupations Table (parallel to CAREER_FULL_VECTORS)
CREATE TABLE CAREER_FULL_VECTORS_NOC (
    NOC_CODE VARCHAR(10) PRIMARY KEY,        -- e.g., "10010.00"
    OASIS_CODE VARCHAR(10),                  -- Same as NOC_CODE
    JOB_TITLE_EN VARCHAR,                    -- English title
    JOB_TITLE_FR VARCHAR,                    -- French title

    -- RIASEC Scores (converted from OaSIS Interests)
    REALISTIC FLOAT,                         -- 0-5 scale
    INVESTIGATIVE FLOAT,
    ARTISTIC FLOAT,
    SOCIAL FLOAT,
    ENTERPRISING FLOAT,
    CONVENTIONAL FLOAT,
    HOLLAND_CODE_1 VARCHAR(1),               -- Primary interest
    HOLLAND_CODE_2 VARCHAR(1),               -- Secondary interest
    HOLLAND_CODE_3 VARCHAR(1),               -- Tertiary interest

    -- Work Values (mapped from Personal Attributes importance)
    ACHIEVEMENT FLOAT,                       -- 0-1 scale (normalized from 1-5)
    INDEPENDENCE FLOAT,
    RECOGNITION FLOAT,
    RELATIONSHIPS FLOAT,
    SUPPORT FLOAT,
    WORKING_CONDITIONS FLOAT,

    -- Skills Vector (from OaSIS Skills)
    SKILLS_VECTOR ARRAY,                     -- JSON: [{skill_id, importance}]

    -- Descriptive Data
    DESCRIPTION VARCHAR,                     -- From Lead Statement
    MAIN_DUTIES ARRAY,                       -- From Main Duties
    EXAMPLE_TITLES ARRAY,                    -- From Example Titles
    EMPLOYMENT_REQUIREMENTS VARCHAR,         -- From Employment Requirements

    -- Metadata
    DATA_SOURCE VARCHAR DEFAULT 'OASIS_2023_V1',
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. NOC-to-O*NET Crosswalk Table
CREATE TABLE NOC_ONET_CROSSWALK (
    ID INT AUTOINCREMENT PRIMARY KEY,
    NOC_CODE VARCHAR(10),                    -- e.g., "10010"
    NOC_TITLE VARCHAR,
    ONET_CODE VARCHAR(10),                   -- e.g., "11-3031.00"
    ONET_TITLE VARCHAR,
    MATCH_TYPE VARCHAR,                      -- '1:1', '1:N', 'N:1'
    MATCH_QUALITY FLOAT,                     -- Similarity score (0-1)
    NOTES VARCHAR,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. OaSIS Skills Mapping (parallel to SUBJECT_SKILLS_MAPPING)
CREATE TABLE SUBJECT_SKILLS_MAPPING_NOC (
    ID INT AUTOINCREMENT PRIMARY KEY,
    SUBJECT_NAME VARCHAR,                    -- e.g., "Math"
    OASIS_SKILL_NAME VARCHAR,                -- e.g., "Numeracy"
    OASIS_SKILL_ID VARCHAR,                  -- For reference
    RELEVANCE_SCORE FLOAT,                   -- 0-1 scale
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. OaSIS Activities Mapping
CREATE TABLE ACTIVITY_SKILLS_MAPPING_NOC (
    ID INT AUTOINCREMENT PRIMARY KEY,
    ACTIVITY_NAME VARCHAR,                   -- e.g., "Coding/Programming"
    OASIS_SKILL_NAME VARCHAR,                -- e.g., "Digital Literacy"
    OASIS_SKILL_ID VARCHAR,
    RELEVANCE_SCORE FLOAT,                   -- 0-1 scale
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. User Country Preference (optional - could be in app)
CREATE TABLE USER_COUNTRY_PREFERENCES (
    USER_ID VARCHAR PRIMARY KEY,
    COUNTRY_CODE VARCHAR(2),                 -- 'US' or 'CA'
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Option B: Unified Table (NOT RECOMMENDED ❌)

**Why Not:**
- Risk of corrupting existing O*NET data
- Complex JOIN queries for every match
- Harder to maintain separate O*NET/NOC updates
- Slower query performance

### 2.2 Data Transformation Pipeline

**RIASEC Conversion Strategy:**

OaSIS provides Holland Codes as ranked letters (e.g., "E,C,I"). We need to convert to numeric 0-5 scale:

```javascript
// Conversion Formula (based on O*NET distribution analysis)
function convertHollandCodesToRIASEC(code1, code2, code3) {
    let scores = {R: 0, I: 0, A: 0, S: 0, E: 0, C: 0};

    // Primary code gets 5.0 (highest)
    if (code1) scores[code1.toUpperCase()] = 5.0;

    // Secondary code gets 3.5 (moderate-high)
    if (code2) scores[code2.toUpperCase()] = 3.5;

    // Tertiary code gets 2.0 (moderate)
    if (code3) scores[code3.toUpperCase()] = 2.0;

    // Unmentioned codes default to 1.0 (low baseline)
    for (let key in scores) {
        if (scores[key] === 0) scores[key] = 1.0;
    }

    return scores;
}

// Example: "E,C,I" → {R:1, I:2, A:1, S:1, E:5, C:3.5}
```

**Skills Mapping Strategy:**

OaSIS has 35 skills with 0-5 ratings. O*NET has 240+ skills. We need to:
1. Map OaSIS skills to O*NET skill IDs (manual mapping table)
2. Keep OaSIS ratings as-is (already 0-5 scale)
3. For unmapped skills, use 0 (not required)

**Work Values Mapping:**

OaSIS "Personal Attributes" (importance 1-5) → O*NET Work Values (0-1 scale):

```sql
-- Example mappings from OaSIS Personal Attributes to O*NET Work Values
OaSIS Attribute              → O*NET Work Value
"Achievement/Effort"         → ACHIEVEMENT
"Independence"               → INDEPENDENCE
"Recognition"                → RECOGNITION
"Relationships"              → RELATIONSHIPS
"Support"                    → SUPPORT
"Working Conditions"         → WORKING_CONDITIONS

-- Normalization: divide by 5 to convert 1-5 scale to 0-1 scale
value_normalized = oasis_importance / 5.0
```

### 2.3 Stored Procedure Updates

**New Procedure: `SP_GET_CAREER_MATCHES_V4_NOC`**

```sql
CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V4_NOC(
    -- Same 17 parameters as O*NET version
    USER_REALISTIC FLOAT,
    USER_INVESTIGATIVE FLOAT,
    USER_ARTISTIC FLOAT,
    USER_SOCIAL FLOAT,
    USER_ENTERPRISING FLOAT,
    USER_CONVENTIONAL FLOAT,
    USER_ACHIEVEMENT FLOAT,
    USER_INDEPENDENCE FLOAT,
    USER_RECOGNITION FLOAT,
    USER_RELATIONSHIPS FLOAT,
    USER_SUPPORT FLOAT,
    USER_WORKING_CONDITIONS FLOAT,
    USER_SUBJECTS VARCHAR,
    USER_ACTIVITIES VARCHAR,
    USER_CAREER_INTERESTS VARCHAR,
    USER_STUDENT_LEVEL VARCHAR,
    USER_CURRENT_STATUS VARCHAR
)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
    // IDENTICAL matching logic to Recipe D v4.0
    // Only difference: query CAREER_FULL_VECTORS_NOC table instead

    let query = `
        SELECT
            NOC_CODE,
            JOB_TITLE_EN,
            REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL,
            ACHIEVEMENT, INDEPENDENCE, RECOGNITION, RELATIONSHIPS, SUPPORT, WORKING_CONDITIONS,
            SKILLS_VECTOR,
            DESCRIPTION
        FROM CAREER_FULL_VECTORS_NOC
    `;

    // Rest of algorithm identical...
$$;
```

**Unified Wrapper Procedure:**

```sql
CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V4_UNIFIED(
    -- Country parameter
    USER_COUNTRY VARCHAR,  -- 'US' or 'CA'

    -- All Recipe D v4.0 parameters
    USER_REALISTIC FLOAT,
    -- ... (rest of 17 parameters)
)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
    if (USER_COUNTRY === 'CA') {
        // Call NOC version
        return snowflake.execute({
            sqlText: "CALL SP_GET_CAREER_MATCHES_V4_NOC(...)"
        });
    } else {
        // Call O*NET version (default)
        return snowflake.execute({
            sqlText: "CALL SP_GET_CAREER_MATCHES_V4(...)"
        });
    }
$$;
```

---

## Phase 3: Swift Service Layer Changes

### 3.1 SnowflakeService.swift Updates

**Location:** `/Users/eddym/Downloads/app/carrer/carrer/Services/Networking/SnowflakeService.swift`

**Changes:**

```swift
// 1. Add country parameter to getCareerMatches
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

    // Select procedure based on country
    let procedureName: String
    switch country {
    case .canada:
        procedureName = "SP_GET_CAREER_MATCHES_V4_NOC"
    case .unitedStates:
        procedureName = "SP_GET_CAREER_MATCHES_V4"
    }

    let sql = """
    CALL \(database).\(schema).\(procedureName)(
        \(r), \(i), \(a), \(s), \(e), \(c),
        \(achievement), \(independence), \(recognition), \(relationships), \(support), \(workingConditions),
        '\(subjectsStr.replacingOccurrences(of: "'", with: "''"))',
        '\(activitiesStr.replacingOccurrences(of: "'", with: "''"))',
        '\(interestsStr.replacingOccurrences(of: "'", with: "''"))',
        '\(level)',
        '\(status)'
    )
    """

    // Rest of parsing logic remains same
    // NOC returns same JSON structure as O*NET
}

// 2. Add new enum for country codes
enum CountryCode: String, Codable {
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
}
```

### 3.2 UserDataKey.swift Updates

**Location:** `/Users/eddym/Downloads/app/carrer/carrer/Models/Shared/UserDataKey.swift`

**Add new key:**

```swift
enum UserDataKey: String, CaseIterable {
    // ... existing keys ...
    case userCountry = "user_country"  // NEW: "US" or "CA"
}
```

### 3.3 AppViewModel.swift Updates

**Location:** `/Users/eddym/Downloads/app/carrer/carrer/ViewModels/Shared/AppViewModel.swift`

**Add country preference:**

```swift
class AppViewModel: ObservableObject {
    // ... existing properties ...

    // NEW: Country preference
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
        }
    }

    // Update fetchCareerMatches to use country
    func fetchCareerMatches() async {
        // ... existing code ...

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

        // ... rest of code ...
    }
}
```

---

## Phase 4: UI Changes

### 4.1 Onboarding: Country Selection

**New View:** `CountrySelectionView.swift`

**Location:** Insert after welcome screen, before RIASEC questions

**Design:**

```swift
struct CountrySelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedCountry: CountryCode = .unitedStates

    var body: some View {
        VStack(spacing: 32) {
            Text("Where are you located?")
                .font(.title)
                .fontWeight(.bold)

            Text("We'll personalize recommendations for your region")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                CountryButton(
                    country: .unitedStates,
                    isSelected: selectedCountry == .unitedStates,
                    action: { selectedCountry = .unitedStates }
                )

                CountryButton(
                    country: .canada,
                    isSelected: selectedCountry == .canada,
                    action: { selectedCountry = .canada }
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button("Continue") {
                viewModel.userCountry = selectedCountry
                // Navigate to next onboarding step
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(false)
        }
        .padding()
        .navigationTitle("Country")
        .onAppear {
            selectedCountry = viewModel.userCountry
        }
    }
}

struct CountryButton: View {
    let country: CountryCode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(country.flag)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(country.displayName)
                        .font(.headline)
                    Text("Occupational data: \(country == .unitedStates ? "O*NET" : "OaSIS/NOC")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                        .font(.title2)
                }
            }
            .padding(20)
            .background(isSelected ? AppColors.primary.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
```

**Integration Point:** Insert in `OnboardingView.swift` after welcome page

### 4.2 Settings: Country Preference Toggle

**Update:** `SettingsView.swift` (or create if doesn't exist)

**Add setting:**

```swift
Section(header: Text("Region")) {
    Picker("Country", selection: $viewModel.userCountry) {
        ForEach([CountryCode.unitedStates, CountryCode.canada], id: \.self) { country in
            HStack {
                Text(country.flag)
                Text(country.displayName)
            }
            .tag(country)
        }
    }
    .pickerStyle(.menu)

    Text("Career recommendations will be based on \(viewModel.userCountry == .unitedStates ? "U.S. O*NET" : "Canadian OaSIS/NOC") data")
        .font(.caption)
        .foregroundColor(.secondary)
}
```

### 4.3 Career Detail View: Data Source Badge

**Update:** `ONetCareerDetailView.swift`

**Add badge showing data source:**

```swift
// In attributionSection
private var attributionSection: some View {
    VStack(spacing: 4) {
        if careerTrack.dataSource == "OASIS_2023_V1" {
            Text("Powered by OaSIS")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("Employment and Social Development Canada")
                .font(.caption2)
                .foregroundColor(.secondary)
        } else {
            Text("Powered by O*NET")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("U.S. Department of Labor")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 24)
}
```

---

## Phase 5: Implementation Roadmap

### 5.1 Snowflake Data Import (Week 1)

**Steps:**

1. **Upload CSV files to Snowflake stage**
   ```sql
   -- Create stage for NOC data
   CREATE STAGE IF NOT EXISTS NOC_STAGE;

   -- Upload files via SnowSQL or Snowsight UI
   PUT file:///path/to/noc2021_onet26.csv @NOC_STAGE;
   PUT file:///path/to/skills_oasis_2023_v1.0.csv @NOC_STAGE;
   PUT file:///path/to/interests_oasis_2023_v1.0.csv @NOC_STAGE;
   -- ... upload all 32 OaSIS files
   ```

2. **Create staging tables**
   ```sql
   -- Temporary tables for raw CSV data
   CREATE TABLE OASIS_SKILLS_RAW (...);
   CREATE TABLE OASIS_INTERESTS_RAW (...);
   CREATE TABLE OASIS_ABILITIES_RAW (...);
   -- ... one staging table per CSV
   ```

3. **Load data from stage**
   ```sql
   COPY INTO OASIS_SKILLS_RAW
   FROM @NOC_STAGE/skills_oasis_2023_v1.0.csv
   FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);
   ```

4. **Transform and populate final tables**
   ```sql
   INSERT INTO CAREER_FULL_VECTORS_NOC
   SELECT
       s.OASIS_CODE AS NOC_CODE,
       s.OASIS_LABEL AS JOB_TITLE_EN,
       -- Convert Holland Codes to RIASEC scores
       CASE WHEN i.HOLLAND_CODE_1 = 'R' THEN 5.0
            WHEN i.HOLLAND_CODE_2 = 'R' THEN 3.5
            WHEN i.HOLLAND_CODE_3 = 'R' THEN 2.0
            ELSE 1.0 END AS REALISTIC,
       -- ... repeat for I, A, S, E, C
       -- Normalize Personal Attributes (1-5) to Work Values (0-1)
       pa.ACHIEVEMENT / 5.0 AS ACHIEVEMENT,
       -- ... rest of transformations
   FROM OASIS_SKILLS_RAW s
   LEFT JOIN OASIS_INTERESTS_RAW i ON s.OASIS_CODE = i.OASIS_CODE
   LEFT JOIN OASIS_PERSONAL_ATTRS_RAW pa ON s.OASIS_CODE = pa.OASIS_CODE;
   ```

5. **Validate data quality**
   ```sql
   -- Check row counts (expect 900 occupations)
   SELECT COUNT(*) FROM CAREER_FULL_VECTORS_NOC;  -- Should be ~900

   -- Check RIASEC distribution
   SELECT
       AVG(REALISTIC), AVG(INVESTIGATIVE), AVG(ARTISTIC),
       AVG(SOCIAL), AVG(ENTERPRISING), AVG(CONVENTIONAL)
   FROM CAREER_FULL_VECTORS_NOC;
   -- Expect values between 1.5-3.0 (normal distribution)

   -- Check for nulls
   SELECT COUNT(*) FROM CAREER_FULL_VECTORS_NOC
   WHERE JOB_TITLE_EN IS NULL OR REALISTIC IS NULL;  -- Should be 0
   ```

**Deliverable:** SQL script `NOC_DATA_IMPORT_V1.sql`

### 5.2 Create NOC Stored Procedures (Week 1-2)

**Steps:**

1. **Copy Recipe D v4.0 procedure**
   ```bash
   cp RECIPE_D_STEP4_PROCEDURE_V4.sql RECIPE_NOC_PROCEDURE_V1.sql
   ```

2. **Modify for NOC table**
   - Change table name: `CAREER_FULL_VECTORS` → `CAREER_FULL_VECTORS_NOC`
   - Change column names: `ONET_SOC_CODE` → `NOC_CODE`, `JOB_TITLE` → `JOB_TITLE_EN`
   - Keep all matching logic identical

3. **Create unified wrapper**
   ```sql
   CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V4_UNIFIED(...);
   ```

4. **Test with sample data**
   ```sql
   -- Test NOC version
   CALL SP_GET_CAREER_MATCHES_V4_NOC(
       2.0, 5.0, 2.5, 3.0, 3.0, 4.0,  -- RIASEC
       5.0, 5.0, 3.0, 2.5, 2.5, 3.5,  -- Work values
       '["Math"]', '["Coding"]', '["Software Developer"]',
       'Undergraduate', 'Student'
   );
   -- Expect: NOC 21232 (Software developers) in top 5
   ```

**Deliverable:** SQL script `RECIPE_NOC_PROCEDURE_V1.sql`

### 5.3 Swift Service Layer Updates (Week 2)

**Steps:**

1. **Add CountryCode enum** (SnowflakeService.swift)
2. **Update getCareerMatches signature** (add country parameter)
3. **Add UserDataKey.userCountry** (UserDataKey.swift)
4. **Add AppViewModel.userCountry property** (AppViewModel.swift)
5. **Update fetchCareerMatches call** (pass country parameter)
6. **Add CareerTrack.dataSource field** (for attribution)

**Testing:**
- Unit tests for country toggling
- Integration test: Fetch recommendations for both countries
- Compare match scores (should be similar for aligned occupations)

**Deliverable:**
- Updated Swift files (6 files)
- Unit tests (`SnowflakeServiceTests.swift`)

### 5.4 UI Implementation (Week 2-3)

**Steps:**

1. **Create CountrySelectionView.swift**
   - Design country picker with flags
   - Add to onboarding flow (page 2)

2. **Update OnboardingView.swift**
   - Insert country selection page after welcome
   - Pass country to AppViewModel

3. **Create SettingsView.swift** (if doesn't exist)
   - Add Region section
   - Country picker (can change after onboarding)
   - Warning: "Changing country will reset recommendations"

4. **Update ONetCareerDetailView.swift**
   - Add data source attribution badge
   - Handle NOC vs O*NET display differences

5. **Update MainAppView.swift**
   - Add country indicator in header (optional)

**Design Review:**
- User testing with 5-10 beta testers
- A/B test: Default country selection (geolocation vs manual)

**Deliverable:**
- 5 new/updated Swift view files
- Screenshots for App Store

### 5.5 Testing & Validation (Week 3)

**Test Matrix:**

| Test Case | Country | Expected Result |
|-----------|---------|----------------|
| **Software Developer** | US | O*NET 15-1252.00 in top 5 |
| **Software Developer** | CA | NOC 21232 in top 5 |
| **Teacher** | US | O*NET 25-2021.00 in top 3 |
| **Teacher** | CA | NOC 41200 in top 3 |
| **Toggle Country** | Switch US→CA | Recommendations refresh |
| **Missing Data** | CA | Gracefully handle missing work values |
| **Performance** | Both | Response time < 2s |

**Validation Metrics:**

1. **Coverage:** How many NOC occupations have matches?
   ```sql
   -- Target: 85%+ of 900 NOC occupations
   SELECT
       COUNT(DISTINCT n.NOC_CODE) AS mapped_noc,
       (SELECT COUNT(*) FROM CAREER_FULL_VECTORS_NOC) AS total_noc,
       (mapped_noc / total_noc * 100) AS coverage_pct
   FROM NOC_ONET_CROSSWALK n
   WHERE n.ONET_CODE IS NOT NULL;
   ```

2. **Match Quality:** Are top matches reasonable?
   - Manual review of top 10 careers for 20 sample profiles
   - Compare O*NET vs NOC results for same user
   - User survey: "Are these careers relevant?" (target: 80% yes)

3. **Performance:** Latency benchmarks
   - O*NET procedure: 1.5s average
   - NOC procedure: Target 1.5s (similar complexity)
   - Network overhead: +0.3s acceptable

**Deliverable:**
- Test report with metrics
- Bug fixes based on findings
- Performance optimization if needed

### 5.6 Deployment & Rollout (Week 4)

**Phase 1: Beta (Week 4)**
- Deploy to TestFlight with 100 beta users
- 50 Canadian users, 50 U.S. users
- Monitor analytics: Country selection %, error rates, match quality feedback
- Hotfix window: 48 hours for critical issues

**Phase 2: Production (Week 5)**
- Feature flag: Enable for 10% of users
- Monitor for 3 days
- Gradual rollout: 25% → 50% → 100%
- Full rollout by end of week

**Monitoring:**
- Snowflake query performance (dashboard)
- Error rate by country (target: <0.5%)
- User engagement: Do Canadian users stay longer?
- Conversion: Do Canadian users complete onboarding more?

**Deliverable:**
- App Store update (v2.0: "Canadian Occupations Support")
- Release notes
- Marketing materials highlighting Canadian support

---

## Phase 6: Maintenance & Future Enhancements

### 6.1 Quarterly Data Updates

**OaSIS Update Cycle:**
- OaSIS releases updates quarterly
- Download latest CSVs from Open Canada Portal
- Run import script `NOC_DATA_IMPORT_V1.sql` (idempotent)
- Validate data quality (same checks as initial import)
- Deploy to production during off-peak hours

**Automation:**
- Cron job: Check Open Canada API for new versions
- Alert if new data available
- Semi-automated import (human approval required)

### 6.2 Future Enhancements (Backlog)

1. **Job Bank Integration** (Canada-specific)
   - Real-time job postings from Job Bank API
   - Labor market trends (growing/declining occupations)
   - Regional salary data (by province)

2. **Bilingual Support** (French/English)
   - NOC data includes French titles/descriptions
   - Allow user to toggle language
   - French onboarding flow

3. **Provincial Filters**
   - Filter by province (Ontario, Quebec, BC, etc.)
   - Regional occupation demand data
   - Province-specific licensing requirements

4. **NOC-O*NET Hybrid Matching**
   - For Canadian users, show both NOC and equivalent O*NET careers
   - "Similar careers in the U.S." section
   - Cross-border career planning

5. **Improved Work Values Mapping**
   - Current: Simple division by 5
   - Enhancement: ML model to learn optimal mapping from user feedback
   - A/B test: Does better mapping improve match quality?

6. **Skills Gap Analysis (Canada)**
   - Compare user skills to in-demand Canadian skills
   - Link to training programs (colleges/universities)
   - Partnership with Canadian education institutions

---

## Risk Assessment & Mitigation

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **Data quality issues in OaSIS** | Medium | High | Extensive validation queries, fallback to O*NET for missing data |
| **RIASEC conversion inaccuracy** | Medium | Medium | A/B test conversion formula, validate with user feedback |
| **Performance degradation** | Low | Medium | Index NOC table, cache results, load testing |
| **Snowflake cost increase** | Low | Low | Monitor query usage, optimize procedures |
| **NOC-O*NET mapping gaps** | High | Medium | Handle missing mappings gracefully, show partial matches |

### Business Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **Low Canadian user adoption** | Medium | Low | Marketing campaign, partnerships with Canadian schools |
| **User confusion (2 datasets)** | Medium | Medium | Clear UI explanation, seamless country toggle |
| **Legal/licensing issues** | Low | High | OaSIS is CC BY 4.0 (open), proper attribution in app |
| **Maintenance burden** | Medium | Medium | Automate updates, document procedures |

### Data Integrity Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **Corrupt CSV files** | Low | High | Checksum validation, staging tables, rollback plan |
| **Snowflake schema drift** | Medium | High | Version control for SQL scripts, schema diff tool |
| **Test data in production** | Low | Critical | Separate dev/prod databases, QA checklist |

---

## Success Metrics

### Launch Targets (Month 1)

- ✅ 900 NOC occupations imported (100% coverage)
- ✅ 85%+ NOC-O*NET crosswalk coverage
- ✅ Match quality: 80%+ users rate top 5 as "relevant"
- ✅ Performance: < 2s response time (p95)
- ✅ Error rate: < 0.5%
- ✅ Canadian user activation: 20%+ select Canada

### Growth Targets (Month 3)

- 📈 Canadian users: 30% of user base
- 📈 User satisfaction: 4.5+ stars from Canadian users
- 📈 Engagement: Canadian users have 10%+ higher session time
- 📈 Conversion: Canadian users complete onboarding at 85%+ rate

### Long-term (6 months)

- 🎯 Market share: Top 3 career app in Canada (App Store ranking)
- 🎯 Partnerships: 5+ Canadian universities using MyPath
- 🎯 Data freshness: Quarterly updates automated
- 🎯 Feature parity: Canadian users have all features of U.S. users

---

## Appendix

### A. File Inventory

**NOC Data Files** (`/Users/eddym/Downloads/app/carrer/NOC/`):

```
Crosswalk:
- noc2021_onet26.csv (141KB) - NOC-to-O*NET mappings

OaSIS Data (English):
- 0ee24456-1c35-41a4-ac7d-e1422e5e2117.csv - Guide
- 38932102-f7a9-40c6-b4f1-fa8e81981726.csv - Skills
- 9a7e1f06-c079-4f48-92c4-9387d43de19d.csv - Abilities
- 0131ca04-0379-4c1f-b814-05fb139b9718.csv - Interests ⭐
- 5dae7457-99a9-4db5-b1a0-e77365bf3dfc.csv - Knowledge
- 0958eaa1-766d-4a93-9228-8cd9b19bb18e.csv - Personal Attributes
- 52063d66-4a70-4898-82fa-cbb24617a1d4.csv - Work Activities
- 93a88c2d-3465-4117-9c26-3f722675a2de.csv - Work Context
- 8cc1bd89-afa1-4cfe-b45a-d6511d9318d7.csv - Lead Statement
- 79361933-2793-4e1e-b255-b6fa214ef28d.csv - Main Duties
- 66414d34-029e-4d0e-b6e5-ae3d99a73fac.csv - Example Titles
- 053f7e1c-e629-432e-a70f-ed043e028f65.csv - Employment Requirements
- 2cbfc470-e16b-473f-a69d-cf385289a83c.csv - Labels
- 075cceec-210a-4d06-856f-a8f289a8f9b1.csv - Workplaces Employers
- 9e785ec0-a7b8-4e2d-b8ad-9982c56ca67e.csv - Additional Information
- 6a4bc765-6284-4e1a-aab8-1748210f80a0.csv - Exclusions

OaSIS Data (French):
- 147f5c1a-f90e-4787-86a0-dff4ec19855e.csv - Guide (FR)
- e34b2a36-9844-4e3c-9549-78a2a1f60478.csv - Compétences (FR)
- ... (16 French equivalents)

Metadata:
- package_show.json - Dataset metadata from Open Canada Portal
```

### B. Key Contacts & Resources

**Data Sources:**
- OaSIS Portal: https://open.canada.ca/data/en/dataset/4f344cd6-0912-411a-ae16-41ea160cc8b5
- NOC 2021 Crosswalk: https://github.com/thedaisTMU/NOC_ONet_Crosswalk
- O*NET Resource Center: https://www.onetcenter.org/
- Canadian Job Bank API: https://www.jobbank.gc.ca/api

**Documentation:**
- OaSIS User Guide: https://noc.esdc.gc.ca/OaSIS/OaSISWelcome
- NOC 2021 Structure: https://noc.esdc.gc.ca/Structure/Hierarchy
- Recipe D v4.0 Architecture: `RECIPE_D_ARCHITECTURE.md`

**Support:**
- Employment and Social Development Canada: NC-CNP-NOC-GD@hrsdc-rhdcc.gc.ca
- O*NET Technical Support: onetcenter@air.org

### C. Glossary

- **OaSIS**: Occupational and Skills Information System (Canada)
- **NOC**: National Occupational Classification (Canada's occupation taxonomy)
- **O*NET**: Occupational Information Network (U.S. occupation taxonomy)
- **RIASEC**: Holland Codes - Realistic, Investigative, Artistic, Social, Enterprising, Conventional
- **Recipe D v4.0**: MyPath's 4-dimensional career matching algorithm
- **Cosine Similarity**: Vector similarity metric (0-1 scale)
- **Snowflake**: Cloud data warehouse used for career matching
- **Swift**: Programming language for iOS app

### D. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-12 | Claude Code | Initial plan, comprehensive architecture design |

---

## Next Steps

⚠️ **USER APPROVAL REQUIRED BEFORE PROCEEDING**

This plan requires explicit approval due to:
1. **Foundational changes** to database schema
2. **New tables** in Snowflake (cost implications)
3. **API changes** affecting all career matching
4. **3-4 week timeline** for full implementation

**Questions for User:**

1. ✅ Approve overall architecture (parallel tables vs unified)?
2. ✅ Approve RIASEC conversion formula?
3. ✅ Approve country selection in onboarding flow?
4. ✅ Budget approval for Snowflake storage (~900 rows, minimal cost)?
5. ✅ Timeline acceptable (4 weeks to production)?
6. 📋 Any adjustments to scope or priorities?

**Once approved, I will:**
1. Generate backup copy of all Snowflake scripts
2. Create `NOC_DATA_IMPORT_V1.sql` import script
3. Create `RECIPE_NOC_PROCEDURE_V1.sql` stored procedure
4. Update Swift files (SnowflakeService, AppViewModel, UserDataKey)
5. Create CountrySelectionView.swift
6. Test thoroughly with sample data

**Estimated Time to First Working Prototype:** 2-3 days after approval

---

*Generated by Claude Code on 2025-10-12*
*Git Backup Commit: `15dc0c3`*
