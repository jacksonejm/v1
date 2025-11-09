USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Fix Mapping Tables to Match Actual App Names
-- =============================================
-- The app uses different names than the mapping tables!
-- This script adds/updates mappings for the ACTUAL app subjects/activities
-- =============================================

-- =============================================
-- ADD MISSING SUBJECT: "Technology"
-- =============================================

INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Technology', '2.B.3.e', 'Programming', 0.90),
('Technology', '2.B.3.b', 'Technology Design', 0.85),
('Technology', '2.B.4.g', 'Systems Analysis', 0.80),
('Technology', '2.A.2.a', 'Critical Thinking', 0.75),
('Technology', '2.B.2.i', 'Complex Problem Solving', 0.75);

-- =============================================
-- FIX ACTIVITY NAMES TO MATCH APP
-- =============================================
-- App has: "Robotics Club", "Drama or Theatre", "Sports", "Debate Team", "Music or Band"
-- But mappings have: "Robotics", "Theater/Drama", "Team Sports", "Debate", "Music Performance"

-- Add "Robotics Club" (currently have "Robotics")
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Robotics Club', '2.B.3.e', 'Programming', 0.85),
('Robotics Club', '2.B.3.b', 'Technology Design', 0.90),
('Robotics Club', '2.B.3.c', 'Equipment Selection', 0.80),
('Robotics Club', '2.B.3.d', 'Installation', 0.75),
('Robotics Club', '2.A.1.e', 'Mathematics', 0.75);

-- Add "Drama or Theatre" (currently have "Theater/Drama")
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Drama or Theatre', '2.A.1.d', 'Speaking', 0.95),
('Drama or Theatre', '2.A.2.b', 'Active Learning', 0.85),
('Drama or Theatre', '2.B.1.a', 'Social Perceptiveness', 0.85);

-- Add "Sports" (currently have "Team Sports")
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Sports', '2.B.1.b', 'Coordination', 0.95),
('Sports', '2.A.2.d', 'Monitoring', 0.70),
('Sports', '2.B.5.a', 'Time Management', 0.65);

-- Add "Debate Team" (currently have "Debate")
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Debate Team', '2.A.1.d', 'Speaking', 0.95),
('Debate Team', '2.B.1.c', 'Persuasion', 0.90),
('Debate Team', '2.A.2.a', 'Critical Thinking', 0.90),
('Debate Team', '2.A.1.b', 'Active Listening', 0.80),
('Debate Team', '2.A.1.a', 'Reading Comprehension', 0.75);

-- Add "Music or Band" (currently have "Music Performance")
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Music or Band', '2.A.2.b', 'Active Learning', 0.90),
('Music or Band', '2.A.2.c', 'Learning Strategies', 0.80),
('Music or Band', '2.B.1.b', 'Coordination', 0.80);

-- =============================================
-- Verification: Check All App Subjects Are Mapped
-- =============================================

SELECT '=============================================' AS SEPARATOR;
SELECT 'Verification: App Subjects Coverage' AS REPORT;
SELECT '=============================================' AS SEPARATOR;

SELECT 'Checking if all app subjects are mapped:' AS INFO;

-- Create a temp table with app subjects
CREATE OR REPLACE TEMPORARY TABLE APP_SUBJECTS (SUBJECT_NAME VARCHAR(100));
INSERT INTO APP_SUBJECTS VALUES
('Math'),
('Science'),
('Art'),
('History'),
('English'),
('Technology'),
('Physical Education'),
('Other');

-- Check which app subjects are mapped
SELECT
    app.SUBJECT_NAME,
    CASE
        WHEN ssm.SUBJECT_NAME IS NOT NULL THEN '✅ Mapped'
        ELSE '❌ NOT MAPPED'
    END AS STATUS,
    COUNT(DISTINCT ssm.ONET_SKILL_ID) AS NUM_SKILLS_MAPPED
FROM APP_SUBJECTS app
LEFT JOIN SUBJECT_SKILLS_MAPPING ssm ON app.SUBJECT_NAME = ssm.SUBJECT_NAME
GROUP BY app.SUBJECT_NAME, ssm.SUBJECT_NAME
ORDER BY app.SUBJECT_NAME;

-- =============================================
-- Verification: Check All App Activities Are Mapped
-- =============================================

SELECT '=============================================' AS SEPARATOR;
SELECT 'Verification: App Activities Coverage' AS REPORT;
SELECT '=============================================' AS SEPARATOR;

SELECT 'Checking if all app activities are mapped:' AS INFO;

-- Create a temp table with app activities
CREATE OR REPLACE TEMPORARY TABLE APP_ACTIVITIES (ACTIVITY_NAME VARCHAR(100));
INSERT INTO APP_ACTIVITIES VALUES
('Robotics Club'),
('Drama or Theatre'),
('Sports'),
('Debate Team'),
('Volunteering'),
('Music or Band'),
('Other');

-- Check which app activities are mapped
SELECT
    app.ACTIVITY_NAME,
    CASE
        WHEN asm.ACTIVITY_NAME IS NOT NULL THEN '✅ Mapped'
        ELSE '❌ NOT MAPPED'
    END AS STATUS,
    COUNT(DISTINCT asm.ONET_SKILL_ID) AS NUM_SKILLS_MAPPED
FROM APP_ACTIVITIES app
LEFT JOIN ACTIVITY_SKILLS_MAPPING asm ON app.ACTIVITY_NAME = asm.ACTIVITY_NAME
GROUP BY app.ACTIVITY_NAME, asm.ACTIVITY_NAME
ORDER BY app.ACTIVITY_NAME;

-- =============================================
-- Test with Actual App Data
-- =============================================

SELECT '=============================================' AS SEPARATOR;
SELECT 'Test: STEM Student with App Subjects/Activities' AS TEST;
SELECT '=============================================' AS SEPARATOR;

-- This simulates what a real student might select in the app:
-- Subjects: Math, Science, Technology
-- Activities: Robotics Club, Debate Team
CALL SP_GET_CAREER_MATCHES_V4(
    -- RIASEC: High Investigative
    2.0, 5.0, 2.5, 3.0, 3.0, 4.0,
    -- Work Values
    5.0, 5.0, 3.0, 2.5, 2.5, 3.5,
    -- Subjects: Using EXACT app names
    '["Math", "Science", "Technology"]',
    -- Activities: Using EXACT app names
    '["Robotics Club", "Debate Team"]',
    -- Career Interests
    '["Software Developer"]',
    'Undergraduate',
    'Student'
);

-- =============================================
-- Expected Results:
-- - All app subjects should show "✅ Mapped"
-- - All app activities should show "✅ Mapped"
-- - Software Developer should have SKILLS_MATCH > 40%
-- =============================================
