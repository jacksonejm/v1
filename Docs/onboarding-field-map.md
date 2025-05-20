# MyPath Onboarding Field Map

This document serves as a tab-delimited representation of the onboarding fields in the MyPath app. It can be copied into Excel or a similar spreadsheet application.

## Fields by Onboarding Step

| Step ID | Step Name | Field ID | Field Label | Data Type | Required | Validation Rules | Current View | Notes |
|---------|-----------|----------|-------------|-----------|----------|------------------|--------------|-------|
| .howDidYouHearAboutUs | Welcome! How Did You Hear About Us? | .howDidYouHearAboutUs | How did you hear about us? | SelectionOption or String | Yes | Non-empty | HowDidYouHearAboutUsView | Fixed options with "Other" allowing free text |
| .getName | Let's Get to Know You | .name | Name | String | Yes | Non-empty | GetNameView | Simple text field |
| .welcomeMessage | Welcome, {name}! | N/A | N/A | N/A | N/A | N/A | WelcomeMessageView | Display-only step, no input fields |
| .currentStatus | What's Your Current Status? | .currentStatus | What's your current status? | SelectionOption or String | Yes | Non-empty | CurrentStatusView | Fixed options with "Other" allowing free text |
| .studentLevel | What's Your Student Level? | .studentLevel | What's your student level? | String | Yes | Non-empty | StudentLevelView | Selection from fixed options |
| .motivationalMessage | Motivational Message | N/A | N/A | N/A | N/A | N/A | MotivationalMessageView | Display-only step, no input fields |
| .interests | What Best Describes You? | .interests | What best describes you? | Set<InterestOption> | Yes | Count == 3 | InterestProfileView | User must select exactly 3 interests |
| .riasecQuestions (Realistic) | Do You Enjoy Hands-On Work? | .riasecResponses | RIASEC questions (Realistic) | [String: Int] | Yes | Non-empty | RIASECQuestionView | Rating 1-5 for each question |
| .riasecQuestions (Investigative) | Are You Analytical? | .riasecResponses | RIASEC questions (Investigative) | [String: Int] | Yes | Non-empty | RIASECQuestionView | Rating 1-5 for each question |
| .riasecQuestions (Artistic) | Do You Like Creative Activities? | .riasecResponses | RIASEC questions (Artistic) | [String: Int] | Yes | Non-empty | RIASECQuestionView | Rating 1-5 for each question |
| .riasecQuestions (Social) | Do You Enjoy Helping Others? | .riasecResponses | RIASEC questions (Social) | [String: Int] | Yes | Non-empty | RIASECQuestionView | Rating 1-5 for each question |
| .riasecQuestions (Enterprising) | Are You a Natural Leader? | .riasecResponses | RIASEC questions (Enterprising) | [String: Int] | Yes | Non-empty | RIASECQuestionView | Rating 1-5 for each question |
| .riasecQuestions (Conventional) | Do You Like Structure? | .riasecResponses | RIASEC questions (Conventional) | [String: Int] | Yes | Non-empty | RIASECQuestionView | Rating 1-5 for each question |
| .favoriteSubjects | What Are Your Favorite School Subjects? | .favoriteSubjects | Favorite subjects | Set<SchoolSubject> | Yes | Count 1-3 | FavoriteSubjectsView | User must select 1-3 subjects |
| .extracurriculars | What Activities Do You Enjoy Outside of School? | .extracurriculars | Activities | Set<Activity> | No | None | ExtracurricularActivitiesView | Multiple selection allowed |
| .extracurriculars | What Activities Do You Enjoy Outside of School? | .extracurricularOther | Other activity | String | No | None | ExtracurricularActivitiesView | Only visible if "Other" is selected |
| .careerInterests | What Careers Interest You the Most? | .careerInterests | Career interests | Set<Career> | No | None | CareerInterestsView | Multiple selection allowed |
| .careerInterests | What Careers Interest You the Most? | .careerInterestsOther | Other career | String | No | None | CareerInterestsView | Only visible if "Other" is selected |
| .loadingScreen | Loading Screen | N/A | N/A | N/A | N/A | N/A | LoadingScreenView | Display-only step, no input fields |
| .completionScreen | Completion Screen | N/A | N/A | N/A | N/A | N/A | CompletionScreenView | Display-only step, no input fields |

## Field Data Types

### SelectionOption
```swift
struct SelectionOption: Hashable, Identifiable {
    let title: String
    let iconName: String
    var id: String { title }
}
```

### SchoolSubject
```swift
struct SchoolSubject: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static let allSubjects: [SchoolSubject] = [
        SchoolSubject(name: "Math"),
        SchoolSubject(name: "Science"),
        SchoolSubject(name: "Art"),
        SchoolSubject(name: "History"),
        SchoolSubject(name: "English"),
        SchoolSubject(name: "Technology"),
        SchoolSubject(name: "Physical Education"),
        SchoolSubject(name: "Other")
    ]
}
```

### Activity
```swift
struct Activity: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static let allActivities: [Activity] = [
        Activity(name: "Robotics Club"),
        Activity(name: "Drama or Theatre"),
        Activity(name: "Sports"),
        Activity(name: "Debate Team"),
        Activity(name: "Volunteering"),
        Activity(name: "Music or Band"),
        Activity(name: "Other")
    ]
}
```

### Career
```swift
struct Career: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    static let suggestedCareers: [Career] = [
        Career(name: "Doctor"),
        Career(name: "Engineer"),
        Career(name: "Artist"),
        Career(name: "Entrepreneur"),
        Career(name: "Research Scientist"),
        Career(name: "Teacher"),
        Career(name: "Other")
    ]
}
```

### InterestOption
```swift
struct InterestOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
}
```

## User Data Storage

All user input is stored in the `userData` dictionary in the `AppViewModel` class:

```swift
@Published var userData: [UserDataKey: AnyHashable] = [:]
```

Where `UserDataKey` is an enum defining all the possible keys for user data:

```swift
public enum UserDataKey: Hashable {
    case howDidYouHearAboutUs
    case name
    case personalizeExperience
    case currentStatus
    case studentLevel
    case interests
    case riasecResponses
    case favoriteSubjects
    case extracurriculars
    case extracurricularOther
    case careerInterests
    case careerInterestsOther
    case riasecResults
    case careerSuggestions
    case questionBank
    case currentQuestionPage
    case completedSkills
    case completedActivities
    case hasSeenAIAssistantTutorial
    case riasecDimensions
}
```