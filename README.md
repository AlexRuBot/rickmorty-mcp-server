# Rick and Morty MCP Server

A Model Context Protocol (MCP) server implementation in Swift that provides access to the Rick and Morty API through SSE (Server-Sent Events) transport.

## Overview

This MCP server exposes 15 tools for querying the Rick and Morty universe, including characters, locations, and episodes. It implements the MCP protocol version 2024-11-05 with JSON-RPC 2.0 over SSE transport.

## Features

- **15 Specialized Tools**: Query characters, locations, episodes, and their relationships
- **SSE Transport**: Real-time Server-Sent Events communication
- **JSON-RPC 2.0**: Standard protocol for request/response handling
- **Docker Support**: Easy deployment with Docker and docker-compose
- **Filtering & Pagination**: Full support for API query parameters
- **Error Handling**: Comprehensive error handling with proper error codes
- **Structured Logging**: Built-in logging for debugging and monitoring

## Architecture

```
┌─────────────┐         SSE          ┌──────────────┐        HTTP        ┌────────────────────┐
│             │◄─────────────────────►│              │◄──────────────────►│                    │
│  MCP Client │  JSON-RPC over SSE   │  MCP Server  │   URLSession       │  Rick & Morty API  │
│  (Claude)   │                      │   (Vapor)    │                    │                    │
└─────────────┘                      └──────────────┘                    └────────────────────┘
```

## Project Structure

```
MCPServer/
├── Package.swift                       # Swift Package Manager manifest
├── Dockerfile                          # Multi-stage Docker build
├── docker-compose.yml                  # Docker Compose configuration
├── README.md                           # This file
├── Sources/
│   └── RickMortyMCP/
│       ├── main.swift                  # Application entry point
│       ├── MCPServer.swift             # MCP protocol implementation
│       ├── SSEHandler.swift            # SSE connection management
│       ├── RickMortyAPI.swift          # Rick & Morty API client
│       ├── Models/
│       │   ├── Character.swift         # Character data model
│       │   ├── Location.swift          # Location data model
│       │   ├── Episode.swift           # Episode data model
│       │   ├── Pagination.swift        # Pagination models
│       │   ├── JSONRPC.swift           # JSON-RPC 2.0 structures
│       │   └── MCPModels.swift         # MCP protocol models
│       └── Tools/
│           ├── ToolDefinitions.swift   # Tool schemas
│           └── ToolExecutor.swift      # Tool execution logic
└── Tests/
    └── RickMortyMCPTests/
```

## Available Tools

### Character Tools

1. **get_character** - Get a single character by ID
   - Input: `id` (number, 1-826)
   - Returns: Character details

2. **search_characters** - Search for characters with filters
   - Inputs: `name`, `status`, `species`, `type`, `gender`, `page`
   - Returns: Paginated character list

3. **get_multiple_characters** - Get multiple characters by IDs
   - Input: `ids` (array of numbers)
   - Returns: Array of characters

4. **get_all_characters_pages** - Get paginated list of all characters
   - Input: `page` (number, default: 1)
   - Returns: Paginated character list

### Location Tools

5. **get_location** - Get a single location by ID
   - Input: `id` (number)
   - Returns: Location details

6. **search_locations** - Search for locations with filters
   - Inputs: `name`, `type`, `dimension`, `page`
   - Returns: Paginated location list

7. **get_multiple_locations** - Get multiple locations by IDs
   - Input: `ids` (array of numbers)
   - Returns: Array of locations

8. **get_all_locations_pages** - Get paginated list of all locations
   - Input: `page` (number, default: 1)
   - Returns: Paginated location list

### Episode Tools

9. **get_episode** - Get a single episode by ID
   - Input: `id` (number)
   - Returns: Episode details

10. **search_episodes** - Search for episodes with filters
    - Inputs: `name`, `episode`, `page`
    - Returns: Paginated episode list

11. **get_multiple_episodes** - Get multiple episodes by IDs
    - Input: `ids` (array of numbers)
    - Returns: Array of episodes

12. **get_all_episodes_pages** - Get paginated list of all episodes
    - Input: `page` (number, default: 1)
    - Returns: Paginated episode list

### Utility Tools

13. **get_character_episodes** - Get all episodes where a character appears
    - Input: `character_id` (number)
    - Returns: Array of episodes

14. **get_location_residents** - Get all characters residing in a location
    - Input: `location_id` (number)
    - Returns: Array of characters

15. **get_episode_characters** - Get all characters in an episode
    - Input: `episode_id` (number)
    - Returns: Array of characters

## Installation

### Prerequisites

- Swift 5.9+ (for local development)
- Docker and Docker Compose (for containerized deployment)

### Option 1: Docker Deployment (Recommended)

1. Clone the repository:
```bash
git clone <your-repo-url>
cd MCPServer
```

2. Build and run with Docker Compose:
```bash
docker-compose up -d
```

3. Check server health:
```bash
curl http://localhost:3000/health
```

### Option 2: Local Development

1. Install Swift 5.9+ from [swift.org](https://swift.org)

2. Clone and build:
```bash
git clone <your-repo-url>
cd MCPServer
swift build
```

3. Run the server:
```bash
swift run
```

## Configuration

### Environment Variables

- `PORT` - Server port (default: 3000)
- `LOG_LEVEL` - Logging level: trace, debug, info, notice, warning, error, critical (default: info)
- `API_BASE_URL` - Rick and Morty API base URL (default: https://rickandmortyapi.com/api)

### Docker Compose Configuration

Edit `docker-compose.yml` to customize:

```yaml
environment:
  - PORT=3000
  - LOG_LEVEL=debug
  - API_BASE_URL=https://rickandmortyapi.com/api
```

## MCP Client Configuration

### Claude API Configuration

To use this server with Claude API, configure your MCP settings:

```json
{
  "mcpServers": {
    "rickmorty": {
      "url": "http://your-server-ip:3000/sse",
      "transport": "sse"
    }
  }
}
```

### Testing with curl

#### 1. Connect to SSE endpoint:
```bash
curl -N http://localhost:3000/sse
```

#### 2. Initialize the connection:
```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {
        "roots": {"listChanged": true},
        "sampling": {}
      },
      "clientInfo": {
        "name": "test-client",
        "version": "1.0.0"
      }
    }
  }'
```

#### 3. List available tools:
```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list"
  }'
```

#### 4. Call a tool (get character):
```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "get_character",
      "arguments": {
        "id": 1
      }
    }
  }'
```

## MCP Protocol Flow

```
Client                                Server
  │                                     │
  ├─────── GET /sse ──────────────────►│  (Establish SSE connection)
  │                                     │
  ├─────── POST /message ──────────────►│
  │        (initialize request)         │
  │◄────── SSE event ───────────────────┤
  │        (initialize response)        │
  │                                     │
  ├─────── POST /message ──────────────►│
  │        (tools/list request)         │
  │◄────── SSE event ───────────────────┤
  │        (tools list)                 │
  │                                     │
  ├─────── POST /message ──────────────►│
  │        (tools/call request)         │
  │◄────── SSE event ───────────────────┤
  │        (tool result)                │
  │                                     │
  │◄────── SSE ping (every 30s) ────────┤
  │                                     │
```

## Error Handling

The server implements standard JSON-RPC 2.0 error codes:

- `-32700` - Parse error (Invalid JSON)
- `-32600` - Invalid Request
- `-32601` - Method not found
- `-32602` - Invalid params
- `-32603` - Internal error

### Example Error Response:

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "error": {
    "code": -32602,
    "message": "Invalid params",
    "data": "Missing required parameter: id"
  }
}
```

### Tool Error Response:

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

## API Rate Limits

The Rick and Morty API has no official rate limits, but best practices:
- Implement client-side rate limiting if making many requests
- Cache responses when appropriate
- Use batch endpoints (`get_multiple_*`) when fetching multiple resources

## Troubleshooting

### Server won't start

**Issue**: Port 3000 already in use
```bash
# Find process using port 3000
lsof -i :3000
# Kill the process or change PORT in docker-compose.yml
```

**Issue**: Docker build fails
```bash
# Clean Docker cache and rebuild
docker-compose down
docker system prune -a
docker-compose up --build
```

### Connection Issues

**Issue**: SSE connection drops
- Check server logs: `docker-compose logs -f rickmorty-mcp`
- Verify firewall settings
- Ensure client supports persistent connections

**Issue**: Tool calls timeout
- Check network connectivity to rickandmortyapi.com
- Increase timeout in RickMortyAPI.swift (default: 30s)
- Check server logs for API errors

### Debugging

Enable debug logging:
```bash
# In docker-compose.yml
environment:
  - LOG_LEVEL=debug
```

View logs:
```bash
docker-compose logs -f
```

## Development

### Running Tests

```bash
swift test
```

### Building for Release

```bash
swift build -c release
```

### Deployment to VDS/VPS

1. Install Docker and Docker Compose on your server

2. Clone the repository:
```bash
git clone <your-repo-url>
cd MCPServer
```

3. Configure firewall:
```bash
sudo ufw allow 3000/tcp
```

4. Start the service:
```bash
docker-compose up -d
```

5. Enable auto-start on boot:
```bash
docker-compose up -d --remove-orphans
```

6. Monitor the service:
```bash
docker-compose ps
docker-compose logs -f
```

## Security Considerations

- The server binds to `0.0.0.0` by default - restrict access using firewall rules
- No authentication is implemented - add reverse proxy with auth if needed
- CORS is enabled for all origins - restrict in production
- Run container as non-root user (already configured)

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is provided as-is for educational purposes.

## Credits

- Rick and Morty API: https://rickandmortyapi.com/
- Model Context Protocol: https://modelcontextprotocol.io/
- Vapor Framework: https://vapor.codes/

## Support

For issues and questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review server logs: `docker-compose logs`
- Open an issue on GitHub

## Changelog

### Version 1.0.0
- Initial release
- 15 tools for Rick and Morty API
- SSE transport with JSON-RPC 2.0
- Docker support
- Comprehensive error handling
