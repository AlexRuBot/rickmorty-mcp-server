#!/bin/bash

# Quick Start Script for Rick and Morty MCP Server
# This script helps you quickly set up and test the MCP server

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════╗"
echo "║   Rick and Morty MCP Server - Quick Start Script    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Docker is installed
print_status "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

print_success "Docker and Docker Compose are installed"
echo ""

# Ask user what they want to do
echo "What would you like to do?"
echo "  1) Build and start the server"
echo "  2) Run tests"
echo "  3) View logs"
echo "  4) Stop server"
echo "  5) Clean everything and rebuild"
echo "  6) Show server status"
echo ""
read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        print_status "Building Docker image..."
        docker-compose build

        print_status "Starting server..."
        docker-compose up -d

        echo ""
        print_success "Server started successfully!"
        echo ""
        echo "Server is running at:"
        echo "  • Health:   http://localhost:3000/health"
        echo "  • SSE:      http://localhost:3000/sse"
        echo "  • Message:  http://localhost:3000/message"
        echo ""

        print_status "Waiting for server to be ready..."
        sleep 3

        # Check health
        if curl -sf http://localhost:3000/health > /dev/null; then
            print_success "Server is healthy!"
            echo ""
            echo "Next steps:"
            echo "  • Run tests:        ./quick-start.sh (choose option 2)"
            echo "  • View logs:        docker-compose logs -f"
            echo "  • See examples:     cat EXAMPLES.md"
            echo "  • Stop server:      docker-compose down"
        else
            print_warning "Server might still be starting up..."
            print_status "Check logs with: docker-compose logs -f"
        fi
        ;;

    2)
        print_status "Running MCP connection tests..."

        # Check if server is running
        if ! curl -sf http://localhost:3000/health > /dev/null; then
            print_error "Server is not running!"
            print_status "Start the server first with option 1"
            exit 1
        fi

        # Run test script
        if [ -f "./test-mcp-connection.sh" ]; then
            chmod +x ./test-mcp-connection.sh
            ./test-mcp-connection.sh
        else
            print_error "Test script not found!"
            exit 1
        fi
        ;;

    3)
        print_status "Showing logs (Ctrl+C to exit)..."
        docker-compose logs -f
        ;;

    4)
        print_status "Stopping server..."
        docker-compose down
        print_success "Server stopped"
        ;;

    5)
        print_warning "This will remove all containers, images, and rebuild from scratch"
        read -p "Are you sure? (y/N): " confirm
        if [[ $confirm == [yY] ]]; then
            print_status "Stopping containers..."
            docker-compose down

            print_status "Removing Docker images..."
            docker-compose down --rmi all

            print_status "Cleaning build cache..."
            docker system prune -f

            print_status "Rebuilding..."
            docker-compose build --no-cache

            print_status "Starting server..."
            docker-compose up -d

            print_success "Clean rebuild complete!"
        else
            print_warning "Cancelled"
        fi
        ;;

    6)
        print_status "Server Status:"
        echo ""

        # Check if container is running
        if docker-compose ps | grep -q "rickmorty-mcp-server"; then
            print_success "Container is running"

            # Get container stats
            echo ""
            docker-compose ps

            echo ""
            print_status "Resource usage:"
            docker stats rickmorty-mcp-server --no-stream

            echo ""
            # Check health
            if curl -sf http://localhost:3000/health > /dev/null; then
                HEALTH=$(curl -s http://localhost:3000/health)
                print_success "Health check: $HEALTH"
            else
                print_warning "Health check failed"
            fi
        else
            print_warning "Container is not running"
            print_status "Start the server with option 1"
        fi
        ;;

    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_status "Done!"
