USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Recipe D v4.0 - Fix Mapping Tables with Correct O*NET Skill IDs
-- =============================================

-- First, let's see what skills Software Developers actually have
SELECT 'Top 15 skills for Software Developers (15-1252.00):' AS INFO;
SELECT
    ELEMENT_ID,
    ELEMENT_NAME,
    DATA_VALUE AS IMPORTANCE
FROM SKILLS_FACT
WHERE ONET_SOC_CODE = '15-1252.00'
  AND SCALE_ID = 'IM'
ORDER BY DATA_VALUE DESC
LIMIT 15;

-- Now let's recreate the mapping tables with CORRECT skill IDs
-- We'll map user-friendly subject/activity names to actual O*NET Element IDs

DROP TABLE IF EXISTS SUBJECT_SKILLS_MAPPING;
CREATE TABLE SUBJECT_SKILLS_MAPPING (
    SUBJECT_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    SKILL_NAME VARCHAR(100),
    RELEVANCE_SCORE FLOAT
);

DROP TABLE IF EXISTS ACTIVITY_SKILLS_MAPPING;
CREATE TABLE ACTIVITY_SKILLS_MAPPING (
    ACTIVITY_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    SKILL_NAME VARCHAR(100),
    RELEVANCE_SCORE FLOAT
);

-- Insert mappings with CORRECT O*NET Element IDs
-- Based on the 35 O*NET skills we just saw

-- Math maps to Mathematics (2.A.1.e)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Math', '2.A.1.e', 'Mathematics', 0.95),
('Math', '2.A.2.a', 'Critical Thinking', 0.75),
('Math', '2.B.2.i', 'Complex Problem Solving', 0.70);

-- Science maps to Science (2.A.1.f)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Science', '2.A.1.f', 'Science', 0.95),
('Science', '2.A.2.a', 'Critical Thinking', 0.80),
('Science', '2.A.2.b', 'Active Learning', 0.75);

-- Computer Science maps to Programming + Systems Analysis + Critical Thinking
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Computer Science', '2.B.3.e', 'Programming', 0.95),
('Computer Science', '2.B.4.g', 'Systems Analysis', 0.85),
('Computer Science', '2.A.2.a', 'Critical Thinking', 0.85),
('Computer Science', '2.A.1.e', 'Mathematics', 0.75),
('Computer Science', '2.B.2.i', 'Complex Problem Solving', 0.80);

-- English maps to Writing + Reading
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('English', '2.A.1.c', 'Writing', 0.95),
('English', '2.A.1.a', 'Reading Comprehension', 0.90),
('English', '2.A.2.a', 'Critical Thinking', 0.75);

-- History/Social Studies maps to Critical Thinking + Reading
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('History', '2.A.2.a', 'Critical Thinking', 0.90),
('History', '2.A.1.a', 'Reading Comprehension', 0.85),
('History', '2.A.1.c', 'Writing', 0.70);

-- Foreign Language maps to Active Learning + Communication
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Foreign Language', '2.A.2.b', 'Active Learning', 0.90),
('Foreign Language', '2.A.1.b', 'Active Listening', 0.85),
('Foreign Language', '2.A.1.d', 'Speaking', 0.80);

-- Business/Economics maps to Critical Thinking + Judgment
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Business', '2.B.4.e', 'Judgment and Decision Making', 0.90),
('Business', '2.A.2.a', 'Critical Thinking', 0.85),
('Business', '2.B.5.b', 'Management of Financial Resources', 0.80);

-- Art maps to (no direct O*NET skills for creativity, but we can use Active Learning)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Art', '2.A.2.b', 'Active Learning', 0.70),
('Art', '2.A.2.a', 'Critical Thinking', 0.60);

-- Music maps to Active Learning
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Music', '2.A.2.b', 'Active Learning', 0.75),
('Music', '2.A.2.c', 'Learning Strategies', 0.70);

-- Physical Education maps to Coordination
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Physical Education', '2.B.1.b', 'Coordination', 0.80),
('Physical Education', '2.A.2.d', 'Monitoring', 0.60);

-- Now Activities
-- Coding/Programming maps to Programming
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Coding/Programming', '2.B.3.e', 'Programming', 0.95),
('Coding/Programming', '2.B.4.g', 'Systems Analysis', 0.80),
('Coding/Programming', '2.B.2.i', 'Complex Problem Solving', 0.85),
('Coding/Programming', '2.A.1.e', 'Mathematics', 0.70);

-- Debate/Public Speaking maps to Speaking + Persuasion
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Debate', '2.A.1.d', 'Speaking', 0.95),
('Debate', '2.B.1.c', 'Persuasion', 0.90),
('Debate', '2.A.2.a', 'Critical Thinking', 0.85),
('Debate', '2.A.1.b', 'Active Listening', 0.75);

-- Community Service maps to Service Orientation
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Community Service', '2.B.1.f', 'Service Orientation', 0.95),
('Community Service', '2.B.1.a', 'Social Perceptiveness', 0.85),
('Community Service', '2.B.1.b', 'Coordination', 0.75);

-- Leadership/Student Government maps to Management + Coordination
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Leadership', '2.B.5.d', 'Management of Personnel Resources', 0.90),
('Leadership', '2.B.1.b', 'Coordination', 0.85),
('Leadership', '2.B.4.e', 'Judgment and Decision Making', 0.85),
('Leadership', '2.B.1.c', 'Persuasion', 0.80);

-- Sports/Athletics maps to Coordination
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Sports', '2.B.1.b', 'Coordination', 0.90),
('Sports', '2.A.2.d', 'Monitoring', 0.70),
('Sports', '2.B.5.a', 'Time Management', 0.65);

-- Creative Writing/Journalism maps to Writing
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Writing', '2.A.1.c', 'Writing', 0.95),
('Writing', '2.A.2.a', 'Critical Thinking', 0.80),
('Writing', '2.A.1.a', 'Reading Comprehension', 0.75);

-- Music Performance maps to Active Learning
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Music', '2.A.2.b', 'Active Learning', 0.85),
('Music', '2.A.2.c', 'Learning Strategies', 0.75),
('Music', '2.B.1.b', 'Coordination', 0.70);

-- Science Club/Lab Work maps to Science + Operations Analysis
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Science Club', '2.A.1.f', 'Science', 0.95),
('Science Club', '2.B.3.a', 'Operations Analysis', 0.85),
('Science Club', '2.A.2.a', 'Critical Thinking', 0.80),
('Science Club', '2.B.2.i', 'Complex Problem Solving', 0.75);

-- Tutoring/Teaching maps to Instructing
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Tutoring', '2.B.1.e', 'Instructing', 0.95),
('Tutoring', '2.B.1.a', 'Social Perceptiveness', 0.80),
('Tutoring', '2.A.1.d', 'Speaking', 0.75),
('Tutoring', '2.A.2.c', 'Learning Strategies', 0.75);

-- Building/Making Things maps to Technology Design + Installation
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Building/Making', '2.B.3.b', 'Technology Design', 0.90),
('Building/Making', '2.B.3.d', 'Installation', 0.85),
('Building/Making', '2.B.3.c', 'Equipment Selection', 0.80),
('Building/Making', '2.B.2.i', 'Complex Problem Solving', 0.70);

-- Fixing/Repairing Things maps to Repairing + Troubleshooting
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Fixing/Repairing', '2.B.3.l', 'Repairing', 0.95),
('Fixing/Repairing', '2.B.3.k', 'Troubleshooting', 0.90),
('Fixing/Repairing', '2.B.3.j', 'Equipment Maintenance', 0.85);

-- Working with Data/Analysis maps to Systems Analysis
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Data Analysis', '2.B.4.g', 'Systems Analysis', 0.90),
('Data Analysis', '2.A.1.e', 'Mathematics', 0.85),
('Data Analysis', '2.A.2.a', 'Critical Thinking', 0.85),
('Data Analysis', '2.B.2.i', 'Complex Problem Solving', 0.80);

-- Verify mappings
SELECT 'SUBJECT_SKILLS_MAPPING count:' AS INFO, COUNT(*) AS COUNT FROM SUBJECT_SKILLS_MAPPING;
SELECT 'ACTIVITY_SKILLS_MAPPING count:' AS INFO, COUNT(*) AS COUNT FROM ACTIVITY_SKILLS_MAPPING;

-- Check if Software Developer skills match our mappings now
SELECT 'Software Developer skills that match our Math mapping:' AS INFO;
SELECT DISTINCT
    sm.SUBJECT_NAME,
    sm.ONET_SKILL_ID,
    sm.SKILL_NAME,
    sf.DATA_VALUE AS IMPORTANCE_FOR_SOFTWARE_DEV
FROM SUBJECT_SKILLS_MAPPING sm
JOIN SKILLS_FACT sf ON sm.ONET_SKILL_ID = sf.ELEMENT_ID
WHERE sm.SUBJECT_NAME = 'Math'
  AND sf.ONET_SOC_CODE = '15-1252.00'
  AND sf.SCALE_ID = 'IM'
ORDER BY sf.DATA_VALUE DESC;

SELECT 'Software Developer skills that match our Computer Science mapping:' AS INFO;
SELECT DISTINCT
    sm.SUBJECT_NAME,
    sm.ONET_SKILL_ID,
    sm.SKILL_NAME,
    sf.DATA_VALUE AS IMPORTANCE_FOR_SOFTWARE_DEV
FROM SUBJECT_SKILLS_MAPPING sm
JOIN SKILLS_FACT sf ON sm.ONET_SKILL_ID = sf.ELEMENT_ID
WHERE sm.SUBJECT_NAME = 'Computer Science'
  AND sf.ONET_SOC_CODE = '15-1252.00'
  AND sf.SCALE_ID = 'IM'
ORDER BY sf.DATA_VALUE DESC;

SELECT 'Software Developer skills that match our Coding/Programming mapping:' AS INFO;
SELECT DISTINCT
    am.ACTIVITY_NAME,
    am.ONET_SKILL_ID,
    am.SKILL_NAME,
    sf.DATA_VALUE AS IMPORTANCE_FOR_SOFTWARE_DEV
FROM ACTIVITY_SKILLS_MAPPING am
JOIN SKILLS_FACT sf ON am.ONET_SKILL_ID = sf.ELEMENT_ID
WHERE am.ACTIVITY_NAME = 'Coding/Programming'
  AND sf.ONET_SOC_CODE = '15-1252.00'
  AND sf.SCALE_ID = 'IM'
ORDER BY sf.DATA_VALUE DESC;

-- =============================================
-- Expected Result: Should now see matches!
-- Math should match 2.A.1.e (Mathematics)
-- Computer Science should match 2.B.3.e (Programming), 2.B.4.g (Systems Analysis)
-- Coding should match 2.B.3.e (Programming)
-- =============================================
