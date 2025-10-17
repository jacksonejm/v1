# MyPath - UX/UI Documentation

**Version:** 1.0
**Last Updated:** October 2025
**Platform:** iOS (SwiftUI)
**Target Audience:** High school and college students exploring career paths

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [App Architecture & Flow](#app-architecture--flow)
3. [Onboarding Experience](#onboarding-experience)
4. [Main App Experience](#main-app-experience)
5. [Career Discovery & Exploration](#career-discovery--exploration)
6. [Career Tracking & Planning](#career-tracking--planning)
7. [Personalization System](#personalization-system)
8. [Canadian vs U.S. Experience](#canadian-vs-us-experience)
9. [Key UX Patterns](#key-ux-patterns)
10. [Current Pain Points](#current-pain-points)
11. [Technical Considerations](#technical-considerations)

---

## Executive Summary

### Product Vision
MyPath is a career guidance app that helps students discover careers aligned with their interests, personality, work values, and skills. It combines psychometric assessments (RIASEC/Holland Codes) with real occupational data (O*NET for U.S., OaSIS/NOC for Canada) to provide personalized career recommendations.

### Core Value Proposition
- **Personalized recommendations** based on scientifically-validated assessments
- **Comprehensive career data** from government sources (O*NET, NOC)
- **Actionable career planning** with milestone-based tracking
- **Bilingual Canadian support** with region-specific requirements

### User Journey Summary
1. **Onboarding** (5-10 minutes): Multi-step assessment collecting interests, RIASEC scores, work values, and demographics
2. **Discovery** (ongoing): Browse 50+ personalized career recommendations with match scores
3. **Exploration** (per career): Deep dive into skills, requirements, salaries, job search strategies
4. **Planning** (per tracked career): Milestone-based action plan with progress tracking

---

## App Architecture & Flow

### High-Level Navigation Structure

```
App Launch
    ↓
┌─────────────────────┐
│  Onboarding Flow    │ (First time users)
│  - 14 steps         │
│  - ~5-10 minutes    │
└─────────────────────┘
    ↓
┌─────────────────────────────────────────────────────┐
│              Main App (Tab Bar)                      │
├─────────────┬─────────────┬─────────────┬───────────┤
│    Home     │   Explore   │  AI Coach   │  Profile  │
└─────────────┴─────────────┴─────────────┴───────────┘
```

### Tab Navigation
1. **Home (Dashboard)**
   - Your Career Tracks (progress cards)
   - Recommended For You (top 3 matches)
   - Learning Resources
   - Career Readiness score

2. **Explore**
   - All career recommendations with filtering
   - Career interest toggles
   - Sort/filter options

3. **AI Coach**
   - Context-aware AI assistant
   - Helps with onboarding questions
   - Career guidance

4. **Profile**
   - User settings
   - Saved careers
   - Assessment responses
   - Analytics dashboard (debug)

---

## Onboarding Experience

### Onboarding Flow (14 Steps)

#### Step 1: How Did You Hear About Us?
- **Purpose:** Track referral sources
- **Input:** Single selection from predefined options + "Other" text field
- **Duration:** 5-10 seconds

#### Step 2: Country Selection 🇨🇦🇺🇸
- **Purpose:** Determine data source (O*NET vs NOC/OaSIS)
- **Input:** Radio buttons (United States / Canada)
- **UX Note:** Critical decision point - affects all subsequent career data
- **Help available:** AI assistant explains how country selection affects recommendations

#### Step 3: Name
- **Purpose:** Personalization
- **Input:** Text field (first name)
- **Optional:** Checkbox to opt-out of personalization

#### Step 4: Welcome Message
- **Purpose:** Set expectations, build trust
- **Content:** Brief overview of assessment process
- **CTA:** "Let's Begin"

#### Step 5: Current Status
- **Purpose:** Context for recommendations
- **Options:**
  - High school student
  - College/University student
  - Recent graduate
  - Career changer
  - Exploring options
- **UX Pattern:** Card selection grid

#### Step 6: Student Level (conditional)
- **Shown if:** User selects "student" in Step 5
- **Options:** Grade 9, 10, 11, 12, College Year 1-4, Graduate school
- **UX Pattern:** Dropdown or vertical list

#### Step 7: Motivational Message
- **Purpose:** Encourage completion, reduce drop-off
- **Content:** Contextual message based on status
- **CTA:** Continue

#### Step 8: Interests
- **Purpose:** Broad career interest categories
- **Input:** Multi-select grid (8-12 interest areas)
- **Examples:** "Healthcare", "Technology", "Arts & Design", "Business"
- **UX Pattern:** Tap to toggle chips/cards
- **Validation:** Minimum 1 selection required

#### Step 9-14: RIASEC Assessment (6 dimensions)
Each RIASEC dimension has its own screen with 5-7 questions:

**Step 9: Realistic (Doers)**
- **Theme:** Hands-on, mechanical, physical work
- **Questions:** Rate agreement with statements (1-5 Likert scale)
- **Example:** "I enjoy working with tools and machinery"

**Step 10: Investigative (Thinkers)**
- **Theme:** Analytical, scientific, problem-solving
- **Questions:** 5-7 statements about research, analysis, investigation

**Step 11: Artistic (Creators)**
- **Theme:** Creative, expressive, imaginative
- **Questions:** 5-7 statements about art, design, creativity

**Step 12: Social (Helpers)**
- **Theme:** People-oriented, teaching, helping
- **Questions:** 5-7 statements about helping, teaching, caring

**Step 13: Enterprising (Persuaders)**
- **Theme:** Leadership, sales, management
- **Questions:** 5-7 statements about leading, persuading, managing

**Step 14: Conventional (Organizers)**
- **Theme:** Organized, detail-oriented, systematic
- **Questions:** 5-7 statements about organizing, accuracy, procedures

**UX Pattern for RIASEC screens:**
- Progress indicator at top (e.g., "3 of 6 dimensions")
- Dimension name and description
- 5-7 questions with 5-point scale (Strongly Disagree → Strongly Agree)
- Horizontal emoji scale: 😞 😐 🙂 😊 😄
- Back/Next navigation
- AI assistant icon for help

#### Step 15: Favorite Subjects
- **Purpose:** Academic interest mapping
- **Input:** Multi-select from common subjects
- **Examples:** Math, Science, English, History, Art, etc.
- **Validation:** Minimum 1 selection

#### Step 16: Extracurricular Activities
- **Purpose:** Skill and interest inference
- **Input:** Multi-select + "Other" text field
- **Examples:** Sports, Music, Debate, Coding club, Volunteer work
- **UX Pattern:** Searchable tag selection

#### Step 17: Career Interests (Direct)
- **Purpose:** Specific career preferences for boosting algorithm
- **Input:** Multi-select from career categories
- **Examples:** "Doctor", "Engineer", "Teacher", "Artist"
- **UX Note:** These selections give 10% boost in Recipe D v4.0 algorithm
- **Validation:** Optional (can skip)

#### Step 18: Work Values
- **Purpose:** Prioritize what matters in a career
- **Input:** Rate importance of 8-12 work values (1-5 scale)
- **Examples:**
  - Work-life balance
  - High salary potential
  - Job security
  - Helping others
  - Creativity and innovation
  - Independence
  - Recognition
  - Continuous learning
- **UX Pattern:** Slider or tap-rating for each value

#### Step 19: Loading Screen
- **Purpose:** Generate recommendations (API call to Snowflake)
- **Duration:** 3-5 seconds
- **Animation:** Progress spinner + motivational text
- **Content:** "Analyzing your responses...", "Matching with 900+ careers..."

#### Step 20: Completion Screen
- **Purpose:** Celebrate completion, set expectations
- **Content:**
  - Congratulations message
  - Summary of assessment (e.g., "Your top traits: Social, Investigative")
  - Preview of match count (e.g., "We found 50 careers matching your profile")
- **CTA:** "View My Recommendations"

### Onboarding UX Patterns

#### AI Assistant Integration
- **Availability:** Every onboarding screen
- **Trigger:** Floating "?" button in top-right corner
- **Behavior:** Opens chat modal with context-aware help
- **Tutorial:** First-time users see tooltip: "Need help? Tap here to ask questions"

#### Progress Indicators
- **Linear progress bar** at top of screen (e.g., "Step 5 of 20")
- **Percentage complete** (e.g., "25% complete")
- **Visual milestones** (e.g., Assessment → Interests → Values → Complete)

#### Navigation
- **Back button:** Always available, returns to previous step
- **Next/Continue button:** Primary CTA, validates input
- **Skip option:** Available for optional questions only
- **Save & Exit:** Not currently implemented (potential improvement)

#### Input Validation
- **Real-time validation:** Immediate feedback on invalid/incomplete inputs
- **Error states:** Red border + error message below field
- **Success states:** Green checkmark when valid
- **Disabled next button:** Until minimum requirements met

---

## Main App Experience

### Home (Dashboard)

#### Layout Structure
```
┌──────────────────────────────────────┐
│  Header: "Hello, [Name]"             │
│  Subtitle: "Your career journey..."  │
│  Profile Icon                        │
├──────────────────────────────────────┤
│  Career Readiness Card               │
│  - Progress bar (65%)                │
│  - Encouragement message             │
├──────────────────────────────────────┤
│  Your Career Tracks (3 max)         │
│  - Horizontal scroll cards           │
│  - OR Empty state with CTA           │
├──────────────────────────────────────┤
│  Recommended For You (Top 3)         │
│  - Vertical list                     │
│  - Match badges (Top Match/Tier)     │
│  - "See All" link                    │
├──────────────────────────────────────┤
│  Learning Resources                  │
│  - Horizontal scroll cards           │
│  - Placeholder content               │
└──────────────────────────────────────┘
```

#### Career Readiness Card
- **Purpose:** Gamification, progress tracking
- **Content:**
  - Percentage score (currently hardcoded to 65%)
  - Progress bar visualization
  - Motivational text: "Complete more activities to increase your score"
- **UX Note:** Currently non-functional (improvement opportunity)

#### Your Career Tracks Section

**Empty State:**
- Large icon (🎯 target)
- Heading: "Start Tracking a Career"
- Description: "Choose from personalized recommendations and build your career action plan"
- Primary CTA: "Browse Recommended Careers" (links to top recommendation)
- Visual: Dashed border, subtle background

**With Tracked Careers:**
- Horizontal scroll of 1-3 cards
- Each card shows:
  - Career title (Canadian or O*NET)
  - Top Match badge OR Match tier pill
  - Progress: "X/Y tasks" with progress bar
  - Next step preview: "Next: [Task title]"
  - "Continue" button → Track Detail View
- Card size: 260×220pt
- Spacing: 16pt between cards

#### Recommended For You Section
- Shows top 3 career recommendations
- Each row:
  - Career title (Canadian or O*NET based on country)
  - Subtitle: "Based on your interests and skills"
  - Match badge (Top Match = top 3, or tier badge)
  - O*NET verified checkmark
  - Chevron right navigation arrow
- Tap → Career Detail View
- "See All" link → All Recommendations View
- Info button → Match explanation modal

#### Match Explanation Modal
- **Trigger:** Info icon next to "Recommended For You" header
- **Content:**
  - Explanation of match percentage
  - "Based on Your Top Interests" (RIASEC)
  - "Higher = Better Fit" (90%+ strong, 70-89% good, <70% weak)
  - "Real Career Data" (O*NET attribution)
- **CTA:** "Got it!" button to dismiss

---

## Career Discovery & Exploration

### All Recommendations View

#### Header
- Title: "All Recommendations"
- Share button (top-right)
- Back navigation

#### Career Interest Filter Section
**Purpose:** Allow users to toggle career interest boosts on/off

**Layout:**
```
┌──────────────────────────────────────┐
│  Career Interests (ℹ️)               │
│  [Reset] (if filtered)               │
├──────────────────────────────────────┤
│  Horizontal scroll chips:            │
│  ✓ Artist  ✓ Doctor  ✗ Research S.  │
├──────────────────────────────────────┤
│  Status: "Showing 2 of 3 interests"  │
└──────────────────────────────────────┘
```

**Behavior:**
- **Selected chip:** Blue background, checkmark
- **Deselected chip:** Gray background, no checkmark
- **Tap to toggle:** Instantly refreshes recommendations
- **Reset button:** Appears when any interest is deselected
- **Info modal:** Explains 10% boost system (Recipe D v4.0)

**Info Modal Content:**
- "Career Interest Boosts"
- "Your selected career interests give a small boost to related careers"
- "10% Context Weight" (90% from RIASEC/values/skills)
- "Boosted Badge" (star icon explanation)
- "Toggle to Explore" (discovery encouragement)

#### Banner Message
```
⭐ Tap to toggle
Deselecting a career interest will update recommendations without that boost
```
- Light blue background
- Shows when career interests exist
- Encourages experimentation

#### Career List
- **Header:** "X Careers" count + Sort icon (non-functional)
- **Layout:** Vertical list of career cards
- **Ranking:** Numbered (#1, #2, #3...)
- **Sorting:** Best match first (Top matches → High → Medium → Low tier)

**Career Card Components:**
```
┌──────────────────────────────────────┐
│  #28  Fire Inspectors and            │
│       Investigators                  │
│       [High match] 🌟 Boosted  87%   │
│                                      │
│  Inspect buildings to detect fire... │
│                                      │
│  🎓 Varies    💰 Varies              │
└──────────────────────────────────────┘
```

**Card Elements:**
1. **Rank number:** #1-50 in gray
2. **Title:** Canadian or O*NET (consistent with detail view)
3. **Match tier badge:** Green pill (High/Medium/Low match)
4. **Boost indicator:** Star + "Boosted" (if applicable)
5. **Match percentage:** Large, right-aligned, color-coded
   - 90-100%: Green
   - 80-89%: Blue
   - 70-79%: Primary color
   - 60-69%: Orange
   - <60%: Gray
6. **Description:** 2-line preview (Canadian or O*NET)
7. **Education:** Icon + text (e.g., "Bachelor's degree")
8. **Salary:** Icon + range (e.g., "$50K-$80K") or "Varies"
9. **Chevron:** Right arrow for navigation

**Tap behavior:** Navigate to Career Detail View

#### Empty State
- Shows if no recommendations (shouldn't happen post-onboarding)
- Icon: 🔍 Magnifying glass
- Message: "No Recommendations"
- Subtitle: "Complete your onboarding to get personalized career matches"

#### Loading State
- **Overlay:** Semi-transparent black background
- **Spinner:** White, 1.5× scale
- **Message:** "Updating recommendations..."
- **Trigger:** When toggling career interests

---

### Career Detail View

**Purpose:** Deep dive into a single career with comprehensive data

#### Navigation
- Back button (top-left)
- Share button (top-right, iOS native share sheet)
- Large title (Canadian or O*NET title based on country)

#### Header Section
```
┌──────────────────────────────────────┐
│  [Large Title]                       │
│  Textile engineers                   │
│                                      │
│  [High match] 🌟 Boosted             │
│  NOC 21399                           │
│                                      │
│  ❓ Why this match?  See breakdown   │
└──────────────────────────────────────┘
```

**Elements:**
1. **Title:** Large, bold (Canadian title for Canadian users, O*NET for U.S.)
2. **Badges:**
   - Top Match badge (gold star, top 3 careers) OR
   - Match tier pill (High/Medium/Low)
   - "Boosted" badge (if career interest boost applies)
3. **Code:**
   - Canadian: "NOC 21399" (gray text)
   - U.S.: "O*NET 17-2141.00" (gray text)
4. **Why this match button:** Light blue pill, opens breakdown modal

#### Add to Track CTA
**Not Tracked:**
```
┌──────────────────────────────────────┐
│  ➕  Add to Track                    │
│      Start planning your path...  →  │
└──────────────────────────────────────┘
```
- Blue background, white text
- Prominent, above content
- Tap → Add to Track sheet

**Already Tracked:**
```
┌──────────────────────────────────────┐
│  ✓  Currently Tracking               │
│      Tap to view your progress    →  │
└──────────────────────────────────────┘
```
- Green background (10% opacity)
- Green border
- Green checkmark icon
- Tap → Track Detail View

#### Match Breakdown Modal (Why this match?)
- **Trigger:** "Why this match?" button
- **Content:**
  - Match percentage breakdown
  - RIASEC alignment scores
  - Work values alignment
  - Skills match percentage
  - Career interest boost (if applicable)
- **Visualization:** Progress bars for each component
- **CTA:** "Close" button

#### About This Career
- **Heading:** "About This Career"
- **Content:**
  - Canadian users: OaSIS description (if available)
  - U.S. users: O*NET description
  - Fallback: O*NET if no Canadian data
- **Font:** Body, secondary color
- **Length:** 2-4 sentences typically

#### Personality Match (conditional)
**Shows if:** RIASEC match data exists
```
┌──────────────────────────────────────┐
│  Personality Match                   │
│  👤 Investigative, Realistic         │
└──────────────────────────────────────┘
```
- Gray background box
- Icon + text
- Explains RIASEC alignment

#### Canadian-Specific Sections
**Only shown for Canadian users when NOC mapping exists:**

##### Titre français (French Title)
- **Heading:** "Titre français" (muted gray)
- **Content:** Italic, gray text
- **Example:** "Ingénieurs/ingénieures en textiles"
- **Purpose:** Bilingual support for Canadian market

##### Employment Requirements
```
Employment Requirements

• A bachelor's degree in an appropriate
  engineering discipline is required.

• A master's degree or doctorate in a related
  engineering discipline may be required.

• Engineers are eligible for registration...

• Licensing by a provincial or territorial
  association of professional engineers...
```
- **Source:** OaSIS Canadian data
- **Format:** Bulleted list with blue bullets
- **Font:** Body, secondary color
- **Purpose:** Canadian-specific licensing, education requirements

##### Main Duties
```
Main Duties

• Design and develop processes, equipment
  and procedures for the production of fibres,
  yarns and textiles.

• [Additional duties...]
```
- **Source:** OaSIS Canadian data
- **Format:** Bulleted list (shows first 5, expandable)
- **Font:** Body, secondary color
- **Purpose:** Job responsibilities specific to Canadian context

#### Required Skills Section
**Always shown (from O*NET):**

```
Required Skills

┌──────────────────────────────────────┐
│  Reading Comprehension               │
│  Importance ▓▓▓▓▓▓▓▓░░░░  Level ▓▓▓▓▓▓▓▓▓░░│
├──────────────────────────────────────┤
│  Science                             │
│  Importance ▓▓▓▓░░░░░░░░  Level ▓▓▓▓▓▓░░░░░│
├──────────────────────────────────────┤
│  Critical Thinking                   │
│  Importance ▓▓▓▓▓▓▓▓░░░░  Level ▓▓▓▓▓▓▓░░░░│
└──────────────────────────────────────┘
```

**Elements per skill:**
1. **Skill name:** Bold, subheadline font
2. **Importance bar:** Blue, percentage fill (0-100%)
3. **Level bar:** Blue, percentage fill (0-100%)
4. **Labels:** "Importance" and "Level" in caption font

**Data source:** O*NET skill requirements (SP_GET_CAREER_SKILLS)
**Shows:** Top 10 skills, sorted by importance

#### Technologies & Tools (conditional)
**Shows if:** Data exists from job search strategy

```
Technologies & Tools

[AutoCAD] [SolidWorks] [MATLAB] [Python]
```
- Horizontal scroll
- Pill-shaped chips
- Light blue background (10% opacity)
- Blue text
- Shows top 10 technologies

#### Also Known As (conditional)
**Shows if:** Valid alternate job titles exist

```
Also Known As

→ Textile Manufacturing Engineer
→ Fiber Engineer
→ Yarn Production Specialist
```
- **Source:** Blended from Canadian example titles + O*NET alternate titles
- **Format:** Bulleted list with arrow icons
- **Filtering:** Excludes single-character entries, numbers only, duplicates
- **Shows:** Maximum 5 titles

**Current bug fixed:** Previously showed "1" as a title (database artifact)

#### Find Jobs Section
**Always shown (from O*NET job search strategy):**

```
Find Jobs

[🔗 Search on LinkedIn      →]
[🔗 Search on Indeed        →]
[🔗 Search on Google Jobs   →]
```
- 3 job board links
- Gray background boxes
- External link icon (↗)
- **Behavior:** Opens job search in Safari with pre-filled career title

#### Attribution Footer
**Canadian users with NOC data:**
```
Data from Canadian OaSIS & O*NET
Employment and Social Development Canada • U.S. Department of Labor
```

**U.S. users or no NOC mapping:**
```
Powered by O*NET
U.S. Department of Labor
```

- Small caption font
- Gray text
- Centered
- 24pt top padding

---

## Career Tracking & Planning

### Track Detail View

**Purpose:** Guide users through career preparation milestones with actionable tasks

#### Navigation
- Back button → Returns to Dashboard or Career Detail
- Title: Career name (Canadian or O*NET)

#### Header Section
```
┌──────────────────────────────────────┐
│  Textile engineers                   │
│  [High match]                        │
│  Progress: 2/8 tasks (25%)          │
│  ▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
└──────────────────────────────────────┘
```

**Elements:**
1. **Title:** Career name (consistent with detail view)
2. **Match badge:** Top Match OR Match tier
3. **Progress text:** "X/Y tasks completed"
4. **Progress percentage:** 0-100%
5. **Progress bar:** Visual representation

#### Milestones & Tasks

**5 Default Milestones:**

##### Milestone 1: Understand the Role
**Purpose:** Initial research and familiarization

**Default tasks:**
- ☐ Read career overview
  - **Type:** Learn
  - **Payload:** `{"section": "overview"}`
- ☐ Review top required skills
  - **Type:** Learn
  - **Payload:** `{"section": "skills"}`

##### Milestone 2: Assess Gaps
**Purpose:** Identify skill deficiencies

**Default tasks:**
- ☐ Complete skill self-assessment
  - **Type:** Learn
  - **Payload:** `{"action": "assess_skills"}`
  - **Opens:** Skill Assessment Sheet
- ☐ Identify 2-3 skills to develop
  - **Type:** Compare
  - **Payload:** `{"action": "identify_gaps"}`

##### Milestone 3: Plan Education
**Purpose:** Determine educational pathway

**Default tasks:**
- ☐ Confirm education requirement: [Bachelor's Degree]
  - **Type:** Plan
  - **Payload:** `{"education_level": "Bachelor's Degree"}`
- ☐ Research relevant programs or courses
  - **Type:** Plan
  - **Payload:** `{"action": "research_programs"}`

##### Milestone 4: Do Activities
**Purpose:** Actively close skill gaps

**Default tasks:**
- ☐ Complete an activity for a gap skill
  - **Type:** Close Gap
  - **Payload:** `{"action": "close_gap"}`

##### Milestone 5: Prepare Job Search (conditional)
**Purpose:** Get ready to apply

**Default tasks:**
- ☐ Review job search strategy
  - **Type:** Prepare
  - **Payload:** `{"action": "review_job_strategy"}`
  - **Shows only if:** O*NET code exists

#### Task UI Components

**Task Status States:**
1. **Pending:** ☐ Empty checkbox, gray text
2. **In Progress:** 🔄 Blue circle, blue text
3. **Completed:** ✅ Green checkmark, strikethrough text

**Task Actions:**
- **Tap task:** Mark as in progress
- **Tap again:** Mark as complete
- **Long press:** Options menu (delete, edit - not implemented)

**Milestone Completion:**
- When all tasks in milestone complete → Confetti animation
- Analytics event: "milestone_completed"

#### Skill Assessment Sheet
**Trigger:** "Complete skill self-assessment" task

**Layout:**
```
┌──────────────────────────────────────┐
│  Assess Your Skills                  │
│  [Close]                             │
├──────────────────────────────────────┤
│  Rate your current level for each    │
│  skill required for this career.     │
├──────────────────────────────────────┤
│  Reading Comprehension               │
│  ○ None  ○ Basic  ○ Intermediate    │
│  ○ Advanced  ○ Expert                │
├──────────────────────────────────────┤
│  Critical Thinking                   │
│  ○ None  ○ Basic  ○ Intermediate    │
│  ○ Advanced  ○ Expert                │
├──────────────────────────────────────┤
│  [Submit Assessment]                 │
└──────────────────────────────────────┘
```

**Behavior:**
- Shows top 5-10 skills for the career
- 5-level skill rating per skill
- Saves to UserSkillsData model
- Used for skill gap calculation
- Triggers analytics: "skill_assessed"

#### Skill Gap Visualization (Future Feature)
**Not yet implemented, but planned:**

```
Skill Gaps to Close

1. Advanced Mathematics
   Your level: Basic  Required: Advanced
   ▓▓░░░░░░░░  Gap: 70%

2. Critical Thinking
   Your level: Intermediate  Required: Expert
   ▓▓▓▓▓░░░░░  Gap: 50%
```

#### Notes Section
**Purpose:** Free-form notes per tracked career

```
┌──────────────────────────────────────┐
│  Notes                               │
│  ┌────────────────────────────────┐ │
│  │ Spoke to advisor, need to take │ │
│  │ calculus before applying...    │ │
│  └────────────────────────────────┘ │
└──────────────────────────────────────┘
```
- Text area, multi-line
- Auto-saves on change
- Analytics: "notes_updated" (when non-empty)

#### Archive/Remove Options
**Bottom actions:**
- **Archive:** Marks track as completed/abandoned, keeps history
- **Remove:** Deletes track entirely

**Archive triggers analytics:**
- Career title
- Completion percentage
- Tasks completed
- Days tracked

---

## Personalization System

### Recipe D v4.0 (Current Matching Algorithm)

#### Algorithm Components

**1. RIASEC Personality Matching (Primary - 60%)**
- 6 dimension scores (R, I, A, S, E, C) from onboarding
- Each career has RIASEC profile from O*NET
- Cosine similarity between user and career profiles
- **Weight:** 60% of total match score

**2. Work Values Alignment (Secondary - 20%)**
- 8-12 work values rated by user (1-5 scale)
- Careers have work importance/context from O*NET
- Vector comparison: user priorities vs career characteristics
- **Weight:** 20% of total match score

**3. Skills Match (Tertiary - 10%)**
- Top skills from user's RIASEC profile
- Career required skills from O*NET
- Match percentage based on overlap
- **Weight:** 10% of total match score

**4. Career Interest Boost (Context - 10%)**
- User-selected career interests from onboarding
- If career matches interest category: +10 points
- Multiple interests can boost (multiplicative)
- **Weight:** 10% of total match score
- **User control:** Can toggle interests on/off in All Recommendations view

#### Match Score Calculation
```
Final Score = (RIASEC × 0.6) + (Work Values × 0.2) + (Skills × 0.1) + (Career Interest × 0.1)

Range: 0-100%
```

#### Match Tiers
Careers are bucketed into 4 tiers:

1. **Top Match** (Top 3 careers)
   - Special gold star badge
   - Priority placement in UI
   - "Your top matches" messaging

2. **High Match** (85-100%)
   - Green badge: "High match"
   - "Excellent alignment with your profile"

3. **Medium Match** (70-84%)
   - Blue badge: "Medium match"
   - "Good fit for your interests"

4. **Low Match** (Below 70%)
   - Gray badge: "Low match"
   - "Some alignment, explore with caution"

**Sorting:** Top matches first, then High → Medium → Low, then by score within tier

#### Boosted Careers
- **Visual indicator:** 🌟 "Boosted" badge
- **Trigger:** Career title matches selected career interest
- **Algorithm:** Simple keyword matching (lowercase contains)
- **User visibility:** Obvious in UI, explained in info modal
- **User control:** Can toggle interests to see score change

### Personalization Data Flow

```
User Onboarding Input
        ↓
  RIASEC Scores + Work Values + Interests
        ↓
   Snowflake SQL Procedure (SP_GET_CAREER_RECOMMENDATIONS_V4)
        ↓
  Recipe D v4.0 Calculation
        ↓
  50 Ranked Careers with Match %
        ↓
  Optional: Career Interest Filter Toggle
        ↓
   Updated Rankings (Real-time)
        ↓
    Display in UI
```

### Data Storage

**UserDefaults (via AppViewModel.userData):**
- RIASEC scores: `.riasecResponses`, `.riasecResults`
- Work values: `.workValues`
- Career interests: `.careerInterests`
- Active filters: `.activeCareerInterests`
- Tracked careers: `.trackedCareers`
- Skill assessments: `.userSkillsData`

**CloudKit Sync:** Not currently implemented (improvement opportunity)

---

## Canadian vs U.S. Experience

### Country Selection Impact

#### Data Source Differences

| Aspect | United States (O*NET) | Canada (NOC/OaSIS) |
|--------|----------------------|-------------------|
| **Occupation Count** | 923 careers | 900 occupations |
| **Code System** | O*NET SOC (e.g., 15-1252.00) | NOC 2021 (e.g., 21399) |
| **Primary Data Source** | O*NET Database | OaSIS (Occupational and Skills Information System) |
| **Fallback** | N/A | O*NET (for non-mapped careers) |
| **Language** | English only | English + French (bilingual) |
| **Coverage** | 100% O*NET | ~66% NOC-mapped, 34% O*NET fallback |

#### User Experience Differences

##### List Views (All Recommendations, Dashboard)

**U.S. Users:**
```
#1  Software Developers, Applications
    High match                          92%
    Design and develop software applications...
    🎓 Bachelor's degree  💰 $90K-$120K
```

**Canadian Users:**
```
#1  Software engineers and designers
    High match                          92%
    Research, design, and develop computer software...
    🎓 Bachelor's degree  💰 $80K-$110K
```
- **Title:** Canadian NOC title (when mapping exists)
- **Description:** OaSIS description (when available)
- **Education/Salary:** Same source (O*NET Bright Outlook data)

##### Career Detail View

**U.S. Users See:**
- O*NET title
- O*NET code (e.g., "O*NET 15-1252.00")
- O*NET description
- Required Skills (O*NET)
- Technologies & Tools (O*NET)
- Also Known As (O*NET alternate titles)
- Find Jobs links
- Attribution: "Powered by O*NET"

**Canadian Users See (with NOC mapping):**
- Canadian NOC title
- NOC code (e.g., "NOC 21399")
- OaSIS description
- **Titre français** (French title) ← Unique
- **Employment Requirements** (Canadian licensing, education) ← Unique
- **Main Duties** (Canadian job responsibilities) ← Unique
- Required Skills (O*NET - same)
- Technologies & Tools (O*NET - same)
- Also Known As (Blended: Canadian example titles + O*NET)
- Find Jobs links (same)
- Attribution: "Data from Canadian OaSIS & O*NET"

**Canadian Users (NO NOC mapping - 34% of careers):**
- Falls back to O*NET experience (identical to U.S.)
- No French title, employment requirements, or main duties
- Attribution: "Powered by O*NET"
- **Key:** No error messages or "data unavailable" warnings

### Hybrid Approach Benefits

1. **Best of both worlds:** Canadian context where available, O*NET fallback ensures completeness
2. **No data gaps:** Users never see "not available" or empty sections
3. **Transparent attribution:** Users know data source, builds trust
4. **Bilingual support:** French titles for Francophone Canadians
5. **Region-specific:** Canadian licensing, educational requirements

### NOC-O*NET Crosswalk

**Mapping Quality:**
- **Source:** Brookfield Institute NOC 2021 ↔ O*NET v26 crosswalk
- **Count:** 1,466 mappings
- **Confidence levels:** HIGH, MEDIUM, LOW
- **Coverage:** 98.5% of user recommendations have NOC data (based on Recipe D v4.0)

**Data Enrichment Process:**
1. User completes onboarding → generates O*NET recommendations
2. App checks country: if Canada, fetch Canadian enrichment
3. Snowflake procedure joins:
   - O*NET career recommendations (SP_GET_CAREER_RECOMMENDATIONS_V4)
   - NOC-O*NET crosswalk (NOC_ONET_CROSSWALK)
   - OaSIS occupation data (OASIS_NOC_*)
4. Returns blended data keyed by O*NET code
5. App stores in `canadianOccupationData` dictionary
6. UI seamlessly chooses Canadian or O*NET data per field

---

## Key UX Patterns

### Design System

#### Colors
- **Primary:** Blue (`AppColors.primary`)
- **Success:** Green (tracking, completion)
- **Warning:** Orange (medium match)
- **Error:** Red (validation, low match)
- **Secondary Text:** Gray (#8E8E93)
- **Background:** System background (white/black adaptive)

#### Typography
- **Title:** System Large Title, Bold
- **Headline:** System Headline, Semibold
- **Subheadline:** System Subheadline
- **Body:** System Body
- **Caption:** System Caption

#### Badges & Pills
1. **Top Match Badge**
   - Gold/yellow star icon
   - "Top match" text
   - Peach/orange background (#FFF4E6)
   - Small/medium/large sizes

2. **Match Tier Pills**
   - **High:** Green background, "High match"
   - **Medium:** Blue background, "Medium match"
   - **Low:** Gray background, "Low match"

3. **Boost Badge**
   - Star icon + "Boosted" text
   - Primary color
   - Light primary background (15% opacity)

#### Cards & Containers
- **Corner radius:** 12pt standard
- **Padding:** 16pt standard
- **Background:** Gray opacity (5-10%)
- **Border:** 1pt gray opacity (20%) or none
- **Shadow:** Minimal or none (flat design)

#### Progress Indicators
- **Linear bar:** 6pt height, rounded corners (3pt)
- **Background:** Gray 20% opacity
- **Fill:** Primary color
- **Text:** "X/Y" or "X%" above or beside

#### Empty States
- Large icon (48-64pt)
- Heading text
- Descriptive subtitle (2-3 lines)
- Primary CTA button
- Centered layout
- Optional dashed border for emphasis

### Navigation Patterns

#### Tab Bar (Primary Navigation)
- 4 tabs: Home, Explore, AI Coach, Profile
- Icons: SF Symbols
- Active state: Primary color
- Inactive state: Gray
- Badge support: Not currently used

#### NavigationStack (Hierarchical)
- Large titles on root views
- Inline titles on child views
- Back button: System default
- Right bar items: Share, info, etc.

#### Modal Sheets
- **Detents:** .medium, .large
- **Dismiss:** Swipe down or explicit button
- **Use cases:** Info modals, forms, AI assistant

### Interaction Patterns

#### Tap Targets
- Minimum size: 44×44pt (Apple HIG)
- Cards: Entire card tappable
- Lists: Entire row tappable
- Buttons: At least 44pt height

#### Feedback
- **Haptics:** On task completion, milestone completion
- **Animation:** Subtle scale on tap, confetti on milestone
- **Loading states:** Spinner + message overlay

#### Error Handling
- Inline validation messages
- Alert modals for critical errors
- Retry buttons when appropriate
- Graceful degradation (fallback data)

### Accessibility Considerations (Current State)

**Implemented:**
- Dynamic Type support (system fonts)
- VoiceOver labels on interactive elements
- Semantic colors (adapts to dark mode)
- Sufficient contrast ratios

**Not Implemented (Improvement Areas):**
- VoiceOver hints/instructions
- Alternative text for images/icons
- Keyboard navigation (iPad)
- Reduced motion support
- Screen reader optimized complex views

---

## Current Pain Points

### High Priority Issues

#### 1. Title Inconsistency (FIXED in latest build)
**Problem:** Career titles differed between list and detail views for Canadian users
- List: "Producers and Directors" (O*NET)
- Detail: "Directors of photography" (NOC)

**Impact:** Confusing, breaks user trust
**Status:** ✅ Fixed - now shows Canadian titles consistently

#### 2. Empty Alternate Titles
**Problem:** "Also Known As" section showing bullet "1" with no text
**Cause:** Database artifact or parsing error
**Impact:** Looks broken, unprofessional
**Status:** ✅ Fixed - stronger filtering logic

#### 3. Career Readiness Score (Non-functional)
**Problem:** Progress bar and score are hardcoded (65%)
**Impact:** Misleading, breaks gamification
**Priority:** Medium
**Recommendation:** Either implement properly or remove entirely

#### 4. Navigation State Bug (Intermittent)
**Problem:** Clicking top 3 careers sometimes shows wrong career detail
**Impact:** Critical UX issue, data integrity concern
**Status:** Cannot reproduce consistently, needs investigation
**Hypothesis:** SwiftUI navigation state caching or list ID collision

### Medium Priority Issues

#### 5. Career Interest Toggle Confusion
**Problem:** Users may not understand 10% boost system
**Impact:** Feature discoverability, value perception
**Current mitigation:** Info modal explains, but users must tap to discover

#### 6. No Search/Filter in All Recommendations
**Problem:** 50 careers, but no way to search by title or filter by criteria
**Impact:** Browsing friction, information overload
**Recommendation:** Add search bar + filter options (education level, salary range, etc.)

#### 7. Learning Resources (Placeholder)
**Problem:** Dashboard shows "Learning Resources" with fake data
**Impact:** Sets false expectations
**Recommendation:** Remove until real content available, or clearly label as "Coming Soon"

#### 8. No Save & Resume in Onboarding
**Problem:** 20-step onboarding with no ability to save progress
**Impact:** High drop-off risk if interrupted
**Recommendation:** Implement draft save, resume from last completed step

#### 9. Skill Assessment Sheet (Limited Context)
**Problem:** Users assess skills without reference to career requirements
**Impact:** May over/under-estimate skill levels
**Recommendation:** Show career requirement level alongside user assessment

### Low Priority Issues

#### 10. Sort/Filter Menu (Non-functional)
**Problem:** All Recommendations has sort icon but no functionality
**Impact:** Minor, but users may expect it to work
**Recommendation:** Implement basic sort (alphabetical, match %, salary) or remove icon

#### 11. AI Coach Not Deeply Integrated
**Problem:** AI assistant is available but users may not discover it
**Impact:** Underutilized feature
**Recommendation:** Proactive tooltips, suggested questions, onboarding tutorial

#### 12. No Social Features
**Problem:** Career exploration is solitary experience
**Impact:** Missed engagement opportunity
**Ideas:** Share career tracks, compare with friends, discussion forums

---

## Technical Considerations

### Performance

#### Data Loading
- **Onboarding:** 3-5 second Snowflake API call for recommendations
- **Career detail:** 1-2 second API calls for skills + job search strategy
- **All Recommendations filter:** 3-5 second re-fetch when toggling interests
- **Optimization needed:** Client-side caching, predictive loading

#### API Rate Limits
- Snowflake REST API: 100 requests/minute (per account)
- Current usage: ~5 requests per user session
- No rate limiting implemented app-side

#### Offline Support
- **Current:** None - requires network for all data
- **Improvement:** Cache recommendations, allow offline browsing
- **Challenge:** Stale data, sync conflicts

### Platform Constraints

#### iOS Version Support
- **Minimum:** iOS 17.5
- **Target:** iOS 18.x
- **Impact:** Latest SwiftUI features available, but excludes older devices

#### iPad Support
- **Current status:** Scales iPhone UI, no iPad-optimized layouts
- **Recommendation:** Design tablet-specific layouts (split view, multiple columns)

#### macOS (Catalyst)
- **Current status:** Not supported
- **Potential:** Could run as Mac app with Catalyst

### Data Privacy & Security

#### Personal Data Collected
- Name (optional)
- Country
- RIASEC responses
- Work values
- Career interests
- Tracked careers
- Skill assessments

#### Storage
- **Local:** UserDefaults (unencrypted)
- **Server:** Snowflake database (encrypted at rest)
- **Sync:** None (no CloudKit, no account system)

#### Privacy Considerations
- No user authentication (anonymous usage)
- No data sharing or export (yet)
- No analytics opt-out (improvement needed)
- GDPR/CCPA compliance: Not addressed

---

## Recommendations for UX Expert Review

### Key Questions for Feedback

1. **Onboarding Flow:**
   - Is 20 steps too long? Where would you reduce?
   - Should we show progress differently (e.g., section-based vs step count)?
   - Is the AI assistant discoverable enough?

2. **Career Discovery:**
   - Are 50 recommendations overwhelming? Should we paginate or show fewer by default?
   - Is the match percentage explanation clear?
   - Should we add more filtering/search capabilities?

3. **Career Detail:**
   - Is the information hierarchy correct?
   - Too much information? Not enough?
   - Should we separate Canadian vs O*NET sections more clearly, or is seamless blending better?

4. **Career Tracking:**
   - Are milestones intuitive?
   - Is task interaction obvious (tap to mark in progress/complete)?
   - Should we add more guidance on HOW to complete tasks?

5. **Visual Design:**
   - Does the design feel modern and trustworthy?
   - Is color usage effective (match tiers, badges, CTA buttons)?
   - Any accessibility concerns?

6. **Navigation:**
   - Is the tab bar the right primary navigation?
   - Are there too many nested screens?
   - Should Explore be more prominent than Home?

7. **Personalization:**
   - Is the career interest toggle feature discoverable?
   - Do users understand how their onboarding responses affect recommendations?
   - Should we show more transparency in algorithm (e.g., "This career matches your high Artistic score")?

### Specific Areas Needing Improvement

1. **Information Architecture:** Feels complex with multiple nested views
2. **Empty States:** Need more thoughtful, actionable empty states
3. **Gamification:** Career readiness score is half-baked, needs full implementation or removal
4. **Search/Discoverability:** No way to search 50 careers or filter by criteria
5. **Onboarding Drop-off:** 20 steps with no save/resume is risky
6. **Mobile Optimization:** Some text-heavy sections may need better mobile layout
7. **Accessibility:** Needs audit for VoiceOver, color contrast, reduced motion

### Success Metrics to Consider

- **Onboarding completion rate:** Target 80%+
- **Career detail view depth:** Time spent, sections scrolled
- **Career tracking adoption:** % of users who track at least 1 career
- **Return usage:** DAU/MAU ratio
- **Career interest toggle usage:** % of users who experiment with filtering

---

## Appendices

### Glossary

- **RIASEC:** Realistic, Investigative, Artistic, Social, Enterprising, Conventional (Holland Codes)
- **O*NET:** Occupational Information Network (U.S. Department of Labor)
- **NOC:** National Occupational Classification (Canada)
- **OaSIS:** Occupational and Skills Information System (Canada)
- **SOC:** Standard Occupational Classification (U.S. code system)
- **Recipe D v4.0:** Current matching algorithm version
- **Match Tier:** Bucketing system (Top/High/Medium/Low)
- **Boost:** +10 point algorithm modifier for career interest alignment

### Technical Stack

- **Frontend:** SwiftUI (iOS 17.5+)
- **Backend:** Snowflake SQL stored procedures
- **Data Sources:** O*NET API, OaSIS CSVs, Brookfield Institute NOC crosswalk
- **Analytics:** AnalyticsService (custom implementation)
- **AI:** Not yet integrated (placeholder for future)

### File Structure Reference

```
carrer/
├── Models/
│   ├── CareerExplorer/
│   │   ├── CareerTrack.swift
│   │   ├── CareerSkill.swift
│   │   ├── CanadianOccupation.swift
│   │   ├── MatchTier.swift
│   ├── Shared/
│   │   ├── UserCountry.swift
│   │   ├── UserDataKey.swift
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   ├── Shared/
│   │   ├── MainAppView.swift (Dashboard + Tabs)
│   ├── CareerExplorer/
│   │   ├── AllRecommendationsView.swift
│   │   ├── ONetCareerDetailView.swift
│   │   ├── TrackDetailView.swift
│   ├── Components/
│   │   ├── TopMatchBadge.swift
│   │   ├── MatchPill.swift
│   │   ├── CareerInterestFilterChip.swift
├── ViewModels/
│   ├── AppViewModel.swift (Central state)
│   ├── OnboardingStore.swift
│   ├── CareerTracksViewModel.swift
│   ├── ONetCareerViewModel.swift
├── Services/
│   ├── Networking/
│   │   ├── SnowflakeService.swift
│   ├── Analytics/
│   │   ├── AnalyticsService.swift
```

---

## Document Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Oct 2025 | AI Assistant | Initial comprehensive documentation |

---

**End of Document**

For questions or clarifications, please contact the development team.
