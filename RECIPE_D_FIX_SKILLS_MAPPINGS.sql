USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Recipe D v4.0 - Fix Skills Mapping Issue
-- =============================================
-- Problem: Software Developers showing 0% skills match
-- Root Cause: Skill IDs in mappings don't match actual SKILLS_FACT data
-- =============================================

-- Step 1: Check actual skill IDs for Software Developers (15-1252.00)
SELECT 'Step 1: Top 10 skills for Software Developers' AS STATUS;

SELECT
    ONET_SOC_CODE,
    ELEMENT_ID,
    ELEMENT_NAME,
    DATA_VALUE AS IMPORTANCE
FROM SKILLS_FACT
WHERE ONET_SOC_CODE = '15-1252.00'
  AND SCALE_ID = 'IM'  -- Importance scale
ORDER BY DATA_VALUE DESC
LIMIT 10;

-- Step 2: Check what we mapped for Math
SELECT 'Step 2: Our Math mappings' AS STATUS;

SELECT ONET_SKILL_ID, SKILL_NAME, RELEVANCE_SCORE
FROM SUBJECT_SKILLS_MAPPING
WHERE SUBJECT_NAME = 'Math';

-- Step 3: Check what we mapped for Computer Science
SELECT 'Step 3: Our Computer Science mappings' AS STATUS;

SELECT ONET_SKILL_ID, SKILL_NAME, RELEVANCE_SCORE
FROM SUBJECT_SKILLS_MAPPING
WHERE SUBJECT_NAME = 'Computer Science';

-- Step 4: Check what we mapped for Coding/Programming
SELECT 'Step 4: Our Coding/Programming mappings' AS STATUS;

SELECT ONET_SKILL_ID, SKILL_NAME, RELEVANCE_SCORE
FROM ACTIVITY_SKILLS_MAPPING
WHERE ACTIVITY_NAME = 'Coding/Programming';

-- Step 5: Check if ANY of our mapped skill IDs exist in SKILLS_FACT
SELECT 'Step 5: Do our mapped skill IDs exist in SKILLS_FACT?' AS STATUS;

SELECT DISTINCT
    ssm.SUBJECT_NAME,
    ssm.ONET_SKILL_ID,
    ssm.SKILL_NAME,
    COUNT(DISTINCT sf.ONET_SOC_CODE) AS NUM_CAREERS_WITH_THIS_SKILL
FROM SUBJECT_SKILLS_MAPPING ssm
LEFT JOIN SKILLS_FACT sf ON ssm.ONET_SKILL_ID = sf.ELEMENT_ID
WHERE ssm.SUBJECT_NAME IN ('Math', 'Computer Science')
GROUP BY ssm.SUBJECT_NAME, ssm.ONET_SKILL_ID, ssm.SKILL_NAME
ORDER BY ssm.SUBJECT_NAME, NUM_CAREERS_WITH_THIS_SKILL DESC;

-- Step 6: Find all Programming-related skills in SKILLS_FACT
SELECT 'Step 6: All Programming-related skills in SKILLS_FACT' AS STATUS;

SELECT DISTINCT
    ELEMENT_ID,
    ELEMENT_NAME,
    COUNT(DISTINCT ONET_SOC_CODE) AS NUM_CAREERS
FROM SKILLS_FACT
WHERE SCALE_ID = 'IM'
  AND (ELEMENT_NAME ILIKE '%program%'
       OR ELEMENT_NAME ILIKE '%coding%'
       OR ELEMENT_NAME ILIKE '%software%')
GROUP BY ELEMENT_ID, ELEMENT_NAME
ORDER BY NUM_CAREERS DESC;

-- Step 7: Find all Math-related skills in SKILLS_FACT
SELECT 'Step 7: All Math-related skills in SKILLS_FACT' AS STATUS;

SELECT DISTINCT
    ELEMENT_ID,
    ELEMENT_NAME,
    COUNT(DISTINCT ONET_SOC_CODE) AS NUM_CAREERS
FROM SKILLS_FACT
WHERE SCALE_ID = 'IM'
  AND (ELEMENT_NAME ILIKE '%math%'
       OR ELEMENT_NAME ILIKE '%computation%'
       OR ELEMENT_NAME ILIKE '%quantitative%')
GROUP BY ELEMENT_ID, ELEMENT_NAME
ORDER BY NUM_CAREERS DESC;

-- =============================================
-- Expected Findings:
-- - Step 1 will show actual skill IDs for Software Developers
-- - Steps 2-4 will show what we mapped
-- - Step 5 will reveal if skill IDs match (likely they don't)
-- - Steps 6-7 will show the CORRECT skill IDs to use
-- =============================================
