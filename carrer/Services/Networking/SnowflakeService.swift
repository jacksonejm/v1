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

    /// Get career matches based on RIASEC scores, Work Values, Skills, and Context (Recipe D v4.0)
    /// - Parameters:
    ///   - scores: Dictionary with keys R, I, A, S, E, C and Float values (0-5 scale)
    ///   - workValues: Optional dictionary with work values (1-5 scale). If nil, defaults to 3.0 for all
    ///   - subjects: Optional array of subject names (e.g., ["Math", "Science"])
    ///   - activities: Optional array of activity names (e.g., ["Coding/Programming", "Debate"])
    ///   - careerInterests: Optional array of career interests (e.g., ["Software Developer"])
    ///   - studentLevel: Optional education level ("High School", "Undergraduate", "Graduate")
    ///   - currentStatus: Optional current status ("Student", "Career Changer", etc.)
    /// - Returns: Array of O*NET occupations with 4-dimensional match scores
    func getCareerMatches(
        scores: [String: Float],
        workValues: [String: Float]? = nil,
        subjects: [String]? = nil,
        activities: [String]? = nil,
        careerInterests: [String]? = nil,
        studentLevel: String? = nil,
        currentStatus: String? = nil
    ) async throws -> [ONetOccupation] {
        // Ensure we have valid RIASEC scores for all 6 dimensions
        guard let r = scores["R"],
              let i = scores["I"],
              let a = scores["A"],
              let s = scores["S"],
              let e = scores["E"],
              let c = scores["C"] else {
            throw SnowflakeError.invalidConfiguration
        }

        // Get work values or use defaults (3.0 = moderate importance)
        let achievement = workValues?["achievement"] ?? 3.0
        let independence = workValues?["independence"] ?? 3.0
        let recognition = workValues?["recognition"] ?? 3.0
        let relationships = workValues?["relationships"] ?? 3.0
        let support = workValues?["support"] ?? 3.0
        let workingConditions = workValues?["working_conditions"] ?? 3.0

        // Recipe D v4.0: Prepare JSON arrays for subjects, activities, career interests
        let encoder = JSONEncoder()
        let subjectsJSON = try encoder.encode(subjects ?? [])
        let activitiesJSON = try encoder.encode(activities ?? [])
        let interestsJSON = try encoder.encode(careerInterests ?? [])

        guard let subjectsStr = String(data: subjectsJSON, encoding: .utf8),
              let activitiesStr = String(data: activitiesJSON, encoding: .utf8),
              let interestsStr = String(data: interestsJSON, encoding: .utf8) else {
            throw SnowflakeError.invalidConfiguration
        }

        let level = studentLevel ?? "Unknown"
        let status = currentStatus ?? "Unknown"

        // Call Recipe D v4.0 with all 17 parameters (6 RIASEC + 6 Work Values + 5 context)
        let sql = """
        CALL \(database).\(schema).SP_GET_CAREER_MATCHES_V4(
            \(r), \(i), \(a), \(s), \(e), \(c),
            \(achievement), \(independence), \(recognition), \(relationships), \(support), \(workingConditions),
            '\(subjectsStr.replacingOccurrences(of: "'", with: "''"))',
            '\(activitiesStr.replacingOccurrences(of: "'", with: "''"))',
            '\(interestsStr.replacingOccurrences(of: "'", with: "''"))',
            '\(level)',
            '\(status)'
        )
        """

        print("📊 Recipe D v4.0 Call:")
        print("  Subjects: \(subjects?.joined(separator: ", ") ?? "none")")
        print("  Activities: \(activities?.joined(separator: ", ") ?? "none")")
        print("  Career Interests: \(careerInterests?.joined(separator: ", ") ?? "none")")
        print("  Student Level: \(level)")
        print("  Status: \(status)")

        let response = try await executeSQLStatement(sql)

        // Parse the response - Recipe D v4.0 returns JSON string
        guard let resultString = response["data"] as? [[String]],
              let firstRow = resultString.first,
              let jsonString = firstRow.first else {
            throw SnowflakeError.noData
        }

        print("📦 Raw JSON response length: \(jsonString.count) characters")

        // Decode the JSON string into array of dictionaries
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw SnowflakeError.decodingFailed
        }

        // Parse JSON array manually since structure is custom
        guard let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            throw SnowflakeError.decodingFailed
        }

        var occupations: [ONetOccupation] = []

        for item in jsonArray {
            guard let code = item["ONET_SOC_CODE"] as? String,
                  let title = item["JOB_TITLE"] as? String,
                  let description = item["DESCRIPTION"] as? String,
                  let interestsMatch = item["INTERESTS_MATCH"] as? Double,
                  let valuesMatch = item["VALUES_MATCH"] as? Double,
                  let skillsMatch = item["SKILLS_MATCH"] as? Double,
                  let contextScore = item["CONTEXT_SCORE"] as? Double,
                  let finalScore = item["FINAL_SCORE"] as? Double,
                  let explanation = item["MATCH_EXPLANATION"] as? String else {
                continue
            }

            let occupation = ONetOccupation(
                onetSocCode: code,
                title: title,
                description: description,
                match: Int(finalScore * 100 / 7.0),  // Convert 0-7 scale to 0-100 percentage
                education: nil,
                outlook: nil,
                salary: nil,
                matchExplanation: explanation,
                interestsMatch: interestsMatch,
                valuesMatch: valuesMatch,
                skillsMatch: skillsMatch,
                contextScore: contextScore
            )

            occupations.append(occupation)
        }

        print("✅ Recipe D v4.0 returned \(occupations.count) matches")

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

    // MARK: - Canadian NOC Integration (Hybrid Approach)

    /// Enrich a single O*NET occupation with Canadian NOC context
    /// - Parameter onetCode: O*NET SOC code (e.g., "15-1252.00")
    /// - Returns: Canadian occupation data with NOC mapping, or nil if no mapping exists
    func getCanadianOccupation(onetCode: String) async throws -> CanadianOccupation? {
        let sql = """
        SELECT
            cfv.ONET_SOC_CODE AS onetCode,
            cfv.JOB_TITLE AS onetTitle,
            c.NOC_CODE AS nocCode,
            n.TITLE_EN AS canadianTitle,
            n.TITLE_FR AS canadianTitleFr,
            n.DESCRIPTION_EN AS description,
            n.DESCRIPTION_FR AS descriptionFr,
            n.HOLLAND_CODE_1 || n.HOLLAND_CODE_2 || COALESCE(n.HOLLAND_CODE_3, '') AS hollandCodes,
            n.EMPLOYMENT_REQUIREMENTS_EN AS requirements,
            n.EMPLOYMENT_REQUIREMENTS_FR AS requirementsFr,
            n.EXAMPLE_TITLES_EN AS exampleTitles,
            n.EXAMPLE_TITLES_FR AS exampleTitlesFr,
            n.MAIN_DUTIES_EN AS duties,
            n.MAIN_DUTIES_FR AS dutiesFr,
            c.MAPPING_CONFIDENCE AS confidence
        FROM \(database).\(schema).CAREER_FULL_VECTORS cfv
        LEFT JOIN \(database).\(schema).NOC_ONET_CROSSWALK c ON cfv.ONET_SOC_CODE = c.ONET_CODE
        LEFT JOIN \(database).\(schema).NOC_OCCUPATIONS n ON c.NOC_CODE = SUBSTRING(n.NOC_CODE, 1, 5)
        WHERE cfv.ONET_SOC_CODE = '\(onetCode)'
        """

        print("🇨🇦 Fetching Canadian occupation data for: \(onetCode)")

        let response = try await executeSQLStatement(sql)

        guard let data = response["data"] as? [[String?]],
              let firstRow = data.first else {
            return nil
        }

        // Parse row manually (columns in order from SELECT)
        guard firstRow.count >= 15,
              let onetCode = firstRow[0],
              let onetTitle = firstRow[1] else {
            return nil
        }

        let canadianOccupation = CanadianOccupation(
            onetCode: onetCode,
            onetTitle: onetTitle,
            nocCode: firstRow[2],
            canadianTitle: firstRow[3],
            canadianTitleFr: firstRow[4],
            description: firstRow[5],
            descriptionFr: firstRow[6],
            hollandCodes: firstRow[7],
            requirements: firstRow[8],
            requirementsFr: firstRow[9],
            exampleTitles: firstRow[10],
            exampleTitlesFr: firstRow[11],
            duties: firstRow[12],
            dutiesFr: firstRow[13],
            mappingConfidence: firstRow[14]
        )

        if canadianOccupation.hasCanadianMapping {
            print("✅ Found Canadian mapping: NOC \(canadianOccupation.nocCode ?? "") - \(canadianOccupation.canadianTitle ?? "")")
        } else {
            print("ℹ️ No Canadian mapping available for \(onetCode)")
        }

        return canadianOccupation
    }

    /// Enrich multiple O*NET occupations with Canadian NOC context (batch operation)
    /// - Parameter onetCodes: Array of O*NET SOC codes
    /// - Returns: Dictionary mapping O*NET code to Canadian occupation data
    func getCanadianOccupations(onetCodes: [String]) async throws -> [String: CanadianOccupation] {
        guard !onetCodes.isEmpty else { return [:] }

        // Build IN clause for SQL query
        let codesString = onetCodes.map { "'\($0)'" }.joined(separator: ", ")

        let sql = """
        SELECT
            cfv.ONET_SOC_CODE AS onetCode,
            cfv.JOB_TITLE AS onetTitle,
            c.NOC_CODE AS nocCode,
            n.TITLE_EN AS canadianTitle,
            n.TITLE_FR AS canadianTitleFr,
            n.DESCRIPTION_EN AS description,
            n.DESCRIPTION_FR AS descriptionFr,
            n.HOLLAND_CODE_1 || n.HOLLAND_CODE_2 || COALESCE(n.HOLLAND_CODE_3, '') AS hollandCodes,
            n.EMPLOYMENT_REQUIREMENTS_EN AS requirements,
            n.EMPLOYMENT_REQUIREMENTS_FR AS requirementsFr,
            n.EXAMPLE_TITLES_EN AS exampleTitles,
            n.EXAMPLE_TITLES_FR AS exampleTitlesFr,
            n.MAIN_DUTIES_EN AS duties,
            n.MAIN_DUTIES_FR AS dutiesFr,
            c.MAPPING_CONFIDENCE AS confidence
        FROM \(database).\(schema).CAREER_FULL_VECTORS cfv
        LEFT JOIN \(database).\(schema).NOC_ONET_CROSSWALK c ON cfv.ONET_SOC_CODE = c.ONET_CODE
        LEFT JOIN \(database).\(schema).NOC_OCCUPATIONS n ON c.NOC_CODE = SUBSTRING(n.NOC_CODE, 1, 5)
        WHERE cfv.ONET_SOC_CODE IN (\(codesString))
        """

        print("🇨🇦 Fetching Canadian occupation data for \(onetCodes.count) careers...")

        let response = try await executeSQLStatement(sql)

        guard let data = response["data"] as? [[String?]] else {
            return [:]
        }

        var result: [String: CanadianOccupation] = [:]

        for row in data {
            guard row.count >= 15,
                  let onetCode = row[0],
                  let onetTitle = row[1] else {
                continue
            }

            let canadianOccupation = CanadianOccupation(
                onetCode: onetCode,
                onetTitle: onetTitle,
                nocCode: row[2],
                canadianTitle: row[3],
                canadianTitleFr: row[4],
                description: row[5],
                descriptionFr: row[6],
                hollandCodes: row[7],
                requirements: row[8],
                requirementsFr: row[9],
                exampleTitles: row[10],
                exampleTitlesFr: row[11],
                duties: row[12],
                dutiesFr: row[13],
                mappingConfidence: row[14]
            )

            result[onetCode] = canadianOccupation
        }

        let mappedCount = result.values.filter { $0.hasCanadianMapping }.count
        print("✅ Found \(mappedCount)/\(onetCodes.count) Canadian mappings")

        return result
    }

    /// Check if an O*NET occupation has Canadian NOC mapping (quick check)
    /// - Parameter onetCode: O*NET SOC code
    /// - Returns: True if Canadian mapping exists
    func hasCanadianMapping(onetCode: String) async throws -> Bool {
        let sql = """
        SELECT COUNT(*) AS count
        FROM \(database).\(schema).NOC_ONET_CROSSWALK
        WHERE ONET_CODE = '\(onetCode)'
        """

        let response = try await executeSQLStatement(sql)

        guard let data = response["data"] as? [[String]],
              let firstRow = data.first,
              let countStr = firstRow.first,
              let count = Int(countStr) else {
            return false
        }

        return count > 0
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
