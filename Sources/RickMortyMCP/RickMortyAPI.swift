import Foundation
import Logging

actor RickMortyAPI {
    private let baseURL: String
    private let session: URLSession
    private let logger: Logger

    init(baseURL: String = "https://rickandmortyapi.com/api", logger: Logger) {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpAdditionalHeaders = ["User-Agent": "RickMortyMCP/1.0.0"]
        self.session = URLSession(configuration: configuration)
        self.logger = logger
    }

    // MARK: - Character Methods

    func getCharacter(id: Int) async throws -> Character {
        let url = URL(string: "\(baseURL)/character/\(id)")!
        return try await fetch(url: url)
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
        return try await fetch(url: components.url!)
    }

    func getMultipleCharacters(ids: [Int]) async throws -> [Character] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        let url = URL(string: "\(baseURL)/character/\(idsString)")!
        let result: [Character] = try await fetch(url: url)
        return result
    }

    func getAllCharacters(page: Int = 1) async throws -> PaginatedResponse<Character> {
        let url = URL(string: "\(baseURL)/character?page=\(page)")!
        return try await fetch(url: url)
    }

    // MARK: - Location Methods

    func getLocation(id: Int) async throws -> Location {
        let url = URL(string: "\(baseURL)/location/\(id)")!
        return try await fetch(url: url)
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
        return try await fetch(url: components.url!)
    }

    func getMultipleLocations(ids: [Int]) async throws -> [Location] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        let url = URL(string: "\(baseURL)/location/\(idsString)")!
        let result: [Location] = try await fetch(url: url)
        return result
    }

    func getAllLocations(page: Int = 1) async throws -> PaginatedResponse<Location> {
        let url = URL(string: "\(baseURL)/location?page=\(page)")!
        return try await fetch(url: url)
    }

    // MARK: - Episode Methods

    func getEpisode(id: Int) async throws -> Episode {
        let url = URL(string: "\(baseURL)/episode/\(id)")!
        return try await fetch(url: url)
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
        return try await fetch(url: components.url!)
    }

    func getMultipleEpisodes(ids: [Int]) async throws -> [Episode] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        let url = URL(string: "\(baseURL)/episode/\(idsString)")!
        let result: [Episode] = try await fetch(url: url)
        return result
    }

    func getAllEpisodes(page: Int = 1) async throws -> PaginatedResponse<Episode> {
        let url = URL(string: "\(baseURL)/episode?page=\(page)")!
        return try await fetch(url: url)
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

    private func fetch<T: Codable>(url: URL) async throws -> T {
        logger.info("Fetching URL: \(url.absoluteString)")

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
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
