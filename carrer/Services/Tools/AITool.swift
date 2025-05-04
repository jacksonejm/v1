import Foundation

protocol AITool {
    var name: String { get }
    var description: String { get }
    
    func execute(with parameters: [String: Any]) async throws -> Any
}