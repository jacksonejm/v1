import Foundation

/// Job search strategy and guidance for a specific occupation
/// Returned by Snowflake SP_GET_JOB_SEARCH_STRATEGY procedure
struct JobSearchStrategy: Codable {
    let occupation: String
    let code: String
    let description: String
    let searchTitles: [String]
    let topSkills: [CareerSkill]
    let technologies: [String]
    let jobSearchLinks: JobBoardLinks

    /// Get the main occupation title
    var mainTitle: String {
        occupation
    }

    /// Get alternate titles (excluding main title)
    var alternateTitles: [String] {
        searchTitles.filter { $0 != occupation }
    }

    /// Get top N skills to highlight
    func topSkills(limit: Int = 5) -> [CareerSkill] {
        Array(topSkills.prefix(limit))
    }

    /// Get technologies to highlight
    func topTechnologies(limit: Int = 5) -> [String] {
        Array(technologies.prefix(limit))
    }
}

/// Links to major job search platforms
struct JobBoardLinks: Codable {
    let linkedin: String
    let indeed: String
    let google: String

    /// All available job board links
    var allLinks: [(name: String, url: String)] {
        [
            ("LinkedIn", linkedin),
            ("Indeed", indeed),
            ("Google Jobs", google)
        ]
    }

    /// Get URL for specific job board
    func url(for board: JobBoard) -> String {
        switch board {
        case .linkedin:
            return linkedin
        case .indeed:
            return indeed
        case .google:
            return google
        }
    }

    /// Supported job boards
    enum JobBoard {
        case linkedin
        case indeed
        case google

        var name: String {
            switch self {
            case .linkedin:
                return "LinkedIn"
            case .indeed:
                return "Indeed"
            case .google:
                return "Google Jobs"
            }
        }

        var icon: String {
            switch self {
            case .linkedin:
                return "briefcase.fill"
            case .indeed:
                return "magnifyingglass"
            case .google:
                return "globe"
            }
        }

        var color: String {
            switch self {
            case .linkedin:
                return "blue"
            case .indeed:
                return "orange"
            case .google:
                return "red"
            }
        }
    }
}
