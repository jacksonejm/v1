import Foundation

/// Represents the current state of the conversation
enum ConversationState: Equatable {
    case idle
    case active
    case processing
    case waitingForUser
    case waitingForConfirmation(data: ExtractedData)
    case error(message: String)
    case completed
    
    var isInteractive: Bool {
        switch self {
        case .active, .waitingForUser, .waitingForConfirmation:
            return true
        default:
            return false
        }
    }
    
    var statusMessage: String? {
        switch self {
        case .idle:
            return nil
        case .active:
            return "Active"
        case .processing:
            return "Thinking..."
        case .waitingForUser:
            return "Waiting for your response"
        case .waitingForConfirmation:
            return "Please confirm"
        case .error(let message):
            return "Error: \(message)"
        case .completed:
            return "Completed"
        }
    }
}