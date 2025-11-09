import Foundation

struct Conversation: Identifiable, Codable {
    let id: UUID
    let userId: String?
    let startTimestamp: Date
    var lastUpdateTimestamp: Date
    var messages: [ChatMessage]
    var step: String  // Current onboarding step
    var status: ConversationStatus
    
    init(id: UUID = UUID(),
         userId: String? = nil,
         startTimestamp: Date = Date(),
         lastUpdateTimestamp: Date = Date(),
         messages: [ChatMessage] = [],
         step: String = "",
         status: ConversationStatus = .active) {
        self.id = id
        self.userId = userId
        self.startTimestamp = startTimestamp
        self.lastUpdateTimestamp = lastUpdateTimestamp
        self.messages = messages
        self.step = step
        self.status = status
    }
    
    enum ConversationStatus: String, Codable {
        case active
        case completed
        case error
    }
}