import Foundation

/// Represents a Canadian NOC (National Occupational Classification) occupation from OaSIS
/// Enriched with bilingual data (English/French) and mapped to O*NET careers
struct CanadianOccupation: Codable, Identifiable {
    let id = UUID()

    // O*NET Reference
    let onetCode: String
    let onetTitle: String

    // Canadian NOC Data
    let nocCode: String?
    let canadianTitle: String?
    let canadianTitleFr: String?  // French title

    // Descriptions
    let description: String?
    let descriptionFr: String?

    // Holland Codes (RIASEC)
    let hollandCodes: String?  // e.g., "IRC" = Investigative, Realistic, Conventional

    // Employment Information
    let requirements: String?  // Bullet-separated employment requirements
    let requirementsFr: String?

    // Job Titles
    let exampleTitles: String?  // Comma-separated example job titles
    let exampleTitlesFr: String?

    // Main Duties
    let duties: String?  // Bullet-separated duties
    let dutiesFr: String?

    // Mapping Quality
    let mappingConfidence: String?  // "HIGH", "MEDIUM", "LOW"

    // MARK: - Computed Properties

    /// Whether this O*NET occupation has a Canadian NOC mapping
    var hasCanadianMapping: Bool {
        nocCode != nil && canadianTitle != nil
    }

    /// Whether this occupation has bilingual (English/French) data
    var supportsBilingual: Bool {
        canadianTitleFr != nil && descriptionFr != nil
    }

    /// Short description (first 150 characters)
    var shortDescription: String {
        guard let desc = description else { return "" }
        if desc.count > 150 {
            return String(desc.prefix(150)) + "..."
        }
        return desc
    }

    /// Parsed Holland codes as individual characters
    var hollandCodesArray: [String] {
        guard let codes = hollandCodes else { return [] }
        return codes.map { String($0) }
    }

    /// Individual RIASEC dimensions with full names
    var hollandCodesFull: [(code: String, name: String)] {
        let mapping: [String: String] = [
            "R": "Realistic (Doers)",
            "I": "Investigative (Thinkers)",
            "A": "Artistic (Creators)",
            "S": "Social (Helpers)",
            "E": "Enterprising (Persuaders)",
            "C": "Conventional (Organizers)"
        ]

        return hollandCodesArray.compactMap { code in
            guard let name = mapping[code] else { return nil }
            return (code: code, name: name)
        }
    }

    /// Employment requirements as array (split by bullet points)
    var requirementsArray: [String] {
        guard let req = requirements else { return [] }
        return req
            .components(separatedBy: " • ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Example titles as array (split by comma)
    var exampleTitlesArray: [String] {
        guard let titles = exampleTitles else { return [] }
        return titles
            .components(separatedBy: ", ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Main duties as array (split by bullet points)
    var dutiesArray: [String] {
        guard let d = duties else { return [] }
        return d
            .components(separatedBy: " • ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Mapping confidence badge color
    var confidenceColor: String {
        switch mappingConfidence {
        case "HIGH": return "green"
        case "MEDIUM": return "orange"
        case "LOW": return "red"
        default: return "gray"
        }
    }

    /// Mapping confidence emoji
    var confidenceEmoji: String {
        switch mappingConfidence {
        case "HIGH": return "✅"
        case "MEDIUM": return "⚠️"
        case "LOW": return "⚡️"
        default: return "❓"
        }
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case onetCode = "ONETCODE"
        case onetTitle = "ONETTITLE"
        case nocCode = "NOCCODE"
        case canadianTitle = "CANADIANTITLE"
        case canadianTitleFr = "CANADIANTITLEFR"
        case description = "DESCRIPTION"
        case descriptionFr = "DESCRIPTIONFR"
        case hollandCodes = "HOLLANDCODES"
        case requirements = "REQUIREMENTS"
        case requirementsFr = "REQUIREMENTSFR"
        case exampleTitles = "EXAMPLETITLES"
        case exampleTitlesFr = "EXAMPLETITLESFR"
        case duties = "DUTIES"
        case dutiesFr = "DUTIESFR"
        case mappingConfidence = "CONFIDENCE"
    }

    // MARK: - Initializer

    init(
        onetCode: String,
        onetTitle: String,
        nocCode: String? = nil,
        canadianTitle: String? = nil,
        canadianTitleFr: String? = nil,
        description: String? = nil,
        descriptionFr: String? = nil,
        hollandCodes: String? = nil,
        requirements: String? = nil,
        requirementsFr: String? = nil,
        exampleTitles: String? = nil,
        exampleTitlesFr: String? = nil,
        duties: String? = nil,
        dutiesFr: String? = nil,
        mappingConfidence: String? = nil
    ) {
        self.onetCode = onetCode
        self.onetTitle = onetTitle
        self.nocCode = nocCode
        self.canadianTitle = canadianTitle
        self.canadianTitleFr = canadianTitleFr
        self.description = description
        self.descriptionFr = descriptionFr
        self.hollandCodes = hollandCodes
        self.requirements = requirements
        self.requirementsFr = requirementsFr
        self.exampleTitles = exampleTitles
        self.exampleTitlesFr = exampleTitlesFr
        self.duties = duties
        self.dutiesFr = dutiesFr
        self.mappingConfidence = mappingConfidence
    }
}
