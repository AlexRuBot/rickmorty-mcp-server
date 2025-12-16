# Project Structure

This document describes the complete structure of the Rick and Morty MCP Server project.

```
MCPServer/
├── Package.swift                           # Swift Package Manager manifest
├── Dockerfile                              # Multi-stage Docker build configuration
├── docker-compose.yml                      # Docker Compose deployment configuration
├── Makefile                                # Build and deployment commands
├── .gitignore                              # Git ignore patterns
│
├── README.md                               # Main documentation
├── DEPLOYMENT.md                           # Deployment guide for VDS/VPS
├── EXAMPLES.md                             # Usage examples and API examples
├── PROJECT_STRUCTURE.md                    # This file
│
├── quick-start.sh                          # Interactive quick start script
├── test-mcp-connection.sh                  # MCP connection test script
│
├── Sources/
│   └── RickMortyMCP/
│       ├── main.swift                      # Application entry point (Vapor setup)
│       ├── MCPServer.swift                 # MCP protocol handler (initialize, tools/list, tools/call)
│       ├── SSEHandler.swift                # SSE connection management
│       ├── RickMortyAPI.swift              # Rick and Morty API client
│       │
│       ├── Models/
│       │   ├── Character.swift             # Character data model
│       │   ├── Location.swift              # Location data model
│       │   ├── Episode.swift               # Episode data model
│       │   ├── Pagination.swift            # Pagination models (Info, PaginatedResponse)
│       │   ├── JSONRPC.swift               # JSON-RPC 2.0 models (Request, Response, Error)
│       │   └── MCPModels.swift             # MCP protocol models (Initialize, Tools, etc.)
│       │
│       └── Tools/
│           ├── ToolDefinitions.swift       # All 15 tool schemas
│           └── ToolExecutor.swift          # Tool execution logic
│
└── Tests/
    └── RickMortyMCPTests/
        └── RickMortyMCPTests.swift         # Unit tests
```

## File Descriptions

### Root Files

- **Package.swift**: Swift Package Manager configuration with dependencies (Vapor, swift-log)
- **Dockerfile**: Multi-stage Docker build (builder + runtime) for production deployment
- **docker-compose.yml**: Docker Compose configuration for easy deployment
- **Makefile**: Common commands (build, run, test, docker operations)
- **.gitignore**: Git ignore patterns for Swift projects

### Documentation

- **README.md**: Main documentation with features, installation, configuration
- **DEPLOYMENT.md**: Complete deployment guide for VDS/VPS servers
- **EXAMPLES.md**: Extensive usage examples with curl, Python, and JavaScript
- **PROJECT_STRUCTURE.md**: This file - project structure overview

### Scripts

- **quick-start.sh**: Interactive menu for common operations
- **test-mcp-connection.sh**: Automated testing of MCP protocol

### Source Code

#### Core Files

- **main.swift**:
  - Application entry point
  - Vapor server configuration
  - Route definitions (GET /sse, POST /message, GET /health)
  - Request/response handling

- **MCPServer.swift**:
  - MCP protocol implementation
  - Handles: initialize, notifications/initialized, tools/list, tools/call
  - JSON-RPC request routing
  - Error handling

- **SSEHandler.swift**:
  - Server-Sent Events connection management
  - Connection tracking
  - Heartbeat/ping mechanism
  - SSE message formatting

- **RickMortyAPI.swift**:
  - Rick and Morty API client
  - All API methods (characters, locations, episodes)
  - Error handling and retries
  - URLSession configuration

#### Models

- **Character.swift**: Character data structure with origin, location
- **Location.swift**: Location data structure with residents
- **Episode.swift**: Episode data structure with characters list
- **Pagination.swift**: Info and PaginatedResponse generic structures
- **JSONRPC.swift**: Complete JSON-RPC 2.0 implementation
- **MCPModels.swift**: MCP protocol structures (initialize, tools, capabilities)

#### Tools

- **ToolDefinitions.swift**: Schema definitions for all 15 tools
- **ToolExecutor.swift**: Tool execution logic and parameter extraction

### Tests

- **RickMortyMCPTests.swift**: Unit tests for models and JSON-RPC

## Architecture

### Layer Structure

```
┌─────────────────────────────────────────┐
│         HTTP Routes Layer               │
│  (GET /sse, POST /message, GET /health) │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         MCP Server Layer                │
│    (Protocol handling, routing)         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Tool Executor Layer             │
│    (Tool execution, validation)         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         API Client Layer                │
│    (Rick and Morty API calls)           │
└─────────────────────────────────────────┘
```

### Data Flow

```
Client Request
     │
     ▼
POST /message (JSON-RPC)
     │
     ▼
MCPServer.handleJSONRPCRequest()
     │
     ├─► initialize → Return capabilities
     │
     ├─► tools/list → Return tool definitions
     │
     └─► tools/call
          │
          ▼
     ToolExecutor.execute()
          │
          ▼
     RickMortyAPI.<method>()
          │
          ▼
     Rick and Morty API
          │
          ▼
     Parse Response
          │
          ▼
     Return JSON-RPC Result
```

## Key Features by File

### main.swift
- Vapor application setup
- Route definitions
- Request body parsing
- Response encoding
- Environment configuration

### MCPServer.swift
- MCP protocol compliance
- Capability negotiation
- Tool discovery
- Tool invocation routing
- Error code mapping

### SSEHandler.swift
- SSE connection lifecycle
- Event formatting
- Heartbeat management
- Connection cleanup

### RickMortyAPI.swift
- 12 API methods
- Parameter filtering
- Pagination support
- Error handling
- Response parsing

### ToolDefinitions.swift
- 15 tool schemas
- Input validation schemas
- Required/optional parameters
- Enum constraints

### ToolExecutor.swift
- Tool routing
- Parameter extraction
- Result formatting
- Error conversion

## Tool Organization

### Character Tools (4)
1. get_character
2. search_characters
3. get_multiple_characters
4. get_all_characters_pages

### Location Tools (4)
5. get_location
6. search_locations
7. get_multiple_locations
8. get_all_locations_pages

### Episode Tools (4)
9. get_episode
10. search_episodes
11. get_multiple_episodes
12. get_all_episodes_pages

### Utility Tools (3)
13. get_character_episodes
14. get_location_residents
15. get_episode_characters

## Dependencies

### Production Dependencies
- **Vapor** (4.89.0+): Web framework
- **swift-log** (1.5.3+): Logging framework

### System Requirements
- Swift 5.9+
- macOS 13+ (for development)
- Docker (for deployment)

## Build Artifacts

### Local Build
- `.build/debug/RickMortyMCP`: Debug executable
- `.build/release/RickMortyMCP`: Release executable

### Docker Build
- Image: `mcpserver_rickmorty-mcp`
- Container: `rickmorty-mcp-server`
- Exposed port: 3000

## Configuration

### Environment Variables
- `PORT`: Server port (default: 3000)
- `LOG_LEVEL`: Logging level (default: info)
- `API_BASE_URL`: API base URL (default: https://rickandmortyapi.com/api)

### Endpoints
- `GET /health`: Health check
- `GET /sse`: SSE connection
- `POST /message`: JSON-RPC messages

## Development Workflow

1. **Setup**: `swift build`
2. **Run**: `swift run` or `./quick-start.sh`
3. **Test**: `./test-mcp-connection.sh`
4. **Deploy**: `docker-compose up -d`
5. **Monitor**: `docker-compose logs -f`

## Code Statistics

- **Total Files**: 24
- **Swift Files**: 13
- **Models**: 6
- **Core Logic**: 4 (main, MCPServer, SSEHandler, RickMortyAPI)
- **Tools**: 2 (definitions, executor)
- **Tests**: 1
- **Documentation**: 4
- **Scripts**: 2
- **Config**: 5 (Package.swift, Dockerfile, docker-compose, Makefile, .gitignore)

## Future Expansion

Potential additions to the structure:

```
Sources/RickMortyMCP/
├── Middleware/
│   ├── AuthMiddleware.swift        # Authentication
│   └── RateLimitMiddleware.swift   # Rate limiting
│
├── Cache/
│   └── ResponseCache.swift         # Response caching
│
└── Services/
    └── MetricsService.swift        # Metrics collection
```
