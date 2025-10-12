USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Debug: Why is Skills Match 0%?
-- =============================================

-- Check 1: Does SUBJECT_SKILLS_MAPPING have "Math"?
SELECT * FROM SUBJECT_SKILLS_MAPPING WHERE SUBJECT_NAME = 'Math';

-- Check 2: Does SUBJECT_SKILLS_MAPPING have "Computer Science"?
SELECT * FROM SUBJECT_SKILLS_MAPPING WHERE SUBJECT_NAME = 'Computer Science';

-- Check 3: Does ACTIVITY_SKILLS_MAPPING have "Coding/Programming"?
SELECT * FROM ACTIVITY_SKILLS_MAPPING WHERE ACTIVITY_NAME = 'Coding/Programming';

-- Check 4: What skills does Software Developer have?
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    SKILLS_VECTOR
FROM CAREER_FULL_VECTORS
WHERE JOB_TITLE LIKE '%Software Developer%'
LIMIT 1;

-- Check 5: Parse the skills vector to see actual skill IDs
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    VALUE:skill_id::STRING AS SKILL_ID,
    VALUE:skill_name::STRING AS SKILL_NAME,
    VALUE:importance::FLOAT AS IMPORTANCE
FROM CAREER_FULL_VECTORS,
LATERAL FLATTEN(input => PARSE_JSON(SKILLS_VECTOR))
WHERE JOB_TITLE LIKE '%Software Developer%'
LIMIT 10;

-- =============================================
-- This will show us:
-- 1. If mapping tables have data
-- 2. If skills vector has data
-- 3. If skill IDs match between mappings and vectors
-- =============================================
