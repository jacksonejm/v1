USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Rebuild CAREER_FULL_VECTORS - FIXED VERSION
-- =============================================
-- Issue: ARRAY_AGG creates empty arrays when sf.ELEMENT_ID is NULL
-- Fix: Filter out NULL skills properly
-- =============================================

CREATE OR REPLACE TABLE CAREER_FULL_VECTORS AS
SELECT
    crv.ONET_SOC_CODE,
    crv.TITLE AS JOB_TITLE,
    crv.SHORT_DESCRIPTION AS DESCRIPTION,
    crv.R AS REALISTIC,
    crv.I AS INVESTIGATIVE,
    crv.A AS ARTISTIC,
    crv.S AS SOCIAL,
    crv.E AS ENTERPRISING,
    crv.C AS CONVENTIONAL,
    crv.ACHIEVEMENT_NORM AS ACHIEVEMENT,
    crv.INDEPENDENCE_NORM AS INDEPENDENCE,
    crv.RECOGNITION_NORM AS RECOGNITION,
    crv.RELATIONSHIPS_NORM AS RELATIONSHIPS,
    crv.SUPPORT_NORM AS SUPPORT,
    crv.WORKING_CONDITIONS_NORM AS WORKING_CONDITIONS,
    CASE
        WHEN MAX(sf.ELEMENT_ID) IS NULL THEN ARRAY_CONSTRUCT()  -- Empty array for no skills
        ELSE ARRAY_AGG(
            OBJECT_CONSTRUCT(
                'skill_id', sf.ELEMENT_ID,
                'skill_name', sf.ELEMENT_NAME,
                'importance', sf.DATA_VALUE
            )
        ) WITHIN GROUP (ORDER BY sf.DATA_VALUE DESC)
    END AS SKILLS_VECTOR
FROM CAREER_RIASEC_VALUES_VECTORS crv
LEFT JOIN SOC_SKILLS_MAPPING ssm ON crv.ONET_SOC_CODE = ssm.CAREER_SOC_CODE
LEFT JOIN (
    SELECT DISTINCT
        ONET_SOC_CODE,
        ELEMENT_ID,
        ELEMENT_NAME,
        DATA_VALUE,
        ROW_NUMBER() OVER (PARTITION BY ONET_SOC_CODE ORDER BY DATA_VALUE DESC) AS RN
    FROM SKILLS_FACT
    WHERE SCALE_ID = 'IM'
) sf ON COALESCE(ssm.SKILLS_SOC_CODE, crv.ONET_SOC_CODE) = sf.ONET_SOC_CODE
    AND sf.RN <= 10
GROUP BY
    crv.ONET_SOC_CODE,
    crv.TITLE,
    crv.SHORT_DESCRIPTION,
    crv.R, crv.I, crv.A, crv.S, crv.E, crv.C,
    crv.ACHIEVEMENT_NORM,
    crv.INDEPENDENCE_NORM,
    crv.RECOGNITION_NORM,
    crv.RELATIONSHIPS_NORM,
    crv.SUPPORT_NORM,
    crv.WORKING_CONDITIONS_NORM;

-- =============================================
-- Verification
-- =============================================

SELECT '=============================================' AS SEPARATOR;
SELECT 'Verification: Software Developers' AS TEST;
SELECT '=============================================' AS SEPARATOR;

SELECT 'Software Developers - Basic Info:' AS INFO;
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS,
    REALISTIC,
    INVESTIGATIVE
FROM CAREER_FULL_VECTORS
WHERE ONET_SOC_CODE = '15-1252.00';

SELECT 'Software Developers - Skills Breakdown:' AS INFO;
SELECT
    f.VALUE:skill_id::STRING AS SKILL_ID,
    f.VALUE:skill_name::STRING AS SKILL_NAME,
    f.VALUE:importance::FLOAT AS IMPORTANCE
FROM CAREER_FULL_VECTORS,
LATERAL FLATTEN(input => SKILLS_VECTOR) f
WHERE ONET_SOC_CODE = '15-1252.00'
ORDER BY f.VALUE:importance::FLOAT DESC;

SELECT '=============================================' AS SEPARATOR;
SELECT 'Overall Statistics' AS TEST;
SELECT '=============================================' AS SEPARATOR;

SELECT 'Total careers:' AS METRIC, COUNT(*) AS VALUE FROM CAREER_FULL_VECTORS
UNION ALL
SELECT 'Careers with 10 skills:', COUNT(*) FROM CAREER_FULL_VECTORS WHERE ARRAY_SIZE(SKILLS_VECTOR) = 10
UNION ALL
SELECT 'Careers with 0 skills:', COUNT(*) FROM CAREER_FULL_VECTORS WHERE ARRAY_SIZE(SKILLS_VECTOR) = 0;

SELECT 'Sample careers with skills:' AS INFO;
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS
FROM CAREER_FULL_VECTORS
WHERE ARRAY_SIZE(SKILLS_VECTOR) > 0
ORDER BY RANDOM()
LIMIT 10;

-- =============================================
-- Expected Results:
-- - Software Developers: 10 skills including Programming (2.B.3.e)
-- - Most careers: 10 skills
-- - Some careers: 0 skills (need more SOC mappings)
-- =============================================
