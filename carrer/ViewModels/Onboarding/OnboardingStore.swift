import Foundation
import Combine
import SwiftUI

/// OnboardingStore serves as the single source of truth for all onboarding state
@MainActor
class OnboardingStore: ObservableObject {
    // MARK: - Published Properties
    
    /// Current onboarding step
    @Published private(set) var currentStep: OnboardingStep
    
    /// All field values
    @Published private(set) var values: [OnboardingField: AnyHashable] = [:]
    
    /// Flag to indicate an error state
    @Published var error: Error?
    
    /// Flag to indicate loading state
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    /// Step field specification loaded from JSON
    private let spec: StepFieldSpec?
    
    /// Change tracking for any updates made by the AI assistant
    private var changeHistory: [ChangeRecord] = []
    
    /// User defaults storage key
    private let storageKey = "onboarding_store_data"
    
    /// Cancellables for publishers
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(initialStep: OnboardingStep = .howDidYouHearAboutUs) {
        self.currentStep = initialStep
        self.spec = StepFieldSpec.load()
        
        // Attempt to restore from saved state
        loadSavedState()
        
        // Setup auto-save when values change
        setupAutoSave()
    }
    
    // MARK: - Public Methods
    
    /// Update a field value with validation
    @MainActor
    func update(field: OnboardingField, value: Any, source: UpdateSource = .user) {
        // Record previous value for change tracking
        let previousValue = values[field]
        
        // Perform validation
        guard validateField(field: field, value: value) else {
            // Handle validation failure
            self.error = ValidationError.invalidValue(field: field.rawValue)
            return
        }
        
        // Save the old and new value for change tracking
        let changeRecord = ChangeRecord(
            field: field,
            oldValue: previousValue,
            newValue: value as? AnyHashable ?? "Unable to convert to AnyHashable" as AnyHashable,
            source: source,
            timestamp: Date()
        )
        
        // Add to change history
        changeHistory.append(changeRecord)
        
        // Set the new value
        values[field] = value as? AnyHashable
        
        // Save state
        saveState()
        
        // Check if this completes the step and we should advance
        if isStepComplete(currentStep) && source == .user {
            // Only auto-advance if it was updated by the user directly
            Task {
                await advanceIfNeeded()
            }
        }
    }
    
    /// Check if the current step is complete
    func isStepComplete(_ step: OnboardingStep) -> Bool {
        // Get the step key
        let stepKey = getStepKey(for: step)
        
        // Get required fields for this step
        guard let requiredFields = spec?.steps[stepKey]?.required else {
            return true // If we can't determine requirements, assume complete
        }
        
        // Check if all required fields have values
        for fieldName in requiredFields {
            guard let field = OnboardingField(rawValue: fieldName) else {
                continue
            }
            
            // Special handling for RIASEC questions
            if field.rawValue.starts(with: "riasecResponses_") {
                if let dimension = field.riasecDimension {
                    let riasecData = values[field] as? [String: Int]
                    if riasecData == nil || riasecData?.isEmpty == true {
                        return false
                    }
                }
                continue
            }
            
            // For other fields, just check if they exist
            if values[field] == nil {
                return false
            }
            
            // Special validation for counts
            if let fieldSpec = spec?.fields[fieldName] {
                if let minCount = fieldSpec.minCount {
                    if let array = values[field] as? Array<Any>, array.count < minCount {
                        return false
                    }
                    if let set = values[field] as? Set<AnyHashable>, set.count < minCount {
                        return false
                    }
                }
                
                if let exactCount = fieldSpec.validation?.count {
                    if let array = values[field] as? Array<Any>, array.count != exactCount {
                        return false
                    }
                    if let set = values[field] as? Set<AnyHashable>, set.count != exactCount {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    /// Advance to the next step automatically if current step is complete
    @MainActor
    func advanceIfNeeded() async {
        if isStepComplete(currentStep) {
            await advanceToNextStep()
        }
    }
    
    /// Advance to the next step
    @MainActor
    func advanceToNextStep() async {
        let nextStep = getNextStep(after: currentStep)
        currentStep = nextStep
        saveState()
    }
    
    /// Go back to the previous step
    @MainActor
    func goToPreviousStep() {
        let previousStep = getPreviousStep(before: currentStep)
        currentStep = previousStep
        saveState()
    }
    
    /// Reset the onboarding process
    @MainActor
    func reset() {
        values = [:]
        currentStep = .howDidYouHearAboutUs
        changeHistory = []
        saveState()
    }
    
    /// Get a value for a specific field
    func value<T>(for field: OnboardingField) -> T? {
        return values[field] as? T
    }
    
    /// Get a binding for a field
    func binding<T>(for field: OnboardingField) -> Binding<T?> {
        return Binding<T?>(
            get: { self.values[field] as? T },
            set: { newValue in
                if let value = newValue {
                    Task { @MainActor in
                        self.update(field: field, value: value)
                    }
                } else {
                    // Handle nil value - either clear it or do nothing
                    Task { @MainActor in
                        self.values[field] = nil
                        self.saveState()
                    }
                }
            }
        )
    }
    
    /// Get a typed binding with a default value
    func binding<T>(for field: OnboardingField, default defaultValue: T) -> Binding<T> {
        return Binding<T>(
            get: { self.values[field] as? T ?? defaultValue },
            set: { newValue in
                Task { @MainActor in
                    self.update(field: field, value: newValue)
                }
            }
        )
    }
    
    // MARK: - AI Assistant Methods
    
    /// Add a pending value from AI that will be applied once confirmed
    @MainActor
    func aiWrite(field: OnboardingField, value: Any, confidence: Float) {
        // Apply the value if confidence is high enough or defer for confirmation
        if confidence >= 0.9 {
            update(field: field, value: value, source: .ai)
        } else {
            // For lower confidence, we would handle pending confirmation
            // This will be implemented in Sprint 2
            print("AI suggested value \(value) for field \(field) with confidence \(confidence)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Validate a field value
    private func validateField(field: OnboardingField, value: Any) -> Bool {
        // Get field specification
        guard let fieldSpec = spec?.fields[field.rawValue] else {
            return true // If no spec, assume valid
        }
        
        // Type validation
        switch fieldSpec.type {
        case .string:
            guard let stringValue = value as? String else { return false }
            
            // Check length constraints
            if let minLength = fieldSpec.minLength, stringValue.count < minLength { return false }
            if let maxLength = fieldSpec.maxLength, stringValue.count > maxLength { return false }
            
            // Check regex if specified
            if let regex = fieldSpec.validation?.regex {
                guard stringValue.range(of: regex, options: .regularExpression) != nil else {
                    return false
                }
            }
            
        case .selection:
            // For selection, the value should be a string from options
            if let stringValue = value as? String {
                if let options = fieldSpec.options {
                    // If the value is not one of the defined options, it's only valid if allowsCustom is true
                    if !options.contains(stringValue) && !(fieldSpec.allowsCustom == true) {
                        return false
                    }
                }
            } else if let selectionOption = value as? SelectionOption {
                // If using SelectionOption, ensure it's valid
                if let options = fieldSpec.options, !options.contains(selectionOption.title) && !(fieldSpec.allowsCustom == true) {
                    return false
                }
            } else {
                return false // Not a valid type for selection
            }
            
        case .multiSelection:
            // For multiSelection, value should be an array or set of valid options
            var count = 0
            var allValid = true
            
            if let arrayValue = value as? [String] {
                count = arrayValue.count
                if let options = fieldSpec.options {
                    for item in arrayValue {
                        if !options.contains(item) && !(fieldSpec.allowsCustom == true) {
                            allValid = false
                            break
                        }
                    }
                }
            } else if let setStringValue = value as? Set<String> {
                count = setStringValue.count
                if let options = fieldSpec.options {
                    for item in setStringValue {
                        if !options.contains(item) && !(fieldSpec.allowsCustom == true) {
                            allValid = false
                            break
                        }
                    }
                }
            } else if let setOptionsValue = value as? Set<SelectionOption> {
                count = setOptionsValue.count
                if let options = fieldSpec.options {
                    for item in setOptionsValue {
                        if !options.contains(item.title) && !(fieldSpec.allowsCustom == true) {
                            allValid = false
                            break
                        }
                    }
                }
            } else if let setActivity = value as? Set<Activity> {
                count = setActivity.count
                // For these custom types, we trust that they're valid since they come from the app
            } else if let setSchoolSubject = value as? Set<SchoolSubject> {
                count = setSchoolSubject.count
                // For these custom types, we trust that they're valid since they come from the app
            } else if let setCareer = value as? Set<Career> {
                count = setCareer.count
                // For these custom types, we trust that they're valid since they come from the app
            } else if let setInterestOption = value as? Set<InterestOption> {
                count = setInterestOption.count
                // For these custom types, we trust that they're valid since they come from the app
            } else {
                return false // Not a valid type for multiSelection
            }
            
            // Check count constraints
            if let minCount = fieldSpec.minCount, count < minCount { return false }
            if let maxCount = fieldSpec.maxCount, count > maxCount { return false }
            if let validation = fieldSpec.validation, let exactCount = validation.count, count != exactCount { return false }
            
            return allValid
            
        case .ratings:
            // For ratings, value should be a dictionary of question to rating
            if let ratingsDict = value as? [String: Int] {
                if let questions = fieldSpec.questions {
                    // Ensure all questions have a rating
                    for question in questions {
                        if ratingsDict[question] == nil {
                            return false
                        }
                    }
                    
                    // Ensure ratings are within range
                    for (_, rating) in ratingsDict {
                        if let minRating = fieldSpec.minRating, rating < minRating { return false }
                        if let maxRating = fieldSpec.maxRating, rating > maxRating { return false }
                    }
                }
            } else {
                return false // Not a valid type for ratings
            }
            
        case .number:
            // Basic number type validation
            return value is Int || value is Double || value is Float
            
        case .boolean:
            // Boolean type validation
            return value is Bool
        }
        
        return true
    }
    
    /// Set up auto-save when values change
    private func setupAutoSave() {
        $values
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveState()
            }
            .store(in: &cancellables)
    }
    
    /// Save the current state to UserDefaults
    private func saveState() {
        // Create a serializable dictionary
        var stateDict: [String: Any] = [:]
        
        // Add the current step
        stateDict["currentStep"] = getStepKey(for: currentStep)
        
        // Add values
        var valuesDict: [String: Any] = [:]
        for (field, value) in values {
            // Convert to serializable form
            if let serializableValue = makeSerializable(value) {
                valuesDict[field.rawValue] = serializableValue
            }
        }
        stateDict["values"] = valuesDict
        
        // Save to UserDefaults
        if let data = try? JSONSerialization.data(withJSONObject: stateDict) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    /// Load the saved state from UserDefaults
    private func loadSavedState() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let stateDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        // Restore the current step
        if let stepKey = stateDict["currentStep"] as? String {
            currentStep = stepFromKey(stepKey) ?? .howDidYouHearAboutUs
        }
        
        // Restore values
        if let valuesDict = stateDict["values"] as? [String: Any] {
            for (fieldKey, value) in valuesDict {
                if let field = OnboardingField(rawValue: fieldKey) {
                    values[field] = value as? AnyHashable
                }
            }
        }
    }
    
    /// Convert a value to a serializable format
    private func makeSerializable(_ value: Any) -> Any? {
        if let stringValue = value as? String {
            return stringValue
        } else if let intValue = value as? Int {
            return intValue
        } else if let doubleValue = value as? Double {
            return doubleValue
        } else if let boolValue = value as? Bool {
            return boolValue
        } else if let dictValue = value as? [String: Any] {
            return dictValue
        } else if let arrayValue = value as? [Any] {
            return arrayValue
        } else if let selectionOption = value as? SelectionOption {
            // Convert SelectionOption to dictionary
            return ["title": selectionOption.title, "iconName": selectionOption.iconName]
        } else if let setOptions = value as? Set<SelectionOption> {
            // Convert set of SelectionOption to array of dictionaries
            return setOptions.map { ["title": $0.title, "iconName": $0.iconName] }
        } else if let setStrings = value as? Set<String> {
            // Convert set of strings to array
            return Array(setStrings)
        } else if let setSubjects = value as? Set<SchoolSubject> {
            // Convert set of SchoolSubject to array of names
            return setSubjects.map { $0.name }
        } else if let setActivity = value as? Set<Activity> {
            // Convert set of Activity to array of names
            return setActivity.map { $0.name }
        } else if let setCareer = value as? Set<Career> {
            // Convert set of Career to array of names
            return setCareer.map { $0.name }
        } else if let setInterest = value as? Set<InterestOption> {
            // Convert set of InterestOption to array of names
            return setInterest.map { $0.name }
        }
        
        return nil
    }
    
    /// Get the string key for a step
    private func getStepKey(for step: OnboardingStep) -> String {
        switch step {
        case .howDidYouHearAboutUs: return "howDidYouHearAboutUs"
        case .getName: return "getName"
        case .welcomeMessage: return "welcomeMessage"
        case .currentStatus: return "currentStatus"
        case .studentLevel: return "studentLevel"
        case .motivationalMessage: return "motivationalMessage"
        case .interests: return "interests"
        case .riasecQuestions(let dimension):
            return "riasecQuestions_\(dimension.rawValue.lowercased())"
        case .favoriteSubjects: return "favoriteSubjects"
        case .extracurriculars: return "extracurriculars"
        case .careerInterests: return "careerInterests"
        case .workValues: return "workValues"
        case .loadingScreen: return "loadingScreen"
        case .completionScreen: return "completionScreen"
        }
    }
    
    /// Convert a step key to a step
    private func stepFromKey(_ key: String) -> OnboardingStep? {
        switch key {
        case "howDidYouHearAboutUs": return .howDidYouHearAboutUs
        case "getName": return .getName
        case "welcomeMessage": return .welcomeMessage(name: values[.name] as? String ?? "")
        case "currentStatus": return .currentStatus
        case "studentLevel": return .studentLevel
        case "motivationalMessage": return .motivationalMessage
        case "interests": return .interests
        case "riasecQuestions_realistic": return .riasecQuestions(dimension: .realistic)
        case "riasecQuestions_investigative": return .riasecQuestions(dimension: .investigative)
        case "riasecQuestions_artistic": return .riasecQuestions(dimension: .artistic)
        case "riasecQuestions_social": return .riasecQuestions(dimension: .social)
        case "riasecQuestions_enterprising": return .riasecQuestions(dimension: .enterprising)
        case "riasecQuestions_conventional": return .riasecQuestions(dimension: .conventional)
        case "favoriteSubjects": return .favoriteSubjects
        case "extracurriculars": return .extracurriculars
        case "careerInterests": return .careerInterests
        case "workValues": return .workValues
        case "loadingScreen": return .loadingScreen
        case "completionScreen": return .completionScreen
        default: return nil
        }
    }
    
    /// Determine the next step after the current one
    private func getNextStep(after step: OnboardingStep) -> OnboardingStep {
        let stepKey = getStepKey(for: step)
        
        // Check if there are conditional navigation rules
        if let conditionalRules = spec?.steps[stepKey]?.conditionalNavigation {
            for rule in conditionalRules {
                if let field = OnboardingField(rawValue: rule.field) {
                    // Get the current value
                    if let currentValue = values[field] as? String {
                        if let valueToMatch = rule.value, currentValue == valueToMatch {
                            // If the value matches, follow this rule
                            if let nextStep = stepFromKey(rule.nextStep) {
                                return nextStep
                            }
                        } else if let valueToNotMatch = rule.valueNot, currentValue != valueToNotMatch {
                            // If the value doesn't match the not-condition, follow this rule
                            if let nextStep = stepFromKey(rule.nextStep) {
                                return nextStep
                            }
                        }
                    } else if let selectionOption = values[field] as? SelectionOption {
                        if let valueToMatch = rule.value, selectionOption.title == valueToMatch {
                            // If the value matches, follow this rule
                            if let nextStep = stepFromKey(rule.nextStep) {
                                return nextStep
                            }
                        } else if let valueToNotMatch = rule.valueNot, selectionOption.title != valueToNotMatch {
                            // If the value doesn't match the not-condition, follow this rule
                            if let nextStep = stepFromKey(rule.nextStep) {
                                return nextStep
                            }
                        }
                    }
                }
            }
        }
        
        // If no conditional rule matched, follow the default next step
        if let nextStepKey = spec?.nextStep(after: stepKey),
           let nextStep = stepFromKey(nextStepKey) {
            return nextStep
        }
        
        // Default navigation if spec doesn't provide a next step
        switch step {
        case .howDidYouHearAboutUs:
            return .getName
        case .getName:
            let name = values[.name] as? String ?? ""
            return .welcomeMessage(name: name)
        case .welcomeMessage:
            return .currentStatus
        case .currentStatus:
            if let status = values[.currentStatus] as? SelectionOption,
               status.title == "Student" {
                return .studentLevel
            } else {
                return .interests
            }
        case .studentLevel:
            return .motivationalMessage
        case .motivationalMessage:
            return .interests
        case .interests:
            return .riasecQuestions(dimension: .realistic)
        case .riasecQuestions(let dimension):
            if let nextDimension = getNextRIASECDimension(after: dimension) {
                return .riasecQuestions(dimension: nextDimension)
            } else {
                return .favoriteSubjects
            }
        case .favoriteSubjects:
            return .extracurriculars
        case .extracurriculars:
            return .careerInterests
        case .careerInterests:
            return .workValues
        case .workValues:
            return .loadingScreen
        case .loadingScreen:
            return .completionScreen
        case .completionScreen:
            return .completionScreen // Stay at completion
        }
    }
    
    /// Determine the previous step before the current one
    private func getPreviousStep(before step: OnboardingStep) -> OnboardingStep {
        switch step {
        case .howDidYouHearAboutUs:
            return .howDidYouHearAboutUs // Stay at first step
        case .getName:
            return .howDidYouHearAboutUs
        case .welcomeMessage:
            return .getName
        case .currentStatus:
            let name = values[.name] as? String ?? ""
            return .welcomeMessage(name: name)
        case .studentLevel:
            return .currentStatus
        case .motivationalMessage:
            return .studentLevel
        case .interests:
            // Check if we came from motivationalMessage or directly from currentStatus
            if let status = values[.currentStatus] as? SelectionOption,
               status.title == "Student" {
                return .motivationalMessage
            } else {
                return .currentStatus
            }
        case .riasecQuestions(let dimension):
            if dimension == .realistic {
                return .interests
            } else {
                let prevDimension = getPreviousRIASECDimension(before: dimension)
                return .riasecQuestions(dimension: prevDimension)
            }
        case .favoriteSubjects:
            return .riasecQuestions(dimension: .conventional)
        case .extracurriculars:
            return .favoriteSubjects
        case .careerInterests:
            return .extracurriculars
        case .workValues:
            return .careerInterests
        case .loadingScreen:
            return .workValues
        case .completionScreen:
            return .loadingScreen
        }
    }
    
    /// Get the next RIASEC dimension
    private func getNextRIASECDimension(after current: RIASECDimension) -> RIASECDimension? {
        let allDimensions = RIASECDimension.allCases
        guard let currentIndex = allDimensions.firstIndex(of: current),
              currentIndex < allDimensions.count - 1 else {
            return nil
        }
        return allDimensions[currentIndex + 1]
    }
    
    /// Get the previous RIASEC dimension
    private func getPreviousRIASECDimension(before current: RIASECDimension) -> RIASECDimension {
        let allDimensions = RIASECDimension.allCases
        guard let currentIndex = allDimensions.firstIndex(of: current),
              currentIndex > 0 else {
            return .realistic // Default to first if can't find previous
        }
        return allDimensions[currentIndex - 1]
    }
}

// MARK: - Supporting Types

/// Record of changes made to the store
struct ChangeRecord {
    let field: OnboardingField
    let oldValue: AnyHashable?
    let newValue: AnyHashable
    let source: UpdateSource
    let timestamp: Date
}

/// Source of an update to the store
enum UpdateSource {
    case user
    case ai
    case system
}

/// Errors that can occur during validation
enum ValidationError: Error {
    case invalidValue(field: String)
    case missingField(field: String)
    case invalidType(field: String, expected: String)
}
