import Foundation

enum ResponseChunk {
    case start
    case content(text: String)
    case toolCall(tool: String, parameters: [String: Any])
    case toolCallArguments(arguments: String)
    case toolCallEnd
    case end
}