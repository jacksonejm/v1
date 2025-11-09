import Foundation

/// Defines the specification for all onboarding steps, fields, and validation rules
struct StepFieldSpec: Codable {
    let version: String
    let order: [String]
    let steps: [String: StepSpec]
    let fields: [String: FieldSpec]
    
    /// Load from bundle resource
    static func load() -> StepFieldSpec? {
        guard let url = Bundle.main.url(forResource: "StepFieldSpec", withExtension: "json") else {
            print("Failed to locate StepFieldSpec.json in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(StepFieldSpec.self, from: data)
        } catch {
            print("Failed to decode StepFieldSpec.json: \(error)")
            return nil
        }
    }
    
    /// Checks if field is required for a step
    func isRequired(field: String, forStep step: String) -> Bool {
        return steps[step]?.required.contains(field) == true
    }
    
    /// Get all fields for a step
    func fields(forStep step: String) -> [String] {
        return steps[step]?.fields ?? []
    }
    
    /// Get validation for a specific field
    func validation(forField field: String) -> FieldValidation? {
        return fields[field]?.validation
    }
    
    /// Determine the next step after the current one
    func nextStep(after step: String) -> String? {
        return steps[step]?.nextStep
    }
}

/// Specification for a single onboarding step
struct StepSpec: Codable {
    let title: String
    let fields: [String]
    let required: [String]
    let nextStep: String
    let isInputStep: Bool
    let conditionalNavigation: [ConditionalNavigation]?
    let needsParameter: String?
    let needsProcessing: Bool?
    let isLastStep: Bool?
    let riasecDimension: String?
    let validation: [String: ValidationRule]?
    
    enum CodingKeys: String, CodingKey {
        case title, fields, required, nextStep, isInputStep, conditionalNavigation
        case needsParameter, needsProcessing, isLastStep, riasecDimension, validation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        fields = try container.decode([String].self, forKey: .fields)
        required = try container.decode([String].self, forKey: .required)
        nextStep = try container.decode(String.self, forKey: .nextStep)
        isInputStep = try container.decode(Bool.self, forKey: .isInputStep)
        conditionalNavigation = try container.decodeIfPresent([ConditionalNavigation].self, forKey: .conditionalNavigation)
        needsParameter = try container.decodeIfPresent(String.self, forKey: .needsParameter)
        needsProcessing = try container.decodeIfPresent(Bool.self, forKey: .needsProcessing)
        isLastStep = try container.decodeIfPresent(Bool.self, forKey: .isLastStep)
        riasecDimension = try container.decodeIfPresent(String.self, forKey: .riasecDimension)
        validation = try container.decodeIfPresent([String: ValidationRule].self, forKey: .validation)
    }
}

/// Conditional navigation rules
struct ConditionalNavigation: Codable {
    let field: String
    let value: String?
    let valueNot: String?
    let nextStep: String
    
    enum CodingKeys: String, CodingKey {
        case field, value, valueNot, nextStep
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        field = try container.decode(String.self, forKey: .field)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        valueNot = try container.decodeIfPresent(String.self, forKey: .valueNot)
        nextStep = try container.decode(String.self, forKey: .nextStep)
    }
}

/// Specification for a single field
struct FieldSpec: Codable {
    let label: String
    let type: FieldType
    let options: [String]?
    let minLength: Int?
    let maxLength: Int?
    let minCount: Int?
    let maxCount: Int?
    let allowsCustom: Bool?
    let questions: [String]?
    let minRating: Int?
    let maxRating: Int?
    let dependsOn: FieldDependency?
    let validation: FieldValidation?
    
    enum CodingKeys: String, CodingKey {
        case label, type, options, minLength, maxLength, minCount, maxCount
        case allowsCustom, questions, minRating, maxRating, dependsOn, validation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        label = try container.decode(String.self, forKey: .label)
        type = try container.decode(FieldType.self, forKey: .type)
        options = try container.decodeIfPresent([String].self, forKey: .options)
        minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
        maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        minCount = try container.decodeIfPresent(Int.self, forKey: .minCount)
        maxCount = try container.decodeIfPresent(Int.self, forKey: .maxCount)
        allowsCustom = try container.decodeIfPresent(Bool.self, forKey: .allowsCustom)
        questions = try container.decodeIfPresent([String].self, forKey: .questions)
        minRating = try container.decodeIfPresent(Int.self, forKey: .minRating)
        maxRating = try container.decodeIfPresent(Int.self, forKey: .maxRating)
        dependsOn = try container.decodeIfPresent(FieldDependency.self, forKey: .dependsOn)
        validation = try container.decodeIfPresent(FieldValidation.self, forKey: .validation)
    }
}

/// Define the type of a field
enum FieldType: String, Codable {
    case string
    case selection
    case multiSelection
    case ratings
    case number
    case boolean
}

/// Define dependencies between fields
struct FieldDependency: Codable {
    let field: String
    let includes: String?
    let equals: String?
    let notEquals: String?
    
    enum CodingKeys: String, CodingKey {
        case field, includes, equals, notEquals
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        field = try container.decode(String.self, forKey: .field)
        includes = try container.decodeIfPresent(String.self, forKey: .includes)
        equals = try container.decodeIfPresent(String.self, forKey: .equals)
        notEquals = try container.decodeIfPresent(String.self, forKey: .notEquals)
    }
}

/// Define validation rules for a field
struct FieldValidation: Codable {
    let required: Bool?
    let minLength: Int?
    let maxLength: Int?
    let minCount: Int?
    let maxCount: Int?
    let count: Int?
    let regex: String?
    let isEmail: Bool?
}

/// Validation rule for a specific field
struct ValidationRule: Codable {
    let count: Int?
    let minCount: Int?
    let maxCount: Int?
    let regex: String?
    
    enum CodingKeys: String, CodingKey {
        case count, minCount, maxCount, regex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        minCount = try container.decodeIfPresent(Int.self, forKey: .minCount)
        maxCount = try container.decodeIfPresent(Int.self, forKey: .maxCount)
        regex = try container.decodeIfPresent(String.self, forKey: .regex)
    }
}

/// Defines a field key in the onboarding process
enum OnboardingField: String, CaseIterable, Hashable {
    case howDidYouHearAboutUs
    case name
    case currentStatus
    case studentLevel
    case interests
    case riasecResponses_realistic
    case riasecResponses_investigative
    case riasecResponses_artistic
    case riasecResponses_social
    case riasecResponses_enterprising
    case riasecResponses_conventional
    case favoriteSubjects
    case extracurriculars
    case extracurricularOther
    case careerInterests
    case careerInterestsOther
    
    /// Maps a UserDataKey to an OnboardingField
    static func from(userDataKey: UserDataKey) -> OnboardingField? {
        switch userDataKey {
        case .howDidYouHearAboutUs: return .howDidYouHearAboutUs
        case .name: return .name
        case .currentStatus: return .currentStatus
        case .studentLevel: return .studentLevel
        case .interests: return .interests
        case .favoriteSubjects: return .favoriteSubjects
        case .extracurriculars: return .extracurriculars
        case .extracurricularOther: return .extracurricularOther
        case .careerInterests: return .careerInterests
        case .careerInterestsOther: return .careerInterestsOther
        case .riasecResponses:
            // This requires special handling because it's stored as a nested structure
            return nil
        default:
            return nil
        }
    }
    
    /// Maps an OnboardingField to a UserDataKey
    var userDataKey: UserDataKey {
        switch self {
        case .howDidYouHearAboutUs: return .howDidYouHearAboutUs
        case .name: return .name
        case .currentStatus: return .currentStatus
        case .studentLevel: return .studentLevel
        case .interests: return .interests
        case .favoriteSubjects: return .favoriteSubjects
        case .extracurriculars: return .extracurriculars
        case .extracurricularOther: return .extracurricularOther
        case .careerInterests: return .careerInterests
        case .careerInterestsOther: return .careerInterestsOther
        case .riasecResponses_realistic,
             .riasecResponses_investigative,
             .riasecResponses_artistic,
             .riasecResponses_social,
             .riasecResponses_enterprising,
             .riasecResponses_conventional:
            return .riasecResponses
        }
    }
    
    /// Get the RIASEC dimension for a RIASEC field
    var riasecDimension: RIASECDimension? {
        switch self {
        case .riasecResponses_realistic: return .realistic
        case .riasecResponses_investigative: return .investigative
        case .riasecResponses_artistic: return .artistic
        case .riasecResponses_social: return .social
        case .riasecResponses_enterprising: return .enterprising
        case .riasecResponses_conventional: return .conventional
        default: return nil
        }
    }
}