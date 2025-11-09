import Foundation

struct APIConfig {
    private static let plistName = "APIKeys"
    
    static func value(for key: String) -> String? {
        guard let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = dict[key] as? String else {
            print("Error: Missing API key for \(key)")
            return nil
        }
        return value
    }
    
    static var openAIKey: String? {
        return value(for: "OPENAI_API_KEY")
    }
    
    static var supabaseURL: String? {
        return value(for: "SUPABASE_URL")
    }
    
    static var supabaseKey: String? {
        return value(for: "SUPABASE_KEY")
    }

    // MARK: - Snowflake Configuration

    static var snowflakeAccount: String? {
        return value(for: "SNOWFLAKE_ACCOUNT")
    }

    static var snowflakeUsername: String? {
        return value(for: "SNOWFLAKE_USERNAME")
    }

    static var snowflakePassword: String? {
        return value(for: "SNOWFLAKE_PASSWORD")
    }

    static var snowflakeWarehouse: String? {
        return value(for: "SNOWFLAKE_WAREHOUSE")
    }

    static var snowflakeDatabase: String? {
        return value(for: "SNOWFLAKE_DATABASE")
    }

    static var snowflakeSchema: String? {
        return value(for: "SNOWFLAKE_SCHEMA")
    }

    static var snowflakePrivateKey: String? {
        return value(for: "SNOWFLAKE_PRIVATE_KEY")
    }

    static var snowflakePublicKeyFingerprint: String? {
        return value(for: "SNOWFLAKE_PUBLIC_KEY_FINGERPRINT")
    }
}