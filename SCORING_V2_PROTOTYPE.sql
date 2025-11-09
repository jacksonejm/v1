-- ================================================================
-- SCORING VERSION 2.0 - RECIPE A: ALL-6 INTEREST COSINE
-- ================================================================
--
-- Status: PROTOTYPE - NOT YET IN PRODUCTION
-- Date: 2025-10-05
-- Author: Development Team
-- Based on: Expert recommendation for enhanced personalization
--
-- This file contains the complete v2.0 scoring implementation.
-- To deploy: Run this script in Snowflake
-- To rollback: Drop procedure and restore v1.0 from backup
--
-- ================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- ================================================================
-- STEP 1: DATA AUDIT (RUN FIRST TO VERIFY FEASIBILITY)
-- ================================================================

-- Check if we have all 6 RIASEC dimensions per occupation
SELECT
    'RIASEC Coverage Check' as audit_step,
    ELEMENT_ID,
    COUNT(DISTINCT ONET_SOC_CODE) as num_occupations,
    AVG(DATA_VALUE) as avg_score,
    MIN(DATA_VALUE) as min_score,
    MAX(DATA_VALUE) as max_score
FROM INTERESTS_FACT
WHERE ELEMENT_ID IN (
    '1.B.1.a',  -- Realistic
    '1.B.1.b',  -- Investigative
    '1.B.1.c',  -- Artistic
    '1.B.1.d',  -- Social
    '1.B.1.e',  -- Enterprising
    '1.B.1.f'   -- Conventional
)
GROUP BY ELEMENT_ID
ORDER BY ELEMENT_ID;

-- Check total unique occupations
SELECT
    'Total Occupations' as audit_step,
    COUNT(DISTINCT ONET_SOC_CODE) as total_occupations
FROM OCCUPATION_DIM;

-- Check occupations with complete RIASEC profiles
SELECT
    'Complete RIASEC Profiles' as audit_step,
    COUNT(*) as occupations_with_all_6
FROM (
    SELECT ONET_SOC_CODE
    FROM INTERESTS_FACT
    WHERE ELEMENT_ID IN ('1.B.1.a', '1.B.1.b', '1.B.1.c', '1.B.1.d', '1.B.1.e', '1.B.1.f')
    GROUP BY ONET_SOC_CODE
    HAVING COUNT(DISTINCT ELEMENT_ID) = 6
);

-- Sample data quality check
SELECT TOP 5
    o.ONET_SOC_CODE,
    o.TITLE,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.a' THEN i.DATA_VALUE END) as Realistic,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.b' THEN i.DATA_VALUE END) as Investigative,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.c' THEN i.DATA_VALUE END) as Artistic,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.d' THEN i.DATA_VALUE END) as Social,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.e' THEN i.DATA_VALUE END) as Enterprising,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.f' THEN i.DATA_VALUE END) as Conventional
FROM INTERESTS_FACT i
JOIN OCCUPATION_DIM o ON i.ONET_SOC_CODE = o.ONET_SOC_CODE
GROUP BY o.ONET_SOC_CODE, o.TITLE
ORDER BY o.TITLE;


-- ================================================================
-- STEP 2: CREATE VIEW OR TABLE (PERFORMANCE OPTIMIZATION)
-- ================================================================
-- Note: Snowflake materialized views only support single-table queries
-- We'll use a regular TABLE with pre-computed data instead

-- Drop if exists (for re-running)
DROP TABLE IF EXISTS CAREER_RIASEC_VECTORS;

-- Create pre-computed RIASEC vectors for fast querying
CREATE TABLE CAREER_RIASEC_VECTORS AS
SELECT
    o.ONET_SOC_CODE,
    o.TITLE,
    SUBSTR(o.DESCRIPTION, 1, 200) as SHORT_DESCRIPTION,
    -- Normalize all scores to 0-1 (divide by 7)
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.a' THEN i.DATA_VALUE/7.0 ELSE 0 END) as R_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.b' THEN i.DATA_VALUE/7.0 ELSE 0 END) as I_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.c' THEN i.DATA_VALUE/7.0 ELSE 0 END) as A_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.d' THEN i.DATA_VALUE/7.0 ELSE 0 END) as S_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.e' THEN i.DATA_VALUE/7.0 ELSE 0 END) as E_NORM,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.f' THEN i.DATA_VALUE/7.0 ELSE 0 END) as C_NORM,
    -- Keep original scores for reference
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.a' THEN i.DATA_VALUE ELSE 0 END) as R,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.b' THEN i.DATA_VALUE ELSE 0 END) as I,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.c' THEN i.DATA_VALUE ELSE 0 END) as A,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.d' THEN i.DATA_VALUE ELSE 0 END) as S,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.e' THEN i.DATA_VALUE ELSE 0 END) as E,
    MAX(CASE WHEN i.ELEMENT_ID = '1.B.1.f' THEN i.DATA_VALUE ELSE 0 END) as C
FROM INTERESTS_FACT i
JOIN OCCUPATION_DIM o ON i.ONET_SOC_CODE = o.ONET_SOC_CODE
WHERE i.ELEMENT_ID IN ('1.B.1.a', '1.B.1.b', '1.B.1.c', '1.B.1.d', '1.B.1.e', '1.B.1.f')
GROUP BY o.ONET_SOC_CODE, o.TITLE, o.DESCRIPTION
-- Only include occupations with data for at least 4 dimensions
HAVING COUNT(DISTINCT i.ELEMENT_ID) >= 4;

-- Test the table
SELECT COUNT(*) as total_careers FROM CAREER_RIASEC_VECTORS;
SELECT TOP 10 * FROM CAREER_RIASEC_VECTORS;


-- ================================================================
-- STEP 3: CREATE V2.0 STORED PROCEDURE (COSINE SIMILARITY)
-- ================================================================

CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V2(
    SCORE_R FLOAT,
    SCORE_I FLOAT,
    SCORE_A FLOAT,
    SCORE_S FLOAT,
    SCORE_E FLOAT,
    SCORE_C FLOAT
)
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS
$$
    // ================================================================
    // V2.0 SCORING ALGORITHM: ALL-6 INTEREST COSINE SIMILARITY
    // ================================================================

    // Normalize user scores to 0-1 range (input is 0-5 scale)
    var user = {
        R: SCORE_R / 5.0,
        I: SCORE_I / 5.0,
        A: SCORE_A / 5.0,
        S: SCORE_S / 5.0,
        E: SCORE_E / 5.0,
        C: SCORE_C / 5.0
    };

    // Calculate user vector magnitude (for cosine similarity)
    var userMag = Math.sqrt(
        user.R * user.R +
        user.I * user.I +
        user.A * user.A +
        user.S * user.S +
        user.E * user.E +
        user.C * user.C
    );

    // Identify top 2 dimensions for labeling
    var dimensions = [
        {type: 'R', score: SCORE_R, name: 'Realistic'},
        {type: 'I', score: SCORE_I, name: 'Investigative'},
        {type: 'A', score: SCORE_A, name: 'Artistic'},
        {type: 'S', score: SCORE_S, name: 'Social'},
        {type: 'E', score: SCORE_E, name: 'Enterprising'},
        {type: 'C', score: SCORE_C, name: 'Conventional'}
    ];
    dimensions.sort(function(a, b) { return b.score - a.score; });
    var topDim = dimensions[0];
    var secondDim = dimensions[1];

    // Query all careers with their RIASEC vectors
    var sql = `
        SELECT
            ONET_SOC_CODE,
            TITLE,
            SHORT_DESCRIPTION,
            R_NORM, I_NORM, A_NORM, S_NORM, E_NORM, C_NORM,
            R, I, A, S, E, C
        FROM CAREER_RIASEC_VECTORS
    `;

    var stmt = snowflake.createStatement({sqlText: sql});
    var result = stmt.execute();

    var careers = [];

    while (result.next()) {
        // Get normalized job scores (already 0-1)
        var job = {
            R: result.getColumnValue('R_NORM'),
            I: result.getColumnValue('I_NORM'),
            A: result.getColumnValue('A_NORM'),
            S: result.getColumnValue('S_NORM'),
            E: result.getColumnValue('E_NORM'),
            C: result.getColumnValue('C_NORM')
        };

        // Calculate job vector magnitude
        var jobMag = Math.sqrt(
            job.R * job.R +
            job.I * job.I +
            job.A * job.A +
            job.S * job.S +
            job.E * job.E +
            job.C * job.C
        );

        // Skip if either vector is zero (shouldn't happen but safety check)
        if (userMag === 0 || jobMag === 0) continue;

        // Calculate dot product
        var dotProduct =
            user.R * job.R +
            user.I * job.I +
            user.A * job.A +
            user.S * job.S +
            user.E * job.E +
            user.C * job.C;

        // Calculate cosine similarity (-1 to 1, but should be 0 to 1 for our use case)
        var cosineSimilarity = dotProduct / (userMag * jobMag);

        // Convert to 0-7 scale (for compatibility with existing app logic)
        // We map cosine similarity (0-1) to interest_score (0-7)
        var interestScore = cosineSimilarity * 7.0;

        // Filter: only include careers with reasonable match (>= 3.5 is ~50%)
        if (interestScore >= 3.5) {
            // Determine primary and secondary match based on job's highest scores
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
                cosine_similarity: cosineSimilarity,
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

-- Test with sample user scores (Social=5, Artistic=4.67, Conventional=4.33)
CALL SP_GET_CAREER_MATCHES_V2(3.0, 4.33, 4.67, 5.0, 1.33, 4.33);

-- Compare with v1.0 (just uses top 2) - COMMENTED OUT if v1.0 doesn't exist yet
-- CALL SP_GET_CAREER_MATCHES(3.0, 4.33, 4.67, 5.0, 1.33, 4.33);


-- ================================================================
-- STEP 5: PERFORMANCE BENCHMARK
-- ================================================================

-- Measure v1.0 performance - COMMENTED OUT if v1.0 doesn't exist yet
-- SET start_time = CURRENT_TIMESTAMP();
-- CALL SP_GET_CAREER_MATCHES(4.0, 3.5, 2.0, 4.5, 2.5, 3.0);
-- SELECT TIMEDIFF(millisecond, $start_time, CURRENT_TIMESTAMP()) as v1_latency_ms;

-- Measure v2.0 performance
SET start_time = CURRENT_TIMESTAMP();
CALL SP_GET_CAREER_MATCHES_V2(4.0, 3.5, 2.0, 4.5, 2.5, 3.0);
SELECT TIMEDIFF(millisecond, $start_time, CURRENT_TIMESTAMP()) as v2_latency_ms;


-- ================================================================
-- STEP 6: SIDE-BY-SIDE COMPARISON QUERY
-- ================================================================

-- Run both versions and compare results - COMMENTED OUT if v1.0 doesn't exist yet
/*
WITH v1_results AS (
    SELECT parse_json(SP_GET_CAREER_MATCHES(4.0, 3.5, 2.0, 4.5, 2.5, 3.0)) as results
),
v2_results AS (
    SELECT parse_json(SP_GET_CAREER_MATCHES_V2(4.0, 3.5, 2.0, 4.5, 2.5, 3.0)) as results
)
SELECT
    'v1.0' as version,
    f.value:title::STRING as career,
    f.value:interest_score::FLOAT as score,
    ROW_NUMBER() OVER (ORDER BY f.value:interest_score::FLOAT DESC) as rank
FROM v1_results, LATERAL FLATTEN(input => v1_results.results) f
UNION ALL
SELECT
    'v2.0' as version,
    f.value:title::STRING as career,
    f.value:interest_score::FLOAT as score,
    ROW_NUMBER() OVER (ORDER BY f.value:interest_score::FLOAT DESC) as rank
FROM v2_results, LATERAL FLATTEN(input => v2_results.results) f
ORDER BY version, rank;
*/


-- ================================================================
-- ROLLBACK INSTRUCTIONS
-- ================================================================

/*
TO ROLLBACK TO V1.0:

1. Drop the new procedure:
   DROP PROCEDURE IF EXISTS SP_GET_CAREER_MATCHES_V2(FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT);

2. Drop the pre-computed table:
   DROP TABLE IF EXISTS CAREER_RIASEC_VECTORS;

3. App will continue using SP_GET_CAREER_MATCHES (v1.0)

4. No Swift code changes needed (if you used feature flag)
*/


-- ================================================================
-- DEPLOYMENT CHECKLIST
-- ================================================================

/*
BEFORE DEPLOYING TO PRODUCTION:

[ ] Data audit passed (all 6 RIASEC dimensions available)
[ ] Pre-computed table (CAREER_RIASEC_VECTORS) created successfully
[ ] SP_GET_CAREER_MATCHES_V2 created successfully
[ ] Test queries return reasonable results
[ ] Performance acceptable (<1 second)
[ ] Side-by-side comparison shows improvement
[ ] Swift feature flag implemented for A/B testing
[ ] Monitoring/analytics in place
[ ] Rollback plan tested
[ ] Stakeholder approval obtained

DEPLOYMENT STEPS:

1. Create pre-computed table (STEP 2 above)
2. Create new stored procedure (STEP 3 above)
3. Deploy Swift app with feature flag
4. Enable for 10% of users (A group)
5. Monitor metrics for 1 week
6. Expand to 50% if metrics positive
7. Full rollout or rollback based on results

METRICS TO MONITOR:

- Match % distribution (should be more varied than v1.0)
- Career save/click rate
- User satisfaction ratings
- Time to first career action
- "Not interested" tap rate
- Query latency (p50, p95, p99)
- Error rate
*/


-- ================================================================
-- END OF V2.0 PROTOTYPE
-- ================================================================

-- Questions or issues? Contact development team
-- Documentation: See SCORING_VERSION_CONTROL.md and FEASIBILITY_ANALYSIS.md
