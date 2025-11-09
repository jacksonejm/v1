-- =============================================
-- Recipe D - Fixed for Your Database Schema
-- =============================================
-- This is customized for your actual table names
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- STEP 1: Check what work values table you have
-- =============================================

-- Check if WORK_VALUES exists (from imports)
SELECT 'Checking WORK_VALUES...' AS STATUS;
SELECT COUNT(*) AS WORK_VALUES_COUNT FROM WORK_VALUES;

-- If that fails, check WORK_VALUES_FACT
-- SELECT COUNT(*) AS WORK_VALUES_FACT_COUNT FROM WORK_VALUES_FACT;

-- =============================================
-- STEP 2A: Create SUBJECT_SKILLS_MAPPING
-- =============================================
-- This should have been created but shows 0 rows
-- Let me recreate it with data

DROP TABLE IF EXISTS SUBJECT_SKILLS_MAPPING;

CREATE TABLE SUBJECT_SKILLS_MAPPING (
    SUBJECT_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    SKILL_NAME VARCHAR(100),
    RELEVANCE_SCORE FLOAT
);

-- Insert mappings (same as Step 2)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
-- Math
('Math', '2.A.1.a', 'Mathematics', 0.95),
('Math', '2.A.1.b', 'Science', 0.60),
('Math', '2.B.1.a', 'Critical Thinking', 0.75),
('Math', '2.B.2.a', 'Active Learning', 0.70),
('Algebra', '2.A.1.a', 'Mathematics', 0.90),
('Algebra', '2.B.1.a', 'Critical Thinking', 0.75),
('Calculus', '2.A.1.a', 'Mathematics', 0.95),
('Calculus', '2.A.1.b', 'Science', 0.70),
('Calculus', '2.B.1.a', 'Critical Thinking', 0.80),
('Statistics', '2.A.1.a', 'Mathematics', 0.85),
('Statistics', '2.B.1.a', 'Critical Thinking', 0.85),
('Statistics', '2.B.2.a', 'Active Learning', 0.75),

-- Science
('Science', '2.A.1.b', 'Science', 0.95),
('Science', '2.B.1.a', 'Critical Thinking', 0.80),
('Science', '2.B.2.a', 'Active Learning', 0.75),
('Biology', '2.A.1.b', 'Science', 0.95),
('Biology', '2.B.1.a', 'Critical Thinking', 0.75),
('Biology', '2.A.2.a', 'Reading Comprehension', 0.70),
('Chemistry', '2.A.1.b', 'Science', 0.95),
('Chemistry', '2.A.1.a', 'Mathematics', 0.65),
('Chemistry', '2.B.1.a', 'Critical Thinking', 0.80),
('Physics', '2.A.1.b', 'Science', 0.95),
('Physics', '2.A.1.a', 'Mathematics', 0.85),
('Physics', '2.B.1.a', 'Critical Thinking', 0.85),

-- English
('English', '2.A.2.a', 'Reading Comprehension', 0.95),
('English', '2.A.2.b', 'Active Listening', 0.75),
('English', '2.A.2.c', 'Writing', 0.90),
('English', '2.A.2.d', 'Speaking', 0.80),
('Literature', '2.A.2.a', 'Reading Comprehension', 0.95),
('Literature', '2.B.1.a', 'Critical Thinking', 0.85),
('Literature', '2.A.2.c', 'Writing', 0.75),
('Writing', '2.A.2.c', 'Writing', 0.95),
('Writing', '2.A.2.a', 'Reading Comprehension', 0.75),
('Writing', '2.B.1.a', 'Critical Thinking', 0.70),

-- Computer Science
('Computer Science', '2.B.3.b', 'Programming', 0.95),
('Computer Science', '2.A.1.a', 'Mathematics', 0.75),
('Computer Science', '2.B.1.a', 'Critical Thinking', 0.85),
('Computer Science', '2.B.3.c', 'Systems Analysis', 0.80);

-- Verify
SELECT COUNT(*) AS SUBJECT_MAPPINGS_COUNT FROM SUBJECT_SKILLS_MAPPING;

-- =============================================
-- STEP 2B: Create ACTIVITY_SKILLS_MAPPING
-- =============================================

DROP TABLE IF EXISTS ACTIVITY_SKILLS_MAPPING;

CREATE TABLE ACTIVITY_SKILLS_MAPPING (
    ACTIVITY_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    SKILL_NAME VARCHAR(100),
    RELEVANCE_SCORE FLOAT
);

-- Insert key mappings
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Coding/Programming', '2.B.3.b', 'Programming', 0.95),
('Coding/Programming', '2.B.1.a', 'Critical Thinking', 0.85),
('Coding/Programming', '2.B.3.c', 'Systems Analysis', 0.75),
('Robotics', '2.B.3.b', 'Programming', 0.85),
('Robotics', '2.A.1.a', 'Mathematics', 0.75),
('Robotics', '2.B.3.c', 'Systems Analysis', 0.80),
('Debate', '2.B.1.a', 'Critical Thinking', 0.90),
('Debate', '2.A.2.d', 'Speaking', 0.90),
('Debate', '2.B.4.c', 'Persuasion', 0.85),
('Debate', '2.A.2.b', 'Active Listening', 0.75),
('Volunteering', '2.B.4.d', 'Social Perceptiveness', 0.85),
('Volunteering', '2.B.4.b', 'Service Orientation', 0.90),
('Volunteering', '2.A.2.b', 'Active Listening', 0.75),
('Drama/Theater', '2.A.2.d', 'Speaking', 0.90),
('Drama/Theater', '2.B.4.d', 'Social Perceptiveness', 0.85),
('Drama/Theater', '2.A.2.b', 'Active Listening', 0.75),
('Math Club', '2.A.1.a', 'Mathematics', 0.90),
('Math Club', '2.B.1.a', 'Critical Thinking', 0.80),
('Science Club', '2.A.1.b', 'Science', 0.85),
('Science Club', '2.B.1.a', 'Critical Thinking', 0.80),
('Science Club', '2.B.2.a', 'Active Learning', 0.80);

-- Verify
SELECT COUNT(*) AS ACTIVITY_MAPPINGS_COUNT FROM ACTIVITY_SKILLS_MAPPING;

-- =============================================
-- STEP 3: Create CAREER_FULL_VECTORS
-- =============================================
-- Using YOUR actual table names: OCCUPATION_DIM, WORK_VALUES

DROP TABLE IF EXISTS CAREER_FULL_VECTORS;

CREATE TABLE CAREER_FULL_VECTORS AS
SELECT
    o.ONET_SOC_CODE,
    o.TITLE AS JOB_TITLE,
    o.DESCRIPTION,

    -- RIASEC from INTERESTS_FACT
    MAX(CASE WHEN i.ELEMENT_NAME = 'Realistic' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS REALISTIC,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Investigative' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS INVESTIGATIVE,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Artistic' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS ARTISTIC,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Social' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS SOCIAL,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Enterprising' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS ENTERPRISING,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Conventional' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS CONVENTIONAL,

    -- Work Values from WORK_VALUES (or WORK_VALUES_FACT)
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.a' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS ACHIEVEMENT,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.f' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS INDEPENDENCE,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.c' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS RECOGNITION,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.d' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS RELATIONSHIPS,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.e' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS SUPPORT,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.b' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS WORKING_CONDITIONS,

    -- Top 10 Skills from SKILLS_FACT
    ARRAY_AGG(
        OBJECT_CONSTRUCT(
            'skill_id', s.ELEMENT_ID,
            'skill_name', s.ELEMENT_NAME,
            'importance', s.DATA_VALUE
        )
    ) WITHIN GROUP (ORDER BY s.DATA_VALUE DESC) AS SKILLS_VECTOR,

    -- Education (NULL for now)
    NULL AS EDUCATION_LEVEL

FROM OCCUPATION_DIM o
LEFT JOIN INTERESTS_FACT i
    ON o.ONET_SOC_CODE = i.ONET_SOC_CODE
LEFT JOIN WORK_VALUES w  -- Change to WORK_VALUES_FACT if needed
    ON o.ONET_SOC_CODE = w.ONET_SOC_CODE
LEFT JOIN (
    SELECT
        ONET_SOC_CODE,
        ELEMENT_ID,
        ELEMENT_NAME,
        DATA_VALUE,
        ROW_NUMBER() OVER (PARTITION BY ONET_SOC_CODE ORDER BY DATA_VALUE DESC) AS RN
    FROM SKILLS_FACT
    WHERE SCALE_ID = 'IM'
      AND (RECOMMEND_SUPPRESS != 'Y' OR RECOMMEND_SUPPRESS IS NULL)
      AND DATA_VALUE > 0
) s ON o.ONET_SOC_CODE = s.ONET_SOC_CODE AND s.RN <= 10

GROUP BY
    o.ONET_SOC_CODE,
    o.TITLE,
    o.DESCRIPTION;

-- Verify
SELECT 'CAREER_FULL_VECTORS created' AS STATUS, COUNT(*) AS ROW_COUNT
FROM CAREER_FULL_VECTORS;

-- Check sample
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    REALISTIC, INVESTIGATIVE,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS
FROM CAREER_FULL_VECTORS
WHERE JOB_TITLE LIKE '%Software%'
LIMIT 3;

-- =============================================
-- FINAL STATUS CHECK
-- =============================================

SELECT 'SUBJECT_SKILLS_MAPPING' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM SUBJECT_SKILLS_MAPPING
UNION ALL
SELECT 'ACTIVITY_SKILLS_MAPPING', COUNT(*) FROM ACTIVITY_SKILLS_MAPPING
UNION ALL
SELECT 'CAREER_FULL_VECTORS', COUNT(*) FROM CAREER_FULL_VECTORS;

-- Expected:
-- SUBJECT_SKILLS_MAPPING: ~36 rows
-- ACTIVITY_SKILLS_MAPPING: ~21 rows
-- CAREER_FULL_VECTORS: ~1000 rows

SELECT '✅ If you see row counts above, Recipe D tables are ready!' AS STATUS;
SELECT '⏳ Next: Run the stored procedure script' AS NEXT_STEP;
