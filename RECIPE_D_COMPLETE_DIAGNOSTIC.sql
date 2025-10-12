USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Recipe D v4.0 - Complete Diagnostic
-- =============================================
-- This script verifies the entire Recipe D v4.0 setup:
-- 1. SOC mapping is working
-- 2. Software Developers has skills in CAREER_FULL_VECTORS
-- 3. Mapping tables cover all skills
-- 4. SP_GET_CAREER_MATCHES_V4 works correctly
-- =============================================

SELECT '=============================================' AS SEPARATOR;
SELECT 'STEP 1: Verify SOC Mapping' AS STEP;
SELECT '=============================================' AS SEPARATOR;

-- Check if SOC_SKILLS_MAPPING exists and has the Software Developer mapping
SELECT * FROM SOC_SKILLS_MAPPING;

SELECT '=============================================' AS SEPARATOR;
SELECT 'STEP 2: Verify Software Developers in CAREER_FULL_VECTORS' AS STEP;
SELECT '=============================================' AS SEPARATOR;

-- Check if Software Developers exists and has skills
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS,
    REALISTIC,
    INVESTIGATIVE,
    ARTISTIC,
    SOCIAL,
    ENTERPRISING,
    CONVENTIONAL
FROM CAREER_FULL_VECTORS
WHERE ONET_SOC_CODE = '15-1252.00';

-- Parse and display Software Developers' skills
SELECT 'Software Developers Skills (from CAREER_FULL_VECTORS):' AS INFO;
SELECT
    f.VALUE:skill_id::STRING AS SKILL_ID,
    f.VALUE:skill_name::STRING AS SKILL_NAME,
    f.VALUE:importance::FLOAT AS IMPORTANCE
FROM CAREER_FULL_VECTORS,
LATERAL FLATTEN(input => SKILLS_VECTOR) f
WHERE ONET_SOC_CODE = '15-1252.00'
ORDER BY f.VALUE:importance::FLOAT DESC;

SELECT '=============================================' AS SEPARATOR;
SELECT 'STEP 3: Verify Mapping Tables' AS STEP;
SELECT '=============================================' AS SEPARATOR;

-- Check SUBJECT_SKILLS_MAPPING
SELECT 'SUBJECT_SKILLS_MAPPING row count:' AS INFO, COUNT(*) AS TOTAL_ROWS
FROM SUBJECT_SKILLS_MAPPING;

-- Check ACTIVITY_SKILLS_MAPPING
SELECT 'ACTIVITY_SKILLS_MAPPING row count:' AS INFO, COUNT(*) AS TOTAL_ROWS
FROM ACTIVITY_SKILLS_MAPPING;

-- Show key mappings for STEM students
SELECT 'Key Subject Mappings (Math, Computer Science):' AS INFO;
SELECT
    SUBJECT_NAME,
    ONET_SKILL_ID,
    SKILL_NAME,
    RELEVANCE_SCORE
FROM SUBJECT_SKILLS_MAPPING
WHERE SUBJECT_NAME IN ('Math', 'Computer Science')
ORDER BY SUBJECT_NAME, RELEVANCE_SCORE DESC;

SELECT 'Key Activity Mappings (Coding/Programming):' AS INFO;
SELECT
    ACTIVITY_NAME,
    ONET_SKILL_ID,
    SKILL_NAME,
    RELEVANCE_SCORE
FROM ACTIVITY_SKILLS_MAPPING
WHERE ACTIVITY_NAME = 'Coding/Programming'
ORDER BY RELEVANCE_SCORE DESC;

SELECT '=============================================' AS SEPARATOR;
SELECT 'STEP 4: Verify Mapping to Computer Programmers (Source of Skills)' AS STEP;
SELECT '=============================================' AS SEPARATOR;

-- Show Computer Programmers' top skills (these are borrowed by Software Developers)
SELECT 'Computer Programmers (15-1251.00) Top Skills:' AS INFO;
SELECT
    ELEMENT_ID,
    ELEMENT_NAME,
    DATA_VALUE AS IMPORTANCE
FROM SKILLS_FACT
WHERE ONET_SOC_CODE = '15-1251.00'
  AND SCALE_ID = 'IM'
ORDER BY DATA_VALUE DESC
LIMIT 10;

SELECT '=============================================' AS SEPARATOR;
SELECT 'STEP 5: Verify Skills Match for STEM Profile' AS STEP;
SELECT '=============================================' AS SEPARATOR;

-- Check if Math subject maps to skills that Software Developers has
SELECT 'Math → Software Developer Skills Match:' AS INFO;
WITH SW_DEV_SKILLS AS (
    SELECT
        f.VALUE:skill_id::STRING AS SKILL_ID,
        f.VALUE:skill_name::STRING AS SKILL_NAME,
        f.VALUE:importance::FLOAT AS IMPORTANCE
    FROM CAREER_FULL_VECTORS cfv,
    LATERAL FLATTEN(input => cfv.SKILLS_VECTOR) f
    WHERE cfv.ONET_SOC_CODE = '15-1252.00'
)
SELECT
    ssm.SUBJECT_NAME,
    ssm.ONET_SKILL_ID,
    ssm.SKILL_NAME,
    ssm.RELEVANCE_SCORE,
    sds.IMPORTANCE AS SW_DEV_IMPORTANCE
FROM SUBJECT_SKILLS_MAPPING ssm
LEFT JOIN SW_DEV_SKILLS sds ON sds.SKILL_ID = ssm.ONET_SKILL_ID
WHERE ssm.SUBJECT_NAME = 'Math'
ORDER BY SW_DEV_IMPORTANCE DESC NULLS LAST;

-- Check if Computer Science subject maps to skills that Software Developers has
SELECT 'Computer Science → Software Developer Skills Match:' AS INFO;
WITH SW_DEV_SKILLS AS (
    SELECT
        f.VALUE:skill_id::STRING AS SKILL_ID,
        f.VALUE:skill_name::STRING AS SKILL_NAME,
        f.VALUE:importance::FLOAT AS IMPORTANCE
    FROM CAREER_FULL_VECTORS cfv,
    LATERAL FLATTEN(input => cfv.SKILLS_VECTOR) f
    WHERE cfv.ONET_SOC_CODE = '15-1252.00'
)
SELECT
    ssm.SUBJECT_NAME,
    ssm.ONET_SKILL_ID,
    ssm.SKILL_NAME,
    ssm.RELEVANCE_SCORE,
    sds.IMPORTANCE AS SW_DEV_IMPORTANCE
FROM SUBJECT_SKILLS_MAPPING ssm
LEFT JOIN SW_DEV_SKILLS sds ON sds.SKILL_ID = ssm.ONET_SKILL_ID
WHERE ssm.SUBJECT_NAME = 'Computer Science'
ORDER BY SW_DEV_IMPORTANCE DESC NULLS LAST;

-- Check if Coding/Programming activity maps to skills that Software Developers has
SELECT 'Coding/Programming → Software Developer Skills Match:' AS INFO;
WITH SW_DEV_SKILLS AS (
    SELECT
        f.VALUE:skill_id::STRING AS SKILL_ID,
        f.VALUE:skill_name::STRING AS SKILL_NAME,
        f.VALUE:importance::FLOAT AS IMPORTANCE
    FROM CAREER_FULL_VECTORS cfv,
    LATERAL FLATTEN(input => cfv.SKILLS_VECTOR) f
    WHERE cfv.ONET_SOC_CODE = '15-1252.00'
)
SELECT
    asm.ACTIVITY_NAME,
    asm.ONET_SKILL_ID,
    asm.SKILL_NAME,
    asm.RELEVANCE_SCORE,
    sds.IMPORTANCE AS SW_DEV_IMPORTANCE
FROM ACTIVITY_SKILLS_MAPPING asm
LEFT JOIN SW_DEV_SKILLS sds ON sds.SKILL_ID = asm.ONET_SKILL_ID
WHERE asm.ACTIVITY_NAME = 'Coding/Programming'
ORDER BY SW_DEV_IMPORTANCE DESC NULLS LAST;

SELECT '=============================================' AS SEPARATOR;
SELECT 'STEP 6: Test SP_GET_CAREER_MATCHES_V4 with STEM Profile' AS STEP;
SELECT '=============================================' AS SEPARATOR;

-- Test with a STEM student profile
-- High Investigative (5.0), Math + Computer Science subjects, Coding activity
CALL SP_GET_CAREER_MATCHES_V4(
    -- RIASEC: R, I, A, S, E, C
    2.0, 5.0, 2.5, 3.0, 3.0, 4.0,
    -- Work Values: Achievement, Independence, Recognition, Relationships, Support, Working Conditions
    5.0, 5.0, 3.0, 2.5, 2.5, 3.5,
    -- Subjects
    '["Math", "Computer Science"]',
    -- Activities
    '["Coding/Programming"]',
    -- Career Interests
    '["Software Developer"]',
    -- Student Level
    'Undergraduate',
    -- Current Status
    'Student'
);

SELECT '=============================================' AS SEPARATOR;
SELECT 'STEP 7: Overall Health Check' AS STEP;
SELECT '=============================================' AS SEPARATOR;

-- Check how many careers have skills
SELECT 'Careers with skills distribution:' AS INFO;
SELECT
    CASE
        WHEN ARRAY_SIZE(SKILLS_VECTOR) = 0 THEN '0 skills (needs SOC mapping)'
        WHEN ARRAY_SIZE(SKILLS_VECTOR) < 10 THEN '1-9 skills'
        WHEN ARRAY_SIZE(SKILLS_VECTOR) = 10 THEN '10 skills (good)'
        ELSE '10+ skills'
    END AS SKILL_RANGE,
    COUNT(*) AS NUM_CAREERS
FROM CAREER_FULL_VECTORS
GROUP BY SKILL_RANGE
ORDER BY SKILL_RANGE;

-- List a few careers without skills (may need more SOC mappings)
SELECT 'Sample careers without skills (may need SOC mapping):' AS INFO;
SELECT
    ONET_SOC_CODE,
    JOB_TITLE
FROM CAREER_FULL_VECTORS
WHERE ARRAY_SIZE(SKILLS_VECTOR) = 0
LIMIT 10;

SELECT '=============================================' AS SEPARATOR;
SELECT 'Diagnostic Complete!' AS STATUS;
SELECT '=============================================' AS SEPARATOR;

-- =============================================
-- Expected Results:
-- =============================================
-- STEP 1: Should show 1 mapping (15-1252.00 → 15-1251.00)
-- STEP 2: Software Developers should have 10 skills including 2.B.3.e (Programming)
-- STEP 3: Mapping tables should have 100+ rows each
-- STEP 4: Computer Programmers should have Programming, Critical Thinking, etc.
-- STEP 5: Math, CS, and Coding should map to skills Software Developers has
-- STEP 6: Software Developers should appear in top 3 with high skills match (40-60%)
-- STEP 7: Most careers should have 10 skills; some may have 0 (need more mappings)
-- =============================================
