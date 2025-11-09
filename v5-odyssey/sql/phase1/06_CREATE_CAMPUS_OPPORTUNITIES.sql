-- ==============================================================================
-- Phase 1: Foundation - Table 6 of 6
-- CAMPUS_OPPORTUNITIES: Clubs, internships, scholarships, and activities
-- ==============================================================================
-- Created: 2025-10-21
-- Purpose: Store campus and local opportunities for skill building
--          Includes clubs, internships, scholarships, volunteer positions
-- ==============================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Drop table if exists (for development only - remove in production)
-- DROP TABLE IF EXISTS CAMPUS_OPPORTUNITIES;

CREATE TABLE IF NOT EXISTS CAMPUS_OPPORTUNITIES (
  -- Primary Key
  opportunity_id VARCHAR(50) PRIMARY KEY,

  -- Opportunity Details
  title VARCHAR(255) NOT NULL,
  description VARCHAR(2000),
  opportunity_type VARCHAR(20) NOT NULL,

  -- Location & Context
  institution VARCHAR(255),
  location VARCHAR(100),
  country VARCHAR(10) DEFAULT 'USA',
  is_remote BOOLEAN DEFAULT FALSE,

  -- Eligibility & Requirements (comma-delimited)
  grade_levels VARCHAR(100),
  gpa_requirement FLOAT,
  prerequisites VARCHAR(500),

  -- Skill Development (comma-delimited skill IDs)
  skill_tags VARCHAR(500) NOT NULL,
  primary_skill_focus VARCHAR(100),

  -- Career Alignment (comma-delimited O*NET codes)
  related_onet_codes VARCHAR(500),
  career_pathways VARCHAR(200),

  -- Timing & Deadlines
  application_deadline TIMESTAMP,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  time_commitment VARCHAR(50),

  -- Financial
  compensation FLOAT,
  scholarship_amount FLOAT,

  -- Application
  application_url VARCHAR(500),
  contact_email VARCHAR(100),
  contact_name VARCHAR(100),

  -- Matching & Recommendations
  difficulty_tier INT DEFAULT 2,
  is_featured BOOLEAN DEFAULT FALSE,

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
)
COMMENT = 'Campus and local opportunities for skill building. Includes clubs, internships, scholarships, volunteer positions, and competitions. Used for personalized opportunity matching.';

-- ==============================================================================
-- Sample Data (for testing)
-- ==============================================================================

-- Sample 1: Robotics Club (STEM, accessible)
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'opp_club_robotics_001',
  'Robotics Club',
  'Build and program robots for regional competitions. Learn engineering design, programming, and teamwork.',
  'club',
  'Lincoln High School',
  'Seattle, WA',
  'USA',
  FALSE,
  '9,10,11,12',
  NULL,
  NULL,
  '2.B.1.b,2.A.1.a,2.C.4.c,2.B.2.a',
  'Technical & Engineering',
  '17-2199.00,15-1252.00,17-2141.00',
  'STEM,Engineering',
  NULL,
  '2025-09-01 00:00:00',
  NULL,
  '5 hours/week',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  1,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  TRUE
);

-- Sample 2: Product Management Internship (competitive)
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'opp_intern_pm_tech_001',
  'Associate Product Manager Intern - Tech Startup',
  'Summer internship working with product team on mobile app development. Gain experience in roadmapping, user research, and stakeholder management.',
  'internship',
  'TechFlow Inc.',
  'San Francisco, CA',
  'USA',
  FALSE,
  '11,12,College',
  3.5,
  '2.B.1.b,2.A.1.a',
  '2.B.1.b,2.B.1.d,2.C.4.c,2.A.1.a',
  'Business & Leadership',
  '15-1299.09,11-2021.00',
  'Technology,Business',
  '2025-03-15 23:59:59',
  '2025-06-15 00:00:00',
  '2025-08-15 00:00:00',
  '40 hours/week',
  25.00,
  NULL,
  'https://techflow.com/careers/internships',
  'internships@techflow.com',
  NULL,
  4,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  TRUE
);

-- Sample 3: STEM Scholarship (competitive)
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'opp_scholarship_stem_001',
  'National STEM Excellence Scholarship',
  'Merit-based scholarship for students pursuing STEM careers. Includes mentorship and networking opportunities.',
  'scholarship',
  'National STEM Foundation',
  'Washington, DC',
  'USA',
  FALSE,
  '11,12',
  3.8,
  NULL,
  '2.B.1.a,2.A.1.a',
  'Academic & STEM',
  '17-2199.00,15-1252.00,29-1141.00',
  'STEM,Healthcare,Engineering',
  '2025-02-01 23:59:59',
  NULL,
  NULL,
  NULL,
  NULL,
  5000.00,
  'https://nationalstemfoundation.org/scholarships',
  NULL,
  NULL,
  5,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  TRUE
);

-- Sample 4: Hospital Volunteer (healthcare pathway)
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'opp_volunteer_hospital_001',
  'Junior Volunteer - Seattle Children''s Hospital',
  'Volunteer in pediatric units, assist with patient activities, and shadow healthcare professionals.',
  'volunteer',
  'Seattle Children''s Hospital',
  'Seattle, WA',
  'USA',
  FALSE,
  '10,11,12',
  NULL,
  NULL,
  '2.B.1.e,2.A.1.b,2.C.7.b',
  'Healthcare & Empathy',
  '29-1141.00,31-1131.00,29-2061.00',
  'Healthcare',
  NULL,
  '2025-09-01 00:00:00',
  NULL,
  '4 hours/week',
  NULL,
  NULL,
  'https://seattlechildrens.org/volunteer',
  'volunteer@seattlechildrens.org',
  NULL,
  2,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  TRUE
);

-- Sample 5: Debate Team (communication skills)
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'opp_club_debate_001',
  'Debate Team',
  'Competitive debate team participating in regional and national tournaments. Build critical thinking, research, and public speaking skills.',
  'club',
  'Lincoln High School',
  'Seattle, WA',
  'USA',
  FALSE,
  '9,10,11,12',
  NULL,
  NULL,
  '2.B.1.a,2.A.1.a,2.B.1.d',
  'Communication & Persuasion',
  '23-1011.00,27-3041.00,11-2021.00',
  'Law,Communication,Business',
  NULL,
  '2025-09-01 00:00:00',
  NULL,
  '6 hours/week',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  2,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  TRUE
);

-- Sample 6: Canadian opportunity (Toronto)
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'opp_intern_software_canada_001',
  'Software Development Co-op',
  'Co-op position for high school students interested in software development. Work with professional developers on real projects.',
  'internship',
  'Shopify',
  'Toronto, ON',
  'Canada',
  FALSE,
  '11,12',
  NULL,
  NULL,
  '2.B.1.a,2.A.1.a,2.B.1.b',
  'Software Development',
  '15-1252.00,15-1299.09',
  'Technology,STEM',
  '2025-03-01 23:59:59',
  '2025-05-01 00:00:00',
  NULL,
  '16 weeks',
  22.00,
  NULL,
  'https://shopify.com/careers/coop',
  NULL,
  NULL,
  3,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  TRUE
);

-- Sample 7: Science Competition (STEM reach opportunity)
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'opp_competition_science_001',
  'Intel International Science and Engineering Fair (ISEF)',
  'Premier international science competition for high school students. Showcase original research and compete for scholarships.',
  'competition',
  'Society for Science',
  'Various',
  'USA',
  FALSE,
  '9,10,11,12',
  NULL,
  NULL,
  '2.B.1.a,2.A.1.a,2.B.2.a',
  'Research & STEM',
  '17-2199.00,19-1029.00,15-2021.00',
  'STEM,Research',
  '2025-01-15 23:59:59',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'https://societyforscience.org/isef',
  NULL,
  NULL,
  5,
  TRUE,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  TRUE
);

-- ==============================================================================
-- Validation Queries (run after deployment)
-- ==============================================================================

-- Verify opportunities loaded
SELECT COUNT(*) as opportunity_count FROM CAMPUS_OPPORTUNITIES;
-- Expected: 7

-- Check opportunity type distribution
SELECT
  opportunity_type,
  COUNT(*) as count,
  AVG(difficulty_tier) as avg_difficulty,
  SUM(CASE WHEN is_featured THEN 1 ELSE 0 END) as featured_count
FROM CAMPUS_OPPORTUNITIES
GROUP BY opportunity_type
ORDER BY count DESC;

-- Check country distribution
SELECT
  country,
  COUNT(*) as count,
  SUM(CASE WHEN is_remote THEN 1 ELSE 0 END) as remote_count
FROM CAMPUS_OPPORTUNITIES
GROUP BY country;

-- Find opportunities by difficulty tier (Ready, Stretch, Reach)
SELECT
  difficulty_tier,
  CASE
    WHEN difficulty_tier <= 2 THEN 'Ready'
    WHEN difficulty_tier <= 4 THEN 'Stretch'
    ELSE 'Reach'
  END as match_category,
  COUNT(*) as count
FROM CAMPUS_OPPORTUNITIES
GROUP BY difficulty_tier
ORDER BY difficulty_tier;

-- Find paid opportunities
SELECT
  title,
  opportunity_type,
  location,
  compensation,
  scholarship_amount
FROM CAMPUS_OPPORTUNITIES
WHERE compensation IS NOT NULL OR scholarship_amount IS NOT NULL
ORDER BY COALESCE(scholarship_amount, 0) DESC, COALESCE(compensation, 0) DESC;

-- ==============================================================================
-- Maintenance Notes
-- ==============================================================================

-- To add new opportunity:
-- INSERT INTO CAMPUS_OPPORTUNITIES VALUES (...);

-- To update opportunity details:
-- UPDATE CAMPUS_OPPORTUNITIES
-- SET description = 'Updated description', updated_at = CURRENT_TIMESTAMP
-- WHERE opportunity_id = 'opp_xxx';

-- To deactivate expired opportunity:
-- UPDATE CAMPUS_OPPORTUNITIES
-- SET is_active = FALSE, updated_at = CURRENT_TIMESTAMP
-- WHERE opportunity_id = 'opp_xxx';

-- ==============================================================================
-- End of Script
-- ==============================================================================
