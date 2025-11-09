-- ==============================================================================
-- Phase 1: Foundation - Table 2 of 6
-- SCENARIO_RUNS: Track user storyline completions and decisions
-- ==============================================================================
-- Created: 2025-10-21
-- Purpose: Store each user's completion of a scenario template, including all
--          decisions made and behavioral signals generated
-- ==============================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Drop table if exists (for development only - remove in production)
-- DROP TABLE IF EXISTS SCENARIO_RUNS;

CREATE TABLE IF NOT EXISTS SCENARIO_RUNS (
  -- Primary Key
  run_id VARCHAR(50) PRIMARY KEY,

  -- User & Role Association
  user_pid VARCHAR(100) NOT NULL,
  onet_code VARCHAR(20) NOT NULL,
  template_id VARCHAR(50) NOT NULL,

  -- Timing
  started_at TIMESTAMP NOT NULL,
  finished_at TIMESTAMP,
  duration_seconds INT,

  -- Decision Trail (stored as JSON string)
  decisions VARCHAR(10000) NOT NULL,

  -- Behavioral Signals (computed from decisions, stored as JSON string)
  signals VARCHAR(10000),

  -- Evidence & Output
  evidence_uri VARCHAR(500),
  completion_status VARCHAR(20) DEFAULT 'in_progress',

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
COMMENT = 'Tracks each user completion of a storyline scenario. Stores all decisions made and computed behavioral signals. Used for skill assessment and evidence generation.';

-- ==============================================================================
-- Sample Data (for testing)
-- ==============================================================================

-- Sample Run 1: Completed PM scenario
INSERT INTO SCENARIO_RUNS (
  run_id,
  user_pid,
  onet_code,
  template_id,
  started_at,
  finished_at,
  duration_seconds,
  decisions,
  signals,
  evidence_uri,
  completion_status
) VALUES (
  'run_20251021_001',
  'pid_device_xyz123',
  '15-1299.09',
  'tmpl_pm_scope',
  '2025-10-21 10:00:00',
  '2025-10-21 10:15:00',
  900,
  '[{"node": "d1", "choice": "b", "timestamp": "2025-10-21T10:05:00Z"}, {"node": "d2", "choice": "a", "timestamp": "2025-10-21T10:12:00Z"}]',
  '{"delegation_l2": 0.75, "assertiveness_l2": 0.75, "analytical_thinking_l3": 0.85, "risk_assessment_l2": 0.70}',
  'https://mypath.app/evidence/run_20251021_001',
  'completed'
);

-- Sample Run 2: Completed Nurse scenario
INSERT INTO SCENARIO_RUNS (
  run_id,
  user_pid,
  onet_code,
  template_id,
  started_at,
  finished_at,
  duration_seconds,
  decisions,
  signals,
  evidence_uri,
  completion_status
) VALUES (
  'run_20251021_002',
  'pid_device_xyz123',
  '29-1141.00',
  'tmpl_nurse_triage',
  '2025-10-21 14:00:00',
  '2025-10-21 14:18:00',
  1080,
  '[{"node": "d1", "choice": "a", "timestamp": "2025-10-21T14:08:00Z"}, {"node": "d2", "choice": "a", "timestamp": "2025-10-21T14:15:00Z"}]',
  '{"clinical_judgment_l3": 0.90, "prioritization_l3": 0.85, "critical_thinking_l3": 0.88, "decision_making_l3": 0.87}',
  'https://mypath.app/evidence/run_20251021_002',
  'completed'
);

-- Sample Run 3: In-progress Teacher scenario
INSERT INTO SCENARIO_RUNS (
  run_id,
  user_pid,
  onet_code,
  template_id,
  started_at,
  finished_at,
  duration_seconds,
  decisions,
  signals,
  completion_status
) VALUES (
  'run_20251021_003',
  'pid_device_abc456',
  '25-2031.00',
  'tmpl_teacher_conflict',
  '2025-10-21 16:00:00',
  NULL,
  NULL,
  '[{"node": "d1", "choice": "a", "timestamp": "2025-10-21T16:03:00Z"}]',
  NULL,
  'in_progress'
);

-- ==============================================================================
-- Validation Queries (run after deployment)
-- ==============================================================================

-- Verify runs loaded
SELECT COUNT(*) as run_count FROM SCENARIO_RUNS;
-- Expected: 3

-- Check completion status breakdown
SELECT
  completion_status,
  COUNT(*) as count,
  AVG(duration_seconds) as avg_duration_sec
FROM SCENARIO_RUNS
WHERE completion_status = 'completed'
GROUP BY completion_status;

-- View user history
SELECT
  user_pid,
  COUNT(*) as total_runs,
  SUM(CASE WHEN completion_status = 'completed' THEN 1 ELSE 0 END) as completed_runs,
  AVG(CASE WHEN completion_status = 'completed' THEN duration_seconds END) as avg_duration_sec
FROM SCENARIO_RUNS
GROUP BY user_pid;

-- ==============================================================================
-- Maintenance Notes
-- ==============================================================================

-- To mark a run as completed:
-- UPDATE SCENARIO_RUNS
-- SET
--   finished_at = CURRENT_TIMESTAMP,
--   duration_seconds = DATEDIFF(second, started_at, CURRENT_TIMESTAMP),
--   completion_status = 'completed',
--   signals = '{"skill_id": score, ...}',
--   evidence_uri = 'https://...',
--   updated_at = CURRENT_TIMESTAMP
-- WHERE run_id = 'run_xxx';

-- To find abandoned runs (started > 24 hours ago, not finished):
-- SELECT * FROM SCENARIO_RUNS
-- WHERE completion_status = 'in_progress'
--   AND started_at < DATEADD(hour, -24, CURRENT_TIMESTAMP);

-- To get user's most recent run:
-- SELECT * FROM SCENARIO_RUNS
-- WHERE user_pid = 'pid_xxx'
-- ORDER BY started_at DESC
-- LIMIT 1;

-- ==============================================================================
-- End of Script
-- ==============================================================================
