import Foundation
import CryptoKit
import Security

/// Service for integrating with Snowflake O*NET Career Agent
/// Provides career matching, skills analysis, and job search guidance
class SnowflakeService {

    // MARK: - Singleton
    static let shared = SnowflakeService()

    // MARK: - Properties
    private let account: String
    private let username: String
    private let password: String
    private let warehouse: String
    private let database: String
    private let schema: String
    private let privateKey: String
    private let publicKeyFingerprint: String

    private var authToken: String?
    private var tokenExpiry: Date?

    // MARK: - Errors
    enum SnowflakeError: Error, LocalizedError {
        case invalidConfiguration
        case authenticationFailed
        case invalidResponse
        case requestFailed(statusCode: Int, message: String)
        case decodingFailed
        case noData

        var errorDescription: String? {
            switch self {
            case .invalidConfiguration:
                return "Snowflake credentials not configured properly"
            case .authenticationFailed:
                return "Failed to authenticate with Snowflake"
            case .invalidResponse:
                return "Invalid response from Snowflake"
            case .requestFailed(let statusCode, let message):
                return "Request failed (Status \(statusCode)): \(message)"
            case .decodingFailed:
                return "Failed to decode Snowflake response"
            case .noData:
                return "No data returned from Snowflake"
            }
        }
    }

    // MARK: - Initialization
    private init() {
        self.account = APIConfig.value(for: "SNOWFLAKE_ACCOUNT") ?? ""
        self.username = APIConfig.value(for: "SNOWFLAKE_USERNAME") ?? ""
        self.password = APIConfig.value(for: "SNOWFLAKE_PASSWORD") ?? ""
        self.warehouse = APIConfig.value(for: "SNOWFLAKE_WAREHOUSE") ?? "ONET_CAREER_AGENT_WH"
        self.database = APIConfig.value(for: "SNOWFLAKE_DATABASE") ?? "ONET_CAREER_DB"
        self.schema = APIConfig.value(for: "SNOWFLAKE_SCHEMA") ?? "CAREER_SCHEMA"
        self.privateKey = APIConfig.value(for: "SNOWFLAKE_PRIVATE_KEY") ?? ""
        self.publicKeyFingerprint = APIConfig.value(for: "SNOWFLAKE_PUBLIC_KEY_FINGERPRINT") ?? ""

        // Log configuration status (without sensitive data)
        print("🔧 Snowflake Configuration:")
        print("  Account: \(account.isEmpty ? "❌ MISSING" : "✅ Set (\(account.prefix(8))...)")")
        print("  Username: \(username.isEmpty ? "❌ MISSING" : "✅ Set")")
        print("  Private Key: \(privateKey.isEmpty ? "❌ MISSING" : "✅ Set (\(privateKey.count) chars)")")
        print("  Public Key FP: \(publicKeyFingerprint.isEmpty ? "❌ MISSING" : "✅ Set")")
        print("  Warehouse: \(warehouse)")
        print("  Database: \(database)")
        print("  Schema: \(schema)")
    }

    // MARK: - Public Methods

    /// Get career matches based on RIASEC scores
    /// - Parameter scores: Dictionary with keys R, I, A, S, E, C and Float values (0-5 scale)
    /// - Returns: Array of O*NET occupations matching the user's interests
    func getCareerMatches(scores: [String: Float]) async throws -> [ONetOccupation] {
        // Ensure we have valid scores for all 6 dimensions
        guard let r = scores["R"],
              let i = scores["I"],
              let a = scores["A"],
              let s = scores["S"],
              let e = scores["E"],
              let c = scores["C"] else {
            throw SnowflakeError.invalidConfiguration
        }

        let sql = """
        CALL \(database).\(schema).SP_GET_CAREER_MATCHES(\(r), \(i), \(a), \(s), \(e), \(c))
        """

        let response = try await executeSQLStatement(sql)

        // Parse the response JSON string
        guard let resultString = response["data"] as? [[String]],
              let firstRow = resultString.first,
              let jsonString = firstRow.first else {
            throw SnowflakeError.noData
        }

        // Decode the JSON string into ONetOccupation array
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SnowflakeError.decodingFailed
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let occupations = try decoder.decode([ONetOccupation].self, from: jsonData)

        return occupations
    }

    /// Get detailed skills for a specific occupation
    /// - Parameter occupationCode: O*NET SOC code (e.g., "27-1024.00")
    /// - Returns: Array of skills with importance and level ratings
    func getCareerSkills(occupationCode: String) async throws -> [CareerSkill] {
        let sql = """
        CALL \(database).\(schema).SP_GET_CAREER_SKILLS('\(occupationCode)')
        """

        let response = try await executeSQLStatement(sql)

        guard let resultString = response["data"] as? [[String]],
              let firstRow = resultString.first,
              let jsonString = firstRow.first else {
            throw SnowflakeError.noData
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SnowflakeError.decodingFailed
        }

        let decoder = JSONDecoder()
        let skills = try decoder.decode([CareerSkill].self, from: jsonData)

        return skills
    }

    /// Get job search strategy for a specific occupation
    /// - Parameter occupationCode: O*NET SOC code (e.g., "27-1024.00")
    /// - Returns: Job search guidance with titles, skills, and job board links
    func getJobSearchStrategy(occupationCode: String) async throws -> JobSearchStrategy {
        let sql = """
        CALL \(database).\(schema).SP_GET_JOB_SEARCH_STRATEGY('\(occupationCode)')
        """

        let response = try await executeSQLStatement(sql)

        guard let resultString = response["data"] as? [[String]],
              let firstRow = resultString.first,
              let jsonString = firstRow.first else {
            throw SnowflakeError.noData
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SnowflakeError.decodingFailed
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let strategy = try decoder.decode(JobSearchStrategy.self, from: jsonData)

        return strategy
    }

    // MARK: - Private Methods

    /// Generate JWT token for Snowflake key-pair authentication
    private func generateJWT() throws -> String {
        guard !account.isEmpty, !username.isEmpty, !privateKey.isEmpty, !publicKeyFingerprint.isEmpty else {
            throw SnowflakeError.invalidConfiguration
        }

        // Prepare account identifier (uppercase, replace dots with hyphens)
        let accountIdentifier = account.uppercased().replacingOccurrences(of: ".", with: "-")
        let usernameUpper = username.uppercased()

        // JWT Header
        let header = [
            "alg": "RS256",
            "typ": "JWT"
        ]

        // JWT Claims
        let now = Date()
        let expiration = now.addingTimeInterval(3540) // 59 minutes (max 1 hour)

        let claims: [String: Any] = [
            "iss": "\(accountIdentifier).\(usernameUpper).SHA256:\(publicKeyFingerprint)",
            "sub": "\(accountIdentifier).\(usernameUpper)",
            "iat": Int(now.timeIntervalSince1970),
            "exp": Int(expiration.timeIntervalSince1970)
        ]

        // Encode header and claims as base64url
        guard let headerData = try? JSONSerialization.data(withJSONObject: header),
              let claimsData = try? JSONSerialization.data(withJSONObject: claims) else {
            throw SnowflakeError.invalidConfiguration
        }

        let headerBase64 = headerData.base64URLEncodedString()
        let claimsBase64 = claimsData.base64URLEncodedString()
        let message = "\(headerBase64).\(claimsBase64)"

        // Sign with private key
        guard let messageData = message.data(using: .utf8) else {
            throw SnowflakeError.invalidConfiguration
        }

        let signature = try signWithPrivateKey(data: messageData)
        let signatureBase64 = signature.base64URLEncodedString()

        return "\(message).\(signatureBase64)"
    }

    /// Sign data with RSA private key (PKCS#1 format)
    private func signWithPrivateKey(data: Data) throws -> Data {
        // Parse private key from PEM format (supports both PKCS#1 and PKCS#8)
        let privateKeyString = privateKey
            .replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let keyData = Data(base64Encoded: privateKeyString, options: .ignoreUnknownCharacters) else {
            print("❌ Failed to decode base64 private key")
            throw SnowflakeError.invalidConfiguration
        }

        print("🔑 Decoded key data length: \(keyData.count) bytes")

        // Create SecKey from PKCS#1 RSA private key
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048,
            kSecAttrIsPermanent as String: false
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                print("❌ Failed to create SecKey: \(error)")
            }
            throw SnowflakeError.invalidConfiguration
        }

        print("✅ Successfully created SecKey")

        // Sign using SHA256withRSA (RS256)
        var signError: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            secKey,
            .rsaSignatureMessagePKCS1v15SHA256,
            data as CFData,
            &signError
        ) as Data? else {
            if let error = signError?.takeRetainedValue() {
                print("❌ Failed to create signature: \(error)")
            }
            throw SnowflakeError.authenticationFailed
        }

        print("✅ Successfully signed data with RSA key")
        return signature
    }

    /// Execute a SQL statement using Snowflake SQL API with JWT authentication
    private func executeSQLStatement(_ sql: String) async throws -> [String: Any] {
        // Generate or get cached JWT token
        let jwt = try getJWT()

        // Snowflake SQL API v2 endpoint
        let urlString = "https://\(account).snowflakecomputing.com/api/v2/statements"
        guard let url = URL(string: urlString) else {
            throw SnowflakeError.invalidConfiguration
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Use Bearer token with JWT
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("KEYPAIR_JWT", forHTTPHeaderField: "X-Snowflake-Authorization-Token-Type")

        // Build request body
        let body: [String: Any] = [
            "statement": sql,
            "timeout": 60,
            "database": database,
            "schema": schema,
            "warehouse": warehouse
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("📡 Executing SQL: \(sql.prefix(100))...")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SnowflakeError.invalidResponse
        }

        // Log response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response (\(httpResponse.statusCode)): \(responseString.prefix(500))")
        }

        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Snowflake API Error (\(httpResponse.statusCode)):")
            print(message)
            throw SnowflakeError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        guard let result = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SnowflakeError.decodingFailed
        }

        return result
    }

    /// Get or generate JWT token (with caching)
    private func getJWT() throws -> String {
        // Check if we have a valid cached JWT
        if let token = authToken, let expiry = tokenExpiry, expiry > Date() {
            return token
        }

        // Generate new JWT
        let jwt = try generateJWT()

        // Cache the JWT
        authToken = jwt
        tokenExpiry = Date().addingTimeInterval(3540) // 59 minutes

        print("✅ Generated new JWT token")
        return jwt
    }
}

// MARK: - Data Extension for Base64URL Encoding

extension Data {
    /// Encode data as base64url (RFC 4648)
    func base64URLEncodedString() -> String {
        let base64 = self.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
