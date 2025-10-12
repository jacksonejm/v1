USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Debug: Check Work Values in CAREER_FULL_VECTORS
-- =============================================

-- Check a sample career (Software Developer)
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    ACHIEVEMENT,
    INDEPENDENCE,
    RECOGNITION,
    RELATIONSHIPS,
    SUPPORT,
    WORKING_CONDITIONS,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS
FROM CAREER_FULL_VECTORS
WHERE JOB_TITLE LIKE '%Software%'
LIMIT 3;

-- Check if ANY career has work values > 0
SELECT
    COUNT(*) AS TOTAL_CAREERS,
    SUM(CASE WHEN ACHIEVEMENT > 0 THEN 1 ELSE 0 END) AS HAS_ACHIEVEMENT,
    SUM(CASE WHEN INDEPENDENCE > 0 THEN 1 ELSE 0 END) AS HAS_INDEPENDENCE,
    SUM(CASE WHEN SKILLS_VECTOR IS NOT NULL THEN 1 ELSE 0 END) AS HAS_SKILLS
FROM CAREER_FULL_VECTORS;

-- Check what the source table CAREER_RIASEC_VALUES_VECTORS has
SELECT
    ONET_SOC_CODE,
    TITLE,
    ACHIEVEMENT_NORM,
    INDEPENDENCE_NORM,
    RECOGNITION_NORM,
    RELATIONSHIPS_NORM,
    SUPPORT_NORM,
    WORKING_CONDITIONS_NORM
FROM CAREER_RIASEC_VALUES_VECTORS
WHERE TITLE LIKE '%Software%'
LIMIT 3;

-- =============================================
-- The issue is likely that CAREER_FULL_VECTORS was created
-- but the work values columns are all 0 or NULL
-- =============================================
