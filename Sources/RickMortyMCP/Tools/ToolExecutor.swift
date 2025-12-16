import Foundation
import Logging

actor ToolExecutor {
    private let api: RickMortyAPI
    private let logger: Logger

    init(api: RickMortyAPI, logger: Logger) {
        self.api = api
        self.logger = logger
    }

    func execute(toolName: String, arguments: [String: JSONValue]?) async -> ToolCallResult {
        logger.info("Executing tool: \(toolName) with arguments: \(String(describing: arguments))")

        do {
            let result = try await executeTool(name: toolName, arguments: arguments ?? [:])
            return result
        } catch let error as APIError {
            logger.error("API Error: \(error.description)")
            return ToolCallResult.error(text: error.description)
        } catch {
            logger.error("Unexpected error: \(error)")
            return ToolCallResult.error(text: "Unexpected error: \(error.localizedDescription)")
        }
    }

    private func executeTool(name: String, arguments: [String: JSONValue]) async throws -> ToolCallResult {
        switch name {
        // Character Tools
        case "get_character":
            guard let id = extractInt(from: arguments, key: "id") else {
                throw ToolError.missingParameter("id")
            }
            let character = try await api.getCharacter(id: id)
            return try ToolCallResult.success(text: encodeToJSON(character))

        case "search_characters":
            let name = extractString(from: arguments, key: "name")
            let status = extractString(from: arguments, key: "status")
            let species = extractString(from: arguments, key: "species")
            let type = extractString(from: arguments, key: "type")
            let gender = extractString(from: arguments, key: "gender")
            let page = extractInt(from: arguments, key: "page") ?? 1
            let result = try await api.searchCharacters(
                name: name,
                status: status,
                species: species,
                type: type,
                gender: gender,
                page: page
            )
            return try ToolCallResult.success(text: encodeToJSON(result))

        case "get_multiple_characters":
            guard let ids = extractIntArray(from: arguments, key: "ids") else {
                throw ToolError.missingParameter("ids")
            }
            let characters = try await api.getMultipleCharacters(ids: ids)
            return try ToolCallResult.success(text: encodeToJSON(characters))

        case "get_all_characters_pages":
            let page = extractInt(from: arguments, key: "page") ?? 1
            let result = try await api.getAllCharacters(page: page)
            return try ToolCallResult.success(text: encodeToJSON(result))

        // Location Tools
        case "get_location":
            guard let id = extractInt(from: arguments, key: "id") else {
                throw ToolError.missingParameter("id")
            }
            let location = try await api.getLocation(id: id)
            return try ToolCallResult.success(text: encodeToJSON(location))

        case "search_locations":
            let name = extractString(from: arguments, key: "name")
            let type = extractString(from: arguments, key: "type")
            let dimension = extractString(from: arguments, key: "dimension")
            let page = extractInt(from: arguments, key: "page") ?? 1
            let result = try await api.searchLocations(
                name: name,
                type: type,
                dimension: dimension,
                page: page
            )
            return try ToolCallResult.success(text: encodeToJSON(result))

        case "get_multiple_locations":
            guard let ids = extractIntArray(from: arguments, key: "ids") else {
                throw ToolError.missingParameter("ids")
            }
            let locations = try await api.getMultipleLocations(ids: ids)
            return try ToolCallResult.success(text: encodeToJSON(locations))

        case "get_all_locations_pages":
            let page = extractInt(from: arguments, key: "page") ?? 1
            let result = try await api.getAllLocations(page: page)
            return try ToolCallResult.success(text: encodeToJSON(result))

        // Episode Tools
        case "get_episode":
            guard let id = extractInt(from: arguments, key: "id") else {
                throw ToolError.missingParameter("id")
            }
            let episode = try await api.getEpisode(id: id)
            return try ToolCallResult.success(text: encodeToJSON(episode))

        case "search_episodes":
            let name = extractString(from: arguments, key: "name")
            let episode = extractString(from: arguments, key: "episode")
            let page = extractInt(from: arguments, key: "page") ?? 1
            let result = try await api.searchEpisodes(
                name: name,
                episode: episode,
                page: page
            )
            return try ToolCallResult.success(text: encodeToJSON(result))

        case "get_multiple_episodes":
            guard let ids = extractIntArray(from: arguments, key: "ids") else {
                throw ToolError.missingParameter("ids")
            }
            let episodes = try await api.getMultipleEpisodes(ids: ids)
            return try ToolCallResult.success(text: encodeToJSON(episodes))

        case "get_all_episodes_pages":
            let page = extractInt(from: arguments, key: "page") ?? 1
            let result = try await api.getAllEpisodes(page: page)
            return try ToolCallResult.success(text: encodeToJSON(result))

        // Utility Tools
        case "get_character_episodes":
            guard let characterId = extractInt(from: arguments, key: "character_id") else {
                throw ToolError.missingParameter("character_id")
            }
            let episodes = try await api.getCharacterEpisodes(characterId: characterId)
            return try ToolCallResult.success(text: encodeToJSON(episodes))

        case "get_location_residents":
            guard let locationId = extractInt(from: arguments, key: "location_id") else {
                throw ToolError.missingParameter("location_id")
            }
            let characters = try await api.getLocationResidents(locationId: locationId)
            return try ToolCallResult.success(text: encodeToJSON(characters))

        case "get_episode_characters":
            guard let episodeId = extractInt(from: arguments, key: "episode_id") else {
                throw ToolError.missingParameter("episode_id")
            }
            let characters = try await api.getEpisodeCharacters(episodeId: episodeId)
            return try ToolCallResult.success(text: encodeToJSON(characters))

        default:
            throw ToolError.unknownTool(name)
        }
    }

    // MARK: - Helper Methods

    private func extractInt(from arguments: [String: JSONValue], key: String) -> Int? {
        guard let value = arguments[key] else { return nil }
        if case .number(let num) = value {
            return Int(num)
        }
        return nil
    }

    private func extractString(from arguments: [String: JSONValue], key: String) -> String? {
        guard let value = arguments[key] else { return nil }
        if case .string(let str) = value {
            return str
        }
        return nil
    }

    private func extractIntArray(from arguments: [String: JSONValue], key: String) -> [Int]? {
        guard let value = arguments[key] else { return nil }
        if case .array(let arr) = value {
            return arr.compactMap { item in
                if case .number(let num) = item {
                    return Int(num)
                }
                return nil
            }
        }
        return nil
    }

    private func encodeToJSON<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(value)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw ToolError.encodingError
        }
        return jsonString
    }
}

enum ToolError: Error, CustomStringConvertible {
    case unknownTool(String)
    case missingParameter(String)
    case invalidParameterType(String)
    case encodingError

    var description: String {
        switch self {
        case .unknownTool(let name):
            return "Unknown tool: \(name)"
        case .missingParameter(let param):
            return "Missing required parameter: \(param)"
        case .invalidParameterType(let param):
            return "Invalid type for parameter: \(param)"
        case .encodingError:
            return "Failed to encode result to JSON"
        }
    }
}
