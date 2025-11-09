import Foundation
import Security

protocol OnboardingDataStore {
    func save(_ dto: OnboardingDTO) throws
    func load() throws -> OnboardingDTO?
    func delete() throws
}

class SecureOnboardingStore: OnboardingDataStore {
    // Keychain constants
    private let secClass = kSecClassGenericPassword
    private let service = "com.mypath.onboarding"
    private let account = "current"
    private let accessibility = kSecAttrAccessibleAfterFirstUnlock
    
    // MARK: - OnboardingDataStore Protocol Methods
    
    func save(_ dto: OnboardingDTO) throws {
        // Encode the DTO to JSON data
        let data = try JSONEncoder().encode(dto)
        
        // Create the query for deleting any existing item
        let deleteQuery: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        // Delete any existing item
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Create the query for adding the new item
        let addQuery: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: accessibility,
            kSecValueData as String: data
        ]
        
        // Add the new item
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.saveFailure(status: status)
        }
    }
    
    func load() throws -> OnboardingDTO? {
        // Create the query for retrieving the item
        let query: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Retrieve the item from keychain
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        // If no item found, return nil
        if status == errSecItemNotFound {
            return nil
        }
        
        // If other error, throw it
        if status != errSecSuccess {
            throw KeychainError.loadFailure(status: status)
        }
        
        // If we got here, we should have the data
        guard let data = dataTypeRef as? Data else {
            throw KeychainError.invalidData
        }
        
        // Decode the data
        let dto = try JSONDecoder().decode(OnboardingDTO.self, from: data)
        
        // Check expiration
        if dto.expiresAt <= Date() {
            // Data has expired, delete it and return nil
            try delete()
            return nil
        }
        
        return dto
    }
    
    func delete() throws {
        // Create the query for deleting the item
        let query: [String: Any] = [
            kSecClass as String: secClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        // Delete the item
        let status = SecItemDelete(query as CFDictionary)
        
        // If the item doesn't exist, that's fine - consider it already deleted
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailure(status: status)
        }
    }
}

// MARK: - Error Types

enum KeychainError: Error {
    case saveFailure(status: OSStatus)
    case loadFailure(status: OSStatus)
    case deleteFailure(status: OSStatus)
    case invalidData
}