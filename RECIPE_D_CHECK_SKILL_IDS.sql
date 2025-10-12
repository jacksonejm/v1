USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Check actual skill IDs in SKILLS_FACT for Software Developers
SELECT
    ONET_SOC_CODE,
    ELEMENT_ID,
    ELEMENT_NAME,
    DATA_VALUE
FROM SKILLS_FACT
WHERE ONET_SOC_CODE = '15-1252.00'  -- Software Developers
  AND SCALE_ID = 'IM'
ORDER BY DATA_VALUE DESC
LIMIT 10;

-- Compare with our mappings
SELECT 'Our Math mapping:' AS CHECK;
SELECT ONET_SKILL_ID, SKILL_NAME FROM SUBJECT_SKILLS_MAPPING WHERE SUBJECT_NAME = 'Math';

SELECT 'Our Computer Science mapping:' AS CHECK;
SELECT ONET_SKILL_ID, SKILL_NAME FROM SUBJECT_SKILLS_MAPPING WHERE SUBJECT_NAME = 'Computer Science';

SELECT 'Our Coding mapping:' AS CHECK;
SELECT ONET_SKILL_ID, SKILL_NAME FROM ACTIVITY_SKILLS_MAPPING WHERE ACTIVITY_NAME = 'Coding/Programming';

-- Check if skill IDs match format
-- If SKILLS_FACT has IDs like "2.B.3.b" and we mapped "2.B.3.b" to "Programming", it should work
