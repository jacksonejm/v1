import Foundation

enum ToolError: Error, LocalizedError {
    case invalidParameters(message: String)
    case executionFailed(message: String)
    case notFound(tool: String)
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidParameters(let message):
            return "Invalid parameters: \(message)"
        case .executionFailed(let message):
            return "Tool execution failed: \(message)"
        case .notFound(let tool):
            return "Tool not found: \(tool)"
        case .notImplemented:
            return "This feature is not yet implemented"
        }
    }
}