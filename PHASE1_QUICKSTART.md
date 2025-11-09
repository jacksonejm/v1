# 🚀 Phase 1: Foundation - Quick Start Guide

**You're now in Phase 1!** Here's everything you need to know to get started.

---

## ✅ Phase 0 Complete!

**Congratulations!** Phase 0 is done with:
- ✅ 51/51 tests passing (100% success rate)
- ✅ 1,466 NOC mappings deployed
- ✅ 94% O*NET coverage
- ✅ Complete documentation

---

## 🚀 Phase 1: What We're Building

### Week 1 (Oct 21-27): Database Schema
**6 Snowflake Tables:**
1. **SCENARIO_TEMPLATES** - Storyline scenarios for role simulations
2. **SCENARIO_RUNS** - User storyline completions & decisions
3. **BEHAVIORAL_SIGNALS** - Skill evidence from choices
4. **USER_SKILLS** - User skill levels with trust scores
5. **USER_EVIDENCE** - User accomplishments & artifacts
6. **CAMPUS_OPPORTUNITIES** - Clubs, internships, scholarships

### Week 2 (Oct 28-Nov 3): Stored Procedures
**4 Snowflake SPs:**
1. **SP_GET_SKILL_GAPS** - Calculate gaps for target career
2. **SP_GET_TRAJECTORIES** - Generate career pathways
3. **SP_INGEST_SCENARIO_RUN** - Process storyline completions
4. **SP_GET_OPPORTUNITIES** - Match to Ready/Stretch opportunities

### Week 3 (Nov 4-10): Service Layer
**4 Swift Services:**
1. **TrajectoryService** - Career pathways API
2. **SimulationService** - Storyline scenarios API
3. **SkillGraphService** - Skill gaps & recommendations API
4. **OpportunityService** - Opportunity matching API

### Week 4 (Nov 11-15): Testing & Docs
- 30+ integration tests
- API documentation (OpenAPI 3.0)
- Phase 1 completion report

---

## 📚 Key Documents

### Essential Reading
1. **[PHASE1_KICKOFF.md](/v5-odyssey/docs/phase1/PHASE1_KICKOFF.md)** - Complete Phase 1 spec (READ THIS!)
2. **[PROJECT_STATUS.md](/v5-odyssey/PROJECT_STATUS.md)** - Live progress tracker
3. **[v5.md](/v5-odyssey/docs/v5.md)** - Full v5.0 specification

### Quick References
- **Phase 1 Todo List** - 7 tasks tracked
- **Current Sprint** - Week of Oct 21-25 (Database schema)
- **Progress** - 5% complete (kickoff done)

---

## 🎯 This Week's Goals (Oct 21-27)

### ✅ Completed
- ✅ Phase 1 kickoff documentation
- ✅ Todo list created
- ✅ PROJECT_STATUS.md updated
- ✅ README.md updated

### 🔄 In Progress
- 🔄 Design 6 table schemas
- 🔄 Create SQL DDL scripts
- 🔄 Set up development environment

### 📋 Upcoming
- [ ] Deploy tables to Snowflake
- [ ] Seed test data
- [ ] Schema validation

---

## 🛠️ How to Contribute

### 1. Database Schema Design
**Task:** Design 6 table schemas
**Owner:** TBD
**Due:** Oct 25, 2025

**Steps:**
1. Review table specifications in PHASE1_KICKOFF.md
2. Create SQL DDL scripts in `/v5-odyssey/sql/phase1/`
3. Add indexes for frequently queried columns
4. Document foreign key relationships
5. Create schema diagram (ERD)

**Deliverable:** SQL files ready for Snowflake deployment

---

### 2. SQL DDL Scripts
**Task:** Write CREATE TABLE statements
**Owner:** TBD
**Due:** Oct 25, 2025

**Template:**
```sql
-- File: /v5-odyssey/sql/phase1/01_CREATE_SCENARIO_TEMPLATES.sql

USE DATABASE ONET_CAREER_DB;
USE SCHEMA CAREER_SCHEMA;

CREATE TABLE IF NOT EXISTS SCENARIO_TEMPLATES (
  template_id STRING PRIMARY KEY,
  onet_code STRING,
  role_title STRING,
  difficulty INT,
  context_tags ARRAY,
  decision_rubric VARIANT,
  content_seed VARIANT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Indexes
CREATE INDEX idx_scenario_templates_onet ON SCENARIO_TEMPLATES(onet_code);

-- Comments
COMMENT ON TABLE SCENARIO_TEMPLATES IS 'Storyline templates for behavioral simulations';
```

**Deliverable:** 6 SQL files (one per table)

---

### 3. Test Data
**Task:** Seed sample data for testing
**Owner:** TBD
**Due:** Oct 27, 2025

**Sample:**
```sql
-- File: /v5-odyssey/sql/phase1/seed_data.sql

-- SCENARIO_TEMPLATES sample data
INSERT INTO SCENARIO_TEMPLATES VALUES (
  'tmpl_pm_scope',
  '15-1299.09',
  'Associate Product Manager',
  3,
  ['remote', 'team', 'deadline'],
  PARSE_JSON('{"delegation_l2": 0.75, "prioritization_l2": 0.70}'),
  PARSE_JSON('{"context": "Tech startup", "team_size": 5}'),
  CURRENT_TIMESTAMP(),
  CURRENT_TIMESTAMP()
);

-- Add 2-3 more sample templates
-- Add sample data for other tables
```

**Deliverable:** Seed data SQL file

---

## 📊 Success Criteria

### Database Schema (Week 1)
- [ ] All 6 tables created in Snowflake
- [ ] Indexes added for performance
- [ ] Foreign keys validated
- [ ] Sample data inserted
- [ ] Schema diagram created
- [ ] Validation queries passing

### Acceptance Checklist
- [ ] Tables deploy without errors
- [ ] Can insert/select from all tables
- [ ] Indexes improve query performance
- [ ] Schema matches specification
- [ ] Documentation complete

---

## 🚨 Common Issues & Solutions

### Issue 1: Snowflake Connection
**Problem:** Can't connect to Snowflake
**Solution:**
- Check VPN connection
- Verify credentials in SnowflakeService
- Test with simple SELECT query

### Issue 2: VARIANT Parsing
**Problem:** Can't parse VARIANT fields
**Solution:**
- Use `PARSE_JSON('...')` for inserts
- Use `column:field` notation for selects
- Example: `SELECT decision_rubric:delegation_l2 FROM ...`

### Issue 3: Array Fields
**Problem:** Can't insert arrays
**Solution:**
- Use ARRAY literal: `['item1', 'item2']`
- Or PARSE_JSON for complex arrays
- Example: `ARRAY_CONSTRUCT('tag1', 'tag2')`

---

## 📞 Need Help?

### Documentation
- **Phase 1 Kickoff:** Complete specifications
- **v5.md:** Architecture overview
- **Snowflake Docs:** Stored procedures, VARIANT types

### Communication
- **Daily Standup:** 10:00 AM (15 min)
- **Office Hours:** Mon/Wed/Fri 3-4 PM
- **Slack:** #v5-phase1

### Team
- **Database Lead:** TBD
- **iOS Lead:** TBD
- **QA Lead:** TBD

---

## 🎯 Next Steps

**Today (Oct 21):**
1. Read PHASE1_KICKOFF.md (30 min)
2. Review table specifications (30 min)
3. Set up SQL development environment (30 min)

**Tomorrow (Oct 22):**
1. Design all 6 table schemas (2 hours)
2. Peer review with team (1 hour)
3. Begin SQL DDL scripts (2 hours)

**Rest of Week:**
- Wed: Complete SQL DDL scripts
- Thu: Deploy to Snowflake dev
- Fri: Validation & seed data

---

## 🎉 Let's Build!

Phase 1 is all about laying the **data foundation** for v5.0. Every table, stored procedure, and service we build this month will power the amazing features coming in Phases 2-10.

**Key Mindset:**
- **Quality over speed** - Get the schema right
- **Test as you go** - Don't defer validation
- **Document everything** - Future you will thank you
- **Ask questions** - Better to clarify than assume

**You've got this! 🚀**

---

**Quick Links:**
- [📊 PROJECT_STATUS.md](v5-odyssey/PROJECT_STATUS.md) - Live progress
- [📖 PHASE1_KICKOFF.md](v5-odyssey/docs/phase1/PHASE1_KICKOFF.md) - Complete spec
- [📝 v5.md](v5-odyssey/docs/v5.md) - Architecture
- [✅ Todo List](Use TodoWrite tool to view)

---

**Last Updated:** October 21, 2025, 12:00 AM
**Status:** 🚀 Phase 1 Week 1 - Database Schema Design
