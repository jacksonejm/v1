-- =============================================
-- Recipe D v4.0 - Complete Validation Script
-- =============================================
-- Run this to verify all Recipe D components are deployed
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- VALIDATION 1: Check All Required Tables Exist
-- =============================================

SELECT '=== TABLE EXISTENCE CHECK ===' AS CHECK_TYPE;

-- Check OCCUPATION_DATA (baseline)
SELECT 'OCCUPATION_DATA' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT,
       CASE WHEN COUNT(*) > 800 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM OCCUPATION_DATA;

-- Check INTERESTS_FACT (Recipe A/C)
SELECT 'INTERESTS_FACT' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT,
       CASE WHEN COUNT(*) > 4000 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM INTERESTS_FACT;

-- Check WORK_VALUES (Recipe C)
SELECT 'WORK_VALUES' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT,
       CASE WHEN COUNT(*) > 6000 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM WORK_VALUES;

-- Check SKILLS_FACT (Recipe D - NEW)
SELECT 'SKILLS_FACT' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT,
       CASE WHEN COUNT(*) > 20000 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM SKILLS_FACT;

-- Check SUBJECT_SKILLS_MAPPING (Recipe D - NEW)
SELECT 'SUBJECT_SKILLS_MAPPING' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT,
       CASE WHEN COUNT(*) > 40 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM SUBJECT_SKILLS_MAPPING;

-- Check ACTIVITY_SKILLS_MAPPING (Recipe D - NEW)
SELECT 'ACTIVITY_SKILLS_MAPPING' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT,
       CASE WHEN COUNT(*) > 40 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM ACTIVITY_SKILLS_MAPPING;

-- Check CAREER_FULL_VECTORS (Recipe D - NEW)
SELECT 'CAREER_FULL_VECTORS' AS TABLE_NAME,
       COUNT(*) AS ROW_COUNT,
       CASE WHEN COUNT(*) > 800 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM CAREER_FULL_VECTORS;

-- =============================================
-- VALIDATION 2: Check Stored Procedures Exist
-- =============================================

SELECT '=== STORED PROCEDURE CHECK ===' AS CHECK_TYPE;

SHOW PROCEDURES LIKE '%CAREER_MATCHES%';

-- You should see:
-- SP_GET_CAREER_MATCHES_V4 (Recipe D - NEW)
-- Possibly: SP_GET_CAREER_MATCHES_V3 (Recipe C - if deployed)
-- Possibly: SP_GET_CAREER_MATCHES_V2 (Recipe A - if exists)

-- =============================================
-- VALIDATION 3: Sample Data Quality Checks
-- =============================================

SELECT '=== DATA QUALITY CHECKS ===' AS CHECK_TYPE;

-- Check 3A: Verify SKILLS_FACT has both Importance and Level scales
SELECT
    SCALE_ID,
    COUNT(*) AS COUNT,
    CASE WHEN COUNT(*) > 0 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM SKILLS_FACT
GROUP BY SCALE_ID
ORDER BY SCALE_ID;
-- Expected: IM (Importance) and LV (Level)

-- Check 3B: Verify subject mappings have reasonable relevance scores
SELECT
    'Subject Mappings Avg Relevance' AS METRIC,
    ROUND(AVG(RELEVANCE_SCORE), 2) AS AVG_SCORE,
    CASE WHEN AVG(RELEVANCE_SCORE) BETWEEN 0.6 AND 1.0 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM SUBJECT_SKILLS_MAPPING;
-- Expected: 0.75-0.85 average

-- Check 3C: Verify activity mappings have reasonable relevance scores
SELECT
    'Activity Mappings Avg Relevance' AS METRIC,
    ROUND(AVG(RELEVANCE_SCORE), 2) AS AVG_SCORE,
    CASE WHEN AVG(RELEVANCE_SCORE) BETWEEN 0.6 AND 1.0 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM ACTIVITY_SKILLS_MAPPING;
-- Expected: 0.75-0.85 average

-- Check 3D: Verify CAREER_FULL_VECTORS has all dimensions
SELECT
    COUNT(*) AS CAREERS_WITH_ALL_DIMENSIONS,
    CASE WHEN COUNT(*) > 800 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM CAREER_FULL_VECTORS
WHERE REALISTIC IS NOT NULL
  AND INVESTIGATIVE IS NOT NULL
  AND ARTISTIC IS NOT NULL
  AND SOCIAL IS NOT NULL
  AND ENTERPRISING IS NOT NULL
  AND CONVENTIONAL IS NOT NULL
  AND ACHIEVEMENT IS NOT NULL
  AND INDEPENDENCE IS NOT NULL;

-- Check 3E: Verify CAREER_FULL_VECTORS has skills vectors
SELECT
    'Careers with Skills Vectors' AS METRIC,
    COUNT(*) AS COUNT,
    CASE WHEN COUNT(*) > 700 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM CAREER_FULL_VECTORS
WHERE SKILLS_VECTOR IS NOT NULL
  AND ARRAY_SIZE(SKILLS_VECTOR) > 0;

-- =============================================
-- VALIDATION 4: Test Subject/Activity Mappings
-- =============================================

SELECT '=== SUBJECT/ACTIVITY MAPPING TESTS ===' AS CHECK_TYPE;

-- Test 4A: Check Math subject mapping
SELECT
    'Math Subject Mapping' AS TEST,
    COUNT(*) AS SKILLS_MAPPED,
    CASE WHEN COUNT(*) >= 3 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM SUBJECT_SKILLS_MAPPING
WHERE SUBJECT_NAME = 'Math';
-- Expected: At least 3 skills

-- Test 4B: Check Computer Science subject mapping
SELECT
    'Computer Science Mapping' AS TEST,
    COUNT(*) AS SKILLS_MAPPED,
    CASE WHEN COUNT(*) >= 3 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM SUBJECT_SKILLS_MAPPING
WHERE SUBJECT_NAME = 'Computer Science';
-- Expected: At least 3 skills

-- Test 4C: Check Coding/Programming activity mapping
SELECT
    'Coding/Programming Mapping' AS TEST,
    COUNT(*) AS SKILLS_MAPPED,
    CASE WHEN COUNT(*) >= 2 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM ACTIVITY_SKILLS_MAPPING
WHERE ACTIVITY_NAME = 'Coding/Programming';
-- Expected: At least 2 skills

-- Test 4D: Check Volunteering activity mapping
SELECT
    'Volunteering Mapping' AS TEST,
    COUNT(*) AS SKILLS_MAPPED,
    CASE WHEN COUNT(*) >= 2 THEN '✅ PASS' ELSE '❌ FAIL' END AS STATUS
FROM ACTIVITY_SKILLS_MAPPING
WHERE ACTIVITY_NAME = 'Volunteering';
-- Expected: At least 2 skills

-- =============================================
-- VALIDATION 5: Sample Career Data
-- =============================================

SELECT '=== SAMPLE CAREER DATA ===' AS CHECK_TYPE;

-- Check Software Developer has complete data
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL,
    ACHIEVEMENT, INDEPENDENCE, RECOGNITION,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS,
    CASE
        WHEN INVESTIGATIVE > 4 AND ARRAY_SIZE(SKILLS_VECTOR) > 5 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS STATUS
FROM CAREER_FULL_VECTORS
WHERE JOB_TITLE LIKE '%Software Developer%'
LIMIT 1;
-- Expected: High Investigative, multiple skills

-- Check Registered Nurse has complete data
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL,
    ACHIEVEMENT, RELATIONSHIPS, SUPPORT,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS,
    CASE
        WHEN SOCIAL > 4 AND ARRAY_SIZE(SKILLS_VECTOR) > 5 THEN '✅ PASS'
        ELSE '❌ FAIL'
    END AS STATUS
FROM CAREER_FULL_VECTORS
WHERE JOB_TITLE LIKE '%Nurse%'
LIMIT 1;
-- Expected: High Social, multiple skills

-- =============================================
-- VALIDATION 6: Test SP_GET_CAREER_MATCHES_V4
-- =============================================

SELECT '=== STORED PROCEDURE TEST ===' AS CHECK_TYPE;

-- Test 6: STEM Student Profile
-- This will actually call the procedure and verify it works
CALL SP_GET_CAREER_MATCHES_V4(
    -- RIASEC: High Investigative
    2.0, 5.0, 2.5, 3.0, 3.0, 4.0,
    -- Work Values: High Achievement, Independence
    5.0, 5.0, 3.0, 2.5, 2.5, 3.5,
    -- Subjects: Math, Computer Science, Science
    '["Math", "Computer Science", "Science"]',
    -- Activities: Coding, Math Club
    '["Coding/Programming", "Math Club"]',
    -- Career Interests: Software Developer, Data Scientist
    '["Software Developer", "Data Scientist"]',
    -- Student Level
    'Undergraduate',
    -- Current Status
    'Student'
);

-- Expected results:
-- - Should return 50 rows
-- - Software Developer should be in top 5
-- - Data Scientist should be in top 5
-- - All match scores should be between 0 and 1
-- - Match explanations should be present (e.g., "I:85% V:75% S:80% C:90%")

-- =============================================
-- VALIDATION 7: Detailed Results Analysis
-- =============================================

-- Analyze the results from the procedure call above
-- (You'll need to scroll up to see the results)

SELECT '=== ANALYZE TOP 5 RESULTS ===' AS CHECK_TYPE;

-- NOTE: You should manually check the results above for:
-- 1. ✅ Returns exactly 50 rows
-- 2. ✅ Software Developer is in top 5 (rows 1-5)
-- 3. ✅ Data Scientist is in top 5 (rows 1-5)
-- 4. ✅ INTERESTS_MATCH is between 0.0 and 1.0
-- 5. ✅ VALUES_MATCH is between 0.0 and 1.0
-- 6. ✅ SKILLS_MATCH is between 0.0 and 1.0
-- 7. ✅ CONTEXT_SCORE is between 0.0 and 1.0
-- 8. ✅ BLENDED_MATCH is between 0.0 and 1.0
-- 9. ✅ FINAL_SCORE is between 0.0 and 7.0
-- 10. ✅ MATCH_EXPLANATION contains all 4 dimensions (I:%, V:%, S:%, C:%)

-- =============================================
-- VALIDATION 8: Performance Check
-- =============================================

SELECT '=== PERFORMANCE CHECK ===' AS CHECK_TYPE;

-- Run the procedure again and check the execution time
-- Target: < 2000ms (2 seconds)

-- Check query history for last execution time
SELECT
    QUERY_TEXT,
    TOTAL_ELAPSED_TIME / 1000 AS ELAPSED_MS,
    CASE
        WHEN TOTAL_ELAPSED_TIME / 1000 < 2000 THEN '✅ PASS (< 2s)'
        WHEN TOTAL_ELAPSED_TIME / 1000 < 5000 THEN '⚠️ SLOW (< 5s)'
        ELSE '❌ FAIL (> 5s)'
    END AS STATUS
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE QUERY_TEXT LIKE '%SP_GET_CAREER_MATCHES_V4%'
  AND EXECUTION_STATUS = 'SUCCESS'
ORDER BY START_TIME DESC
LIMIT 1;

-- =============================================
-- VALIDATION SUMMARY
-- =============================================

SELECT '=== VALIDATION SUMMARY ===' AS SUMMARY;

-- Run this final check to get overall status
SELECT
    '✅ If all checks above show PASS, Recipe D v4.0 is fully deployed!' AS STATUS,
    '⏳ Next step: Test in iOS app' AS NEXT_STEP;

-- =============================================
-- EXPECTED CHECKLIST
-- =============================================
-- After running this script, you should see:
--
-- ✅ OCCUPATION_DATA: 800+ rows
-- ✅ INTERESTS_FACT: 4000+ rows
-- ✅ WORK_VALUES: 6000+ rows
-- ✅ SKILLS_FACT: 20000+ rows
-- ✅ SUBJECT_SKILLS_MAPPING: 40+ rows
-- ✅ ACTIVITY_SKILLS_MAPPING: 40+ rows
-- ✅ CAREER_FULL_VECTORS: 800+ rows
-- ✅ SP_GET_CAREER_MATCHES_V4: Exists
-- ✅ STEM test returns 50 results
-- ✅ Software Developer in top 5
-- ✅ Execution time < 2000ms
-- ✅ All match scores between 0.0 and 1.0
-- ✅ Match explanations present
--
-- If any ❌ FAIL appears, review the specific section
-- =============================================
