# MyPath App Refactoring Plan

## Structure Overview

Converting from a monolithic `app 2.3.swift` file to a **layer-first, feature-second** structure:

```
MyPath/
 ├─ Models/            ──┬─ Onboarding/
 │                      │   └─ …
 ├─ ViewModels/        ──┤
 ├─ Views/             ──┤
 ├─ Services/          ──┤  (Networking, Persistence, Analytics)
 ├─ Resources/         ──┤  (Assets.xcassets, Localizable.strings)
 ├─ PreviewContent/    ──┤
 └─ App root & other top‑level files
```

## Type Categorization

Based on analyzing the `app 2.3.swift` file, I've categorized all types by their responsibilities:

### Models

**Onboarding:**
- `SchoolSubject`
- `Activity`
- `Career`
- `InterestOption`
- `OnboardingStep`
- `RIASECDimension`
- `SelectionOption`
- `AuthenticationModel`

**AIChat:**
- `ChatMessage`
- `Conversation`
- `ResponseChunk`
- `ToolExecutionStatus`
- `ActivityQuestion`
- `QuestionBank`
- `RIASECQuestion`

**CareerExplorer:**
- `CareerMatch`
- `CareerInterest`
- `ProfileData`
- `InterestDetail`
- `Resource`
- `Job`
- `CareerTrack`
- `CareerPath`
- `CareerModelInput`
- `CareerModelOutput`
- `CareerScores`
- `CareerRequirements`
- `CareerOutlook`
- `CareerRecommendation`
- `ProfileAnalysis`
- `ProfileStrength`
- `DevelopmentGap`
- `DevelopmentRecommendation`
- `LearningResource`
- `Milestone`
- `MilestoneStatus`
- `PreliminaryRIASECProfile`
- `RIASECScore`
- `Usage`
- `RIASECNormalizer`
- `SkillsAnalyzer`
- `PrincipalComponentAnalyzer`
- `UserProfile`
- `EducationLevel`

**Shared:**
- `UserData`
- `QuickStat`
- `CareerModelConfig`
- `ModelWeights`
- `RetryConfiguration`

### ViewModels

**AIChat:**
- `QuestionBankViewModel`
- `AIAssistantViewModel`
- `ConversationStore`

**CareerExplorer:**
- `CareerTracksViewModel`
- `ResourcesViewModel`
- `RecommendedCareersViewModel`
- `CareerRecommendationViewModel`
- `DashboardViewModel`
- `DashboardSectionViewModel`
- `PreliminaryRIASECCalculator`
- `RIASECScoreCalculator`

**Shared:**
- `AppViewModel`

### Views

**Onboarding:**
- `LoginView`
- `SignUpView`
- `OnboardingView`
- `FavoriteSubjectsView`
- `ExtracurricularActivitiesView`
- `CareerInterestsView`
- `HelpSheetView`
- `WelcomeMessageView`
- `HowDidYouHearAboutUsView`
- `GetNameView`
- `CurrentStatusView`
- `StudentLevelView`
- `MotivationalMessageView`
- `InterestProfileIntroView`
- `InterestProfileView`
- `RIASECQuestionView`
- `QuestionCard`
- `QuestionsSection`
- `RIASECIntroView`
- `LoadingScreenView`
- `CompletionScreenView`
- `WelcomeView`
- `AccountCreationPromptView`

**AIChat:**
- `AIAssistantOverlay`
- `VoiceAssistantOverlay`
- `ChatBubble`
- `TypingIndicator`

**CareerExplorer:**
- `DashboardView`
- `CareerGuidanceDashboardView`
- `HeaderSectionView`
- `QuickStatsSectionView`
- `CareerProfileSectionView`
- `CareerTracksSectionView`
- `ResourcesSectionView`
- `CareerReadinessView`
- `CareerTracksView`
- `LearningPathView`
- `CareerLearningSection`
- `FavoritesSectionView`
- `CareerTrackOverviewView`
- `JobDetailView`
- `RecommendedCareersSectionView`
- `RecommendedNextStepsView`
- `LearningResourcesView`
- `JobCarousel`

**Shared:**
- `ContentView`
- `MainAppView`
- `CoursesView`
- `SinglesView`
- `SleepView`
- `PodcastsView`
- `SplashScreen`
- `ErrorView`
- `HeaderView`
- `BackButton`
- `ProgressBar`

### UI Components

**Shared:**
- `InputField`
- `SocialSignInButton`
- `SelectionButton`
- `InterestSelectionButton`
- `RatingButton`
- `SelectionButtonView`
- `QuickStatCard`
- `QuoteView`
- `QuoteCard`
- `InterestCard`
- `CareerTrackCard`
- `ResourceCard`
- `JobMatchCard`
- `DetailRow`
- `HelpButton`
- `NextStepItem`
- `CircleView`
- `CareerInterestPatternView`
- `ActionCard`
- `MilestoneCard`
- `TimelineView`
- `TimelineItem`
- `JobCard`
- `CubeAnimationView`
- `InterestCircle`
- `CompletionItem`

### Services

**Networking & Data:**
- `APIConfig`
- `NetworkMonitor`
- `PersistenceController`
- `SupabaseService` 
- `OpenAIService`
- `OpenAIManager`
- `CoreMLAdapter`
- `ToolRegistry`
- `CareerMatchTool`
- `UserProfileTool`
- `FieldValidationTool`
- `ErrorLogger`
- `AITool` (protocol)
- `HeaderServiceProtocol`
- `QuickStatsServiceProtocol`
- `CareerProfileServiceProtocol`
- `FeatureExtractorProtocol`
- `ModelLoaderServiceProtocol`
- `CareerRecommendationServiceProtocol`
- `ErrorLogging` (protocol)

### Utilities & Constants

**Style & UI Constants:**
- `IconSize`
- `Elevation`
- `Border`
- `Spacing`
- `Layout`
- `Motion`
- `AppColors`
- `HeaderConstants`
- `QuickStatsConstants`
- `CareerProfileConstants`
- `AppTypography`

**Button Styles:**
- `TertiaryButtonStyle`
- `PrimaryButtonStyle`
- `SecondaryButtonStyle`
- `ScaleButtonStyle`
- `CheckboxToggleStyle`

**View Modifiers:**
- `CardStyle`
- `ShimmerModifier`
- `RoundedCorner`
- `PressActions`
- `HeaderStyle`
- `QuickStatCardStyle`
- `CareerTrackCardStyle`
- `ResourceCardStyle`
- `DetailRowStyle`
- `InteractiveElement`
- `ContentSection`
- `HeadingStyle`
- `BodyStyle`
- `InputFieldStyle`
- `SectionHeaderStyle`
- `ListItemStyle`
- `NavigationBarStyle`
- `OnboardingTextStyle`
- `OnboardingSecondaryTextStyle`

**Enums & Error Types:**
- `AppFlowState`
- `InterestOptions`
- `LoadingState`
- `ViewModelError`
- `APIConstants`
- `UserDefaultsKeys`
- `ToolError`
- `QuestionBankError`
- `CareerServiceError`
- `CareerModelError`
- `QuickStatsFactory`
- `HeaderFactory`

## File Movement Plan

### 1. Core App Files

| Current Path | Target Path |
|--------------|-------------|
| `/carrer/app 2.3.swift` (MyPathApp struct) | `/carrer/MyPathApp.swift` |

### 2. Models

| Type | Target Path |
|------|-------------|
| **Onboarding** |
| `SchoolSubject`, `Activity`, `Career`, `InterestOption`, etc. | `/carrer/Models/Onboarding/` |
| **AIChat** |
| `ChatMessage`, `Conversation`, `ResponseChunk`, etc. | `/carrer/Models/AIChat/` |
| **CareerExplorer** |
| `CareerMatch`, `CareerInterest`, `ProfileData`, etc. | `/carrer/Models/CareerExplorer/` |
| **Shared** |
| `UserData`, `QuickStat`, etc. | `/carrer/Models/Shared/` |

### 3. ViewModels

| Type | Target Path |
|------|-------------|
| **AIChat** |
| `QuestionBankViewModel`, `AIAssistantViewModel`, etc. | `/carrer/ViewModels/AIChat/` |
| **CareerExplorer** |
| `CareerTracksViewModel`, `ResourcesViewModel`, etc. | `/carrer/ViewModels/CareerExplorer/` |
| **Shared** |
| `AppViewModel` | `/carrer/ViewModels/Shared/` |

### 4. Views

| Type | Target Path |
|------|-------------|
| **Onboarding** |
| `LoginView`, `SignUpView`, `OnboardingView`, etc. | `/carrer/Views/Onboarding/` |
| **AIChat** |
| `AIAssistantOverlay`, `VoiceAssistantOverlay`, etc. | `/carrer/Views/AIChat/` |
| **CareerExplorer** |
| `DashboardView`, `CareerGuidanceDashboardView`, etc. | `/carrer/Views/CareerExplorer/` |
| **Shared** |
| `ContentView`, `MainAppView`, etc. | `/carrer/Views/Shared/` |
| **UI Components** |
| `InputField`, `SocialSignInButton`, etc. | `/carrer/Views/Components/` |

### 5. Services

| Type | Target Path |
|------|-------------|
| **Networking** |
| `NetworkMonitor`, `SupabaseService`, etc. | `/carrer/Services/Networking/` |
| **Persistence** |
| `PersistenceController` | `/carrer/Services/Persistence/` |
| **AI & ML** |
| `OpenAIService`, `CoreMLAdapter`, etc. | `/carrer/Services/AI/` |
| **Tools** |
| `ToolRegistry`, `CareerMatchTool`, etc. | `/carrer/Services/Tools/` |

### 6. Utilities & Constants

| Type | Target Path |
|------|-------------|
| **Style Constants** |
| `IconSize`, `Elevation`, `AppColors`, etc. | `/carrer/Utilities/Style/` |
| **Button Styles** |
| `TertiaryButtonStyle`, `PrimaryButtonStyle`, etc. | `/carrer/Utilities/Style/Buttons/` |
| **View Modifiers** |
| `CardStyle`, `ShimmerModifier`, etc. | `/carrer/Utilities/Modifiers/` |
| **Enums & Error Types** |
| `AppFlowState`, `ViewModelError`, etc. | `/carrer/Utilities/Enums/` |

## Potential Conflicts & Risks

1. **Circular Dependencies**: The monolithic file likely has interdependencies between types that will need careful management when split
2. **Import Management**: Each new file will need proper import statements
3. **Missing Type Errors**: References to types that haven't been moved yet
4. **SwiftUI Preview Providers**: Will need to be updated for each View

## Implementation Order

1. Create all directories first
2. Move the simplest, most independent types first (Models, Constants)
3. Move Services next as they have fewer UI dependencies
4. Move ViewModels which depend on Models and Services
5. Finally move Views which depend on everything else
6. Create the AppCoordinator and slim down MyPathApp.swift