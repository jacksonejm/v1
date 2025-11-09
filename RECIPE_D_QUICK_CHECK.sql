-- =============================================
-- Recipe D v4.0 - Quick Status Check
-- =============================================
-- Run this to quickly see what's deployed
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- Check all tables at once
SELECT 'OCCUPATION_DATA' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM OCCUPATION_DATA
UNION ALL
SELECT 'INTERESTS_FACT', COUNT(*) FROM INTERESTS_FACT
UNION ALL
SELECT 'WORK_VALUES', COUNT(*) FROM WORK_VALUES
UNION ALL
SELECT 'SKILLS_FACT', COUNT(*) FROM SKILLS_FACT
UNION ALL
SELECT 'SUBJECT_SKILLS_MAPPING', COUNT(*) FROM SUBJECT_SKILLS_MAPPING
UNION ALL
SELECT 'ACTIVITY_SKILLS_MAPPING', COUNT(*) FROM ACTIVITY_SKILLS_MAPPING
UNION ALL
SELECT 'CAREER_FULL_VECTORS', COUNT(*) FROM CAREER_FULL_VECTORS
ORDER BY TABLE_NAME;

-- Check stored procedures
SHOW PROCEDURES LIKE '%CAREER_MATCHES%';

-- Quick test of v4.0
SELECT 'Testing SP_GET_CAREER_MATCHES_V4...' AS STATUS;

CALL SP_GET_CAREER_MATCHES_V4(
    2.0, 5.0, 2.5, 3.0, 3.0, 4.0,  -- RIASEC
    5.0, 5.0, 3.0, 2.5, 2.5, 3.5,  -- Work Values
    '["Math", "Computer Science"]',  -- Subjects
    '["Coding/Programming"]',        -- Activities
    '["Software Developer"]',        -- Career Interests
    'Undergraduate',                 -- Student Level
    'Student'                        -- Status
);
