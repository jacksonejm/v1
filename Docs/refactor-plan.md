# MyPath iOS App Refactor Plan

## Introduction
This document outlines the plan for refactoring the MyPath iOS app to implement the "Guided Onboarding" feature. The goal is to enable users to switch to an AI Assistant that fills onboarding forms conversationally.

## Current Code Repository Structure
The codebase follows an MVVM architecture with the following top-level folders:
- Models
- ViewModels
- Views
- Services
- Utilities

Each main area contains feature-specific subfolders for:
- Onboarding
- CareerExplorer
- AIChat
- Shared

## Open Questions for PO/UX

1. **AI Assistant Visibility:**
   - Should the AI Assistant be available on every onboarding step or only on specific steps?
   - When a user dismisses the AI Assistant, should it remember the conversation when reopened on the same step?

2. **Data Confidence Thresholds:**
   - What confidence threshold should be required for the AI to auto-populate a field without follow-up?
   - For low-confidence extractions, should the AI suggest a value or ask for confirmation?

3. **Validation and Error Handling:**
   - When the AI extracts a value that doesn't match available options (e.g., a career not in our list), should we:
     a) Map to the closest match
     b) Add it as a custom entry if the field supports it
     c) Reject it and ask for clarification

4. **UI/UX Considerations:**
   - How should the UI indicate that a field has been auto-populated by the AI?
   - Should users be able to edit AI-populated fields directly, or should they use the chat interface?

5. **Step Navigation:**
   - Can the AI Assistant advance users to the next step automatically after collecting all required information?
   - Should there be a confirmation step before advancing?

6. **Conversation Memory:**
   - How much of the conversation history should be preserved across steps?
   - Should the AI reference information shared in previous steps?

7. **Fallback Mechanisms:**
   - If the AI service is unavailable, should we:
     a) Hide the AI Assistant option entirely
     b) Show a degraded experience with canned responses
     c) Queue requests for processing when service is restored

8. **User Preferences:**
   - Should we allow users to set preferences for the AI Assistant (e.g., verbosity, formality)?
   - Should we remember these preferences across sessions?

9. **Multi-field Extraction:**
   - If a user provides information for multiple fields in a single message, should we:
     a) Update all relevant fields immediately
     b) Focus on one field at a time and acknowledge the other information was captured
     c) Ask for confirmation for each field separately

10. **Integration with Analytics:**
    - What specific metrics should we track related to AI Assistant usage?
    - Do we need separate event tracking for AI-populated fields vs. manually entered data?

11. **Personalization Level:**
    - How personalized should the AI responses be based on previously collected information?
    - Should the AI adapt its communication style based on user demographics (e.g., high school vs. college student)?

12. **RIASEC Assessment Special Handling:**
    - The RIASEC assessment involves multiple steps with ratings. Should the AI:
      a) Handle one dimension per conversation
      b) Allow for answering multiple dimensions at once
      c) Provide a different interface for this section entirely

## Appendix A: Swift File Inventory

### Views

| File Path | Type | Description |
|-----------|------|-------------|
| /carrer/Views/Onboarding/OnboardingView.swift | View | Main onboarding container view that manages step navigation and content |
| /carrer/Views/Onboarding/WelcomeView.swift | View | Welcome screen with app introduction and call-to-action buttons |
| /carrer/Views/Onboarding/LoginView.swift | View | Login screen for existing users |
| /carrer/Views/Onboarding/AccountCreationPromptView.swift | View | Modal view prompting user to create an account |
| /carrer/Views/AIChat/AIAssistantOverlay.swift | View | Chat interface overlay for AI assistance |
| /carrer/Views/AIChat/ChatBubble.swift | View | Message bubble component for chat UI |
| /carrer/Views/AIChat/TypingIndicator.swift | View | Animation indicating AI is composing a response |
| /carrer/Views/AIChat/VoiceAssistantOverlay.swift | View | Voice input interface for AI assistance |
| /carrer/Views/Shared/ContentView.swift | View | Root view for the app that manages app state |
| /carrer/Views/Shared/MainAppView.swift | View | Main app container after onboarding |
| /carrer/Views/Shared/SplashScreen.swift | View | Initial loading screen |

### ViewModels

| File Path | Type | Description |
|-----------|------|-------------|
| /carrer/ViewModels/Shared/AppViewModel.swift | ViewModel | Main view model managing app state and user data |
| /carrer/ViewModels/Shared/AppCoordinator.swift | ViewModel | Coordinates navigation between major app sections |
| /carrer/ViewModels/AIChat/AIAssistantViewModel.swift | ViewModel | Manages AI assistant conversation state |
| /carrer/ViewModels/AIChat/ConversationStore.swift | ViewModel | Handles saving and loading conversation data |
| /carrer/ViewModels/CareerExplorer/RIASECScoreCalculator.swift | ViewModel | Calculates career interest scores from RIASEC responses |

### Models

| File Path | Type | Description |
|-----------|------|-------------|
| /carrer/Models/Onboarding/OnboardingStep.swift | Model | Enum defining all onboarding steps |
| /carrer/Models/Onboarding/RIASECDimension.swift | Model | Enum defining RIASEC personality dimensions |
| /carrer/Models/Onboarding/SelectionOption.swift | Model | Data structure for selectable options |
| /carrer/Models/AIChat/ChatMessage.swift | Model | Data structure for chat messages |
| /carrer/Models/AIChat/Conversation.swift | Model | Data structure for chat conversations |
| /carrer/Models/AIChat/ResponseChunk.swift | Model | Data structure for streamed AI responses |
| /carrer/Models/CareerExplorer/CareerTrack.swift | Model | Career path data model |
| /carrer/Models/CareerExplorer/Job.swift | Model | Individual job data model |
| /carrer/Models/CareerExplorer/Milestone.swift | Model | Career milestone data model |
| /carrer/Models/CareerExplorer/MilestoneStatus.swift | Model | Enum for milestone completion status |
| /carrer/Models/CareerExplorer/RIASECQuestion.swift | Model | Question model for career assessment |
| /carrer/Models/Shared/Usage.swift | Model | Tracks app usage statistics |
| /carrer/Models/Shared/UserDataKey.swift | Model | Keys for accessing user data dictionary |

### Services

| File Path | Type | Description |
|-----------|------|-------------|
| /carrer/Services/AI/OpenAIService.swift | Service | Handles communication with OpenAI API |
| /carrer/Services/Networking/APIConfig.swift | Service | API configuration settings |
| /carrer/Services/Networking/NetworkMonitor.swift | Service | Monitors network connectivity |
| /carrer/Services/Networking/SupabaseService.swift | Service | Handles communication with Supabase backend |
| /carrer/Services/Persistence/PersistenceController.swift | Service | Manages Core Data persistence |
| /carrer/Services/Tools/AITool.swift | Service | Base implementation for AI tools |
| /carrer/Services/Tools/ToolRegistry.swift | Service | Registry for available AI tools |
| /carrer/Services/Tools/ToolError.swift | Service | Error types for AI tools |

### Other

| File Path | Type | Description |
|-----------|------|-------------|
| /carrer/MyPathApp.swift | App | Main SwiftUI app entry point |
| /carrer/Utilities/Enums/AppFlowState.swift | Utility | Enum defining major app navigation states |