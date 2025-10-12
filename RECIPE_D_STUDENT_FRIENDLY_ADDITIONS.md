# Recipe D v4.0 - Student-Friendly Additions

## Strategy: Use Language Students Actually Use

High school and college students need familiar, relatable terms that match:
- What they see in their class schedule
- How they describe activities to friends
- Common school/college terminology

---

## Subjects to Add (5) - Student-Friendly Names

### 1. **Business/Economics** ✅
- **Why this name**: Students take "Business" or "Economics" classes
- **Maps to**: Business → Judgment, Financial Management, Persuasion
- **Student context**: "I take a Business class" or "I'm interested in Economics"

### 2. **Computer Programming** ✅
- **Why this name**: More specific than "Technology", matches actual class names
- **Maps to**: Computer Science → Programming, Systems Analysis
- **Student context**: "I'm learning to code" or "I take Programming class"
- **Note**: Keep "Technology" for general tech interest, add this for coding-specific

### 3. **Psychology** ✅
- **Why this name**: Common AP/college class, students call it "Psych"
- **Maps to**: Psychology → Social Perceptiveness, Critical Thinking
- **Student context**: "I love Psych class" or "I'm interested in how people think"

### 4. **Biology** ✅
- **Why this name**: More specific than general "Science"
- **Maps to**: Biology → Science, Critical Thinking, Systems Evaluation
- **Student context**: "I take AP Bio" or "I'm good at Biology"
- **Note**: Keep "Science" for general interest, add this for bio-specific

### 5. **World Languages** ✅
- **Why this name**: Modern term for "Foreign Language", inclusive
- **Maps to**: Foreign Language → Active Learning, Speaking, Listening
- **Student context**: "I take Spanish" or "I study French"
- **Alt option**: "Foreign Language" (also fine)

---

## Activities to Add (5) - Student-Friendly Names

### 1. **Student Council** ✅
- **Why this name**: "Student Government" sounds formal; students say "Student Council"
- **Maps to**: Student Government → Personnel Management, Coordination, Judgment
- **Student context**: "I'm on Student Council" or "I'm a class officer"

### 2. **Business Club/DECA** ✅
- **Why this name**: DECA is widely known business organization in high schools
- **Maps to**: Business Club → Judgment, Persuasion, Financial Management
- **Student context**: "I'm in DECA" or "I do Business Club"
- **Note**: DECA = Distributive Education Clubs of America (entrepreneurship/business)

### 3. **Auto Shop/Mechanics** ✅
- **Why this name**: "Auto Shop" is what students call it; "Auto Repair" sounds professional
- **Maps to**: Auto Repair → Repairing, Troubleshooting, Equipment Maintenance
- **Student context**: "I take Auto Shop" or "I work on cars"

### 4. **Model UN** ✅
- **Why this name**: Well-known activity, students say "Model UN" or "MUN"
- **Maps to**: Model UN → Negotiation, Persuasion, Speaking, Critical Thinking
- **Student context**: "I compete in Model UN" or "I'm in MUN"

### 5. **Event Planning/School Events** ✅
- **Why this name**: Clear and relatable - planning dances, fundraisers, etc.
- **Maps to**: Event Planning → Material Resources, Coordination, Time Management
- **Student context**: "I help plan school events" or "I organize fundraisers"
- **Alt option**: "Event Organizing" or just "Event Planning"

---

## Final List for App (20 options)

### Subjects (13 total)
```
Current (8):
1. Math
2. Science
3. Art
4. History
5. English
6. Technology
7. Physical Education
8. Other

NEW (5):
9. Business/Economics
10. Computer Programming
11. Psychology
12. Biology
13. World Languages
```

### Activities (12 total)
```
Current (7):
1. Robotics Club
2. Drama or Theatre
3. Sports
4. Debate Team
5. Volunteering
6. Music or Band
7. Other

NEW (5):
8. Student Council
9. Business Club/DECA
10. Auto Shop/Mechanics
11. Model UN
12. Event Planning/School Events
```

---

## Snowflake Mapping Names

The mapping tables use formal O*NET-aligned names, but we'll create aliases:

### Subject Mappings
```sql
-- Student-Friendly → Formal Mapping
'Business/Economics' → 'Business' (already mapped)
'Computer Programming' → 'Computer Science' (already mapped)
'Psychology' → 'Psychology' (already mapped)
'Biology' → 'Biology' (already mapped)
'World Languages' → 'Foreign Language' (already mapped)
```

### Activity Mappings
```sql
-- Student-Friendly → Formal Mapping
'Student Council' → 'Student Government' (already mapped)
'Business Club/DECA' → 'Business Club/DECA' (already mapped)
'Auto Shop/Mechanics' → 'Auto Repair/Mechanics' (already mapped)
'Model UN' → 'Model UN' (already mapped)
'Event Planning/School Events' → 'Event Planning' (already mapped)
```

---

## UI Presentation Tips

### Grouping by Category (Optional)

**STEM:**
- Math
- Science
- Biology
- Computer Programming
- Technology

**Humanities:**
- English
- History
- World Languages

**Social Sciences:**
- Psychology

**Business/Creative:**
- Business/Economics
- Art

**Other:**
- Physical Education

### Activity Grouping (Optional)

**Leadership:**
- Student Council
- Event Planning/School Events

**Clubs:**
- Robotics Club
- Business Club/DECA
- Model UN
- Debate Team

**Creative/Performance:**
- Drama or Theatre
- Music or Band

**Service:**
- Volunteering

**Technical:**
- Auto Shop/Mechanics

**Athletics:**
- Sports

---

## Student Context Examples

### STEM Student
**Selects:**
- Math
- Biology
- Computer Programming
- Robotics Club
- Debate Team

**Result:** 60-75% skills match for Software Developer, Bioinformatics, Data Scientist

### Business Student
**Selects:**
- Business/Economics
- Psychology
- Math
- Business Club/DECA
- Student Council

**Result:** 50-65% skills match for Marketing Manager, Financial Analyst, Management

### Trades Student
**Selects:**
- Technology
- Math
- Physical Education
- Auto Shop/Mechanics
- Event Planning

**Result:** 45-60% skills match for Automotive Technician, Mechanical Engineer

### Arts Student
**Selects:**
- Art
- English
- Psychology
- Drama or Theatre
- Event Planning/School Events

**Result:** 40-55% skills match for Graphic Designer, Event Coordinator, Theatre Director

---

## Implementation Notes

1. **Swift Models**: Use student-friendly names in the app
2. **Snowflake Mapping**: Either:
   - Option A: Update mapping table to use student-friendly names
   - Option B: Create translation layer in Swift (student name → formal name)
3. **UI Design**: Consider icons for each subject/activity for visual recognition
4. **Help Text**: Add brief descriptions for less common options
   - "DECA: Business and entrepreneurship club"
   - "Model UN: Debate and diplomacy competition"
   - "Auto Shop: Learning to repair and maintain vehicles"

---

## Coverage Impact

With these student-friendly additions:
- **Skills Coverage**: 66% → 91% (23 → 32 of 35 skills)
- **Total Options**: 15 → 20 (manageable)
- **Student Relatability**: ⭐⭐⭐⭐⭐ (familiar terms)
- **Onboarding Time**: +2 minutes (still under 10 min total)
