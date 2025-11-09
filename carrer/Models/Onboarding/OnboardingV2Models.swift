import Foundation

// MARK: - Onboarding Step Enum

enum OnbStep: String, Codable, CaseIterable {
    case welcome
    case country_lang
    case riasec_p1
    case riasec_p2
    case riasec_p3
    case values
    case subj_acts
    case interests
    case review
    case generate
    case done

    var displayName: String {
        switch self {
        case .welcome: return "Welcome"
        case .country_lang: return "Country & Language"
        case .riasec_p1: return "RIASEC 1/3"
        case .riasec_p2: return "RIASEC 2/3"
        case .riasec_p3: return "RIASEC 3/3"
        case .values: return "Work Values"
        case .subj_acts: return "Subjects & Activities"
        case .interests: return "Career Interests"
        case .review: return "Review"
        case .generate: return "Generating"
        case .done: return "Complete"
        }
    }

    var stepNumber: Int {
        Self.allCases.firstIndex(of: self).map { $0 + 1 } ?? 0
    }

    var totalSteps: Int {
        Self.allCases.count
    }

    var next: OnbStep? {
        guard let index = Self.allCases.firstIndex(of: self),
              index + 1 < Self.allCases.count else {
            return nil
        }
        return Self.allCases[index + 1]
    }

    var previous: OnbStep? {
        guard let index = Self.allCases.firstIndex(of: self),
              index > 0 else {
            return nil
        }
        return Self.allCases[index - 1]
    }
}

// MARK: - RIASEC Item

struct RIASECItem: Codable, Identifiable {
    let id: String
    let dim: String  // Short code: "R", "I", "A", "S", "E", "C"
    let text: String
    let reverse: Bool

    var dimension: RIASECDimensionV2 {
        RIASECDimensionV2(rawValue: dim) ?? .realistic
    }
}

// OnboardingV2-specific RIASEC dimension enum (uses short codes)
enum RIASECDimensionV2: String, Codable {
    case realistic = "R"
    case investigative = "I"
    case artistic = "A"
    case social = "S"
    case enterprising = "E"
    case conventional = "C"

    var fullName: String {
        switch self {
        case .realistic: return "Realistic (Doers)"
        case .investigative: return "Investigative (Thinkers)"
        case .artistic: return "Artistic (Creators)"
        case .social: return "Social (Helpers)"
        case .enterprising: return "Enterprising (Persuaders)"
        case .conventional: return "Conventional (Organizers)"
        }
    }

    var shortDescription: String {
        switch self {
        case .realistic:
            return "Hands-on, mechanical, physical work"
        case .investigative:
            return "Analytical, scientific, problem-solving"
        case .artistic:
            return "Creative, expressive, imaginative"
        case .social:
            return "People-oriented, teaching, helping"
        case .enterprising:
            return "Leadership, sales, management"
        case .conventional:
            return "Organized, detail-oriented, systematic"
        }
    }
}

// MARK: - Work Value (OnboardingV2)

struct WorkValueItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
}

struct WorkValuesData: Codable {
    let primary: [WorkValueItem]
    let additional: [WorkValueItem]
}

// MARK: - Draft Schema

struct OnboardingDraft: Codable {
    var schemaVersion: Int = 1
    var lastStep: OnbStep = .welcome
    var riasecPageIndex: Int = 0
    var focusedRowId: String? = nil

    var answers: [String: Int] = [:]  // "R.Q1" -> 1..5
    var values: [String: Int] = [:]    // "balance" -> 1..5
    var subjects: [String] = []
    var activities: [String] = []
    var interests: [String] = []
    var country: String = ""
    var language: String = "en"

    var updatedAt: Date = Date()
    var completed: Bool = false

    // MARK: - Validation

    func riasecPageComplete(for page: Int, items: [RIASECItem]) -> Bool {
        let pageItems = itemsForPage(page, allItems: items)
        return pageItems.allSatisfy { answers[$0.id] != nil }
    }

    func valuesComplete() -> Bool {
        values.count >= 6
    }

    func riasecComplete(items: [RIASECItem]) -> Bool {
        items.allSatisfy { answers[$0.id] != nil }
    }

    // MARK: - RIASEC Scoring

    func riasecMeans(from items: [RIASECItem]) -> [String: Double] {
        let grouped = Dictionary(grouping: items) { $0.dim }
        return grouped.mapValues { dimItems in
            let vals = dimItems.compactMap { item -> Double? in
                guard let raw = answers[item.id] else { return nil }
                let mapped = item.reverse ? (6 - raw) : raw
                return Double(mapped)
            }
            guard !vals.isEmpty else { return 0.0 }
            return vals.reduce(0, +) / Double(vals.count)
        }
    }

    func topRIASEC(from items: [RIASECItem]) -> [String] {
        let means = riasecMeans(from: items)
        return means.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    func topValues() -> [(key: String, value: Int)] {
        values.sorted { $0.value > $1.value }
            .prefix(5)
            .map { ($0.key, $0.value) }
    }

    // MARK: - Helper

    private func itemsForPage(_ page: Int, allItems: [RIASECItem]) -> [RIASECItem] {
        let dimensions: [[String]]  = [
            ["R", "I"],  // Page 0
            ["A", "S"],  // Page 1
            ["E", "C"]   // Page 2
        ]
        guard page < dimensions.count else { return [] }
        let dims = dimensions[page]
        return allItems.filter { dims.contains($0.dim) }
    }
}
