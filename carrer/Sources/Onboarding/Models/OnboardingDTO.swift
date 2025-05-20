import Foundation

struct OnboardingDTO: Codable {
    var firstName: String
    var lastName: String
    var birthDate: Date
    var progressStep: Int
    /// Auto-expires in 7 days (604 800 s) from creation
    var expiresAt: Date = Date().addingTimeInterval(604_800)
}