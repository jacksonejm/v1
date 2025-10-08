-- ================================================================
-- FIND WORK VALUES DATA IN SNOWFLAKE
-- ================================================================
-- Purpose: Locate Work Values data in your O*NET database
-- The table name might be different than expected

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- ================================================================
-- STEP 1: LIST ALL TABLES IN SCHEMA
-- ================================================================

SHOW TABLES IN ONET_CAREER_DB.CAREER_SCHEMA;

-- ================================================================
-- STEP 2: SEARCH FOR TABLES WITH "VALUE" OR "STYLE" IN NAME
-- ================================================================

-- Look for any table with "VALUE" in the name
SHOW TABLES LIKE '%VALUE%' IN ONET_CAREER_DB.CAREER_SCHEMA;

-- Look for any table with "STYLE" in the name
SHOW TABLES LIKE '%STYLE%' IN ONET_CAREER_DB.CAREER_SCHEMA;

-- Look for any table with "WORK" in the name
SHOW TABLES LIKE '%WORK%' IN ONET_CAREER_DB.CAREER_SCHEMA;

-- ================================================================
-- STEP 3: CHECK WHAT TABLES YOU CURRENTLY HAVE
-- ================================================================

-- List the tables you're currently using successfully
SELECT 'INTERESTS_FACT' as table_name, COUNT(*) as row_count FROM INTERESTS_FACT
UNION ALL
SELECT 'OCCUPATION_DIM', COUNT(*) FROM OCCUPATION_DIM;

-- ================================================================
-- STEP 4: CHECK IF WORK VALUES DATA IS IN INTERESTS_FACT
-- ================================================================

-- Sometimes Work Values are stored with Interests
-- Check all unique ELEMENT_IDs in INTERESTS_FACT
SELECT DISTINCT ELEMENT_ID, ELEMENT_NAME
FROM INTERESTS_FACT
ORDER BY ELEMENT_ID
LIMIT 50;

-- ================================================================
-- STEP 5: CHECK FOR WORK_CONTEXT TABLE (IF IT EXISTS)
-- ================================================================

-- Work Context might contain some work environment preferences
-- Uncomment if table exists:
-- SELECT COUNT(*) as work_context_count FROM WORK_CONTEXT;
-- SELECT TOP 10 * FROM WORK_CONTEXT;

-- ================================================================
-- STEP 6: CHECK FOR WORK_STYLES TABLE (IF IT EXISTS)
-- ================================================================

-- Work Styles is similar to Work Values
-- Uncomment if table exists:
-- SELECT COUNT(*) as work_styles_count FROM WORK_STYLES;
-- SELECT TOP 10 * FROM WORK_STYLES;
-- SELECT DISTINCT ELEMENT_ID, ELEMENT_NAME FROM WORK_STYLES ORDER BY ELEMENT_ID;

-- ================================================================
-- ANALYSIS & RECOMMENDATIONS
-- ================================================================

/*
Based on the results above, we'll determine:

OPTION A: Work Values exist in a different table name
→ Update SCORING_V3_RECIPE_C.sql to use correct table name

OPTION B: Work Values don't exist, but Work Styles do
→ Use Work Styles instead (similar concept)

OPTION C: Neither Work Values nor Work Styles exist
→ Fall back to Recipe A (v2.0) + Option 1 (post-filtering)
   OR collect Work Values from users without O*NET data (user-only values)

OPTION D: Work Values data is embedded in another table
→ Extract and create our own Work Values mapping
*/
