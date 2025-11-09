-- =============================================
-- NOC HYBRID APPROACH: STEP 2 - Import OaSIS Display Data
-- =============================================
--
-- PURPOSE: Import Canadian occupation display data from OaSIS
-- SOURCE: 10 CSV files from open.canada.ca
-- TABLES CREATED: NOC_OCCUPATIONS
--
-- PREREQUISITES:
-- 1. Completed STEP 1 (NOC_ONET_CROSSWALK table exists)
-- 2. Downloaded OaSIS CSV files to /Users/eddym/Downloads/app/carrer/NOC/
-- 3. NOC_STAGE exists from Step 1
--
-- EXECUTION TIME: ~5 minutes
-- =============================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;
USE WAREHOUSE ONET_CAREER_AGENT_WH;

-- =============================================
-- SECTION 1: Upload OaSIS CSV Files
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 1: Upload OaSIS CSV Files to Stage' AS step;
SELECT '════════════════════════════════════════' AS step;

-- MANUAL STEP: Upload the 10 essential OaSIS CSV files
--
-- Option A: Using SnowSQL (command line) - Run all commands:
--
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/0131ca04-0379-4c1f-b814-05fb139b9718.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/7941081c-a0ce-4add-aa2c-74aa96b1c57f.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/8cc1bd89-afa1-4cfe-b45a-d6511d9318d7.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/381efe24-1b50-4a18-b6bb-cb7d0fa0921f.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/053f7e1c-e629-432e-a70f-ed043e028f65.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/e080bd8a-a760-488d-81f8-e6e6f50c6396.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/66414d34-029e-4d0e-b6e5-ae3d99a73fac.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/e3599639-3540-4d39-a42b-f7d41909d6d4.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/79361933-2793-4e1e-b255-b6fa214ef28d.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
-- PUT file:///Users/eddym/Downloads/app/carrer/NOC/0553ee55-1a87-4709-bd61-3739af0322a3.csv @NOC_STAGE AUTO_COMPRESS=FALSE;
--
-- Option B: Using Snowsight Web UI
-- 1. Navigate to Data > Databases > ONET_CAREER_DB > CAREER_SCHEMA > Stages > NOC_STAGE
-- 2. Click "Upload Files"
-- 3. Select all 10 files listed above
-- 4. Click "Upload"
--
-- FILE DESCRIPTIONS:
-- 0131ca04-*.csv = Interests (EN) - Holland Codes
-- 7941081c-*.csv = Interests (FR) - Holland Codes
-- 8cc1bd89-*.csv = Lead Statement (EN) - Descriptions
-- 381efe24-*.csv = Lead Statement (FR) - Descriptions
-- 053f7e1c-*.csv = Employment Requirements (EN)
-- e080bd8a-*.csv = Employment Requirements (FR)
-- 66414d34-*.csv = Example Titles (EN)
-- e3599639-*.csv = Example Titles (FR)
-- 79361933-*.csv = Main Duties (EN)
-- 0553ee55-*.csv = Main Duties (FR)
--
-- WAIT FOR ALL UPLOADS TO COMPLETE before proceeding!

-- Verify files uploaded successfully
LIST @NOC_STAGE;
-- Expected: You should see 11 files total (1 crosswalk + 10 OaSIS files)

-- =============================================
-- SECTION 2: Create Staging Tables
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 2: Creating Staging Tables' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Staging table for Interests (Holland Codes)
CREATE OR REPLACE TEMPORARY TABLE INTERESTS_STAGING_EN (
    noc_code VARCHAR(10),
    noc_label VARCHAR(255),
    holland_code_1 VARCHAR(1),
    holland_code_2 VARCHAR(1),
    holland_code_3 VARCHAR(1)
);

CREATE OR REPLACE TEMPORARY TABLE INTERESTS_STAGING_FR (
    noc_code VARCHAR(10),
    noc_label VARCHAR(255),
    holland_code_1 VARCHAR(1),
    holland_code_2 VARCHAR(1),
    holland_code_3 VARCHAR(1)
);

-- Staging table for Lead Statements (Descriptions)
CREATE OR REPLACE TEMPORARY TABLE LEADSTATEMENT_STAGING_EN (
    noc_code VARCHAR(10),
    lead_statement VARCHAR(5000)
);

CREATE OR REPLACE TEMPORARY TABLE LEADSTATEMENT_STAGING_FR (
    noc_code VARCHAR(10),
    lead_statement VARCHAR(5000)
);

-- Staging table for Employment Requirements
CREATE OR REPLACE TEMPORARY TABLE EMPLOYMENT_REQ_STAGING_EN (
    noc_code VARCHAR(10),
    employment_requirement VARCHAR(1000)
);

CREATE OR REPLACE TEMPORARY TABLE EMPLOYMENT_REQ_STAGING_FR (
    noc_code VARCHAR(10),
    employment_requirement VARCHAR(1000)
);

-- Staging table for Example Titles
CREATE OR REPLACE TEMPORARY TABLE EXAMPLE_TITLES_STAGING_EN (
    noc_code VARCHAR(10),
    example_title VARCHAR(500)
);

CREATE OR REPLACE TEMPORARY TABLE EXAMPLE_TITLES_STAGING_FR (
    noc_code VARCHAR(10),
    example_title VARCHAR(500)
);

-- Staging table for Main Duties
CREATE OR REPLACE TEMPORARY TABLE MAIN_DUTIES_STAGING_EN (
    noc_code VARCHAR(10),
    main_duty VARCHAR(2000)
);

CREATE OR REPLACE TEMPORARY TABLE MAIN_DUTIES_STAGING_FR (
    noc_code VARCHAR(10),
    main_duty VARCHAR(2000)
);

SELECT 'All staging tables created successfully' AS status;

-- =============================================
-- SECTION 3: Load Interests (Holland Codes)
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 3: Loading Interests (Holland Codes)' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Load English Interests
COPY INTO INTERESTS_STAGING_EN
FROM @NOC_STAGE/0131ca04-0379-4c1f-b814-05fb139b9718.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Load French Interests
COPY INTO INTERESTS_STAGING_FR
FROM @NOC_STAGE/7941081c-a0ce-4add-aa2c-74aa96b1c57f.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Verify load
SELECT 'Interests loaded:' AS status;
SELECT 'English:' AS language, COUNT(*) AS row_count FROM INTERESTS_STAGING_EN
UNION ALL
SELECT 'French:' AS language, COUNT(*) AS row_count FROM INTERESTS_STAGING_FR;
-- Expected: 900 rows each

-- Preview
SELECT 'Sample English Interests:' AS preview;
SELECT * FROM INTERESTS_STAGING_EN LIMIT 5;

-- =============================================
-- SECTION 4: Load Lead Statements (Descriptions)
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 4: Loading Lead Statements' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Load English Lead Statements
COPY INTO LEADSTATEMENT_STAGING_EN
FROM @NOC_STAGE/8cc1bd89-afa1-4cfe-b45a-d6511d9318d7.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Load French Lead Statements
COPY INTO LEADSTATEMENT_STAGING_FR
FROM @NOC_STAGE/381efe24-1b50-4a18-b6bb-cb7d0fa0921f.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Verify load
SELECT 'Lead Statements loaded:' AS status;
SELECT 'English:' AS language, COUNT(*) AS row_count FROM LEADSTATEMENT_STAGING_EN
UNION ALL
SELECT 'French:' AS language, COUNT(*) AS row_count FROM LEADSTATEMENT_STAGING_FR;
-- Expected: 900 rows each

-- Preview
SELECT 'Sample English Lead Statements:' AS preview;
SELECT noc_code, LEFT(lead_statement, 100) || '...' AS description_preview
FROM LEADSTATEMENT_STAGING_EN
LIMIT 5;

-- =============================================
-- SECTION 5: Load Employment Requirements
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 5: Loading Employment Requirements' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Load English Employment Requirements
COPY INTO EMPLOYMENT_REQ_STAGING_EN
FROM @NOC_STAGE/053f7e1c-e629-432e-a70f-ed043e028f65.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Load French Employment Requirements
COPY INTO EMPLOYMENT_REQ_STAGING_FR
FROM @NOC_STAGE/e080bd8a-a760-488d-81f8-e6e6f50c6396.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Verify load
SELECT 'Employment Requirements loaded:' AS status;
SELECT 'English:' AS language, COUNT(*) AS row_count FROM EMPLOYMENT_REQ_STAGING_EN
UNION ALL
SELECT 'French:' AS language, COUNT(*) AS row_count FROM EMPLOYMENT_REQ_STAGING_FR;
-- Expected: ~2,800 rows each (multiple requirements per occupation)

-- Preview
SELECT 'Sample Employment Requirements:' AS preview;
SELECT * FROM EMPLOYMENT_REQ_STAGING_EN LIMIT 10;

-- =============================================
-- SECTION 6: Load Example Titles
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 6: Loading Example Titles' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Load English Example Titles
COPY INTO EXAMPLE_TITLES_STAGING_EN
FROM @NOC_STAGE/66414d34-029e-4d0e-b6e5-ae3d99a73fac.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Load French Example Titles
COPY INTO EXAMPLE_TITLES_STAGING_FR
FROM @NOC_STAGE/e3599639-3540-4d39-a42b-f7d41909d6d4.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Verify load
SELECT 'Example Titles loaded:' AS status;
SELECT 'English:' AS language, COUNT(*) AS row_count FROM EXAMPLE_TITLES_STAGING_EN
UNION ALL
SELECT 'French:' AS language, COUNT(*) AS row_count FROM EXAMPLE_TITLES_STAGING_FR;
-- Expected: ~7,000+ rows each (multiple titles per occupation)

-- =============================================
-- SECTION 7: Load Main Duties
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 7: Loading Main Duties' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Load English Main Duties
COPY INTO MAIN_DUTIES_STAGING_EN
FROM @NOC_STAGE/79361933-2793-4e1e-b255-b6fa214ef28d.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Load French Main Duties
COPY INTO MAIN_DUTIES_STAGING_FR
FROM @NOC_STAGE/0553ee55-1a87-4709-bd61-3739af0322a3.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ENCODING = 'UTF8'
)
ON_ERROR = CONTINUE;

-- Verify load
SELECT 'Main Duties loaded:' AS status;
SELECT 'English:' AS language, COUNT(*) AS row_count FROM MAIN_DUTIES_STAGING_EN
UNION ALL
SELECT 'French:' AS language, COUNT(*) AS row_count FROM MAIN_DUTIES_STAGING_FR;
-- Expected: ~4,500+ rows each (multiple duties per occupation)

-- =============================================
-- SECTION 8: Data Quality Checks (Pre-Load)
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 8: Data Quality Checks' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Check for NULL values in Interests
SELECT 'NULL check - Interests:' AS check_name;
SELECT
    SUM(CASE WHEN noc_code IS NULL THEN 1 ELSE 0 END) AS null_noc_codes,
    SUM(CASE WHEN holland_code_1 IS NULL THEN 1 ELSE 0 END) AS null_holland_1,
    SUM(CASE WHEN holland_code_2 IS NULL THEN 1 ELSE 0 END) AS null_holland_2,
    SUM(CASE WHEN holland_code_3 IS NULL THEN 1 ELSE 0 END) AS null_holland_3
FROM INTERESTS_STAGING_EN;
-- Expected: All should be 0

-- Check Holland Code validity
SELECT 'Holland Code validation:' AS check_name;
SELECT DISTINCT holland_code_1 FROM INTERESTS_STAGING_EN
UNION
SELECT DISTINCT holland_code_2 FROM INTERESTS_STAGING_EN
UNION
SELECT DISTINCT holland_code_3 FROM INTERESTS_STAGING_EN
ORDER BY 1;
-- Expected: Only R, I, A, S, E, C (and possibly lowercase variants)

-- Check for duplicate NOC codes in Interests (should be unique)
SELECT 'Duplicate NOC codes in Interests:' AS check_name;
SELECT noc_code, COUNT(*) AS duplicate_count
FROM INTERESTS_STAGING_EN
GROUP BY noc_code
HAVING COUNT(*) > 1;
-- Expected: No results (no duplicates)

-- Verify key occupations exist
SELECT 'Key occupation check - Software Developers:' AS check_name;
SELECT * FROM INTERESTS_STAGING_EN
WHERE noc_label ILIKE '%software%developer%' OR noc_code = '21231.00';
-- Expected: 1-2 rows

-- Check English/French consistency
SELECT 'Language consistency check:' AS check_name;
SELECT
    (SELECT COUNT(DISTINCT noc_code) FROM INTERESTS_STAGING_EN) AS unique_noc_en,
    (SELECT COUNT(DISTINCT noc_code) FROM INTERESTS_STAGING_FR) AS unique_noc_fr,
    (SELECT COUNT(DISTINCT noc_code) FROM LEADSTATEMENT_STAGING_EN) AS lead_en,
    (SELECT COUNT(DISTINCT noc_code) FROM LEADSTATEMENT_STAGING_FR) AS lead_fr;
-- Expected: All should be 900

-- =============================================
-- SECTION 9: Create NOC_OCCUPATIONS Table
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 9: Creating NOC_OCCUPATIONS Table' AS step;
SELECT '════════════════════════════════════════' AS step;

CREATE TABLE IF NOT EXISTS NOC_OCCUPATIONS (
    -- Primary Key
    NOC_CODE VARCHAR(10) PRIMARY KEY,

    -- Basic Information (English)
    TITLE_EN VARCHAR(255) NOT NULL,
    DESCRIPTION_EN VARCHAR(5000),

    -- Basic Information (French)
    TITLE_FR VARCHAR(255),
    DESCRIPTION_FR VARCHAR(5000),

    -- Holland Codes (RIASEC)
    HOLLAND_CODE_1 VARCHAR(1),          -- Primary interest (R, I, A, S, E, or C)
    HOLLAND_CODE_2 VARCHAR(1),          -- Secondary interest
    HOLLAND_CODE_3 VARCHAR(1),          -- Tertiary interest

    -- Employment Requirements (Aggregated, English)
    EMPLOYMENT_REQUIREMENTS_EN VARCHAR(10000),  -- Bullet-separated list

    -- Employment Requirements (Aggregated, French)
    EMPLOYMENT_REQUIREMENTS_FR VARCHAR(10000),

    -- Example Titles (First 5, English)
    EXAMPLE_TITLES_EN VARCHAR(2000),

    -- Example Titles (First 5, French)
    EXAMPLE_TITLES_FR VARCHAR(2000),

    -- Main Duties (First 8, English)
    MAIN_DUTIES_EN VARCHAR(10000),

    -- Main Duties (First 8, French)
    MAIN_DUTIES_FR VARCHAR(10000),

    -- Metadata
    DATA_SOURCE VARCHAR(50) DEFAULT 'OASIS_2023_V1',
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
COMMENT = 'Canadian NOC occupation display data from OaSIS 2023 v1.0';

SELECT 'Table NOC_OCCUPATIONS created successfully' AS status;

-- =============================================
-- SECTION 10: Aggregate and Insert Data
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 10: Aggregating and Inserting Data' AS step;
SELECT '════════════════════════════════════════' AS step;

-- This is a complex INSERT that combines data from multiple staging tables
-- We'll use CTEs to aggregate the multi-row data

INSERT INTO NOC_OCCUPATIONS (
    NOC_CODE,
    TITLE_EN,
    TITLE_FR,
    DESCRIPTION_EN,
    DESCRIPTION_FR,
    HOLLAND_CODE_1,
    HOLLAND_CODE_2,
    HOLLAND_CODE_3,
    EMPLOYMENT_REQUIREMENTS_EN,
    EMPLOYMENT_REQUIREMENTS_FR,
    EXAMPLE_TITLES_EN,
    EXAMPLE_TITLES_FR,
    MAIN_DUTIES_EN,
    MAIN_DUTIES_FR
)
WITH
-- Aggregate Employment Requirements (concatenate with bullet points)
employment_agg_en AS (
    SELECT
        noc_code,
        LISTAGG(employment_requirement, ' • ') WITHIN GROUP (ORDER BY employment_requirement) AS requirements
    FROM EMPLOYMENT_REQ_STAGING_EN
    GROUP BY noc_code
),
employment_agg_fr AS (
    SELECT
        noc_code,
        LISTAGG(employment_requirement, ' • ') WITHIN GROUP (ORDER BY employment_requirement) AS requirements
    FROM EMPLOYMENT_REQ_STAGING_FR
    GROUP BY noc_code
),
-- Aggregate Example Titles (first 5)
titles_agg_en AS (
    SELECT
        noc_code,
        LISTAGG(example_title, ', ') WITHIN GROUP (ORDER BY example_title) AS titles
    FROM (
        SELECT noc_code, example_title,
               ROW_NUMBER() OVER (PARTITION BY noc_code ORDER BY example_title) AS rn
        FROM EXAMPLE_TITLES_STAGING_EN
    )
    WHERE rn <= 5
    GROUP BY noc_code
),
titles_agg_fr AS (
    SELECT
        noc_code,
        LISTAGG(example_title, ', ') WITHIN GROUP (ORDER BY example_title) AS titles
    FROM (
        SELECT noc_code, example_title,
               ROW_NUMBER() OVER (PARTITION BY noc_code ORDER BY example_title) AS rn
        FROM EXAMPLE_TITLES_STAGING_FR
    )
    WHERE rn <= 5
    GROUP BY noc_code
),
-- Aggregate Main Duties (first 8)
duties_agg_en AS (
    SELECT
        noc_code,
        LISTAGG(main_duty, ' • ') WITHIN GROUP (ORDER BY main_duty) AS duties
    FROM (
        SELECT noc_code, main_duty,
               ROW_NUMBER() OVER (PARTITION BY noc_code ORDER BY main_duty) AS rn
        FROM MAIN_DUTIES_STAGING_EN
    )
    WHERE rn <= 8
    GROUP BY noc_code
),
duties_agg_fr AS (
    SELECT
        noc_code,
        LISTAGG(main_duty, ' • ') WITHIN GROUP (ORDER BY main_duty) AS duties
    FROM (
        SELECT noc_code, main_duty,
               ROW_NUMBER() OVER (PARTITION BY noc_code ORDER BY main_duty) AS rn
        FROM MAIN_DUTIES_STAGING_FR
    )
    WHERE rn <= 8
    GROUP BY noc_code
)
-- Main SELECT combining all data sources
SELECT
    TRIM(i_en.noc_code) AS NOC_CODE,
    TRIM(i_en.noc_label) AS TITLE_EN,
    TRIM(i_fr.noc_label) AS TITLE_FR,
    TRIM(ls_en.lead_statement) AS DESCRIPTION_EN,
    TRIM(ls_fr.lead_statement) AS DESCRIPTION_FR,
    UPPER(TRIM(i_en.holland_code_1)) AS HOLLAND_CODE_1,
    UPPER(TRIM(i_en.holland_code_2)) AS HOLLAND_CODE_2,
    UPPER(TRIM(i_en.holland_code_3)) AS HOLLAND_CODE_3,
    emp_en.requirements AS EMPLOYMENT_REQUIREMENTS_EN,
    emp_fr.requirements AS EMPLOYMENT_REQUIREMENTS_FR,
    tit_en.titles AS EXAMPLE_TITLES_EN,
    tit_fr.titles AS EXAMPLE_TITLES_FR,
    dut_en.duties AS MAIN_DUTIES_EN,
    dut_fr.duties AS MAIN_DUTIES_FR
FROM INTERESTS_STAGING_EN i_en
LEFT JOIN INTERESTS_STAGING_FR i_fr ON i_en.noc_code = i_fr.noc_code
LEFT JOIN LEADSTATEMENT_STAGING_EN ls_en ON i_en.noc_code = ls_en.noc_code
LEFT JOIN LEADSTATEMENT_STAGING_FR ls_fr ON i_en.noc_code = ls_fr.noc_code
LEFT JOIN employment_agg_en emp_en ON i_en.noc_code = emp_en.noc_code
LEFT JOIN employment_agg_fr emp_fr ON i_en.noc_code = emp_fr.noc_code
LEFT JOIN titles_agg_en tit_en ON i_en.noc_code = tit_en.noc_code
LEFT JOIN titles_agg_fr tit_fr ON i_en.noc_code = tit_fr.noc_code
LEFT JOIN duties_agg_en dut_en ON i_en.noc_code = dut_en.noc_code
LEFT JOIN duties_agg_fr dut_fr ON i_en.noc_code = dut_fr.noc_code
WHERE TRIM(i_en.noc_code) IS NOT NULL;

-- Verify insert
SELECT 'Rows inserted into NOC_OCCUPATIONS:' AS status, COUNT(*) AS row_count
FROM NOC_OCCUPATIONS;
-- Expected: 900 rows

-- =============================================
-- SECTION 11: Optimize Table for Performance
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 11: Optimizing Table for Performance' AS step;
SELECT '════════════════════════════════════════' AS step;

-- NOTE: Snowflake regular tables use micro-partitioning and don't need indexes
-- Indexes are only for hybrid tables. For regular tables, we can use clustering keys instead.
-- Since this is a small table (900 rows), no optimization is needed.
-- Queries will be fast due to Snowflake's automatic optimization and the PRIMARY KEY on NOC_CODE.

SELECT 'Table optimization complete (using Snowflake micro-partitioning)' AS status;

-- =============================================
-- SECTION 12: Post-Load Validation
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 12: Post-Load Validation' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Overall statistics
SELECT 'NOC Occupations Statistics:' AS metric_name;
SELECT
    COUNT(*) AS total_occupations,
    COUNT(DISTINCT NOC_CODE) AS unique_noc_codes,
    COUNT(DISTINCT TITLE_EN) AS unique_titles,
    SUM(CASE WHEN DESCRIPTION_EN IS NOT NULL THEN 1 ELSE 0 END) AS has_description,
    SUM(CASE WHEN HOLLAND_CODE_1 IS NOT NULL THEN 1 ELSE 0 END) AS has_holland_codes,
    SUM(CASE WHEN EMPLOYMENT_REQUIREMENTS_EN IS NOT NULL THEN 1 ELSE 0 END) AS has_requirements
FROM NOC_OCCUPATIONS;
-- Expected: 900 total, all have descriptions and Holland codes

-- Holland Code distribution
SELECT 'Holland Code Distribution (Primary):' AS metric_name;
SELECT
    HOLLAND_CODE_1,
    COUNT(*) AS occupation_count,
    ROUND(COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER (), 0), 1) AS percentage
FROM NOC_OCCUPATIONS
GROUP BY HOLLAND_CODE_1
ORDER BY occupation_count DESC;
-- Expected: Distribution across R, I, A, S, E, C

-- Check bilingual completeness
SELECT 'Bilingual Completeness:' AS metric_name;
SELECT
    COUNT(*) AS total_occupations,
    SUM(CASE WHEN TITLE_FR IS NOT NULL THEN 1 ELSE 0 END) AS has_french_title,
    SUM(CASE WHEN DESCRIPTION_FR IS NOT NULL THEN 1 ELSE 0 END) AS has_french_description,
    ROUND(SUM(CASE WHEN TITLE_FR IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 1) AS french_title_pct,
    ROUND(SUM(CASE WHEN DESCRIPTION_FR IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 1) AS french_desc_pct
FROM NOC_OCCUPATIONS;
-- Expected: 100% or near 100% for French content

-- Test key occupation lookups
SELECT 'Test Key Occupation Lookups:' AS test_name;
SELECT
    NOC_CODE,
    TITLE_EN,
    HOLLAND_CODE_1 || HOLLAND_CODE_2 || HOLLAND_CODE_3 AS holland_codes,
    LEFT(DESCRIPTION_EN, 100) || '...' AS description_preview,
    LENGTH(EMPLOYMENT_REQUIREMENTS_EN) AS req_length
FROM NOC_OCCUPATIONS
WHERE TITLE_EN ILIKE '%software%developer%'
   OR TITLE_EN ILIKE '%teacher%'
   OR TITLE_EN ILIKE '%financial%manager%'
   OR TITLE_EN ILIKE '%registered%nurse%'
ORDER BY TITLE_EN
LIMIT 10;
-- Expected: At least 4 occupations found

-- Verify specific NOC codes that should map to O*NET
SELECT 'NOC codes that should map to key O*NET codes:' AS test_name;
SELECT
    n.NOC_CODE,
    n.TITLE_EN AS noc_title,
    c.ONET_CODE,
    c.ONET_TITLE,
    c.MAPPING_CONFIDENCE
FROM NOC_OCCUPATIONS n
JOIN NOC_ONET_CROSSWALK c ON n.NOC_CODE = SUBSTRING(c.NOC_CODE, 1, LENGTH(n.NOC_CODE))
WHERE c.ONET_CODE IN (
    '15-1252.00',  -- Software Developers
    '25-2031.00',  -- Secondary Teachers
    '11-3031.00',  -- Financial Managers
    '29-1141.00'   -- Registered Nurses
)
ORDER BY c.ONET_CODE;
-- Expected: Successful joins showing NOC-to-O*NET mapping

-- =============================================
-- SECTION 13: Test Crosswalk Integration
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 13: Testing Crosswalk Integration' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Test how many NOC occupations have O*NET mappings
SELECT 'NOC-to-O*NET Coverage:' AS metric_name;
SELECT
    COUNT(DISTINCT n.NOC_CODE) AS total_noc_occupations,
    COUNT(DISTINCT CASE WHEN c.ONET_CODE IS NOT NULL THEN n.NOC_CODE END) AS noc_with_onet_mapping,
    ROUND(COUNT(DISTINCT CASE WHEN c.ONET_CODE IS NOT NULL THEN n.NOC_CODE END) * 100.0 / NULLIF(COUNT(DISTINCT n.NOC_CODE), 0), 1) AS coverage_pct
FROM NOC_OCCUPATIONS n
LEFT JOIN NOC_ONET_CROSSWALK c ON SUBSTRING(n.NOC_CODE, 1, 5) = c.NOC_CODE;
-- Expected: ~50-60% coverage (not all NOC codes have O*NET equivalents)

-- Show example of enriched data (NOC + O*NET combined)
SELECT 'Example Enriched Data (NOC + O*NET):' AS test_name;
SELECT
    n.NOC_CODE AS noc_code,
    n.TITLE_EN AS canadian_title,
    n.HOLLAND_CODE_1 || n.HOLLAND_CODE_2 || n.HOLLAND_CODE_3 AS holland_codes,
    c.ONET_CODE AS onet_code,
    c.ONET_TITLE AS us_title,
    c.MAPPING_CONFIDENCE,
    LEFT(n.DESCRIPTION_EN, 150) || '...' AS description_preview
FROM NOC_OCCUPATIONS n
LEFT JOIN NOC_ONET_CROSSWALK c ON SUBSTRING(n.NOC_CODE, 1, 5) = c.NOC_CODE
WHERE n.TITLE_EN ILIKE '%software%developer%'
LIMIT 3;
-- Expected: Shows NOC data enriched with O*NET crosswalk

-- =============================================
-- SECTION 14: Cleanup Staging Tables
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT 'STEP 14: Cleanup Staging Tables' AS step;
SELECT '════════════════════════════════════════' AS step;

-- Drop all staging tables (they're temporary, will auto-drop on session end)
DROP TABLE IF EXISTS INTERESTS_STAGING_EN;
DROP TABLE IF EXISTS INTERESTS_STAGING_FR;
DROP TABLE IF EXISTS LEADSTATEMENT_STAGING_EN;
DROP TABLE IF EXISTS LEADSTATEMENT_STAGING_FR;
DROP TABLE IF EXISTS EMPLOYMENT_REQ_STAGING_EN;
DROP TABLE IF EXISTS EMPLOYMENT_REQ_STAGING_FR;
DROP TABLE IF EXISTS EXAMPLE_TITLES_STAGING_EN;
DROP TABLE IF EXISTS EXAMPLE_TITLES_STAGING_FR;
DROP TABLE IF EXISTS MAIN_DUTIES_STAGING_EN;
DROP TABLE IF EXISTS MAIN_DUTIES_STAGING_FR;

SELECT 'All staging tables cleaned up' AS status;

-- =============================================
-- FINAL STATUS
-- =============================================

SELECT '════════════════════════════════════════' AS step;
SELECT '✅ STEP 2 COMPLETE: OaSIS Display Data Imported' AS step;
SELECT '════════════════════════════════════════' AS step;

SELECT
    '✅ Table created: NOC_OCCUPATIONS' AS status
UNION ALL
SELECT
    '✅ Rows imported: ' || COUNT(*) || ' occupations'
FROM NOC_OCCUPATIONS
UNION ALL
SELECT
    '✅ Unique NOC codes: ' || COUNT(DISTINCT NOC_CODE)
FROM NOC_OCCUPATIONS
UNION ALL
SELECT
    '✅ Holland codes: ' || SUM(CASE WHEN HOLLAND_CODE_1 IS NOT NULL THEN 1 ELSE 0 END) || ' complete'
FROM NOC_OCCUPATIONS
UNION ALL
SELECT
    '✅ French content: ' || ROUND(SUM(CASE WHEN TITLE_FR IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 1) || '% coverage'
FROM NOC_OCCUPATIONS
UNION ALL
SELECT
    '✅ Crosswalk integration: ' ||
    ROUND(COUNT(DISTINCT CASE WHEN c.ONET_CODE IS NOT NULL THEN n.NOC_CODE END) * 100.0 / NULLIF(COUNT(DISTINCT n.NOC_CODE), 0), 1) || '% mapped to O*NET'
FROM NOC_OCCUPATIONS n
LEFT JOIN NOC_ONET_CROSSWALK c ON SUBSTRING(n.NOC_CODE, 1, 5) = c.NOC_CODE
UNION ALL
SELECT '✅ Performance: Optimized with Snowflake micro-partitioning'
UNION ALL
SELECT '✅ Ready for: STEP 3 (Validation & Testing)';

-- =============================================
-- NEXT STEP
-- =============================================
--
-- Run: NOC_STEP3_VALIDATION_QUERIES.sql
--
-- This will provide comprehensive validation queries
-- to test the hybrid matching approach end-to-end
-- =============================================
