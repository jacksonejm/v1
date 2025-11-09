-- ==============================================================================
-- Phase 1: Foundation - Table 3 of 6
-- BEHAVIORAL_SIGNALS: Skill signal definitions and weights
-- ==============================================================================
-- Created: 2025-10-21
-- Purpose: Define behavioral signals that can be inferred from user choices
--          Maps signal codes to skill IDs with confidence weights
-- ==============================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Drop table if exists (for development only - remove in production)
-- DROP TABLE IF EXISTS BEHAVIORAL_SIGNALS;

CREATE TABLE IF NOT EXISTS BEHAVIORAL_SIGNALS (
  -- Primary Key
  signal_id VARCHAR(50) PRIMARY KEY,

  -- Signal Definition
  signal_name VARCHAR(100) NOT NULL,
  signal_category VARCHAR(50) NOT NULL,

  -- Skill Mapping
  onet_skill_id VARCHAR(20),
  skill_name VARCHAR(255),

  -- Confidence & Weighting
  base_weight FLOAT NOT NULL DEFAULT 1.0,
  proficiency_level INT NOT NULL,

  -- Context (comma-delimited tags)
  context_tags VARCHAR(500),

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
)
COMMENT = 'Defines behavioral signals that can be inferred from user choices in scenarios. Maps signals to O*NET skills with confidence weights and proficiency levels.';

-- ==============================================================================
-- Sample Data (for testing)
-- ==============================================================================

-- Leadership Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('delegation_l2', 'Delegation', 'Leadership', '2.B.1.b', 'Coordination', 0.75, 2, 'team_management,project_management', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('assertiveness_l2', 'Assertiveness', 'Leadership', '2.B.1.d', 'Persuasion', 0.70, 2, 'stakeholder_management,conflict_resolution', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('prioritization_l2', 'Prioritization', 'Leadership', '2.C.4.c', 'Time Management', 0.80, 2, 'project_management,deadline_pressure', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- Analytical Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('analytical_thinking_l3', 'Analytical Thinking', 'Cognitive', '2.B.1.a', 'Critical Thinking', 0.85, 3, 'problem_solving,data_driven', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('risk_assessment_l2', 'Risk Assessment', 'Cognitive', '2.B.1.a', 'Critical Thinking', 0.75, 2, 'decision_making,strategic_planning', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('decision_making_l3', 'Decision Making', 'Cognitive', '2.B.1.a', 'Critical Thinking', 0.90, 3, 'leadership,autonomy', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- Clinical/Healthcare Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('clinical_judgment_l3', 'Clinical Judgment', 'Domain-Specific', '2.B.1.a', 'Critical Thinking', 0.90, 3, 'healthcare,emergency_response', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('prioritization_l3', 'Advanced Prioritization', 'Cognitive', '2.C.4.c', 'Time Management', 0.85, 3, 'emergency,triage', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('critical_thinking_l3', 'Critical Thinking', 'Cognitive', '2.B.1.a', 'Critical Thinking', 0.88, 3, 'complex_problem,high_stakes', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- Interpersonal Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('empathy_l2', 'Empathy', 'Interpersonal', '2.B.1.e', 'Social Perceptiveness', 0.70, 2, 'patient_care,counseling', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('empathy_l3', 'Advanced Empathy', 'Interpersonal', '2.B.1.e', 'Social Perceptiveness', 0.85, 3, 'crisis_management,therapeutic', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('active_listening_l2', 'Active Listening', 'Interpersonal', '2.A.1.b', 'Active Listening', 0.75, 2, 'communication,student_support', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('conflict_resolution_l2', 'Conflict Resolution', 'Interpersonal', '2.B.1.d', 'Negotiation', 0.80, 2, 'classroom,team_dynamics', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- Communication Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('stakeholder_communication_l2', 'Stakeholder Communication', 'Communication', '2.A.1.a', 'Reading Comprehension', 0.70, 2, 'business,external_relations', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('communication_l2', 'Communication', 'Communication', '2.A.1.a', 'Oral Expression', 0.75, 2, 'patient_care,teaching', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('classroom_management_l2', 'Classroom Management', 'Domain-Specific', '2.B.1.b', 'Coordination', 0.80, 2, 'education,group_facilitation', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- Teamwork & Collaboration Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('teamwork_l2', 'Teamwork', 'Interpersonal', '2.B.1.b', 'Coordination', 0.75, 2, 'collaborative,cross_functional', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('relationship_building_l2', 'Relationship Building', 'Interpersonal', '2.B.1.e', 'Social Perceptiveness', 0.65, 2, 'education,mentoring', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- Adaptability Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('flexibility_l2', 'Flexibility', 'Adaptability', '2.C.4.a', 'Adaptability/Flexibility', 0.70, 2, 'changing_requirements,agile', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('negotiation_l2', 'Negotiation', 'Interpersonal', '2.B.1.d', 'Negotiation', 0.75, 2, 'stakeholder_management,conflict', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('patience_l2', 'Patience', 'Interpersonal', '2.C.7.b', 'Self Control', 0.65, 2, 'education,customer_service', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- Values & Ethics Signals
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('fairness_l3', 'Fairness', 'Ethics', '2.C.9', 'Integrity', 0.85, 3, 'education,justice', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE),
  ('integrity_l3', 'Integrity', 'Ethics', '2.C.9', 'Integrity', 0.90, 3, 'leadership,ethical_decision', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, TRUE);

-- ==============================================================================
-- Validation Queries (run after deployment)
-- ==============================================================================

-- Verify signals loaded
SELECT COUNT(*) as signal_count FROM BEHAVIORAL_SIGNALS;
-- Expected: 23

-- Check signal distribution by category
SELECT
  signal_category,
  COUNT(*) as signal_count,
  AVG(base_weight) as avg_weight,
  AVG(proficiency_level) as avg_level
FROM BEHAVIORAL_SIGNALS
GROUP BY signal_category
ORDER BY signal_count DESC;

-- Find high-confidence signals (weight >= 0.8)
SELECT
  signal_id,
  signal_name,
  base_weight,
  proficiency_level,
  skill_name
FROM BEHAVIORAL_SIGNALS
WHERE base_weight >= 0.8
ORDER BY base_weight DESC;

-- ==============================================================================
-- Maintenance Notes
-- ==============================================================================

-- To add a new signal:
-- INSERT INTO BEHAVIORAL_SIGNALS VALUES (...);

-- To update signal weight:
-- UPDATE BEHAVIORAL_SIGNALS
-- SET base_weight = 0.85, updated_at = CURRENT_TIMESTAMP
-- WHERE signal_id = 'new_signal_id';

-- To deactivate a signal:
-- UPDATE BEHAVIORAL_SIGNALS SET is_active = FALSE WHERE signal_id = 'signal_xxx';

-- ==============================================================================
-- End of Script
-- ==============================================================================
