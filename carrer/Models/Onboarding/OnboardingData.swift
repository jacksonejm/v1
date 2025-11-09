import Foundation

/// Stores all data collected during conversational onboarding
struct OnboardingData {
    var firstName: String?
    var lastName: String?
    var referralSource: String?
    var currentStatus: String?
    var educationLevel: String?
    var interests: Set<String> = []
    var riasecResponses: [String: Int] = [:]
    var favoriteSubjects: Set<String> = []
    var extracurriculars: Set<String> = []
    var careerInterests: Set<String> = []
    
    /// Get the user's full name
    var fullName: String? {
        guard let first = firstName else { return nil }
        if let last = lastName {
            return "\(first) \(last)"
        }
        return first
    }
    
    /// Check if a specific field has been collected
    func hasData(for field: OnboardingField) -> Bool {
        switch field {
        case .name:
            return firstName != nil
        case .howDidYouHearAboutUs:
            return referralSource != nil
        case .currentStatus:
            return currentStatus != nil
        case .studentLevel:
            return educationLevel != nil
        case .interests:
            return !interests.isEmpty
        case .favoriteSubjects:
            return !favoriteSubjects.isEmpty
        case .extracurriculars:
            return !extracurriculars.isEmpty
        case .careerInterests:
            return !careerInterests.isEmpty
        case .riasecResponses_realistic,
             .riasecResponses_investigative,
             .riasecResponses_artistic,
             .riasecResponses_social,
             .riasecResponses_enterprising,
             .riasecResponses_conventional:
            return !riasecResponses.isEmpty
        default:
            return false
        }
    }
    
    /// Convert to dictionary for storage
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        if let firstName = firstName { dict["firstName"] = firstName }
        if let lastName = lastName { dict["lastName"] = lastName }
        if let referralSource = referralSource { dict["referralSource"] = referralSource }
        if let currentStatus = currentStatus { dict["currentStatus"] = currentStatus }
        if let educationLevel = educationLevel { dict["educationLevel"] = educationLevel }
        
        if !interests.isEmpty { dict["interests"] = Array(interests) }
        if !riasecResponses.isEmpty { dict["riasecResponses"] = riasecResponses }
        if !favoriteSubjects.isEmpty { dict["favoriteSubjects"] = Array(favoriteSubjects) }
        if !extracurriculars.isEmpty { dict["extracurriculars"] = Array(extracurriculars) }
        if !careerInterests.isEmpty { dict["careerInterests"] = Array(careerInterests) }
        
        return dict
    }
    
    /// Create from dictionary
    static func from(dictionary: [String: Any]) -> OnboardingData {
        var data = OnboardingData()
        
        data.firstName = dictionary["firstName"] as? String
        data.lastName = dictionary["lastName"] as? String
        data.referralSource = dictionary["referralSource"] as? String
        data.currentStatus = dictionary["currentStatus"] as? String
        data.educationLevel = dictionary["educationLevel"] as? String
        
        if let interests = dictionary["interests"] as? [String] {
            data.interests = Set(interests)
        }
        if let riasec = dictionary["riasecResponses"] as? [String: Int] {
            data.riasecResponses = riasec
        }
        if let subjects = dictionary["favoriteSubjects"] as? [String] {
            data.favoriteSubjects = Set(subjects)
        }
        if let activities = dictionary["extracurriculars"] as? [String] {
            data.extracurriculars = Set(activities)
        }
        if let careers = dictionary["careerInterests"] as? [String] {
            data.careerInterests = Set(careers)
        }
        
        return data
    }
}