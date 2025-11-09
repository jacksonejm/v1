-- =============================================
-- Recipe D Troubleshooting Script
-- =============================================
-- Run this first to check what objects exist
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- Check 1: What tables exist?
-- =============================================

SHOW TABLES;

-- =============================================
-- Check 2: Verify required tables exist
-- =============================================

-- Check OCCUPATION_DATA
SELECT 'OCCUPATION_DATA' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM OCCUPATION_DATA;

-- Check INTERESTS_FACT
SELECT 'INTERESTS_FACT' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM INTERESTS_FACT;

-- Check WORK_VALUES (should exist if Recipe C was attempted)
SELECT 'WORK_VALUES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM WORK_VALUES;

-- =============================================
-- Check 3: Check if Skills.txt is in stage
-- =============================================

LIST @ONET_DATA_STAGE;

-- Look for Skills.txt in the output
-- If you see "Skills.txt", you can proceed with import

-- =============================================
-- Check 4: What stored procedures exist?
-- =============================================

SHOW PROCEDURES;

-- =============================================
-- DIAGNOSIS GUIDE
-- =============================================
-- If you see these errors, here's what to do:
--
-- ERROR: "Object 'OCCUPATION_DATA' does not exist"
--   → Your database isn't set up yet
--   → Need to import basic O*NET tables first
--
-- ERROR: "Object 'WORK_VALUES' does not exist"
--   → Recipe C was never deployed to Snowflake
--   → Need to run IMPORT_WORK_VALUES.sql first
--
-- ERROR: "Object '@ONET_DATA_STAGE' does not exist"
--   → Need to create stage and upload O*NET files
--   → Run: CREATE STAGE ONET_DATA_STAGE;
--
-- ERROR: No 'Skills.txt' in stage listing
--   → Need to upload Skills.txt to stage
--   → Upload via Snowflake UI or PUT command
-- =============================================
