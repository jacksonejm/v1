import Foundation
import NaturalLanguage

/// Extracts structured data from conversational user input
class ConversationalDataExtractor {
    
    // MARK: - Public Methods
    
    /// Extract data from user message based on expected fields
    func extract(
        from message: String,
        expecting fields: [OnboardingField],
        context: OnboardingData
    ) async -> ExtractedDataCollection {
        var extracted = ExtractedDataCollection()
        
        for field in fields {
            if let data = await extractField(field, from: message, context: context) {
                extracted.add(data)
            }
        }
        
        return extracted
    }
    
    // MARK: - Field-Specific Extraction
    
    private func extractField(
        _ field: OnboardingField,
        from message: String,
        context: OnboardingData
    ) async -> ExtractedData? {
        switch field {
        case .name:
            return extractName(from: message)
        case .howDidYouHearAboutUs:
            return extractReferralSource(from: message)
        case .currentStatus:
            return extractCurrentStatus(from: message)
        case .studentLevel:
            return extractEducationLevel(from: message)
        case .interests:
            return extractInterests(from: message)
        case .favoriteSubjects:
            return extractSubjects(from: message)
        case .extracurriculars:
            return extractActivities(from: message)
        case .careerInterests:
            return extractCareers(from: message)
        default:
            return nil
        }
    }
    
    // MARK: - Name Extraction
    
    private func extractName(from message: String) -> ExtractedData? {
        let normalized = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Common patterns for name responses
        let patterns = [
            "^(my name is |i'm |i am |call me )?([A-Za-z]+(?:\\s+[A-Za-z]+)*)$",
            "^([A-Za-z]+(?:\\s+[A-Za-z]+)*)$"
        ]
        
        for pattern in patterns {
            if let match = normalized.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let extracted = String(normalized[match])
                
                // Clean up the match
                let cleaned = extracted
                    .replacingOccurrences(of: "my name is", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "i'm", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "i am", with: "", options: .caseInsensitive)
                    .replacingOccurrences(of: "call me", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !cleaned.isEmpty && cleaned.count < 50 { // Reasonable name length
                    return ExtractedData(
                        field: .name,
                        value: cleaned,
                        confidence: 0.9,
                        rawText: message
                    )
                }
            }
        }
        
        // If it's just a single or two words, might be a name
        let words = normalized.split(separator: " ")
        if words.count <= 3 && words.allSatisfy({ $0.rangeOfCharacter(from: .letters) != nil }) {
            return ExtractedData(
                field: .name,
                value: normalized,
                confidence: 0.7,
                rawText: message
            )
        }
        
        return nil
    }
    
    // MARK: - Referral Source Extraction
    
    private func extractReferralSource(from message: String) -> ExtractedData? {
        let normalized = message.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let sources = [
            "friend": ["friend", "buddy", "someone i know"],
            "family": ["family", "parent", "mom", "dad", "brother", "sister", "relative"],
            "school": ["school", "teacher", "counselor", "advisor"],
            "social media": ["social media", "instagram", "tiktok", "facebook", "twitter", "youtube"],
            "search": ["google", "search", "online", "internet", "website"],
            "other": ["other", "else"]
        ]
        
        for (category, keywords) in sources {
            for keyword in keywords {
                if normalized.contains(keyword) {
                    return ExtractedData(
                        field: .howDidYouHearAboutUs,
                        value: category,
                        confidence: 0.85,
                        rawText: message
                    )
                }
            }
        }
        
        // If no match, store as "other" with lower confidence
        return ExtractedData(
            field: .howDidYouHearAboutUs,
            value: "other",
            confidence: 0.5,
            rawText: message
        )
    }
    
    // MARK: - Current Status Extraction
    
    private func extractCurrentStatus(from message: String) -> ExtractedData? {
        let normalized = message.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let statuses = [
            "Student": ["student", "studying", "in school", "going to school", "at school"],
            "Working": ["working", "work", "job", "employed", "employee"],
            "Both": ["both", "working and studying", "student and working"],
            "Neither": ["neither", "none", "not working", "not studying", "looking"]
        ]
        
        for (status, keywords) in statuses {
            for keyword in keywords {
                if normalized.contains(keyword) {
                    return ExtractedData(
                        field: .currentStatus,
                        value: status,
                        confidence: 0.9,
                        rawText: message
                    )
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Education Level Extraction
    
    private func extractEducationLevel(from message: String) -> ExtractedData? {
        let normalized = message.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let levels = [
            "High School": ["high school", "9th", "10th", "11th", "12th", "freshman", "sophomore", "junior", "senior"],
            "College": ["college", "university", "undergraduate", "bachelors", "associates"],
            "Graduate": ["graduate", "masters", "phd", "doctorate", "postgrad"],
            "Other": ["other", "different"]
        ]
        
        for (level, keywords) in levels {
            for keyword in keywords {
                if normalized.contains(keyword) {
                    return ExtractedData(
                        field: .studentLevel,
                        value: level,
                        confidence: 0.85,
                        rawText: message
                    )
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Interests Extraction
    
    private func extractInterests(from message: String) -> ExtractedData? {
        let normalized = message.lowercased()
        var interests: [String] = []
        
        // Common interest categories
        let interestKeywords = [
            "technology", "computers", "programming", "coding", "software",
            "science", "math", "physics", "chemistry", "biology",
            "art", "music", "drawing", "painting", "design",
            "sports", "fitness", "exercise", "athletics",
            "reading", "writing", "literature", "books",
            "business", "entrepreneurship", "finance",
            "helping people", "volunteering", "community service",
            "nature", "environment", "outdoors", "animals"
        ]
        
        for keyword in interestKeywords {
            if normalized.contains(keyword) {
                interests.append(keyword)
            }
        }
        
        if !interests.isEmpty {
            return ExtractedData(
                field: .interests,
                value: interests,
                confidence: 0.8,
                rawText: message
            )
        }
        
        return nil
    }
    
    // MARK: - Subjects Extraction
    
    private func extractSubjects(from message: String) -> ExtractedData? {
        let normalized = message.lowercased()
        var subjects: [String] = []
        
        let subjectKeywords = [
            "math", "mathematics", "algebra", "geometry", "calculus",
            "science", "biology", "chemistry", "physics",
            "english", "literature", "writing", "language arts",
            "history", "social studies", "geography",
            "art", "music", "drama", "theater",
            "computer science", "programming", "technology",
            "physical education", "pe", "gym",
            "foreign language", "spanish", "french", "german"
        ]
        
        for keyword in subjectKeywords {
            if normalized.contains(keyword) {
                subjects.append(keyword)
            }
        }
        
        if !subjects.isEmpty {
            return ExtractedData(
                field: .favoriteSubjects,
                value: subjects,
                confidence: 0.85,
                rawText: message
            )
        }
        
        return nil
    }
    
    // MARK: - Activities Extraction
    
    private func extractActivities(from message: String) -> ExtractedData? {
        let normalized = message.lowercased()
        var activities: [String] = []
        
        let activityKeywords = [
            "sports", "football", "basketball", "soccer", "tennis", "swimming",
            "club", "debate", "chess", "robotics", "science club",
            "music", "band", "orchestra", "choir",
            "volunteer", "community service", "tutoring",
            "student government", "student council",
            "art", "photography", "yearbook", "newspaper",
            "gaming", "video games", "esports"
        ]
        
        for keyword in activityKeywords {
            if normalized.contains(keyword) {
                activities.append(keyword)
            }
        }
        
        if !activities.isEmpty {
            return ExtractedData(
                field: .extracurriculars,
                value: activities,
                confidence: 0.8,
                rawText: message
            )
        }
        
        return nil
    }
    
    // MARK: - Career Interests Extraction
    
    private func extractCareers(from message: String) -> ExtractedData? {
        let normalized = message.lowercased()
        var careers: [String] = []
        
        let careerKeywords = [
            "doctor", "nurse", "healthcare", "medicine",
            "engineer", "engineering", "developer", "programmer",
            "teacher", "professor", "education",
            "artist", "designer", "creative",
            "business", "entrepreneur", "manager",
            "scientist", "researcher", "laboratory",
            "lawyer", "attorney", "law",
            "writer", "journalist", "author"
        ]
        
        for keyword in careerKeywords {
            if normalized.contains(keyword) {
                careers.append(keyword)
            }
        }
        
        if !careers.isEmpty {
            return ExtractedData(
                field: .careerInterests,
                value: careers,
                confidence: 0.75,
                rawText: message
            )
        }
        
        return nil
    }
}

// MARK: - Supporting Types

//private struct ExtractedDataCollection {
//    private var items: [ExtractedData] = []
//    
//    mutating func add(_ data: ExtractedData) {
//        items.append(data)
//    }
//    
//    var all: [ExtractedData] { items }
//    var isEmpty: Bool { items.isEmpty }
//    var needsConfirmation: Bool { items.contains { !$0.isHighConfidence } }
//}
