-- =============================================
-- Recipe D Step 3: Create Full Vectors & v4.0 Procedure
-- =============================================
-- Combines Interests + Values + Skills into unified table
-- Creates SP_GET_CAREER_MATCHES_V4 with 4-dimensional matching
-- =============================================

USE DATABASE ONET_DB;
USE SCHEMA PUBLIC;

-- =============================================
-- Create CAREER_FULL_VECTORS table
-- =============================================
-- This table combines RIASEC, Work Values, and Skills
-- for fast 4-dimensional matching

CREATE OR REPLACE TABLE CAREER_FULL_VECTORS AS
SELECT
    o.ONET_SOC_CODE,
    o.TITLE AS JOB_TITLE,
    o.DESCRIPTION,

    -- RIASEC Interests (6 dimensions)
    MAX(CASE WHEN i.ELEMENT_NAME = 'Realistic' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS REALISTIC,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Investigative' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS INVESTIGATIVE,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Artistic' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS ARTISTIC,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Social' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS SOCIAL,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Enterprising' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS ENTERPRISING,
    MAX(CASE WHEN i.ELEMENT_NAME = 'Conventional' AND i.SCALE_ID = 'OI' THEN i.DATA_VALUE ELSE 0 END) AS CONVENTIONAL,

    -- Work Values (6 dimensions)
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.a' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS ACHIEVEMENT,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.f' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS INDEPENDENCE,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.c' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS RECOGNITION,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.d' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS RELATIONSHIPS,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.e' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS SUPPORT,
    MAX(CASE WHEN w.ELEMENT_ID = '1.B.2.b' AND w.SCALE_ID = 'EX' THEN w.DATA_VALUE ELSE 0 END) AS WORKING_CONDITIONS,

    -- Top 10 Skills as JSON (for flexible skill matching)
    ARRAY_AGG(
        OBJECT_CONSTRUCT(
            'skill_id', s.ELEMENT_ID,
            'skill_name', s.ELEMENT_NAME,
            'importance', s.DATA_VALUE
        )
    ) WITHIN GROUP (ORDER BY s.DATA_VALUE DESC) AS SKILLS_VECTOR,

    -- Education requirement - set to NULL for now since EDUCATION table may not exist
    NULL AS EDUCATION_LEVEL

FROM OCCUPATION_DATA o
LEFT JOIN INTERESTS_FACT i
    ON o.ONET_SOC_CODE = i.ONET_SOC_CODE
LEFT JOIN WORK_VALUES w
    ON o.ONET_SOC_CODE = w.ONET_SOC_CODE
LEFT JOIN (
    -- Get top 10 most important skills per occupation
    SELECT
        ONET_SOC_CODE,
        ELEMENT_ID,
        ELEMENT_NAME,
        DATA_VALUE,
        ROW_NUMBER() OVER (PARTITION BY ONET_SOC_CODE ORDER BY DATA_VALUE DESC) AS RN
    FROM SKILLS_FACT
    WHERE SCALE_ID = 'IM'  -- Importance scale
      AND (RECOMMEND_SUPPRESS != 'Y' OR RECOMMEND_SUPPRESS IS NULL)
      AND DATA_VALUE > 0
) s ON o.ONET_SOC_CODE = s.ONET_SOC_CODE AND s.RN <= 10

GROUP BY
    o.ONET_SOC_CODE,
    o.TITLE,
    o.DESCRIPTION;

-- =============================================
-- Verify CAREER_FULL_VECTORS
-- =============================================

-- Check row count
SELECT 'Total Careers with Full Vectors' AS METRIC, COUNT(*) AS VALUE
FROM CAREER_FULL_VECTORS;

-- Sample record with all dimensions
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL,
    ACHIEVEMENT, INDEPENDENCE, RECOGNITION, RELATIONSHIPS, SUPPORT, WORKING_CONDITIONS,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS,
    EDUCATION_LEVEL
FROM CAREER_FULL_VECTORS
WHERE JOB_TITLE LIKE '%Software Developer%'
LIMIT 1;

-- Check skills vector for Software Developer
SELECT
    JOB_TITLE,
    SKILLS_VECTOR
FROM CAREER_FULL_VECTORS
WHERE JOB_TITLE LIKE '%Software Developer%'
LIMIT 1;

-- =============================================
-- Create SP_GET_CAREER_MATCHES_V4
-- =============================================
-- 4-Dimensional Career Matching:
--   40% RIASEC Interests
--   30% Work Values
--   20% Skills (from subjects/activities)
--   10% Context (education, direct interests)
-- =============================================

CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V4(
    -- RIASEC Interests (6 params)
    USER_REALISTIC FLOAT,
    USER_INVESTIGATIVE FLOAT,
    USER_ARTISTIC FLOAT,
    USER_SOCIAL FLOAT,
    USER_ENTERPRISING FLOAT,
    USER_CONVENTIONAL FLOAT,

    -- Work Values (6 params)
    USER_ACHIEVEMENT FLOAT,
    USER_INDEPENDENCE FLOAT,
    USER_RECOGNITION FLOAT,
    USER_RELATIONSHIPS FLOAT,
    USER_SUPPORT FLOAT,
    USER_WORKING_CONDITIONS FLOAT,

    -- Skills from Subjects/Activities (2 params - JSON arrays)
    USER_SUBJECTS VARCHAR,  -- JSON: ["Math", "Science"]
    USER_ACTIVITIES VARCHAR,  -- JSON: ["Coding", "Debate"]

    -- Context (3 params)
    USER_CAREER_INTERESTS VARCHAR,  -- JSON: ["Software Developer"]
    USER_STUDENT_LEVEL VARCHAR,  -- "High School", "Undergraduate", "Graduate"
    USER_CURRENT_STATUS VARCHAR  -- "Student", "Career Changer", etc.
)
RETURNS TABLE (
    ONET_SOC_CODE VARCHAR,
    JOB_TITLE VARCHAR,
    INTERESTS_MATCH FLOAT,
    VALUES_MATCH FLOAT,
    SKILLS_MATCH FLOAT,
    CONTEXT_SCORE FLOAT,
    BLENDED_MATCH FLOAT,
    FINAL_SCORE FLOAT,
    DESCRIPTION VARCHAR,
    MATCH_EXPLANATION VARCHAR
)
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
    // ========================================
    // Helper Functions
    // ========================================

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

    function calculateUserSkills(subjects, activities) {
        let skillsMap = {};

        // Get skills from subjects
        for (let subject of subjects) {
            let query = `
                SELECT ONET_SKILL_ID, SKILL_NAME, RELEVANCE_SCORE
                FROM SUBJECT_SKILLS_MAPPING
                WHERE SUBJECT_NAME = ?
            `;
            let stmt = snowflake.createStatement({
                sqlText: query,
                binds: [subject]
            });
            let rs = stmt.execute();

            while (rs.next()) {
                let skillId = rs.getColumnValue(1);
                let skillName = rs.getColumnValue(2);
                let score = rs.getColumnValue(3);
                // Take max if skill appears multiple times
                if (!skillsMap[skillId] || skillsMap[skillId].score < score) {
                    skillsMap[skillId] = {name: skillName, score: score};
                }
            }
        }

        // Get skills from activities
        for (let activity of activities) {
            let query = `
                SELECT ONET_SKILL_ID, SKILL_NAME, RELEVANCE_SCORE
                FROM ACTIVITY_SKILLS_MAPPING
                WHERE ACTIVITY_NAME = ?
            `;
            let stmt = snowflake.createStatement({
                sqlText: query,
                binds: [activity]
            });
            let rs = stmt.execute();

            while (rs.next()) {
                let skillId = rs.getColumnValue(1);
                let skillName = rs.getColumnValue(2);
                let score = rs.getColumnValue(3);
                if (!skillsMap[skillId] || skillsMap[skillId].score < score) {
                    skillsMap[skillId] = {name: skillName, score: score};
                }
            }
        }

        return skillsMap;
    }

    function calculateSkillsMatch(userSkills, jobSkills) {
        if (!jobSkills || jobSkills.length === 0) return 0;

        let totalImportance = 0;
        let matchedImportance = 0;

        for (let jobSkill of jobSkills) {
            let skillId = jobSkill.skill_id;
            let importance = jobSkill.importance;

            totalImportance += importance;

            if (userSkills[skillId]) {
                // Multiply job importance by user relevance
                matchedImportance += importance * userSkills[skillId].score;
            }
        }

        return totalImportance > 0 ? matchedImportance / totalImportance : 0;
    }

    function calculateContextScore(careerInterests, studentLevel, jobTitle, jobEducation) {
        let contextScore = 0.5;  // Baseline 50%

        // Direct career interest match (+50% boost)
        for (let interest of careerInterests) {
            let interestLower = interest.toLowerCase();
            let titleLower = jobTitle.toLowerCase();

            if (titleLower.includes(interestLower) || interestLower.includes(titleLower)) {
                contextScore += 0.5;
                break;
            }
        }

        // Education level appropriateness
        if (jobEducation) {
            let eduLower = jobEducation.toLowerCase();

            if (studentLevel === 'High School') {
                if (eduLower.includes('high school') ||
                    eduLower.includes('associate') ||
                    eduLower.includes('some college')) {
                    contextScore += 0.2;
                } else if (eduLower.includes('doctoral') ||
                           eduLower.includes('post-doctoral')) {
                    contextScore -= 0.3;  // Penalize PhD requirements
                }
            } else if (studentLevel === 'Undergraduate') {
                if (eduLower.includes('bachelor')) {
                    contextScore += 0.2;
                }
            } else if (studentLevel === 'Graduate') {
                if (eduLower.includes('master') ||
                    eduLower.includes('doctoral')) {
                    contextScore += 0.2;
                }
            }
        }

        // Cap between 0 and 1
        return Math.max(0, Math.min(1, contextScore));
    }

    // ========================================
    // Main Matching Logic
    // ========================================

    // Parse JSON inputs (with fallbacks for empty/null)
    let userSubjects = [];
    let userActivities = [];
    let userCareerInterests = [];

    try {
        userSubjects = USER_SUBJECTS ? JSON.parse(USER_SUBJECTS) : [];
    } catch (e) {
        userSubjects = [];
    }

    try {
        userActivities = USER_ACTIVITIES ? JSON.parse(USER_ACTIVITIES) : [];
    } catch (e) {
        userActivities = [];
    }

    try {
        userCareerInterests = USER_CAREER_INTERESTS ? JSON.parse(USER_CAREER_INTERESTS) : [];
    } catch (e) {
        userCareerInterests = [];
    }

    // Build user vectors
    let userRIASEC = [
        USER_REALISTIC,
        USER_INVESTIGATIVE,
        USER_ARTISTIC,
        USER_SOCIAL,
        USER_ENTERPRISING,
        USER_CONVENTIONAL
    ];

    let userValues = [
        USER_ACHIEVEMENT,
        USER_INDEPENDENCE,
        USER_RECOGNITION,
        USER_RELATIONSHIPS,
        USER_SUPPORT,
        USER_WORKING_CONDITIONS
    ];

    // Build user skills map from subjects and activities
    let userSkills = calculateUserSkills(userSubjects, userActivities);

    // Query all careers with full vectors
    let query = `
        SELECT
            ONET_SOC_CODE,
            JOB_TITLE,
            REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL,
            ACHIEVEMENT, INDEPENDENCE, RECOGNITION, RELATIONSHIPS, SUPPORT, WORKING_CONDITIONS,
            SKILLS_VECTOR,
            EDUCATION_LEVEL,
            DESCRIPTION
        FROM CAREER_FULL_VECTORS
    `;

    let stmt = snowflake.createStatement({sqlText: query});
    let rs = stmt.execute();

    let results = [];

    while (rs.next()) {
        // Job vectors
        let jobRIASEC = [
            rs.getColumnValue('REALISTIC') || 0,
            rs.getColumnValue('INVESTIGATIVE') || 0,
            rs.getColumnValue('ARTISTIC') || 0,
            rs.getColumnValue('SOCIAL') || 0,
            rs.getColumnValue('ENTERPRISING') || 0,
            rs.getColumnValue('CONVENTIONAL') || 0
        ];

        let jobValues = [
            rs.getColumnValue('ACHIEVEMENT') || 0,
            rs.getColumnValue('INDEPENDENCE') || 0,
            rs.getColumnValue('RECOGNITION') || 0,
            rs.getColumnValue('RELATIONSHIPS') || 0,
            rs.getColumnValue('SUPPORT') || 0,
            rs.getColumnValue('WORKING_CONDITIONS') || 0
        ];

        let skillsVectorStr = rs.getColumnValue('SKILLS_VECTOR');
        let jobSkills = [];
        if (skillsVectorStr) {
            try {
                jobSkills = JSON.parse(skillsVectorStr);
            } catch (e) {
                jobSkills = [];
            }
        }

        let jobEducation = rs.getColumnValue('EDUCATION_LEVEL');
        let jobTitle = rs.getColumnValue('JOB_TITLE');

        // Calculate 4 match scores
        let interestsMatch = cosineSimilarity(userRIASEC, jobRIASEC);
        let valuesMatch = cosineSimilarity(userValues, jobValues);
        let skillsMatch = calculateSkillsMatch(userSkills, jobSkills);
        let contextScore = calculateContextScore(
            userCareerInterests,
            USER_STUDENT_LEVEL,
            jobTitle,
            jobEducation
        );

        // 4-Dimensional blended scoring
        let blendedMatch = (0.40 * interestsMatch) +
                          (0.30 * valuesMatch) +
                          (0.20 * skillsMatch) +
                          (0.10 * contextScore);

        let finalScore = blendedMatch * 7.0;

        // Generate explanation
        let explanation = `I:${Math.round(interestsMatch*100)}% ` +
                         `V:${Math.round(valuesMatch*100)}% ` +
                         `S:${Math.round(skillsMatch*100)}% ` +
                         `C:${Math.round(contextScore*100)}%`;

        results.push({
            ONET_SOC_CODE: rs.getColumnValue('ONET_SOC_CODE'),
            JOB_TITLE: jobTitle,
            INTERESTS_MATCH: Math.round(interestsMatch * 100) / 100,
            VALUES_MATCH: Math.round(valuesMatch * 100) / 100,
            SKILLS_MATCH: Math.round(skillsMatch * 100) / 100,
            CONTEXT_SCORE: Math.round(contextScore * 100) / 100,
            BLENDED_MATCH: Math.round(blendedMatch * 100) / 100,
            FINAL_SCORE: Math.round(finalScore * 100) / 100,
            DESCRIPTION: rs.getColumnValue('DESCRIPTION'),
            MATCH_EXPLANATION: explanation
        });
    }

    // Sort by blended match descending
    results.sort((a, b) => b.BLENDED_MATCH - a.BLENDED_MATCH);

    // Return top 50 (Swift will take top 15)
    return results.slice(0, 50);
$$;

-- =============================================
-- Test SP_GET_CAREER_MATCHES_V4
-- =============================================

-- Test Case 1: STEM Student (Math, Science, Coding)
CALL SP_GET_CAREER_MATCHES_V4(
    -- RIASEC: High I (Investigative)
    2.0, 5.0, 2.5, 3.0, 3.0, 4.0,
    -- Work Values: Achievement, Independence
    5.0, 5.0, 3.0, 2.5, 2.5, 3.5,
    -- Subjects/Activities
    '["Math", "Computer Science", "Science"]',
    '["Coding/Programming", "Math Club"]',
    -- Context
    '["Software Developer", "Data Scientist"]',
    'Undergraduate',
    'Student'
);

-- Expected: Software Developer, Data Scientist, Computer Systems Analyst in top 5

-- =============================================
-- SUCCESS CRITERIA
-- =============================================
-- ✅ CAREER_FULL_VECTORS created with 800+ careers
-- ✅ Each career has RIASEC, Values, and Skills data
-- ✅ SP_GET_CAREER_MATCHES_V4 created successfully
-- ✅ Test query returns 50 results sorted by match
-- ✅ STEM test case shows tech careers in top 5
-- ✅ Match explanations include all 4 dimensions
-- =============================================
