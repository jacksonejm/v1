-- =============================================
-- Recipe D Step 1: Import O*NET Skills Data
-- =============================================
-- This script imports Skills.txt from O*NET database
-- Skills represent job requirements for specific abilities
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- Create SKILLS_FACT table
-- =============================================

CREATE OR REPLACE TABLE SKILLS_FACT (
    ONET_SOC_CODE VARCHAR(10),
    ELEMENT_ID VARCHAR(20),
    ELEMENT_NAME VARCHAR(100),
    SCALE_ID VARCHAR(10),
    DATA_VALUE FLOAT,
    N INTEGER,
    STANDARD_ERROR FLOAT,
    LOWER_CI_BOUND FLOAT,
    UPPER_CI_BOUND FLOAT,
    RECOMMEND_SUPPRESS VARCHAR(1),
    NOT_RELEVANT VARCHAR(1),
    DATE VARCHAR(20),
    DOMAIN_SOURCE VARCHAR(50)
);

-- =============================================
-- Import Skills data from O*NET stage
-- =============================================
-- File: Skills.txt (5.3MB)
-- Expected rows: ~30,000

COPY INTO SKILLS_FACT
FROM '@ONET_DATA_STAGE/Skills.txt'
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_DELIMITER = '\t'
    SKIP_HEADER = 1
    TRIM_SPACE = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL')
)
ON_ERROR = 'CONTINUE';

-- =============================================
-- Verify data import
-- =============================================

-- Check row count
SELECT 'Total Skills Records' AS METRIC, COUNT(*) AS VALUE
FROM SKILLS_FACT;

-- Check scale types (we'll use IM = Importance and LV = Level)
SELECT SCALE_ID, COUNT(*) AS COUNT
FROM SKILLS_FACT
GROUP BY SCALE_ID
ORDER BY SCALE_ID;

-- Sample skills data
SELECT *
FROM SKILLS_FACT
LIMIT 10;

-- Check which skills are most common across all jobs
SELECT
    ELEMENT_ID,
    ELEMENT_NAME,
    COUNT(DISTINCT ONET_SOC_CODE) AS NUM_OCCUPATIONS,
    ROUND(AVG(CASE WHEN SCALE_ID = 'IM' THEN DATA_VALUE END), 2) AS AVG_IMPORTANCE,
    ROUND(AVG(CASE WHEN SCALE_ID = 'LV' THEN DATA_VALUE END), 2) AS AVG_LEVEL
FROM SKILLS_FACT
WHERE RECOMMEND_SUPPRESS != 'Y'
GROUP BY ELEMENT_ID, ELEMENT_NAME
HAVING COUNT(DISTINCT ONET_SOC_CODE) > 100
ORDER BY AVG_IMPORTANCE DESC
LIMIT 20;

-- =============================================
-- Example: Software Developer skills
-- =============================================

SELECT
    ONET_SOC_CODE,
    ELEMENT_NAME AS SKILL,
    SCALE_ID,
    DATA_VALUE
FROM SKILLS_FACT
WHERE ONET_SOC_CODE = '15-1252.00'  -- Software Developers
  AND SCALE_ID = 'IM'  -- Importance scale
ORDER BY DATA_VALUE DESC
LIMIT 10;

-- =============================================
-- Validation: Ensure we have skills for most occupations
-- =============================================

SELECT
    'Occupations with Skills Data' AS METRIC,
    COUNT(DISTINCT ONET_SOC_CODE) AS VALUE
FROM SKILLS_FACT;

-- Compare to total occupations
SELECT
    'Total Occupations in Database' AS METRIC,
    COUNT(*) AS VALUE
FROM OCCUPATION_DATA;

-- =============================================
-- SUCCESS CRITERIA
-- =============================================
-- ✅ SKILLS_FACT table created
-- ✅ ~30,000 rows imported from Skills.txt
-- ✅ Skills data available for 800+ occupations
-- ✅ Importance (IM) and Level (LV) scales present
-- ✅ Sample queries return expected results
-- =============================================
