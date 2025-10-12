USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Recipe D v4.0 - COMPLETE Mapping Tables
-- =============================================
-- Maps ALL 35 O*NET skills to user-friendly subjects/activities
-- Even if not in app yet, we cover all skills for future expansion
-- =============================================

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

-- =============================================
-- SUBJECTS MAPPING (Academic Subjects)
-- =============================================

-- Math
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Math', '2.A.1.e', 'Mathematics', 0.95),
('Math', '2.A.2.a', 'Critical Thinking', 0.75),
('Math', '2.B.2.i', 'Complex Problem Solving', 0.70);

-- Science (General)
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Science', '2.A.1.f', 'Science', 0.95),
('Science', '2.A.2.a', 'Critical Thinking', 0.80),
('Science', '2.A.2.b', 'Active Learning', 0.75),
('Science', '2.B.3.a', 'Operations Analysis', 0.70);

-- Biology
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Biology', '2.A.1.f', 'Science', 0.95),
('Biology', '2.A.2.a', 'Critical Thinking', 0.80),
('Biology', '2.B.4.h', 'Systems Evaluation', 0.70);

-- Chemistry
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Chemistry', '2.A.1.f', 'Science', 0.95),
('Chemistry', '2.A.1.e', 'Mathematics', 0.75),
('Chemistry', '2.B.3.a', 'Operations Analysis', 0.85);

-- Physics
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Physics', '2.A.1.f', 'Science', 0.95),
('Physics', '2.A.1.e', 'Mathematics', 0.90),
('Physics', '2.B.4.g', 'Systems Analysis', 0.80),
('Physics', '2.B.2.i', 'Complex Problem Solving', 0.80);

-- Computer Science
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Computer Science', '2.B.3.e', 'Programming', 0.95),
('Computer Science', '2.B.4.g', 'Systems Analysis', 0.85),
('Computer Science', '2.A.2.a', 'Critical Thinking', 0.85),
('Computer Science', '2.A.1.e', 'Mathematics', 0.75),
('Computer Science', '2.B.2.i', 'Complex Problem Solving', 0.80),
('Computer Science', '2.B.3.b', 'Technology Design', 0.75);

-- Engineering
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Engineering', '2.B.3.b', 'Technology Design', 0.95),
('Engineering', '2.B.4.g', 'Systems Analysis', 0.90),
('Engineering', '2.A.1.e', 'Mathematics', 0.85),
('Engineering', '2.A.1.f', 'Science', 0.85),
('Engineering', '2.B.2.i', 'Complex Problem Solving', 0.85),
('Engineering', '2.B.3.a', 'Operations Analysis', 0.80);

-- English/Literature
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('English', '2.A.1.c', 'Writing', 0.95),
('English', '2.A.1.a', 'Reading Comprehension', 0.95),
('English', '2.A.2.a', 'Critical Thinking', 0.80),
('English', '2.A.1.b', 'Active Listening', 0.70);

-- History/Social Studies
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('History', '2.A.2.a', 'Critical Thinking', 0.90),
('History', '2.A.1.a', 'Reading Comprehension', 0.90),
('History', '2.A.1.c', 'Writing', 0.75),
('History', '2.A.2.b', 'Active Learning', 0.75);

-- Geography
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Geography', '2.A.1.a', 'Reading Comprehension', 0.85),
('Geography', '2.A.2.a', 'Critical Thinking', 0.75),
('Geography', '2.B.4.g', 'Systems Analysis', 0.65);

-- Psychology
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Psychology', '2.B.1.a', 'Social Perceptiveness', 0.95),
('Psychology', '2.A.2.a', 'Critical Thinking', 0.85),
('Psychology', '2.A.1.a', 'Reading Comprehension', 0.80),
('Psychology', '2.A.2.b', 'Active Learning', 0.80);

-- Sociology
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Sociology', '2.B.1.a', 'Social Perceptiveness', 0.90),
('Sociology', '2.A.2.a', 'Critical Thinking', 0.85),
('Sociology', '2.A.1.a', 'Reading Comprehension', 0.80);

-- Foreign Language
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Foreign Language', '2.A.2.b', 'Active Learning', 0.90),
('Foreign Language', '2.A.1.b', 'Active Listening', 0.90),
('Foreign Language', '2.A.1.d', 'Speaking', 0.85),
('Foreign Language', '2.A.1.a', 'Reading Comprehension', 0.80),
('Foreign Language', '2.A.1.c', 'Writing', 0.80);

-- Business/Economics
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Business', '2.B.4.e', 'Judgment and Decision Making', 0.90),
('Business', '2.A.2.a', 'Critical Thinking', 0.85),
('Business', '2.B.5.b', 'Management of Financial Resources', 0.85),
('Business', '2.B.1.c', 'Persuasion', 0.75),
('Business', '2.A.1.e', 'Mathematics', 0.70);

-- Accounting/Finance
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Accounting', '2.B.5.b', 'Management of Financial Resources', 0.95),
('Accounting', '2.A.1.e', 'Mathematics', 0.90),
('Accounting', '2.A.2.a', 'Critical Thinking', 0.80),
('Accounting', '2.A.2.d', 'Monitoring', 0.75);

-- Marketing
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Marketing', '2.B.1.c', 'Persuasion', 0.95),
('Marketing', '2.A.2.a', 'Critical Thinking', 0.80),
('Marketing', '2.B.1.a', 'Social Perceptiveness', 0.80),
('Marketing', '2.A.1.c', 'Writing', 0.75);

-- Art/Visual Arts
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Art', '2.A.2.b', 'Active Learning', 0.75),
('Art', '2.A.2.a', 'Critical Thinking', 0.65),
('Art', '2.B.3.b', 'Technology Design', 0.60);

-- Music
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Music', '2.A.2.b', 'Active Learning', 0.80),
('Music', '2.A.2.c', 'Learning Strategies', 0.75),
('Music', '2.B.1.b', 'Coordination', 0.70);

-- Drama/Theater
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Drama', '2.A.1.d', 'Speaking', 0.95),
('Drama', '2.A.2.b', 'Active Learning', 0.80),
('Drama', '2.B.1.a', 'Social Perceptiveness', 0.80),
('Drama', '2.A.1.a', 'Reading Comprehension', 0.75);

-- Physical Education
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Physical Education', '2.B.1.b', 'Coordination', 0.90),
('Physical Education', '2.A.2.d', 'Monitoring', 0.70),
('Physical Education', '2.B.1.e', 'Instructing', 0.65);

-- Health/Nursing
INSERT INTO SUBJECT_SKILLS_MAPPING VALUES
('Health', '2.B.1.f', 'Service Orientation', 0.90),
('Health', '2.A.1.f', 'Science', 0.85),
('Health', '2.B.1.a', 'Social Perceptiveness', 0.80),
('Health', '2.A.2.d', 'Monitoring', 0.80);

-- =============================================
-- ACTIVITIES MAPPING (Extracurriculars)
-- =============================================

-- Technology/Programming Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Coding/Programming', '2.B.3.e', 'Programming', 0.95),
('Coding/Programming', '2.B.4.g', 'Systems Analysis', 0.85),
('Coding/Programming', '2.B.2.i', 'Complex Problem Solving', 0.85),
('Coding/Programming', '2.A.1.e', 'Mathematics', 0.75),
('Coding/Programming', '2.A.2.a', 'Critical Thinking', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Web Design', '2.B.3.e', 'Programming', 0.80),
('Web Design', '2.B.3.b', 'Technology Design', 0.90),
('Web Design', '2.A.2.a', 'Critical Thinking', 0.70);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('App Development', '2.B.3.e', 'Programming', 0.95),
('App Development', '2.B.3.b', 'Technology Design', 0.90),
('App Development', '2.B.4.g', 'Systems Analysis', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Robotics', '2.B.3.e', 'Programming', 0.85),
('Robotics', '2.B.3.b', 'Technology Design', 0.90),
('Robotics', '2.B.3.c', 'Equipment Selection', 0.80),
('Robotics', '2.B.3.d', 'Installation', 0.75),
('Robotics', '2.A.1.e', 'Mathematics', 0.75);

-- Communication/Speaking Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Debate', '2.A.1.d', 'Speaking', 0.95),
('Debate', '2.B.1.c', 'Persuasion', 0.90),
('Debate', '2.A.2.a', 'Critical Thinking', 0.90),
('Debate', '2.A.1.b', 'Active Listening', 0.80),
('Debate', '2.A.1.a', 'Reading Comprehension', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Public Speaking', '2.A.1.d', 'Speaking', 0.95),
('Public Speaking', '2.B.1.c', 'Persuasion', 0.85),
('Public Speaking', '2.A.1.b', 'Active Listening', 0.70);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Podcasting/Broadcasting', '2.A.1.d', 'Speaking', 0.90),
('Podcasting/Broadcasting', '2.A.1.c', 'Writing', 0.75),
('Podcasting/Broadcasting', '2.A.1.b', 'Active Listening', 0.80);

-- Leadership Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Student Government', '2.B.5.d', 'Management of Personnel Resources', 0.95),
('Student Government', '2.B.1.b', 'Coordination', 0.90),
('Student Government', '2.B.4.e', 'Judgment and Decision Making', 0.90),
('Student Government', '2.B.1.c', 'Persuasion', 0.85),
('Student Government', '2.A.1.d', 'Speaking', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Club President/Officer', '2.B.5.d', 'Management of Personnel Resources', 0.90),
('Club President/Officer', '2.B.1.b', 'Coordination', 0.90),
('Club President/Officer', '2.B.5.a', 'Time Management', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Team Captain', '2.B.5.d', 'Management of Personnel Resources', 0.85),
('Team Captain', '2.B.1.b', 'Coordination', 0.90),
('Team Captain', '2.A.2.d', 'Monitoring', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Event Planning', '2.B.5.c', 'Management of Material Resources', 0.90),
('Event Planning', '2.B.1.b', 'Coordination', 0.90),
('Event Planning', '2.B.5.a', 'Time Management', 0.85),
('Event Planning', '2.B.5.b', 'Management of Financial Resources', 0.75);

-- Service/Helping Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Community Service', '2.B.1.f', 'Service Orientation', 0.95),
('Community Service', '2.B.1.a', 'Social Perceptiveness', 0.85),
('Community Service', '2.B.1.b', 'Coordination', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Volunteering', '2.B.1.f', 'Service Orientation', 0.95),
('Volunteering', '2.B.1.a', 'Social Perceptiveness', 0.80),
('Volunteering', '2.B.1.b', 'Coordination', 0.70);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Tutoring', '2.B.1.e', 'Instructing', 0.95),
('Tutoring', '2.B.1.a', 'Social Perceptiveness', 0.85),
('Tutoring', '2.A.1.d', 'Speaking', 0.80),
('Tutoring', '2.A.2.c', 'Learning Strategies', 0.80),
('Tutoring', '2.A.1.b', 'Active Listening', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Peer Counseling', '2.B.1.a', 'Social Perceptiveness', 0.95),
('Peer Counseling', '2.A.1.b', 'Active Listening', 0.95),
('Peer Counseling', '2.B.1.f', 'Service Orientation', 0.85),
('Peer Counseling', '2.A.1.d', 'Speaking', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Mentoring', '2.B.1.e', 'Instructing', 0.90),
('Mentoring', '2.B.1.a', 'Social Perceptiveness', 0.90),
('Mentoring', '2.A.1.b', 'Active Listening', 0.85);

-- Sports/Physical Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Team Sports', '2.B.1.b', 'Coordination', 0.95),
('Team Sports', '2.A.2.d', 'Monitoring', 0.70),
('Team Sports', '2.B.5.a', 'Time Management', 0.65);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Individual Sports', '2.A.2.d', 'Monitoring', 0.80),
('Individual Sports', '2.B.1.b', 'Coordination', 0.85),
('Individual Sports', '2.B.5.a', 'Time Management', 0.70);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Coaching', '2.B.1.e', 'Instructing', 0.95),
('Coaching', '2.A.2.d', 'Monitoring', 0.85),
('Coaching', '2.B.1.a', 'Social Perceptiveness', 0.80);

-- Creative/Arts Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Creative Writing', '2.A.1.c', 'Writing', 0.95),
('Creative Writing', '2.A.2.a', 'Critical Thinking', 0.80),
('Creative Writing', '2.A.1.a', 'Reading Comprehension', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Journalism/Newspaper', '2.A.1.c', 'Writing', 0.95),
('Journalism/Newspaper', '2.A.1.b', 'Active Listening', 0.85),
('Journalism/Newspaper', '2.A.2.a', 'Critical Thinking', 0.85),
('Journalism/Newspaper', '2.A.1.a', 'Reading Comprehension', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Yearbook/Photography', '2.A.2.a', 'Critical Thinking', 0.75),
('Yearbook/Photography', '2.B.5.a', 'Time Management', 0.70),
('Yearbook/Photography', '2.B.1.b', 'Coordination', 0.70);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Theater/Drama', '2.A.1.d', 'Speaking', 0.95),
('Theater/Drama', '2.A.2.b', 'Active Learning', 0.85),
('Theater/Drama', '2.B.1.a', 'Social Perceptiveness', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Music Performance', '2.A.2.b', 'Active Learning', 0.90),
('Music Performance', '2.A.2.c', 'Learning Strategies', 0.80),
('Music Performance', '2.B.1.b', 'Coordination', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Dance', '2.B.1.b', 'Coordination', 0.95),
('Dance', '2.A.2.b', 'Active Learning', 0.80),
('Dance', '2.A.2.d', 'Monitoring', 0.70);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Art/Painting', '2.A.2.b', 'Active Learning', 0.80),
('Art/Painting', '2.A.2.a', 'Critical Thinking', 0.70);

-- STEM Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Science Club', '2.A.1.f', 'Science', 0.95),
('Science Club', '2.B.3.a', 'Operations Analysis', 0.85),
('Science Club', '2.A.2.a', 'Critical Thinking', 0.85),
('Science Club', '2.B.2.i', 'Complex Problem Solving', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Math Club', '2.A.1.e', 'Mathematics', 0.95),
('Math Club', '2.A.2.a', 'Critical Thinking', 0.90),
('Math Club', '2.B.2.i', 'Complex Problem Solving', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Science Fair', '2.A.1.f', 'Science', 0.95),
('Science Fair', '2.B.3.a', 'Operations Analysis', 0.90),
('Science Fair', '2.A.2.a', 'Critical Thinking', 0.85),
('Science Fair', '2.B.4.g', 'Systems Analysis', 0.75);

-- Technical/Hands-On Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Building/Construction', '2.B.3.d', 'Installation', 0.90),
('Building/Construction', '2.B.3.c', 'Equipment Selection', 0.85),
('Building/Construction', '2.B.3.b', 'Technology Design', 0.80),
('Building/Construction', '2.A.1.e', 'Mathematics', 0.70);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Auto Repair/Mechanics', '2.B.3.l', 'Repairing', 0.95),
('Auto Repair/Mechanics', '2.B.3.k', 'Troubleshooting', 0.95),
('Auto Repair/Mechanics', '2.B.3.j', 'Equipment Maintenance', 0.90),
('Auto Repair/Mechanics', '2.B.3.c', 'Equipment Selection', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Electronics/Electrical Work', '2.B.3.l', 'Repairing', 0.90),
('Electronics/Electrical Work', '2.B.3.k', 'Troubleshooting', 0.95),
('Electronics/Electrical Work', '2.B.3.d', 'Installation', 0.85),
('Electronics/Electrical Work', '2.A.1.f', 'Science', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Woodworking/Crafts', '2.B.3.c', 'Equipment Selection', 0.85),
('Woodworking/Crafts', '2.B.3.h', 'Operation and Control', 0.90),
('Woodworking/Crafts', '2.B.3.b', 'Technology Design', 0.75);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Machinery Operation', '2.B.3.h', 'Operation and Control', 0.95),
('Machinery Operation', '2.B.3.g', 'Operations Monitoring', 0.90),
('Machinery Operation', '2.A.2.d', 'Monitoring', 0.85),
('Machinery Operation', '2.B.3.j', 'Equipment Maintenance', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Quality Control/Inspection', '2.B.3.m', 'Quality Control Analysis', 0.95),
('Quality Control/Inspection', '2.A.2.d', 'Monitoring', 0.90),
('Quality Control/Inspection', '2.A.2.a', 'Critical Thinking', 0.80);

-- Business/Financial Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Business Club/DECA', '2.B.4.e', 'Judgment and Decision Making', 0.90),
('Business Club/DECA', '2.B.1.c', 'Persuasion', 0.85),
('Business Club/DECA', '2.A.2.a', 'Critical Thinking', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Investment Club', '2.B.5.b', 'Management of Financial Resources', 0.95),
('Investment Club', '2.A.2.a', 'Critical Thinking', 0.90),
('Investment Club', '2.A.1.e', 'Mathematics', 0.80),
('Investment Club', '2.B.4.e', 'Judgment and Decision Making', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Entrepreneurship', '2.B.4.e', 'Judgment and Decision Making', 0.95),
('Entrepreneurship', '2.B.5.b', 'Management of Financial Resources', 0.85),
('Entrepreneurship', '2.B.1.c', 'Persuasion', 0.85),
('Entrepreneurship', '2.A.2.a', 'Critical Thinking', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Sales/Marketing', '2.B.1.c', 'Persuasion', 0.95),
('Sales/Marketing', '2.B.1.a', 'Social Perceptiveness', 0.85),
('Sales/Marketing', '2.A.1.d', 'Speaking', 0.80);

-- Research/Analysis Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Research Projects', '2.A.2.a', 'Critical Thinking', 0.95),
('Research Projects', '2.B.4.g', 'Systems Analysis', 0.90),
('Research Projects', '2.A.1.a', 'Reading Comprehension', 0.85),
('Research Projects', '2.A.2.b', 'Active Learning', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Data Analysis', '2.B.4.g', 'Systems Analysis', 0.95),
('Data Analysis', '2.A.1.e', 'Mathematics', 0.90),
('Data Analysis', '2.A.2.a', 'Critical Thinking', 0.90),
('Data Analysis', '2.B.2.i', 'Complex Problem Solving', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Statistics Projects', '2.A.1.e', 'Mathematics', 0.95),
('Statistics Projects', '2.B.4.g', 'Systems Analysis', 0.85),
('Statistics Projects', '2.A.2.a', 'Critical Thinking', 0.85);

-- Negotiation/Coordination Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Model UN', '2.B.1.d', 'Negotiation', 0.95),
('Model UN', '2.B.1.c', 'Persuasion', 0.90),
('Model UN', '2.A.1.d', 'Speaking', 0.85),
('Model UN', '2.A.2.a', 'Critical Thinking', 0.85),
('Model UN', '2.B.1.a', 'Social Perceptiveness', 0.80);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Mediation/Conflict Resolution', '2.B.1.d', 'Negotiation', 0.95),
('Mediation/Conflict Resolution', '2.B.1.a', 'Social Perceptiveness', 0.95),
('Mediation/Conflict Resolution', '2.A.1.b', 'Active Listening', 0.90),
('Mediation/Conflict Resolution', '2.B.4.e', 'Judgment and Decision Making', 0.85);

-- Learning/Study Skills Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Study Groups', '2.A.2.c', 'Learning Strategies', 0.90),
('Study Groups', '2.B.1.b', 'Coordination', 0.80),
('Study Groups', '2.A.2.b', 'Active Learning', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Academic Competitions', '2.A.2.a', 'Critical Thinking', 0.90),
('Academic Competitions', '2.A.2.b', 'Active Learning', 0.85),
('Academic Competitions', '2.B.2.i', 'Complex Problem Solving', 0.80);

-- Systems/Evaluation Activities
INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Systems Design', '2.B.4.g', 'Systems Analysis', 0.95),
('Systems Design', '2.B.4.h', 'Systems Evaluation', 0.95),
('Systems Design', '2.B.3.b', 'Technology Design', 0.90),
('Systems Design', '2.B.2.i', 'Complex Problem Solving', 0.85);

INSERT INTO ACTIVITY_SKILLS_MAPPING VALUES
('Process Improvement', '2.B.4.h', 'Systems Evaluation', 0.95),
('Process Improvement', '2.B.3.a', 'Operations Analysis', 0.90),
('Process Improvement', '2.A.2.a', 'Critical Thinking', 0.85);

-- =============================================
-- Verification Queries
-- =============================================

SELECT '=============================================' AS SEPARATOR;
SELECT 'Coverage Summary' AS REPORT;
SELECT '=============================================' AS SEPARATOR;

-- Check coverage of all 35 O*NET skills
SELECT 'Skills covered in SUBJECT mappings:' AS METRIC, COUNT(DISTINCT ONET_SKILL_ID) AS COUNT
FROM SUBJECT_SKILLS_MAPPING;

SELECT 'Skills covered in ACTIVITY mappings:' AS METRIC, COUNT(DISTINCT ONET_SKILL_ID) AS COUNT
FROM ACTIVITY_SKILLS_MAPPING;

SELECT 'Total unique skills covered:' AS METRIC, COUNT(DISTINCT ONET_SKILL_ID) AS COUNT
FROM (
    SELECT ONET_SKILL_ID FROM SUBJECT_SKILLS_MAPPING
    UNION
    SELECT ONET_SKILL_ID FROM ACTIVITY_SKILLS_MAPPING
);

-- List all 35 O*NET skills and their coverage
SELECT 'Coverage by O*NET Skill:' AS REPORT;
SELECT
    sf.ELEMENT_ID,
    sf.ELEMENT_NAME,
    COUNT(DISTINCT ssm.SUBJECT_NAME) AS NUM_SUBJECTS,
    COUNT(DISTINCT asm.ACTIVITY_NAME) AS NUM_ACTIVITIES,
    CASE
        WHEN COUNT(DISTINCT ssm.SUBJECT_NAME) > 0 OR COUNT(DISTINCT asm.ACTIVITY_NAME) > 0
        THEN '✅ Covered'
        ELSE '❌ NOT COVERED'
    END AS STATUS
FROM (
    SELECT DISTINCT ELEMENT_ID, ELEMENT_NAME
    FROM SKILLS_FACT
    WHERE SCALE_ID = 'IM'
) sf
LEFT JOIN SUBJECT_SKILLS_MAPPING ssm ON sf.ELEMENT_ID = ssm.ONET_SKILL_ID
LEFT JOIN ACTIVITY_SKILLS_MAPPING asm ON sf.ELEMENT_ID = asm.ONET_SKILL_ID
GROUP BY sf.ELEMENT_ID, sf.ELEMENT_NAME
ORDER BY sf.ELEMENT_ID;

-- Verify Software Developer mapping works
SELECT '=============================================' AS SEPARATOR;
SELECT 'Software Developer Skills Match Test' AS REPORT;
SELECT '=============================================' AS SEPARATOR;

SELECT 'Math skills that match Software Developer:' AS TEST;
SELECT DISTINCT
    sm.SUBJECT_NAME,
    sm.ONET_SKILL_ID,
    sm.SKILL_NAME,
    sm.RELEVANCE_SCORE,
    sf.DATA_VALUE AS IMPORTANCE_FOR_SW_DEV
FROM SUBJECT_SKILLS_MAPPING sm
JOIN SKILLS_FACT sf ON sm.ONET_SKILL_ID = sf.ELEMENT_ID
WHERE sm.SUBJECT_NAME = 'Math'
  AND sf.ONET_SOC_CODE = '15-1252.00'
  AND sf.SCALE_ID = 'IM'
ORDER BY sf.DATA_VALUE DESC;

SELECT 'Computer Science skills that match Software Developer:' AS TEST;
SELECT DISTINCT
    sm.SUBJECT_NAME,
    sm.ONET_SKILL_ID,
    sm.SKILL_NAME,
    sm.RELEVANCE_SCORE,
    sf.DATA_VALUE AS IMPORTANCE_FOR_SW_DEV
FROM SUBJECT_SKILLS_MAPPING sm
JOIN SKILLS_FACT sf ON sm.ONET_SKILL_ID = sf.ELEMENT_ID
WHERE sm.SUBJECT_NAME = 'Computer Science'
  AND sf.ONET_SOC_CODE = '15-1252.00'
  AND sf.SCALE_ID = 'IM'
ORDER BY sf.DATA_VALUE DESC;

SELECT 'Coding/Programming skills that match Software Developer:' AS TEST;
SELECT DISTINCT
    am.ACTIVITY_NAME,
    am.ONET_SKILL_ID,
    am.SKILL_NAME,
    am.RELEVANCE_SCORE,
    sf.DATA_VALUE AS IMPORTANCE_FOR_SW_DEV
FROM ACTIVITY_SKILLS_MAPPING am
JOIN SKILLS_FACT sf ON am.ONET_SKILL_ID = sf.ELEMENT_ID
WHERE am.ACTIVITY_NAME = 'Coding/Programming'
  AND sf.ONET_SOC_CODE = '15-1252.00'
  AND sf.SCALE_ID = 'IM'
ORDER BY sf.DATA_VALUE DESC;

-- =============================================
-- Expected: 100% coverage of all 35 O*NET skills
-- Expected: Software Developer gets strong matches for Math + CS + Coding
-- =============================================
