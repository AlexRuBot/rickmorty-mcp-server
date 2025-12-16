# Промт для Claude Code: Rick and Morty MCP Server на Swift

Create a Model Context Protocol (MCP) server in Swift that provides access to the Rick and Morty API (https://rickandmortyapi.com/documentation).

## Project Requirements:

### 1. Technology Stack
- Language: Swift 5.9+
- Transport: SSE (Server-Sent Events) over HTTP
- HTTP Client: URLSession or AsyncHTTPClient
- JSON parsing: Codable
- Server framework: Vapor or similar async HTTP framework
- Deployment: Docker container

### 2. MCP Server Implementation

#### 2.1 MCP Protocol Overview

The Model Context Protocol (MCP) is a JSON-RPC 2.0 based protocol that enables communication between clients (like Claude API) and servers providing tools/resources.

**Core Concepts:**
- Server exposes tools that clients can discover and invoke
- Communication uses JSON-RPC 2.0 request/response format
- SSE (Server-Sent Events) transport for server-to-client messages
- HTTP POST for client-to-server requests

#### 2.2 SSE Transport Implementation

**Endpoint Structure:**

1. **GET /sse** - SSE connection endpoint
   - Client connects to receive server messages
   - Server sends events in SSE format: `event: message\ndata: {JSON}\n\n`
   - Keep connection alive with periodic ping/heartbeat
   - Support multiple concurrent client connections

2. **POST /message** - Client message endpoint
   - Accepts JSON-RPC requests from client
   - Returns JSON-RPC responses
   - Handle request correlation using `id` field

**SSE Message Format:**
```
event: message
data: {"jsonrpc":"2.0","id":1,"result":{...}}

event: message
data: {"jsonrpc":"2.0","method":"notifications/message","params":{...}}

```

#### 2.3 MCP Protocol Handshake

**Step 1: Initialize Request (from client)**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "roots": {
        "listChanged": true
      },
      "sampling": {}
    },
    "clientInfo": {
      "name": "claude-api-client",
      "version": "1.0.0"
    }
  }
}
```

**Step 2: Initialize Response (from server)**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "tools": {},
      "logging": {}
    },
    "serverInfo": {
      "name": "rickmorty-mcp-server",
      "version": "1.0.0"
    }
  }
}
```

**Step 3: Initialized Notification (from client)**
```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized"
}
```

#### 2.4 Tool Discovery

**Client Request: tools/list**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list"
}
```

**Server Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "tools": [
      {
        "name": "get_character",
        "description": "Get a single character by ID from Rick and Morty universe",
        "inputSchema": {
          "type": "object",
          "properties": {
            "id": {
              "type": "number",
              "description": "Character ID (1-826)"
            }
          },
          "required": ["id"]
        }
      },
      {
        "name": "search_characters",
        "description": "Search for characters with optional filters",
        "inputSchema": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string",
              "description": "Filter by character name"
            },
            "status": {
              "type": "string",
              "enum": ["alive", "dead", "unknown"],
              "description": "Filter by status"
            },
            "species": {
              "type": "string",
              "description": "Filter by species"
            },
            "type": {
              "type": "string",
              "description": "Filter by type"
            },
            "gender": {
              "type": "string",
              "enum": ["female", "male", "genderless", "unknown"],
              "description": "Filter by gender"
            },
            "page": {
              "type": "number",
              "description": "Page number for pagination (default: 1)"
            }
          }
        }
      }
      // ... other tools
    ]
  }
}
```

#### 2.5 Tool Invocation

**Client Request: tools/call**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "get_character",
    "arguments": {
      "id": 1
    }
  }
}
```

**Server Response (Success):**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"id\":1,\"name\":\"Rick Sanchez\",\"status\":\"Alive\",\"species\":\"Human\",\"type\":\"\",\"gender\":\"Male\",\"origin\":{\"name\":\"Earth (C-137)\",\"url\":\"https://rickandmortyapi.com/api/location/1\"},\"location\":{\"name\":\"Citadel of Ricks\",\"url\":\"https://rickandmortyapi.com/api/location/3\"},\"image\":\"https://rickandmortyapi.com/api/character/avatar/1.jpeg\",\"episode\":[\"https://rickandmortyapi.com/api/episode/1\",\"https://rickandmortyapi.com/api/episode/2\"],\"url\":\"https://rickandmortyapi.com/api/character/1\",\"created\":\"2017-11-04T18:48:46.250Z\"}"
      }
    ],
    "isError": false
  }
}
```

**Server Response (Error):**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Character not found: No character with ID 9999"
      }
    ],
    "isError": true
  }
}
```

**JSON-RPC Error Response (for protocol errors):**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "error": {
    "code": -32602,
    "message": "Invalid params",
    "data": {
      "details": "Missing required parameter: id"
    }
  }
}
```

#### 2.6 Error Codes

Implement standard JSON-RPC 2.0 error codes:
- `-32700`: Parse error (Invalid JSON)
- `-32600`: Invalid Request
- `-32601`: Method not found
- `-32602`: Invalid params
- `-32603`: Internal error
- `-32000` to `-32099`: Server-defined errors

#### 2.7 Connection Management

- **Heartbeat**: Send ping every 30 seconds to keep SSE connection alive
- **Reconnection**: Support client reconnection with session restoration
- **Timeouts**: 60 seconds for tool execution, 120 seconds for idle connections
- **Graceful Shutdown**: Send closing notification before server shutdown

#### 2.8 Integration with Claude API

When configuring this MCP server in Claude API:

```json
{
  "mcpServers": {
    "rickmorty": {
      "url": "http://your-vds-ip:3000/sse",
      "transport": "sse"
    }
  }
}
```

The server must:
1. Accept SSE connections from Claude API client
2. Handle initialize handshake
3. Provide tools list when requested
4. Execute tools and return results in proper format
5. Maintain connection stability for long-running conversations

### 3. Rick and Morty API Integration

Base URL: https://rickandmortyapi.com/api

#### Tools to Implement:

**CHARACTER TOOLS:**

1. `get_character`
   - Input: id (integer)
   - Returns: Single character details

2. `search_characters`
   - Inputs (all optional):
     - name (string)
     - status (enum: "alive", "dead", "unknown")
     - species (string)
     - type (string)
     - gender (enum: "female", "male", "genderless", "unknown")
     - page (integer, default: 1)
   - Returns: Paginated character list with info metadata

3. `get_multiple_characters`
   - Input: ids (array of integers)
   - Returns: Array of characters

4. `get_all_characters_pages`
   - Input: page (integer, default: 1)
   - Returns: Paginated list of all characters

**LOCATION TOOLS:**

5. `get_location`
   - Input: id (integer)
   - Returns: Single location details

6. `search_locations`
   - Inputs (all optional):
     - name (string)
     - type (string)
     - dimension (string)
     - page (integer, default: 1)
   - Returns: Paginated location list

7. `get_multiple_locations`
   - Input: ids (array of integers)
   - Returns: Array of locations

8. `get_all_locations_pages`
   - Input: page (integer, default: 1)
   - Returns: Paginated list of all locations

**EPISODE TOOLS:**

9. `get_episode`
   - Input: id (integer)
   - Returns: Single episode details

10. `search_episodes`
    - Inputs (all optional):
      - name (string)
      - episode (string, e.g., "S01E01")
      - page (integer, default: 1)
    - Returns: Paginated episode list

11. `get_multiple_episodes`
    - Input: ids (array of integers)
    - Returns: Array of episodes

12. `get_all_episodes_pages`
    - Input: page (integer, default: 1)
    - Returns: Paginated list of all episodes

**UTILITY TOOLS:**

13. `get_character_episodes`
    - Input: character_id (integer)
    - Returns: All episodes where character appears

14. `get_location_residents`
    - Input: location_id (integer)
    - Returns: All characters residing in location

15. `get_episode_characters`
    - Input: episode_id (integer)
    - Returns: All characters in episode

### 4. Data Models

Create Codable structs for:
- Character (id, name, status, species, type, gender, origin, location, image, episode, url, created)
- Location (id, name, type, dimension, residents, url, created)
- Episode (id, name, air_date, episode, characters, url, created)
- Info (count, pages, next, prev) for pagination
- Response wrappers for paginated results

### 5. Features

- **Filtering**: Implement all query parameters from the API
- **Pagination**: Support page parameter and return pagination metadata
- **Error Handling**: 
  - Handle 404 (not found)
  - Handle invalid parameters
  - Network errors
  - Return proper MCP error responses
- **Async/Await**: Use Swift concurrency throughout
- **Logging**: Add structured logging for debugging
- **Configuration**: Environment variables for:
  - PORT (default: 3000)
  - LOG_LEVEL (default: info)
  - API_BASE_URL (default: https://rickandmortyapi.com/api)

### 6. Docker Setup

Create a Dockerfile that:
- Uses official Swift image (swift:5.9)
- Multi-stage build (builder + runtime)
- Exposes port 3000
- Runs as non-root user
- Includes healthcheck endpoint

Create docker-compose.yml for easy deployment:
- Service name: rickmorty-mcp
- Port mapping: 3000:3000
- Restart policy: unless-stopped
- Volume for logs (optional)

### 7. Project Structure

```
rickmorty-mcp-server/
├── Package.swift
├── Dockerfile
├── docker-compose.yml
├── README.md
├── Sources/
│   └── RickMortyMCP/
│       ├── main.swift
│       ├── MCPServer.swift
│       ├── SSEHandler.swift
│       ├── RickMortyAPI.swift
│       ├── Models/
│       │   ├── Character.swift
│       │   ├── Location.swift
│       │   ├── Episode.swift
│       │   └── Pagination.swift
│       └── Tools/
│           ├── CharacterTools.swift
│           ├── LocationTools.swift
│           ├── EpisodeTools.swift
│           └── UtilityTools.swift
└── Tests/
    └── RickMortyMCPTests/
```

### 8. Documentation

Create README.md with:
- Installation instructions
- Docker deployment steps
- MCP client configuration example
- Tool usage examples
- API rate limits and best practices
- Troubleshooting guide

### 9. Testing

- Add basic unit tests for data models
- Integration tests for API client
- Example MCP client connection test

### 10. Additional Requirements

- Use proper Swift naming conventions (camelCase for properties)
- Add comprehensive error messages
- Implement request timeout (30 seconds)
- Add User-Agent header to API requests
- Support graceful shutdown
- Include .gitignore for Swift projects

### 11. MCP Implementation Checklist

**SSE Transport:**
- [ ] GET /sse endpoint with proper SSE headers (`Content-Type: text/event-stream`, `Cache-Control: no-cache`)
- [ ] POST /message endpoint for JSON-RPC requests
- [ ] Event format: `event: message\ndata: {JSON}\n\n`
- [ ] Heartbeat/ping mechanism every 30 seconds
- [ ] Connection tracking and cleanup

**JSON-RPC 2.0:**
- [ ] Request parsing with `jsonrpc`, `id`, `method`, `params`
- [ ] Response format with `jsonrpc`, `id`, `result` or `error`
- [ ] Proper error codes (-32700 to -32603, and custom)
- [ ] Request ID correlation

**MCP Protocol Methods:**
- [ ] `initialize` - handshake and capability negotiation
- [ ] `notifications/initialized` - handshake completion
- [ ] `tools/list` - return all 15 tools with schemas
- [ ] `tools/call` - execute tool and return result
- [ ] `ping` - keep-alive (optional)

**Tool Response Format:**
- [ ] Wrap results in `content` array with `type: "text"`
- [ ] Include `isError: false` for success
- [ ] Include `isError: true` for application errors
- [ ] Use JSON-RPC error object for protocol errors

**Testing MCP Connection:**
Add a test script or instructions for:
1. Connecting to SSE endpoint with curl or HTTP client
2. Sending initialize request
3. Listing tools
4. Calling a tool
5. Example Claude API configuration

## Success Criteria:

1. Server starts and listens on specified port
2. SSE endpoint accepts MCP client connections
3. All 15 tools are registered and functional
4. Filtering and pagination work correctly
5. Docker container builds and runs successfully
6. Proper error handling and logging
7. README with clear setup instructions

Start by creating the project structure, then implement the MCP server core, followed by Rick and Morty API integration, and finally add Docker support.
