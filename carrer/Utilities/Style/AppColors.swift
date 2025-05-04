import SwiftUI

struct AppColors {
    // Private hex color initializer
    private static func color(hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Brand Colors
    static let primaryBlue = color(hex: "3B82F6")
    static let accentPurple = color(hex: "8B5CF6")
    static let successGreen = color(hex: "34D399")
    
    // Background Colors
    static let background = color(hex: "F9FAFB")
    static let surfacePrimary = Color.white
    static let surfaceSecondary = color(hex: "F3F4F6")
    static let surfaceVariant = color(hex: "E5E7EB")
    
    // Text Colors
    static let textPrimary = color(hex: "1F2937")
    static let textSecondary = color(hex: "6B7280")
    static let textTertiary = color(hex: "9CA3AF")
    static let textOnPrimary = Color.white
    
    // Feedback Colors
    static let error = color(hex: "EF4444")
    static let warning = color(hex: "F59E0B")
    static let info = color(hex: "3B82F6")
    static let success = color(hex: "10B981")
    
    // Alias for primary
    static let primary = primaryBlue
}