-- ================================================================
-- WORK VALUES DATA AUDIT
-- ================================================================
-- Purpose: Verify O*NET Work Values data availability for Recipe C
-- Date: 2025-10-05

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- ================================================================
-- STEP 1: CHECK IF WORK VALUES TABLE EXISTS
-- ================================================================

-- List all tables in schema
SHOW TABLES IN ONET_CAREER_DB.CAREER_SCHEMA;

-- Check for Work Values related tables
-- Possible names: WORK_VALUES, WORK_STYLES, VALUES_FACT, etc.

-- ================================================================
-- STEP 2: EXPLORE WORK VALUES TABLE STRUCTURE
-- ================================================================

-- If table exists, check its structure (try different possible names)

-- Option A: WORK_VALUES table
SELECT TOP 10 * FROM WORK_VALUES;

-- Option B: WORK_STYLES table
-- SELECT TOP 10 * FROM WORK_STYLES;

-- Option C: Check INTERESTS_FACT for similar pattern
-- SELECT DISTINCT SCALE_NAME FROM INTERESTS_FACT;

-- ================================================================
-- STEP 3: CHECK WORK VALUES ELEMENTS
-- ================================================================

-- O*NET Work Values have 6 dimensions with specific Element IDs:
-- 1.B.2.a = Achievement
-- 1.B.2.b = Working Conditions
-- 1.B.2.c = Recognition
-- 1.B.2.d = Relationships
-- 1.B.2.e = Support
-- 1.B.2.f = Independence

SELECT
    ELEMENT_ID,
    ELEMENT_NAME,
    COUNT(DISTINCT ONET_SOC_CODE) as num_occupations,
    AVG(DATA_VALUE) as avg_value,
    MIN(DATA_VALUE) as min_value,
    MAX(DATA_VALUE) as max_value
FROM WORK_VALUES
WHERE ELEMENT_ID IN (
    '1.B.2.a',  -- Achievement
    '1.B.2.b',  -- Working Conditions
    '1.B.2.c',  -- Recognition
    '1.B.2.d',  -- Relationships
    '1.B.2.e',  -- Support
    '1.B.2.f'   -- Independence
)
GROUP BY ELEMENT_ID, ELEMENT_NAME
ORDER BY ELEMENT_ID;

-- ================================================================
-- STEP 4: CHECK COVERAGE
-- ================================================================

-- Count occupations with complete Work Values profiles (all 6 dimensions)
SELECT COUNT(*) as occupations_with_all_6_values
FROM (
    SELECT ONET_SOC_CODE
    FROM WORK_VALUES
    WHERE ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f')
    GROUP BY ONET_SOC_CODE
    HAVING COUNT(DISTINCT ELEMENT_ID) = 6
);

-- ================================================================
-- STEP 5: SAMPLE DATA QUALITY CHECK
-- ================================================================

-- Get sample of occupations with their Work Values scores
SELECT TOP 10
    o.ONET_SOC_CODE,
    o.TITLE,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.a' THEN w.DATA_VALUE END) as Achievement,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.b' THEN w.DATA_VALUE END) as Working_Conditions,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.c' THEN w.DATA_VALUE END) as Recognition,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.d' THEN w.DATA_VALUE END) as Relationships,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.e' THEN w.DATA_VALUE END) as Support,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.f' THEN w.DATA_VALUE END) as Independence
FROM WORK_VALUES w
JOIN OCCUPATION_DIM o ON w.ONET_SOC_CODE = o.ONET_SOC_CODE
GROUP BY o.ONET_SOC_CODE, o.TITLE
ORDER BY o.TITLE;

-- ================================================================
-- STEP 6: CHECK SCALE RANGE
-- ================================================================

-- O*NET Work Values should be on 0-7 scale like interests
SELECT
    'Work Values Scale Range' as check_type,
    MIN(DATA_VALUE) as min_scale,
    MAX(DATA_VALUE) as max_scale,
    AVG(DATA_VALUE) as avg_scale
FROM WORK_VALUES
WHERE ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f');

-- ================================================================
-- TROUBLESHOOTING QUERIES
-- ================================================================

-- If above queries fail, try these alternatives:

-- Check if data is in a different table structure
-- SELECT TOP 5 * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'CAREER_SCHEMA';

-- Check for any table with "VALUE" or "STYLE" in name
-- SHOW TABLES LIKE '%VALUE%';
-- SHOW TABLES LIKE '%STYLE%';

-- ================================================================
-- GO/NO-GO CRITERIA
-- ================================================================

/*
Recipe C is FEASIBLE if:
✅ Work Values table exists
✅ All 6 dimensions present (1.B.2.a through 1.B.2.f)
✅ Coverage >= 80% of occupations
✅ Data on 0-7 scale
✅ No major nulls or data quality issues

Recipe C is NOT FEASIBLE if:
❌ No Work Values table found
❌ Missing 2+ dimensions
❌ Coverage < 50%
❌ Scale doesn't match expectations
*/
