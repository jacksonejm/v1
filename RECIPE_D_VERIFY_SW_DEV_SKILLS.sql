USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Get Software Developers with all details
SELECT
    ONET_SOC_CODE,
    JOB_TITLE,
    ARRAY_SIZE(SKILLS_VECTOR) AS NUM_SKILLS,
    REALISTIC,
    INVESTIGATIVE,
    ARTISTIC,
    SOCIAL,
    ENTERPRISING,
    CONVENTIONAL
FROM CAREER_FULL_VECTORS
WHERE ONET_SOC_CODE = '15-1252.00';

-- Parse the skills
SELECT
    f.VALUE:skill_id::STRING AS SKILL_ID,
    f.VALUE:skill_name::STRING AS SKILL_NAME,
    f.VALUE:importance::FLOAT AS IMPORTANCE
FROM CAREER_FULL_VECTORS,
LATERAL FLATTEN(input => SKILLS_VECTOR) f
WHERE ONET_SOC_CODE = '15-1252.00'
ORDER BY f.VALUE:importance::FLOAT DESC;

-- Now test SP_GET_CAREER_MATCHES_V4 with Math + Computer Science + Coding
CALL SP_GET_CAREER_MATCHES_V4(
    2.0, 5.0, 2.5, 3.0, 3.0, 4.0,
    5.0, 5.0, 3.0, 2.5, 2.5, 3.5,
    '["Math", "Computer Science"]',
    '["Coding/Programming"]',
    '["Software Developer"]',
    'Undergraduate',
    'Student'
);
