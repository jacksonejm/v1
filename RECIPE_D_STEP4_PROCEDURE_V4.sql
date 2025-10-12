USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- =============================================
-- Recipe D v4.0 - Create SP_GET_CAREER_MATCHES_V4
-- =============================================

CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES_V4(
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
    USER_WORKING_CONDITIONS FLOAT,
    USER_SUBJECTS VARCHAR,
    USER_ACTIVITIES VARCHAR,
    USER_CAREER_INTERESTS VARCHAR,
    USER_STUDENT_LEVEL VARCHAR,
    USER_CURRENT_STATUS VARCHAR
)
RETURNS VARCHAR
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS
$$
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

        for (let subject of subjects) {
            let query = `SELECT ONET_SKILL_ID, SKILL_NAME, RELEVANCE_SCORE FROM SUBJECT_SKILLS_MAPPING WHERE SUBJECT_NAME = ?`;
            let stmt = snowflake.createStatement({sqlText: query, binds: [subject]});
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

        for (let activity of activities) {
            let query = `SELECT ONET_SKILL_ID, SKILL_NAME, RELEVANCE_SCORE FROM ACTIVITY_SKILLS_MAPPING WHERE ACTIVITY_NAME = ?`;
            let stmt = snowflake.createStatement({sqlText: query, binds: [activity]});
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
                matchedImportance += importance * userSkills[skillId].score;
            }
        }
        return totalImportance > 0 ? matchedImportance / totalImportance : 0;
    }

    function calculateContextScore(careerInterests, studentLevel, jobTitle, jobEducation) {
        let contextScore = 0.5;
        for (let interest of careerInterests) {
            let interestLower = interest.toLowerCase();
            let titleLower = jobTitle.toLowerCase();
            if (titleLower.includes(interestLower) || interestLower.includes(titleLower)) {
                contextScore += 0.5;
                break;
            }
        }
        if (jobEducation) {
            let eduLower = jobEducation.toLowerCase();
            if (studentLevel === 'High School') {
                if (eduLower.includes('high school') || eduLower.includes('associate') || eduLower.includes('some college')) {
                    contextScore += 0.2;
                } else if (eduLower.includes('doctoral') || eduLower.includes('post-doctoral')) {
                    contextScore -= 0.3;
                }
            } else if (studentLevel === 'Undergraduate') {
                if (eduLower.includes('bachelor')) {
                    contextScore += 0.2;
                }
            } else if (studentLevel === 'Graduate') {
                if (eduLower.includes('master') || eduLower.includes('doctoral')) {
                    contextScore += 0.2;
                }
            }
        }
        return Math.max(0, Math.min(1, contextScore));
    }

    let userSubjects = [];
    let userActivities = [];
    let userCareerInterests = [];

    try { userSubjects = USER_SUBJECTS ? JSON.parse(USER_SUBJECTS) : []; } catch (e) { userSubjects = []; }
    try { userActivities = USER_ACTIVITIES ? JSON.parse(USER_ACTIVITIES) : []; } catch (e) { userActivities = []; }
    try { userCareerInterests = USER_CAREER_INTERESTS ? JSON.parse(USER_CAREER_INTERESTS) : []; } catch (e) { userCareerInterests = []; }

    let userRIASEC = [USER_REALISTIC, USER_INVESTIGATIVE, USER_ARTISTIC, USER_SOCIAL, USER_ENTERPRISING, USER_CONVENTIONAL];
    let userValues = [USER_ACHIEVEMENT, USER_INDEPENDENCE, USER_RECOGNITION, USER_RELATIONSHIPS, USER_SUPPORT, USER_WORKING_CONDITIONS];
    let userSkills = calculateUserSkills(userSubjects, userActivities);

    let query = `
        SELECT
            ONET_SOC_CODE,
            JOB_TITLE,
            REALISTIC, INVESTIGATIVE, ARTISTIC, SOCIAL, ENTERPRISING, CONVENTIONAL,
            ACHIEVEMENT, INDEPENDENCE, RECOGNITION, RELATIONSHIPS, SUPPORT, WORKING_CONDITIONS,
            SKILLS_VECTOR,
            DESCRIPTION
        FROM CAREER_FULL_VECTORS
    `;

    let stmt = snowflake.createStatement({sqlText: query});
    let rs = stmt.execute();
    let results = [];

    while (rs.next()) {
        let jobRIASEC = [
            rs.getColumnValue('REALISTIC') || 0,
            rs.getColumnValue('INVESTIGATIVE') || 0,
            rs.getColumnValue('ARTISTIC') || 0,
            rs.getColumnValue('SOCIAL') || 0,
            rs.getColumnValue('ENTERPRISING') || 0,
            rs.getColumnValue('CONVENTIONAL') || 0
        ];

        // Get work values, use 0.5 as default for missing data (neutral/average value)
        let jobValues = [
            rs.getColumnValue('ACHIEVEMENT') || 0.5,
            rs.getColumnValue('INDEPENDENCE') || 0.5,
            rs.getColumnValue('RECOGNITION') || 0.5,
            rs.getColumnValue('RELATIONSHIPS') || 0.5,
            rs.getColumnValue('SUPPORT') || 0.5,
            rs.getColumnValue('WORKING_CONDITIONS') || 0.5
        ];

        // Check if all values are 0 (missing data), use defaults
        let hasWorkValues = jobValues.some(v => v > 0 && v !== 0.5);
        if (!hasWorkValues) {
            jobValues = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
        }

        // SKILLS_VECTOR is already an array in Snowflake, convert to JavaScript array
        let skillsVectorRaw = rs.getColumnValue('SKILLS_VECTOR');
        let jobSkills = [];
        if (skillsVectorRaw) {
            try {
                // If it's a string, parse it. If it's already an object/array, use it directly
                if (typeof skillsVectorRaw === 'string') {
                    jobSkills = JSON.parse(skillsVectorRaw);
                } else if (Array.isArray(skillsVectorRaw)) {
                    jobSkills = skillsVectorRaw;
                } else {
                    // Convert Snowflake array to JavaScript array
                    jobSkills = JSON.parse(JSON.stringify(skillsVectorRaw));
                }
            } catch (e) {
                jobSkills = [];
            }
        }

        let jobEducation = null;  // Education level not available in current schema
        let jobTitle = rs.getColumnValue('JOB_TITLE');

        let interestsMatch = cosineSimilarity(userRIASEC, jobRIASEC);
        let valuesMatch = cosineSimilarity(userValues, jobValues);
        let skillsMatch = calculateSkillsMatch(userSkills, jobSkills);
        let contextScore = calculateContextScore(userCareerInterests, USER_STUDENT_LEVEL, jobTitle, jobEducation);

        let blendedMatch = (0.40 * interestsMatch) + (0.30 * valuesMatch) + (0.20 * skillsMatch) + (0.10 * contextScore);
        let finalScore = blendedMatch * 7.0;

        let explanation = `I:${Math.round(interestsMatch*100)}% V:${Math.round(valuesMatch*100)}% S:${Math.round(skillsMatch*100)}% C:${Math.round(contextScore*100)}%`;

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

    results.sort((a, b) => b.BLENDED_MATCH - a.BLENDED_MATCH);
    return JSON.stringify(results.slice(0, 50));
$$;

-- =============================================
-- Test the procedure
-- =============================================

SELECT 'Testing SP_GET_CAREER_MATCHES_V4...' AS STATUS;

CALL SP_GET_CAREER_MATCHES_V4(
    2.0, 5.0, 2.5, 3.0, 3.0, 4.0,
    5.0, 5.0, 3.0, 2.5, 2.5, 3.5,
    '["Math", "Computer Science"]',
    '["Coding/Programming"]',
    '["Software Developer"]',
    'Undergraduate',
    'Student'
);

-- Expected: Software Developer should be in top 5
-- Verify: All match scores between 0.0 and 1.0
-- Verify: Returns 50 results
