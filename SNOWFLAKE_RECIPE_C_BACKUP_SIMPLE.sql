-- =============================================
-- Recipe C v3.0 - Simplified Snowflake Backup
-- =============================================
-- Run each section separately to identify which objects exist
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- STEP 1: Check what objects currently exist
-- =============================================

-- Check for SP_GET_CAREER_MATCHES_V3
SHOW PROCEDURES LIKE 'SP_GET_CAREER_MATCHES_V3';

-- Check for materialized view
SHOW VIEWS LIKE 'CAREER_RIASEC_VALUES_VECTORS';

-- Check for tables
SHOW TABLES LIKE 'CAREER_RIASEC_VALUES_VECTORS';
SHOW TABLES LIKE 'WORK_VALUES';
SHOW TABLES LIKE 'INTERESTS_FACT';

-- =============================================
-- STEP 2: Backup WORK_VALUES table (if exists)
-- =============================================

CREATE OR REPLACE TABLE WORK_VALUES_V3_BACKUP AS
SELECT * FROM WORK_VALUES;

-- Verify
SELECT 'WORK_VALUES_V3_BACKUP' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM WORK_VALUES_V3_BACKUP;

-- =============================================
-- STEP 3: Backup INTERESTS_FACT table (if exists)
-- =============================================

CREATE OR REPLACE TABLE INTERESTS_FACT_V3_BACKUP AS
SELECT * FROM INTERESTS_FACT;

-- Verify
SELECT 'INTERESTS_FACT_V3_BACKUP' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM INTERESTS_FACT_V3_BACKUP;

-- =============================================
-- STEP 4: Backup stored procedure by recreating it
-- =============================================
-- Copy the entire SP_GET_CAREER_MATCHES_V3 definition
-- and rename it to SP_GET_CAREER_MATCHES_V3_BACKUP

-- NOTE: You'll need to run SCORING_V3_RECIPE_C.sql first if the procedure doesn't exist

-- =============================================
-- STEP 5: Create backup metadata
-- =============================================

CREATE TABLE IF NOT EXISTS BACKUP_METADATA (
    BACKUP_ID VARCHAR,
    BACKUP_DATE TIMESTAMP,
    VERSION VARCHAR,
    DESCRIPTION VARCHAR,
    OBJECTS_BACKED_UP VARCHAR
);

INSERT INTO BACKUP_METADATA VALUES (
    'recipe-c-v3.0',
    CURRENT_TIMESTAMP(),
    'v3.0',
    'Recipe C backup before Recipe D - Code backups only, Snowflake objects may not exist yet',
    'WORK_VALUES_V3_BACKUP, INTERESTS_FACT_V3_BACKUP'
);

-- View backup history
SELECT * FROM BACKUP_METADATA ORDER BY BACKUP_DATE DESC;
