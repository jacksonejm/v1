-- ==============================================================================
-- Phase 1: Foundation - Table 5 of 6
-- USER_EVIDENCE: Portfolio of user accomplishments and artifacts
-- ==============================================================================
-- Created: 2025-10-21
-- Purpose: Store user-submitted and system-generated evidence of skills
--          Includes artifacts, badges, certificates, and scenario completions
-- ==============================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Drop table if exists (for development only - remove in production)
-- DROP TABLE IF EXISTS USER_EVIDENCE;

CREATE TABLE IF NOT EXISTS USER_EVIDENCE (
  -- Primary Key
  evidence_id VARCHAR(50) PRIMARY KEY,

  -- User & Source
  user_pid VARCHAR(100) NOT NULL,
  evidence_type VARCHAR(20) NOT NULL,
  source_id VARCHAR(50),

  -- Evidence Content
  title VARCHAR(255) NOT NULL,
  description VARCHAR(2000),

  -- Skill Mapping (comma-delimited skill IDs)
  skill_tags VARCHAR(500) NOT NULL,
  primary_skill VARCHAR(20),

  -- Trust & Verification
  verification_status VARCHAR(20) DEFAULT 'unverified',
  trust_contribution FLOAT NOT NULL DEFAULT 0.0,

  -- Artifact Storage
  artifact_uri VARCHAR(500),
  artifact_type VARCHAR(20),

  -- Visibility & Sharing
  is_public BOOLEAN DEFAULT FALSE,
  is_portfolio_item BOOLEAN DEFAULT FALSE,

  -- Metadata
  earned_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP
)
COMMENT = 'Portfolio of user accomplishments and skill evidence. Includes scenario completions, artifacts, badges, certificates, and endorsements.';

-- ==============================================================================
-- Sample Data (for testing)
-- ==============================================================================

-- Sample Evidence 1: Completed PM scenario
INSERT INTO USER_EVIDENCE VALUES (
  'ev_20251021_001',
  'pid_device_xyz123',
  'scenario_run',
  'run_20251021_001',
  'Product Manager Scenario: Scope Creep',
  'Successfully navigated stakeholder pressure and scope changes while maintaining team focus and timeline.',
  '2.B.1.b,2.B.1.d,2.B.1.a,2.C.4.c',
  '2.B.1.a',
  'system_verified',
  0.45,
  'https://mypath.app/evidence/run_20251021_001',
  NULL,
  TRUE,
  TRUE,
  '2025-10-21 10:15:00',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULL
);

-- Sample Evidence 2: Completed Nurse scenario
INSERT INTO USER_EVIDENCE VALUES (
  'ev_20251021_002',
  'pid_device_xyz123',
  'scenario_run',
  'run_20251021_002',
  'Registered Nurse Scenario: Emergency Triage',
  'Demonstrated clinical judgment and prioritization in high-pressure emergency room situation.',
  '2.B.1.a,2.C.4.c,2.B.1.e',
  '2.B.1.a',
  'system_verified',
  0.50,
  'https://mypath.app/evidence/run_20251021_002',
  NULL,
  TRUE,
  TRUE,
  '2025-10-21 14:18:00',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULL
);

-- Sample Evidence 3: User-uploaded artifact
INSERT INTO USER_EVIDENCE VALUES (
  'ev_20251015_003',
  'pid_device_xyz123',
  'artifact',
  NULL,
  'Product Roadmap - Q4 2025',
  'Created comprehensive product roadmap for mobile app launch, including feature prioritization and timeline.',
  '2.B.1.b,2.C.4.c,2.B.1.d',
  '2.B.1.b',
  'self_reported',
  0.20,
  's3://mypath-artifacts/pid_device_xyz123/roadmap_q4_2025.pdf',
  'pdf',
  FALSE,
  TRUE,
  '2025-10-15 12:00:00',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULL
);

-- Sample Evidence 4: External badge
INSERT INTO USER_EVIDENCE VALUES (
  'ev_20250901_004',
  'pid_device_abc456',
  'certificate',
  'credly_badge_12345',
  'CPR & First Aid Certification',
  'American Red Cross CPR and First Aid certification',
  '2.B.1.a,2.C.4.c',
  '2.B.1.a',
  'external_verified',
  0.70,
  'https://credly.com/badges/12345',
  NULL,
  TRUE,
  TRUE,
  '2025-09-01 10:00:00',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  '2027-09-01 10:00:00'
);

-- Sample Evidence 5: Peer endorsement
INSERT INTO USER_EVIDENCE VALUES (
  'ev_20251010_005',
  'pid_device_abc456',
  'endorsement',
  'endorsement_peer_001',
  'Team Leadership - Student Council',
  'Endorsed by Student Council Advisor for exceptional leadership during Fall 2025 fundraising campaign.',
  '2.B.1.b,2.B.1.d',
  '2.B.1.b',
  'peer_verified',
  0.35,
  NULL,
  NULL,
  FALSE,
  FALSE,
  '2025-10-10 15:00:00',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULL
);

-- Sample Evidence 6: Work sample (image)
INSERT INTO USER_EVIDENCE VALUES (
  'ev_20251005_006',
  'pid_device_def789',
  'artifact',
  NULL,
  'Science Fair Poster - Renewable Energy',
  'Designed research poster for regional science fair. Placed 2nd in Engineering category.',
  '2.A.1.a,2.B.1.a',
  '2.B.1.a',
  'self_reported',
  0.25,
  's3://mypath-artifacts/pid_device_def789/science_fair_poster.jpg',
  'image',
  TRUE,
  TRUE,
  '2025-10-05 14:00:00',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULL
);

-- ==============================================================================
-- Validation Queries (run after deployment)
-- ==============================================================================

-- Verify evidence loaded
SELECT COUNT(*) as evidence_count FROM USER_EVIDENCE;
-- Expected: 6

-- Check evidence breakdown by type
SELECT
  evidence_type,
  COUNT(*) as count,
  AVG(trust_contribution) as avg_trust_contribution,
  SUM(CASE WHEN is_portfolio_item THEN 1 ELSE 0 END) as portfolio_items
FROM USER_EVIDENCE
GROUP BY evidence_type
ORDER BY count DESC;

-- Check verification status distribution
SELECT
  verification_status,
  COUNT(*) as count,
  AVG(trust_contribution) as avg_trust_contribution
FROM USER_EVIDENCE
GROUP BY verification_status
ORDER BY avg_trust_contribution DESC;

-- User evidence summary
SELECT
  user_pid,
  COUNT(*) as total_evidence,
  SUM(CASE WHEN is_portfolio_item THEN 1 ELSE 0 END) as portfolio_items,
  SUM(CASE WHEN is_public THEN 1 ELSE 0 END) as public_items,
  AVG(trust_contribution) as avg_trust_contribution,
  MAX(earned_at) as most_recent_evidence
FROM USER_EVIDENCE
GROUP BY user_pid;

-- Find high-value evidence (trust contribution >= 0.4)
SELECT
  user_pid,
  evidence_type,
  title,
  primary_skill,
  verification_status,
  trust_contribution,
  earned_at
FROM USER_EVIDENCE
WHERE trust_contribution >= 0.4
ORDER BY trust_contribution DESC;

-- ==============================================================================
-- Maintenance Notes
-- ==============================================================================

-- To add new evidence:
-- INSERT INTO USER_EVIDENCE VALUES (...);

-- To update verification status (e.g., after peer review):
-- UPDATE USER_EVIDENCE
-- SET
--   verification_status = 'peer_verified',
--   trust_contribution = 0.35,
--   updated_at = CURRENT_TIMESTAMP
-- WHERE evidence_id = 'ev_xxx';

-- To add to portfolio:
-- UPDATE USER_EVIDENCE
-- SET is_portfolio_item = TRUE, updated_at = CURRENT_TIMESTAMP
-- WHERE evidence_id = 'ev_xxx';

-- To mark as public/shareable:
-- UPDATE USER_EVIDENCE
-- SET is_public = TRUE, updated_at = CURRENT_TIMESTAMP
-- WHERE evidence_id = 'ev_xxx';

-- ==============================================================================
-- End of Script
-- ==============================================================================
