import Foundation

struct ToolDefinitions {
    static func allTools() -> [Tool] {
        return [
            // Character Tools
            Tool(
                name: "get_character",
                description: "Get a single character by ID from Rick and Morty universe",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "id": PropertySchema(type: "number", description: "Character ID (1-826)", enumValues: nil)
                    ],
                    required: ["id"]
                )
            ),
            Tool(
                name: "search_characters",
                description: "Search for characters with optional filters",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "name": PropertySchema(type: "string", description: "Filter by character name", enumValues: nil),
                        "status": PropertySchema(type: "string", description: "Filter by status", enumValues: ["alive", "dead", "unknown"]),
                        "species": PropertySchema(type: "string", description: "Filter by species", enumValues: nil),
                        "type": PropertySchema(type: "string", description: "Filter by type", enumValues: nil),
                        "gender": PropertySchema(type: "string", description: "Filter by gender", enumValues: ["female", "male", "genderless", "unknown"]),
                        "page": PropertySchema(type: "number", description: "Page number for pagination (default: 1)", enumValues: nil)
                    ],
                    required: nil
                )
            ),
            Tool(
                name: "get_multiple_characters",
                description: "Get multiple characters by their IDs",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "ids": PropertySchema(type: "array", description: "Array of character IDs", enumValues: nil)
                    ],
                    required: ["ids"]
                )
            ),
            Tool(
                name: "get_all_characters_pages",
                description: "Get paginated list of all characters",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "page": PropertySchema(type: "number", description: "Page number (default: 1)", enumValues: nil)
                    ],
                    required: nil
                )
            ),
            // Location Tools
            Tool(
                name: "get_location",
                description: "Get a single location by ID",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "id": PropertySchema(type: "number", description: "Location ID", enumValues: nil)
                    ],
                    required: ["id"]
                )
            ),
            Tool(
                name: "search_locations",
                description: "Search for locations with optional filters",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "name": PropertySchema(type: "string", description: "Filter by location name", enumValues: nil),
                        "type": PropertySchema(type: "string", description: "Filter by type", enumValues: nil),
                        "dimension": PropertySchema(type: "string", description: "Filter by dimension", enumValues: nil),
                        "page": PropertySchema(type: "number", description: "Page number for pagination (default: 1)", enumValues: nil)
                    ],
                    required: nil
                )
            ),
            Tool(
                name: "get_multiple_locations",
                description: "Get multiple locations by their IDs",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "ids": PropertySchema(type: "array", description: "Array of location IDs", enumValues: nil)
                    ],
                    required: ["ids"]
                )
            ),
            Tool(
                name: "get_all_locations_pages",
                description: "Get paginated list of all locations",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "page": PropertySchema(type: "number", description: "Page number (default: 1)", enumValues: nil)
                    ],
                    required: nil
                )
            ),
            // Episode Tools
            Tool(
                name: "get_episode",
                description: "Get a single episode by ID",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "id": PropertySchema(type: "number", description: "Episode ID", enumValues: nil)
                    ],
                    required: ["id"]
                )
            ),
            Tool(
                name: "search_episodes",
                description: "Search for episodes with optional filters",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "name": PropertySchema(type: "string", description: "Filter by episode name", enumValues: nil),
                        "episode": PropertySchema(type: "string", description: "Filter by episode code (e.g., S01E01)", enumValues: nil),
                        "page": PropertySchema(type: "number", description: "Page number for pagination (default: 1)", enumValues: nil)
                    ],
                    required: nil
                )
            ),
            Tool(
                name: "get_multiple_episodes",
                description: "Get multiple episodes by their IDs",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "ids": PropertySchema(type: "array", description: "Array of episode IDs", enumValues: nil)
                    ],
                    required: ["ids"]
                )
            ),
            Tool(
                name: "get_all_episodes_pages",
                description: "Get paginated list of all episodes",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "page": PropertySchema(type: "number", description: "Page number (default: 1)", enumValues: nil)
                    ],
                    required: nil
                )
            ),
            // Utility Tools
            Tool(
                name: "get_character_episodes",
                description: "Get all episodes where a character appears",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "character_id": PropertySchema(type: "number", description: "Character ID", enumValues: nil)
                    ],
                    required: ["character_id"]
                )
            ),
            Tool(
                name: "get_location_residents",
                description: "Get all characters residing in a location",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "location_id": PropertySchema(type: "number", description: "Location ID", enumValues: nil)
                    ],
                    required: ["location_id"]
                )
            ),
            Tool(
                name: "get_episode_characters",
                description: "Get all characters in an episode",
                inputSchema: InputSchema(
                    type: "object",
                    properties: [
                        "episode_id": PropertySchema(type: "number", description: "Episode ID", enumValues: nil)
                    ],
                    required: ["episode_id"]
                )
            )
        ]
    }
}
