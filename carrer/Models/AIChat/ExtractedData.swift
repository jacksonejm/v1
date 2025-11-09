import Foundation

/// Represents data extracted from user messages
struct ExtractedData: Equatable {
    let field: OnboardingField
    let value: Any
    let confidence: Float
    let rawText: String
    
    static func == (lhs: ExtractedData, rhs: ExtractedData) -> Bool {
        // Compare all properties except 'value' which is Any type
        lhs.field == rhs.field &&
        lhs.confidence == rhs.confidence &&
        lhs.rawText == rhs.rawText &&
        // For 'value', we need to handle comparison based on actual type
        areValuesEqual(lhs.value, rhs.value)
    }
    
    private static func areValuesEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        // Handle common types that might be stored in value
        if let lhsString = lhs as? String, let rhsString = rhs as? String {
            return lhsString == rhsString
        } else if let lhsInt = lhs as? Int, let rhsInt = rhs as? Int {
            return lhsInt == rhsInt
        } else if let lhsBool = lhs as? Bool, let rhsBool = rhs as? Bool {
            return lhsBool == rhsBool
        } else if let lhsArray = lhs as? [String], let rhsArray = rhs as? [String] {
            return lhsArray == rhsArray
        } else if let lhsDict = lhs as? [String: Any], let rhsDict = rhs as? [String: Any] {
            // For dictionaries, compare keys and recursively compare values
            guard lhsDict.keys.count == rhsDict.keys.count else { return false }
            for key in lhsDict.keys {
                guard let lhsValue = lhsDict[key],
                      let rhsValue = rhsDict[key],
                      areValuesEqual(lhsValue, rhsValue) else {
                    return false
                }
            }
            return true
        }
        // If we can't determine the type, consider them not equal
        return false
    }
    
    /// Whether this extraction has high confidence
    var isHighConfidence: Bool {
        confidence >= 0.8
    }
    
    /// Convert to dictionary for storage
    func toDictionary() -> [String: Any] {
        return [
            "field": field.rawValue,
            "value": value,
            "confidence": confidence,
            "rawText": rawText
        ]
    }
    
    /// Create a confirmation message for this extracted data
    func confirmationMessage() -> String {
        switch field {
        case .name:
            if let name = value as? String {
                return "I understood your name is \(name). Is that correct?"
            }
        case .currentStatus:
            if let status = value as? String {
                return "So you're currently \(status). Did I get that right?"
            }
        case .interests:
            if let interests = value as? [String] {
                let interestList = interests.joined(separator: ", ")
                return "I heard you're interested in \(interestList). Is that accurate?"
            }
        default:
            return "Just to confirm, you said '\(rawText)'. Is that correct?"
        }
        return "Is '\(rawText)' correct?"
    }
}

/// Collection of extracted data from a conversation
struct ExtractedDataCollection {
    private var items: [ExtractedData] = []
    
    mutating func add(_ data: ExtractedData) {
        items.append(data)
    }
    
    func get(for field: OnboardingField) -> ExtractedData? {
        items.first { $0.field == field }
    }
    
    var all: [ExtractedData] {
        items
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    var needsConfirmation: Bool {
        items.contains { !$0.isHighConfidence }
    }
}