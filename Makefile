.PHONY: build run test docker-build docker-up docker-down docker-logs clean help

help:
	@echo "Rick and Morty MCP Server - Available Commands"
	@echo "=============================================="
	@echo "  make build        - Build the project locally"
	@echo "  make run          - Run the server locally"
	@echo "  make test         - Run unit tests"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-up    - Start Docker container"
	@echo "  make docker-down  - Stop Docker container"
	@echo "  make docker-logs  - View Docker logs"
	@echo "  make test-mcp     - Test MCP connection"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make help         - Show this help message"

build:
	swift build

run:
	swift run

test:
	swift test

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d
	@echo "Server started at http://localhost:3000"
	@echo "Health check: http://localhost:3000/health"
	@echo "SSE endpoint: http://localhost:3000/sse"

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

docker-restart:
	docker-compose restart

test-mcp:
	@echo "Testing MCP connection..."
	@./test-mcp-connection.sh

clean:
	swift package clean
	rm -rf .build

status:
	@docker-compose ps
	@echo ""
	@curl -s http://localhost:3000/health || echo "Server not running"
