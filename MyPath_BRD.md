# Business Requirements Document (BRD) for MyPath

## 1. Executive Summary

MyPath is a career guidance and development application designed to help users discover suitable career paths based on their personal interests, skills, educational background, and preferences. The app employs a conversational AI coach to guide users through a personalized onboarding process, collecting relevant information to build a comprehensive user profile. This profile is then used to generate tailored career recommendations, providing users with actionable insights for their career journey.

## 2. Business Objectives

1. **Primary Objective**: Help users identify and pursue fulfilling career paths aligned with their unique attributes and preferences.

2. **Secondary Objectives**:
   - Provide personalized career guidance through an AI coach interface
   - Collect meaningful user data to enable accurate career matching
   - Create an engaging and intuitive user experience
   - Support users at various stages of their career journey (students, recent graduates, career changers, etc.)
   - Build a sustainable platform that can evolve with user needs and market trends

## 3. Target Audience

MyPath targets a diverse audience at different stages of their career journey:

1. **Students** (high school, CEGEP, university) seeking guidance on potential career paths based on their interests and studies
2. **Recent Graduates** entering the job market and exploring career opportunities
3. **Employed Individuals** considering career advancement or changes within their field
4. **Career Changers** looking to transition to a new industry or role
5. **Job Seekers** actively looking for employment and seeking to align opportunities with their profile

## 4. Application Features

### 4.1 Onboarding Experience

The app features a dual-mode onboarding process allowing users to choose between:

1. **Conversational AI Coach**:
   - Interactive dialogue-based data collection
   - Personalized responses based on previous inputs
   - Ability to exit to standard UI at any point
   - Context-aware prompts that explain the purpose of each question

2. **Standard UI**:
   - Form-based interface with clear labels and instructions
   - Visual selection options (cards, buttons, checkboxes)
   - Progress tracking throughout the onboarding flow
   - Ability to switch to AI coach at any point

### 4.2 Onboarding Flow Screens

The onboarding process consists of the following screens:

| Screen | OnboardingStep | UI Elements | Content | Purpose |
|--------|---------------|-------------|---------|---------|
| **Splash Screen** | N/A | Logo, Animation | App logo, loading indicator | Initial loading screen while app resources initialize |
| **How Did You Hear About Us** | .howDidYouHearAboutUs | Selection cards | Options: Social Media, Friend/Family, Search Engine, Advertisement, Blog/Article, Event, Other | Collects referral information to understand acquisition channels |
| **Enter Your Name** | .getName | Text field, Next button | Text field for user's name input | Personalizes the experience and enables addressing the user by name |
| **Welcome Message** | .welcomeMessage | Personalized greeting, Continue button | "Welcome [Name]! I'm excited to help you discover your ideal career path." | Creates a personalized connection with the user |
| **Current Status** | .currentStatus | Selection cards | Options: Student, Employed, Recent Graduate, Career Changer, Unemployed, Other | Identifies user's current career/education situation |
| **Student Level** | .studentLevel | Selection cards | Options: High School, CEGEP, University | For students, determines educational level for appropriate recommendations |
| **Motivational Message** | .motivationalMessage | Inspirational quote, Continue button | Motivational content relevant to career development | Engages the user emotionally and boosts motivation |
| **Interest Selection** | .interests | Interest cards, Multi-select | Options based on RIASEC dimensions: Fixing/Building Things, Learning, Helping Others, Creative Activities, Leadership, Planning/Organizing | Collects initial interest data for career matching |
| **RIASEC Questions - Realistic** | .riasecQuestions(dimension: .realistic) | Question cards, Likert scale | "Do You Enjoy Hands-On Work?" questions | Measures preference for practical, physical activities |
| **RIASEC Questions - Investigative** | .riasecQuestions(dimension: .investigative) | Question cards, Likert scale | "Are You Analytical?" questions | Measures preference for intellectual, research-oriented activities |
| **RIASEC Questions - Artistic** | .riasecQuestions(dimension: .artistic) | Question cards, Likert scale | "Do You Like Creative Activities?" questions | Measures preference for creative, expressive activities |
| **RIASEC Questions - Social** | .riasecQuestions(dimension: .social) | Question cards, Likert scale | "Do You Enjoy Helping Others?" questions | Measures preference for working with and helping people |
| **RIASEC Questions - Enterprising** | .riasecQuestions(dimension: .enterprising) | Question cards, Likert scale | "Are You a Natural Leader?" questions | Measures preference for leadership and persuasion activities |
| **RIASEC Questions - Conventional** | .riasecQuestions(dimension: .conventional) | Question cards, Likert scale | "Do You Like Structure?" questions | Measures preference for organization and clear procedures |
| **Favorite Subjects** | .favoriteSubjects | Subject cards, Multi-select | Options: Math, Science, Languages, Arts, History, Physical Education, etc. | Identifies academic interests that correlate with career success |
| **Extracurricular Activities** | .extracurriculars | Activity cards, Multi-select | Options: Sports, Music, Community Service, Clubs, Hobbies, etc. | Identifies non-academic interests and skills |
| **Career Interests** | .careerInterests | Career field cards, Multi-select | Options: Healthcare, Technology, Business, Creative Arts, Education, etc. | Captures explicit career preferences |
| **Loading Screen** | .loadingScreen | Progress animation, Processing message | "Analyzing your profile to find your ideal career matches..." | Provides feedback while processing profile data |
| **Completion Screen** | .completionScreen | Success message, Continue button | "Profile complete! We've found [X] potential career matches for you." | Confirms completion and transitions to main app experience |

### 4.3 AI Coach Interaction Flow

When using the AI Coach mode, the conversation follows this pattern:

1. **AI Introduction**: The AI introduces itself and explains its purpose
2. **Context-Aware Questions**: The AI asks questions based on the current onboarding step
3. **Follow-up Questions**: Based on user responses, the AI asks relevant follow-up questions
4. **Data Collection**: The AI extracts and stores information from the conversation
5. **Transition Prompts**: The AI naturally guides the user through all required topics
6. **Exit Option**: At any point, users can exit to the standard UI while preserving their data

Key AI conversational features:
- Personalization based on user name and previous responses
- Clear explanations of why information is being collected
- Options that match the standard UI selections
- Natural transitions between topics
- Ability to correct misinterpreted responses
- Context recall to avoid asking for information already provided

### 4.4 User Profile Creation

The onboarding process collects the following information:

1. **Basic Information**:
   - Name (for personalized interaction)
   - Referral source (how they heard about the app)
   - Current status (student, employed, etc.)
   - Education level (if applicable)

2. **Career-Relevant Data**:
   - Personal interests and activities
   - RIASEC dimensions (Realistic, Investigative, Artistic, Social, Enterprising, Conventional)
   - Favorite academic subjects
   - Extracurricular activities and hobbies
   - Current career interests (if any)

### 4.5 Career Recommendation Engine

Based on the collected profile data, the app provides:

1. **Career Matches**:
   - List of recommended careers based on user profile
   - Match percentage or scoring to indicate suitability
   - Brief descriptions of each career option
   - Filter and sorting capabilities

2. **Career Exploration Tools**:
   - Detailed information about specific careers
   - Required education and skills
   - Salary expectations and job market outlook
   - Related career paths and advancement opportunities

### 4.4 Learning and Development

To support users' career journey, the app offers:

1. **Skill Development Recommendations**:
   - Suggested courses, certifications, or learning paths
   - Resources to develop necessary skills for target careers
   - Progress tracking for completed activities

2. **Resource Center**:
   - Articles, videos, and other educational content
   - Links to external resources (courses, job boards, etc.)
   - Community features (if applicable)

### 4.5 Dashboard and Progress Tracking

The app includes a personalized dashboard featuring:

1. **Quick Stats**:
   - Profile completion percentage
   - Career matches found
   - Activities completed

2. **Career Tracks**:
   - Visual representation of potential career paths
   - Milestones and requirements for each track

3. **Personalized Quote/Motivation**:
   - Inspirational content relevant to the user's career journey

## 5. Technical Requirements

### 5.1 Platform and Architecture

1. **Mobile Application**:
   - iOS native application (Swift/SwiftUI)
   - Potential for cross-platform expansion in future versions

2. **Backend Services**:
   - Firebase/Firestore for authentication and data storage
   - OpenAI API integration for AI coach functionality
   - Additional APIs for career data and recommendations

### 5.2 Data Management

1. **User Data**:
   - Secure storage of personal information
   - Preference settings and profile management
   - Data export and deletion capabilities (for privacy compliance)

2. **Career Information Database**:
   - Comprehensive career descriptions and requirements
   - Regular updates to reflect job market changes
   - Categorization by RIASEC dimensions, skills, education level, etc.

### 5.3 AI Integration

1. **Conversational AI**:
   - Natural language processing for user interactions
   - Context-aware responses based on conversation history
   - Personalization based on user profile
   - Tool execution capabilities for data storage and retrieval

2. **Recommendation Algorithms**:
   - Career matching based on multiple profile attributes
   - Machine learning models for interest-to-career mapping
   - Score calculation for career/user compatibility

### 5.4 Offline Functionality

1. **Data Caching**:
   - Storage of user profile information locally
   - Synchronization when connectivity is restored
   - Essential functionality available offline

## 6. User Experience Requirements

### 6.1 Interface Design

1. **Visual Design**:
   - Clean, professional interface with consistent branding
   - Accessible color scheme and typography
   - Responsive layouts for different device sizes
   - Visual hierarchy to emphasize important information

2. **Navigation**:
   - Intuitive flow between different sections
   - Clear progress indicators during onboarding
   - Easy access to key features from dashboard
   - Minimal clicks/taps to reach desired information

### 6.2 Accessibility

1. **Standards Compliance**:
   - WCAG 2.1 AA compliance
   - Support for screen readers and assistive technologies
   - Keyboard navigation support
   - Color contrast ratios meeting accessibility standards

2. **Inclusive Design**:
   - Multiple input methods (touch, voice, text)
   - Adjustable text sizes and contrast
   - Alternative text for images and graphics

### 6.3 Performance

1. **Response Times**:
   - App launch under 3 seconds
   - Screen transitions under 300ms
   - AI responses within 2-3 seconds
   - Career recommendations generation within 5 seconds

2. **Resource Efficiency**:
   - Minimal battery consumption
   - Optimized data usage
   - Efficient storage utilization

## 7. Security and Compliance

### 7.1 Data Protection

1. **User Privacy**:
   - Transparent data collection policies
   - Secure handling of personal information
   - Encryption of sensitive data
   - User control over data sharing preferences

2. **Authentication**:
   - Secure login methods
   - Session management
   - Account recovery procedures

### 7.2 Regulatory Compliance

1. **Privacy Regulations**:
   - GDPR compliance for EU users
   - CCPA compliance for California residents
   - Other regional privacy laws as applicable

2. **Information Security**:
   - Regular security audits
   - Vulnerability assessments
   - Incident response procedures

## 8. Implementation Phases

### 8.1 Phase 1: MVP Launch

1. **Core Features**:
   - Basic onboarding (standard UI mode)
   - Simple profile creation
   - Initial career recommendations
   - Basic dashboard

2. **Timeline**: Q3 2025
3. **Success Metrics**:
   - User registration rate
   - Onboarding completion rate
   - User retention at 7 days

### 8.2 Phase 2: AI Coach Integration

1. **Key Additions**:
   - Conversational AI coach
   - Enhanced profile creation
   - Improved recommendation algorithms
   - Resource center

2. **Timeline**: Q4 2025
3. **Success Metrics**:
   - AI coach usage rate
   - User satisfaction with recommendations
   - Time spent in app

### 8.3 Phase 3: Advanced Features

1. **Enhancements**:
   - Community features
   - Learning path integration
   - Job market insights
   - Premium subscription options

2. **Timeline**: Q1-Q2 2026
3. **Success Metrics**:
   - Subscription conversion rate
   - User engagement with advanced features
   - Referral rates

## 9. Key Performance Indicators (KPIs)

### 9.1 User Engagement

1. **Daily/Monthly Active Users**
2. **Session Length and Frequency**
3. **Feature Utilization Rates**
4. **Retention Rates (7-day, 30-day, 90-day)**

### 9.2 User Satisfaction

1. **Net Promoter Score (NPS)**
2. **In-app Feedback Ratings**
3. **App Store Ratings and Reviews**
4. **Customer Support Interactions**

### 9.3 Business Performance

1. **User Acquisition Costs**
2. **Conversion Rates (free to premium)**
3. **Revenue per User**
4. **Customer Lifetime Value**

## 10. Risks and Mitigation Strategies

### 10.1 Technical Risks

1. **AI Performance Issues**:
   - Risk: AI coach may provide irrelevant or incorrect guidance
   - Mitigation: Extensive training, human review of conversations, feedback mechanisms

2. **Data Security Breaches**:
   - Risk: Unauthorized access to user personal data
   - Mitigation: Encryption, regular security audits, minimal data collection

### 10.2 Business Risks

1. **Low User Adoption**:
   - Risk: Insufficient user interest or engagement
   - Mitigation: User-centered design, beta testing, marketing strategy

2. **Competitive Pressure**:
   - Risk: Similar solutions entering the market
   - Mitigation: Unique value proposition, continuous innovation, user loyalty programs

### 10.3 Operational Risks

1. **Resource Constraints**:
   - Risk: Insufficient development resources for feature delivery
   - Mitigation: Phased approach, prioritization of features, scalable architecture

2. **Regulatory Changes**:
   - Risk: New privacy laws or AI regulations
   - Mitigation: Regular compliance reviews, adaptable data handling practices

## 11. Success Criteria

The MyPath application will be considered successful if it achieves the following within 12 months of launch:

1. **User Base**: 100,000+ registered users
2. **Engagement**: 30% monthly active user rate
3. **Satisfaction**: Average rating of 4.5+ stars in app stores
4. **Retention**: 40% user retention at 90 days
5. **Impact**: 70% of users report the app helped them make career decisions

## 12. Software Architecture

### 12.1 Architectural Overview

The MyPath application follows a modern, layered architecture with clear separation of concerns to ensure maintainability, scalability, and testability.

![MyPath Software Architecture Diagram](https://placeholder-for-architecture-diagram.com)

### 12.2 Client Architecture (iOS)

#### 12.2.1 Presentation Layer

1. **UI Components**:
   - SwiftUI views and modifiers
   - Custom components (buttons, cards, selection options)
   - Accessibility enhancements

2. **View Models**:
   - MVVM pattern implementation
   - Data binding to views
   - Business logic for UI presentation
   - State management and transitions

3. **Navigation**:
   - AppFlowState for managing application flow
   - Navigation coordination between screens
   - Deep linking support

#### 12.2.2 Domain Layer

1. **Business Logic**:
   - UseCase implementations
   - Domain-specific models and entities
   - Validation logic
   
2. **AI Coach Integration**:
   - Conversation management
   - Context tracking
   - Message handling and processing
   - Tool execution framework
   
3. **Career Matching Logic**:
   - Scoring algorithms
   - Profile analysis
   - Recommendation generation

#### 12.2.3 Data Layer

1. **Local Storage**:
   - CoreData for structured data (conversations, profile)
   - UserDefaults for preferences and settings
   - Keychain for sensitive information

2. **Remote APIs**:
   - Network clients for backend services
   - API response parsing and mapping
   - Error handling and retry logic

3. **Repository Pattern**:
   - Abstract data access for domain layer
   - Caching strategies
   - Offline-first approach

### 12.3 Backend Components

#### 12.3.1 Authentication Service

1. **Components**:
   - Firebase Authentication
   - Custom token generation
   - Session management
   - Social sign-in integration

2. **Functionality**:
   - User registration and login
   - Password reset
   - Authentication state management
   - Account linking

#### 12.3.2 Profile Service

1. **Components**:
   - Firestore database
   - Profile document structure
   - Validation rules

2. **Functionality**:
   - User profile CRUD operations
   - Profile completion tracking
   - Data versioning
   - Profile synchronization

#### 12.3.3 AI Conversation Service

1. **Components**:
   - OpenAI API integration
   - Conversation model
   - Context management
   - Tool definitions

2. **Functionality**:
   - Message processing
   - Context-aware responses
   - Tool execution for data collection
   - Error handling and recovery

#### 12.3.4 Career Recommendation Service

1. **Components**:
   - Machine learning models
   - Career database
   - Scoring engine
   - Recommendation caching

2. **Functionality**:
   - Profile analysis
   - Career matching algorithms
   - Personalized recommendations
   - Score calculation and explanation

### 12.4 Data Models

#### 12.4.1 User Profile Model

```swift
struct UserProfile {
    let id: String
    var name: String
    var referralSource: SelectionOption?
    var currentStatus: SelectionOption?
    var educationLevel: SelectionOption?
    var interests: Set<InterestOption>
    var riasecScores: [RIASECDimension: Float]
    var favoriteSubjects: [Subject]
    var extracurriculars: [Activity]
    var careerInterests: [CareerInterest]
    var profileCompletion: Float  // 0.0 to 1.0
    var lastUpdated: Date
}
```

#### 12.4.2 Conversation Model

```swift
struct Conversation {
    let id: UUID
    let userId: String?
    let startTimestamp: Date
    var lastUpdateTimestamp: Date
    var messages: [ChatMessage]
    var step: String
    var status: ConversationStatus
}

struct ChatMessage {
    let id: UUID
    var content: String
    let isUser: Bool
    let timestamp: Date
    var toolResults: [String: Any]?
}
```

#### 12.4.3 Career Model

```swift
struct Career {
    let id: String
    let title: String
    let description: String
    let educationRequirements: [String]
    let skills: [Skill]
    let salary: SalaryRange
    let outlook: JobOutlook
    let riasecProfile: [RIASECDimension: Float]
    let relatedCareers: [String]  // IDs of related careers
}
```

### 12.5 Communication Flows

#### 12.5.1 User Authentication Flow

1. User enters credentials in app
2. App sends request to Firebase Authentication
3. Firebase validates credentials and returns token
4. App stores token securely and uses for subsequent API calls
5. Token refresh is handled automatically when needed

#### 12.5.2 AI Conversation Flow

1. User sends message to AI coach
2. Message is sent to OpenAI API with conversation context
3. OpenAI processes message and generates response
4. If tools are needed, API specifies tool and parameters
5. App executes tools locally (storing data, etc.)
6. Results are sent back to OpenAI for continued processing
7. Final response is displayed to user

#### 12.5.3 Career Recommendation Flow

1. User completes profile information
2. App sends profile data to recommendation service
3. Service analyzes profile using ML models
4. Service generates career matches with scores
5. Results are cached locally and displayed to user
6. User can filter, sort, and explore matched careers

### 12.6 Integration Points

#### 12.6.1 External APIs

1. **OpenAI API**:
   - Used for: AI coach conversations
   - Integration method: RESTful API
   - Authentication: API key

2. **Firebase**:
   - Used for: Authentication, database, analytics
   - Integration method: Firebase SDK
   - Authentication: Firebase credentials

#### 12.6.2 Internal Services

1. **Career Database Service**:
   - Used for: Career information and recommendations
   - Integration method: RESTful API
   - Authentication: Service-to-service JWT

2. **User Profile Service**:
   - Used for: Profile management and synchronization
   - Integration method: Firestore SDK
   - Authentication: User token

### 12.7 Technical Debt Management

1. **Code Quality**:
   - Static analysis tools
   - Unit test coverage
   - Code review processes
   - Regular refactoring sessions

2. **Architecture Reviews**:
   - Quarterly architecture assessment
   - Performance reviews
   - Security audits
   - Dependency updates

### 12.8 File Structure and Dependencies

#### 12.8.1 Core Application Files

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **mypath-app-swift.swift** | Application entry point | AppViewModel | Main app structure, initializes environment objects, and sets up the root view |
| **app-view-model.swift** | Core app state management | UserDefaults, FirebaseService | Central view model managing app state, user session, and navigation flow |
| **app-flow-state-swift.swift** | Navigation state enum | OnboardingStep | Defines all possible app states (onboarding, dashboard, profile, etc.) |
| **user-data-keys.swift** | Data key definitions | None | Enum of all user data keys used throughout the app for type-safe data access |

#### 12.8.2 Onboarding Flow

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **onboarding-view.swift** | Primary onboarding UI | AppViewModel, OnboardingStep | Container view that orchestrates the onboarding flow steps |
| **onboarding-step.swift** | Onboarding step definitions | None | Enum defining all steps in the onboarding process with associated values |
| **how-did-you-hear-view.swift** | Referral source UI | SelectionOption, UserDataKey | First step view collecting information about how users found the app |
| **GetNameView.swift** | Name collection UI | UserDataKey | View for collecting user's name for personalization |
| **current-status-view.swift** | Status selection UI | SelectionOption, UserDataKey | View for selecting current career/education status |
| **personalize-experience-view.swift** | Preferences UI | UserDataKey | View for collecting initial personalization preferences |
| **riasec-questions-view.swift** | RIASEC assessment UI | RIASECDimension, QBank | View for administering RIASEC personality assessment |
| **riasec-scoring.swift** | RIASEC calculation | RIASECDimension | Logic for scoring and calculating RIASEC dimension results |
| **interest-profile-view.swift** | Interest selection UI | InterestOption | View for collecting user's interest preferences |
| **interest-profile-intro-view.swift** | Interests intro UI | None | Introduction view explaining the interest selection process |
| **progress-bar.swift** | Progress indicator | None | Reusable progress bar component used in onboarding |
| **welcome-message-view.swift** | Welcome screen | UserDataKey | Personalized welcome view after name collection |
| **completion-screen-view.swift** | Onboarding completion | AppViewModel | Final screen of onboarding showing completion status |
| **loading-screen-view.swift** | Processing indicator | None | Loading screen while processing user information |

#### 12.8.3 AI Coach Components

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **chat.swift** | AI conversation core | ConversationStore, OpenAIManager | Core implementation of the AI coach conversation logic |
| **AIAssistantOverlay.swift** | AI coach UI | AIAssistantViewModel | UI overlay for displaying the AI coach conversation interface |
| **MyPathPromptGenerator.swift** | Prompt generation | OnboardingStep, UserDataKey | Generates context-aware prompts for the AI based on onboarding step |
| **aicoatch.swift** | Backend services | OpenAI API, Firebase | AI backend services, tool implementation, conversation management |
| **openai-manager.swift** | API wrapper | OpenAI API | Client for OpenAI API communications |
| **openai-response.swift** | Response models | None | Data models for OpenAI API responses |
| **ConversationModel.xcdatamodeld** | Data model | CoreData | CoreData model for conversation storage |

#### 12.8.4 Dashboard and Main App

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **dashboard-view.swift** | Main dashboard UI | DashboardViewModel | Primary view after onboarding showing user's progress and options |
| **dashboard-view-model.swift** | Dashboard logic | UserDataKey, CareerService | Business logic for the dashboard, loading relevant data |
| **dashboard-section-view-model.swift** | Section management | None | View models for individual dashboard sections |
| **main-app-view.swift** | Post-onboarding container | AppViewModel | Main application container after onboarding is complete |
| **header-section-view.swift** | Dashboard header | HeaderViewModel | Reusable header component for dashboard sections |
| **header-view-model.swift** | Header logic | UserDataKey | View model providing data for the header component |
| **career-guidance-dashboard-view.swift** | Career guidance UI | CareerViewModel | Dashboard section for career guidance information |

#### 12.8.5 Career Profile Components

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **career-profile-view-model.swift** | Profile management | UserDataKey, FirebaseService | View model managing career profile data |
| **career-profile-protocol.swift** | Profile interfaces | None | Protocols defining career profile component interfaces |
| **career-profile-section-view.swift** | Profile UI section | CareerProfileViewModel | Reusable section for displaying career profile information |
| **career-tracks-view-model.swift** | Career paths | CareerTrackModel | View model for managing and displaying career paths |
| **career-tracks-section-view.swift** | Career paths UI | CareerTracksViewModel | Section displaying available career tracks and paths |
| **career-track-model.swift** | Career path data | None | Data model for career tracks and advancement paths |
| **career-track-card.swift** | Career path UI card | CareerTrackModel | Card component for displaying a career track option |
| **job-model.swift** | Job data | RIASEC | Data model for jobs/careers with requirements and details |
| **job-match-card.swift** | Job match UI | JobModel | Card component displaying a job match with compatibility score |
| **recommended-careers-view-model.swift** | Recommendations | JobModel, UserDataKey | View model for generating and managing career recommendations |

#### 12.8.6 UI Components and Styling

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **app-colors-swift.swift** | Color definitions | None | App-wide color constants and theme definitions |
| **app-typography.swift** | Typography styles | None | Text styles and font definitions |
| **app-spacing.swift** | Layout constants | None | Spacing and layout constants for consistent UI |
| **app-layout.swift** | Layout components | None | Reusable layout components and containers |
| **primary-button-style.swift** | Primary button UI | None | Styling for primary action buttons |
| **secondary-button-style.swift** | Secondary button UI | None | Styling for secondary action buttons |
| **tertiary-button-style.swift** | Tertiary button UI | None | Styling for tertiary action buttons |
| **card-style.swift** | Card component UI | None | Styling for card components used throughout the app |
| **detail-row.swift** | Detail row component | None | Reusable component for displaying detail information |
| **selection-button-view.swift** | Selection component | None | Button component for selection interfaces |
| **interest-card.swift** | Interest UI card | InterestOption | Card component for displaying interest options |
| **interest-selection-button.swift** | Interest selection UI | InterestOption | Button component for selecting interests |
| **quick-stat-card.swift** | Stat display card | None | Card component for displaying quick statistics |
| **progress-ring.swift** | Progress indicator | None | Circular progress indicator component |
| **quote-card.swift** | Quote display | None | Card component for displaying motivational quotes |
| **quote-view.swift** | Quote container | QuoteViewModel | View for displaying quotes with attribution |
| **quote-view-model.swift** | Quote management | None | View model for managing and rotating quotes |
| **resource-card.swift** | Resource display | ResourceModel | Card component for displaying learning resources |
| **view-modifiers.swift** | Custom modifiers | None | SwiftUI view modifiers for consistent styling |
| **view-extensions.swift** | View extensions | None | Extensions to SwiftUI View for added functionality |
| **color-extensions.swift** | Color utilities | None | Extensions to Color for additional functionality |

#### 12.8.7 Authentication and Services

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **auth-model.swift** | Authentication logic | Firebase Auth | Manages user authentication and session state |
| **login-view.swift** | Login UI | AuthModel | User login interface |
| **signup-view.swift** | Signup UI | AuthModel | User registration interface |
| **firebase-service.swift** | Firebase client | Firebase | Client for interacting with Firebase services |
| **constants.swift** | App constants | None | Application-wide constants and configuration values |
| **feature-extractor.swift** | ML feature extraction | CoreML | Extracts features from user data for ML models |
| **QBank.swift** | Question bank | None | Repository of questions for assessments |
| **QuestionBank.json** | Question data | None | JSON data file containing assessment questions |

#### 12.8.8 Error Handling and Utilities

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **error-view.swift** | Error display | None | Component for displaying error messages |
| **status-specific-message-view.swift** | Status messages | None | Component for displaying status-specific messages |
| **splash-screen-swift.swift** | App splash screen | None | Initial loading screen when app starts |
| **content-view-swift.swift** | Root container | AppViewModel | Root content container for the application |
| **Model.swift** | Core data models | None | Core application data models |

#### 12.8.9 ML Models

| File | Purpose | Dependencies | Description |
|------|---------|--------------|-------------|
| **Updated_CareerRecommendation_Career_Development_Score.mlmodel** | ML model | CoreML | Model for career development scoring |
| **Updated_CareerRecommendation_Job_Complexity_Score.mlmodel** | ML model | CoreML | Model for job complexity assessment |
| **Updated_CareerRecommendation_Physical_Demands_Score.mlmodel** | ML model | CoreML | Model for physical demands assessment |
| **Updated_CareerRecommendation_Social_Interaction_Score.mlmodel** | ML model | CoreML | Model for social interaction scoring |
| **Updated_CareerRecommendation_Technical_Expertise_Score.mlmodel** | ML model | CoreML | Model for technical expertise assessment |

### 12.9 Dependency Graph

```
AppViewModel (Central State)
│
├── AuthModel (User Authentication)
│   ├── LoginView
│   └── SignupView
│
├── AppFlowState (Navigation)
│   │
│   ├── OnboardingFlow
│   │   ├── OnboardingView
│   │   │   ├── HowDidYouHearView
│   │   │   ├── GetNameView
│   │   │   ├── CurrentStatusView
│   │   │   ├── StudentLevelView
│   │   │   ├── MotivationalMessageView
│   │   │   ├── InterestProfileView
│   │   │   ├── RIASECQuestionsView
│   │   │   ├── FavoriteSubjectsView
│   │   │   ├── ExtracurricularsView
│   │   │   ├── CareerInterestsView
│   │   │   ├── LoadingScreenView
│   │   │   └── CompletionScreenView
│   │   │
│   │   └── AIAssistantOverlay (Optional Path)
│   │       ├── Chat
│   │       ├── MyPathPromptGenerator
│   │       └── ConversationStore
│   │
│   └── MainAppFlow
│       ├── DashboardView
│       │   ├── CareerGuidanceDashboardView
│       │   ├── QuickStatsSectionView
│       │   ├── CareerTracksSectionView
│       │   └── ResourcesSectionView
│       │
│       ├── ProfileView
│       └── SettingsView
│
├── UserDataKeys (Data Access)
│
├── Services
│   ├── FirebaseService
│   ├── OpenAIManager
│   └── CareerService
│
└── UI Components
    ├── Button Styles
    ├── Cards
    ├── Selection Components
    └── Layout Helpers
```

## 13. Approval and Stakeholders

This Business Requirements Document requires approval from the following stakeholders:

1. Product Owner
2. Technical Lead
3. UX Design Lead
4. Business Sponsor
5. Legal/Compliance Representative

---

Document Version: 1.1
Last Updated: May 3, 2025
Prepared by: MyPath Product Team