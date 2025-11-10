# MyPath Design System - Implementation Guide & File References

## Quick Reference: Key Design Files

### Color & Style System
```
/home/user/v1/carrer/Utilities/Style/
├── AppColors.swift           # Hex color definitions & color extensions
├── Spacing.swift             # Spacing constants (xxs-xxxl)
└── IconSize.swift            # Icon sizing (small-extraLarge)
```

### Text & Modifiers
```
/home/user/v1/carrer/Utilities/Modifiers/
├── OnboardingTextStyle.swift          # Headline + foreground + padding
├── OnboardingSecondaryTextStyle.swift # 20pt system + center aligned
└── RoundedCorner.swift                # Custom selective corner rounding
```

### Core Components Library
```
/home/user/v1/carrer/Views/Components/
├── ActionCard.swift              # Icon + title + subtitle card
├── CareerTrackCard.swift         # Title + progress bar
├── JobCard.swift                 # Job title in colored background
├── JobMatchCard.swift            # Job + match % + salary + growth
├── MilestoneCard.swift           # Status + progress + action button
├── ResourceCard.swift            # Icon + title + metadata
├── MatchPill.swift               # High/Medium/Low match display
├── TopMatchBadge.swift           # Star + "Top match" (orange)
├── CareerInterestFilterChip.swift # Toggle chip with animation
├── CircleView.swift              # Colored circle with letter
├── InterestCircle.swift          # Blue outlined circle (RIASEC)
├── CareerInterestPatternView.swift # Two circles + connector
├── HeaderView.swift              # Dashboard header
├── TimelineView.swift            # Timeline container
├── TimelineItem.swift            # Timeline step
├── SocialSignInButton.swift      # OAuth button wrapper
├── LoadingOverlay.swift          # Dark overlay + spinner
└── RoundedCorner.swift           # Custom rounded corners
```

### Main Screens
```
/home/user/v1/carrer/Views/Shared/
├── MainAppView.swift             # Tab-based dashboard (Home/Explore/AI/Profile)
├── ContentView.swift             # App entry point + flow routing
├── SplashScreen.swift            # Launch animation
└── MatchPill.swift              # Match display component
└── TopMatchBadge.swift          # Top match indicator
```

### Onboarding V2 (Primary Flow)
```
/home/user/v1/carrer/Views/Onboarding/OnboardingV2/
├── OnboardingV2View.swift            # Step router (welcome → done)
├── WelcomeStepView.swift             # 🎯 Welcome with hero icon
├── CountryLanguageStepView.swift     # 🌍 Country & language selection
├── RIASECCarouselView.swift          # 📊 Interest assessment (3 pages)
├── WorkValuesStepView.swift          # 💼 Work values selection
├── SubjectsActivitiesStepView.swift  # 📚 Education & activities
├── CareerInterestsStepView.swift     # ✨ Career interest boosting
├── ReviewStepView.swift              # 👀 Review all responses
├── GenerateStepView.swift            # ⚙️ Processing recommendations
└── DoneStepView.swift                # 🎉 Success celebration
```

### Career Explorer Views
```
/home/user/v1/carrer/Views/CareerExplorer/
├── CareerTracksView.swift                # All tracked careers
├── CareerTrackSectionView.swift          # Single track details
├── ONetCareerDetailView.swift            # Career detail (O*NET integration)
├── AllRecommendationsView.swift          # All recommended careers
├── RecommendedCareersSection.swift       # Carousel of recommendations
├── MatchBreakdownView.swift              # Match percentage explanation
├── JobDetailView.swift                   # Job posting details
├── SkillAssessmentSheet.swift            # Skills for a career
├── LearningPathView.swift                # Learning progression
├── CareerLearningSection.swift           # Learning cards
├── ResourcesSection.swift                # Resource links
├── TrackDetailView.swift                 # Track progress view
└── HeaderSection.swift                   # Career page headers
```

---

## Design Patterns in Action

### Pattern 1: Hero Section
**File**: `/home/user/v1/carrer/Views/Shared/MainAppView.swift` (lines 75-105)
```
┌─────────────────────────────────┐
│  [sparkles icon - 0.35 opacity]│
│  Hi, Name!                       │
│  "Let's build momentum..."       │
│  [Tracks: 2]  [Top Match: 92%]  │
└─────────────────────────────────┘
Gradient: Blue → Purple
Corner radius: 28pt
Padding: 32pt v, 24pt h
```

### Pattern 2: Card Section
**File**: `/home/user/v1/carrer/Views/Shared/MainAppView.swift` (lines 313-355)
```
┌──────────────────────────────────┐
│ 📌 Your Career Tracks      [See all]
│ "Plan milestone-based steps..."   │
├──────────────────────────────────┤
│ ┌─ Career Title     [Top Match]─┐
│ │ 45% complete  •  3/7 tasks    │
│ │ ████░ Progress Bar            │
│ │ ➜ Next: Complete Skills Test  │
│ │ [Continue Plan →]             │
│ └───────────────────────────────┘
└──────────────────────────────────┘
White card: corner 20pt, padding 20pt
Shadow: 18pt@0.05 + 4pt@0.05
```

### Pattern 3: Match Tier Indicator
**File**: `/home/user/v1/carrer/Views/Shared/MatchPill.swift`
```
High Match:     [✓ High]      Green pill
Medium Match:   [✓ Medium]    Blue pill
Low Match:      [✓ Low]       Gray pill

Top Match:      [⭐ Top match] Orange pill
```

### Pattern 4: Quick Action Button
**File**: `/home/user/v1/carrer/Views/Shared/MainAppView.swift` (lines 798-835)
```
┌─────────────────────────────────────┐
│ [circle icon]  Title                │
│                Subtitle        [›]  │
└─────────────────────────────────────┘
Background: Secondary surface @ 0.65
Corner radius: 22pt (pill)
Icon: Primary blue in gray circle
```

### Pattern 5: Onboarding Step
**File**: `/home/user/v1/carrer/Views/Onboarding/OnboardingV2/WelcomeStepView.swift`
```
                 Spacer()
                    
        [map.fill icon - 80pt]
        Discover Your Path
        "We'll help you find..."
        
                 Spacer()
        
        [Get Started Button]
        (Blue, corner 12pt, 50pt height)
```

---

## Color Usage by Component

### Buttons & CTAs
- Primary: `AppColors.primaryBlue` (#3B82F6)
- Gradient CTA: `AppGradient.hero` (Blue→Purple)
- Pill radius: 22pt

### Cards & Sections
- Background: `AppColors.surfacePrimary` (white)
- Secondary: `AppColors.surfaceSecondary` (#F3F4F6)
- Corner: 20pt
- Padding: 20pt (Spacing.xl)

### Match Tiers
- High (80%+): Green text on light green background
- Medium (70-79%): Blue text on light blue background
- Low (<70%): Gray text on light gray background
- All: 0.15 opacity backgrounds, fully rounded (999pt)

### Text Hierarchy
- Hero: 34pt bold (rounded design)
- Title: 28pt semibold
- Section: 20pt semibold
- Body: 16pt regular
- Caption: 13pt regular
- All primary text: #1F2937

### Special Effects
- Hover gradient: Light at 0.12 opacity
- Subtle shadow: Black at 0.05 opacity
- Elevated shadow: Black at 0.12 opacity
- Disabled: Gray at various opacities

---

## Key Navigation Patterns

### Main App Navigation (TabView)
**File**: `/home/user/v1/carrer/Views/Shared/MainAppView.swift` (lines 14-46)
```
┌────────────────────────────────────┐
│  [Content Area]                    │
├────────────────────────────────────┤
│ [home] [search] [chat] [person]    │
│  Home   Explore  AI Coach Profile  │
```

### Onboarding Flow
**File**: `/home/user/v1/carrer/Views/Onboarding/OnboardingV2/OnboardingV2View.swift`
```
Welcome
  ↓
Country/Language
  ↓
RIASEC Assessment (3 pages)
  ↓
Work Values
  ↓
Subjects & Activities
  ↓
Career Interests
  ↓
Review
  ↓
Generate Recommendations
  ↓
Completion Screen
```

### Career Detail Navigation
**File**: `/home/user/v1/carrer/Views/CareerExplorer/ONetCareerDetailView.swift`
```
Career List
  ↓ (NavigationLink)
Career Detail
  ├─ Header + Match info
  ├─ Description
  ├─ Skills
  ├─ Technologies
  ├─ Job Search Links
  └─ Attribution
```

---

## Responsive Design Approach

### Layout Strategies
1. **Geometry Reader** - Dynamic width-based sizing
   - Progress bars scale to available width
   - Carousels use screen width calculations
   
2. **Frame Constraints** - Fixed sizes with max/min
   - Career track cards: 280pt width
   - Resource cards: 200pt × 170pt
   - Icon sizes: 16-80pt range

3. **Spacing** - Proportional padding
   - Horizontal: 24pt standard, 32pt edges
   - Vertical: 12-32pt based on importance

4. **ScrollView** - For overflow content
   - Horizontal carousels (tracks, resources)
   - Vertical lists (recommendations, careers)
   - `.showsIndicators(false)` for clean look

---

## Animation & Transition Patterns

### Duration
- Quick feedback: 0.2s
- Standard: 0.3s
- Page transitions: 0.3s
- Splash screen: 1.0s entry

### Types
- **easeInOut** - Smooth transitions
- **easeOut** - Deceleration (splash fade)
- **asymmetric** - Different insertion/removal
  - Entry: slide right + fade
  - Exit: slide left + fade

### Interactive
- Selection feedback: 0.2s animation on chips
- Loading: circular progress spinner (1.5x scale)
- Button presses: color + shadow change

---

## Dark Mode Considerations

- Uses system colors where possible
- Light backgrounds adapt to dark theme
- Text colors flip automatically
- Badges tested in dark mode (see TopMatchBadge_Previews)
- Shadows soften in dark mode

---

## Accessibility Features

1. **Color Contrast** - WCAG AA compliant
2. **Font Sizes** - Minimum 13pt body, 16pt headlines
3. **Touch Targets** - 44pt minimum tap areas
4. **Labels** - Accessibility labels on badges/buttons
5. **Text Hierarchy** - Clear primary/secondary information
6. **Icons** - Always paired with text (except decorative)

---

## Design System Extensibility

To add new components:

1. **Create in Views/Components/**
2. **Use AppColors for colors**
3. **Use Spacing constants for padding**
4. **Use AppCornerRadius for rounded corners**
5. **Add preview in #Preview block**
6. **Follow VStack/HStack composition pattern**

To modify theme:

1. Edit `AppColors.swift` for colors
2. Edit `Spacing.swift` for dimensions
3. Edit `AppCornerRadius` in AppColors.swift
4. Update gradients in `AppGradient` enum

---

## Summary Statistics

- **Color Palette**: 15+ named colors
- **Text Styles**: 10+ size/weight combinations
- **Spacing Levels**: 8 (xxs to xxxl)
- **Component Types**: 20+ distinct components
- **Corner Radius Presets**: 3 (pill, card, section)
- **Shadow Depths**: 2 (subtle, elevated)
- **Main Views**: 20+ screens
- **Onboarding Steps**: 10 (V2 flow)
- **Navigation Tabs**: 4 (Home, Explore, Coach, Profile)
