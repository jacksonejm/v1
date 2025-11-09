-- ==============================================================================
-- Phase 1: Foundation - Table 4 of 6
-- USER_SKILLS: User skill levels with trust scores and time decay
-- ==============================================================================
-- Created: 2025-10-21
-- Purpose: Track user skill levels across all O*NET skills with confidence
--          scoring based on multiple evidence sources and recency
-- ==============================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Drop table if exists (for development only - remove in production)
-- DROP TABLE IF EXISTS USER_SKILLS;

CREATE TABLE IF NOT EXISTS USER_SKILLS (
  -- Composite Primary Key (enforced by application)
  user_pid VARCHAR(100) NOT NULL,
  skill_id VARCHAR(20) NOT NULL,

  -- Skill Assessment
  skill_level FLOAT NOT NULL,
  proficiency_tier INT,

  -- Trust & Confidence
  trust_score FLOAT NOT NULL DEFAULT 0.0,
  evidence_count INT NOT NULL DEFAULT 0,
  last_evidence_date TIMESTAMP,

  -- Evidence Breakdown (stored as JSON string)
  evidence_sources VARCHAR(1000),

  -- Recency & Decay
  recency_weight FLOAT DEFAULT 1.0,
  decay_rate FLOAT DEFAULT 0.95,

  -- Goal Tracking
  target_level FLOAT,
  is_priority_skill BOOLEAN DEFAULT FALSE,

  -- Metadata
  first_assessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- Note: Snowflake doesn't enforce composite PKs, handle in application
  PRIMARY KEY (user_pid, skill_id)
)
COMMENT = 'Tracks user skill levels across all O*NET skills with trust scores based on multiple evidence sources. Supports time decay and goal tracking.';

-- ==============================================================================
-- Sample Data (for testing)
-- ==============================================================================

-- Sample User 1: Strong PM skills
INSERT INTO USER_SKILLS VALUES
  ('pid_device_xyz123', '2.B.1.b', 0.75, 4, 0.80, 5, '2025-10-21 10:15:00', '{"scenarios": 2, "riasec_assessment": 1, "work_values": 1, "artifacts": 1}', 1.0, 0.95, NULL, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('pid_device_xyz123', '2.B.1.a', 0.85, 5, 0.85, 6, '2025-10-21 14:18:00', '{"scenarios": 3, "riasec_assessment": 1, "work_values": 1, "external_badges": 1}', 1.0, 0.95, NULL, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('pid_device_xyz123', '2.C.4.c', 0.70, 4, 0.75, 5, '2025-10-21 10:15:00', '{"scenarios": 2, "riasec_assessment": 1, "work_values": 1, "artifacts": 1}', 1.0, 0.95, NULL, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Sample User 1: Developing skills (lower trust)
INSERT INTO USER_SKILLS VALUES
  ('pid_device_xyz123', '2.B.1.d', 0.45, 3, 0.45, 3, '2025-10-20 08:00:00', '{"scenarios": 1, "riasec_assessment": 1, "work_values": 1}', 0.95, 0.95, 0.80, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('pid_device_xyz123', '2.A.1.a', 0.60, 3, 0.60, 4, '2025-10-19 12:00:00', '{"scenarios": 1, "riasec_assessment": 1, "work_values": 1, "artifacts": 1}', 0.90, 0.95, 0.85, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Sample User 2: Healthcare/Nurse skills
INSERT INTO USER_SKILLS VALUES
  ('pid_device_abc456', '2.B.1.a', 0.88, 5, 0.90, 6, '2025-10-21 14:18:00', '{"scenarios": 2, "riasec_assessment": 1, "work_values": 1, "clinical_assessments": 2}', 1.0, 0.95, NULL, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('pid_device_abc456', '2.C.4.c', 0.85, 5, 0.85, 6, '2025-10-21 14:18:00', '{"scenarios": 2, "riasec_assessment": 1, "work_values": 1, "clinical_assessments": 2}', 1.0, 0.95, NULL, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('pid_device_abc456', '2.B.1.e', 0.75, 4, 0.75, 5, '2025-10-21 14:18:00', '{"scenarios": 1, "riasec_assessment": 1, "work_values": 1, "clinical_assessments": 2}', 1.0, 0.95, NULL, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Sample User 3: Early career, low evidence
INSERT INTO USER_SKILLS VALUES
  ('pid_device_def789', '2.A.1.b', 0.35, 2, 0.30, 2, '2025-10-15 10:00:00', '{"riasec_assessment": 1, "work_values": 1}', 0.85, 0.95, 0.70, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('pid_device_def789', '2.B.1.e', 0.40, 2, 0.30, 2, '2025-10-15 10:00:00', '{"riasec_assessment": 1, "work_values": 1}', 0.85, 0.95, 0.75, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ==============================================================================
-- Validation Queries (run after deployment)
-- ==============================================================================

-- Verify skills loaded
SELECT COUNT(*) as skill_count FROM USER_SKILLS;
-- Expected: 10

-- Check user skill summary
SELECT
  user_pid,
  COUNT(*) as total_skills,
  AVG(skill_level) as avg_skill_level,
  AVG(trust_score) as avg_trust,
  SUM(CASE WHEN is_priority_skill THEN 1 ELSE 0 END) as priority_skills,
  MAX(last_evidence_date) as most_recent_evidence
FROM USER_SKILLS
GROUP BY user_pid;

-- Find high-confidence skills (trust >= 0.7)
SELECT
  user_pid,
  skill_id,
  skill_level,
  proficiency_tier,
  trust_score,
  evidence_count
FROM USER_SKILLS
WHERE trust_score >= 0.7
ORDER BY trust_score DESC, skill_level DESC;

-- Find skills needing development (gap between current and target)
SELECT
  user_pid,
  skill_id,
  skill_level as current_level,
  target_level,
  (target_level - skill_level) as gap,
  trust_score,
  is_priority_skill
FROM USER_SKILLS
WHERE target_level IS NOT NULL
  AND target_level > skill_level
ORDER BY gap DESC;

-- ==============================================================================
-- Maintenance Notes
-- ==============================================================================

-- To update skill level after new evidence:
-- UPDATE USER_SKILLS
-- SET
--   skill_level = 0.80,
--   trust_score = 0.85,
--   evidence_count = evidence_count + 1,
--   last_evidence_date = CURRENT_TIMESTAMP,
--   recency_weight = 1.0,
--   last_updated_at = CURRENT_TIMESTAMP
-- WHERE user_pid = 'pid_xxx' AND skill_id = '2.B.1.a';

-- To mark skill as priority:
-- UPDATE USER_SKILLS
-- SET is_priority_skill = TRUE, target_level = 0.85
-- WHERE user_pid = 'pid_xxx' AND skill_id = '2.B.1.a';

-- To apply time decay to all skills (run monthly):
-- UPDATE USER_SKILLS
-- SET
--   recency_weight = EXP(-1 * DATEDIFF(month, last_evidence_date, CURRENT_TIMESTAMP) * 0.1),
--   last_updated_at = CURRENT_TIMESTAMP
-- WHERE last_evidence_date IS NOT NULL;

-- ==============================================================================
-- End of Script
-- ==============================================================================
