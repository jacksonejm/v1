# Scoring System Version Control

## Current Version: v1.0 Baseline (Top-2 RIASEC)

**Date:** 2025-10-05
**Status:** ✅ Production - Working
**Backup Location:** `/scoring_versions/v1.0_baseline_20251005/`

---

## v1.0 Baseline - Current Implementation

### Overview
Simple, deterministic scoring using top 2 RIASEC dimensions matched against O*NET interest scores.

### Core Algorithm
1. User answers 18 RIASEC questions (1-5 scale)
2. Calculate average per dimension (6 scores, 0-5 scale)
3. Identify top 2 dimensions
4. Query Snowflake for careers matching those 2 dimensions
5. Convert O*NET interest scores (0-7) to match % (0-100%)

### Files Included in Backup
```
scoring_versions/v1.0_baseline_20251005/
├── RIASECScoreCalculator.swift     # Score calculation logic
├── ONetOccupation.swift            # Match % conversion (line 26-28)
├── CareerTrack.swift               # CareerTrack model
├── SnowflakeService.swift          # Snowflake API integration
├── AppViewModel.swift              # generateCareerSuggestions()
└── Agentsnowm.md                   # Snowflake stored procedures
```

### Key Characteristics
- ✅ Simple and explainable
- ✅ Fast (single Snowflake query)
- ✅ No data collection beyond RIASEC
- ⚠️ Limited personalization (ignores 4 dimensions)
- ⚠️ No skills, values, or constraints
- ⚠️ Same scores for users with same top 2

### Match % Formula
```swift
// ONetOccupation.swift:26-28
var interestScorePercentage: Int {
    Int((interestScore / 7.0) * 100)
}
```

### Snowflake Query Pattern
```sql
SELECT occupation, title, description, interest_score
WHERE dimension IN (top_dimension_1, top_dimension_2)
  AND interest_score >= 4.0
ORDER BY interest_score DESC
LIMIT 15
```

---

## Proposed Version: v2.0 Enhanced Scoring

**Status:** 🔬 Under Evaluation
**Proposed Date:** TBD

### Evaluation Criteria

Before implementing v2.0, we need to assess:

#### 1. **Feasibility**
- [ ] Do we have O*NET data for all 6 RIASEC dimensions?
- [ ] Can Snowflake handle cosine similarity calculations?
- [ ] Do we have Work Values data in O*NET tables?
- [ ] Do we have Skills/KSA data with importance ratings?
- [ ] What's the performance impact of complex scoring?

#### 2. **Data Requirements**
- [ ] Work Values table (6 dimensions)
- [ ] Skills table with importance ratings
- [ ] Work Context table
- [ ] Wage/Education/Outlook data (BLS)
- [ ] All 6 RIASEC interest scores per occupation

#### 3. **User Experience Impact**
- [ ] Additional questions needed?
- [ ] UI changes for new explanations?
- [ ] Performance/latency acceptable?
- [ ] A/B testing framework needed?

#### 4. **Development Effort**
- [ ] Snowflake schema changes
- [ ] New stored procedures
- [ ] Swift model updates
- [ ] UI component updates
- [ ] Testing and validation

---

## Proposed Enhancement Recipes

### Recipe A: All-6 Interest Cosine ⭐ (Recommended starting point)
**Complexity:** Low
**Impact:** High
**Data Required:** Existing RIASEC data (all 6 dimensions)

**Changes Needed:**
- Update Snowflake SP to use cosine similarity
- No new user questions
- Minimal UI changes

**Formula:**
```
InterestMatch = 100 × cosine_similarity(user_vector_6D, job_vector_6D)
```

**Pros:**
- Uses existing data
- Big quality lift
- Simple to explain

**Cons:**
- Need all 6 O*NET interest scores per career

---

### Recipe B: Softmax-Weighted Interests
**Complexity:** Medium
**Impact:** High
**Data Required:** Existing RIASEC data

**Changes Needed:**
- More complex Snowflake calculation
- Hyperparameter tuning (tau)

**Formula:**
```
weights = softmax(user_scores / tau)
InterestMatch = 100 × Σ(weights[i] × job_scores[i])
```

**Pros:**
- Smooth transition from top-2
- Uses all 6 dimensions
- Tunable concentration

**Cons:**
- Less intuitive than cosine
- Requires calibration

---

### Recipe C: Interests × Values
**Complexity:** High
**Impact:** Very High
**Data Required:** Work Values table + 6 new user questions

**Changes Needed:**
- Add Work Values onboarding step
- Join O*NET Work Values table
- Update UI to show value matches

**Formula:**
```
InterestMatch = (Recipe A or B)
ValueMatch = cosine_similarity(user_values, job_values)
FinalScore = 0.6 × InterestMatch + 0.4 × ValueMatch
```

**Pros:**
- Much more personal
- Better long-term satisfaction
- Richer explanations

**Cons:**
- 6 more questions
- More complex queries
- Need O*NET values data

---

### Recipe D: Interest + Skill Fit
**Complexity:** Very High
**Impact:** Very High
**Data Required:** Skills table + user skill inventory

**Changes Needed:**
- Add skill collection UI
- O*NET skills with importance
- Calculate skill overlap

**Formula:**
```
SkillFit = 100 × (matched_skill_importance / total_job_importance)
FinalScore = 0.5×Interest + 0.3×SkillFit - 0.2×Friction
```

**Pros:**
- Addresses "can I do this?"
- Great explanations
- Practical guidance

**Cons:**
- Requires resume parsing or many checkboxes
- Complex skill matching
- Higher development cost

---

### Recipe E: Multi-Objective Utility
**Complexity:** Very High
**Impact:** Very High
**Data Required:** All of above + BLS wage/outlook data

**Changes Needed:**
- Constraint collection UI
- Multiple data source joins
- Complex scoring pipeline

**Formula:**
```
U = 0.45I + 0.20V + 0.15Wage + 0.10Outlook + 0.10Education
```

**Pros:**
- Comprehensive fit
- Addresses real constraints
- Future-proof

**Cons:**
- Most complex
- Many data dependencies
- Requires extensive testing

---

## Migration Strategy

### Phase 1: Evaluation (Current)
1. Analyze O*NET data availability ✅
2. Prototype Recipe A in Snowflake
3. Benchmark performance
4. Estimate development effort

### Phase 2: Incremental Rollout
1. Implement Recipe A (all-6 cosine)
2. A/B test vs. v1.0 baseline
3. Collect user feedback
4. Iterate

### Phase 3: Expansion (Optional)
1. Add Work Values (Recipe C)
2. Add constraints filtering
3. Add skill matching

### Phase 4: Advanced (Future)
1. Behavioral learning (Recipe G)
2. Diversity optimization (Recipe H)
3. Two-stage retrieval (Recipe I)

---

## Rollback Plan

If v2.0 has issues, rollback is simple:

```bash
# 1. Restore backed-up files
cp scoring_versions/v1.0_baseline_20251005/* carrer/

# 2. Revert Snowflake stored procedure
USE DATABASE ONET_CAREER_DB;
-- Run original SP_GET_CAREER_MATCHES from Agentsnowm.md backup

# 3. Rebuild app
xcodebuild clean build
```

---

## A/B Testing Framework (Recommended)

Before fully replacing v1.0, implement A/B testing:

```swift
enum ScoringVersion {
    case v1_baseline    // Top-2 RIASEC
    case v2_cosine      // All-6 cosine
    case v2_softmax     // Softmax-weighted
}

// Randomly assign users
let userScoringVersion: ScoringVersion = {
    let userId = UUID().hashValue
    switch userId % 3 {
    case 0: return .v1_baseline
    case 1: return .v2_cosine
    default: return .v2_softmax
    }
}()
```

Track metrics:
- User satisfaction ratings
- Career saves/clicks
- Time to first save
- Career detail views
- "Not interested" taps

---

## Data Requirements Checklist

Before implementing any v2.0 recipe:

### Currently Have ✅
- [x] RIASEC scores (user) - 6 dimensions
- [x] O*NET occupation titles, codes, descriptions
- [x] O*NET interest scores (need to verify: all 6 or just top 2?)
- [x] Snowflake infrastructure

### Need to Verify ❓
- [ ] Do O*NET tables have all 6 RIASEC scores per occupation?
- [ ] What tables exist in CAREER_SCHEMA?
- [ ] Current table schema documentation
- [ ] Query performance benchmarks

### May Need to Add ⚠️
- [ ] Work Values table (O*NET database)
- [ ] Skills/Abilities table with importance ratings
- [ ] Work Context table
- [ ] BLS wage data by occupation
- [ ] Education requirements table
- [ ] Job outlook/growth projections

---

## Performance Considerations

### v1.0 Baseline
- **Latency:** ~200-500ms (single query)
- **Snowflake compute:** Minimal (simple WHERE + ORDER BY)
- **Results:** 15 careers

### v2.0 Estimates

**Recipe A (Cosine):**
- **Latency:** ~300-700ms (vector math per row)
- **Compute:** Moderate (1000+ occupations × 6D vectors)
- **Recommendation:** Pre-compute and cache

**Recipe C (Values):**
- **Latency:** ~500-1000ms (two cosine calculations + join)
- **Compute:** High
- **Recommendation:** Two-stage retrieval (Recipe I)

**Recipe E (Multi-objective):**
- **Latency:** ~1-2s (multiple table joins)
- **Compute:** Very high
- **Recommendation:** Background job + caching

---

## Next Steps

1. **Immediate:** Run data audit query on Snowflake
2. **This week:** Prototype Recipe A in Snowflake
3. **Next week:** Benchmark performance
4. **Month 1:** Implement and A/B test Recipe A
5. **Month 2+:** Evaluate adding Values/Skills

---

## Contact & Documentation

**Version Control Owner:** Development Team
**Snowflake Schema:** WAB63663.ONET_CAREER_DB.CAREER_SCHEMA
**Backup Schedule:** Before any scoring changes
**Testing Protocol:** A/B test with 20%+ sample size

**Related Documents:**
- `SNOWFLAKE_AUTH_ISSUE.md` - Authentication setup
- `SNOWFLAKE_KEYPAIR_SETUP.md` - Key configuration
- `Agentsnowm.md` - Current stored procedures
- This file - Version control
