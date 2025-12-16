import Vapor
import Logging

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
defer { app.shutdown() }

let logger = app.logger

logger.info("Starting Rick and Morty MCP Server")

let connectionManager = SSEConnectionManager(logger: logger)
let sseHandler = SSEHandler(connectionManager: connectionManager, logger: logger)
let mcpServer = MCPServer(logger: logger)

app.get("health") { req async -> String in
    let count = await connectionManager.connectionCount()
    return "OK - Active connections: \(count)"
}

app.get("sse") { req async -> Response in
    logger.info("SSE endpoint hit")
    return await sseHandler.handleSSEConnection(req: req)
}

app.post("message") { req async throws -> Response in
    logger.info("Message endpoint hit")

    guard let bodyData = req.body.data else {
        throw Abort(.badRequest, reason: "Missing request body")
    }

    do {
        let decoder = JSONDecoder()
        let jsonrpcRequest = try decoder.decode(JSONRPCRequest.self, from: bodyData)

        logger.info("Received JSON-RPC request: \(jsonrpcRequest.method)")

        let jsonrpcResponse = await mcpServer.handleJSONRPCRequest(jsonrpcRequest)

        let encoder = JSONEncoder()
        let responseData = try encoder.encode(jsonrpcResponse)

        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")

        return Response(
            status: .ok,
            headers: headers,
            body: .init(data: responseData)
        )
    } catch let decodingError as DecodingError {
        logger.error("JSON parsing error: \(decodingError)")

        let errorResponse = JSONRPCResponse.failure(
            id: nil,
            error: .parseError(details: "Invalid JSON: \(decodingError.localizedDescription)")
        )

        let encoder = JSONEncoder()
        let responseData = try encoder.encode(errorResponse)

        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")

        return Response(
            status: .ok,
            headers: headers,
            body: .init(data: responseData)
        )
    } catch {
        logger.error("Unexpected error: \(error)")
        throw error
    }
}

let port = Environment.get("PORT").flatMap(Int.init) ?? 3000
app.http.server.configuration.hostname = "0.0.0.0"
app.http.server.configuration.port = port

logger.info("Server configured to listen on 0.0.0.0:\(port)")
logger.info("SSE endpoint: http://0.0.0.0:\(port)/sse")
logger.info("Message endpoint: http://0.0.0.0:\(port)/message")
logger.info("Health endpoint: http://0.0.0.0:\(port)/health")

try app.run()
