import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    let isUser: Bool
    let timestamp: Date
    var toolResults: [String: Any]?
    
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date(), toolResults: [String: Any]? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.toolResults = toolResults
    }
    
    // Custom Codable implementation for toolResults dictionary
    enum CodingKeys: String, CodingKey {
        case id, content, isUser, timestamp, toolResults
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        isUser = try container.decode(Bool.self, forKey: .isUser)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        if let toolResultsData = try container.decodeIfPresent(Data.self, forKey: .toolResults) {
            toolResults = try JSONSerialization.jsonObject(with: toolResultsData) as? [String: Any]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(isUser, forKey: .isUser)
        try container.encode(timestamp, forKey: .timestamp)
        
        if let toolResults = toolResults {
            let toolResultsData = try JSONSerialization.data(withJSONObject: toolResults)
            try container.encode(toolResultsData, forKey: .toolResults)
        }
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp
        // Note: toolResults is not compared for equality
    }
}