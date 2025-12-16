import Vapor
import Logging

actor RickMortyAPI {
    private let baseURL: String
    private let client: Client
    private let logger: Logger

    init(baseURL: String = "https://rickandmortyapi.com/api", client: Client, logger: Logger) {
        self.baseURL = baseURL
        self.client = client
        self.logger = logger
    }

    // MARK: - Character Methods

    func getCharacter(id: Int) async throws -> Character {
        let uri = URI(string: "\(baseURL)/character/\(id)")
        return try await fetch(uri: uri)
    }

    func searchCharacters(
        name: String? = nil,
        status: String? = nil,
        species: String? = nil,
        type: String? = nil,
        gender: String? = nil,
        page: Int = 1
    ) async throws -> PaginatedResponse<Character> {
        var components = URLComponents(string: "\(baseURL)/character")!
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "page", value: "\(page)")]

        if let name = name { queryItems.append(URLQueryItem(name: "name", value: name)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        if let species = species { queryItems.append(URLQueryItem(name: "species", value: species)) }
        if let type = type { queryItems.append(URLQueryItem(name: "type", value: type)) }
        if let gender = gender { queryItems.append(URLQueryItem(name: "gender", value: gender)) }

        components.queryItems = queryItems
        let uri = URI(string: components.url!.absoluteString)
        return try await fetch(uri: uri)
    }

    func getMultipleCharacters(ids: [Int]) async throws -> [Character] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        let uri = URI(string: "\(baseURL)/character/\(idsString)")
        let result: [Character] = try await fetch(uri: uri)
        return result
    }

    func getAllCharacters(page: Int = 1) async throws -> PaginatedResponse<Character> {
        let uri = URI(string: "\(baseURL)/character?page=\(page)")
        return try await fetch(uri: uri)
    }

    // MARK: - Location Methods

    func getLocation(id: Int) async throws -> Location {
        let uri = URI(string: "\(baseURL)/location/\(id)")
        return try await fetch(uri: uri)
    }

    func searchLocations(
        name: String? = nil,
        type: String? = nil,
        dimension: String? = nil,
        page: Int = 1
    ) async throws -> PaginatedResponse<Location> {
        var components = URLComponents(string: "\(baseURL)/location")!
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "page", value: "\(page)")]

        if let name = name { queryItems.append(URLQueryItem(name: "name", value: name)) }
        if let type = type { queryItems.append(URLQueryItem(name: "type", value: type)) }
        if let dimension = dimension { queryItems.append(URLQueryItem(name: "dimension", value: dimension)) }

        components.queryItems = queryItems
        let uri = URI(string: components.url!.absoluteString)
        return try await fetch(uri: uri)
    }

    func getMultipleLocations(ids: [Int]) async throws -> [Location] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        let uri = URI(string: "\(baseURL)/location/\(idsString)")
        let result: [Location] = try await fetch(uri: uri)
        return result
    }

    func getAllLocations(page: Int = 1) async throws -> PaginatedResponse<Location> {
        let uri = URI(string: "\(baseURL)/location?page=\(page)")
        return try await fetch(uri: uri)
    }

    // MARK: - Episode Methods

    func getEpisode(id: Int) async throws -> Episode {
        let uri = URI(string: "\(baseURL)/episode/\(id)")
        return try await fetch(uri: uri)
    }

    func searchEpisodes(
        name: String? = nil,
        episode: String? = nil,
        page: Int = 1
    ) async throws -> PaginatedResponse<Episode> {
        var components = URLComponents(string: "\(baseURL)/episode")!
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "page", value: "\(page)")]

        if let name = name { queryItems.append(URLQueryItem(name: "name", value: name)) }
        if let episode = episode { queryItems.append(URLQueryItem(name: "episode", value: episode)) }

        components.queryItems = queryItems
        let uri = URI(string: components.url!.absoluteString)
        return try await fetch(uri: uri)
    }

    func getMultipleEpisodes(ids: [Int]) async throws -> [Episode] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        let uri = URI(string: "\(baseURL)/episode/\(idsString)")
        let result: [Episode] = try await fetch(uri: uri)
        return result
    }

    func getAllEpisodes(page: Int = 1) async throws -> PaginatedResponse<Episode> {
        let uri = URI(string: "\(baseURL)/episode?page=\(page)")
        return try await fetch(uri: uri)
    }

    // MARK: - Utility Methods

    func getCharacterEpisodes(characterId: Int) async throws -> [Episode] {
        let character = try await getCharacter(id: characterId)
        let episodeIds = character.episode.compactMap { url -> Int? in
            guard let id = url.split(separator: "/").last else { return nil }
            return Int(id)
        }

        guard !episodeIds.isEmpty else { return [] }
        return try await getMultipleEpisodes(ids: episodeIds)
    }

    func getLocationResidents(locationId: Int) async throws -> [Character] {
        let location = try await getLocation(id: locationId)
        let residentIds = location.residents.compactMap { url -> Int? in
            guard let id = url.split(separator: "/").last else { return nil }
            return Int(id)
        }

        guard !residentIds.isEmpty else { return [] }
        return try await getMultipleCharacters(ids: residentIds)
    }

    func getEpisodeCharacters(episodeId: Int) async throws -> [Character] {
        let episode = try await getEpisode(id: episodeId)
        let characterIds = episode.characters.compactMap { url -> Int? in
            guard let id = url.split(separator: "/").last else { return nil }
            return Int(id)
        }

        guard !characterIds.isEmpty else { return [] }
        return try await getMultipleCharacters(ids: characterIds)
    }

    // MARK: - Private Helper Methods

    private func fetch<T: Codable>(uri: URI) async throws -> T {
        logger.info("Fetching URI: \(uri.string)")

        let response = try await client.get(uri) { req in
            req.headers.add(name: .userAgent, value: "RickMortyMCP/1.0.0")
        }

        guard response.status == .ok else {
            if response.status == .notFound {
                throw APIError.notFound
            }
            throw APIError.httpError(statusCode: Int(response.status.code))
        }

        do {
            return try response.content.decode(T.self)
        } catch {
            logger.error("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
}

enum APIError: Error, CustomStringConvertible {
    case invalidResponse
    case notFound
    case httpError(statusCode: Int)
    case decodingError(Error)
    case invalidURL

    var description: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .notFound:
            return "Resource not found"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL"
        }
    }
}
