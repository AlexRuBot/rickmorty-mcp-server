# Usage Examples

This document provides practical examples of using the Rick and Morty MCP Server.

## Table of Contents

- [Basic Connection](#basic-connection)
- [Character Queries](#character-queries)
- [Location Queries](#location-queries)
- [Episode Queries](#episode-queries)
- [Utility Queries](#utility-queries)
- [Advanced Examples](#advanced-examples)

## Basic Connection

### 1. Establish SSE Connection

```bash
curl -N http://localhost:3000/sse
```

This establishes a Server-Sent Events connection. You'll receive periodic heartbeat messages.

### 2. Initialize the MCP Session

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
        "name": "example-client",
        "version": "1.0.0"
      }
    }
  }'
```

**Expected Response:**
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

### 3. List Available Tools

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list"
  }'
```

## Character Queries

### Get Character by ID

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

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"id\":1,\"name\":\"Rick Sanchez\",\"status\":\"Alive\",\"species\":\"Human\",...}"
      }
    ],
    "isError": false
  }
}
```

### Search Characters by Name

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "search_characters",
      "arguments": {
        "name": "Morty"
      }
    }
  }'
```

### Search Characters by Status

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 5,
    "method": "tools/call",
    "params": {
      "name": "search_characters",
      "arguments": {
        "status": "alive",
        "page": 1
      }
    }
  }'
```

### Search Characters with Multiple Filters

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 6,
    "method": "tools/call",
    "params": {
      "name": "search_characters",
      "arguments": {
        "species": "Human",
        "gender": "female",
        "status": "alive"
      }
    }
  }'
```

### Get Multiple Characters

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 7,
    "method": "tools/call",
    "params": {
      "name": "get_multiple_characters",
      "arguments": {
        "ids": [1, 2, 3, 4, 5]
      }
    }
  }'
```

### Get All Characters (Paginated)

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 8,
    "method": "tools/call",
    "params": {
      "name": "get_all_characters_pages",
      "arguments": {
        "page": 1
      }
    }
  }'
```

## Location Queries

### Get Location by ID

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 9,
    "method": "tools/call",
    "params": {
      "name": "get_location",
      "arguments": {
        "id": 1
      }
    }
  }'
```

### Search Locations by Name

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 10,
    "method": "tools/call",
    "params": {
      "name": "search_locations",
      "arguments": {
        "name": "Earth"
      }
    }
  }'
```

### Search Locations by Dimension

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 11,
    "method": "tools/call",
    "params": {
      "name": "search_locations",
      "arguments": {
        "dimension": "C-137"
      }
    }
  }'
```

### Get Multiple Locations

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 12,
    "method": "tools/call",
    "params": {
      "name": "get_multiple_locations",
      "arguments": {
        "ids": [1, 2, 3]
      }
    }
  }'
```

## Episode Queries

### Get Episode by ID

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 13,
    "method": "tools/call",
    "params": {
      "name": "get_episode",
      "arguments": {
        "id": 1
      }
    }
  }'
```

### Search Episodes by Name

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 14,
    "method": "tools/call",
    "params": {
      "name": "search_episodes",
      "arguments": {
        "name": "Pilot"
      }
    }
  }'
```

### Search Episodes by Code

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 15,
    "method": "tools/call",
    "params": {
      "name": "search_episodes",
      "arguments": {
        "episode": "S01E01"
      }
    }
  }'
```

### Get Multiple Episodes

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 16,
    "method": "tools/call",
    "params": {
      "name": "get_multiple_episodes",
      "arguments": {
        "ids": [1, 2, 3, 4, 5]
      }
    }
  }'
```

## Utility Queries

### Get All Episodes for a Character

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 17,
    "method": "tools/call",
    "params": {
      "name": "get_character_episodes",
      "arguments": {
        "character_id": 1
      }
    }
  }'
```

### Get All Residents of a Location

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 18,
    "method": "tools/call",
    "params": {
      "name": "get_location_residents",
      "arguments": {
        "location_id": 1
      }
    }
  }'
```

### Get All Characters in an Episode

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 19,
    "method": "tools/call",
    "params": {
      "name": "get_episode_characters",
      "arguments": {
        "episode_id": 1
      }
    }
  }'
```

## Advanced Examples

### Chain Multiple Queries

Get a character, then get all their episodes:

```bash
# Step 1: Get character
CHARACTER_RESPONSE=$(curl -s -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 20,
    "method": "tools/call",
    "params": {
      "name": "get_character",
      "arguments": {"id": 1}
    }
  }')

# Step 2: Get character's episodes
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 21,
    "method": "tools/call",
    "params": {
      "name": "get_character_episodes",
      "arguments": {"character_id": 1}
    }
  }'
```

### Find All Human Characters

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 22,
    "method": "tools/call",
    "params": {
      "name": "search_characters",
      "arguments": {
        "species": "Human",
        "page": 1
      }
    }
  }' | jq '.result.content[0].text | fromjson | .results[] | {name: .name, status: .status}'
```

### Get Location and Its Residents

```bash
# Get location details
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 23,
    "method": "tools/call",
    "params": {
      "name": "get_location",
      "arguments": {"id": 1}
    }
  }'

# Get all residents
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 24,
    "method": "tools/call",
    "params": {
      "name": "get_location_residents",
      "arguments": {"location_id": 1}
    }
  }'
```

### Error Handling Example

```bash
# Invalid character ID
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 25,
    "method": "tools/call",
    "params": {
      "name": "get_character",
      "arguments": {"id": 99999}
    }
  }'
```

**Error Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 25,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Resource not found"
      }
    ],
    "isError": true
  }
}
```

### Missing Required Parameter

```bash
curl -X POST http://localhost:3000/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 26,
    "method": "tools/call",
    "params": {
      "name": "get_character",
      "arguments": {}
    }
  }'
```

**Error Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 26,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Missing required parameter: id"
      }
    ],
    "isError": true
  }
}
```

## Python Client Example

```python
import requests
import json

class RickMortyMCPClient:
    def __init__(self, base_url="http://localhost:3000"):
        self.base_url = base_url
        self.request_id = 0

    def call_tool(self, tool_name, arguments=None):
        self.request_id += 1
        payload = {
            "jsonrpc": "2.0",
            "id": self.request_id,
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": arguments or {}
            }
        }

        response = requests.post(
            f"{self.base_url}/message",
            json=payload,
            headers={"Content-Type": "application/json"}
        )

        return response.json()

    def get_character(self, character_id):
        result = self.call_tool("get_character", {"id": character_id})
        return json.loads(result["result"]["content"][0]["text"])

    def search_characters(self, **filters):
        result = self.call_tool("search_characters", filters)
        return json.loads(result["result"]["content"][0]["text"])

# Usage
client = RickMortyMCPClient()

# Get Rick Sanchez
rick = client.get_character(1)
print(f"Character: {rick['name']}")

# Search for alive humans
alive_humans = client.search_characters(species="Human", status="alive")
print(f"Found {alive_humans['info']['count']} alive humans")
```

## JavaScript/Node.js Client Example

```javascript
const axios = require('axios');

class RickMortyMCPClient {
    constructor(baseUrl = 'http://localhost:3000') {
        this.baseUrl = baseUrl;
        this.requestId = 0;
    }

    async callTool(toolName, arguments = {}) {
        this.requestId++;
        const payload = {
            jsonrpc: '2.0',
            id: this.requestId,
            method: 'tools/call',
            params: {
                name: toolName,
                arguments: arguments
            }
        };

        const response = await axios.post(
            `${this.baseUrl}/message`,
            payload,
            { headers: { 'Content-Type': 'application/json' } }
        );

        return response.data;
    }

    async getCharacter(characterId) {
        const result = await this.callTool('get_character', { id: characterId });
        return JSON.parse(result.result.content[0].text);
    }

    async searchCharacters(filters) {
        const result = await this.callTool('search_characters', filters);
        return JSON.parse(result.result.content[0].text);
    }
}

// Usage
(async () => {
    const client = new RickMortyMCPClient();

    // Get Rick Sanchez
    const rick = await client.getCharacter(1);
    console.log(`Character: ${rick.name}`);

    // Search for alive humans
    const aliveHumans = await client.searchCharacters({
        species: 'Human',
        status: 'alive'
    });
    console.log(`Found ${aliveHumans.info.count} alive humans`);
})();
```

## Tips and Best Practices

1. **Pagination**: Always handle pagination when searching:
   ```bash
   # Get first page
   page=1
   while true; do
     response=$(curl -s -X POST http://localhost:3000/message \
       -H "Content-Type: application/json" \
       -d "{\"jsonrpc\":\"2.0\",\"id\":$page,\"method\":\"tools/call\",\"params\":{\"name\":\"get_all_characters_pages\",\"arguments\":{\"page\":$page}}}")

     # Process response...

     # Check if there's a next page
     if [ "$(echo $response | jq -r '.result.content[0].text | fromjson | .info.next')" == "null" ]; then
       break
     fi

     page=$((page + 1))
   done
   ```

2. **Error Handling**: Always check for `isError` flag:
   ```bash
   response=$(curl -s -X POST ...)
   is_error=$(echo $response | jq -r '.result.isError')
   if [ "$is_error" == "true" ]; then
     echo "Error occurred!"
   fi
   ```

3. **Rate Limiting**: Be respectful of the Rick and Morty API:
   - Add delays between requests if making many calls
   - Use batch endpoints when possible (`get_multiple_*`)
   - Cache responses when appropriate

4. **Connection Management**: Keep SSE connection alive:
   - Monitor for heartbeat/ping messages
   - Reconnect if connection drops
   - Handle graceful disconnection
