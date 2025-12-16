import Vapor
import Foundation
import Logging

actor SSEConnectionManager {
    private var connections: [UUID: SSEConnection] = [:]
    private let logger: Logger

    struct SSEConnection {
        let id: UUID
        let eventLoop: EventLoop
        var lastActivity: Date
    }

    init(logger: Logger) {
        self.logger = logger
    }

    func addConnection(id: UUID, eventLoop: EventLoop) {
        connections[id] = SSEConnection(id: id, eventLoop: eventLoop, lastActivity: Date())
        logger.info("SSE connection added: \(id)")
    }

    func removeConnection(id: UUID) {
        connections.removeValue(forKey: id)
        logger.info("SSE connection removed: \(id)")
    }

    func updateActivity(id: UUID) {
        if var connection = connections[id] {
            connection.lastActivity = Date()
            connections[id] = connection
        }
    }

    func connectionCount() -> Int {
        return connections.count
    }
}

class SSEHandler {
    private let connectionManager: SSEConnectionManager
    private let logger: Logger

    init(connectionManager: SSEConnectionManager, logger: Logger) {
        self.connectionManager = connectionManager
        self.logger = logger
    }

    func handleSSEConnection(req: Request) async -> Response {
        let connectionId = UUID()
        logger.info("New SSE connection request: \(connectionId)")

        let headers: HTTPHeaders = [
            "Content-Type": "text/event-stream",
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "Access-Control-Allow-Origin": "*"
        ]

        let response = Response(status: .ok, headers: headers)

        await connectionManager.addConnection(id: connectionId, eventLoop: req.eventLoop)

        response.body = .init(stream: { writer in
            req.eventLoop.scheduleRepeatedAsyncTask(
                initialDelay: .seconds(0),
                delay: .seconds(30)
            ) { task -> EventLoopFuture<Void> in
                let heartbeat = self.formatSSEMessage(event: "ping", data: "{}")
                return writer.write(.buffer(.init(string: heartbeat)))
            }
        }, count: nil, byteBufferAllocator: req.byteBufferAllocator)

        req.eventLoop.scheduleTask(deadline: .distantFuture) {
            Task {
                await self.connectionManager.removeConnection(id: connectionId)
            }
        }

        return response
    }

    func sendSSEMessage(response: JSONRPCResponse, writer: some BodyStreamWriter) -> EventLoopFuture<Void> {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(response)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                return writer.eventLoop.makeFailedFuture(SSEError.encodingFailed)
            }

            let message = formatSSEMessage(event: "message", data: jsonString)
            return writer.write(.buffer(.init(string: message)))
        } catch {
            return writer.eventLoop.makeFailedFuture(error)
        }
    }

    private func formatSSEMessage(event: String, data: String) -> String {
        return "event: \(event)\ndata: \(data)\n\n"
    }
}

enum SSEError: Error {
    case encodingFailed
    case connectionClosed
}
