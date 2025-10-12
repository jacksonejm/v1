-- ================================================================
-- IMPORT WORK VALUES DATA INTO SNOWFLAKE
-- ================================================================
-- Purpose: Create WORK_VALUES table from O*NET text file
-- Date: 2025-10-05
-- File: /Users/eddym/Downloads/db_28_2_text/Work Values.txt
--
-- ================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- ================================================================
-- STEP 1: CREATE WORK_VALUES TABLE
-- ================================================================

CREATE OR REPLACE TABLE WORK_VALUES (
    ONET_SOC_CODE VARCHAR(10),
    ELEMENT_ID VARCHAR(10),
    ELEMENT_NAME VARCHAR(100),
    SCALE_ID VARCHAR(10),
    DATA_VALUE FLOAT,
    DATE VARCHAR(20),
    DOMAIN_SOURCE VARCHAR(50)
);

-- ================================================================
-- STEP 2: CREATE STAGE FOR FILE UPLOAD
-- ================================================================

-- Create a named internal stage
CREATE OR REPLACE STAGE ONET_STAGE
    FILE_FORMAT = (
        TYPE = 'CSV'
        FIELD_DELIMITER = '\t'
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        TRIM_SPACE = TRUE
    );

-- ================================================================
-- STEP 3: UPLOAD FILE TO STAGE (DO THIS MANUALLY IN SNOWFLAKE UI)
-- ================================================================

/*
MANUAL STEPS IN SNOWFLAKE UI:

1. Go to: Databases → ONET_CAREER_DB → CAREER_SCHEMA → Stages → ONET_STAGE
2. Click "Upload Files" button
3. Select file: /Users/eddym/Downloads/db_28_2_text/Work Values.txt
4. Wait for upload to complete
5. Come back here and run STEP 4

OR use SnowSQL command line:
PUT file:///Users/eddym/Downloads/db_28_2_text/Work\ Values.txt @ONET_STAGE;
*/

-- ================================================================
-- STEP 4: LOAD DATA FROM STAGE INTO TABLE
-- ================================================================

COPY INTO WORK_VALUES
FROM @ONET_STAGE/Work_Values.txt
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_DELIMITER = '\t'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
)
ON_ERROR = 'CONTINUE';

-- ================================================================
-- STEP 5: VERIFY DATA LOADED
-- ================================================================

-- Check row count
SELECT COUNT(*) as total_rows FROM WORK_VALUES;

-- Check element coverage
SELECT
    ELEMENT_ID,
    ELEMENT_NAME,
    COUNT(DISTINCT ONET_SOC_CODE) as num_occupations,
    AVG(DATA_VALUE) as avg_value,
    MIN(DATA_VALUE) as min_value,
    MAX(DATA_VALUE) as max_value
FROM WORK_VALUES
WHERE ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f')
GROUP BY ELEMENT_ID, ELEMENT_NAME
ORDER BY ELEMENT_ID;

-- Check occupations with complete profiles
SELECT COUNT(*) as occupations_with_all_6_values
FROM (
    SELECT ONET_SOC_CODE
    FROM WORK_VALUES
    WHERE ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f')
    GROUP BY ONET_SOC_CODE
    HAVING COUNT(DISTINCT ELEMENT_ID) = 6
);

-- Sample data
SELECT TOP 10
    ONET_SOC_CODE,
    ELEMENT_ID,
    ELEMENT_NAME,
    DATA_VALUE
FROM WORK_VALUES
WHERE ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f')
ORDER BY ONET_SOC_CODE, ELEMENT_ID;

-- ================================================================
-- STEP 6: VERIFY INTEGRATION WITH EXISTING TABLES
-- ================================================================

-- Join with OCCUPATION_DIM to verify compatibility
SELECT
    o.ONET_SOC_CODE,
    o.TITLE,
    COUNT(DISTINCT w.ELEMENT_ID) as num_work_values
FROM OCCUPATION_DIM o
LEFT JOIN WORK_VALUES w ON o.ONET_SOC_CODE = w.ONET_SOC_CODE
    AND w.ELEMENT_ID IN ('1.B.2.a', '1.B.2.b', '1.B.2.c', '1.B.2.d', '1.B.2.e', '1.B.2.f')
GROUP BY o.ONET_SOC_CODE, o.TITLE
ORDER BY num_work_values DESC, o.TITLE
LIMIT 20;

-- ================================================================
-- SUCCESS CRITERIA
-- ================================================================

/*
✅ IMPORT SUCCESSFUL IF:
- Total rows: 6,000-10,000 (depends on O*NET version)
- 6 elements (1.B.2.a through 1.B.2.f) present
- 800-1,000 occupations with complete profiles
- Values on 0-7 scale
- No major nulls or errors

❌ TROUBLESHOOT IF:
- Row count = 0: File not uploaded or wrong path
- Element count < 6: File corrupted or wrong format
- Many nulls: Delimiter or format issues
*/

-- ================================================================
-- NEXT STEPS AFTER SUCCESSFUL IMPORT
-- ================================================================

/*
After verifying data is loaded successfully:

1. ✅ Run SCORING_V3_RECIPE_C.sql to create:
   - CAREER_RIASEC_VALUES_VECTORS table
   - SP_GET_CAREER_MATCHES_V3 procedure

2. ✅ Update SnowflakeService.swift to:
   - Extract work values from userData
   - Call SP_GET_CAREER_MATCHES_V3 with 12 parameters

3. ✅ Test end-to-end in app

4. ✅ A/B test v2.0 vs v3.0
*/
