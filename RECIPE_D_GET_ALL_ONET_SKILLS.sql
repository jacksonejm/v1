USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Get all unique O*NET skills (ELEMENT_ID and ELEMENT_NAME)
-- These are the 35 standard O*NET skills that all careers are rated on
SELECT DISTINCT
    ELEMENT_ID,
    ELEMENT_NAME,
    COUNT(DISTINCT ONET_SOC_CODE) AS NUM_CAREERS_WITH_SKILL
FROM SKILLS_FACT
WHERE SCALE_ID = 'IM'  -- Importance scale
GROUP BY ELEMENT_ID, ELEMENT_NAME
ORDER BY ELEMENT_ID;

-- This should return ~35 skills like:
-- 2.A.1.a - Reading Comprehension
-- 2.A.1.b - Active Listening
-- 2.A.1.e - Mathematics
-- 2.B.1.a - Critical Thinking
-- 2.B.3.b - Programming
-- etc.
