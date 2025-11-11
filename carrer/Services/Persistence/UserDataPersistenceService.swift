import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Service responsible for persisting user data to Firestore
class UserDataPersistenceService {

    // MARK: - Properties

    private let db = Firestore.firestore()

    // MARK: - Public Methods

    /// Saves user data to Firestore
    func saveUserData(_ userData: [UserDataKey: AnyHashable]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            throw PersistenceError.noAuthenticatedUser
        }

        // Convert userData to dictionary for Firestore
        let userDataDict = convertToFirestoreFormat(userData)

        // Save to Firestore
        try await db.collection("users").document(userId).setData(userDataDict, merge: true)

        print("✅ User data saved successfully to Firestore")
    }

    /// Loads user data from Firestore
    func loadUserData() async throws -> [UserDataKey: AnyHashable] {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            throw PersistenceError.noAuthenticatedUser
        }

        let document = try await db.collection("users").document(userId).getDocument()

        guard document.exists, let data = document.data() else {
            print("ℹ️ No user data found in Firestore")
            return [:]
        }

        // Convert Firestore data back to userData format
        let userData = convertFromFirestoreFormat(data)

        print("✅ User data loaded successfully from Firestore")
        return userData
    }

    /// Deletes user data from Firestore
    func deleteUserData() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            throw PersistenceError.noAuthenticatedUser
        }

        try await db.collection("users").document(userId).delete()

        print("✅ User data deleted successfully from Firestore")
    }

    /// Clears specific keys from user data in Firestore
    func clearKeys(_ keys: [UserDataKey]) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            throw PersistenceError.noAuthenticatedUser
        }

        var updates: [String: Any] = [:]
        for key in keys {
            updates["\(key)"] = FieldValue.delete()
        }

        try await db.collection("users").document(userId).updateData(updates)

        print("✅ Cleared \(keys.count) keys from Firestore")
    }

    // MARK: - Private Methods

    /// Convert userData dictionary to Firestore-compatible format
    private func convertToFirestoreFormat(_ userData: [UserDataKey: AnyHashable]) -> [String: Any] {
        var userDataDict: [String: Any] = [:]

        for (key, value) in userData {
            // Handle different value types
            if let stringValue = value as? String {
                userDataDict["\(key)"] = stringValue
            } else if let intValue = value as? Int {
                userDataDict["\(key)"] = intValue
            } else if let doubleValue = value as? Double {
                userDataDict["\(key)"] = doubleValue
            } else if let floatValue = value as? Float {
                userDataDict["\(key)"] = Double(floatValue)
            } else if let boolValue = value as? Bool {
                userDataDict["\(key)"] = boolValue
            } else if let arrayValue = value as? [String] {
                userDataDict["\(key)"] = arrayValue
            } else if let dictValue = value as? [String: Any] {
                userDataDict["\(key)"] = dictValue
            } else if let setString = value as? Set<String> {
                userDataDict["\(key)"] = Array(setString)
            } else {
                // Fallback to string representation for complex types
                userDataDict["\(key)"] = "\(value)"
            }
        }

        // Add timestamp
        userDataDict["lastUpdated"] = FieldValue.serverTimestamp()

        return userDataDict
    }

    /// Convert Firestore data back to userData dictionary
    private func convertFromFirestoreFormat(_ firestoreData: [String: Any]) -> [UserDataKey: AnyHashable] {
        var userData: [UserDataKey: AnyHashable] = [:]

        for (keyString, value) in firestoreData {
            // Skip metadata fields
            if keyString == "lastUpdated" {
                continue
            }

            // Try to convert string key to UserDataKey
            guard let userDataKey = UserDataKey.from(string: keyString) else {
                print("⚠️ Unknown user data key: \(keyString)")
                continue
            }

            // Convert value back to appropriate type
            if let stringValue = value as? String {
                userData[userDataKey] = stringValue
            } else if let intValue = value as? Int {
                userData[userDataKey] = intValue
            } else if let doubleValue = value as? Double {
                userData[userDataKey] = doubleValue
            } else if let boolValue = value as? Bool {
                userData[userDataKey] = boolValue
            } else if let arrayValue = value as? [String] {
                userData[userDataKey] = arrayValue
            } else if let dictValue = value as? [String: Any] {
                userData[userDataKey] = dictValue
            } else {
                // Store as-is if type is unknown
                userData[userDataKey] = value as? AnyHashable
            }
        }

        return userData
    }
}

// MARK: - Supporting Types

/// Errors that can occur during persistence operations
enum PersistenceError: Error {
    case noAuthenticatedUser
    case conversionFailed
    case firestoreError(Error)

    var localizedDescription: String {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found"
        case .conversionFailed:
            return "Failed to convert data for storage"
        case .firestoreError(let error):
            return "Firestore error: \(error.localizedDescription)"
        }
    }
}

// MARK: - UserDataKey Extension

extension UserDataKey {
    /// Convert string to UserDataKey (reverse mapping)
    static func from(string: String) -> UserDataKey? {
        // This is a simple implementation - you may need to customize based on your keys
        switch string {
        case "howDidYouHearAboutUs": return .howDidYouHearAboutUs
        case "country": return .country
        case "name": return .name
        case "personalizeExperience": return .personalizeExperience
        case "currentStatus": return .currentStatus
        case "studentLevel": return .studentLevel
        case "interests": return .interests
        case "riasecResponses": return .riasecResponses
        case "riasecResponsesFlat": return .riasecResponsesFlat
        case "riasecResults": return .riasecResults
        case "riasecDimensions": return .riasecDimensions
        case "favoriteSubjects": return .favoriteSubjects
        case "extracurriculars": return .extracurriculars
        case "extracurricularOther": return .extracurricularOther
        case "careerInterests": return .careerInterests
        case "careerInterestsOther": return .careerInterestsOther
        case "workValues": return .workValues
        case "careerSuggestions": return .careerSuggestions
        default:
            return nil
        }
    }
}
