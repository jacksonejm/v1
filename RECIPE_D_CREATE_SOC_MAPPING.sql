USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Create SOC Code Mapping for Skills Data
-- =============================================
-- Some careers in CAREER_RIASEC_VALUES_VECTORS don't exist in SKILLS_FACT
-- We map them to similar occupations that DO have skills data
-- =============================================

CREATE OR REPLACE TABLE SOC_SKILLS_MAPPING (
    CAREER_SOC_CODE VARCHAR(20),  -- The SOC code in CAREER_RIASEC_VALUES_VECTORS
    SKILLS_SOC_CODE VARCHAR(20),  -- The SOC code to use for skills from SKILLS_FACT
    REASON VARCHAR(500)
);

-- Software Developers → Computer Programmers
INSERT INTO SOC_SKILLS_MAPPING VALUES
('15-1252.00', '15-1251.00', 'Software Developers uses Computer Programmers skills (very similar roles)');

-- Add more mappings as we discover them
-- (We'll find more careers without skills data after rebuild)

SELECT 'SOC_SKILLS_MAPPING created with ' || COUNT(*) || ' mappings' AS STATUS
FROM SOC_SKILLS_MAPPING;

-- =============================================
-- Rebuild CAREER_FULL_VECTORS with SOC Mapping
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
    ARRAY_AGG(
        OBJECT_CONSTRUCT(
            'skill_id', sf.ELEMENT_ID,
            'skill_name', sf.ELEMENT_NAME,
            'importance', sf.DATA_VALUE
        )
    ) WITHIN GROUP (ORDER BY sf.DATA_VALUE DESC) AS SKILLS_VECTOR
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
    WHERE SCALE_ID = 'IM'  -- Use Importance scale
) sf ON COALESCE(ssm.SKILLS_SOC_CODE, crv.ONET_SOC_CODE) = sf.ONET_SOC_CODE
    AND sf.RN <= 10  -- Top 10 skills
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
SELECT 'CAREER_FULL_VECTORS Rebuild Complete' AS STATUS;
SELECT '=============================================' AS SEPARATOR;

-- Check Software Developers now has skills
SELECT 'Software Developers after mapping:' AS INFO;
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS
FROM CAREER_FULL_VECTORS
WHERE ONET_SOC_CODE = '15-1252.00';

-- Parse the skills
SELECT 'Software Developers skills:' AS INFO;
SELECT
    f.VALUE:skill_id::STRING AS SKILL_ID,
    f.VALUE:skill_name::STRING AS SKILL_NAME,
    f.VALUE:importance::FLOAT AS IMPORTANCE
FROM CAREER_FULL_VECTORS,
LATERAL FLATTEN(input => SKILLS_VECTOR) f
WHERE ONET_SOC_CODE = '15-1252.00'
ORDER BY f.VALUE:importance::FLOAT DESC;

-- Check skill distribution
SELECT 'Skill distribution after rebuild:' AS INFO;
SELECT
    CASE
        WHEN ARRAY_SIZE(SKILLS_VECTOR) = 0 THEN '0 skills (NO DATA)'
        WHEN ARRAY_SIZE(SKILLS_VECTOR) < 10 THEN '1-9 skills'
        WHEN ARRAY_SIZE(SKILLS_VECTOR) = 10 THEN '10 skills (GOOD)'
        ELSE '10+ skills'
    END AS SKILL_RANGE,
    COUNT(*) AS NUM_CAREERS
FROM CAREER_FULL_VECTORS
GROUP BY SKILL_RANGE
ORDER BY SKILL_RANGE;

-- Find other careers that still have 0 skills (need mapping)
SELECT 'Careers still without skills (need SOC mapping):' AS INFO;
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS
FROM CAREER_FULL_VECTORS
WHERE ARRAY_SIZE(SKILLS_VECTOR) = 0
LIMIT 20;

-- =============================================
-- Expected Result:
-- - Software Developers should now have 10 skills
-- - Skills should include 2.B.3.e (Programming)
-- - Most careers should have 10 skills
-- - Some careers may still have 0 (need more mappings)
-- =============================================
