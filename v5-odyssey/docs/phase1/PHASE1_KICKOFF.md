# Phase 1: Foundation - Kickoff Document

**MyPath v5.0 "Odyssey" - Phase 1**

**Status:** 🚀 IN PROGRESS
**Start Date:** October 21, 2025
**Target End Date:** November 15, 2025
**Duration:** 3-4 weeks
**Lead:** TBD

---

## 📋 Executive Summary

Phase 1 establishes the **data foundation and service layer** for v5.0 Odyssey. This phase creates the database schema and stored procedures needed to support:

- **Personal Interest Dimensions (PID)** scoring
- **Skill gap analysis** and recommendations
- **Career pathfinding** (trajectories)
- **Opportunity matching** (campus clubs, internships, scholarships)
- **Behavioral evidence** tracking from storylines

**Key Deliverables:**
- ✅ 6 new Snowflake tables
- ✅ 4 new stored procedures
- ✅ 4 Swift service layer classes
- ✅ 30+ integration tests
- ✅ Complete API documentation

---

## 🎯 Objectives

### Primary Objectives
1. **Database Schema** - Create 6 tables to store user profiles, skills, evidence, and opportunities
2. **Stored Procedures** - Implement 4 SPs for skill gaps, trajectories, opportunities, and run ingestion
3. **Service Layer** - Build 4 Swift services to interface with Snowflake
4. **Testing** - Achieve 85%+ code coverage on new components

### Success Criteria
- [ ] All 6 tables created and validated in Snowflake
- [ ] All 4 stored procedures tested with sample data
- [ ] All 4 services implemented with error handling
- [ ] 30+ tests passing (100% success rate)
- [ ] API response time < 500ms for all queries
- [ ] Complete documentation (API docs + integration guide)

---

## 📦 Deliverables

### Week 1: Database Schema (6 Tables)

#### 1. SCENARIO_TEMPLATES
**Purpose:** Store storyline templates for behavioral simulations

```sql
CREATE TABLE SCENARIO_TEMPLATES (
  template_id STRING PRIMARY KEY,
  onet_code STRING,              -- Associated career role
  role_title STRING,             -- "Associate Product Manager"
  difficulty INT,                -- 1-5 scale
  context_tags ARRAY,            -- ["remote","team","deadline"]
  decision_rubric VARIANT,       -- Maps choices → behavioral signals
  content_seed VARIANT           -- Prompt fragments, constraints
);
```

**Sample Data:**
- `tmpl_pm_scope` - Product Manager scope creep scenario
- `tmpl_nurse_triage` - Nurse triage priority scenario
- `tmpl_teacher_conflict` - Teacher student conflict scenario

**Status:** 📋 Pending

---

#### 2. SCENARIO_RUNS
**Purpose:** Track user storyline completions and decisions

```sql
CREATE TABLE SCENARIO_RUNS (
  run_id STRING PRIMARY KEY,
  user_pid STRING,               -- Device-scoped user ID
  onet_code STRING,              -- Career role tested
  template_id STRING,            -- Which scenario
  started_at TIMESTAMP,
  finished_at TIMESTAMP,
  decisions VARIANT,             -- [{node:"d1", choice:"b", ts:...}]
  signals VARIANT,               -- Aggregated behavioral signals
  evidence_uri STRING            -- Link to summary/artifact
);
```

**Indexes:**
- `user_pid` (for user history queries)
- `template_id` (for scenario analytics)

**Status:** 📋 Pending

---

#### 3. BEHAVIORAL_SIGNALS
**Purpose:** Map scenario choices to skill evidence

```sql
CREATE TABLE BEHAVIORAL_SIGNALS (
  signal_code STRING,            -- "delegation_l2", "empathy_l3"
  skill_id STRING,               -- Unified skill graph ID
  weight FLOAT                   -- Signal strength (0.0-1.0)
);
```

**Sample Data:**
```sql
INSERT INTO BEHAVIORAL_SIGNALS VALUES
  ('delegation_l2', 'leadership_delegation', 0.75),
  ('active_listening_l3', 'communication_active_listening', 0.90),
  ('prioritization_l2', 'organization_prioritization', 0.70);
```

**Status:** 📋 Pending

---

#### 4. USER_SKILLS
**Purpose:** Track user skill levels with trust scores

```sql
CREATE TABLE USER_SKILLS (
  user_pid STRING,
  skill_id STRING,
  level FLOAT,                   -- 0.0-1.0 (current proficiency)
  trust_score FLOAT,             -- Confidence in assessment
  last_evidence_at TIMESTAMP,
  PRIMARY KEY (user_pid, skill_id)
);
```

**Trust Score Algorithm:**
- Evidence from multiple sources → higher trust
- Recent evidence → higher trust
- Time decay → lower trust over time

**Status:** 📋 Pending

---

#### 5. USER_EVIDENCE
**Purpose:** Store user accomplishments and artifacts

```sql
CREATE TABLE USER_EVIDENCE (
  evidence_id STRING PRIMARY KEY,
  user_pid STRING,
  source STRING,                 -- "storyline", "sprint", "project"
  onet_code STRING,              -- Related career
  summary STRING,                -- "Completed PM scope scenario"
  artifact_uri STRING,           -- Link to certificate/badge
  verified_by STRING,            -- Null, "self", "mentor", "system"
  created_at TIMESTAMP
);
```

**Use Cases:**
- Portfolio building
- Skill verification
- Resume generation
- Mentor reviews

**Status:** 📋 Pending

---

#### 6. CAMPUS_OPPORTUNITIES
**Purpose:** Store student opportunities (clubs, internships, scholarships)

```sql
CREATE TABLE CAMPUS_OPPORTUNITIES (
  opp_id STRING PRIMARY KEY,
  org_type STRING,               -- "club", "competition", "scholarship", "internship"
  audience STRING,               -- "HS", "College", "Both"
  school_id STRING,              -- Nullable for public opps
  title STRING,                  -- "Data Club (Beginner Track)"
  description STRING,
  skill_tags ARRAY,              -- Skill IDs for matching/bridge
  start_date DATE,
  end_date DATE,
  apply_uri STRING
);
```

**Example Records:**
```sql
-- High School Opportunity
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'club_data_hs_001',
  'club',
  'HS',
  NULL,  -- Public
  'Data Science Club (Beginner)',
  'Learn Python, analyze real-world datasets...',
  ['python_basics', 'data_analysis_intro'],
  '2025-09-01',
  '2026-06-15',
  'https://example.edu/dataclub'
);

-- College Internship
INSERT INTO CAMPUS_OPPORTUNITIES VALUES (
  'intern_analytics_001',
  'internship',
  'College',
  'stanford_001',
  'Analytics Intern - Summer 2026',
  'Work with marketing team on A/B testing...',
  ['sql_queries', 'dashboarding', 'statistics'],
  '2026-06-01',
  '2026-08-31',
  'https://careers.example.com/intern'
);
```

**Status:** 📋 Pending

---

### Week 2: Stored Procedures (4 SPs)

#### 1. SP_GET_SKILL_GAPS
**Purpose:** Calculate skill gaps for a target career role

```sql
CREATE OR REPLACE PROCEDURE SP_GET_SKILL_GAPS(
  user_pid STRING,
  onet_code STRING
)
RETURNS VARIANT
AS $$
DECLARE
  user_skills VARIANT;
  role_requirements VARIANT;
  gaps VARIANT;
BEGIN
  -- 1. Fetch user's current skills from USER_SKILLS
  -- 2. Fetch role requirements from ONET_SKILLS/ABILITIES
  -- 3. Calculate gaps (target - current)
  -- 4. Prioritize by importance × gap size
  -- 5. Recommend SkillSprints to close gaps

  RETURN {
    "role": role_title,
    "gaps": [
      {
        "skill_id": "sql_queries",
        "current": 0.4,
        "target": 0.7,
        "priority": 0.92,
        "gap_size": 0.3
      }
    ],
    "recommended_sprints": ["sql_joins_101", "active_listening_basics"]
  };
END;
$$;
```

**Output Example:**
```json
{
  "role": "Data Analyst",
  "gaps": [
    {
      "skill_id": "sql_queries",
      "current": 0.4,
      "target": 0.7,
      "priority": 0.92,
      "gap_size": 0.3
    },
    {
      "skill_id": "requirements_gathering",
      "current": 0.5,
      "target": 0.8,
      "priority": 0.81,
      "gap_size": 0.3
    }
  ],
  "recommended_sprints": ["sql_joins_101", "active_listening_basics"]
}
```

**Status:** 📋 Pending

---

#### 2. SP_INGEST_SCENARIO_RUN
**Purpose:** Process storyline completion and update user skills

```sql
CREATE OR REPLACE PROCEDURE SP_INGEST_SCENARIO_RUN(
  run VARIANT
)
RETURNS VARIANT
AS $$
BEGIN
  -- 1. Insert into SCENARIO_RUNS
  -- 2. Extract behavioral signals from decisions
  -- 3. Map signals to skills via BEHAVIORAL_SIGNALS
  -- 4. Update USER_SKILLS with new evidence
  --    - Apply trust score algorithm
  --    - Handle time decay
  -- 5. Create USER_EVIDENCE record

  RETURN {
    "run_id": run_id,
    "skills_updated": 3,
    "evidence_id": evidence_id
  };
END;
$$;
```

**Input Example:**
```json
{
  "run_id": "run_20251021_001",
  "user_pid": "pid_device_xyz",
  "onet_code": "15-1299.09",
  "template_id": "tmpl_pm_scope",
  "started_at": "2025-10-21T10:00:00Z",
  "finished_at": "2025-10-21T10:15:00Z",
  "decisions": [
    {"node": "d1", "choice": "b", "timestamp": "2025-10-21T10:05:00Z"},
    {"node": "d2", "choice": "a", "timestamp": "2025-10-21T10:12:00Z"}
  ]
}
```

**Status:** 📋 Pending

---

#### 3. SP_GET_OPPORTUNITIES
**Purpose:** Match user to Ready vs Stretch opportunities

```sql
CREATE OR REPLACE PROCEDURE SP_GET_OPPORTUNITIES(
  user_pid STRING,
  audience STRING  -- "HS", "College"
)
RETURNS VARIANT
AS $$
BEGIN
  -- 1. Fetch user skills from USER_SKILLS
  -- 2. Fetch opportunities from CAMPUS_OPPORTUNITIES (filtered by audience)
  -- 3. Calculate fit score for each opportunity
  -- 4. Classify as "ready_now" or "stretch"
  -- 5. For stretch: identify bridge skills needed
  -- 6. Estimate time to become ready

  RETURN {
    "ready_now": [...],
    "stretch": [...]
  };
END;
$$;
```

**Output Example:**
```json
{
  "ready_now": [
    {
      "opp_id": "club_123",
      "title": "Data Club (Beginner Track)",
      "fit_score": 0.87,
      "fit_reasons": ["matches interests", "time commitment fits schedule"],
      "why": ["skill: curiosity", "values: achievement"],
      "apply_uri": "https://school.edu/dataclub"
    }
  ],
  "stretch": [
    {
      "opp_id": "intern_456",
      "title": "Analytics Intern",
      "fit_score": 0.65,
      "bridge_skills": ["sql_queries", "dashboarding"],
      "estimated_time_weeks": 6,
      "prepare_pack": ["sql_joins_101", "tableau_basics"]
    }
  ]
}
```

**Status:** 📋 Pending

---

#### 4. SP_GET_TRAJECTORIES
**Purpose:** Generate career pathways for constellation view

```sql
CREATE OR REPLACE PROCEDURE SP_GET_TRAJECTORIES(
  user_pid STRING
)
RETURNS VARIANT
AS $$
BEGIN
  -- 1. Fetch user's current skills, interests, values
  -- 2. Cluster related careers based on skill overlap
  -- 3. Estimate effort/time to transition
  -- 4. Include XAI features (why this path is suggested)

  RETURN {
    "trajectories": [
      {
        "from_role": "Current Student",
        "to_role": "Data Analyst",
        "effort_weeks": 12,
        "key_skills": ["sql_queries", "python_basics", "statistics"],
        "why_features": ["interests: problem-solving", "values: impact"]
      }
    ]
  };
END;
$$;
```

**Output Example:**
```json
{
  "trajectories": [
    {
      "trajectory_id": "traj_001",
      "from_role": "Current Student",
      "to_role": "Data Analyst",
      "effort_weeks": 12,
      "difficulty": "Medium",
      "key_skills": ["sql_queries", "python_basics", "statistics"],
      "skill_gaps": ["sql_queries", "dashboarding"],
      "why_features": [
        "interests: problem-solving (85% match)",
        "values: impact (90% match)"
      ],
      "next_steps": ["Take SQL basics sprint", "Join Data Club"]
    }
  ]
}
```

**Status:** 📋 Pending

---

### Week 3: Service Layer (4 Services)

#### 1. TrajectoryService.swift
**Purpose:** Manage career trajectory API calls

```swift
protocol TrajectoryServiceProtocol {
    func fetchTrajectories(userPid: String) async throws -> [Trajectory]
    func applyWhatIf(userPid: String, skillId: String) async throws -> TrajectoryDelta
}

class TrajectoryService: TrajectoryServiceProtocol {
    private let snowflakeService: SnowflakeService

    func fetchTrajectories(userPid: String) async throws -> [Trajectory] {
        let response = try await snowflakeService.execute(
            procedure: "SP_GET_TRAJECTORIES",
            parameters: ["user_pid": userPid]
        )
        return try decodeTrajectories(response)
    }

    func applyWhatIf(userPid: String, skillId: String) async throws -> TrajectoryDelta {
        // Calculate how trajectories change if user gains a skill
        // Used for "What-If" drag feature in Constellation
    }
}
```

**Status:** 📋 Pending

---

#### 2. SimulationService.swift
**Purpose:** Manage storyline scenario API calls

```swift
protocol SimulationServiceProtocol {
    func startScenario(onet: String, templateId: String) async throws -> ScenarioRun
    func submitDecision(runId: String, nodeId: String, choiceId: String) async throws -> Consequence
    func completeRun(_ run: ScenarioRun) async throws -> EvidenceChip
}

class SimulationService: SimulationServiceProtocol {
    private let snowflakeService: SnowflakeService

    func startScenario(onet: String, templateId: String) async throws -> ScenarioRun {
        // Initialize a new storyline run
        let runId = UUID().uuidString
        let userPid = UserDefaults.standard.string(forKey: "user_pid") ?? generatePID()

        return ScenarioRun(
            runId: runId,
            userPid: userPid,
            onetCode: onet,
            templateId: templateId,
            startedAt: Date(),
            decisions: []
        )
    }

    func submitDecision(runId: String, nodeId: String, choiceId: String) async throws -> Consequence {
        // Record decision and calculate consequence
        // Returns impact on trust scores, next scene
    }

    func completeRun(_ run: ScenarioRun) async throws -> EvidenceChip {
        // Call SP_INGEST_SCENARIO_RUN
        let response = try await snowflakeService.execute(
            procedure: "SP_INGEST_SCENARIO_RUN",
            parameters: ["run": run.toJSON()]
        )
        return try decodeEvidenceChip(response)
    }
}
```

**Status:** 📋 Pending

---

#### 3. SkillGraphService.swift
**Purpose:** Manage skill gap and recommendation API calls

```swift
protocol SkillGraphServiceProtocol {
    func getGaps(userPid: String, onet: String) async throws -> SkillGaps
    func recommendSprints(for gaps: SkillGaps) -> [Sprint]
    func updateSkill(userPid: String, skillId: String, newLevel: Float) async throws
}

class SkillGraphService: SkillGraphServiceProtocol {
    private let snowflakeService: SnowflakeService

    func getGaps(userPid: String, onet: String) async throws -> SkillGaps {
        let response = try await snowflakeService.execute(
            procedure: "SP_GET_SKILL_GAPS",
            parameters: [
                "user_pid": userPid,
                "onet_code": onet
            ]
        )
        return try decodeSkillGaps(response)
    }

    func recommendSprints(for gaps: SkillGaps) -> [Sprint] {
        // Map gaps to SkillSprints (5-20 min learning modules)
        return gaps.gaps.compactMap { gap in
            SprintLibrary.findSprint(for: gap.skillId)
        }
    }
}
```

**Status:** 📋 Pending

---

#### 4. OpportunityService.swift
**Purpose:** Manage opportunity matching API calls

```swift
protocol OpportunityServiceProtocol {
    func fetchOpportunities(userPid: String, audience: Audience) async throws -> Opportunities
    func getPreparePack(for opportunity: Opportunity) -> [Sprint]
}

class OpportunityService: OpportunityServiceProtocol {
    private let snowflakeService: SnowflakeService

    func fetchOpportunities(userPid: String, audience: Audience) async throws -> Opportunities {
        let response = try await snowflakeService.execute(
            procedure: "SP_GET_OPPORTUNITIES",
            parameters: [
                "user_pid": userPid,
                "audience": audience.rawValue
            ]
        )
        return try decodeOpportunities(response)
    }

    func getPreparePack(for opportunity: Opportunity) -> [Sprint] {
        // For stretch opportunities, return sprints to close bridge skills
        return opportunity.bridgeSkills.compactMap { skillId in
            SprintLibrary.findSprint(for: skillId)
        }
    }
}
```

**Status:** 📋 Pending

---

### Week 4: Testing & Documentation

#### Integration Tests (30+ tests)

**TrajectoryServiceTests (8 tests)**
- `testFetchTrajectoriesSuccess` - Valid user PID returns trajectories
- `testFetchTrajectoriesEmpty` - New user returns empty/starter trajectories
- `testFetchTrajectoriesError` - Handle API errors gracefully
- `testWhatIfSkillAdd` - Adding skill changes trajectory effort
- `testWhatIfSkillRemove` - Removing skill increases effort
- `testTrajectoryParsing` - Correct JSON decoding
- `testTrajectoryCache` - Cache results for performance
- `testTrajectoryPerformance` - < 500ms response time

**SimulationServiceTests (8 tests)**
- `testStartScenario` - Initialize scenario run
- `testSubmitDecision` - Record decision and get consequence
- `testCompleteRun` - Ingest run and update skills
- `testEvidenceGeneration` - Create evidence chip
- `testMultipleRuns` - Handle concurrent runs
- `testInvalidTemplate` - Handle missing template
- `testScenarioParsing` - Correct JSON decoding
- `testSimulationPerformance` - < 500ms per decision

**SkillGraphServiceTests (8 tests)**
- `testGetSkillGaps` - Calculate gaps for target role
- `testRecommendSprints` - Map gaps to sprints
- `testUpdateSkill` - Update skill level
- `testTrustScoreCalculation` - Verify trust algorithm
- `testMultipleEvidence` - Multiple sources increase trust
- `testTimeDecay` - Old evidence decays trust
- `testGapPrioritization` - Correct priority ordering
- `testSkillGraphPerformance` - < 500ms response time

**OpportunityServiceTests (6 tests)**
- `testFetchOpportunities` - Get ready + stretch opps
- `testReadyNowFiltering` - Correct classification
- `testStretchBridgeSkills` - Identify bridge skills
- `testPreparePack` - Generate sprint recommendations
- `testAudienceFiltering` - HS vs College filtering
- `testOpportunityPerformance` - < 500ms response time

**Status:** 📋 Pending

---

#### API Documentation

**Format:** OpenAPI 3.0 specification

**Sections:**
1. Authentication (JWT via SnowflakeService)
2. Endpoint Reference
   - POST /sp/get_trajectories
   - POST /sp/get_skill_gaps
   - POST /sp/ingest_scenario_run
   - POST /sp/get_opportunities
3. Request/Response Examples
4. Error Codes
5. Rate Limits
6. Versioning Strategy

**Status:** 📋 Pending

---

## 📅 Timeline & Milestones

### Week 1: Oct 21-27, 2025
**Goal:** Database schema complete

- [ ] **Oct 21 (Mon):** Phase 1 kickoff, create GitHub branch `phase1/foundation`
- [ ] **Oct 22 (Tue):** Design all 6 table schemas, peer review
- [ ] **Oct 23 (Wed):** Write SQL DDL scripts, test locally
- [ ] **Oct 24 (Thu):** Deploy to Snowflake dev environment
- [ ] **Oct 25 (Fri):** Data validation, seed test data
- [ ] **Oct 26-27 (Weekend):** Buffer for issues

**Deliverable:** ✅ 6 tables created and validated

---

### Week 2: Oct 28 - Nov 3, 2025
**Goal:** Stored procedures complete

- [ ] **Oct 28 (Mon):** Implement SP_GET_SKILL_GAPS
- [ ] **Oct 29 (Tue):** Implement SP_GET_TRAJECTORIES
- [ ] **Oct 30 (Wed):** Implement SP_INGEST_SCENARIO_RUN
- [ ] **Oct 31 (Thu):** Implement SP_GET_OPPORTUNITIES
- [ ] **Nov 1 (Fri):** Test all SPs with sample data
- [ ] **Nov 2-3 (Weekend):** Buffer for issues

**Deliverable:** ✅ 4 stored procedures tested

---

### Week 3: Nov 4-10, 2025
**Goal:** Service layer complete

- [ ] **Nov 4 (Mon):** Implement TrajectoryService.swift
- [ ] **Nov 5 (Tue):** Implement SimulationService.swift
- [ ] **Nov 6 (Wed):** Implement SkillGraphService.swift
- [ ] **Nov 7 (Thu):** Implement OpportunityService.swift
- [ ] **Nov 8 (Fri):** Integration testing, error handling
- [ ] **Nov 9-10 (Weekend):** Buffer for issues

**Deliverable:** ✅ 4 services implemented

---

### Week 4: Nov 11-15, 2025
**Goal:** Testing and documentation complete

- [ ] **Nov 11 (Mon):** Write integration tests (30+ tests)
- [ ] **Nov 12 (Tue):** Performance testing, optimization
- [ ] **Nov 13 (Wed):** API documentation (OpenAPI spec)
- [ ] **Nov 14 (Thu):** Phase 1 completion report
- [ ] **Nov 15 (Fri):** Phase 1 sign-off, Phase 2 planning

**Deliverable:** ✅ Phase 1 complete

---

## 🎯 Success Metrics

### Code Quality
- [ ] 85%+ test coverage on new code
- [ ] 0 compiler warnings
- [ ] 0 critical bugs
- [ ] All tests passing (30+)

### Performance
- [ ] API response time < 500ms (95th percentile)
- [ ] Database queries optimized with indexes
- [ ] Caching strategy implemented

### Data Quality
- [ ] All tables have sample/seed data
- [ ] Foreign key constraints validated
- [ ] Data types consistent across schema

### Documentation
- [ ] Complete API documentation (OpenAPI 3.0)
- [ ] Database schema diagrams (ERD)
- [ ] Integration guide for Phase 2
- [ ] Phase 1 completion report

---

## 🔧 Technical Details

### Database Schema Design Principles

1. **Pseudonymous IDs:** Use `user_pid` (device-scoped) until accounts ship
2. **Variant Types:** Use for flexible JSON storage (decisions, signals)
3. **Timestamps:** All tables include audit timestamps
4. **Indexes:** Add on frequently queried columns (user_pid, template_id)
5. **Constraints:** Foreign keys where appropriate

### Service Layer Design Principles

1. **Protocol-Oriented:** All services have protocol interfaces for testing
2. **Async/Await:** Use modern Swift concurrency
3. **Error Handling:** Comprehensive error types with user-friendly messages
4. **Caching:** Implement for frequently accessed data
5. **Dependency Injection:** SnowflakeService injected for testability

### Stored Procedure Design Principles

1. **Single Responsibility:** Each SP does one thing well
2. **Consistent Returns:** All return VARIANT (JSON)
3. **Error Handling:** Try/catch with meaningful error codes
4. **Performance:** Optimize queries, limit result sets
5. **Documentation:** Inline comments explaining logic

---

## ⚠️ Risks & Mitigations

### Risk 1: Database Schema Changes
**Risk:** Schema may need changes as we implement features
**Probability:** Medium
**Impact:** Medium
**Mitigation:**
- Use migration scripts (v1, v2, etc.)
- Test thoroughly before deployment
- Document all changes

### Risk 2: API Performance
**Risk:** Stored procedures may be slow for complex queries
**Probability:** Low
**Impact:** High
**Mitigation:**
- Performance testing early
- Query optimization
- Caching strategy
- Fallback to simpler queries if needed

### Risk 3: Skill Taxonomy Complexity
**Risk:** Skill IDs and mapping may be inconsistent
**Probability:** Medium
**Impact:** Medium
**Mitigation:**
- Define skill taxonomy upfront
- Create skill ID registry
- Validate all skill references

### Risk 4: Time Constraints
**Risk:** 4 weeks may not be enough for full implementation
**Probability:** Low
**Impact:** Medium
**Mitigation:**
- Prioritize core functionality
- Phase out nice-to-haves
- Add buffer week if needed

---

## 📞 Team & Communication

### Team Roles
- **Database Lead:** TBD - Schema design, SQL implementation
- **iOS Lead:** TBD - Service layer, Swift implementation
- **QA Lead:** TBD - Testing strategy, validation
- **Tech Writer:** TBD - API documentation

### Communication Schedule
- **Daily Standup:** 10:00 AM (15 min) - Blockers, progress
- **Weekly Review:** Fridays 2:00 PM - Demo, retrospective
- **Office Hours:** Mon/Wed/Fri 3-4 PM - Open Q&A

### Collaboration Tools
- **Git Branch:** `phase1/foundation`
- **Jira Board:** Phase 1 Epic
- **Slack Channel:** #v5-phase1
- **Design Docs:** Confluence

---

## 🔗 Resources

### Documentation
- [v5.0 Specification](../v5.md) - Complete v5.0 spec
- [Phase 0 Completion Report](../phase0/PHASE0_COMPLETION_REPORT.md) - Foundation work
- [PROJECT_STATUS.md](../../PROJECT_STATUS.md) - Live progress tracker

### Code References
- `SnowflakeService.swift` - Existing Snowflake integration
- `ONetOccupation.swift` - Existing data model pattern
- Phase 0 test files - Testing patterns

### External Resources
- [Snowflake Stored Procedures Docs](https://docs.snowflake.com/en/sql-reference/stored-procedures.html)
- [Swift Concurrency Guide](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [OpenAPI 3.0 Specification](https://swagger.io/specification/)

---

## 📝 Notes

### Phase 0 Learnings Applied
1. **Test-First Approach:** Write tests alongside implementation
2. **Documentation As We Go:** Don't defer docs to the end
3. **JSON Validation:** Validate all VARIANT data structures
4. **Performance Benchmarks:** Establish early, measure continuously

### Phase 1 → Phase 2 Handoff
- All services ready for UI integration
- Sample data available for UI testing
- API contracts frozen (versioned if changes needed)
- Performance benchmarks established

---

**Document Owner:** Phase 1 Lead
**Created:** October 21, 2025
**Last Updated:** October 21, 2025
**Status:** 🚀 IN PROGRESS

---

**Let's build the foundation for v5.0! 🚀**
