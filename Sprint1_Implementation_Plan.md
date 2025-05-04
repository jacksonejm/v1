# Sprint 1 Implementation Plan: Shared State Refactor

## Overview

This document outlines the implementation plan for Sprint 1, which focuses on refactoring the app's state management to use a centralized `OnboardingStore` instead of scattered state variables. This will provide a single source of truth for both the card-based UI and future AI interactions.

## 0. Pre-work: Inventory & Gap Check

### Files to Analyze
Based on the project structure, these are the onboarding files to review:

- `/carrer/New/how-did-you-hear-view.swift`
- `/carrer/New/GetNameView.swift`
- `/carrer/New/current-status-view.swift` 
- `/carrer/New/personalize-experience-view.swift`
- `/carrer/New/interest-profile-view.swift`
- `/carrer/New/interest-profile-intro-view.swift`
- `/carrer/New/riasec-questions-view.swift`
- `/carrer/New/riasec-profile-view.swift`
- `/carrer/New/onboarding-view.swift`
- `/carrer/New/welcome-message-view.swift`
- `/carrer/New/loading-screen-view.swift`
- `/carrer/New/completion-screen-view.swift`

### State Inventory (Preliminary)
| File | Property | Type | Persists? |
|------|----------|------|-----------|
| `how-did-you-hear-view.swift` | `selectedOption` | `SelectionOption?` | Yes - UserDefaults |
| `GetNameView.swift` | `name` | `String` | Yes - UserDefaults |
| `current-status-view.swift` | `selectedStatus` | `SelectionOption?` | Yes - UserDefaults |
| `interest-profile-view.swift` | `selectedInterests` | `Set<InterestOption>` | Yes - UserDefaults |
| `riasec-questions-view.swift` | `responses` | `[String: Int]` | Yes - UserDefaults |
| `riasec-profile-view.swift` | `scores` | `[RIASECDimension: Float]` | Yes - UserDefaults |

*Note: This is a preliminary list based on expected patterns. The actual implementation will require a thorough code review.*

## 1. StepFieldSpec Definition (Story FE-1.1)

### Implementation Plan

1. Create the JSON specification file:
   - File path: `/carrer/Resources/StepFieldSpec.json`
   - Include all onboarding steps with their fields, requirements, and UI flags

2. Create the parsing model:
   - File path: `/carrer/Core/Models/StepFieldSpec.swift`
   - Implement `Decodable` structs for the JSON schema
   - Add helper methods for step validation

3. Create unit tests:
   - File path: `/carrer/Tests/StepFieldSpecTests.swift`
   - Test JSON loading
   - Test step count verification
   - Test required fields validation

### StepFieldSpec.json Structure

```json
{
  "order": [
    "howDidYouHearAboutUs",
    "getName",
    "welcomeMessage",
    "currentStatus",
    "studentLevel",
    "motivationalMessage",
    "interests",
    "riasecRealistic",
    "riasecInvestigative",
    "riasecArtistic",
    "riasecSocial",
    "riasecEnterprising",
    "riasecConventional",
    "favoriteSubjects",
    "extracurriculars",
    "careerInterests",
    "loadingScreen",
    "completionScreen"
  ],
  "steps": {
    "howDidYouHearAboutUs": {
      "fields": ["referralSource"],
      "required": ["referralSource"],
      "uiOnly": false
    },
    "getName": {
      "fields": ["name"],
      "required": ["name"],
      "uiOnly": false
    },
    "welcomeMessage": {
      "fields": [],
      "required": [],
      "uiOnly": true
    },
    "currentStatus": {
      "fields": ["currentStatus"],
      "required": ["currentStatus"],
      "uiOnly": false
    },
    "studentLevel": {
      "fields": ["studentLevel"],
      "required": ["studentLevel"],
      "uiOnly": false,
      "conditional": {
        "dependsOn": "currentStatus",
        "showWhen": "student"
      }
    },
    "motivationalMessage": {
      "fields": [],
      "required": [],
      "uiOnly": true
    },
    "interests": {
      "fields": ["interests"],
      "required": ["interests"],
      "uiOnly": false,
      "validation": {
        "minCount": 1,
        "maxCount": 3
      }
    },
    "riasecRealistic": {
      "fields": ["riasecScores.realistic"],
      "required": ["riasecScores.realistic"],
      "uiOnly": false
    },
    "riasecInvestigative": {
      "fields": ["riasecScores.investigative"],
      "required": ["riasecScores.investigative"],
      "uiOnly": false
    },
    "riasecArtistic": {
      "fields": ["riasecScores.artistic"],
      "required": ["riasecScores.artistic"],
      "uiOnly": false
    },
    "riasecSocial": {
      "fields": ["riasecScores.social"],
      "required": ["riasecScores.social"],
      "uiOnly": false
    },
    "riasecEnterprising": {
      "fields": ["riasecScores.enterprising"],
      "required": ["riasecScores.enterprising"],
      "uiOnly": false
    },
    "riasecConventional": {
      "fields": ["riasecScores.conventional"],
      "required": ["riasecScores.conventional"],
      "uiOnly": false
    },
    "favoriteSubjects": {
      "fields": ["favoriteSubjects"],
      "required": ["favoriteSubjects"],
      "uiOnly": false,
      "validation": {
        "minCount": 1
      }
    },
    "extracurriculars": {
      "fields": ["extracurriculars"],
      "required": ["extracurriculars"],
      "uiOnly": false,
      "validation": {
        "minCount": 1
      }
    },
    "careerInterests": {
      "fields": ["careerInterests"],
      "required": ["careerInterests"],
      "uiOnly": false,
      "validation": {
        "minCount": 0
      }
    },
    "loadingScreen": {
      "fields": [],
      "required": [],
      "uiOnly": true
    },
    "completionScreen": {
      "fields": [],
      "required": [],
      "uiOnly": true
    }
  }
}
```

### StepFieldSpec.swift Implementation

```swift
import Foundation

struct StepFieldSpec: Decodable {
    let order: [String]
    let steps: [String: StepSpec]
    
    func validate() -> Bool {
        // Ensure order matches steps
        guard order.count == steps.count else { return false }
        
        // Ensure all ordered steps exist in the steps dictionary
        for stepID in order {
            guard steps[stepID] != nil else { return false }
        }
        
        // Validate each step's spec
        for (_, stepSpec) in steps {
            // Ensure all required fields are in the fields array
            for requiredField in stepSpec.required {
                guard stepSpec.fields.contains(requiredField) else { return false }
            }
        }
        
        return true
    }
}

struct StepSpec: Decodable {
    let fields: [String]
    let required: [String]
    let uiOnly: Bool
    let validation: ValidationRules?
    let conditional: ConditionalDisplay?
    
    struct ValidationRules: Decodable {
        let minCount: Int?
        let maxCount: Int?
    }
    
    struct ConditionalDisplay: Decodable {
        let dependsOn: String
        let showWhen: String
    }
}

enum OnboardingField: String, CaseIterable {
    case referralSource
    case name
    case currentStatus
    case studentLevel
    case interests
    case riasecScoresRealistic = "riasecScores.realistic"
    case riasecScoresInvestigative = "riasecScores.investigative"
    case riasecScoresArtistic = "riasecScores.artistic"
    case riasecScoresSocial = "riasecScores.social"
    case riasecScoresEnterprising = "riasecScores.enterprising"
    case riasecScoresConventional = "riasecScores.conventional"
    case favoriteSubjects
    case extracurriculars
    case careerInterests
}
```

## 2. OnboardingStore Implementation (Story FE-1.2)

### Implementation Plan

1. Create the StepCompletion model:
   - File path: `/carrer/Core/Models/StepCompletion.swift`
   - Define model that holds all user input data
   - Implement Codable for persistence

2. Create the OnboardingStore:
   - File path: `/carrer/Core/Stores/OnboardingStore.swift`
   - Implement observable store with validation and persistence
   - Add methods for updating fields and checking completion

3. Create unit tests:
   - File path: `/carrer/Tests/OnboardingStoreTests.swift`
   - Test persistence
   - Test validation
   - Test step completion logic

### StepCompletion.swift Implementation

```swift
import Foundation

struct StepCompletion: Codable, Equatable {
    var referralSource: SelectionOption?
    var name: String?
    var currentStatus: SelectionOption?
    var studentLevel: SelectionOption?
    var interests: Set<InterestOption>?
    var riasecScores: [RIASECDimension: Float]?
    var favoriteSubjects: [Subject]?
    var extracurriculars: [Activity]?
    var careerInterests: [String]?
    var profileCompletion: Float = 0.0
    
    enum CodingKeys: String, CodingKey {
        case referralSource
        case name
        case currentStatus
        case studentLevel
        case interests
        case riasecScores
        case favoriteSubjects
        case extracurriculars
        case careerInterests
        case profileCompletion
    }
}
```

### OnboardingStore.swift Implementation

```swift
import SwiftUI
import Combine

@MainActor
class OnboardingStore: ObservableObject {
    private let stepFieldSpec: StepFieldSpec
    
    @Published var completion: StepCompletion
    @Published var currentStepIndex: Int = 0
    @AppStorage("stepCompletion") private var storedCompletion: Data = Data()
    
    var currentStep: OnboardingStep {
        let stepID = stepFieldSpec.order[currentStepIndex]
        return OnboardingStep.fromString(stepID)
    }
    
    init() {
        // Load step field specification
        guard let url = Bundle.main.url(forResource: "StepFieldSpec", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let spec = try? JSONDecoder().decode(StepFieldSpec.self, from: data) else {
            fatalError("Failed to load StepFieldSpec.json")
        }
        
        self.stepFieldSpec = spec
        
        // Load saved completion data or create new
        if let savedCompletion = try? JSONDecoder().decode(StepCompletion.self, from: storedCompletion) {
            self.completion = savedCompletion
        } else {
            self.completion = StepCompletion()
        }
        
        // Find the current step index based on completion
        self.currentStepIndex = self.calculateCurrentStepIndex()
    }
    
    private func calculateCurrentStepIndex() -> Int {
        for (index, stepID) in stepFieldSpec.order.enumerated() {
            if !isStepComplete(OnboardingStep.fromString(stepID)) {
                return index
            }
        }
        // If all steps are complete, return the last step
        return stepFieldSpec.order.count - 1
    }
    
    func update(_ field: OnboardingField, value: AnyHashable) -> Bool {
        // Validate the value
        guard validate(field, value: value) else {
            return false
        }
        
        // Update the field based on its type
        switch field {
        case .referralSource:
            if let option = value as? SelectionOption {
                completion.referralSource = option
            }
        case .name:
            if let name = value as? String {
                completion.name = name
            }
        case .currentStatus:
            if let status = value as? SelectionOption {
                completion.currentStatus = status
            }
        case .studentLevel:
            if let level = value as? SelectionOption {
                completion.studentLevel = level
            }
        case .interests:
            if let interests = value as? Set<InterestOption> {
                completion.interests = interests
            }
        case .riasecScoresRealistic, .riasecScoresInvestigative, .riasecScoresArtistic,
             .riasecScoresSocial, .riasecScoresEnterprising, .riasecScoresConventional:
            if let score = value as? Float, let dimension = field.toDimension() {
                if completion.riasecScores == nil {
                    completion.riasecScores = [:]
                }
                completion.riasecScores?[dimension] = score
            }
        case .favoriteSubjects:
            if let subjects = value as? [Subject] {
                completion.favoriteSubjects = subjects
            }
        case .extracurriculars:
            if let activities = value as? [Activity] {
                completion.extracurriculars = activities
            }
        case .careerInterests:
            if let interests = value as? [String] {
                completion.careerInterests = interests
            }
        }
        
        // Persist the changes
        saveCompletion()
        
        // Update profile completion percentage
        updateProfileCompletion()
        
        return true
    }
    
    func isStepComplete(_ step: OnboardingStep) -> Bool {
        let stepID = step.toStepID()
        guard let stepSpec = stepFieldSpec.steps[stepID] else {
            return false
        }
        
        // UI-only steps are always considered complete
        if stepSpec.uiOnly {
            return true
        }
        
        // Check conditional display
        if let conditional = stepSpec.conditional {
            let dependsOnField = OnboardingField(rawValue: conditional.dependsOn)
            
            if let currentStatus = completion.currentStatus, 
               dependsOnField == .currentStatus && 
               currentStatus.id != "student" && 
               conditional.showWhen == "student" {
                // Skip this step if it depends on being a student and user is not a student
                return true
            }
        }
        
        // Check if all required fields are filled
        for requiredField in stepSpec.required {
            let field = OnboardingField(rawValue: requiredField) ?? .name // Default to name as fallback
            
            switch field {
            case .referralSource:
                if completion.referralSource == nil { return false }
            case .name:
                if completion.name == nil || completion.name?.isEmpty == true { return false }
            case .currentStatus:
                if completion.currentStatus == nil { return false }
            case .studentLevel:
                // Only required for students
                if completion.currentStatus?.id == "student" && completion.studentLevel == nil { return false }
            case .interests:
                if completion.interests == nil || completion.interests?.isEmpty == true { return false }
            case .riasecScoresRealistic, .riasecScoresInvestigative, .riasecScoresArtistic,
                 .riasecScoresSocial, .riasecScoresEnterprising, .riasecScoresConventional:
                if completion.riasecScores == nil || completion.riasecScores?[field.toDimension() ?? .realistic] == nil { return false }
            case .favoriteSubjects:
                if completion.favoriteSubjects == nil || completion.favoriteSubjects?.isEmpty == true { return false }
            case .extracurriculars:
                if completion.extracurriculars == nil || completion.extracurriculars?.isEmpty == true { return false }
            case .careerInterests:
                // Career interests might be optional
                break
            }
        }
        
        return true
    }
    
    func advanceIfNeeded() {
        if isStepComplete(currentStep) && currentStepIndex < stepFieldSpec.order.count - 1 {
            currentStepIndex += 1
        }
    }
    
    private func validate(_ field: OnboardingField, value: AnyHashable) -> Bool {
        // Basic validation
        switch field {
        case .name:
            guard let name = value as? String else { return false }
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && name.count <= 50
            
        case .interests:
            guard let interests = value as? Set<InterestOption> else { return false }
            // Find the step spec for interests
            if let interestsSpec = stepFieldSpec.steps["interests"],
               let validation = interestsSpec.validation {
                if let minCount = validation.minCount, interests.count < minCount { return false }
                if let maxCount = validation.maxCount, interests.count > maxCount { return false }
            }
            return true
            
        case .riasecScoresRealistic, .riasecScoresInvestigative, .riasecScoresArtistic,
             .riasecScoresSocial, .riasecScoresEnterprising, .riasecScoresConventional:
            guard let score = value as? Float else { return false }
            return score >= 0 && score <= 5
            
        default:
            // Basic type checking for other fields
            return true
        }
    }
    
    private func saveCompletion() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(completion)
            storedCompletion = data
        } catch {
            print("Error saving completion: \(error)")
        }
    }
    
    private func updateProfileCompletion() {
        var completedSteps = 0
        var totalRequiredSteps = 0
        
        for stepID in stepFieldSpec.order {
            if let spec = stepFieldSpec.steps[stepID], !spec.uiOnly && !spec.required.isEmpty {
                totalRequiredSteps += 1
                
                if isStepComplete(OnboardingStep.fromString(stepID)) {
                    completedSteps += 1
                }
            }
        }
        
        completion.profileCompletion = totalRequiredSteps > 0 ? Float(completedSteps) / Float(totalRequiredSteps) : 0
    }
}

// Helper extensions
extension OnboardingStep {
    func toStepID() -> String {
        switch self {
        case .howDidYouHearAboutUs: return "howDidYouHearAboutUs"
        case .getName: return "getName"
        case .welcomeMessage: return "welcomeMessage"
        case .currentStatus: return "currentStatus"
        case .studentLevel: return "studentLevel"
        case .motivationalMessage: return "motivationalMessage"
        case .interests: return "interests"
        case .riasecQuestions(let dimension):
            switch dimension {
            case .realistic: return "riasecRealistic"
            case .investigative: return "riasecInvestigative"
            case .artistic: return "riasecArtistic"
            case .social: return "riasecSocial"
            case .enterprising: return "riasecEnterprising"
            case .conventional: return "riasecConventional"
            }
        case .favoriteSubjects: return "favoriteSubjects"
        case .extracurriculars: return "extracurriculars"
        case .careerInterests: return "careerInterests"
        case .loadingScreen: return "loadingScreen"
        case .completionScreen: return "completionScreen"
        }
    }
    
    static func fromString(_ stepID: String) -> OnboardingStep {
        switch stepID {
        case "howDidYouHearAboutUs": return .howDidYouHearAboutUs
        case "getName": return .getName
        case "welcomeMessage": return .welcomeMessage(name: "")  // Default empty name
        case "currentStatus": return .currentStatus
        case "studentLevel": return .studentLevel
        case "motivationalMessage": return .motivationalMessage
        case "interests": return .interests
        case "riasecRealistic": return .riasecQuestions(dimension: .realistic)
        case "riasecInvestigative": return .riasecQuestions(dimension: .investigative)
        case "riasecArtistic": return .riasecQuestions(dimension: .artistic)
        case "riasecSocial": return .riasecQuestions(dimension: .social)
        case "riasecEnterprising": return .riasecQuestions(dimension: .enterprising)
        case "riasecConventional": return .riasecQuestions(dimension: .conventional)
        case "favoriteSubjects": return .favoriteSubjects
        case "extracurriculars": return .extracurriculars
        case "careerInterests": return .careerInterests
        case "loadingScreen": return .loadingScreen
        case "completionScreen": return .completionScreen
        default: return .howDidYouHearAboutUs  // Default to first step
        }
    }
}

extension OnboardingField {
    func toDimension() -> RIASECDimension? {
        switch self {
        case .riasecScoresRealistic: return .realistic
        case .riasecScoresInvestigative: return .investigative
        case .riasecScoresArtistic: return .artistic
        case .riasecScoresSocial: return .social
        case .riasecScoresEnterprising: return .enterprising
        case .riasecScoresConventional: return .conventional
        default: return nil
        }
    }
}
```

## 3. Refactor Views to the Store (Story FE-1.3)

### Implementation Plan

1. Update the app entry point:
   - File path: `/carrer/New/mypath-app-swift.swift`
   - Add the OnboardingStore as an environment object

2. Create a router view:
   - File path: `/carrer/New/onboarding-router.swift`
   - Dynamically show views based on the current step in the store

3. Refactor each onboarding view:
   - Replace local state with environment object references
   - Convert direct writes to store updates
   - Update navigation to use the store's advancement logic

### MyPathApp.swift Update

```swift
import SwiftUI

@main
struct MyPathApp: App {
    @StateObject private var store = OnboardingStore()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
```

### OnboardingRouter.swift Implementation

```swift
import SwiftUI

struct OnboardingRouter: View {
    @EnvironmentObject var store: OnboardingStore
    
    var body: some View {
        switch store.currentStep {
        case .howDidYouHearAboutUs:
            HowDidYouHearView()
        
        case .getName:
            GetNameView()
            
        case .welcomeMessage(let name):
            WelcomeMessageView(name: name.isEmpty ? store.completion.name ?? "" : name)
            
        case .currentStatus:
            CurrentStatusView()
            
        case .studentLevel:
            StudentLevelView()
            
        case .motivationalMessage:
            MotivationalMessageView()
            
        case .interests:
            InterestProfileView()
            
        case .riasecQuestions(let dimension):
            RIASECQuestionsView(dimension: dimension)
            
        case .favoriteSubjects:
            FavoriteSubjectsView()
            
        case .extracurriculars:
            ExtracurricularsView()
            
        case .careerInterests:
            CareerInterestsView()
            
        case .loadingScreen:
            LoadingScreenView()
            
        case .completionScreen:
            CompletionScreenView()
        }
    }
}
```

### Example of a Refactored View

```swift
import SwiftUI

struct HowDidYouHearView: View {
    @EnvironmentObject var store: OnboardingStore
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How did you hear about us?")
                .font(.title)
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(SelectionOption.howDidYouHearOptions) { option in
                        SelectionCard(
                            option: option,
                            isSelected: Binding(
                                get: { store.completion.referralSource?.id == option.id },
                                set: { isSelected in
                                    if isSelected {
                                        store.update(.referralSource, value: option)
                                    }
                                }
                            )
                        )
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                store.advanceIfNeeded()
            }) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(store.isStepComplete(.howDidYouHearAboutUs) ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!store.isStepComplete(.howDidYouHearAboutUs))
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

struct SelectionCard: View {
    let option: SelectionOption
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: {
            isSelected = true
        }) {
            HStack {
                Image(systemName: option.iconName)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading) {
                    Text(option.title)
                        .font(.headline)
                    
                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}
```

## 4. Quality Checks (Story QA-1.1)

### Implementation Plan

1. Create UI tests:
   - File path: `/carrer/UITests/OnboardingFlowUITests.swift`
   - Test the complete onboarding flow
   - Verify all steps can be completed

2. Ensure code coverage:
   - Add tests for edge cases in the store
   - Add tests for the StepFieldSpec validation

### OnboardingFlowUITests.swift Implementation

```swift
import XCTest

class OnboardingFlowUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Clear user defaults to ensure a fresh start
        app.launchArguments = ["--uitesting", "--reset-userdefaults"]
        app.launch()
    }
    
    func testCompleteOnboardingFlow() {
        // How Did You Hear About Us
        let socialMediaOption = app.buttons["Social Media"]
        XCTAssertTrue(socialMediaOption.waitForExistence(timeout: 2))
        socialMediaOption.tap()
        
        app.buttons["Next"].tap()
        
        // Name Entry
        let nameField = app.textFields["Enter your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Test User")
        
        app.buttons["Next"].tap()
        
        // Welcome Message
        XCTAssertTrue(app.staticTexts["Welcome Test User!"].waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()
        
        // Current Status
        let studentOption = app.buttons["Student"]
        XCTAssertTrue(studentOption.waitForExistence(timeout: 2))
        studentOption.tap()
        
        app.buttons["Next"].tap()
        
        // Student Level (only shown for students)
        let universityOption = app.buttons["University"]
        XCTAssertTrue(universityOption.waitForExistence(timeout: 2))
        universityOption.tap()
        
        app.buttons["Next"].tap()
        
        // Motivational Message
        XCTAssertTrue(app.buttons["Continue"].waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()
        
        // Interests
        let techInterest = app.buttons["Learning How Things Work"]
        XCTAssertTrue(techInterest.waitForExistence(timeout: 2))
        techInterest.tap()
        
        app.buttons["Next"].tap()
        
        // Complete RIASEC questions (6 dimensions)
        for _ in 1...6 {
            // Find the highest option in the Likert scale and tap it
            app.buttons["Strongly Agree"].tap()
            app.buttons["Next"].tap()
        }
        
        // Favorite Subjects
        let mathSubject = app.buttons["Mathematics"]
        XCTAssertTrue(mathSubject.waitForExistence(timeout: 2))
        mathSubject.tap()
        
        app.buttons["Next"].tap()
        
        // Extracurricular Activities
        let sportsActivity = app.buttons["Sports"]
        XCTAssertTrue(sportsActivity.waitForExistence(timeout: 2))
        sportsActivity.tap()
        
        app.buttons["Next"].tap()
        
        // Career Interests
        let techCareer = app.buttons["Technology"]
        XCTAssertTrue(techCareer.waitForExistence(timeout: 2))
        techCareer.tap()
        
        app.buttons["Next"].tap()
        
        // Loading Screen should appear briefly
        XCTAssertTrue(app.activityIndicators.firstMatch.waitForExistence(timeout: 2))
        
        // Completion Screen
        XCTAssertTrue(app.staticTexts["Profile Complete!"].waitForExistence(timeout: 5))
        
        // Verify the Get Started button is present to move to the dashboard
        XCTAssertTrue(app.buttons["Get Started"].exists)
    }
}
```

## 5. Definition of Done Checklist

| Checklist | Owner | Status |
|-----------|-------|--------|
| StepFieldSpec.json committed, parsed, tests green | FE | ⬜ |
| OnboardingStore compiles, unit tests green | FE | ⬜ |
| All onboarding screens run via Store; no direct @State for answers | FE | ⬜ |
| UI smoke test passes on iPhone SE (iOS 17) & iPhone 15 Pro (iOS 18) | QA | ⬜ |
| TestFlight build 1.0.0-alpha1 uploaded and approved | PM | ⬜ |
| Sprint retro note: performance baseline (cold launch, memory) captured | Dev-Ops | ⬜ |

## Implementation Notes

### Schema Drift Prevention
- Any changes to the StepFieldSpec.json file must be reflected in the StepFieldSpec model and tests
- Unit tests should verify the schema is valid and complete
- Consider adding a build phase that validates the JSON schema against a schema definition

### Avoiding Duplicate Writes
- When refactoring views, watch for places where both onChange and button actions write the same field
- Use a single source of truth for each field
- Consider adding a debounce mechanism for text fields that update frequently

### Accessibility Considerations
- Test with VoiceOver enabled to ensure bindings work correctly with accessibility features
- Ensure all UI elements have proper accessibility labels
- Add proper focus navigation for screen readers

### Incremental Merge Strategy
- Break the refactor into logical chunks (spec, store, view groups)
- Create feature branches for each chunk
- Only merge to main when all related views compile and function correctly
- Use comprehensive PR descriptions to document the changes and testing performed

## Timeline

| Task | Duration | Dependencies |
|------|----------|--------------|
| Pre-work: Inventory & Gap Check | 1 day | None |
| StepFieldSpec Definition | 2 days | Pre-work |
| OnboardingStore Implementation | 3 days | StepFieldSpec |
| Refactor First View Group (Basic Info) | 2 days | OnboardingStore |
| Refactor Second View Group (Interests & RIASEC) | 2 days | OnboardingStore |
| Refactor Third View Group (Final Screens) | 2 days | OnboardingStore |
| Quality Checks | 2 days | All Refactors |
| Bug Fixes and Final Polish | 1 day | Quality Checks |

Total Sprint Duration: 15 days (3 weeks)