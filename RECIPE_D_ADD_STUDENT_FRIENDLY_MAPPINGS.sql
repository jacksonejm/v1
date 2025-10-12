USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Add Student-Friendly Subject/Activity Mappings
-- =============================================
-- Uses language high school/college students actually use
-- Maps to existing formal O*NET skill mappings
-- =============================================

-- =============================================
-- NEW SUBJECTS (5 additions)
-- =============================================

-- 1. Business/Economics (maps to existing "Business" mappings)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Business/Economics', '2.B.4.e', 'Judgment and Decision Making', 0.90),
('Business/Economics', '2.A.2.a', 'Critical Thinking', 0.85),
('Business/Economics', '2.B.5.b', 'Management of Financial Resources', 0.85),
('Business/Economics', '2.B.1.c', 'Persuasion', 0.75),
('Business/Economics', '2.A.1.e', 'Mathematics', 0.70);

-- 2. Computer Programming (maps to existing "Computer Science" mappings)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Computer Programming', '2.B.3.e', 'Programming', 0.95),
('Computer Programming', '2.B.4.g', 'Systems Analysis', 0.85),
('Computer Programming', '2.A.2.a', 'Critical Thinking', 0.85),
('Computer Programming', '2.A.1.e', 'Mathematics', 0.75),
('Computer Programming', '2.B.2.i', 'Complex Problem Solving', 0.80),
('Computer Programming', '2.B.3.b', 'Technology Design', 0.75);

-- 3. Psychology (already mapped, keep as-is)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Psychology', '2.B.1.a', 'Social Perceptiveness', 0.95),
('Psychology', '2.A.2.a', 'Critical Thinking', 0.85),
('Psychology', '2.A.1.a', 'Reading Comprehension', 0.80),
('Psychology', '2.A.2.b', 'Active Learning', 0.80);

-- 4. Biology (already mapped, keep as-is)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Biology', '2.A.1.f', 'Science', 0.95),
('Biology', '2.A.2.a', 'Critical Thinking', 0.80),
('Biology', '2.B.4.h', 'Systems Evaluation', 0.70);

-- 5. World Languages (maps to existing "Foreign Language" mappings)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('World Languages', '2.A.2.b', 'Active Learning', 0.90),
('World Languages', '2.A.1.b', 'Active Listening', 0.90),
('World Languages', '2.A.1.d', 'Speaking', 0.85),
('World Languages', '2.A.1.a', 'Reading Comprehension', 0.80),
('World Languages', '2.A.1.c', 'Writing', 0.80);

-- =============================================
-- NEW ACTIVITIES (5 additions)
-- =============================================

-- 1. Student Council (maps to existing "Student Government" mappings)
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Student Council', '2.B.5.d', 'Management of Personnel Resources', 0.95),
('Student Council', '2.B.1.b', 'Coordination', 0.90),
('Student Council', '2.B.4.e', 'Judgment and Decision Making', 0.90),
('Student Council', '2.B.1.c', 'Persuasion', 0.85),
('Student Council', '2.A.1.d', 'Speaking', 0.80);

-- 2. Business Club/DECA (maps to existing "Business Club/DECA" mappings)
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Business Club/DECA', '2.B.4.e', 'Judgment and Decision Making', 0.90),
('Business Club/DECA', '2.B.1.c', 'Persuasion', 0.85),
('Business Club/DECA', '2.A.2.a', 'Critical Thinking', 0.80);

-- 3. Auto Shop/Mechanics (maps to existing "Auto Repair/Mechanics" mappings)
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Auto Shop/Mechanics', '2.B.3.l', 'Repairing', 0.95),
('Auto Shop/Mechanics', '2.B.3.k', 'Troubleshooting', 0.95),
('Auto Shop/Mechanics', '2.B.3.j', 'Equipment Maintenance', 0.90),
('Auto Shop/Mechanics', '2.B.3.c', 'Equipment Selection', 0.75);

-- 4. Model UN (already mapped, keep as-is)
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Model UN', '2.B.1.d', 'Negotiation', 0.95),
('Model UN', '2.B.1.c', 'Persuasion', 0.90),
('Model UN', '2.A.1.d', 'Speaking', 0.85),
('Model UN', '2.A.2.a', 'Critical Thinking', 0.85),
('Model UN', '2.B.1.a', 'Social Perceptiveness', 0.80);

-- 5. Event Planning/School Events (maps to existing "Event Planning" mappings)
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Event Planning/School Events', '2.B.5.c', 'Management of Material Resources', 0.90),
('Event Planning/School Events', '2.B.1.b', 'Coordination', 0.90),
('Event Planning/School Events', '2.B.5.a', 'Time Management', 0.85),
('Event Planning/School Events', '2.B.5.b', 'Management of Financial Resources', 0.75);

-- =============================================
-- Verification: Check All App Subjects/Activities
-- =============================================

SELECT '=============================================' AS SEPARATOR;
SELECT 'Final Coverage Check' AS REPORT;
SELECT '=============================================' AS SEPARATOR;

-- All subjects in the app (13 total)
CREATE OR REPLACE TEMPORARY TABLE FINAL_APP_SUBJECTS (SUBJECT_NAME VARCHAR(100));
INSERT INTO FINAL_APP_SUBJECTS VALUES
-- Original 8
('Math'),
('Science'),
('Art'),
('History'),
('English'),
('Technology'),
('Physical Education'),
('Other'),
-- New 5
('Business/Economics'),
('Computer Programming'),
('Psychology'),
('Biology'),
('World Languages');

SELECT 'App Subjects Coverage (13 total):' AS INFO;
SELECT
    app.SUBJECT_NAME,
    CASE
        WHEN ssm.SUBJECT_NAME IS NOT NULL THEN '✅ Mapped'
        ELSE '❌ NOT MAPPED'
    END AS STATUS,
    COUNT(DISTINCT ssm.ONET_SKILL_ID) AS NUM_SKILLS
FROM FINAL_APP_SUBJECTS app
LEFT JOIN SUBJECT_SKILLS_MAPPING ssm ON app.SUBJECT_NAME = ssm.SUBJECT_NAME
GROUP BY app.SUBJECT_NAME, ssm.SUBJECT_NAME
ORDER BY app.SUBJECT_NAME;

-- All activities in the app (12 total)
CREATE OR REPLACE TEMPORARY TABLE FINAL_APP_ACTIVITIES (ACTIVITY_NAME VARCHAR(100));
INSERT INTO FINAL_APP_ACTIVITIES VALUES
-- Original 7
('Robotics Club'),
('Drama or Theatre'),
('Sports'),
('Debate Team'),
('Volunteering'),
('Music or Band'),
('Other'),
-- New 5
('Student Council'),
('Business Club/DECA'),
('Auto Shop/Mechanics'),
('Model UN'),
('Event Planning/School Events');

SELECT 'App Activities Coverage (12 total):' AS INFO;
SELECT
    app.ACTIVITY_NAME,
    CASE
        WHEN asm.ACTIVITY_NAME IS NOT NULL THEN '✅ Mapped'
        ELSE '❌ NOT MAPPED'
    END AS STATUS,
    COUNT(DISTINCT asm.ONET_SKILL_ID) AS NUM_SKILLS
FROM FINAL_APP_ACTIVITIES app
LEFT JOIN ACTIVITY_SKILLS_MAPPING asm ON app.ACTIVITY_NAME = asm.ACTIVITY_NAME
GROUP BY app.ACTIVITY_NAME, asm.ACTIVITY_NAME
ORDER BY app.ACTIVITY_NAME;

-- Overall skills coverage
SELECT '=============================================' AS SEPARATOR;
SELECT 'O*NET Skills Coverage Summary' AS REPORT;
SELECT '=============================================' AS SEPARATOR;

SELECT
    COUNT(DISTINCT sf.ELEMENT_ID) AS TOTAL_ONET_SKILLS,
    COUNT(DISTINCT COALESCE(ssm.ONET_SKILL_ID, asm.ONET_SKILL_ID)) AS COVERED_SKILLS,
    ROUND(COUNT(DISTINCT COALESCE(ssm.ONET_SKILL_ID, asm.ONET_SKILL_ID)) * 100.0 / COUNT(DISTINCT sf.ELEMENT_ID), 1) AS COVERAGE_PERCENTAGE
FROM (
    SELECT DISTINCT ELEMENT_ID FROM SKILLS_FACT WHERE SCALE_ID = 'IM'
) sf
LEFT JOIN SUBJECT_SKILLS_MAPPING ssm ON sf.ELEMENT_ID = ssm.ONET_SKILL_ID
LEFT JOIN ACTIVITY_SKILLS_MAPPING asm ON sf.ELEMENT_ID = asm.ONET_SKILL_ID;

-- Test with business student profile
SELECT '=============================================' AS SEPARATOR;
SELECT 'Test: Business Student Profile' AS TEST;
SELECT '=============================================' AS SEPARATOR;

CALL SP_GET_CAREER_MATCHES_V4(
    -- RIASEC: High Enterprising (E) and Conventional (C)
    2.0, 3.0, 2.0, 3.5, 5.0, 4.5,
    -- Work Values: Achievement, Independence
    5.0, 4.5, 4.0, 3.0, 3.0, 3.5,
    -- Subjects: Business student
    '["Business/Economics", "Math", "Psychology"]',
    -- Activities: Leadership and business
    '["Student Council", "Business Club/DECA", "Debate Team"]',
    -- Career Interests
    '["Marketing Manager", "Financial Analyst"]',
    'Undergraduate',
    'Student'
);

-- =============================================
-- Expected Results:
-- - All 13 subjects should show "✅ Mapped"
-- - All 12 activities should show "✅ Mapped"
-- - Coverage should be ~90-95%
-- - Business careers should have SKILLS_MATCH 50-70%
-- =============================================
