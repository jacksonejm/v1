USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Check how many careers are missing work values
-- =============================================

SELECT
    COUNT(*) AS TOTAL_CAREERS,
    SUM(CASE WHEN ACHIEVEMENT_NORM = 0 AND INDEPENDENCE_NORM = 0 AND RECOGNITION_NORM = 0 THEN 1 ELSE 0 END) AS MISSING_ALL_VALUES,
    SUM(CASE WHEN ACHIEVEMENT_NORM > 0 THEN 1 ELSE 0 END) AS HAS_ACHIEVEMENT,
    ROUND(100.0 * SUM(CASE WHEN ACHIEVEMENT_NORM > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS PCT_WITH_VALUES
FROM CAREER_RIASEC_VALUES_VECTORS;

-- Show some examples of careers WITH work values
SELECT
    ONET_SOC_CODE,
    TITLE,
    ACHIEVEMENT_NORM,
    INDEPENDENCE_NORM,
    RECOGNITION_NORM
FROM CAREER_RIASEC_VALUES_VECTORS
WHERE ACHIEVEMENT_NORM > 0
LIMIT 10;

-- Show some examples of careers WITHOUT work values
SELECT
    ONET_SOC_CODE,
    TITLE,
    ACHIEVEMENT_NORM,
    INDEPENDENCE_NORM,
    RECOGNITION_NORM
FROM CAREER_RIASEC_VALUES_VECTORS
WHERE ACHIEVEMENT_NORM = 0
  AND INDEPENDENCE_NORM = 0
  AND RECOGNITION_NORM = 0
LIMIT 10;

-- =============================================
-- This will tell us:
-- 1. What % of careers have work values data
-- 2. If we need to use fallback/default values for missing data
-- =============================================
