# MyPath Career App - SwiftUI Design System Analysis

## Overview
The MyPath career app uses a modern, clean design system with a focus on clarity, progressive disclosure, and supportive visual hierarchy. The design is data-driven with emphasis on career matching tiers and milestone tracking.

---

## 1. Color Palette

### Brand Colors
- **Primary Blue**: `#3B82F6` - Main action color, links, primary CTAs
- **Accent Purple**: `#8B5CF6` - Secondary brand color, alternatives, highlights
- **Success Green**: `#34D399` - Positive states, completed milestones

### Background Colors
- **Base Background**: `#F9FAFB` - App background, subtle gradient base
- **Surface Primary**: `Color.white` - Card backgrounds, primary surfaces
- **Surface Secondary**: `#F3F4F6` - Secondary surface, section backgrounds
- **Surface Variant**: `#E5E7EB` - Disabled states, subtle dividers

### Text Colors
- **Text Primary**: `#1F2937` - Main body text, headings
- **Text Secondary**: `#6B7280` - Supporting text, descriptions
- **Text Tertiary**: `#9CA3AF` - Placeholder text, icons
- **Text on Primary**: `Color.white` - Text on blue/purple backgrounds

### Feedback/Status Colors
- **Error**: `#EF4444` - Destructive actions, errors
- **Warning**: `#F59E0B` - Cautions, important notices
- **Info**: `#3B82F6` - Informational messages
- **Success**: `#10B981` - Successful states, confirmations

### Match Tier System (Dynamic)
- **High Match** (80%+): Green accent + light green background (0.15 opacity)
- **Medium Match** (70-79%): Blue accent + light blue background (0.15 opacity)
- **Low Match** (<70%): Gray accent + light gray background (0.15 opacity)

### Special Colors
- **Top Match Badge**: Orange (`#FF9500` implicit) - Star icon with 0.15 opacity background
- **Shadows**: Black at 0.05 opacity (subtle), 0.12 opacity (elevated)

---

## 2. Typography

### Font Styles
- **Headlines/Titles**:
  - Hero Headlines: `.system(size: 34, weight: .bold, design: .rounded)`
  - Section Titles: `.system(size: 28, weight: .semibold)`
  - Card Titles: `.system(size: 20, weight: .semibold)`
  - Subheadings: `.system(size: 18, weight: .semibold)`

- **Body Text**:
  - Primary Body: `.system(size: 16, weight: .regular)`
  - Secondary Body: `.system(size: 15, weight: .regular)`
  - Supporting Text: `.system(size: 14, weight: .regular)`
  - Captions: `.system(size: 13, weight: .regular)`
  - Small Captions: `.system(size: 12, weight: .regular)`

- **Emphasis & Weights**:
  - Bold: `.bold`, `.semibold` (headlines, CTAs)
  - Medium: `.medium` (pills, badges, secondary buttons)
  - Regular: default (body text)

### Usage
- **Onboarding**: Uses `.headline` and `.system(size: 20)` with center alignment
- **MainAppView**: Size variants (28pt hero, 20pt sections, 16pt body)
- **Cards**: Headline + subheadline hierarchy
- **Minimal custom text modifiers** - relies on SwiftUI system fonts

---

## 3. Layout Patterns

### Spacing System
```swift
struct Spacing {
    static let xxs = 2        // Micro gaps
    static let xs = 4         // Minimal spacing
    static let small = 8      // Small gaps
    static let medium = 12    // Standard spacing
    static let large = 16     // Standard padding
    static let xl = 20        // Large sections
    static let xxl = 24       // Section padding
    static let xxxl = 32      // Major sections
}
```

### Corner Radius System
```swift
enum AppCornerRadius {
    static let pill = 22           // Fully rounded buttons/pills
    static let card = 20           // Card backgrounds
    static let section = 28        // Hero sections
}
```

### Common Patterns

#### 1. **Hero/Header Section**
- Gradient background (blue to purple)
- Large title (28pt+) + subtitle
- Progress pills with light background (white at 0.12 opacity)
- Corner radius of 28pt
- Icon decoration (opacity 0.35)
- Padding: 32pt vertical, 24pt horizontal

#### 2. **Card Layout**
- White background with corner radius 20pt
- Padding: 20pt (Spacing.xl)
- Subtle shadow (18pt radius @ 0.05 opacity + 4pt radius @ 0.05)
- Content: VStack with varied spacing
- Used for sections, tracks, resources

#### 3. **Button Patterns**
- **Primary CTA**: 
  - Background: Blue gradient or solid blue
  - Text: White, semibold
  - Corner radius: 12-22pt (pill style)
  - Padding: 12-16pt vertical, fills max width
  
- **Secondary/Outline**:
  - Background: Color at 0.1 opacity
  - Text: Primary color, medium weight
  - Corner radius: 20pt (pill)
  - Border: 1pt stroke at 0.3 opacity

#### 4. **Progress Bar**
- Background: Gray at 0.2 opacity
- Fill: Gradient or solid color
- Height: 4-8pt
- Corner radius: 2-4pt (rounded caps)
- Width driven by percentage

#### 5. **List/Row Patterns**
- Horizontal padding: 16-24pt
- Vertical padding: 12-16pt
- Background: Secondary surface or transparent
- Chevron indicator on right
- Icon + Text stacking

### TabView Navigation
- 4 tabs: Home, Explore, AI Coach, Profile
- Custom accent color (primary blue)
- Gradient background on dashboard

---

## 4. Component Library

### Core Components

#### **Buttons**
- `SocialSignInButton` - Social OAuth buttons with icon
- Primary CTA buttons - gradient or solid blue
- Secondary buttons - outline style with accent color
- Pill buttons - fully rounded with text + icon

#### **Cards & Containers**
- `ActionCard` - Icon + title + subtitle with blue background
- `CareerTrackCard` - Title + progress bar
- `JobCard` - Job title on colored background
- `JobMatchCard` - Job title + salary + growth + circular match %
- `MilestoneCard` - Status icon + title + progress bar + action button
- `ResourceCard` - Icon (book) + title + metadata (type, duration)
- Modern Card Modifier - applies consistent card styling

#### **Badges & Indicators**
- `MatchPill` - Qualitative match display (High/Medium/Low)
  - Size variants: small, medium, large
  - Colored background + text
  - Fully rounded (999pt radius)
- `TopMatchBadge` - Star icon + "Top match" text
  - Orange color scheme
  - Size variants: small, medium, large
- `CircleView` - Colored circle with initial/text
- `InterestCircle` - Blue circle outline with letter (RIASEC)

#### **Filters & Selection**
- `CareerInterestFilterChip` - Toggle chip with icon + text
  - Checkmark when selected
  - Rounded background (20pt)
  - Animated selection
  - Used in recommendations filtering

#### **Navigation & Headers**
- `HeaderView` - Large title "Career Guidance Dashboard"
- `TimelineView` - Container for timeline items
- `TimelineItem` - Visual timeline step indicator
- App navigation uses TabView + NavigationStack

#### **Input/Interactive**
- `RIASECCarouselView` - Multi-page carousel for interest assessment
  - Page indicator dots
  - Dimension badges (RIASEC letters)
  - Card-based questions
- Rating controls (implicit in onboarding)
- Work values selection interface

#### **Feedback & Loading**
- `LoadingOverlay` - Semi-transparent dark overlay with spinner
  - Circular progress view (scaled 1.5x)
  - White spinner + message text
  - Corner radius 20pt
- `TypingIndicator` - AI chat typing animation
- Chat bubbles for AI responses

#### **Visual Patterns**
- `CareerInterestPatternView` - Two circles with connector line + text
- `CircleView` - Colored circle with letter
- Pattern visualization for RIASEC dimensions

#### **Modifiers**
- `OnboardingTextStyle` - `.headline` + primary color + top padding
- `OnboardingSecondaryTextStyle` - 20pt system + center alignment + horizontal padding
- `RoundedCorner` - Custom selective corner rounding

### Component Sizing

#### Icon Sizes
```swift
struct IconSize {
    static let small = 16         // Small icons
    static let medium = 24        // Standard icons
    static let large = 32         // Large icons
    static let extraLarge = 48    // Hero icons
}
```

#### Avatar/Circle Sizes
- Small circles: 30-32pt
- Medium circles: 40-44pt
- Large circles: 50pt+
- Hero icons: 64-80pt

---

## 5. Overall Design Style

### Classification: **Modern Minimalist with Playful Elements**

### Key Characteristics

#### **Visual Style**
- Clean, spacious layouts with generous whitespace
- Rounded corners throughout (never sharp edges)
- Subtle shadows and depth (not material-heavy)
- Gradient accents (blue to purple hero section)
- Soft color overlays (0.1-0.15 opacity) for emphasis

#### **Aesthetic**
- **Professional yet approachable** - suitable for student/career guidance app
- **Data-focused** - emphasizes match percentages, progress, achievements
- **Progressive disclosure** - information revealed in steps
- **Encouraging tone** - success colors (green), milestone celebrations

#### **Color Philosophy**
- Blue as trust/action color
- Green for success/progress
- Minimal use of red (only errors)
- Grayscale for secondary information
- Each tier has consistent color associations (High=Green, Medium=Blue, Low=Gray)

#### **Interaction Patterns**
- Smooth transitions (0.2-0.3s animations)
- Asymmetric transitions (different slide directions for next/back)
- Haptic-ready button states (color change, shadow shift)
- Clear affordances (pills look tappable, cards look interactive)

#### **Information Architecture**
1. **Hero Section** - Grab attention, show key metrics
2. **Action Strips** - Quick actions, CTAs
3. **Content Cards** - Organized content sections
4. **Lists** - Detailed items with metadata
5. **Modals/Sheets** - Secondary workflows

#### **Onboarding Design**
- Welcome screen with large icon
- Step-by-step progression (10 steps in V2)
- Page indicators for carousel sections
- Dimension badges for RIASEC (visual context)
- Review step before generation
- Success celebration screen

#### **Career Exploration Design**
- Hero header with gradient
- Match percentage emphasis (high prominence)
- Top match badging (orange with star)
- Tier-based visual distinction
- Card-based layout for related items
- Horizontal scrolling carousels
- Quick action buttons with icons + text

#### **Dashboard Design**
- Welcome greeting with personalization
- Progress pills showing active tracks
- Activity sections (Your Tracks, Recommended, Learning)
- Horizontal scrolling content
- "Jump back in" quick actions
- Empty states with encouraging messages

---

## Design System Strengths

1. **Consistency** - Unified spacing, colors, corner radius across all views
2. **Accessibility** - Good contrast, readable fonts, semantic HTML structure
3. **Modularity** - Reusable components with configurable styling
4. **Responsiveness** - Uses GeometryReader, relative sizing
5. **Visual Hierarchy** - Clear primary/secondary/tertiary text levels
6. **Feedback** - Loading states, match breakdown explanations, progress indication

---

## Key Design Decisions

1. **Pill-style rounded buttons** - Creates a modern, friendly appearance
2. **Match tier coloring** - Green/Blue/Gray provides instant visual categorization
3. **Gradient hero sections** - Creates visual interest and guides user attention
4. **Horizontal carousels** - Space-efficient for many items
5. **Soft shadows** - Subtle depth without material design heaviness
6. **Opaque overlays** - Gentle color emphasis without harsh backgrounds

---

## File Structure Summary
- **Utilities/Style/** - Centralized color, spacing, icon size constants
- **Utilities/Modifiers/** - Text styling modifiers
- **Views/Components/** - Reusable UI components (cards, pills, badges)
- **Views/CareerExplorer/** - Career-specific detail views
- **Views/Onboarding/** - Multi-step onboarding flows (V1 and V2)
- **Views/Shared/** - Navigation, main app view, shared components
