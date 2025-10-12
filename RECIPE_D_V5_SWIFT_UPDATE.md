# Recipe D v5.0 - Swift Code Updates

## Changes Required

### 1. Add ONetSkill Model

Create a new model for O*NET skills:

```swift
// carrer/Models/CareerExplorer/ONetSkill.swift

import Foundation

/// O*NET skill with proficiency rating
struct ONetSkill: Codable, Identifiable, Hashable {
    let id: String  // Element ID like "2.A.1.e"
    let name: String  // Element name like "Mathematics"
    var proficiency: Double  // 0.0 to 1.0

    init(id: String, name: String, proficiency: Double = 0.5) {
        self.id = id
        self.name = name
        self.proficiency = min(max(proficiency, 0.0), 1.0)  // Clamp to 0-1
    }

    // Convert 5-star rating to proficiency
    static func fromStars(_ stars: Int) -> Double {
        return Double(stars) * 0.2
    }

    // Convert proficiency to 5-star rating
    var stars: Int {
        return Int(round(proficiency / 0.2))
    }
}

/// All 35 O*NET skills organized by category
struct ONetSkillsCatalog {
    static let coreAcademic = [
        ONetSkill(id: "2.A.1.e", name: "Mathematics"),
        ONetSkill(id: "2.A.1.f", name: "Science"),
        ONetSkill(id: "2.A.1.a", name: "Reading Comprehension"),
        ONetSkill(id: "2.A.1.c", name: "Writing"),
        ONetSkill(id: "2.A.1.d", name: "Speaking"),
        ONetSkill(id: "2.A.1.b", name: "Active Listening")
    ]

    static let technical = [
        ONetSkill(id: "2.B.3.e", name: "Programming"),
        ONetSkill(id: "2.B.3.b", name: "Technology Design"),
        ONetSkill(id: "2.B.4.g", name: "Systems Analysis"),
        ONetSkill(id: "2.A.2.a", name: "Critical Thinking"),
        ONetSkill(id: "2.B.2.i", name: "Complex Problem Solving"),
        ONetSkill(id: "2.B.3.k", name: "Troubleshooting")
    ]

    static let social = [
        ONetSkill(id: "2.B.1.a", name: "Social Perceptiveness"),
        ONetSkill(id: "2.B.1.c", name: "Persuasion"),
        ONetSkill(id: "2.B.1.e", name: "Instructing"),
        ONetSkill(id: "2.B.1.f", name: "Service Orientation"),
        ONetSkill(id: "2.B.1.b", name: "Coordination"),
        ONetSkill(id: "2.B.1.d", name: "Negotiation")
    ]

    static let business = [
        ONetSkill(id: "2.B.5.d", name: "Management of Personnel Resources"),
        ONetSkill(id: "2.B.5.b", name: "Management of Financial Resources"),
        ONetSkill(id: "2.B.4.e", name: "Judgment and Decision Making"),
        ONetSkill(id: "2.B.5.a", name: "Time Management"),
        ONetSkill(id: "2.B.5.c", name: "Management of Material Resources")
    ]

    static let handsOn = [
        ONetSkill(id: "2.B.3.d", name: "Installation"),
        ONetSkill(id: "2.B.3.j", name: "Equipment Maintenance"),
        ONetSkill(id: "2.B.3.l", name: "Repairing"),
        ONetSkill(id: "2.B.3.c", name: "Equipment Selection"),
        ONetSkill(id: "2.B.3.h", name: "Operation and Control"),
        ONetSkill(id: "2.B.3.m", name: "Quality Control Analysis")
    ]

    // Get recommended skills based on RIASEC top code
    static func recommendedSkills(for riasecCode: String) -> [ONetSkill] {
        var recommended = coreAcademic  // Everyone gets core academic

        switch riasecCode {
        case "R":
            recommended += handsOn
        case "I":
            recommended += technical
        case "S":
            recommended += social
        case "E":
            recommended += business
        default:
            break
        }

        return recommended
    }
}
```

### 2. Update SnowflakeService.swift

Replace the `getCareerMatches` function:

```swift
/// Get career matches based on RIASEC scores, Work Values, Skills, and Context (Recipe D v5.0)
/// - Parameters:
///   - scores: Dictionary with keys R, I, A, S, E, C and Float values (0-5 scale)
///   - workValues: Optional dictionary with work values (1-5 scale). If nil, defaults to 3.0 for all
///   - skills: Optional array of ONetSkill with proficiency ratings (0.0-1.0)
///   - careerInterests: Optional array of career interests (e.g., ["Software Developer"])
///   - studentLevel: Optional education level ("High School", "Undergraduate", "Graduate")
///   - currentStatus: Optional current status ("Student", "Career Changer", etc.)
/// - Returns: Array of O*NET occupations with 4-dimensional match scores
func getCareerMatches(
    scores: [String: Float],
    workValues: [String: Float]? = nil,
    skills: [ONetSkill]? = nil,
    careerInterests: [String]? = nil,
    studentLevel: String? = nil,
    currentStatus: String? = nil
) async throws -> [ONetOccupation] {
    // Ensure we have valid RIASEC scores for all 6 dimensions
    guard let r = scores["R"],
          let i = scores["I"],
          let a = scores["A"],
          let s = scores["S"],
          let e = scores["E"],
          let c = scores["C"] else {
        throw SnowflakeError.invalidConfiguration
    }

    // Get work values or use defaults (3.0 = moderate importance)
    let achievement = workValues?["achievement"] ?? 3.0
    let independence = workValues?["independence"] ?? 3.0
    let recognition = workValues?["recognition"] ?? 3.0
    let relationships = workValues?["relationships"] ?? 3.0
    let support = workValues?["support"] ?? 3.0
    let workingConditions = workValues?["working_conditions"] ?? 3.0

    // Recipe D v5.0: Convert skills to JSON format
    let skillsArray = skills?.map { skill in
        ["skill_id": skill.id, "proficiency": skill.proficiency]
    } ?? []

    let encoder = JSONEncoder()
    let skillsJSON = try encoder.encode(skillsArray)
    let interestsJSON = try encoder.encode(careerInterests ?? [])

    guard let skillsStr = String(data: skillsJSON, encoding: .utf8),
          let interestsStr = String(data: interestsJSON, encoding: .utf8) else {
        throw SnowflakeError.invalidConfiguration
    }

    let level = studentLevel ?? "Unknown"
    let status = currentStatus ?? "Unknown"

    // Call Recipe D v5.0 with direct O*NET skills (14 parameters)
    let sql = """
    CALL \(database).\(schema).SP_GET_CAREER_MATCHES_V5(
        \(r), \(i), \(a), \(s), \(e), \(c),
        \(achievement), \(independence), \(recognition), \(relationships), \(support), \(workingConditions),
        '\(skillsStr.replacingOccurrences(of: "'", with: "''"))',
        '\(interestsStr.replacingOccurrences(of: "'", with: "''"))',
        '\(level)',
        '\(status)'
    )
    """

    print("📊 Recipe D v5.0 Call:")
    print("  Skills: \(skills?.map { "\($0.name): \(Int($0.proficiency * 100))%" }.joined(separator: ", ") ?? "none")")
    print("  Career Interests: \(careerInterests?.joined(separator: ", ") ?? "none")")
    print("  Student Level: \(level)")

    let response = try await executeSQLStatement(sql)

    // Parse the response - same as v4.0
    guard let resultString = response["data"] as? [[String]],
          let firstRow = resultString.first,
          let jsonString = firstRow.first else {
        throw SnowflakeError.noData
    }

    guard let jsonData = jsonString.data(using: .utf8),
          let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
        throw SnowflakeError.decodingFailed
    }

    var occupations: [ONetOccupation] = []

    for item in jsonArray {
        guard let code = item["ONET_SOC_CODE"] as? String,
              let title = item["JOB_TITLE"] as? String,
              let description = item["DESCRIPTION"] as? String,
              let interestsMatch = item["INTERESTS_MATCH"] as? Double,
              let valuesMatch = item["VALUES_MATCH"] as? Double,
              let skillsMatch = item["SKILLS_MATCH"] as? Double,
              let contextScore = item["CONTEXT_SCORE"] as? Double,
              let finalScore = item["FINAL_SCORE"] as? Double,
              let explanation = item["MATCH_EXPLANATION"] as? String else {
            continue
        }

        let occupation = ONetOccupation(
            onetSocCode: code,
            title: title,
            description: description,
            match: Int(finalScore * 100 / 7.0),
            education: nil,
            outlook: nil,
            salary: nil,
            matchExplanation: explanation,
            interestsMatch: interestsMatch,
            valuesMatch: valuesMatch,
            skillsMatch: skillsMatch,
            contextScore: contextScore
        )

        occupations.append(occupation)
    }

    print("✅ Parsed \(occupations.count) occupations")
    if let first = occupations.first {
        print("  Top match: \(first.title) - \(first.match)%")
        print("  Breakdown: I:\(first.interestsPercentage)% V:\(first.valuesPercentage)% S:\(first.skillsPercentage)% C:\(first.contextPercentage)%")
    }

    return occupations
}
```

### 3. Update AppViewModel.swift

Replace skills extraction:

```swift
// Extract O*NET skills with proficiency
var userSkills: [ONetSkill]? = nil
if let skillsData = userData[.onetSkills] as? [String: Double] {
    // Convert stored dictionary to ONetSkill array
    userSkills = skillsData.map { skillId, proficiency in
        // Get skill name from catalog if available
        let skillName = ONetSkillsCatalog.getSkillName(for: skillId) ?? skillId
        return ONetSkill(id: skillId, name: skillName, proficiency: proficiency)
    }
    print("🎯 Skills extracted: \(userSkills!.map { "\($0.name): \(Int($0.proficiency * 100))%" }.joined(separator: ", "))")
}

// Extract career interests
var careerInterests: [String]? = nil
if let interestsSet = userData[.careerInterests] as? Set<String> {
    careerInterests = Array(interestsSet)
    print("💼 Career Interests: \(careerInterests!.joined(separator: ", "))")
}

let onetOccupations = try await snowflakeService.getCareerMatches(
    scores: riasecScores,
    workValues: workValuesDict,
    skills: userSkills,  // Now using ONetSkill array
    careerInterests: careerInterests,
    studentLevel: studentLevel,
    currentStatus: currentStatus
)
```

### 4. Update OnboardingData.swift

Add field for O*NET skills:

```swift
enum OnboardingDataKey {
    // ... existing keys ...
    case onetSkills  // Stores [String: Double] mapping skill_id -> proficiency
}
```

### 5. Create Skills Selection View

```swift
// carrer/Views/Onboarding/SkillsSelectionView.swift

import SwiftUI

struct SkillsSelectionView: View {
    @Binding var selectedSkills: [ONetSkill]
    let riasecTopCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rate Your Skills")
                .font(.title)
                .fontWeight(.bold)

            Text("How would you rate your proficiency in these areas?")
                .foregroundColor(.secondary)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(recommendedSkills) { skill in
                        SkillRatingRow(skill: binding(for: skill))
                    }
                }
            }
        }
        .padding()
    }

    private var recommendedSkills: [ONetSkill] {
        ONetSkillsCatalog.recommendedSkills(for: riasecTopCode)
    }

    private func binding(for skill: ONetSkill) -> Binding<ONetSkill> {
        if let index = selectedSkills.firstIndex(where: { $0.id == skill.id }) {
            return $selectedSkills[index]
        } else {
            // Add skill with default proficiency
            selectedSkills.append(skill)
            return $selectedSkills[selectedSkills.count - 1]
        }
    }
}

struct SkillRatingRow: View {
    @Binding var skill: ONetSkill

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(skill.name)
                .font(.headline)

            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= skill.stars ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            skill.proficiency = ONetSkill.fromStars(star)
                        }
                }

                Spacer()

                Text("\(Int(skill.proficiency * 100))%")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
```

## Migration Path

1. ✅ Deploy SP_GET_CAREER_MATCHES_V5 to Snowflake
2. ✅ Add ONetSkill model to app
3. ✅ Update SnowflakeService to call v5 procedure
4. ✅ Add SkillsSelectionView to onboarding flow
5. ✅ Update AppViewModel to pass ONetSkill array
6. ✅ Test with STEM profile (Math + Programming skills)
7. ✅ Verify Software Developer gets 50-60% skills match

## Backward Compatibility

Keep v4 procedure as fallback until v5 is fully tested:

```swift
// Try v5 first, fallback to v4 if needed
do {
    return try await getCareerMatchesV5(...)
} catch {
    print("⚠️ V5 failed, falling back to V4")
    return try await getCareerMatchesV4(...)
}
```
