import Foundation

struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let progress: Int
    let status: MilestoneStatus
    let actionTitle: String
}