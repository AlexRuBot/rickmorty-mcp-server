import Vapor
import Foundation
import Logging

actor MCPServer {
    private let api: RickMortyAPI
    private let toolExecutor: ToolExecutor
    private let logger: Logger
    private var initialized = false

    init(logger: Logger) {
        self.logger = logger
        self.api = RickMortyAPI(logger: logger)
        self.toolExecutor = ToolExecutor(api: api, logger: logger)
    }

    func handleJSONRPCRequest(_ request: JSONRPCRequest) async -> JSONRPCResponse {
        logger.info("Handling JSON-RPC method: \(request.method)")

        switch request.method {
        case "initialize":
            return await handleInitialize(request)
        case "notifications/initialized":
            return await handleInitializedNotification(request)
        case "tools/list":
            return await handleToolsList(request)
        case "tools/call":
            return await handleToolCall(request)
        case "ping":
            return handlePing(request)
        default:
            return JSONRPCResponse.failure(
                id: request.id,
                error: .methodNotFound(method: request.method)
            )
        }
    }

    // MARK: - MCP Protocol Handlers

    private func handleInitialize(_ request: JSONRPCRequest) async -> JSONRPCResponse {
        guard let params = request.params else {
            return JSONRPCResponse.failure(
                id: request.id,
                error: .invalidParams(details: "Missing initialize params")
            )
        }

        do {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            let paramsData = try encoder.encode(params)
            let initParams = try decoder.decode(InitializeParams.self, from: paramsData)

            logger.info("Initializing with client: \(initParams.clientInfo.name) v\(initParams.clientInfo.version)")

            let result = InitializeResult(
                protocolVersion: "2024-11-05",
                capabilities: ServerCapabilities(
                    tools: ServerCapabilities.ToolsCapability(),
                    logging: ServerCapabilities.LoggingCapability()
                ),
                serverInfo: ServerInfo(
                    name: "rickmorty-mcp-server",
                    version: "1.0.0"
                )
            )

            initialized = true

            let resultValue = try JSONValue.from(result)
            return JSONRPCResponse.success(id: request.id, result: resultValue)
        } catch {
            logger.error("Initialize error: \(error)")
            return JSONRPCResponse.failure(
                id: request.id,
                error: .internalError(details: "Failed to initialize: \(error.localizedDescription)")
            )
        }
    }

    private func handleInitializedNotification(_ request: JSONRPCRequest) async -> JSONRPCResponse {
        logger.info("Client initialized notification received")
        return JSONRPCResponse.success(id: request.id, result: .null)
    }

    private func handleToolsList(_ request: JSONRPCRequest) async -> JSONRPCResponse {
        logger.info("Listing tools")

        do {
            let result = ToolsListResult(tools: ToolDefinitions.allTools())
            let resultValue = try JSONValue.from(result)
            return JSONRPCResponse.success(id: request.id, result: resultValue)
        } catch {
            logger.error("Tools list error: \(error)")
            return JSONRPCResponse.failure(
                id: request.id,
                error: .internalError(details: "Failed to list tools: \(error.localizedDescription)")
            )
        }
    }

    private func handleToolCall(_ request: JSONRPCRequest) async -> JSONRPCResponse {
        guard let params = request.params else {
            return JSONRPCResponse.failure(
                id: request.id,
                error: .invalidParams(details: "Missing tool call params")
            )
        }

        do {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            let paramsData = try encoder.encode(params)
            let toolCallParams = try decoder.decode(ToolCallParams.self, from: paramsData)

            logger.info("Calling tool: \(toolCallParams.name)")

            let toolResult = await toolExecutor.execute(
                toolName: toolCallParams.name,
                arguments: toolCallParams.arguments
            )

            let resultValue = try JSONValue.from(toolResult)
            return JSONRPCResponse.success(id: request.id, result: resultValue)
        } catch {
            logger.error("Tool call error: \(error)")
            return JSONRPCResponse.failure(
                id: request.id,
                error: .internalError(details: "Failed to execute tool: \(error.localizedDescription)")
            )
        }
    }

    private func handlePing(_ request: JSONRPCRequest) -> JSONRPCResponse {
        return JSONRPCResponse.success(id: request.id, result: .object(["status": "ok"]))
    }
}
