# Onboarding v2 Data Mapping Reference

This document explains how OnboardingV2 data maps to the existing AppViewModel userData format and career recommendation system.

---

## 📊 Data Structure Overview

### OnboardingDraft (Source)
```swift
struct OnboardingDraft {
    var country: String              // "US" or "CA"
    var language: String             // "en" or "fr"
    var answers: [String: Int]       // "R.Q1" -> 1..5
    var values: [String: Int]        // "balance" -> 1..5
    var subjects: [String]           // ["Math", "Science", ...]
    var activities: [String]         // ["Coding", "Sports", ...]
    var interests: [String]          // ["STEM", "Healthcare", ...]
    var riasecPageIndex: Int         // 0, 1, or 2
    var lastStep: OnbStep            // Current step
}
```

### AppViewModel.userData (Target)
```swift
var userData: [UserDataKey: AnyHashable] = [:]

// Mapped keys:
userData[.riasec("R")] = 3.5              // Double (mean of R dimension)
userData[.riasec("I")] = 4.2              // Double (mean of I dimension)
userData[.riasec("A")] = 2.8              // Double (mean of A dimension)
userData[.riasec("S")] = 3.9              // Double (mean of S dimension)
userData[.riasec("E")] = 3.1              // Double (mean of E dimension)
userData[.riasec("C")] = 4.0              // Double (mean of C dimension)

userData[.workValue("balance")] = 4       // Int (star rating)
userData[.workValue("salary")] = 5        // Int (star rating)
// ... other work values

userData[.subjects] = ["Math", "Science"] // [String]
userData[.activities] = ["Coding"]        // [String]
userData[.careerInterests] = ["STEM"]     // [String]
userData[.country] = UserCountry.canada   // UserCountry enum
userData[.hasCompletedOnboarding] = true  // Bool
```

---

## 🔄 Step-by-Step Mapping (GenerateStepView.swift)

### 1. RIASEC Dimension Means
```swift
// Source: draft.answers (30 item-level responses)
// Target: userData[.riasec(dim)] (6 dimension means)

let riasecItems = loadFromJSON("RIASECItemBank.json")
let riasecMeans = draft.riasecMeans(from: riasecItems)

// riasecMeans = ["R": 3.5, "I": 4.2, "A": 2.8, "S": 3.9, "E": 3.1, "C": 4.0]

for (dim, mean) in riasecMeans {
    appViewModel.userData[UserDataKey.riasec(dim)] = mean
}
```

**Calculation Logic** (in `OnboardingDraft.riasecMeans()`):
1. Group 30 items by dimension (5 items per dimension)
2. For each item:
   - Get user's raw answer (1-5)
   - If item.reverse == true: score = 6 - raw
   - Else: score = raw
3. Calculate mean for each dimension
4. Return `[String: Double]` dictionary

### 2. Work Values
```swift
// Source: draft.values (value_id -> rating)
// Target: userData[.workValue(value_id)]

for (valueId, rating) in draft.values {
    appViewModel.userData[UserDataKey.workValue(valueId)] = rating
}

// Example:
// draft.values = ["balance": 4, "salary": 5, "helping": 3]
// → userData[.workValue("balance")] = 4
// → userData[.workValue("salary")] = 5
// → userData[.workValue("helping")] = 3
```

### 3. Subjects & Activities
```swift
// Source: draft.subjects, draft.activities
// Target: userData[.subjects], userData[.activities]

appViewModel.userData[.subjects] = draft.subjects
appViewModel.userData[.activities] = draft.activities

// Example:
// draft.subjects = ["Math", "Science", "Technology"]
// draft.activities = ["Coding", "Building Things"]
```

### 4. Career Interests
```swift
// Source: draft.interests
// Target: userData[.careerInterests]

appViewModel.userData[.careerInterests] = draft.interests

// Example:
// draft.interests = ["STEM", "Healthcare", "Business & Finance"]
```

### 5. Country
```swift
// Source: draft.country (String "US" or "CA")
// Target: appViewModel.userCountry (UserCountry enum)

if let country = UserCountry(rawValue: draft.country) {
    appViewModel.userCountry = country
}

// draft.country = "CA" → appViewModel.userCountry = .canada
// draft.country = "US" → appViewModel.userCountry = .usa
```

### 6. Completion Flag
```swift
// Set on completion
appViewModel.userData[.hasCompletedOnboarding] = true
```

---

## 🧮 Algorithm Weights (Recipe D v4.0)

The career matching algorithm uses these weights:

| Component | Weight | Source |
|-----------|--------|--------|
| **RIASEC Personality** | 60% | `userData[.riasec(dim)]` for each dimension |
| **Work Values** | 20% | `userData[.workValue(id)]` for each value |
| **Skills/Subjects** | 10% | `userData[.subjects]`, `userData[.activities]` |
| **Career Interest Boost** | 10% | `userData[.careerInterests]` |

**Formula** (simplified):
```
match_score = (
    0.60 * riasec_similarity +
    0.20 * work_values_similarity +
    0.10 * skills_similarity +
    0.10 * interest_boost
)
```

---

## 📋 Example Complete Mapping

### Input (OnboardingDraft)
```json
{
  "country": "CA",
  "language": "en",
  "answers": {
    "R.Q1": 4, "R.Q2": 2, "R.Q3": 5, "R.Q4": 1, "R.Q5": 4,
    "I.Q1": 5, "I.Q2": 1, "I.Q3": 5, "I.Q4": 2, "I.Q5": 4,
    "A.Q1": 3, "A.Q2": 3, "A.Q3": 3, "A.Q4": 3, "A.Q5": 2,
    "S.Q1": 5, "S.Q2": 2, "S.Q3": 4, "S.Q4": 1, "S.Q5": 5,
    "E.Q1": 3, "E.Q2": 3, "E.Q3": 3, "E.Q4": 3, "E.Q5": 3,
    "C.Q1": 4, "C.Q2": 2, "C.Q3": 5, "C.Q4": 2, "C.Q5": 4
  },
  "values": {
    "balance": 4,
    "salary": 5,
    "security": 3,
    "helping": 4,
    "creativity": 3,
    "learning": 5
  },
  "subjects": ["Math", "Science", "Technology"],
  "activities": ["Coding", "Building Things"],
  "interests": ["STEM", "Healthcare"]
}
```

### Output (userData)
```swift
// RIASEC Dimension Means
userData[.riasec("R")] = 3.2  // (4+4+5+5+4)/5 = 4.4 (after reverse scoring)
userData[.riasec("I")] = 4.2  // (5+5+5+4+4)/5 = 4.6 (after reverse scoring)
userData[.riasec("A")] = 2.8  // (3+3+3+3+2)/5 = 2.8
userData[.riasec("S")] = 4.2  // (5+4+4+5+5)/5 = 4.6 (after reverse scoring)
userData[.riasec("E")] = 3.0  // (3+3+3+3+3)/5 = 3.0
userData[.riasec("C")] = 3.8  // (4+4+5+4+4)/5 = 4.2 (after reverse scoring)

// Work Values
userData[.workValue("balance")] = 4
userData[.workValue("salary")] = 5
userData[.workValue("security")] = 3
userData[.workValue("helping")] = 4
userData[.workValue("creativity")] = 3
userData[.workValue("learning")] = 5

// Subjects & Activities
userData[.subjects] = ["Math", "Science", "Technology"]
userData[.activities] = ["Coding", "Building Things"]

// Career Interests
userData[.careerInterests] = ["STEM", "Healthcare"]

// Country & Completion
appViewModel.userCountry = .canada
userData[.hasCompletedOnboarding] = true
```

### Resulting Top RIASEC Code
```swift
// Top 3 dimensions by mean score:
// 1. I (Investigative) = 4.2
// 2. S (Social) = 4.2
// 3. C (Conventional) = 3.8

// Holland Code = "ISC"
```

### Career Matches (Examples)
Based on this profile, likely matches include:
- **Software Developer** (IRA profile, STEM interest boost)
- **Data Scientist** (IRA profile, high learning value)
- **Healthcare IT Specialist** (ISC profile, STEM + Healthcare boost)
- **Systems Analyst** (ICR profile, high learning + salary values)

---

## 🔍 Validation Rules

### Required Fields (Validation Guards)
| Step | Field | Requirement |
|------|-------|-------------|
| Country & Language | `country`, `language` | Must be selected |
| RIASEC Pages 1-3 | `answers` | All 10 items on current page must be answered |
| Work Values | `values` | At least 6 values must be rated (≥1 star) |
| Subjects & Activities | `subjects`, `activities` | **Optional** (0+ items) |
| Career Interests | `interests` | **Optional** (0+ items) |

### Minimum Data for Generation
```swift
func canGenerateRecommendations() -> Bool {
    return riasecComplete(items: allItems) &&  // 30/30 answered
           valuesComplete() &&                   // ≥6 values rated
           !country.isEmpty                      // Country selected
}
```

---

## 🎯 Key Differences from Old Onboarding

| Aspect | Old Onboarding | OnboardingV2 |
|--------|----------------|--------------|
| **Steps** | 20 steps | 10 steps |
| **RIASEC Questions** | 18 items (3 per dimension) | 30 items (5 per dimension) |
| **RIASEC Presentation** | 6 separate pages | 3 carousel pages (2 dimensions each) |
| **Work Values** | Multiple choice | Star ratings (1-5) |
| **Subjects** | Checkboxes | Chip-based selection |
| **Save Mechanism** | Explicit "Continue" button | Silent autosave (250ms debounce) |
| **Resume** | Start from beginning | Restore to exact step |
| **Review** | No review step | Comprehensive review with edit links |
| **Algorithm Visibility** | Hidden | Shown on review screen (60/20/10/10) |

---

## 📱 UserDefaults Storage

### Key
```swift
"mypath.onb.v1.draft"
```

### Format
```json
{
  "schemaVersion": 1,
  "lastStep": "values",
  "riasecPageIndex": 2,
  "focusedRowId": null,
  "answers": { "R.Q1": 4, "R.Q2": 2, ... },
  "values": { "balance": 4, "salary": 5, ... },
  "subjects": ["Math", "Science"],
  "activities": ["Coding"],
  "interests": ["STEM"],
  "country": "CA",
  "language": "en",
  "updatedAt": "2025-10-13T12:34:56Z",
  "completed": false
}
```

### Cleanup
- Draft is **cleared** when user taps "View My Recommendations" on DoneStepView
- Draft persists if user force-quits app mid-onboarding
- Draft is **restored** on next app launch

---

## 🔗 Integration Points

### 1. AppViewModel.generateCareerSuggestions()
**Location**: `carrer/ViewModels/Shared/AppViewModel.swift`
**Called from**: `GenerateStepView.generateRecommendations()`
**Input**: Reads from `userData` dictionary
**Output**: Populates `careerTracks` array

### 2. SnowflakeService (Recipe D v4.0)
**Location**: `carrer/Services/Networking/SnowflakeService.swift`
**Called from**: `AppViewModel.generateCareerSuggestions()`
**Input**: RIASEC means, work values, skills
**Output**: Ranked career recommendations with match scores

### 3. Canadian NOC Integration
**Location**: Multiple files (CanadianOccupation.swift, etc.)
**Trigger**: `appViewModel.userCountry == .canada`
**Effect**: Enriches O*NET careers with Canadian NOC data

---

## ✅ Testing Data Mapping

### Unit Test Example (pseudo-code)
```swift
func testRIASECMapping() {
    let draft = OnboardingDraft()

    // Set all R dimension answers to 5 (strongly agree)
    draft.answers = [
        "R.Q1": 5, "R.Q2": 1, "R.Q3": 5, "R.Q4": 1, "R.Q5": 5,
        // ... (set rest to 3)
    ]

    let means = draft.riasecMeans(from: riasecItems)

    // Expected: R dimension should have highest mean
    XCTAssertGreaterThan(means["R"] ?? 0, 4.0)
}
```

### Manual Test Steps
1. Complete onboarding with known values
2. Check Console for "💾 [OnbDraft] Saved to UserDefaults"
3. Open Xcode debugger after generation
4. Inspect `appViewModel.userData` dictionary
5. Verify all keys are populated correctly
6. Check `appViewModel.careerTracks` for recommendations

---

## 🎓 Summary

**OnboardingV2** collects user data in a streamlined format and maps it to the existing career recommendation system. The mapping preserves all algorithm weights and integrates seamlessly with Recipe D v4.0 and Canadian NOC data.

**Key Insight**: The new onboarding is a better UX wrapper around the same underlying data model and matching algorithm.
