-- =============================================
-- NOC HYBRID APPROACH: STEP 1 - Import Crosswalk
-- =============================================
--
-- PURPOSE: Import NOC-to-O*NET crosswalk data from Brookfield Institute
-- SOURCE: noc2021_onet26.csv (1,466 mappings)
-- TABLES CREATED: NOC_ONET_CROSSWALK
--
-- PREREQUISITES:
-- 1. You have access to ONET_CAREER_DB database
-- 2. You have the noc2021_onet26.csv file
-- 3. You can create stages and tables
--
-- EXECUTION TIME: ~2 minutes
-- =============================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;
USE WAREHOUSE ONET_CAREER_AGENT_WH;

-- =============================================
-- SECTION 1: Create Stage for File Upload
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 1: Creating Stage for NOC Files' AS step;
SELECT '════════════════════════════════════════' AS step;

CREATE STAGE IF NOT EXISTS NOC_STAGE
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
        SKIP_HEADER = 1
        TRIM_SPACE = TRUE
        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    )
    COMMENT = 'Stage for NOC/OaSIS data files (Brookfield crosswalk + OaSIS CSVs)';

SELECT 'Stage NOC_STAGE created successfully' AS status;

-- =============================================
-- SECTION 2: Upload CSV File
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 2: Upload CSV File to Stage' AS step;
SELECT '════════════════════════════════════════' AS step;

-- MANUAL STEP: Upload the crosswalk CSV file
--
-- Option A: Using SnowSQL (command line)
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/Cross/noc2021_onet26.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
--
-- Option B: Using Snowsight Web UI
-- 1. Navigate to Data > Databases > ONET_CAREER_DB > CAREER_SCHEMA > Stages > NOC_STAGE
-- 2. Click "Upload Files"
-- 3. Select: /Users/eddym/Downloads/app/carrer/NOC/Cross/noc2021_onet26.csv
-- 4. Click "Upload"
--
-- WAIT FOR UPLOAD TO COMPLETE before proceeding!

-- Verify file uploaded successfully
LIST @NOC_STAGE;
-- Expected: You should see "noc2021_onet26.csv" in the results

-- =============================================
-- SECTION 3: Create Crosswalk Table
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 3: Creating NOC_ONET_CROSSWALK Table' AS step;
SELECT '════════════════════════════════════════' AS step;

CREATE TABLE IF NOT EXISTS NOC_ONET_CROSSWALK (
    -- Primary Key
    ID INT AUTOINCREMENT PRIMARY KEY,

    -- NOC (Canadian) Data
    NOC_CODE VARCHAR(10) NOT NULL,              -- e.g., "21231", "10010"
    NOC_TITLE VARCHAR(255),                     -- Canadian occupation title

    -- O*NET (U.S.) Data
    ONET_CODE VARCHAR(10) NOT NULL,             -- e.g., "15-1252.00"
    ONET_TITLE VARCHAR(255),                    -- U.S. occupation title

    -- Mapping Metadata
    MAPPING_SOURCE VARCHAR(50) DEFAULT 'BROOKFIELD_2021',
    MAPPING_CONFIDENCE VARCHAR(10) DEFAULT 'HIGH',  -- HIGH, MEDIUM, LOW

    -- Timestamps
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
COMMENT = 'NOC 2021 to O*NET v26 crosswalk from Brookfield Institute';

SELECT 'Table NOC_ONET_CROSSWALK created successfully' AS status;

-- =============================================
-- SECTION 4: Create Staging Table
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 4: Creating Temporary Staging Table' AS step;
SELECT '════════════════════════════════════════' AS step;

CREATE OR REPLACE TEMPORARY TABLE CROSSWALK_STAGING (
    noc VARCHAR(10),
    noc_title VARCHAR(255),
    onet VARCHAR(10),
    onet_title VARCHAR(255)
);

SELECT 'Staging table CROSSWALK_STAGING created successfully' AS status;

-- =============================================
-- SECTION 5: Load Data from CSV
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 5: Loading Data from CSV to Staging' AS step;
SELECT '════════════════════════════════════════' AS step;

COPY INTO CROSSWALK_STAGING
FROM @NOC_STAGE/noc2021_onet26.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = CONTINUE;

-- Check how many rows loaded
SELECT 'Rows loaded into staging:' AS status, COUNT(*) AS row_count
FROM CROSSWALK_STAGING;
-- Expected: 1,466 rows (or 1,467 if header was counted)

-- Preview first 10 rows
SELECT 'Preview of staging data:' AS status;
SELECT * FROM CROSSWALK_STAGING LIMIT 10;

-- =============================================
-- SECTION 6: Data Quality Checks (Pre-Load)
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 6: Data Quality Checks' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Check for NULL values
SELECT 'NULL value check:' AS check_name;
SELECT
    SUM(CASE WHEN noc IS NULL THEN 1 ELSE 0 END) AS null_noc_codes,
    SUM(CASE WHEN onet IS NULL THEN 1 ELSE 0 END) AS null_onet_codes,
    SUM(CASE WHEN noc_title IS NULL THEN 1 ELSE 0 END) AS null_noc_titles,
    SUM(CASE WHEN onet_title IS NULL THEN 1 ELSE 0 END) AS null_onet_titles
FROM CROSSWALK_STAGING;
-- Expected: All should be 0

-- Check for duplicate mappings
SELECT 'Duplicate check:' AS check_name;
SELECT noc, onet, COUNT(*) AS duplicate_count
FROM CROSSWALK_STAGING
GROUP BY noc, onet
HAVING COUNT(*) > 1;
-- Expected: No results (no duplicates)

-- Count unique codes
SELECT 'Unique code counts:' AS check_name;
SELECT
    COUNT(DISTINCT noc) AS unique_noc_codes,
    COUNT(DISTINCT onet) AS unique_onet_codes,
    COUNT(*) AS total_mappings
FROM CROSSWALK_STAGING;
-- Expected: ~515 NOC, ~952 O*NET, 1,466 total

-- Check key occupations exist
SELECT 'Key occupation check:' AS check_name;
SELECT * FROM CROSSWALK_STAGING
WHERE onet IN (
    '15-1252.00',  -- Software Developers
    '25-2031.00',  -- Secondary Teachers
    '11-3031.00',  -- Financial Managers
    '29-1141.00'   -- Registered Nurses
);
-- Expected: 4+ rows (some may have multiple NOC mappings)

-- =============================================
-- SECTION 7: Insert into Production Table
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 7: Inserting into Production Table' AS step;
SELECT '════════════════════════════════════════' AS step;

INSERT INTO NOC_ONET_CROSSWALK (
    NOC_CODE,
    NOC_TITLE,
    ONET_CODE,
    ONET_TITLE,
    MAPPING_SOURCE,
    MAPPING_CONFIDENCE
)
SELECT
    TRIM(noc) AS NOC_CODE,
    TRIM(noc_title) AS NOC_TITLE,
    TRIM(onet) AS ONET_CODE,
    TRIM(onet_title) AS ONET_TITLE,
    'BROOKFIELD_2021' AS MAPPING_SOURCE,
    CASE
        -- 1:1 mappings are high confidence
        WHEN (SELECT COUNT(*) FROM CROSSWALK_STAGING s2 WHERE s2.noc = s1.noc) = 1
        THEN 'HIGH'
        -- 1:2 or 1:3 mappings are medium confidence
        WHEN (SELECT COUNT(*) FROM CROSSWALK_STAGING s2 WHERE s2.noc = s1.noc) <= 3
        THEN 'MEDIUM'
        -- 1:4+ mappings are lower confidence
        ELSE 'LOW'
    END AS MAPPING_CONFIDENCE
FROM CROSSWALK_STAGING s1
WHERE TRIM(noc) IS NOT NULL AND TRIM(onet) IS NOT NULL;

-- Verify insert
SELECT 'Rows inserted into production table:' AS status, COUNT(*) AS row_count
FROM NOC_ONET_CROSSWALK;
-- Expected: 1,466 rows

-- =============================================
-- SECTION 8: Optimize Table for Performance
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 8: Optimizing Table for Performance' AS step;
SELECT '════════════════════════════════════════' AS step;

-- NOTE: Snowflake regular tables use micro-partitioning and don't need indexes
-- Indexes are only for hybrid tables. For regular tables, we can use clustering keys instead.
-- Since this is a small table (1,466 rows), no optimization is needed.
-- Queries will be fast due to Snowflake's automatic optimization.

SELECT 'Table optimization complete (using Snowflake micro-partitioning)' AS status;

-- =============================================
-- SECTION 9: Post-Load Validation
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 9: Post-Load Validation' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Overall statistics
SELECT 'Crosswalk Statistics:' AS metric_name;
SELECT
    COUNT(*) AS total_mappings,
    COUNT(DISTINCT NOC_CODE) AS unique_noc_codes,
    COUNT(DISTINCT ONET_CODE) AS unique_onet_codes,
    ROUND(COUNT(DISTINCT ONET_CODE) / 1016.0 * 100, 1) AS onet_coverage_pct,
    COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT NOC_CODE), 0) AS avg_onet_per_noc,
    COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT ONET_CODE), 0) AS avg_noc_per_onet
FROM NOC_ONET_CROSSWALK;
-- Expected: 1466 mappings, 515 NOC, 952 O*NET, 94% coverage

-- Confidence distribution
SELECT 'Mapping Confidence Distribution:' AS metric_name;
SELECT
    MAPPING_CONFIDENCE,
    COUNT(*) AS mapping_count,
    ROUND(COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER (), 0), 1) AS percentage
FROM NOC_ONET_CROSSWALK
GROUP BY MAPPING_CONFIDENCE
ORDER BY mapping_count DESC;

-- Top NOC codes with most O*NET mappings
SELECT 'NOC codes with most O*NET mappings:' AS metric_name;
SELECT
    NOC_CODE,
    NOC_TITLE,
    COUNT(*) AS onet_mapping_count
FROM NOC_ONET_CROSSWALK
GROUP BY NOC_CODE, NOC_TITLE
HAVING COUNT(*) >= 5
ORDER BY onet_mapping_count DESC
LIMIT 10;

-- Top O*NET codes with most NOC mappings
SELECT 'O*NET codes with most NOC mappings:' AS metric_name;
SELECT
    ONET_CODE,
    ONET_TITLE,
    COUNT(*) AS noc_mapping_count
FROM NOC_ONET_CROSSWALK
GROUP BY ONET_CODE, ONET_TITLE
HAVING COUNT(*) >= 3
ORDER BY noc_mapping_count DESC
LIMIT 10;

-- Test key occupation lookups
SELECT 'Test Key Occupation Lookups:' AS test_name;
SELECT
    ONET_CODE,
    ONET_TITLE,
    NOC_CODE,
    NOC_TITLE,
    MAPPING_CONFIDENCE
FROM NOC_ONET_CROSSWALK
WHERE ONET_CODE IN (
    '15-1252.00',  -- Software Developers
    '25-2031.00',  -- Secondary Teachers
    '11-3031.00',  -- Financial Managers
    '29-1141.00'   -- Registered Nurses
)
ORDER BY ONET_CODE;
-- Expected: All 4 O*NET codes found with NOC mappings

-- =============================================
-- SECTION 10: Test Lookup Query Performance
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 10: Performance Testing' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Test single lookup (what Swift will do)
SELECT 'Test single O*NET lookup:' AS test_name;
SELECT
    ONET_CODE,
    NOC_CODE,
    NOC_TITLE,
    MAPPING_CONFIDENCE
FROM NOC_ONET_CROSSWALK
WHERE ONET_CODE = '15-1252.00';
-- Expected: Instant return (< 10ms), shows NOC 21231

-- Test batch lookup (50 careers)
SELECT 'Test batch lookup (50 O*NET codes):' AS test_name;
SELECT COUNT(*) AS matched_count
FROM (
    SELECT ONET_SOC_CODE
    FROM CAREER_FULL_VECTORS
    LIMIT 50
) o
JOIN NOC_ONET_CROSSWALK c ON o.ONET_SOC_CODE = c.ONET_CODE;
-- Expected: Fast (< 100ms), 45-48 matches (~94% coverage)

-- =============================================
-- SECTION 11: Cleanup
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 11: Cleanup' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Drop staging table (it's temporary, will auto-drop on session end)
-- But we can explicitly drop it to free memory
DROP TABLE IF EXISTS CROSSWALK_STAGING;

SELECT 'Staging table cleaned up' AS status;

-- =============================================
-- FINAL STATUS
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT '✅ STEP 1 COMPLETE: Crosswalk Imported' AS step;
SELECT '════════════════════════════════════════' AS step;

SELECT
    '✅ Table created: NOC_ONET_CROSSWALK' AS status
UNION ALL
SELECT
    '✅ Rows imported: ' || COUNT(*) || ' mappings'
FROM NOC_ONET_CROSSWALK
UNION ALL
SELECT
    '✅ Unique NOC codes: ' || COUNT(DISTINCT NOC_CODE)
FROM NOC_ONET_CROSSWALK
UNION ALL
SELECT
    '✅ Unique O*NET codes: ' || COUNT(DISTINCT ONET_CODE)
FROM NOC_ONET_CROSSWALK
UNION ALL
SELECT
    '✅ Coverage: ' || ROUND(COUNT(DISTINCT ONET_CODE) / 1016.0 * 100, 1) || '%'
FROM NOC_ONET_CROSSWALK
UNION ALL
SELECT '✅ Performance: Optimized with Snowflake micro-partitioning'
UNION ALL
SELECT '✅ Ready for: STEP 2 (OaSIS Display Import)';

-- =============================================
-- NEXT STEP
-- =============================================
--
-- Run: NOC_STEP2_IMPORT_OASIS_DISPLAY.sql
--
-- This will import the OaSIS occupation display data
-- (titles, descriptions, employment requirements, etc.)
-- =============================================
