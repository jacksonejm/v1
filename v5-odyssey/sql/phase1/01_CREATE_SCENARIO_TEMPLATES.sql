-- ==============================================================================
-- Phase 1: Foundation - Table 1 of 6
-- SCENARIO_TEMPLATES: Storyline templates for behavioral simulations
-- ==============================================================================
-- Created: 2025-10-21
-- Purpose: Store scenario templates that users can complete to demonstrate skills
--          Each template represents a realistic workplace situation for a specific role
-- ==============================================================================

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

-- Drop table if exists (for development only - remove in production)
-- DROP TABLE IF EXISTS SCENARIO_TEMPLATES;

CREATE TABLE IF NOT EXISTS SCENARIO_TEMPLATES (
  -- Primary Key
  template_id VARCHAR(50) PRIMARY KEY,

  -- Role Association
  onet_code VARCHAR(20) NOT NULL,
  role_title VARCHAR(255) NOT NULL,

  -- Difficulty & Context
  difficulty INT NOT NULL,
  context_tags VARCHAR(1000),  -- Comma-delimited: "remote,team,deadline"

  -- Scenario Logic (stored as JSON strings)
  decision_rubric VARCHAR(10000) NOT NULL,
  content_seed VARCHAR(10000),

  -- Metadata
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(50) DEFAULT 'system',
  is_active BOOLEAN DEFAULT TRUE
)
COMMENT = 'Storyline templates for behavioral simulations. Each template represents a realistic workplace scenario that users can complete to demonstrate skills and generate evidence.';

-- ==============================================================================
-- Sample Data (for testing)
-- ==============================================================================

-- Product Manager: Scope Creep Scenario
INSERT INTO SCENARIO_TEMPLATES (
  template_id,
  onet_code,
  role_title,
  difficulty,
  context_tags,
  decision_rubric,
  content_seed
) VALUES (
  'tmpl_pm_scope',
  '15-1299.09',
  'Associate Product Manager',
  3,
  'remote,team,deadline,stakeholder_management',
  '{"d1": {"choice_a": ["prioritization_l2", "stakeholder_communication_l2"], "choice_b": ["delegation_l2", "assertiveness_l2"]}, "d2": {"choice_a": ["analytical_thinking_l3", "risk_assessment_l2"], "choice_b": ["flexibility_l2", "negotiation_l2"]}}',
  '{"context": "Tech startup - mobile app development", "team_size": 5, "timeline": "2 weeks to launch", "scenario_type": "scope_creep", "constraints": ["time_pressure", "limited_resources", "first_time_pm"]}'
);

-- Registered Nurse: Triage Priority Scenario
INSERT INTO SCENARIO_TEMPLATES (
  template_id,
  onet_code,
  role_title,
  difficulty,
  context_tags,
  decision_rubric,
  content_seed
) VALUES (
  'tmpl_nurse_triage',
  '29-1141.00',
  'Registered Nurse',
  4,
  'hospital,emergency,time_pressure,patient_care',
  '{"d1": {"choice_a": ["clinical_judgment_l3", "prioritization_l3"], "choice_b": ["empathy_l2", "communication_l2"]}, "d2": {"choice_a": ["critical_thinking_l3", "decision_making_l3"], "choice_b": ["teamwork_l2", "delegation_l2"]}}',
  '{"context": "Emergency room - busy Friday night", "team_size": 3, "scenario_type": "triage_priority", "constraints": ["limited_beds", "multiple_patients", "varied_severity"]}'
);

-- High School Teacher: Student Conflict Scenario
INSERT INTO SCENARIO_TEMPLATES (
  template_id,
  onet_code,
  role_title,
  difficulty,
  context_tags,
  decision_rubric,
  content_seed
) VALUES (
  'tmpl_teacher_conflict',
  '25-2031.00',
  'High School Teacher',
  2,
  'classroom,conflict_resolution,adolescents',
  '{"d1": {"choice_a": ["active_listening_l2", "empathy_l3"], "choice_b": ["assertiveness_l2", "classroom_management_l2"]}, "d2": {"choice_a": ["conflict_resolution_l2", "fairness_l3"], "choice_b": ["relationship_building_l2", "patience_l2"]}}',
  '{"context": "High school classroom - 10th grade", "class_size": 28, "scenario_type": "student_conflict", "constraints": ["public_setting", "time_limited", "peer_pressure"]}'
);

-- ==============================================================================
-- Validation Queries (run after deployment)
-- ==============================================================================

-- Verify all templates loaded
SELECT COUNT(*) as template_count FROM SCENARIO_TEMPLATES;
-- Expected: 3

-- Check template structure
SELECT
  template_id,
  role_title,
  difficulty,
  context_tags,
  is_active
FROM SCENARIO_TEMPLATES
ORDER BY difficulty;

-- ==============================================================================
-- Maintenance Notes
-- ==============================================================================

-- To add a new template:
-- INSERT INTO SCENARIO_TEMPLATES (...) VALUES (...);

-- To deactivate a template (instead of deleting):
-- UPDATE SCENARIO_TEMPLATES SET is_active = FALSE WHERE template_id = 'tmpl_xxx';

-- To update difficulty:
-- UPDATE SCENARIO_TEMPLATES SET difficulty = 4, updated_at = CURRENT_TIMESTAMP()
-- WHERE template_id = 'tmpl_xxx';

-- ==============================================================================
-- End of Script
-- ==============================================================================
