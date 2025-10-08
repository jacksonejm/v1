# Recipe C+ Implementation Plan
## Incorporating Subjects, Activities, and Career Interests

**Status:** Planning Phase
**Current:** Recipe C v3.0 (Interests + Work Values)
**Goal:** Recipe C+ (Interests + Values + Skills + Context)

---

## 📊 Current State Analysis

### Data We Collect But Don't Use for Matching:

1. **Favorite Subjects** (userData[.favoriteSubjects])
   - Math, Science, English, History, Art, Music, etc.
   - Users select up to 3 subjects
   - Indicates academic strengths and interests

2. **Extracurricular Activities** (userData[.extracurriculars])
   - Sports, Drama, Debate, Volunteering, Coding, etc.
   - Multiple selection allowed
   - Reveals skills, interests, and personality

3. **Career Interests** (userData[.careerInterests])
   - Specific careers user has expressed interest in
   - Direct preferences and exploration history

4. **Student Level** (userData[.studentLevel])
   - High School, Undergraduate, Graduate
   - Indicates education level and timeline

5. **Current Status** (userData[.currentStatus])
   - Student, Professional, Career Changer, Unemployed
   - Context for career readiness and priorities

### Why This Data is Valuable:

**Subjects → Skills & Knowledge Areas**
- Math → Analytical, quantitative careers
- Science → Research, healthcare, engineering
- Art → Creative, design, media careers
- English → Communication, writing, teaching

**Activities → Skills & Personality**
- Sports → Teamwork, discipline, competition
- Drama → Communication, creativity, performance
- Debate → Critical thinking, persuasion
- Volunteering → Helping others, community service
- Coding → Technical skills, problem-solving

**Career Interests → Direct Preferences**
- User explicitly mentioned wanting to be a doctor
- Should boost healthcare careers
- Reduces exploration burden

**Context (Level + Status) → Filtering**
- High school student → Entry-level accessibility
- Graduate student → Advanced degree requirements OK
- Career changer → Transferable skills important

---

## 🎯 Three Implementation Options

### Option 1: Post-Filtering & Boosting ⭐ RECOMMENDED
**Complexity:** Low
**Time to Implement:** 2-4 hours
**Impact:** Medium-High
**Risk:** Low

#### How It Works:

```
1. Run Recipe C v3.0 (Interests + Values) → Get top 50 matches
2. For each match, calculate bonus score based on:
   - Subject alignment
   - Activity skill overlap
   - Direct career interest match
   - Education level appropriateness
3. Re-rank top 50 with bonuses applied
4. Return top 15
```

#### Advantages:
- ✅ No changes to Snowflake stored procedure
- ✅ Fast to implement (Swift-only changes)
- ✅ Easy to test and tune
- ✅ No database schema changes
- ✅ Fully reversible
- ✅ Preserves Recipe C core logic

#### Implementation:

**Step 1: Create Mapping Tables**

```swift
// Subject → Career Field Mapping
struct SubjectCareerMapping {
    static let mappings: [String: [String]] = [
        // Math subjects boost quantitative careers
        "Math": ["Mathematician", "Actuary", "Data Scientist", "Financial Analyst",
                 "Statistician", "Operations Research Analyst", "Economist"],
        "Algebra": ["Engineer", "Computer Programmer", "Data Scientist"],
        "Calculus": ["Physicist", "Engineer", "Mathematician", "Economist"],
        "Statistics": ["Data Scientist", "Market Research Analyst", "Biostatistician"],

        // Science subjects boost STEM careers
        "Science": ["Scientist", "Researcher", "Lab Technician"],
        "Biology": ["Biologist", "Physician", "Nurse", "Pharmacist", "Veterinarian",
                    "Medical Scientist", "Genetic Counselor"],
        "Chemistry": ["Chemist", "Pharmacist", "Chemical Engineer", "Lab Technician"],
        "Physics": ["Physicist", "Engineer", "Astronomer", "Materials Scientist"],

        // English/Language Arts boost communication careers
        "English": ["Writer", "Editor", "Teacher", "Journalist", "Public Relations",
                    "Technical Writer", "Content Strategist"],
        "Literature": ["Librarian", "Editor", "Professor", "Archivist"],
        "Writing": ["Author", "Copywriter", "Grant Writer", "Screenwriter"],

        // Social Studies boost social science careers
        "History": ["Historian", "Archivist", "Museum Curator", "Teacher", "Lawyer"],
        "Government": ["Political Scientist", "Public Administrator", "Diplomat"],
        "Economics": ["Economist", "Financial Analyst", "Market Research Analyst"],
        "Psychology": ["Psychologist", "Counselor", "Social Worker", "HR Specialist"],

        // Arts boost creative careers
        "Art": ["Graphic Designer", "Artist", "Art Director", "Museum Curator",
                "Photographer", "Fashion Designer", "Animator"],
        "Music": ["Musician", "Music Teacher", "Sound Engineer", "Music Therapist"],
        "Drama": ["Actor", "Director", "Drama Teacher", "Producer"],

        // Foreign Language boost international careers
        "Foreign Language": ["Translator", "Interpreter", "Diplomat", "ESL Teacher",
                            "International Relations Specialist"],

        // Computer Science boost tech careers
        "Computer Science": ["Software Developer", "Data Scientist", "IT Manager",
                            "Cybersecurity Analyst", "Web Developer", "Game Developer"],

        // Business boost business careers
        "Business": ["Business Analyst", "Manager", "Entrepreneur", "Consultant",
                    "Marketing Manager", "Human Resources Manager"]
    ]

    // Get matching career keywords for subjects
    static func getMatchingKeywords(for subjects: Set<SchoolSubject>) -> Set<String> {
        var keywords = Set<String>()
        for subject in subjects {
            if let matches = mappings[subject.name] {
                keywords.formUnion(matches)
            }
        }
        return keywords
    }
}

// Activity → Skill Mapping
struct ActivitySkillMapping {
    static let mappings: [String: [String]] = [
        // Sports → Teamwork, physical careers
        "Sports": ["Athletic Trainer", "Physical Therapist", "Coach", "Recreation Worker",
                   "Sports Manager", "Exercise Physiologist"],

        // Arts → Creative careers
        "Drama/Theater": ["Actor", "Director", "Producer", "Drama Teacher", "Event Planner"],
        "Music": ["Musician", "Music Teacher", "Audio Engineer", "Music Therapist"],
        "Visual Arts": ["Artist", "Graphic Designer", "Photographer", "Art Director"],
        "Dance": ["Dancer", "Choreographer", "Dance Teacher", "Physical Therapist"],

        // Academic → Knowledge-based careers
        "Debate": ["Lawyer", "Political Scientist", "Public Relations", "Sales Manager"],
        "Academic Clubs": ["Teacher", "Researcher", "Professor", "Analyst"],
        "Science Club": ["Scientist", "Lab Technician", "Researcher", "Engineer"],
        "Math Club": ["Mathematician", "Data Scientist", "Actuary", "Engineer"],

        // Service → Helping careers
        "Volunteering": ["Social Worker", "Counselor", "Nonprofit Manager",
                        "Community Health Worker", "Clergy"],
        "Community Service": ["Social Worker", "Community Organizer", "Nonprofit Director"],

        // Leadership → Management careers
        "Student Government": ["Manager", "Public Administrator", "Political Scientist",
                              "Event Planner", "HR Manager"],

        // Technical → Technical careers
        "Coding/Programming": ["Software Developer", "Data Scientist", "Web Developer",
                              "Cybersecurity Analyst", "Game Developer"],
        "Robotics": ["Robotics Engineer", "Mechanical Engineer", "Software Developer"],

        // Media → Communication careers
        "Journalism": ["Journalist", "Editor", "Public Relations", "Content Strategist"],
        "Yearbook": ["Photographer", "Graphic Designer", "Editor", "Marketing Specialist"],

        // Other
        "Gaming": ["Game Developer", "Game Designer", "Esports Manager"],
        "Reading": ["Librarian", "Editor", "Writer", "Teacher", "Researcher"]
    ]

    static func getMatchingKeywords(for activities: Set<ExtracurricularActivity>) -> Set<String> {
        var keywords = Set<String>()
        for activity in activities {
            if let matches = mappings[activity.name] {
                keywords.formUnion(matches)
            }
        }
        return keywords
    }
}
```

**Step 2: Update Career Matching Logic**

```swift
// In AppViewModel.swift - generateCareerSuggestions()

func generateCareerSuggestions() async {
    print("🚀 generateCareerSuggestions started - Using Recipe C+ (Enhanced)")
    await MainActor.run { isLoading = true }

    do {
        // 1. Calculate RIASEC scores
        let riasecScores = calculateRIASECScores()
        guard !riasecScores.isEmpty else {
            await generateSampleCareerTracks()
            return
        }

        // 2. Extract work values
        var workValuesDict: [String: Float]? = nil
        if let workValuesData = userData[.workValues] as? [String: Double] {
            workValuesDict = [
                "achievement": Float(workValuesData["achievement"] ?? 3.0),
                "independence": Float(workValuesData["independence"] ?? 3.0),
                "recognition": Float(workValuesData["recognition"] ?? 3.0),
                "relationships": Float(workValuesData["relationships"] ?? 3.0),
                "support": Float(workValuesData["support"] ?? 3.0),
                "working_conditions": Float(workValuesData["working_conditions"] ?? 3.0)
            ]
        }

        // 3. Call Snowflake Recipe C v3.0 (top 50 instead of 15)
        let snowflakeService = SnowflakeService.shared
        var onetOccupations = try await snowflakeService.getCareerMatches(
            scores: riasecScores,
            workValues: workValuesDict,
            limit: 50  // Get more candidates for post-filtering
        )

        print("✅ Received \(onetOccupations.count) O*NET career matches from Snowflake")

        // 4. ⭐ NEW: Apply post-filtering bonuses
        onetOccupations = applyContextualBonuses(to: onetOccupations)

        // 5. Re-sort and take top 15
        onetOccupations = Array(onetOccupations.sorted { $0.match > $1.match }.prefix(15))

        print("✅ Final ranked careers after Recipe C+ bonuses: \(onetOccupations.count)")

        // 6. Convert to CareerTrack and save
        await MainActor.run {
            careerTracks = onetOccupations.map { occupation in
                CareerTrack.from(onetOccupation: occupation, progress: 0)
            }
            userData[.careerSuggestions] = careerTracks as AnyHashable
            userData[.riasecResults] = riasecScores as AnyHashable
            isLoading = false
        }

    } catch {
        await MainActor.run {
            print("❌ Error: \(error.localizedDescription)")
            generateSampleCareerTracksSync()
            isLoading = false
        }
    }
}

// NEW: Apply contextual bonuses based on subjects, activities, interests
private func applyContextualBonuses(to occupations: [ONetOccupation]) -> [ONetOccupation] {
    print("🎯 Applying Recipe C+ contextual bonuses...")

    // Extract user data
    let subjects = userData[.favoriteSubjects] as? Set<SchoolSubject> ?? []
    let activities = userData[.extracurriculars] as? Set<ExtracurricularActivity> ?? []
    let careerInterests = userData[.careerInterests] as? Set<String> ?? []
    let studentLevel = userData[.studentLevel] as? String
    let currentStatus = userData[.currentStatus] as? SelectionOption

    // Get matching keywords from mappings
    let subjectKeywords = SubjectCareerMapping.getMatchingKeywords(for: subjects)
    let activityKeywords = ActivitySkillMapping.getMatchingKeywords(for: activities)

    print("  📚 Subject keywords: \(subjectKeywords.count)")
    print("  🎭 Activity keywords: \(activityKeywords.count)")
    print("  💼 Career interests: \(careerInterests.count)")

    var boostedOccupations: [ONetOccupation] = []

    for var occupation in occupations {
        var bonusPoints = 0

        // Bonus 1: Subject alignment (+5 points per match, max +15)
        let subjectMatches = subjectKeywords.filter { keyword in
            occupation.title.localizedCaseInsensitiveContains(keyword)
        }
        let subjectBonus = min(subjectMatches.count * 5, 15)
        bonusPoints += subjectBonus

        // Bonus 2: Activity skill alignment (+5 points per match, max +15)
        let activityMatches = activityKeywords.filter { keyword in
            occupation.title.localizedCaseInsensitiveContains(keyword)
        }
        let activityBonus = min(activityMatches.count * 5, 15)
        bonusPoints += activityBonus

        // Bonus 3: Direct career interest match (+20 points for exact match)
        let directMatch = careerInterests.contains { interest in
            occupation.title.localizedCaseInsensitiveContains(interest) ||
            interest.localizedCaseInsensitiveContains(occupation.title)
        }
        if directMatch {
            bonusPoints += 20
            print("  🎯 Direct match bonus: \(occupation.title)")
        }

        // Bonus 4: Education level appropriateness
        if let level = studentLevel {
            let educationBonus = calculateEducationBonus(
                studentLevel: level,
                careerEducation: occupation.education
            )
            bonusPoints += educationBonus
        }

        // Apply bonus (cap total bonus at +25 match points)
        let cappedBonus = min(bonusPoints, 25)
        occupation.match = min(occupation.match + cappedBonus, 100)

        if cappedBonus > 0 {
            print("  ✨ \(occupation.title): +\(cappedBonus) bonus (was \(occupation.match - cappedBonus)%, now \(occupation.match)%)")
        }

        boostedOccupations.append(occupation)
    }

    return boostedOccupations
}

private func calculateEducationBonus(studentLevel: String, careerEducation: String?) -> Int {
    guard let education = careerEducation else { return 0 }

    let educationLower = education.lowercased()

    switch studentLevel {
    case "High School":
        // Boost careers that don't require college
        if educationLower.contains("high school") ||
           educationLower.contains("certificate") ||
           educationLower.contains("associate") {
            return 5
        }
        // Penalize careers requiring advanced degrees
        if educationLower.contains("doctorate") || educationLower.contains("phd") {
            return -10
        }

    case "Undergraduate":
        // Boost bachelor's level careers
        if educationLower.contains("bachelor") {
            return 5
        }

    case "Graduate":
        // Boost master's and doctorate careers
        if educationLower.contains("master") ||
           educationLower.contains("doctorate") ||
           educationLower.contains("phd") {
            return 5
        }

    default:
        break
    }

    return 0
}
```

**Step 3: Update Snowflake Service (Optional)**

```swift
// In SnowflakeService.swift - add optional limit parameter

func getCareerMatches(
    scores: [String: Float],
    workValues: [String: Float]? = nil,
    limit: Int = 15  // ⭐ NEW: Allow requesting more than 15
) async throws -> [ONetOccupation] {
    // ... existing code ...

    // Modify SQL to accept limit parameter
    let sql = """
    CALL \(database).\(schema).SP_GET_CAREER_MATCHES_V3(
        \(r), \(i), \(a), \(s), \(e), \(c),
        \(achievement), \(independence), \(recognition),
        \(relationships), \(support), \(workingConditions),
        \(limit)  -- ⭐ NEW: Pass limit to stored procedure
    )
    """

    // ... rest of existing code ...
}
```

**Step 4: Update Snowflake Stored Procedure (Optional)**

```sql
-- Modify SP_GET_CAREER_MATCHES_V3 to accept limit parameter

CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V3(
    USER_R FLOAT,
    USER_I FLOAT,
    USER_A FLOAT,
    USER_S FLOAT,
    USER_E FLOAT,
    USER_C FLOAT,
    USER_ACHIEVEMENT FLOAT,
    USER_INDEPENDENCE FLOAT,
    USER_RECOGNITION FLOAT,
    USER_RELATIONSHIPS FLOAT,
    USER_SUPPORT FLOAT,
    USER_WORKING_CONDITIONS FLOAT,
    RESULT_LIMIT FLOAT  -- ⭐ NEW: Allow variable limit (default 15)
)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
    // ... existing matching logic ...

    // At the end, use dynamic limit instead of hardcoded 15
    var limit = RESULT_LIMIT || 15;
    careers.sort((a, b) => b.match - a.match);
    return JSON.stringify(careers.slice(0, limit));
$$;
```

---

### Option 2: Skills-Based Matching (Moderate Complexity)
**Complexity:** Medium
**Time to Implement:** 1-2 weeks
**Impact:** High
**Risk:** Medium

#### How It Works:

```
1. Create SKILLS_MAPPING table in Snowflake
   - Subject → O*NET Skills mapping
   - Activity → O*NET Skills mapping
2. For each career, calculate skill overlap score
3. Add as 3rd dimension: (50% interests + 30% values + 20% skills)
4. Return top 15
```

#### Advantages:
- ✅ More sophisticated than post-filtering
- ✅ Uses O*NET skills data (already available)
- ✅ Scientifically grounded
- ✅ Transparent scoring

#### Disadvantages:
- ❌ Requires Snowflake schema changes
- ❌ More complex to maintain
- ❌ Harder to tune weights

#### Implementation Outline:

**Database Changes:**

```sql
-- Create skills mapping table
CREATE TABLE SUBJECT_SKILLS_MAPPING (
    SUBJECT_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    RELEVANCE_SCORE FLOAT  -- 0-1 scale
);

-- Example data
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Math', '2.A.1.a', 0.9),  -- Number Facility
('Math', '2.A.1.b', 0.8),  -- Mathematical Reasoning
('Science', '2.A.2.a', 0.9), -- Science
('English', '2.A.1.c', 0.9); -- Reading Comprehension

-- Similar for activities
CREATE TABLE ACTIVITY_SKILLS_MAPPING (
    ACTIVITY_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    RELEVANCE_SCORE FLOAT
);
```

**Updated Procedure:**

```sql
CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V3_PLUS(
    -- Existing RIASEC + Work Values params...
    USER_R FLOAT,
    -- ... (all 12 params)

    -- NEW: Skills from subjects/activities
    USER_SUBJECTS VARCHAR,  -- JSON array: ["Math", "Science"]
    USER_ACTIVITIES VARCHAR  -- JSON array: ["Sports", "Debate"]
)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
AS
$$
    // Parse user subjects and activities
    var userSubjects = JSON.parse(USER_SUBJECTS);
    var userActivities = JSON.parse(USER_ACTIVITIES);

    // Get relevant skills for user
    var userSkills = {};
    // Query SUBJECT_SKILLS_MAPPING for each subject
    // Query ACTIVITY_SKILLS_MAPPING for each activity
    // Combine into userSkills object

    // For each career:
    var careers = [];
    while (result.next()) {
        // Calculate interests match (existing)
        var interestsMatch = cosineSimilarity(user_riasec, job_riasec);

        // Calculate values match (existing)
        var valuesMatch = cosineSimilarity(user_values, job_values);

        // NEW: Calculate skills match
        var jobSkills = getJobSkills(result.getColumnValue('ONET_SOC_CODE'));
        var skillsMatch = calculateSkillOverlap(userSkills, jobSkills);

        // 3-way blended scoring
        var blendedMatch = (0.5 * interestsMatch) +
                          (0.3 * valuesMatch) +
                          (0.2 * skillsMatch);

        var finalScore = blendedMatch * 7.0;
        // ... rest of logic
    }
$$;
```

---

### Option 3: Multi-Dimensional Blending (Most Advanced)
**Complexity:** High
**Time to Implement:** 3-4 weeks
**Impact:** Very High
**Risk:** High

#### How It Works:

```
4-Dimensional Matching:
  40% Interests (RIASEC)
  30% Work Values
  20% Skills (from subjects/activities)
  10% Context (education level, status, timeline)

Machine Learning Refinement:
  - Track which careers users save/explore
  - Learn optimal weights per user type
  - Personalize over time
```

#### This is Recipe D (Future)
Not recommended for immediate implementation. Consider for v4.0.

---

## 🎯 Recommended Implementation Path

### Phase 1: Option 1 (Post-Filtering) ⭐
**Timeline:** This Week
**Effort:** 4-6 hours
**Files to Modify:**
- `AppViewModel.swift` (add bonus calculation)
- Create new `CareerMatchingUtils.swift` (mapping tables)

**Testing:**
1. Test with various subject combinations
2. Test with direct career interest matches
3. Verify bonus caps working correctly
4. A/B test against Recipe C baseline

**Success Metrics:**
- Career save rate: +10-15%
- User satisfaction: +15%
- "This matches my interests" feedback: +25%

### Phase 2: Monitor & Tune
**Timeline:** Next 2 weeks
**Actions:**
- Collect user feedback
- Track which bonuses fire most often
- Adjust bonus values based on data
- Add more subject/activity mappings

### Phase 3: Consider Option 2
**Timeline:** Next Quarter
**Condition:** If Option 1 shows significant improvement
**Effort:** 1-2 weeks

---

## 📊 Expected Impact Analysis

### Current Recipe C Results:
```
User: Math + Science subjects, Coding activity
Top Match: "Software Developer" (92%)
Match Basis: RIASEC (Investigative=5, Conventional=4)
              Work Values (Achievement=5, Independence=5)
```

### With Recipe C+ (Option 1):
```
User: Math + Science subjects, Coding activity
Top Match: "Software Developer" (97%)  ← +5% boost
Match Basis: RIASEC (92%) + Subject Bonus (+5%)
Explanation: "Great match! We noticed you love Math and coding."

Other boosted careers:
  - Data Scientist: 89% → 94% (+5% from Math/Science)
  - Computer Systems Analyst: 85% → 95% (+10% from Math+Coding)
  - Mathematician: 78% → 88% (+10% from Math)
```

### User Experience Improvement:
```
Before: "Why is 'Accountant' ranked higher than 'Software Developer'?"
After: "Perfect! Software Developer is #1, exactly what I'm interested in!"
```

---

## 🔧 Implementation Steps (Option 1)

### Step 1: Create Mapping Utilities (1 hour)

```bash
# Create new file
touch carrer/Utilities/CareerMatchingUtils.swift
```

Add to Xcode project, then implement:
- SubjectCareerMapping struct
- ActivitySkillMapping struct
- Helper functions

### Step 2: Update AppViewModel (2 hours)

Modify `generateCareerSuggestions()`:
1. Request top 50 from Snowflake (instead of 15)
2. Call `applyContextualBonuses()`
3. Re-sort and take top 15
4. Add logging for transparency

### Step 3: Test Thoroughly (2 hours)

Test cases:
- Math + Science + Coding → Should boost STEM
- Art + Drama + Music → Should boost Creative
- History + Debate + Volunteering → Should boost Social
- Direct interest "Doctor" → Should boost healthcare

### Step 4: Deploy & Monitor (Ongoing)

Track:
- How often bonuses are applied
- Average bonus amount
- User save rate before/after
- User feedback

---

## 📈 Success Criteria

**Immediate (Week 1):**
- ✅ Code deployed without breaking Recipe C
- ✅ Bonuses applying correctly
- ✅ Console logs showing bonus calculations
- ✅ No performance degradation

**Short-term (Month 1):**
- ✅ Career save rate +10%
- ✅ User satisfaction +15%
- ✅ Positive qualitative feedback
- ✅ No increase in "poor match" reports

**Long-term (Quarter 1):**
- ✅ Career save rate +15%
- ✅ User retention +10%
- ✅ Data supports Option 2 exploration
- ✅ Clear mapping improvement opportunities identified

---

## 🚨 Risks & Mitigation

### Risk 1: Over-fitting to stated preferences
**Problem:** User says "doctor" but RIASEC shows low Social
**Mitigation:** Cap direct interest bonus at +20 points (max 25% boost)

### Risk 2: Mapping inaccuracies
**Problem:** "Math" boosting irrelevant careers
**Mitigation:** Start conservative, tune based on feedback, add negative keywords

### Risk 3: Reduced diversity
**Problem:** Only showing STEM to STEM students
**Mitigation:** Ensure Recipe C base (60/40) remains dominant, bonuses are supplemental

### Risk 4: Performance degradation
**Problem:** Processing 50 results instead of 15
**Mitigation:** Profile performance, optimize keyword matching, consider caching

---

## 🎯 Conclusion

**Recommendation: Implement Option 1 (Post-Filtering) immediately**

**Why:**
- ✅ Low risk, high reward
- ✅ Quick to implement (4-6 hours)
- ✅ No database changes required
- ✅ Easy to A/B test
- ✅ Fully reversible
- ✅ Addresses user feedback immediately

**After 1 month of data:**
- Evaluate if Option 2 is worth the effort
- Consider machine learning for Option 3 in v4.0

---

**Next Steps:**
1. Review this plan with team
2. Get approval for Option 1
3. Implement CareerMatchingUtils.swift
4. Update AppViewModel
5. Test thoroughly
6. Deploy with feature flag
7. Monitor metrics closely

---

*Document: RECIPE_C_PLUS_IMPLEMENTATION_PLAN.md*
*Created: October 2025*
*Status: Ready for Implementation*
