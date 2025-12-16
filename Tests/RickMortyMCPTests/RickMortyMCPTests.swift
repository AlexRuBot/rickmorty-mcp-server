import XCTest
@testable import RickMortyMCP

final class CharacterTests: XCTestCase {
    func testCharacterDecoding() throws {
        let json = """
        {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "type": "",
            "gender": "Male",
            "origin": {
                "name": "Earth (C-137)",
                "url": "https://rickandmortyapi.com/api/location/1"
            },
            "location": {
                "name": "Citadel of Ricks",
                "url": "https://rickandmortyapi.com/api/location/3"
            },
            "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            "episode": [
                "https://rickandmortyapi.com/api/episode/1",
                "https://rickandmortyapi.com/api/episode/2"
            ],
            "url": "https://rickandmortyapi.com/api/character/1",
            "created": "2017-11-04T18:48:46.250Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let character = try decoder.decode(Character.self, from: json)

        XCTAssertEqual(character.id, 1)
        XCTAssertEqual(character.name, "Rick Sanchez")
        XCTAssertEqual(character.status, "Alive")
        XCTAssertEqual(character.species, "Human")
    }
}

final class JSONRPCTests: XCTestCase {
    func testJSONRPCRequestEncoding() throws {
        let request = JSONRPCRequest(
            id: .number(1),
            method: "initialize",
            params: .object(["test": "value"])
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(request)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(JSONRPCRequest.self, from: data)

        XCTAssertEqual(decoded.method, "initialize")
        XCTAssertEqual(decoded.id, .number(1))
    }

    func testJSONRPCErrorResponse() throws {
        let error = JSONRPCError.invalidParams(details: "Missing parameter: id")
        let response = JSONRPCResponse.failure(id: .number(1), error: error)

        XCTAssertEqual(response.error?.code, -32602)
        XCTAssertEqual(response.error?.message, "Invalid params")
    }
}
