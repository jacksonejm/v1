# Gap Analysis: Current Onboarding vs. Guided Onboarding Spec

This document analyzes the current onboarding implementation against the requirements for the new Guided Onboarding feature. It identifies key gaps and required changes for implementation.

## 1. Current Architecture vs. Target Architecture

### Current Architecture

- User data for onboarding is stored directly in the `AppViewModel` using a dictionary:
  ```swift
  @Published var userData: [UserDataKey: AnyHashable] = [:]
  ```
- Navigation through onboarding steps is controlled by `AppViewModel` methods
- The AI assistant exists but is currently separate from the onboarding flow
- No mechanism for AI to directly update form fields

### Target Architecture (Guided Onboarding)

- Shared `OnboardingStore` that can be accessed by both the form UI and AI Assistant
- Validation layer between parsed AI responses and data storage
- Logging system to track all AI-initiated changes with before/after snapshots
- AI integration that can extract entities from conversation and write to the store

## 2. Required Changes and Gaps

### Data Layer Gaps

| Component | Current Status | Required Change | Gap Severity |
|-----------|---------------|-----------------|--------------|
| OnboardingStore | Missing | Create a centralized store for onboarding data | High |
| Data Validation | Inline in views | Extract to shared validation service | Medium |
| Change Tracking | Missing | Implement before/after snapshots for all writes | Medium |
| Confidence Scoring | Missing | Add confidence scores for AI-extracted entities | High |

### Architectural Gaps

| Component | Current Status | Required Change | Gap Severity |
|-----------|---------------|-----------------|--------------|
| AI Integration | Standalone | Connect AI to shared data store | High |
| Entity Extraction | Missing | Implement entity extraction from messages | High |
| Field Mapping | Missing | Create mapping between AI entities and form fields | High |
| Form Pre-population | Missing | Add mechanism to update UI when AI changes data | Medium |

### Backend Service Gaps

| Component | Current Status | Required Change | Gap Severity |
|-----------|---------------|-----------------|--------------|
| AI Parsing API | Missing | Implement /ai/parse endpoint | High |
| Data Write API | Missing | Implement /ai/commit endpoint | High |
| Validation Gateway | Missing | Implement validation for AI-parsed data | High |
| Logging Service | Basic | Enhance for detailed change tracking | Medium |

## 3. Field-Specific Gaps

| Field | Current Validation | Required Additional Validation | Gap |
|-------|-------------------|-------------------------------|-----|
| name | Non-empty | Parse first/last name components | Medium |
| howDidYouHearAboutUs | Selection from options | Map free text responses to options | Medium |
| currentStatus | Selection from options | Map free text responses to options | Medium |
| studentLevel | Selection from options | Extract grade level from conversation | Medium |
| interests | Exactly 3 selections | Extract interests from conversation, map to options | High |
| riasecResponses | Rating 1-5 for questions | Extract sentiment and map to ratings | High |
| favoriteSubjects | 1-3 selections | Extract subjects from conversation | Medium |
| extracurriculars | Multiple selections | Map activities mentioned to options | Low |
| careerInterests | Multiple selections | Map career mentions to options | Low |

## 4. Enhancement Opportunities

- **Contextual Assistance**: AI could provide more detailed explanations about steps
- **Progressive Disclosure**: AI could gradually introduce more complex onboarding concepts
- **Smart Defaults**: AI could suggest reasonable defaults based on partial information
- **Cross-Field Intelligence**: AI could use information from one field to make suggestions for others
- **Multi-step Extraction**: AI could extract multiple field values from a single user message

## 5. Technical Implementation Requirements

### New Components Needed

1. **OnboardingStore**: Source of truth for all onboarding data
   ```swift
   class OnboardingStore: ObservableObject {
       @Published var fields: [UserDataKey: FieldState] = [:]
       // Methods for validated updates with change tracking
   }
   
   struct FieldState {
       let value: Any
       let lastUpdated: Date
       let source: UpdateSource // user, ai, default
       let confidence: Float? // Only for AI updates
   }
   ```

2. **ValidationService**: Centralized validation logic
   ```swift
   protocol FieldValidator {
       func validate(value: Any) -> ValidationResult
   }
   
   struct ValidationResult {
       let isValid: Bool
       let modifiedValue: Any? // For corrections
       let message: String? // For validation failure explanations
   }
   ```

3. **EntityExtractor**: Extract structured data from AI conversations
   ```swift
   protocol EntityExtractor {
       func extractEntities(from message: String, forField: UserDataKey) -> ExtractionResult
   }
   
   struct ExtractionResult {
       let field: UserDataKey
       let value: Any
       let confidence: Float
   }
   ```

4. **ChangeLogger**: Track all data changes
   ```swift
   class ChangeLogger {
       func logChange(field: UserDataKey, oldValue: Any?, newValue: Any, source: UpdateSource)
   }
   ```

## 6. Integration Points with Existing Code

1. **AppViewModel**: Update to use OnboardingStore instead of direct dictionary
2. **AIAssistantViewModel**: Enhance to extract entities and update OnboardingStore
3. **OnboardingView**: Modify to observe OnboardingStore for pre-filled values
4. **Validation**: Extract inline validation from views to centralized service

## 7. Risky Areas and Potential Issues

1. **Mismatch between AI understanding and form options**: AI might extract "School" when the form expects "Friend or Family"
2. **Confidence thresholds**: Setting appropriate confidence thresholds for automatic updates
3. **UI feedback**: Clear indication to users when AI has auto-filled forms
4. **Conversion between data types**: AI extracts strings but fields may require complex objects
5. **Performance impact**: Additional validation and logging may impact performance

## 8. Testing Considerations

1. **Entity extraction accuracy**: Test suite for various user inputs and expected extractions
2. **Cross-field validation**: Ensure changes in one field don't invalidate others
3. **Error handling**: Test various error conditions and recovery mechanisms
4. **Performance testing**: Ensure responsive UI during AI processing
5. **Integration testing**: Verify end-to-end flow from conversation to form updates