-- =============================================
-- Recipe C v3.0 - Snowflake Backup Script
-- =============================================
-- Creates backup copies of all Recipe C database objects
-- Run this script in Snowflake to create v3.0 backups
--
-- Created: 2025-10-07
-- Version: Recipe C v3.0
-- Purpose: Backup before Recipe D implementation
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- BACKUP 1: Stored Procedure SP_GET_CAREER_MATCHES_V3
-- =============================================
-- This creates a backup copy of the v3.0 matching procedure
-- The backup can be called directly if rollback is needed

CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V3_BACKUP(
    USER_REALISTIC FLOAT,
    USER_INVESTIGATIVE FLOAT,
    USER_ARTISTIC FLOAT,
    USER_SOCIAL FLOAT,
    USER_ENTERPRISING FLOAT,
    USER_CONVENTIONAL FLOAT,
    USER_ACHIEVEMENT FLOAT,
    USER_INDEPENDENCE FLOAT,
    USER_RECOGNITION FLOAT,
    USER_RELATIONSHIPS FLOAT,
    USER_SUPPORT FLOAT,
    USER_WORKING_CONDITIONS FLOAT
)
RETURNS TABLE (
    ONET_SOC_CODE VARCHAR,
    JOB_TITLE VARCHAR,
    INTERESTS_MATCH FLOAT,
    VALUES_MATCH FLOAT,
    BLENDED_MATCH FLOAT,
    FINAL_SCORE FLOAT,
    DESCRIPTION VARCHAR
)
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    // Cosine similarity function
    function cosineSimilarity(a, b) {
        let dotProduct = 0;
        let normA = 0;
        let normB = 0;

        for (let i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }

        if (normA === 0 || normB === 0) return 0;
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    // User RIASEC profile (interests)
    var userRIASEC = [
        USER_REALISTIC,
        USER_INVESTIGATIVE,
        USER_ARTISTIC,
        USER_SOCIAL,
        USER_ENTERPRISING,
        USER_CONVENTIONAL
    ];

    // User Work Values profile
    var userValues = [
        USER_ACHIEVEMENT,
        USER_INDEPENDENCE,
        USER_RECOGNITION,
        USER_RELATIONSHIPS,
        USER_SUPPORT,
        USER_WORKING_CONDITIONS
    ];

    // Query careers from the materialized view
    var sqlQuery = `
        SELECT
            ONET_SOC_CODE,
            JOB_TITLE,
            REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL,
            ACHIEVEMENT, INDEPENDENCE, RECOGNITION, RELATIONSHIPS, SUPPORT, WORKING_CONDITIONS,
            DESCRIPTION
        FROM CAREER_RIASEC_VALUES_VECTORS
    `;

    var statement = snowflake.createStatement({sqlText: sqlQuery});
    var resultSet = statement.execute();

    // Calculate matches and scores
    var results = [];

    while (resultSet.next()) {
        var jobRIASEC = [
            resultSet.getColumnValue('REALISTIC'),
            resultSet.getColumnValue('INVESTIGATIVE'),
            resultSet.getColumnValue('ARTISTIC'),
            resultSet.getColumnValue('SOCIAL'),
            resultSet.getColumnValue('ENTERPRISING'),
            resultSet.getColumnValue('CONVENTIONAL')
        ];

        var jobValues = [
            resultSet.getColumnValue('ACHIEVEMENT'),
            resultSet.getColumnValue('INDEPENDENCE'),
            resultSet.getColumnValue('RECOGNITION'),
            resultSet.getColumnValue('RELATIONSHIPS'),
            resultSet.getColumnValue('SUPPORT'),
            resultSet.getColumnValue('WORKING_CONDITIONS')
        ];

        // Calculate individual match scores (0-1 range)
        var interestsMatch = cosineSimilarity(userRIASEC, jobRIASEC);
        var valuesMatch = cosineSimilarity(userValues, jobValues);

        // Blended match: 60% interests + 40% work values
        var blendedMatch = (0.6 * interestsMatch) + (0.4 * valuesMatch);

        // Scale to 0-7 range for final score
        var finalScore = blendedMatch * 7.0;

        results.push({
            ONET_SOC_CODE: resultSet.getColumnValue('ONET_SOC_CODE'),
            JOB_TITLE: resultSet.getColumnValue('JOB_TITLE'),
            INTERESTS_MATCH: interestsMatch,
            VALUES_MATCH: valuesMatch,
            BLENDED_MATCH: blendedMatch,
            FINAL_SCORE: finalScore,
            DESCRIPTION: resultSet.getColumnValue('DESCRIPTION')
        });
    }

    // Sort by blended match score descending
    results.sort((a, b) => b.BLENDED_MATCH - a.BLENDED_MATCH);

    return results;
$$;

-- =============================================
-- BACKUP 2: Materialized View CAREER_RIASEC_VALUES_VECTORS
-- =============================================
-- This creates a static table backup of the vectors view
-- Preserves the exact state at backup time

CREATE OR REPLACE TABLE CAREER_RIASEC_VALUES_VECTORS_V3_BACKUP AS
SELECT * FROM CAREER_RIASEC_VALUES_VECTORS;

-- =============================================
-- BACKUP 3: Work Values Data Table
-- =============================================
-- Backup the raw Work Values data imported from O*NET

CREATE OR REPLACE TABLE WORK_VALUES_V3_BACKUP AS
SELECT * FROM WORK_VALUES;

-- =============================================
-- BACKUP 4: Interests Data (for completeness)
-- =============================================
-- Backup the RIASEC interests data

CREATE OR REPLACE TABLE INTERESTS_FACT_V3_BACKUP AS
SELECT * FROM INTERESTS_FACT;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================
-- Run these to verify backups were created successfully

-- Verify procedure backup exists
SHOW PROCEDURES LIKE 'SP_GET_CAREER_MATCHES_V3_BACKUP';

-- Verify table backups exist and check row counts
SELECT 'CAREER_RIASEC_VALUES_VECTORS_V3_BACKUP' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM CAREER_RIASEC_VALUES_VECTORS_V3_BACKUP
UNION ALL
SELECT 'WORK_VALUES_V3_BACKUP', COUNT(*)
FROM WORK_VALUES_V3_BACKUP
UNION ALL
SELECT 'INTERESTS_FACT_V3_BACKUP', COUNT(*)
FROM INTERESTS_FACT_V3_BACKUP;

-- Test the backup procedure with sample data
CALL SP_GET_CAREER_MATCHES_V3_BACKUP(
    4.5, 5.0, 3.0, 4.0, 3.5, 2.5,  -- RIASEC scores
    4.0, 5.0, 3.0, 4.0, 3.0, 4.0   -- Work Values scores
);

-- =============================================
-- ROLLBACK PROCEDURE (if needed)
-- =============================================
-- To restore Recipe C v3.0 from backup:
--
-- 1. Restore the stored procedure:
--    CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V3 AS
--    SELECT GET_DDL('PROCEDURE', 'SP_GET_CAREER_MATCHES_V3_BACKUP');
--
-- 2. Restore the vectors view:
--    CREATE OR REPLACE TABLE CAREER_RIASEC_VALUES_VECTORS AS
--    SELECT * FROM CAREER_RIASEC_VALUES_VECTORS_V3_BACKUP;
--
-- 3. Restore Work Values data:
--    CREATE OR REPLACE TABLE WORK_VALUES AS
--    SELECT * FROM WORK_VALUES_V3_BACKUP;

-- =============================================
-- BACKUP METADATA
-- =============================================
-- Record backup information

CREATE TABLE IF NOT EXISTS BACKUP_METADATA (
    BACKUP_ID VARCHAR,
    BACKUP_DATE TIMESTAMP,
    VERSION VARCHAR,
    DESCRIPTION VARCHAR,
    OBJECTS_BACKED_UP ARRAY
);

INSERT INTO BACKUP_METADATA VALUES (
    'recipe-c-v3.0',
    CURRENT_TIMESTAMP(),
    'v3.0',
    'Recipe C backup before Recipe D implementation - Interests + Work Values matching',
    ARRAY_CONSTRUCT(
        'SP_GET_CAREER_MATCHES_V3_BACKUP',
        'CAREER_RIASEC_VALUES_VECTORS_V3_BACKUP',
        'WORK_VALUES_V3_BACKUP',
        'INTERESTS_FACT_V3_BACKUP'
    )
);

-- View backup history
SELECT * FROM BACKUP_METADATA ORDER BY BACKUP_DATE DESC;

-- =============================================
-- PERFORMANCE BASELINE (for Recipe D comparison)
-- =============================================
-- Expected performance metrics for Recipe C v3.0:
-- - Average latency: 1055ms
-- - Success rate: 99.8%
-- - Occupations matched: 823
-- - Algorithm: 60% RIASEC + 40% Work Values
-- =============================================
