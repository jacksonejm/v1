import Foundation

/// Generates contextual responses for the conversational onboarding
class ContextualResponseGenerator {
    
    // MARK: - Response Templates
    
    private let acknowledgments = [
        "Great!",
        "Perfect!",
        "Excellent!",
        "Wonderful!",
        "That's great!",
        "Awesome!",
        "Got it!",
        "Thanks for sharing!"
    ]
    
    private let transitions = [
        "Now,",
        "Next,",
        "Moving on,",
        "Let's talk about",
        "I'd like to know about"
    ]
    
    // MARK: - Public Methods
    
    /// Generate a contextual response based on the current phase and extracted data
    func generate(
        for phase: ConversationPhase,
        with collectedData: OnboardingData,
        basedOn extractedData: ExtractedDataCollection,
        context: ConversationContext? = nil
    ) async -> String {
        // Start with acknowledgment if we extracted data
        var response = ""
        if !extractedData.isEmpty {
            response = generateAcknowledgment(for: extractedData, context: context)
        }
        
        // Add phase-specific response
        switch phase {
        case .confirmingName:
            response += generateNameConfirmationResponse(collectedData)
        case .askingReferralSource:
            response += generateReferralResponse(extractedData)
        case .askingCurrentStatus:
            response += generateStatusResponse(extractedData)
        case .askingEducationLevel:
            response += generateEducationResponse(extractedData)
        case .exploringInterests:
            response += generateInterestsResponse(extractedData, collectedData)
        case .discussingSubjects:
            response += generateSubjectsResponse(extractedData, collectedData)
        case .exploringActivities:
            response += generateActivitiesResponse(extractedData, collectedData)
        case .exploringCareers:
            response += generateCareersResponse(extractedData, collectedData)
        case .reviewingProfile:
            response = generateProfileReview(collectedData)
        default:
            response += generateGenericResponse(phase, collectedData)
        }
        
        return response
    }
    
    // MARK: - Acknowledgment Generation
    
    private func generateAcknowledgment(for extractedData: ExtractedDataCollection, context: ConversationContext? = nil) -> String {
        // Use context to make acknowledgments more varied and contextual
        if let context = context {
            switch context.userPreferences.communicationStyle {
            case .concise:
                return "Got it. "
            case .detailed:
                let acknowledgment = acknowledgments.randomElement() ?? "Great!"
                return "\(acknowledgment) Thank you for sharing that with me. "
            case .balanced:
                let acknowledgment = acknowledgments.randomElement() ?? "Great!"
                return "\(acknowledgment) "
            }
        }
        
        let acknowledgment = acknowledgments.randomElement() ?? "Great!"
        return "\(acknowledgment) "
    }
    
    // MARK: - Phase-Specific Responses
    
    private func generateNameConfirmationResponse(_ data: OnboardingData) -> String {
        if let name = data.firstName {
            return "Nice to meet you, \(name)! I'm excited to help you explore career paths that match your interests and strengths."
        }
        return "I'm excited to help you explore career paths that match your interests and strengths."
    }
    
    private func generateReferralResponse(_ extractedData: ExtractedDataCollection) -> String {
        if let referralData = extractedData.all.first(where: { $0.field == .howDidYouHearAboutUs }),
           let source = referralData.value as? String {
            switch source {
            case "friend":
                return "It's great when friends share helpful resources! "
            case "family":
                return "Family support is so important in career exploration! "
            case "school":
                return "Your school wants to help you succeed - that's wonderful! "
            case "social media":
                return "Glad you found us online! "
            default:
                return ""
            }
        }
        return ""
    }
    
    private func generateStatusResponse(_ extractedData: ExtractedDataCollection) -> String {
        if let statusData = extractedData.all.first(where: { $0.field == .currentStatus }),
           let status = statusData.value as? String {
            switch status {
            case "Student":
                return "Being a student is an exciting time to explore your future! "
            case "Working":
                return "It's great that you're already in the workforce! "
            case "Both":
                return "Balancing work and studies shows great dedication! "
            default:
                return ""
            }
        }
        return ""
    }
    
    private func generateEducationResponse(_ extractedData: ExtractedDataCollection) -> String {
        if let eduData = extractedData.all.first(where: { $0.field == .studentLevel }),
           let level = eduData.value as? String {
            switch level {
            case "High School":
                return "High school is a perfect time to start thinking about your future career! "
            case "College":
                return "College opens up so many possibilities for your career path! "
            case "Graduate":
                return "Graduate studies really help you specialize in your field! "
            default:
                return ""
            }
        }
        return ""
    }
    
    private func generateInterestsResponse(_ extractedData: ExtractedDataCollection, _ data: OnboardingData) -> String {
        if let interestsData = extractedData.all.first(where: { $0.field == .interests }),
           let interests = interestsData.value as? [String], !interests.isEmpty {
            let interestList = formatList(interests)
            return "I love that you're interested in \(interestList)! These interests can lead to some exciting career paths. "
        }
        return "Understanding your interests helps me suggest careers you'll truly enjoy. "
    }
    
    private func generateSubjectsResponse(_ extractedData: ExtractedDataCollection, _ data: OnboardingData) -> String {
        if let subjectsData = extractedData.all.first(where: { $0.field == .favoriteSubjects }),
           let subjects = subjectsData.value as? [String], !subjects.isEmpty {
            let subjectList = formatList(subjects)
            
            // Connect subjects to potential careers
            var connection = ""
            if subjects.contains(where: { $0.contains("math") || $0.contains("science") }) {
                connection = "Your strength in STEM subjects opens doors to many technical careers! "
            } else if subjects.contains(where: { $0.contains("english") || $0.contains("writing") }) {
                connection = "Your love for language arts could lead to creative or communication-focused careers! "
            }
            
            return "Excellent choices with \(subjectList)! \(connection)"
        }
        return "Your favorite subjects often point to your natural strengths. "
    }
    
    private func generateActivitiesResponse(_ extractedData: ExtractedDataCollection, _ data: OnboardingData) -> String {
        if let activitiesData = extractedData.all.first(where: { $0.field == .extracurriculars }),
           let activities = activitiesData.value as? [String], !activities.isEmpty {
            let activityList = formatList(activities)
            return "Your involvement in \(activityList) shows great initiative! These activities help develop important skills for your future career. "
        }
        return "Activities outside of academics help you develop well-rounded skills. "
    }
    
    private func generateCareersResponse(_ extractedData: ExtractedDataCollection, _ data: OnboardingData) -> String {
        if let careersData = extractedData.all.first(where: { $0.field == .careerInterests }),
           let careers = careersData.value as? [String], !careers.isEmpty {
            let careerList = formatList(careers)
            return "Those are exciting career interests! \(careerList) could be great matches based on what you've told me. "
        }
        return "Let's explore some career options that align with your interests and strengths. "
    }
    
    private func generateProfileReview(_ data: OnboardingData) -> String {
        var review = "Let me summarize what I've learned about you:\n\n"
        
        if let name = data.fullName {
            review += "• Name: \(name)\n"
        }
        if let status = data.currentStatus {
            review += "• Current Status: \(status)\n"
        }
        if let education = data.educationLevel {
            review += "• Education Level: \(education)\n"
        }
        if !data.interests.isEmpty {
            review += "• Interests: \(formatList(Array(data.interests)))\n"
        }
        if !data.favoriteSubjects.isEmpty {
            review += "• Favorite Subjects: \(formatList(Array(data.favoriteSubjects)))\n"
        }
        if !data.extracurriculars.isEmpty {
            review += "• Activities: \(formatList(Array(data.extracurriculars)))\n"
        }
        if !data.careerInterests.isEmpty {
            review += "• Career Interests: \(formatList(Array(data.careerInterests)))\n"
        }
        
        review += "\nDoes everything look correct?"
        return review
    }
    
    private func generateGenericResponse(_ phase: ConversationPhase, _ data: OnboardingData) -> String {
        // Fallback to the phase's prompt template
        return personalizePrompt(phase.promptTemplate, with: data)
    }
    
    // MARK: - Helper Methods
    
    private func formatList(_ items: [String]) -> String {
        switch items.count {
        case 0:
            return ""
        case 1:
            return items[0]
        case 2:
            return "\(items[0]) and \(items[1])"
        default:
            let allButLast = items.dropLast().joined(separator: ", ")
            return "\(allButLast), and \(items.last!)"
        }
    }
    
    private func personalizePrompt(_ template: String, with data: OnboardingData) -> String {
        var prompt = template
        
        if let name = data.firstName {
            prompt = prompt.replacingOccurrences(of: "{name}", with: name)
        }
        
        return prompt
    }
    
    // MARK: - Clarification Responses
    
    func generateClarificationResponse(for phase: ConversationPhase) -> String {
        switch phase {
        case .gettingName:
            return "Could you tell me your name? You can just type your first name, or your full name if you'd like."
        case .askingReferralSource:
            return "How did you find out about MyPath? Was it through a friend, family, school, or somewhere else?"
        case .askingCurrentStatus:
            return "Are you currently a student, working, doing both, or neither?"
        case .askingEducationLevel:
            return "What level of education are you at? For example: high school, college, or graduate school?"
        case .exploringInterests:
            return "What kinds of things interest you? This could be subjects, hobbies, or activities you enjoy."
        default:
            return "I didn't quite understand that. Could you tell me more?"
        }
    }
    
    // MARK: - Error Responses
    
    func generateErrorResponse() -> String {
        let responses = [
            "I'm having a bit of trouble understanding. Let's try again.",
            "Sorry, I didn't catch that. Could you rephrase?",
            "I want to make sure I understand you correctly. Could you say that differently?"
        ]
        return responses.randomElement() ?? responses[0]
    }
}