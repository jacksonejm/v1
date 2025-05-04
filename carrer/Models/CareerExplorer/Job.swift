import Foundation

struct Job: Identifiable {
    let id = UUID()
    let title: String
    let focus: String
    let salaryRange: String
    let growth: String
    let matchPercentage: Int
}