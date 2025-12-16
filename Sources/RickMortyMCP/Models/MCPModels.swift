import Foundation

// MARK: - MCP Initialize

struct InitializeParams: Codable {
    let protocolVersion: String
    let capabilities: ClientCapabilities
    let clientInfo: ClientInfo
}

struct ClientCapabilities: Codable {
    let roots: RootsCapability?
    let sampling: SamplingCapability?

    struct RootsCapability: Codable {
        let listChanged: Bool
    }

    struct SamplingCapability: Codable {}
}

struct ClientInfo: Codable {
    let name: String
    let version: String
}

struct InitializeResult: Codable {
    let protocolVersion: String
    let capabilities: ServerCapabilities
    let serverInfo: ServerInfo
}

struct ServerCapabilities: Codable {
    let tools: ToolsCapability?
    let logging: LoggingCapability?

    struct ToolsCapability: Codable {}
    struct LoggingCapability: Codable {}
}

struct ServerInfo: Codable {
    let name: String
    let version: String
}

// MARK: - MCP Tools

struct Tool: Codable {
    let name: String
    let description: String
    let inputSchema: InputSchema
}

struct InputSchema: Codable {
    let type: String
    let properties: [String: PropertySchema]?
    let required: [String]?
}

struct PropertySchema: Codable {
    let type: String
    let description: String?
    let enumValues: [String]?

    enum CodingKeys: String, CodingKey {
        case type, description
        case enumValues = "enum"
    }
}

struct ToolsListResult: Codable {
    let tools: [Tool]
}

// MARK: - MCP Tool Call

struct ToolCallParams: Codable {
    let name: String
    let arguments: [String: JSONValue]?
}

struct ToolCallResult: Codable {
    let content: [Content]
    let isError: Bool

    struct Content: Codable {
        let type: String
        let text: String
    }
}

// Helper methods
extension ToolCallResult {
    static func success(text: String) -> ToolCallResult {
        return ToolCallResult(
            content: [Content(type: "text", text: text)],
            isError: false
        )
    }

    static func error(text: String) -> ToolCallResult {
        return ToolCallResult(
            content: [Content(type: "text", text: text)],
            isError: true
        )
    }
}
