import Foundation
import Combine

class OpenAIService {
    // MARK: - Configuration
    private let apiKey: String
    private let model: String
    private let baseURL = "https://api.openai.com/v1"
    
    init() {
        // Load from APIConfig
        self.apiKey = APIConfig.openAIKey ?? ""
        self.model = "gpt-4o"
    }
    
    // MARK: - Stream Response
    func streamResponse(
        messages: [ChatMessage],
        systemPrompt: String
    ) -> AnyPublisher<ResponseChunk, Error> {
        // Convert messages to OpenAI format
        let openAIMessages = formatMessages(messages, systemPrompt: systemPrompt)
        
        // Define tools - we'll implement this later
        let tools: [[String: Any]] = [] // For now, empty
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": model,
            "messages": openAIMessages,
            "tools": tools,
            "stream": true
        ]
        
        // Create request
        guard let url = URL(string: "\(baseURL)/chat/completions"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return Fail(error: APIError.invalidRequest).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Create streaming publisher
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw APIError.requestFailed(statusCode: httpResponse.statusCode, message: String(data: data, encoding: .utf8) ?? "Unknown error")
                }
                
                return data
            }
            .flatMap { data -> AnyPublisher<ResponseChunk, Error> in
                // Split the data by lines (SSE format)
                let lines = String(data: data, encoding: .utf8)?.components(separatedBy: "\n") ?? []
                
                // Process each line
                return lines.publisher
                    .filter { !$0.isEmpty && $0 != "data: [DONE]" }
                    .compactMap { line -> Data? in
                        guard line.hasPrefix("data: ") else { return nil }
                        let jsonString = String(line.dropFirst(6))
                        return jsonString.data(using: .utf8)
                    }
                    .tryMap { jsonData -> ResponseChunk in
                        try self.processChunk(jsonData)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    private func formatMessages(_ messages: [ChatMessage], systemPrompt: String) -> [[String: String]] {
        var formattedMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            formattedMessages.append(["role": role, "content": message.content])
            
            // Add tool results if available
            // We'll implement this later
        }
        
        return formattedMessages
    }
    
    private func processChunk(_ data: Data) throws -> ResponseChunk {
        let decoder = JSONDecoder()
        
        struct StreamResponse: Decodable {
            let id: String
            let choices: [Choice]
            
            struct Choice: Decodable {
                let delta: Delta
                let finishReason: String?
                
                enum CodingKeys: String, CodingKey {
                    case delta
                    case finishReason = "finish_reason"
                }
            }
            
            struct Delta: Decodable {
                let content: String?
                let toolCalls: [ToolCall]?
                
                enum CodingKeys: String, CodingKey {
                    case content
                    case toolCalls = "tool_calls"
                }
            }
            
            struct ToolCall: Decodable {
                let index: Int?
                let id: String?
                let type: String?
                let function: Function
                
                struct Function: Decodable {
                    let name: String?
                    let arguments: String?
                }
            }
        }
        
        do {
            let response = try decoder.decode(StreamResponse.self, from: data)
            
            // Extract the first choice
            if let choice = response.choices.first {
                // Handle tool call
                if let toolCalls = choice.delta.toolCalls, !toolCalls.isEmpty {
                    // Get the tool call
                    let toolCall = toolCalls[0]
                    
                    if let functionName = toolCall.function.name, !functionName.isEmpty {
                        // Parse arguments as JSON
                        let arguments = toolCall.function.arguments ?? "{}"
                        if let argData = arguments.data(using: .utf8),
                           let params = try? JSONSerialization.jsonObject(with: argData) as? [String: Any] {
                            return .toolCall(tool: functionName, parameters: params)
                        }
                        // If we can't parse arguments yet, just return tool name
                        return .toolCall(tool: functionName, parameters: [:])
                    }
                    
                    // Update partial tool call with new arguments
                    if let arguments = toolCall.function.arguments, !arguments.isEmpty {
                        return .toolCallArguments(arguments: arguments)
                    }
                }
                
                // Handle content
                if let content = choice.delta.content, !content.isEmpty {
                    return .content(text: content)
                }
                
                // Handle end of response
                if choice.finishReason == "stop" {
                    return .end
                } else if choice.finishReason == "tool_calls" {
                    return .toolCallEnd
                }
                
                // If we're at the start of the response
                if response.choices.first?.delta.content == nil &&
                   response.choices.first?.delta.toolCalls == nil {
                    return .start
                }
            }
            
            // Default to empty content chunk if unable to parse
            return .content(text: "")
        } catch {
            print("Error decoding chunk: \(error)")
            return .start // Default fallback
        }
    }
    
    // MARK: - Errors
    enum APIError: Error, LocalizedError {
        case invalidRequest
        case invalidResponse
        case requestFailed(statusCode: Int, message: String)
        case decodingFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidRequest:
                return "Invalid request"
            case .invalidResponse:
                return "Invalid response"
            case .requestFailed(let statusCode, let message):
                return "Request failed with status \(statusCode): \(message)"
            case .decodingFailed:
                return "Failed to decode response"
            }
        }
    }
}