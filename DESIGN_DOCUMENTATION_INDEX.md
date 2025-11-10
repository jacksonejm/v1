# MyPath Career App - Design Documentation Index

This directory contains comprehensive documentation of the MyPath SwiftUI design system. Use this index to navigate the design system documentation.

## Document Overview

### 1. DESIGN_SUMMARY.md - Start Here
**Best for**: Quick overview, executives, designers new to the project

A concise 2-page summary covering:
- Color palette at a glance
- Typography scale
- Core design patterns
- Component inventory
- Layout architecture
- Design philosophy & principles
- Key numbers and statistics

**Read this first** for a high-level understanding of the design approach.

---

### 2. DESIGN_SYSTEM_ANALYSIS.md - Comprehensive Reference
**Best for**: Detailed design specifications, implementation details, consistency

A thorough analysis including:
- Complete color palette with hex codes
- Typography styles and usage patterns
- Spacing system (8 levels: xxs to xxxl)
- Layout patterns (hero, cards, buttons, progress)
- Complete component library inventory
- Overall design style classification
- Design system strengths
- File structure summary

**Use this** when implementing components or need exact specifications.

---

### 3. DESIGN_IMPLEMENTATION_GUIDE.md - Developer Reference
**Best for**: Developers, builders, file locations, code examples

A practical implementation guide containing:
- Quick reference file locations
- Component library file structure
- 5 design patterns in action with code
- Color usage by component type
- Navigation patterns diagram
- Responsive design strategies
- Animation & transition details
- Dark mode considerations
- Accessibility features
- Design system extensibility guide

**Reference this** when building new features or modifying existing components.

---

## Key Design System Files

### Style & Theming
- `/carrer/Utilities/Style/AppColors.swift` - Color definitions
- `/carrer/Utilities/Style/Spacing.swift` - Spacing constants
- `/carrer/Utilities/Style/IconSize.swift` - Icon sizing

### Components (20+ reusable)
- `/carrer/Views/Components/MatchPill.swift` - Match tier indicator
- `/carrer/Views/Components/TopMatchBadge.swift` - Top match badge
- `/carrer/Views/Components/MilestoneCard.swift` - Progress tracking
- `/carrer/Views/Components/` - 20+ other components

### Main Screens
- `/carrer/Views/Shared/MainAppView.swift` - Dashboard (4 tabs)
- `/carrer/Views/Shared/ContentView.swift` - App entry point

### Onboarding
- `/carrer/Views/Onboarding/OnboardingV2/OnboardingV2View.swift` - Step router
- 10 step views (Welcome → Done)

---

## Design Highlights at a Glance

### Color Scheme
- **Primary**: Blue (#3B82F6) for actions
- **Secondary**: Purple (#8B5CF6) for alternatives
- **Match Tiers**: Green (High), Blue (Medium), Gray (Low)
- **Top Match**: Orange with star icon
- **Backgrounds**: White cards on light gray (#F9FAFB)

### Typography
- **Hero**: 34pt bold (rounded design)
- **Section**: 28pt semibold
- **Body**: 16pt regular
- **Caption**: 13pt regular
All using system fonts (no custom typefaces)

### Layout
- **Spacing**: 8-level system (2pt to 32pt)
- **Corner Radius**: 22pt (pills), 20pt (cards), 28pt (sections)
- **Shadows**: Subtle (0.05) and elevated (0.12) opacity
- **Navigation**: 4-tab TabView + NavigationStack

### Style Classification
**Modern Minimalist with Playful Elements**
- Clean, spacious layouts
- Rounded corners throughout
- Subtle shadows (not material design)
- Gradient accents (blue→purple hero)
- Professional yet approachable

---

## Quick Navigation Guide

### I want to...

#### Understand the overall design approach
→ Read: **DESIGN_SUMMARY.md** (5 min read)

#### See exact color hex codes and typography sizes
→ Read: **DESIGN_SYSTEM_ANALYSIS.md** - Section 1 & 2 (10 min)

#### Find a specific component file
→ Read: **DESIGN_IMPLEMENTATION_GUIDE.md** - Quick Reference (2 min)

#### Understand design patterns
→ Read: **DESIGN_IMPLEMENTATION_GUIDE.md** - Design Patterns in Action (10 min)

#### Build a new component
→ Read: **DESIGN_IMPLEMENTATION_GUIDE.md** - Extensibility Guide (5 min)

#### Improve accessibility
→ Read: **DESIGN_SYSTEM_ANALYSIS.md** - Section 4 (5 min)

#### Implement responsive design
→ Read: **DESIGN_IMPLEMENTATION_GUIDE.md** - Responsive Design Approach (5 min)

---

## Key Statistics

| Metric | Value |
|--------|-------|
| Color Palette | 15+ named colors |
| Text Styles | 10+ size/weight combinations |
| Spacing Levels | 8 (xxs to xxxl) |
| Component Types | 20+ distinct components |
| Corner Radius Presets | 3 (pill, card, section) |
| Shadow Depths | 2 (subtle, elevated) |
| Main Navigation Tabs | 4 (Home, Explore, Coach, Profile) |
| Onboarding Steps | 10 (V2 flow) |
| Match Tiers | 3 (High, Medium, Low) |

---

## Design System Highlights

### Strengths
✓ Consistent color usage across all views
✓ Clear spacing scale enforces alignment
✓ Reusable component library (20+ components)
✓ WCAG AA accessibility compliance
✓ Modern, clean aesthetic
✓ Well-organized file structure

### Notable Decisions
1. **Pill-style buttons** - Creates friendly, modern appearance
2. **Match tier coloring** - Green/Blue/Gray provides instant visual categorization
3. **Gradient hero sections** - Guides attention and creates visual interest
4. **Horizontal carousels** - Space-efficient for multiple items
5. **Soft shadows** - Subtle depth without heaviness
6. **Centralized tokens** - Single source of truth for colors/spacing

---

## Navigation Structure

### App Flow
```
ContentView (Entry Point)
    ↓
SplashScreen (2 sec animation)
    ↓
MainAppView (TabView with 4 tabs)
    ├─ Home Tab → Dashboard
    ├─ Explore Tab → Career Discovery
    ├─ AI Coach Tab → Chat Interface
    └─ Profile Tab → Settings & Help
```

### Onboarding Flow
```
Welcome
  ↓
Country/Language
  ↓
RIASEC (3-page carousel)
  ↓
Work Values
  ↓
Subjects & Activities
  ↓
Career Interests
  ↓
Review
  ↓
Generate
  ↓
Success Screen
```

---

## File Organization

```
/carrer/
├── Utilities/
│   ├── Style/
│   │   ├── AppColors.swift      # Primary design tokens
│   │   ├── Spacing.swift        # Spacing scale
│   │   └── IconSize.swift       # Icon dimensions
│   └── Modifiers/
│       ├── OnboardingTextStyle.swift
│       ├── OnboardingSecondaryTextStyle.swift
│       └── RoundedCorner.swift
│
├── Views/
│   ├── Components/              # 20+ reusable components
│   ├── Shared/                  # Main app views
│   ├── Onboarding/              # Onboarding flows
│   └── CareerExplorer/          # Career discovery
│
└── ViewModels/
    ├── AIChat/
    ├── CareerExplorer/
    └── Onboarding/
```

---

## Design System Rules

### Colors
- Always use `AppColors.*` constants
- Never hardcode hex values
- Match tiers auto-color via `MatchTier` enum

### Spacing
- Always use `Spacing.*` constants
- Never use arbitrary padding values
- Maintain 8-level system

### Components
- Place new components in `Views/Components/`
- Include `#Preview` blocks for testing
- Test in both light and dark modes
- Use reusable patterns, avoid duplication

### Typography
- Use system fonts (no custom typefaces)
- Follow size/weight hierarchy in analysis
- Maintain consistent text colors from AppColors

---

## Contact & Questions

For questions about:
- **Color usage**: See `AppColors.swift`
- **Spacing decisions**: See `Spacing.swift`
- **Component architecture**: See individual component files
- **Overall approach**: See `DESIGN_SYSTEM_ANALYSIS.md`
- **Implementation**: See `DESIGN_IMPLEMENTATION_GUIDE.md`

---

## Document Metadata

- **Generated**: November 10, 2025
- **App**: MyPath Career Guidance
- **Framework**: SwiftUI
- **Design Approach**: Modern Minimalist
- **Target Users**: Students, early-career professionals
- **Platforms**: iOS/iPadOS

---

Last Updated: November 10, 2025
