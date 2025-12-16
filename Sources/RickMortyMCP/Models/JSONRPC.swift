import Foundation

// MARK: - JSON-RPC 2.0 Request

struct JSONRPCRequest: Codable {
    let jsonrpc: String
    let id: JSONRPCId?
    let method: String
    let params: JSONValue?

    init(jsonrpc: String = "2.0", id: JSONRPCId? = nil, method: String, params: JSONValue? = nil) {
        self.jsonrpc = jsonrpc
        self.id = id
        self.method = method
        self.params = params
    }
}

// MARK: - JSON-RPC 2.0 Response

struct JSONRPCResponse: Codable {
    let jsonrpc: String
    let id: JSONRPCId?
    let result: JSONValue?
    let error: JSONRPCError?

    init(jsonrpc: String = "2.0", id: JSONRPCId? = nil, result: JSONValue? = nil, error: JSONRPCError? = nil) {
        self.jsonrpc = jsonrpc
        self.id = id
        self.result = result
        self.error = error
    }

    static func success(id: JSONRPCId?, result: JSONValue) -> JSONRPCResponse {
        return JSONRPCResponse(id: id, result: result, error: nil)
    }

    static func failure(id: JSONRPCId?, error: JSONRPCError) -> JSONRPCResponse {
        return JSONRPCResponse(id: id, result: nil, error: error)
    }
}

// MARK: - JSON-RPC ID

enum JSONRPCId: Codable, Equatable {
    case string(String)
    case number(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .number(intValue)
        } else {
            throw DecodingError.typeMismatch(
                JSONRPCId.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "ID must be string or number")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        }
    }
}

// MARK: - JSON-RPC Error

struct JSONRPCError: Codable {
    let code: Int
    let message: String
    let data: JSONValue?

    init(code: Int, message: String, data: JSONValue? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }

    // Standard JSON-RPC 2.0 errors
    static func parseError(details: String? = nil) -> JSONRPCError {
        let data = details.map { JSONValue.string($0) }
        return JSONRPCError(code: -32700, message: "Parse error", data: data)
    }

    static func invalidRequest(details: String? = nil) -> JSONRPCError {
        let data = details.map { JSONValue.string($0) }
        return JSONRPCError(code: -32600, message: "Invalid Request", data: data)
    }

    static func methodNotFound(method: String) -> JSONRPCError {
        return JSONRPCError(code: -32601, message: "Method not found", data: .string(method))
    }

    static func invalidParams(details: String) -> JSONRPCError {
        return JSONRPCError(code: -32602, message: "Invalid params", data: .string(details))
    }

    static func internalError(details: String? = nil) -> JSONRPCError {
        let data = details.map { JSONValue.string($0) }
        return JSONRPCError(code: -32603, message: "Internal error", data: data)
    }
}

// MARK: - Generic JSON Value

enum JSONValue: Codable, Equatable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .number(Double(int))
        } else if let double = try? container.decode(Double.self) {
            self = .number(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.typeMismatch(
                JSONValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON type")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }

    var object: [String: JSONValue]? {
        if case .object(let dict) = self {
            return dict
        }
        return nil
    }

    subscript(key: String) -> JSONValue? {
        object?[key]
    }
}

extension JSONValue: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}

// Helper extension for encoding Codable types to JSONValue
extension JSONValue {
    static func from<T: Encodable>(_ value: T) throws -> JSONValue {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        let decoder = JSONDecoder()
        return try decoder.decode(JSONValue.self, from: data)
    }
}
