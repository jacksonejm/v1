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
}