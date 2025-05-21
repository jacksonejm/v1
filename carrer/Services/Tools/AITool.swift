import Foundation

protocol AITool {
    var name: String { get }
    var description: String { get }
    /// JSON schema for the tool parameters
    var parametersSchema: [String: Any] { get }

    func execute(with parameters: [String: Any]) async throws -> Any
}
