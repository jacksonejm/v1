-- =============================================
-- Recipe D Step 2: Create Skills Mapping Tables
-- =============================================
-- Maps user's subjects and activities to O*NET skills
-- This allows us to build a "skills vector" for each user
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- Create SUBJECT_SKILLS_MAPPING table
-- =============================================

CREATE OR REPLACE TABLE SUBJECT_SKILLS_MAPPING (
    SUBJECT_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    SKILL_NAME VARCHAR(100),
    RELEVANCE_SCORE FLOAT  -- 0.0 to 1.0 (how strongly this subject indicates this skill)
);

-- =============================================
-- Populate SUBJECT_SKILLS_MAPPING
-- =============================================
-- Based on O*NET Skills taxonomy
-- Skill IDs from Skills.txt ELEMENT_ID column

INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
-- Math & Quantitative Subjects
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

-- Science Subjects
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

-- English & Language Arts
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

-- Social Studies
('History', '2.A.2.a', 'Reading Comprehension', 0.85),
('History', '2.B.1.a', 'Critical Thinking', 0.85),
('History', '2.A.2.c', 'Writing', 0.70),

('Government', '2.B.1.a', 'Critical Thinking', 0.85),
('Government', '2.A.2.a', 'Reading Comprehension', 0.80),
('Government', '2.B.2.a', 'Active Learning', 0.75),

('Economics', '2.A.1.a', 'Mathematics', 0.70),
('Economics', '2.B.1.a', 'Critical Thinking', 0.85),
('Economics', '2.A.2.a', 'Reading Comprehension', 0.75),

('Psychology', '2.B.1.a', 'Critical Thinking', 0.85),
('Psychology', '2.A.2.a', 'Reading Comprehension', 0.80),
('Psychology', '2.B.4.d', 'Social Perceptiveness', 0.80),

-- Arts
('Art', '2.B.3.a', 'Operations Analysis', 0.60),
('Art', '2.B.1.b', 'Active Thinking', 0.75),
('Art', '2.B.3.h', 'Judgment and Decision Making', 0.65),

('Music', '2.B.2.a', 'Active Learning', 0.75),
('Music', '2.A.2.b', 'Active Listening', 0.85),

('Drama', '2.A.2.d', 'Speaking', 0.90),
('Drama', '2.B.4.d', 'Social Perceptiveness', 0.80),
('Drama', '2.A.2.b', 'Active Listening', 0.75),

-- Foreign Language
('Foreign Language', '2.A.2.b', 'Active Listening', 0.85),
('Foreign Language', '2.A.2.d', 'Speaking', 0.85),
('Foreign Language', '2.A.2.a', 'Reading Comprehension', 0.80),
('Foreign Language', '2.A.2.c', 'Writing', 0.75),

-- Computer Science
('Computer Science', '2.B.3.b', 'Programming', 0.95),
('Computer Science', '2.A.1.a', 'Mathematics', 0.75),
('Computer Science', '2.B.1.a', 'Critical Thinking', 0.85),
('Computer Science', '2.B.3.c', 'Systems Analysis', 0.80),

-- Business
('Business', '2.B.1.a', 'Critical Thinking', 0.75),
('Business', '2.A.2.d', 'Speaking', 0.75),
('Business', '2.B.4.d', 'Social Perceptiveness', 0.70),
('Business', '2.B.3.h', 'Judgment and Decision Making', 0.80);

-- =============================================
-- Create ACTIVITY_SKILLS_MAPPING table
-- =============================================

CREATE OR REPLACE TABLE ACTIVITY_SKILLS_MAPPING (
    ACTIVITY_NAME VARCHAR(100),
    ONET_SKILL_ID VARCHAR(20),
    SKILL_NAME VARCHAR(100),
    RELEVANCE_SCORE FLOAT
);

-- =============================================
-- Populate ACTIVITY_SKILLS_MAPPING
-- =============================================

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
-- Sports & Physical Activities
('Sports', '2.B.4.e', 'Coordination', 0.85),
('Sports', '2.B.4.g', 'Time Management', 0.70),
('Sports', '2.B.4.d', 'Social Perceptiveness', 0.65),

-- Performing Arts
('Drama/Theater', '2.A.2.d', 'Speaking', 0.90),
('Drama/Theater', '2.B.4.d', 'Social Perceptiveness', 0.85),
('Drama/Theater', '2.A.2.b', 'Active Listening', 0.75),

('Music', '2.B.2.a', 'Active Learning', 0.80),
('Music', '2.A.2.b', 'Active Listening', 0.85),
('Music', '2.B.4.e', 'Coordination', 0.75),

('Visual Arts', '2.B.1.b', 'Active Thinking', 0.80),
('Visual Arts', '2.B.3.a', 'Operations Analysis', 0.65),

('Dance', '2.B.4.e', 'Coordination', 0.90),
('Dance', '2.B.2.a', 'Active Learning', 0.70),

-- Academic & Leadership
('Debate', '2.B.1.a', 'Critical Thinking', 0.90),
('Debate', '2.A.2.d', 'Speaking', 0.90),
('Debate', '2.B.4.c', 'Persuasion', 0.85),
('Debate', '2.A.2.b', 'Active Listening', 0.75),

('Academic Clubs', '2.B.2.a', 'Active Learning', 0.85),
('Academic Clubs', '2.B.1.a', 'Critical Thinking', 0.80),
('Academic Clubs', '2.A.2.a', 'Reading Comprehension', 0.75),

('Science Club', '2.A.1.b', 'Science', 0.85),
('Science Club', '2.B.1.a', 'Critical Thinking', 0.80),
('Science Club', '2.B.2.a', 'Active Learning', 0.80),

('Math Club', '2.A.1.a', 'Mathematics', 0.90),
('Math Club', '2.B.1.a', 'Critical Thinking', 0.80),

-- Service & Helping
('Volunteering', '2.B.4.d', 'Social Perceptiveness', 0.85),
('Volunteering', '2.B.4.b', 'Service Orientation', 0.90),
('Volunteering', '2.A.2.b', 'Active Listening', 0.75),

('Community Service', '2.B.4.b', 'Service Orientation', 0.90),
('Community Service', '2.B.4.d', 'Social Perceptiveness', 0.80),
('Community Service', '2.B.4.e', 'Coordination', 0.70),

-- Leadership
('Student Government', '2.B.4.d', 'Social Perceptiveness', 0.85),
('Student Government', '2.A.2.d', 'Speaking', 0.80),
('Student Government', '2.B.4.c', 'Persuasion', 0.80),
('Student Government', '2.B.4.g', 'Time Management', 0.75),

-- Technical & STEM
('Coding/Programming', '2.B.3.b', 'Programming', 0.95),
('Coding/Programming', '2.B.1.a', 'Critical Thinking', 0.85),
('Coding/Programming', '2.B.3.c', 'Systems Analysis', 0.75),

('Robotics', '2.B.3.b', 'Programming', 0.85),
('Robotics', '2.A.1.a', 'Mathematics', 0.75),
('Robotics', '2.B.3.c', 'Systems Analysis', 0.80),
('Robotics', '2.B.3.f', 'Equipment Selection', 0.70),

-- Media & Communication
('Journalism', '2.A.2.c', 'Writing', 0.95),
('Journalism', '2.A.2.a', 'Reading Comprehension', 0.85),
('Journalism', '2.A.2.b', 'Active Listening', 0.80),
('Journalism', '2.B.1.a', 'Critical Thinking', 0.80),

('Yearbook', '2.A.2.c', 'Writing', 0.75),
('Yearbook', '2.B.4.e', 'Coordination', 0.75),
('Yearbook', '2.B.4.g', 'Time Management', 0.80),

-- Other
('Gaming', '2.B.1.a', 'Critical Thinking', 0.65),
('Gaming', '2.B.3.h', 'Judgment and Decision Making', 0.70),

('Reading', '2.A.2.a', 'Reading Comprehension', 0.90),
('Reading', '2.B.2.a', 'Active Learning', 0.75),
('Reading', '2.B.1.a', 'Critical Thinking', 0.70);

-- =============================================
-- Verify mappings
-- =============================================

-- Check subject mappings
SELECT
    SUBJECT_NAME,
    COUNT(*) AS NUM_SKILLS_MAPPED,
    ROUND(AVG(RELEVANCE_SCORE), 2) AS AVG_RELEVANCE
FROM SUBJECT_SKILLS_MAPPING
GROUP BY SUBJECT_NAME
ORDER BY SUBJECT_NAME;

-- Check activity mappings
SELECT
    ACTIVITY_NAME,
    COUNT(*) AS NUM_SKILLS_MAPPED,
    ROUND(AVG(RELEVANCE_SCORE), 2) AS AVG_RELEVANCE
FROM ACTIVITY_SKILLS_MAPPING
GROUP BY ACTIVITY_NAME
ORDER BY ACTIVITY_NAME;

-- Show example: What skills does "Math + Coding" indicate?
SELECT DISTINCT
    SKILL_NAME,
    MAX(RELEVANCE_SCORE) AS MAX_RELEVANCE,
    LISTAGG(DISTINCT SOURCE_TYPE, ', ') AS SOURCES
FROM (
    SELECT SKILL_NAME, RELEVANCE_SCORE, 'Subject: Math' AS SOURCE_TYPE
    FROM SUBJECT_SKILLS_MAPPING
    WHERE SUBJECT_NAME = 'Math'

    UNION ALL

    SELECT SKILL_NAME, RELEVANCE_SCORE, 'Activity: Coding' AS SOURCE_TYPE
    FROM ACTIVITY_SKILLS_MAPPING
    WHERE ACTIVITY_NAME = 'Coding/Programming'
)
GROUP BY SKILL_NAME
ORDER BY MAX_RELEVANCE DESC;

-- =============================================
-- SUCCESS CRITERIA
-- =============================================
-- ✅ SUBJECT_SKILLS_MAPPING created with 50+ mappings
-- ✅ ACTIVITY_SKILLS_MAPPING created with 50+ mappings
-- ✅ Each subject/activity maps to 1-5 relevant O*NET skills
-- ✅ Relevance scores between 0.6 and 0.95 (realistic ranges)
-- ✅ Sample queries return expected skill overlaps
-- =============================================
