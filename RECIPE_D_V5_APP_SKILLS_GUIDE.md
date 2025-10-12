# Recipe D v5.0 - App Skills Selection Guide

## Overview
Instead of asking about "subjects" and "activities" and mapping them, we now ask users directly about **O*NET skills** with a proficiency rating (0.0 to 1.0).

## Recommended Skills to Ask About

### Category 1: Core Academic Skills (6 skills)
Ask all students to rate these:

1. **2.A.1.e - Mathematics** (Math proficiency)
2. **2.A.1.f - Science** (Science proficiency)
3. **2.A.1.a - Reading Comprehension**
4. **2.A.1.c - Writing**
5. **2.A.1.d - Speaking**
6. **2.A.1.b - Active Listening**

### Category 2: Technical Skills (6 skills)
Show these for students interested in STEM/Technical careers:

7. **2.B.3.e - Programming** (Coding/Software Development)
8. **2.B.3.b - Technology Design** (Designing tech solutions)
9. **2.B.4.g - Systems Analysis** (Understanding complex systems)
10. **2.A.2.a - Critical Thinking** (Problem solving)
11. **2.B.2.i - Complex Problem Solving**
12. **2.B.3.k - Troubleshooting** (Fixing technical problems)

### Category 3: People/Social Skills (6 skills)
Show these for students interested in Social/Service careers:

13. **2.B.1.a - Social Perceptiveness** (Understanding people)
14. **2.B.1.c - Persuasion** (Convincing others)
15. **2.B.1.e - Instructing** (Teaching)
16. **2.B.1.f - Service Orientation** (Helping others)
17. **2.B.1.b - Coordination** (Working with others)
18. **2.B.1.d - Negotiation**

### Category 4: Business/Management Skills (5 skills)
Show these for students interested in Enterprising careers:

19. **2.B.5.d - Management of Personnel Resources** (Leading teams)
20. **2.B.5.b - Management of Financial Resources** (Budgeting)
21. **2.B.4.e - Judgment and Decision Making**
22. **2.B.5.a - Time Management**
23. **2.B.5.c - Management of Material Resources**

### Category 5: Hands-On/Technical Trade Skills (6 skills)
Show these for students interested in Realistic careers:

24. **2.B.3.d - Installation** (Installing equipment)
25. **2.B.3.j - Equipment Maintenance** (Maintaining machinery)
26. **2.B.3.l - Repairing** (Fixing things)
27. **2.B.3.c - Equipment Selection** (Choosing right tools)
28. **2.B.3.h - Operation and Control** (Operating machinery)
29. **2.B.3.m - Quality Control Analysis**

## UI Design Recommendations

### Option 1: Simple Rating Scale
```
How would you rate your skill in these areas? (1-5 stars)

Mathematics ⭐⭐⭐⭐⭐
Programming ⭐⭐⭐⭐☆
Writing ⭐⭐⭐☆☆
```

Map stars to proficiency:
- 1 star = 0.2
- 2 stars = 0.4
- 3 stars = 0.6
- 4 stars = 0.8
- 5 stars = 1.0

### Option 2: Slider with Labels
```
Mathematics
[-------|--------]
Beginner      Expert
(0.0 - 1.0 scale)
```

### Option 3: Self-Assessment Questions
```
"I am confident in my math skills"
○ Strongly Disagree (0.2)
○ Disagree (0.4)
○ Neutral (0.6)
○ Agree (0.8)
○ Strongly Agree (1.0)
```

## Adaptive Questioning Strategy

**Step 1:** Ask about all 6 Core Academic Skills (everyone gets these)

**Step 2:** Based on RIASEC results, show relevant category:
- High Realistic → Show Hands-On/Technical Trade Skills
- High Investigative → Show Technical Skills
- High Artistic → Show fewer skills (art is less skill-dependent in O*NET)
- High Social → Show People/Social Skills
- High Enterprising → Show Business/Management Skills
- High Conventional → Show Organization/Detail skills

**Step 3:** Let users optionally add more skills if they want

## Data Format for API

Send skills as JSON array:
```json
[
  {"skill_id": "2.A.1.e", "proficiency": 0.9},
  {"skill_id": "2.B.3.e", "proficiency": 0.85},
  {"skill_id": "2.A.2.a", "proficiency": 0.8},
  {"skill_id": "2.B.4.g", "proficiency": 0.75}
]
```

## Benefits of This Approach

1. ✅ **No mapping tables needed** - Direct O*NET skill IDs
2. ✅ **More accurate matching** - Using exact same taxonomy as careers
3. ✅ **Granular proficiency** - 0.0-1.0 scale instead of binary yes/no
4. ✅ **Easier to maintain** - O*NET skills rarely change
5. ✅ **Better explanations** - Can show exactly which skills matched

## Example: STEM Student Profile

```json
{
  "skills": [
    {"skill_id": "2.A.1.e", "proficiency": 0.9, "name": "Mathematics"},
    {"skill_id": "2.A.1.f", "proficiency": 0.85, "name": "Science"},
    {"skill_id": "2.B.3.e", "proficiency": 0.8, "name": "Programming"},
    {"skill_id": "2.A.2.a", "proficiency": 0.85, "name": "Critical Thinking"},
    {"skill_id": "2.B.4.g", "proficiency": 0.75, "name": "Systems Analysis"},
    {"skill_id": "2.B.2.i", "proficiency": 0.8, "name": "Complex Problem Solving"}
  ]
}
```

**Expected Match for Software Developer:**
- Interests: 95% (high Investigative)
- Values: 96% (matches Achievement/Independence)
- **Skills: 50-60%** ← Much better than 0%!
- Context: 100% (direct interest match)
- **Blended: 85%** → Rank #1 ✅

## Implementation in Swift

See updated `SnowflakeService.swift` and `AppViewModel.swift` in next section.
