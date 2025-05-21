import Foundation

class ToolRegistry {
    static let shared = ToolRegistry()

    private var tools: [String: AITool] = [:]

    private init() {
        // Register tools
    }
    
    func registerTool(_ tool: AITool) {
        tools[tool.name] = tool
    }
    
    func getTool(named name: String) -> AITool? {
        return tools[name]
    }
    
    func getAllTools() -> [AITool] {
        return Array(tools.values)
    }

    /// Return tool definitions in OpenAI function format
    func getToolDefinitions() -> [[String: Any]] {
        tools.values.map { tool in
            [
                "type": "function",
                "function": [
                    "name": tool.name,
                    "description": tool.description,
                    "parameters": tool.parametersSchema
                ]
            ]
        }
    }
}
