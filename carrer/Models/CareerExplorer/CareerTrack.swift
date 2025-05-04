import Foundation

// Make CareerTrack conform to Hashable and Codable
struct CareerTrack: Identifiable, Hashable, Codable {
    let id = UUID()
    let title: String
    let progress: Int
    let salary: String
    let education: String
    let match: Int
}