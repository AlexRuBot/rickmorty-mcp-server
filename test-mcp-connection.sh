#!/bin/bash

# Test MCP Server Connection Script
# This script tests the basic functionality of the Rick and Morty MCP Server

SERVER_URL="http://localhost:3000"

echo "========================================="
echo "Rick and Morty MCP Server Test Script"
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo "Test 1: Health Check"
echo "---------------------"
HEALTH=$(curl -s ${SERVER_URL}/health)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "Response: $HEALTH"
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi
echo ""

# Test 2: Initialize
echo "Test 2: Initialize Request"
echo "-------------------------"
INIT_RESPONSE=$(curl -s -X POST ${SERVER_URL}/message \
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
  }')

if echo "$INIT_RESPONSE" | grep -q "rickmorty-mcp-server"; then
    echo -e "${GREEN}✓ Initialize passed${NC}"
    echo "Response: $INIT_RESPONSE" | jq '.' 2>/dev/null || echo "$INIT_RESPONSE"
else
    echo -e "${RED}✗ Initialize failed${NC}"
    echo "Response: $INIT_RESPONSE"
    exit 1
fi
echo ""

# Test 3: List Tools
echo "Test 3: List Tools"
echo "------------------"
TOOLS_RESPONSE=$(curl -s -X POST ${SERVER_URL}/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list"
  }')

TOOL_COUNT=$(echo "$TOOLS_RESPONSE" | jq '.result.tools | length' 2>/dev/null)
if [ "$TOOL_COUNT" == "15" ]; then
    echo -e "${GREEN}✓ Tools list passed (15 tools found)${NC}"
    echo "Tools:"
    echo "$TOOLS_RESPONSE" | jq '.result.tools[] | .name' 2>/dev/null || echo "$TOOLS_RESPONSE"
else
    echo -e "${RED}✗ Tools list failed${NC}"
    echo "Response: $TOOLS_RESPONSE"
    exit 1
fi
echo ""

# Test 4: Call Tool - Get Character
echo "Test 4: Call Tool (get_character)"
echo "---------------------------------"
TOOL_RESPONSE=$(curl -s -X POST ${SERVER_URL}/message \
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
  }')

if echo "$TOOL_RESPONSE" | grep -q "Rick Sanchez"; then
    echo -e "${GREEN}✓ Tool call passed${NC}"
    echo "Character data retrieved successfully"
    echo "$TOOL_RESPONSE" | jq '.result.content[0].text' 2>/dev/null | jq '.' || echo "$TOOL_RESPONSE"
else
    echo -e "${RED}✗ Tool call failed${NC}"
    echo "Response: $TOOL_RESPONSE"
    exit 1
fi
echo ""

# Test 5: Search Characters
echo "Test 5: Search Characters"
echo "------------------------"
SEARCH_RESPONSE=$(curl -s -X POST ${SERVER_URL}/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "search_characters",
      "arguments": {
        "status": "alive",
        "page": 1
      }
    }
  }')

if echo "$SEARCH_RESPONSE" | grep -q "\"results\""; then
    echo -e "${GREEN}✓ Search characters passed${NC}"
    echo "Search results retrieved successfully"
else
    echo -e "${RED}✗ Search characters failed${NC}"
    echo "Response: $SEARCH_RESPONSE"
    exit 1
fi
echo ""

# Test 6: Error Handling
echo "Test 6: Error Handling (invalid character ID)"
echo "--------------------------------------------"
ERROR_RESPONSE=$(curl -s -X POST ${SERVER_URL}/message \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 5,
    "method": "tools/call",
    "params": {
      "name": "get_character",
      "arguments": {
        "id": 99999
      }
    }
  }')

if echo "$ERROR_RESPONSE" | grep -q "isError.*true"; then
    echo -e "${GREEN}✓ Error handling passed${NC}"
    echo "Error properly handled"
else
    echo -e "${RED}✗ Error handling failed${NC}"
    echo "Response: $ERROR_RESPONSE"
fi
echo ""

echo "========================================="
echo -e "${GREEN}All tests completed successfully!${NC}"
echo "========================================="
