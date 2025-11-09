# O*NET Career Recommendation Agent - Complete Documentation

## Overview
A Snowflake Intelligence Agent that provides comprehensive career guidance using O*NET occupational data and RIASEC personality assessment. The agent administers a validated 36-question Holland Code assessment and matches users to 1,000+ real occupations with detailed career insights.

## Agent Capabilities

### Core Features
- **RIASEC Personality Assessment**: 36-question validated assessment measuring 6 interest types
- **Career Matching**: Matches users to O*NET occupations based on interest profiles
- **Skills Analysis**: Detailed breakdown of skills required for specific careers
- **Job Search Strategy**: Personalized job search guidance with direct links to job boards
- **Multi-tool Orchestration**: Seamlessly chains multiple tools based on conversation flow

### Data Sources
- **O*NET Database Version**: 28.2+
- **Total Occupations**: 1,016
- **Skills Data**: 61,000+ skill requirements
- **Interest Profiles**: Complete RIASEC mappings
- **Technology Requirements**: 32,000+ tool/software entries

---

## Architecture

### Database Structure
```
ONET_CAREER_DB
└── CAREER_SCHEMA
    ├── Tables
    │   ├── OCCUPATION_DIM (1,016 occupations)
    │   ├── RIASEC_QUESTIONS (36 questions)
    │   ├── INTERESTS_FACT (RIASEC mappings)
    │   ├── SKILLS_FACT (61,000+ skills)
    │   ├── TECHNOLOGY_SKILLS (32,000+ tools)
    │   ├── ALTERNATE_TITLES (alternate job titles)
    │   └── RELATED_OCCUPATIONS (career paths)
    └── Procedures
        ├── SP_GET_RIASEC_QUESTIONS()
        ├── SP_GET_RIASEC_TYPE_DESCRIPTIONS()
        ├── SP_GET_CAREER_MATCHES()
        ├── SP_GET_CAREER_SKILLS()
        └── SP_GET_JOB_SEARCH_STRATEGY()
```

### Agent Workflow
```
User Request: "I'd like career guidance"
    ↓
[1] SP_GET_RIASEC_QUESTIONS()
    → Returns 36 assessment questions
    ↓
User provides 36 ratings (1-5 scale)
    ↓
[2] Agent calculates RIASEC scores
    → R: Realistic (questions 1-6)
    → I: Investigative (questions 7-12)
    → A: Artistic (questions 13-18)
    → S: Social (questions 19-24)
    → E: Enterprising (questions 25-30)
    → C: Conventional (questions 31-36)
    ↓
[3] SP_GET_CAREER_MATCHES(R, I, A, S, E, C)
    → Queries INTERESTS_FACT for matching careers
    → Returns 15 best-match occupations
    ↓
[4] Optional: SP_GET_CAREER_SKILLS(occupation_code)
    → Returns top 10-15 skills for specific career
    ↓
[5] Optional: SP_GET_JOB_SEARCH_STRATEGY(occupation_code)
    → Returns job titles, skills, links to job boards
```

---

## Technical Implementation

### 1. Infrastructure Setup

```sql
-- Create role and warehouse
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE ROLE ONET_CAREER_AGENT_ROLE;
GRANT ROLE ONET_CAREER_AGENT_ROLE TO USER IDENTIFIER($current_user_name);

CREATE OR REPLACE WAREHOUSE ONET_CAREER_AGENT_WH
    WITH WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

GRANT USAGE ON WAREHOUSE ONET_CAREER_AGENT_WH TO ROLE ONET_CAREER_AGENT_ROLE;

-- Create database
CREATE OR REPLACE DATABASE ONET_CAREER_DB;
CREATE SCHEMA ONET_CAREER_DB.CAREER_SCHEMA;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE ONET_CAREER_DB TO ROLE ONET_CAREER_AGENT_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA ONET_CAREER_DB.CAREER_SCHEMA TO ROLE ONET_CAREER_AGENT_ROLE;
```

### 2. Core Procedures

#### SP_GET_RIASEC_QUESTIONS
Returns all 36 assessment questions from database.

```sql
CREATE OR REPLACE PROCEDURE SP_GET_RIASEC_QUESTIONS()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    result STRING;
BEGIN
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(
        'QUESTION_ID', QUESTION_ID,
        'QUESTION_TEXT', QUESTION_TEXT,
        'RIASEC_TYPE', RIASEC_TYPE
    ))::STRING INTO result
    FROM RIASEC_QUESTIONS
    ORDER BY QUESTION_ID;
    
    RETURN result;
END;
$$;
```

**Tool Configuration:**
- **Name**: Get_RIASEC_Questions
- **Resource Type**: procedure
- **No parameters**
- **Returns**: JSON array of 36 questions

---

#### SP_GET_CAREER_MATCHES
Matches user RIASEC scores to O*NET occupations.

```sql
CREATE OR REPLACE PROCEDURE SP_GET_CAREER_MATCHES(
    SCORE_R FLOAT,
    SCORE_I FLOAT, 
    SCORE_A FLOAT,
    SCORE_S FLOAT,
    SCORE_E FLOAT,
    SCORE_C FLOAT
)
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS
$$
    var scores = [
        {type: 'R', score: SCORE_R, name: 'Realistic', element: '1.B.1.a'},
        {type: 'I', score: SCORE_I, name: 'Investigative', element: '1.B.1.b'},
        {type: 'A', score: SCORE_A, name: 'Artistic', element: '1.B.1.c'},
        {type: 'S', score: SCORE_S, name: 'Social', element: '1.B.1.d'},
        {type: 'E', score: SCORE_E, name: 'Enterprising', element: '1.B.1.e'},
        {type: 'C', score: SCORE_C, name: 'Conventional', element: '1.B.1.f'}
    ];
    scores.sort(function(a, b) { return b.score - a.score; });
    var top = scores[0];
    var second = scores[1];
    
    var sql = `
        SELECT 
            o.ONET_SOC_CODE,
            o.TITLE,
            SUBSTR(o.DESCRIPTION, 1, 150) as SHORT_DESC,
            i.DATA_VALUE
        FROM INTERESTS_FACT i
        JOIN OCCUPATION_DIM o ON i.ONET_SOC_CODE = o.ONET_SOC_CODE
        WHERE i.ELEMENT_ID IN ('${top.element}', '${second.element}')
        AND i.DATA_VALUE >= 4.0
        ORDER BY i.DATA_VALUE DESC
        LIMIT 15
    `;
    
    var stmt = snowflake.createStatement({sqlText: sql});
    var result = stmt.execute();
    
    var careers = [];
    while (result.next()) {
        careers.push({
            code: result.getColumnValue(1),
            title: result.getColumnValue(2),
            description: result.getColumnValue(3),
            interest_score: result.getColumnValue(4),
            primary_match: top.name,
            secondary_match: second.name
        });
    }
    
    return JSON.stringify(careers);
$$;
```

**Tool Configuration:**
- **Name**: Get_Career_Matches
- **Parameters**: 6 FLOAT parameters (SCORE_R, SCORE_I, SCORE_A, SCORE_S, SCORE_E, SCORE_C)
- **Returns**: JSON array of 15 matching careers with codes, titles, descriptions

---

#### SP_GET_CAREER_SKILLS
Returns detailed skill requirements for a specific occupation.

```sql
CREATE OR REPLACE PROCEDURE SP_GET_CAREER_SKILLS(
    OCCUPATION_CODE VARCHAR
)
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS
$$
    var sql = `
        SELECT 
            s.ELEMENT_NAME,
            s.DATA_VALUE,
            s.SCALE_ID
        FROM SKILLS_FACT s
        WHERE s.ONET_SOC_CODE = '${OCCUPATION_CODE}'
        AND s.SCALE_ID IN ('IM', 'LV')
        ORDER BY s.DATA_VALUE DESC
        LIMIT 15
    `;
    
    var result = snowflake.execute({sqlText: sql});
    var skills = {};
    
    while (result.next()) {
        var skill = result.getColumnValue(1);
        var value = result.getColumnValue(2);
        var scale = result.getColumnValue(3);
        
        if (!skills[skill]) {
            skills[skill] = {};
        }
        skills[skill][scale] = value;
    }
    
    var output = [];
    for (var s in skills) {
        output.push({
            skill: s,
            importance: skills[s]['IM'] || 0,
            level: skills[s]['LV'] || 0
        });
    }
    
    return JSON.stringify(output);
$$;
```

**Tool Configuration:**
- **Name**: Get_Career_Skills
- **Parameter**: OCCUPATION_CODE (string)
- **Returns**: JSON array of skills with importance and level ratings

---

#### SP_GET_JOB_SEARCH_STRATEGY
Provides comprehensive job search guidance including alternate titles and direct job board links.

```sql
CREATE OR REPLACE PROCEDURE SP_GET_JOB_SEARCH_STRATEGY(
    OCCUPATION_CODE VARCHAR
)
RETURNS STRING
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS
$$
    var code = OCCUPATION_CODE;
    
    // Get main occupation info
    var occSql = `
        SELECT TITLE, DESCRIPTION
        FROM OCCUPATION_DIM
        WHERE ONET_SOC_CODE = '${code}'
    `;
    var occResult = snowflake.execute({sqlText: occSql});
    
    if (!occResult.next()) {
        return JSON.stringify({error: "Occupation not found"});
    }
    
    var mainTitle = occResult.getColumnValue(1);
    var description = occResult.getColumnValue(2);
    
    // Get alternate job titles
    var titlesSql = `
        SELECT ALTERNATE_TITLE
        FROM ALTERNATE_TITLES
        WHERE ONET_SOC_CODE = '${code}'
        LIMIT 15
    `;
    var titlesResult = snowflake.execute({sqlText: titlesSql});
    var searchTitles = [mainTitle];
    
    while (titlesResult.next()) {
        searchTitles.push(titlesResult.getColumnValue(1));
    }
    
    // Get top skills
    var skillsSql = `
        SELECT ELEMENT_NAME, DATA_VALUE
        FROM SKILLS_FACT
        WHERE ONET_SOC_CODE = '${code}'
        AND SCALE_ID = 'IM'
        ORDER BY DATA_VALUE DESC
        LIMIT 10
    `;
    var skillsResult = snowflake.execute({sqlText: skillsSql});
    var topSkills = [];
    
    while (skillsResult.next()) {
        topSkills.push({
            skill: skillsResult.getColumnValue(1),
            importance: skillsResult.getColumnValue(2)
        });
    }
    
    // Get technologies
    var techSql = `
        SELECT DISTINCT COMMODITY_TITLE
        FROM TECHNOLOGY_SKILLS
        WHERE ONET_SOC_CODE = '${code}'
        LIMIT 10
    `;
    var techResult = snowflake.execute({sqlText: techSql});
    var technologies = [];
    
    while (techResult.next()) {
        technologies.push(techResult.getColumnValue(1));
    }
    
    // Build search URLs
    var linkedinUrl = 'https://www.linkedin.com/jobs/search/?keywords=' + 
                      encodeURIComponent(mainTitle);
    var indeedUrl = 'https://www.indeed.com/jobs?q=' + 
                    encodeURIComponent(mainTitle);
    
    return JSON.stringify({
        occupation: mainTitle,
        code: code,
        description: description.substring(0, 200),
        search_titles: searchTitles,
        top_skills: topSkills,
        technologies: technologies,
        job_search_links: {
            linkedin: linkedinUrl,
            indeed: indeedUrl,
            google: 'https://www.google.com/search?q=' + 
                    encodeURIComponent(mainTitle + ' jobs near me')
        }
    });
$$;
```

**Tool Configuration:**
- **Name**: Get_Job_Search_Strategy
- **Parameter**: OCCUPATION_CODE (string)
- **Returns**: JSON with alternate titles, skills, technologies, and job board links

---

## Agent Configuration

### Basic Settings
- **Name**: ONET_CAREER_AGENT_FINAL
- **Display Name**: O*NET Career Guidance Agent
- **Database**: ONET_CAREER_DB
- **Schema**: CAREER_SCHEMA
- **Warehouse**: ONET_CAREER_AGENT_WH

### Response Instructions
```
You are an expert career counselor with access to comprehensive O*NET occupational data and interactive RIASEC personality assessment. 

When users request career guidance:
1. Call Get_RIASEC_Questions to display all 36 questions
2. Collect user's 36 responses (ratings 1-5)
3. Calculate RIASEC scores:
   - R (Realistic): Average of questions 1-6
   - I (Investigative): Average of questions 7-12
   - A (Artistic): Average of questions 13-18
   - S (Social): Average of questions 19-24
   - E (Enterprising): Average of questions 25-30
   - C (Conventional): Average of questions 31-36
4. Call Get_Career_Matches with the 6 calculated scores
5. Present results with career titles, codes, descriptions, and match explanations

When users ask about skills for specific careers:
- Extract occupation code from previous recommendations
- Call Get_Career_Skills with that code
- Explain skills organized by importance and level
- Provide learning path suggestions

When users want to find jobs:
- Call Get_Job_Search_Strategy with the occupation code
- Present alternate job titles, key skills, and technologies
- Provide clickable links to LinkedIn, Indeed, and Google Jobs

Always show score calculations transparently and explain the RIASEC framework clearly.
```

### Orchestration Instructions
```
Use tools in logical sequence based on conversation flow. 
If user asks about specific careers mentioned in previous results, extract occupation codes from context.
Chain tools naturally without asking permission.
```

### Tools Configuration

| Tool Name | Type | Parameters | Description |
|-----------|------|------------|-------------|
| Get_RIASEC_Questions | procedure | None | Returns 36 assessment questions |
| Get_RIASEC_Type_Descriptions | procedure | None | Returns RIASEC type descriptions |
| Get_Career_Matches | procedure | 6 FLOAT scores | Returns matching O*NET careers |
| Get_Career_Skills | procedure | OCCUPATION_CODE | Returns skill requirements |
| Get_Job_Search_Strategy | procedure | OCCUPATION_CODE | Returns job search guidance |

---

## Usage Examples

### Example 1: Complete Assessment Flow
```
User: "I'd like to take a career assessment"

Agent: [Calls Get_RIASEC_Questions]
      Displays all 36 questions

User: "Here are my ratings: 4,5,4,3,4,5,2,3,2,1,2,3,5,4,5,4,5,4,3,4,3,2,3,4,2,1,2,3,2,1,1,2,1,2,1,2"

Agent: Calculates scores:
      - Artistic: 4.50 (highest)
      - Realistic: 4.17 (second)
      - Social: 3.17
      - Others: <3.0
      
      [Calls Get_Career_Matches(4.17, 2.17, 4.50, 3.17, 1.83, 1.50)]
      
      Returns 15 careers including:
      - Art Directors (27-1011.00)
      - Graphic Designers (27-1024.00)
      - Fine Artists (27-1013.00)
      - Fashion Designers (27-1022.00)
```

### Example 2: Skills Deep Dive
```
User: "What skills do I need to become a Graphic Designer?"

Agent: [Calls Get_Career_Matches to find code]
      Finds: 27-1024.00
      
      [Calls Get_Career_Skills('27-1024.00')]
      
      Returns skills:
      - Active Listening (Importance: 4.5)
      - Critical Thinking (Importance: 4.2)
      - Speaking (Importance: 4.0)
      - Coordination (Importance: 3.8)
      [Plus 10 more skills]
```

### Example 3: Job Search
```
User: "How do I find Graphic Designer jobs?"

Agent: [Calls Get_Job_Search_Strategy('27-1024.00')]
      
      Returns:
      - Alternate titles: "Visual Designer", "Creative Designer", "Digital Designer"
      - Top skills to highlight
      - Technologies: Adobe Creative Suite, Figma, Sketch
      - Links:
        • LinkedIn: https://www.linkedin.com/jobs/search/?keywords=Graphic%20Designer
        • Indeed: https://www.indeed.com/jobs?q=Graphic+Designer
        • Google: Search link with location
```

---

## Data Loading Guide

### Required O*NET Files
```sql
-- File format
CREATE OR REPLACE FILE FORMAT ONET_TAB_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = '\t'
    SKIP_HEADER = 1;

-- Load key tables
COPY INTO OCCUPATION_DIM FROM @ONET_DATA_STAGE/Occupation Data.txt;
COPY INTO RIASEC_QUESTIONS FROM [manual insert - see appendix];
COPY INTO INTERESTS_FACT FROM @ONET_DATA_STAGE/Interests.txt;
COPY INTO SKILLS_FACT FROM @ONET_DATA_STAGE/Skills.txt;
COPY INTO TECHNOLOGY_SKILLS FROM @ONET_DATA_STAGE/Technology Skills.txt;
COPY INTO ALTERNATE_TITLES FROM @ONET_DATA_STAGE/Alternate Titles.txt;
```

### RIASEC Questions Data
See Appendix A for the complete 36-question insert statement.

---

## Troubleshooting

### Common Issues

**Agent doesn't return questions:**
- Verify `SP_GET_RIASEC_QUESTIONS()` returns data when called manually
- Check RIASEC_QUESTIONS table has 36 rows
- Ensure procedure granted to ONET_CAREER_AGENT_ROLE

**Career matches return empty:**
- Verify INTERESTS_FACT table loaded (should have 6,000+ rows)
- Check ELEMENT_ID format is '1.B.1.a' through '1.B.1.f'
- Test procedure manually with sample scores

**Skills tool fails:**
- Verify SKILLS_FACT table loaded (should have 61,000+ rows)
- Check occupation code format (XX-XXXX.XX)
- Test with known code like '27-1024.00'

**Job search returns no titles:**
- Verify ALTERNATE_TITLES table loaded
- Check TECHNOLOGY_SKILLS table has data
- Ensure occupation code exists in OCCUPATION_DIM

### Verification Queries
```sql
-- Check data loaded
SELECT 'OCCUPATION_DIM' as table_name, COUNT(*) FROM OCCUPATION_DIM
UNION ALL
SELECT 'RIASEC_QUESTIONS', COUNT(*) FROM RIASEC_QUESTIONS
UNION ALL
SELECT 'INTERESTS_FACT', COUNT(*) FROM INTERESTS_FACT
UNION ALL
SELECT 'SKILLS_FACT', COUNT(*) FROM SKILLS_FACT;

-- Test procedures
CALL SP_GET_RIASEC_QUESTIONS();
CALL SP_GET_CAREER_MATCHES(4.0, 3.0, 5.0, 3.0, 2.0, 2.0);
CALL SP_GET_CAREER_SKILLS('27-1024.00');
CALL SP_GET_JOB_SEARCH_STRATEGY('27-1024.00');
```

---

## Performance Optimization

### Query Performance
- INTERESTS_FACT queries typically < 200ms
- SKILLS_FACT queries typically < 150ms
- OCCUPATION_DIM lookups < 50ms

### Warehouse Sizing
- XSMALL sufficient for < 50 concurrent users
- SMALL recommended for production (< 200 users)
- Auto-suspend at 5 minutes optimal

### Caching Strategy
- Agent results not cached between sessions
- Each assessment is independent
- No persistent user state required

---

## Future Enhancements

### Possible Additions
1. **Education Pathways** - Add EDUCATION_TRAINING_FACT integration
2. **Work Environment** - Show physical demands, schedule, context
3. **Related Careers** - Career progression and lateral moves
4. **Salary Data** - If wage data available in O*NET
5. **Multi-user Support** - Store assessment history by user
6. **Comparison Tool** - Compare 2-3 careers side-by-side
7. **Resume Builder** - Generate resume bullets from skills data
8. **Interview Prep** - Common questions for specific careers

### Technical Improvements
1. Better RIASEC matching algorithm (weighted scoring)
2. Semantic search on occupations
3. API integration with job boards (Indeed API, Adzuna)
4. Email notifications with results
5. PDF report generation

---

## Appendix A: RIASEC Questions

```sql
INSERT INTO RIASEC_QUESTIONS (QUESTION_ID, QUESTION_TEXT, RIASEC_TYPE) VALUES
(1, 'I enjoy working with tools and machinery', 'R'),
(2, 'I like to build things with my hands', 'R'),
(3, 'I prefer working outdoors rather than in an office', 'R'),
(4, 'I enjoy fixing mechanical problems', 'R'),
(5, 'I like working with plants and animals', 'R'),
(6, 'I prefer concrete tasks over abstract concepts', 'R'),
(7, 'I enjoy solving complex problems and puzzles', 'I'),
(8, 'I like to analyze data and find patterns', 'I'),
(9, 'I am curious about how things work', 'I'),
(10, 'I enjoy conducting research and experiments', 'I'),
(11, 'I like working with numbers and statistics', 'I'),
(12, 'I prefer to think through problems systematically', 'I'),
(13, 'I enjoy creating original artwork or designs', 'A'),
(14, 'I like to express myself through writing or speaking', 'A'),
(15, 'I am drawn to music, art, or drama', 'A'),
(16, 'I enjoy working in unstructured environments', 'A'),
(17, 'I like to come up with new and innovative ideas', 'A'),
(18, 'I prefer flexible schedules and creative freedom', 'A'),
(19, 'I enjoy helping people solve their problems', 'S'),
(20, 'I like to teach or train others', 'S'),
(21, 'I am interested in human behavior and psychology', 'S'),
(22, 'I enjoy working as part of a team', 'S'),
(23, 'I like to provide care and support to others', 'S'),
(24, 'I am skilled at understanding others feelings', 'S'),
(25, 'I enjoy leading teams and making decisions', 'E'),
(26, 'I like to persuade others and influence outcomes', 'E'),
(27, 'I am interested in business and entrepreneurship', 'E'),
(28, 'I enjoy taking risks for potential rewards', 'E'),
(29, 'I like to compete and strive to win', 'E'),
(30, 'I am comfortable speaking in front of groups', 'E'),
(31, 'I enjoy organizing information and keeping records', 'C'),
(32, 'I like to follow established procedures and rules', 'C'),
(33, 'I am good at working with details and being precise', 'C'),
(34, 'I prefer structured and predictable work environments', 'C'),
(35, 'I like to work with numbers and financial data', 'C'),
(36, 'I enjoy administrative and clerical tasks', 'C');
```

---

## Appendix B: Key Lessons Learned

1. **Snowflake Agents require procedures, not functions** - Table functions must be wrapped in procedures
2. **STRING return types work better than TABLE** - JSON strings more reliable for agent parsing
3. **Simple procedures outperform complex ones** - Multi-step logic should be in agent orchestration
4. **Parameter naming matters** - Avoid SQL reserved words, use simple names
5. **JavaScript > SQL for procedures** - Cleaner parameter handling and string manipulation
6. **Test procedures manually first** - Debug with role before configuring in agent
7. **Data must be loaded correctly** - Empty tables cause silent failures
8. **EXECUTE AS OWNER is critical** - Ensures proper permission context

---

## License & Attribution

**Data Source**: O*NET Database (U.S. Department of Labor)
**License**: Public domain (U.S. Government work)
**Attribution**: O*NET® is a trademark of the U.S. Department of Labor

**Implementation**: Custom Snowflake Intelligence Agent
**Platform**: Snowflake (Enterprise Edition or higher required)

---

*Last Updated: Based on Snowflake Intelligence Agents platform as of Q3 2025*
