-- ================================================================
-- SCORING VERSION 3.0 - RECIPE C: INTERESTS + WORK VALUES
-- ================================================================
--
-- Status: PROTOTYPE - NOT YET IN PRODUCTION
-- Date: 2025-10-05
-- Author: Development Team
-- Based on: Recipe A (v2.0) + Work Values integration
--
-- This file contains the complete v3.0 scoring implementation.
-- Prerequisites: v2.0 (Recipe A) must be deployed first
-- To deploy: Run this script in Snowflake
-- To rollback: Drop procedure and restore v2.0
--
-- ================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- ================================================================
-- STEP 1: VERIFY WORK VALUES DATA (RUN FIRST)
-- ================================================================

-- Check if WORK_VALUES table exists and has all 6 dimensions
SELECT
    'Work Values Coverage Check' as audit_step,
    ELEMENT_ID,
    COUNT(DISTINCT ONET_SOC_CODE) as num_occupations,
    AVG(DATA_VALUE) as avg_score,
    MIN(DATA_VALUE) as min_score,
    MAX(DATA_VALUE) as max_score
FROM WORK_VALUES
WHERE ELEMENT_ID IN (
    '1.B.2.a',  -- Achievement
    '1.B.2.b',  -- Working Conditions
    '1.B.2.c',  -- Recognition
    '1.B.2.d',  -- Relationships
    '1.B.2.e',  -- Support
    '1.B.2.f'   -- Independence
)
GROUP BY ELEMENT_ID
ORDER BY ELEMENT_ID;

-- Check occupations with complete Work Values profiles
SELECT
    'Complete Work Values Profiles' as audit_step,
    COUNT(*) as occupations_with_all_6_values
FROM (
    SELECT ONET_SOC_CODE
    FROM WORK_VALUES
    WHERE ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f')
    GROUP BY ONET_SOC_CODE
    HAVING COUNT(DISTINCT ELEMENT_ID) = 6
);


-- ================================================================
-- STEP 2: CREATE ENHANCED VECTORS TABLE (INTERESTS + VALUES)
-- ================================================================

-- Drop if exists (for re-running)
DROP TABLE IF EXISTS CAREER_RIASEC_VALUES_VECTORS;

-- Create pre-computed vectors with both RIASEC and Work Values
CREATE TABLE CAREER_RIASEC_VALUES_VECTORS AS
SELECT
    o.ONET_SOC_CODE,
    o.TITLE,
    SUBSTR(o.DESCRIPTION, 1, 200) as SHORT_DESCRIPTION,
    -- RIASEC scores (normalized 0-1)
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.a' THEN i.DATA_VALUE/7.0 ELSE 0 END) as R_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.b' THEN i.DATA_VALUE/7.0 ELSE 0 END) as I_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.c' THEN i.DATA_VALUE/7.0 ELSE 0 END) as A_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.d' THEN i.DATA_VALUE/7.0 ELSE 0 END) as S_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.e' THEN i.DATA_VALUE/7.0 ELSE 0 END) as E_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.f' THEN i.DATA_VALUE/7.0 ELSE 0 END) as C_NORM,
    -- Work Values scores (normalized 0-1)
    MAX(CASE WHEN v.ELEMENT_ID = '1.B.2.a' THEN v.DATA_VALUE/7.0 ELSE 0 END) as ACHIEVEMENT_NORM,
    MAX(CASE WHEN v.ELEMENT_ID = '1.B.2.b' THEN v.DATA_VALUE/7.0 ELSE 0 END) as WORKING_CONDITIONS_NORM,
    MAX(CASE WHEN v.ELEMENT_ID = '1.B.2.c' THEN v.DATA_VALUE/7.0 ELSE 0 END) as RECOGNITION_NORM,
    MAX(CASE WHEN v.ELEMENT_ID = '1.B.2.d' THEN v.DATA_VALUE/7.0 ELSE 0 END) as RELATIONSHIPS_NORM,
    MAX(CASE WHEN v.ELEMENT_ID = '1.B.2.e' THEN v.DATA_VALUE/7.0 ELSE 0 END) as SUPPORT_NORM,
    MAX(CASE WHEN v.ELEMENT_ID = '1.B.2.f' THEN v.DATA_VALUE/7.0 ELSE 0 END) as INDEPENDENCE_NORM,
    -- Keep original scores for reference
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.a' THEN i.DATA_VALUE ELSE 0 END) as R,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.b' THEN i.DATA_VALUE ELSE 0 END) as I,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.c' THEN i.DATA_VALUE ELSE 0 END) as A,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.d' THEN i.DATA_VALUE ELSE 0 END) as S,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.e' THEN i.DATA_VALUE ELSE 0 END) as E,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.f' THEN i.DATA_VALUE ELSE 0 END) as C
FROM OCCUPATION_DIM o
LEFT JOIN INTERESTS_FACT i ON o.ONET_SOC_CODE = i.ONET_SOC_CODE
    AND i.ELEMENT_ID IN ('1.B.1.a', '1.B.1.b', '1.B.1.c', '1.B.1.d', '1.B.1.e', '1.B.1.f')
LEFT JOIN WORK_VALUES v ON o.ONET_SOC_CODE = v.ONET_SOC_CODE
    AND v.ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f')
GROUP BY o.ONET_SOC_CODE, o.TITLE, o.DESCRIPTION
-- Only include occupations with at least 4 RIASEC dimensions
HAVING COUNT(DISTINCT i.ELEMENT_ID) >= 4;

-- Test the table
SELECT COUNT(*) as total_careers FROM CAREER_RIASEC_VALUES_VECTORS;
SELECT TOP 10 * FROM CAREER_RIASEC_VALUES_VECTORS;


-- ================================================================
-- STEP 3: CREATE V3.0 STORED PROCEDURE (RECIPE C)
-- ================================================================

CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V3(
    -- RIASEC scores (0-5 scale from app)
    SCORE_R FLOAT,
    SCORE_I FLOAT,
    SCORE_A FLOAT,
    SCORE_S FLOAT,
    SCORE_E FLOAT,
    SCORE_C FLOAT,
    -- Work Values scores (1-5 scale from app)
    VALUE_ACHIEVEMENT FLOAT,
    VALUE_INDEPENDENCE FLOAT,
    VALUE_RECOGNITION FLOAT,
    VALUE_RELATIONSHIPS FLOAT,
    VALUE_SUPPORT FLOAT,
    VALUE_WORKING_CONDITIONS FLOAT
)
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS
$$
    // ================================================================
    // V3.0 SCORING ALGORITHM: INTERESTS + WORK VALUES
    // ================================================================

    // Normalize user RIASEC scores to 0-1 range (input is 0-5 scale)
    var userInterests = {
        R: SCORE_R / 5.0,
        I: SCORE_I / 5.0,
        A: SCORE_A / 5.0,
        S: SCORE_S / 5.0,
        E: SCORE_E / 5.0,
        C: SCORE_C / 5.0
    };

    // Normalize user Work Values scores to 0-1 range (input is 1-5 scale)
    var userValues = {
        achievement: (VALUE_ACHIEVEMENT - 1) / 4.0,           // Convert 1-5 to 0-1
        independence: (VALUE_INDEPENDENCE - 1) / 4.0,
        recognition: (VALUE_RECOGNITION - 1) / 4.0,
        relationships: (VALUE_RELATIONSHIPS - 1) / 4.0,
        support: (VALUE_SUPPORT - 1) / 4.0,
        workingConditions: (VALUE_WORKING_CONDITIONS - 1) / 4.0
    };

    // Calculate user interests vector magnitude
    var interestsMag = Math.sqrt(
        userInterests.R * userInterests.R +
        userInterests.I * userInterests.I +
        userInterests.A * userInterests.A +
        userInterests.S * userInterests.S +
        userInterests.E * userInterests.E +
        userInterests.C * userInterests.C
    );

    // Calculate user values vector magnitude
    var valuesMag = Math.sqrt(
        userValues.achievement * userValues.achievement +
        userValues.independence * userValues.independence +
        userValues.recognition * userValues.recognition +
        userValues.relationships * userValues.relationships +
        userValues.support * userValues.support +
        userValues.workingConditions * userValues.workingConditions
    );

    // Query all careers with their RIASEC and Work Values vectors
    var sql = `
        SELECT
            ONET_SOC_CODE,
            TITLE,
            SHORT_DESCRIPTION,
            R_NORM, I_NORM, A_NORM, S_NORM, E_NORM, C_NORM,
            ACHIEVEMENT_NORM, WORKING_CONDITIONS_NORM, RECOGNITION_NORM,
            RELATIONSHIPS_NORM, SUPPORT_NORM, INDEPENDENCE_NORM,
            R, I, A, S, E, C
        FROM CAREER_RIASEC_VALUES_VECTORS
    `;

    var stmt = snowflake.createStatement({sqlText: sql});
    var result = stmt.execute();

    var careers = [];

    while (result.next()) {
        // Get normalized job RIASEC scores (already 0-1)
        var jobInterests = {
            R: result.getColumnValue('R_NORM'),
            I: result.getColumnValue('I_NORM'),
            A: result.getColumnValue('A_NORM'),
            S: result.getColumnValue('S_NORM'),
            E: result.getColumnValue('E_NORM'),
            C: result.getColumnValue('C_NORM')
        };

        // Get normalized job Work Values scores (already 0-1)
        var jobValues = {
            achievement: result.getColumnValue('ACHIEVEMENT_NORM'),
            independence: result.getColumnValue('INDEPENDENCE_NORM'),
            recognition: result.getColumnValue('RECOGNITION_NORM'),
            relationships: result.getColumnValue('RELATIONSHIPS_NORM'),
            support: result.getColumnValue('SUPPORT_NORM'),
            workingConditions: result.getColumnValue('WORKING_CONDITIONS_NORM')
        };

        // Calculate job interests vector magnitude
        var jobInterestsMag = Math.sqrt(
            jobInterests.R * jobInterests.R +
            jobInterests.I * jobInterests.I +
            jobInterests.A * jobInterests.A +
            jobInterests.S * jobInterests.S +
            jobInterests.E * jobInterests.E +
            jobInterests.C * jobInterests.C
        );

        // Calculate job values vector magnitude
        var jobValuesMag = Math.sqrt(
            jobValues.achievement * jobValues.achievement +
            jobValues.independence * jobValues.independence +
            jobValues.recognition * jobValues.recognition +
            jobValues.relationships * jobValues.relationships +
            jobValues.support * jobValues.support +
            jobValues.workingConditions * jobValues.workingConditions
        );

        // Skip if any vector is zero
        if (interestsMag === 0 || jobInterestsMag === 0 || valuesMag === 0) continue;

        // Calculate interests dot product
        var interestsDotProduct =
            userInterests.R * jobInterests.R +
            userInterests.I * jobInterests.I +
            userInterests.A * jobInterests.A +
            userInterests.S * jobInterests.S +
            userInterests.E * jobInterests.E +
            userInterests.C * jobInterests.C;

        // Calculate values dot product
        var valuesDotProduct =
            userValues.achievement * jobValues.achievement +
            userValues.independence * jobValues.independence +
            userValues.recognition * jobValues.recognition +
            userValues.relationships * jobValues.relationships +
            userValues.support * jobValues.support +
            userValues.workingConditions * jobValues.workingConditions;

        // Calculate cosine similarities
        var interestsMatch = interestsDotProduct / (interestsMag * jobInterestsMag);

        // Only calculate values match if job has values data
        var valuesMatch = 0;
        if (jobValuesMag > 0) {
            valuesMatch = valuesDotProduct / (valuesMag * jobValuesMag);
        }

        // ================================================================
        // RECIPE C FORMULA: 60% Interests + 40% Values
        // ================================================================
        var blendedMatch = (0.6 * interestsMatch) + (0.4 * valuesMatch);

        // Convert to 0-7 scale (for compatibility with app)
        var interestScore = blendedMatch * 7.0;

        // Filter: only include careers with reasonable match (>= 3.5 is ~50%)
        if (interestScore >= 3.5) {
            // Determine primary and secondary match based on job's highest RIASEC scores
            var jobDimensions = [
                {name: 'Realistic', score: result.getColumnValue('R')},
                {name: 'Investigative', score: result.getColumnValue('I')},
                {name: 'Artistic', score: result.getColumnValue('A')},
                {name: 'Social', score: result.getColumnValue('S')},
                {name: 'Enterprising', score: result.getColumnValue('E')},
                {name: 'Conventional', score: result.getColumnValue('C')}
            ];
            jobDimensions.sort(function(a, b) { return b.score - a.score; });

            careers.push({
                code: result.getColumnValue('ONET_SOC_CODE'),
                title: result.getColumnValue('TITLE'),
                description: result.getColumnValue('SHORT_DESCRIPTION'),
                interest_score: interestScore,
                interests_match: interestsMatch,
                values_match: valuesMatch,
                blended_match: blendedMatch,
                primary_match: jobDimensions[0].name,
                secondary_match: jobDimensions[1].name
            });
        }
    }

    // Sort by interest_score descending
    careers.sort(function(a, b) {
        return b.interest_score - a.interest_score;
    });

    // Return top 15
    return JSON.stringify(careers.slice(0, 15));
$$;


-- ================================================================
-- STEP 4: TEST THE NEW PROCEDURE
-- ================================================================

-- Test with sample user scores
-- RIASEC: Social=5, Artistic=4.67, Realistic=4.33, Investigative=4.33, Enterprising=2, Conventional=1.67
-- Values: All moderate (3 out of 5)
CALL SP_GET_CAREER_MATCHES_V3(
    4.33, 4.33, 4.67, 5.0, 2.0, 1.67,  -- RIASEC
    3.0, 3.0, 3.0, 3.0, 3.0, 3.0       -- Work Values
);

-- Compare with v2.0 (interests only)
CALL SP_GET_CAREER_MATCHES_V2(4.33, 4.33, 4.67, 5.0, 2.0, 1.67);


-- ================================================================
-- STEP 5: PERFORMANCE BENCHMARK
-- ================================================================

-- Measure v3.0 performance
SET start_time = CURRENT_TIMESTAMP();
CALL SP_GET_CAREER_MATCHES_V3(4.0, 3.5, 2.0, 4.5, 2.5, 3.0, 3.0, 4.0, 2.0, 5.0, 4.0, 3.0);
SELECT TIMEDIFF(millisecond, $start_time, CURRENT_TIMESTAMP()) as v3_latency_ms;


-- ================================================================
-- ROLLBACK INSTRUCTIONS
-- ================================================================

/*
TO ROLLBACK TO V2.0:

1. Drop the v3.0 procedure:
   DROP PROCEDURE IF EXISTS SP_GET_CAREER_MATCHES_V3(FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT);

2. Drop the enhanced table:
   DROP TABLE IF EXISTS CAREER_RIASEC_VALUES_VECTORS;

3. App will use SP_GET_CAREER_MATCHES_V2 (v2.0)

4. Remove Work Values step from Swift onboarding
*/


-- ================================================================
-- DEPLOYMENT CHECKLIST
-- ================================================================

/*
BEFORE DEPLOYING TO PRODUCTION:

[ ] v2.0 (Recipe A) deployed and stable
[ ] Work Values data audit passed (all 6 dimensions available)
[ ] CAREER_RIASEC_VALUES_VECTORS table created successfully
[ ] SP_GET_CAREER_MATCHES_V3 created successfully
[ ] Test queries return reasonable results
[ ] Performance acceptable (<2 seconds)
[ ] Swift Work Values UI implemented
[ ] Work Values step added to onboarding flow
[ ] Snowflake service updated to send 12 parameters
[ ] A/B testing framework in place
[ ] Monitoring/analytics ready
[ ] Rollback plan tested
[ ] Stakeholder approval obtained

DEPLOYMENT STEPS:

1. Create enhanced vectors table (STEP 2 above)
2. Create v3.0 stored procedure (STEP 3 above)
3. Deploy Swift app with Work Values step
4. Update SnowflakeService to call SP_GET_CAREER_MATCHES_V3
5. Enable for 10% of users (A/B test)
6. Monitor metrics for 1-2 weeks
7. Expand to 50% if metrics positive
8. Full rollout or rollback based on results

METRICS TO MONITOR:

- Match % distribution (should be more varied)
- Career save/click rate (target: +15%)
- User satisfaction ratings (target: +20%)
- Time to first career action
- Work Values step completion rate
- "Not interested" tap rate
- Query latency (p50, p95, p99)
- Error rate
*/


-- ================================================================
-- END OF V3.0 PROTOTYPE (RECIPE C)
-- ================================================================

-- Questions or issues? Contact development team
-- Documentation: See FEASIBILITY_ANALYSIS.md and SCORING_VERSION_CONTROL.md
