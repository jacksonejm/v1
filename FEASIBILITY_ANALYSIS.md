# Feasibility Analysis: Enhanced Scoring Recipes

**Analysis Date:** 2025-10-05
**Current Version:** v1.0 Baseline
**Goal:** Evaluate expert-proposed scoring enhancements

---

## Executive Summary

**Recommendation:** Start with **Recipe A (All-6 Interest Cosine)** as Phase 1

**Rationale:**
- ✅ Uses existing data (no new questions)
- ✅ Biggest quality lift with minimal complexity
- ✅ Foundation for future enhancements
- ✅ Low risk, high reward

**Timeline:** 2-3 weeks for Recipe A implementation + A/B testing

---

## Data Audit Required

**Action Item:** Run these queries in Snowflake to verify data availability:

### Query 1: Check if we have all 6 RIASEC dimensions per occupation
```sql
-- Check INTERESTS_FACT table structure
SELECT TOP 10 *
FROM ONET_CAREER_DB.CAREER_SCHEMA.INTERESTS_FACT;

-- Count how many RIASEC elements we have
SELECT ELEMENT_ID, COUNT(DISTINCT ONET_SOC_CODE) as num_occupations
FROM ONET_CAREER_DB.CAREER_SCHEMA.INTERESTS_FACT
WHERE ELEMENT_ID IN (
    '1.B.1.a',  -- Realistic
    '1.B.1.b',  -- Investigative
    '1.B.1.c',  -- Artistic
    '1.B.1.d',  -- Social
    '1.B.1.e',  -- Enterprising
    '1.B.1.f'   -- Conventional
)
GROUP BY ELEMENT_ID;
```

### Query 2: Check for Work Values data
```sql
-- List all O*NET tables
SHOW TABLES IN ONET_CAREER_DB.CAREER_SCHEMA;

-- Check if Work Values table exists
SELECT COUNT(*) FROM ONET_CAREER_DB.CAREER_SCHEMA.WORK_VALUES;
-- or
SELECT COUNT(*) FROM ONET_CAREER_DB.CAREER_SCHEMA.WORK_STYLES;
```

### Query 3: Check for Skills/Abilities data
```sql
-- Check for skills with importance ratings
SELECT TOP 10 *
FROM ONET_CAREER_DB.CAREER_SCHEMA.SKILLS
-- or
FROM ONET_CAREER_DB.CAREER_SCHEMA.ABILITIES;
```

### Query 4: Check for Work Context data
```sql
SELECT TOP 10 *
FROM ONET_CAREER_DB.CAREER_SCHEMA.WORK_CONTEXT;
```

---

## Recipe-by-Recipe Feasibility

### ✅ Recipe A: All-6 Interest Cosine
**Status:** HIGHLY FEASIBLE (Recommended Phase 1)

**Requirements:**
- ✅ User RIASEC scores (all 6) - **We already collect this**
- ❓ O*NET interest scores (all 6) - **Need to verify Snowflake table**

**Implementation Checklist:**
- [ ] Verify INTERESTS_FACT has all 6 dimensions per occupation
- [ ] Write new Snowflake stored procedure (SP_GET_CAREER_MATCHES_V2)
- [ ] Update Swift models to accept 6-dimension scores
- [ ] Test cosine similarity calculation
- [ ] A/B test vs. v1.0

**Estimated Effort:** 1-2 weeks
**Risk Level:** Low
**Expected Impact:** High (+30-50% match quality)

**Sample Snowflake Implementation:**
```sql
CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_COSINE(
    SCORE_R FLOAT, SCORE_I FLOAT, SCORE_A FLOAT,
    SCORE_S FLOAT, SCORE_E FLOAT, SCORE_C FLOAT
)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    // Normalize user scores (0-5 → 0-1)
    var u = {
        R: SCORE_R / 5.0,
        I: SCORE_I / 5.0,
        A: SCORE_A / 5.0,
        S: SCORE_S / 5.0,
        E: SCORE_E / 5.0,
        C: SCORE_C / 5.0
    };

    // Get all occupations with their 6 RIASEC scores
    var sql = `
        SELECT
            o.ONET_SOC_CODE,
            o.TITLE,
            o.DESCRIPTION,
            MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.a' THEN i.DATA_VALUE/7.0 END) as R,
            MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.b' THEN i.DATA_VALUE/7.0 END) as I,
            MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.c' THEN i.DATA_VALUE/7.0 END) as A,
            MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.d' THEN i.DATA_VALUE/7.0 END) as S,
            MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.e' THEN i.DATA_VALUE/7.0 END) as E,
            MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.f' THEN i.DATA_VALUE/7.0 END) as C
        FROM INTERESTS_FACT i
        JOIN OCCUPATION_DIM o ON i.ONET_SOC_CODE = o.ONET_SOC_CODE
        GROUP BY o.ONET_SOC_CODE, o.TITLE, o.DESCRIPTION
    `;

    var stmt = snowflake.createStatement({sqlText: sql});
    var result = stmt.execute();

    var careers = [];
    while (result.next()) {
        var j = {
            R: result.getColumnValue(4) || 0,
            I: result.getColumnValue(5) || 0,
            A: result.getColumnValue(6) || 0,
            S: result.getColumnValue(7) || 0,
            E: result.getColumnValue(8) || 0,
            C: result.getColumnValue(9) || 0
        };

        // Cosine similarity
        var dot = u.R*j.R + u.I*j.I + u.A*j.A + u.S*j.S + u.E*j.E + u.C*j.C;
        var mag_u = Math.sqrt(u.R*u.R + u.I*u.I + u.A*u.A + u.S*u.S + u.E*u.E + u.C*u.C);
        var mag_j = Math.sqrt(j.R*j.R + j.I*j.I + j.A*j.A + j.S*j.S + j.E*j.E + j.C*j.C);
        var cosine = dot / (mag_u * mag_j);
        var interest_score = cosine * 7.0; // Scale back to 0-7 for compatibility

        // Filter low matches
        if (interest_score >= 3.5) {
            careers.push({
                code: result.getColumnValue(1),
                title: result.getColumnValue(2),
                description: result.getColumnValue(3),
                interest_score: interest_score,
                primary_match: getPrimary(j),
                secondary_match: getSecondary(j)
            });
        }
    }

    // Sort by interest_score
    careers.sort((a, b) => b.interest_score - a.interest_score);
    return JSON.stringify(careers.slice(0, 15));

    function getPrimary(scores) {
        var max = Math.max(scores.R, scores.I, scores.A, scores.S, scores.E, scores.C);
        if (scores.R === max) return 'Realistic';
        if (scores.I === max) return 'Investigative';
        if (scores.A === max) return 'Artistic';
        if (scores.S === max) return 'Social';
        if (scores.E === max) return 'Enterprising';
        return 'Conventional';
    }

    function getSecondary(scores) {
        // Similar logic for second highest
    }
$$;
```

---

### ⚠️ Recipe B: Softmax-Weighted Interests
**Status:** FEASIBLE but MORE COMPLEX

**Requirements:**
- Same as Recipe A
- Additional: Hyperparameter tuning for tau

**Pros over Recipe A:**
- Tunable concentration on top interests
- Smoother transition from v1.0

**Cons:**
- Less intuitive than cosine
- Requires calibration experiments
- More complex to explain

**Recommendation:** Consider after Recipe A is proven

---

### ⚠️ Recipe C: Interests × Values
**Status:** PARTIALLY FEASIBLE (Missing Data + UX)

**Requirements:**
- ✅ Recipe A foundation
- ❓ O*NET Work Values table - **Need to verify**
- ❌ 6 new user questions - **Requires UX design**

**Blockers:**
1. Need to verify WORK_VALUES or WORK_STYLES table exists
2. Need to design Work Values onboarding step
3. Need to add 6 new questions to flow
4. Need to update UI to show value-based explanations

**Estimated Effort:** 4-6 weeks
**Risk Level:** Medium
**Expected Impact:** Very High (better long-term satisfaction)

**Recommendation:** Phase 2 (after Recipe A proves valuable)

**Work Values Questions to Add:**
If we proceed, these 6 questions (1-5 scale):
1. "I value achievement and accomplishment in my work"
2. "I prefer to work independently with minimal supervision"
3. "I value recognition and status from my work"
4. "I value helping others and making a difference"
5. "I value a supportive work environment"
6. "I value good working conditions and job security"

---

### ❌ Recipe D: Interest + Skill Fit
**Status:** NOT CURRENTLY FEASIBLE

**Requirements:**
- ✅ Recipe A foundation
- ❓ O*NET Skills table with importance - **Need to verify**
- ❌ User skill inventory - **Major UX undertaking**

**Blockers:**
1. Need Skills/Abilities table with importance ratings
2. Need to design skill collection interface (resume upload? checkboxes?)
3. Need skill taxonomy mapping
4. Complex skill matching algorithm
5. Friction calculation logic

**Estimated Effort:** 8-12 weeks
**Risk Level:** High
**Expected Impact:** Very High (addresses "can I do this?")

**Recommendation:** Phase 3+ (requires significant investment)

**UX Challenge:**
- Resume parsing? (privacy concerns, accuracy issues)
- Checkbox list? (overwhelming - O*NET has 100s of skills)
- AI-assisted skill extraction? (expensive, complex)

---

### ❌ Recipe E: Multi-Objective Utility
**Status:** NOT CURRENTLY FEASIBLE

**Requirements:**
- All of above
- ❌ BLS wage data integration
- ❌ Job outlook/growth data
- ❌ Constraint collection UI

**Blockers:**
1. Need external BLS API or data import
2. Need constraint collection step in onboarding
3. Multiple complex data joins
4. Performance concerns

**Estimated Effort:** 12+ weeks
**Risk Level:** Very High
**Expected Impact:** Very High (comprehensive fit)

**Recommendation:** Long-term vision (6+ months)

---

### 📊 Recipe G: Behavioral Learning
**Status:** FUTURE CONSIDERATION

**Requirements:**
- Base scoring (A-E)
- User action tracking infrastructure
- ML/analytics pipeline

**Recommendation:** Year 2+ feature

---

### 🎯 Recipe H: Diversified Top-N
**Status:** FEASIBLE (Can layer on top of any recipe)

**Effort:** Low (1-2 days)
**Impact:** Medium (better exploration)

**Recommendation:** Add to Recipe A after validation

---

### 🚀 Recipe I: Two-Stage Retrieval
**Status:** FEASIBLE (Performance optimization)

**Use Case:** If Recipe C/D/E queries are too slow
**Effort:** Medium (1-2 weeks)

**Recommendation:** Only if latency > 1s

---

## Phased Implementation Plan

### Phase 1: Foundation (Weeks 1-3) ✅ RECOMMENDED START
**Goal:** Prove enhanced scoring value with minimal risk

**Deliverables:**
1. Data audit (verify 6-dimension O*NET data)
2. Implement Recipe A (All-6 Cosine)
3. Create A/B testing framework
4. Deploy to 20% of users
5. Measure engagement metrics

**Success Criteria:**
- Match quality ratings +15% or higher
- Career save rate +10% or higher
- User satisfaction scores improved
- Latency < 1 second

**Go/No-Go Decision:** Proceed to Phase 2 if metrics improve

---

### Phase 2: Enrichment (Weeks 4-8) ⚠️ CONDITIONAL
**Goal:** Add Work Values for deeper personalization

**Prerequisites:**
- Phase 1 success metrics met
- Work Values table verified in O*NET

**Deliverables:**
1. Design Work Values onboarding step
2. Implement Recipe C (Interests × Values)
3. Update UI for value-based explanations
4. A/B test vs. Recipe A
5. Analyze impact

**Success Criteria:**
- Long-term engagement improved
- Career detail views +20%
- User feedback positive

---

### Phase 3: Advanced Features (Months 3-6) ❌ FUTURE
**Goal:** Skills, constraints, behavioral learning

**Prerequisites:**
- Phase 2 validated
- Product-market fit confirmed
- Engineering resources available

**Deliverables:**
1. Skill collection interface
2. Constraint filtering
3. BLS data integration
4. Recipe D/E implementation

---

## Technical Feasibility Assessment

### Snowflake Performance

**Current (v1.0):**
- Query time: ~200-500ms
- Simple WHERE clause + ORDER BY
- 15 results

**Recipe A Estimate:**
- Query time: ~500-1000ms
- Cosine calculation per occupation (1000+)
- Recommendation: Pre-aggregate or cache

**Optimization Strategy:**
```sql
-- Create materialized view for faster querying
CREATE MATERIALIZED VIEW CAREER_RIASEC_VECTORS AS
SELECT
    ONET_SOC_CODE,
    TITLE,
    DESCRIPTION,
    MAX(CASE WHEN ELEMENT_ID = '1.B.1.a' THEN DATA_VALUE/7.0 END) as R,
    MAX(CASE WHEN ELEMENT_ID = '1.B.1.b' THEN DATA_VALUE/7.0 END) as I,
    MAX(CASE WHEN ELEMENT_ID = '1.B.1.c' THEN DATA_VALUE/7.0 END) as A,
    MAX(CASE WHEN ELEMENT_ID = '1.B.1.d' THEN DATA_VALUE/7.0 END) as S,
    MAX(CASE WHEN ELEMENT_ID = '1.B.1.e' THEN DATA_VALUE/7.0 END) as E,
    MAX(CASE WHEN ELEMENT_ID = '1.B.1.f' THEN DATA_VALUE/7.0 END) as C
FROM INTERESTS_FACT i
JOIN OCCUPATION_DIM o ON i.ONET_SOC_CODE = o.ONET_SOC_CODE
GROUP BY ONET_SOC_CODE, TITLE, DESCRIPTION;
```

---

### Swift/iOS Changes

**Recipe A Changes:**
```swift
// Minimal changes needed - already pass 6 scores
// Just need to handle new response format

// SnowflakeService.swift - NO CHANGES NEEDED
// Already sends all 6 scores:
let sql = """
CALL \(database).\(schema).SP_GET_CAREER_MATCHES_V2(\(r), \(i), \(a), \(s), \(e), \(c))
"""

// ONetOccupation.swift - NO CHANGES NEEDED
// interestScore is still 0-7, conversion still works

// Only need: New stored procedure in Snowflake
```

**Minimal code changes = Low risk!**

---

## Risk Assessment

### Recipe A Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| O*NET missing data | Medium | High | Data audit first |
| Performance slow | Low | Medium | Materialized views |
| Worse results | Low | High | A/B test, keep v1.0 |
| User confusion | Low | Low | Same UI initially |

### Phase 2+ Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| User fatigue (more questions) | Medium | Medium | Keep optional |
| Data quality issues | Medium | High | Validate first |
| Development delays | High | Medium | Phased approach |
| Maintenance burden | Medium | High | Good documentation |

---

## Go/No-Go Criteria for Recipe A

### Must Have (Go Criteria ✅)
- [ ] INTERESTS_FACT has all 6 RIASEC dimensions
- [ ] Coverage > 80% of occupations
- [ ] Test query runs < 1 second
- [ ] Results look reasonable (spot check 10 careers)

### Nice to Have
- [ ] 90%+ occupation coverage
- [ ] Query < 500ms
- [ ] Clear improvement in sample results

### No-Go Conditions (❌)
- Missing 2+ RIASEC dimensions
- Query time > 2 seconds
- Data quality issues (nulls, outliers)
- Results look worse than v1.0

---

## Recommendation

**Start with Recipe A (All-6 Cosine)**

**Justification:**
1. Uses data we already collect (no UX changes)
2. Addresses main v1.0 weakness (ignoring 4 dimensions)
3. Low implementation risk
4. Foundation for future enhancements
5. Easy to A/B test and rollback

**Next Step:** Run Snowflake data audit queries above

**If audit passes:** Implement Recipe A prototype

**Timeline:**
- Week 1: Data audit + prototype
- Week 2: Implementation + testing
- Week 3: A/B test deployment
- Week 4: Analysis + decision

**Budget:** ~40-60 hours development + testing

---

## Questions for Stakeholder Review

1. **Priorities:** Is match quality the #1 priority, or are there other goals (engagement, conversion, etc.)?

2. **User Research:** Do we have feedback that v1.0 matches feel "off" or "generic"?

3. **Resources:** Can we allocate 2-3 weeks for Recipe A experiment?

4. **Data Access:** Do we have Snowflake access to run audit queries?

5. **Metrics:** What engagement metrics matter most? (saves, clicks, time on site, etc.)

6. **Long-term:** Are Work Values/Skills on the product roadmap anyway?

---

## Conclusion

**Recipe A is ready to implement** pending data verification.

The expert's suggestions are sound and well-designed. The phased approach allows us to:
- Start simple (Recipe A)
- Prove value incrementally
- Build toward comprehensive solution (Recipes C-E)
- Maintain v1.0 as safety net

**Immediate Action:** Run Snowflake data audit (queries above)

**Go/No-Go Decision:** Based on audit results

**Timeline to Production (Recipe A):** 3-4 weeks from go decision
