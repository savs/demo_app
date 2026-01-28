#!/bin/bash

# Script to (re)start the Docker Compose project

set -e

echo "Stopping existing containers..."
docker compose down --remove-orphans 2>/dev/null || true

echo "Building and starting containers..."
docker compose up --build -d

echo ""
echo "Services started successfully!"
echo ""
echo "Available endpoints:"
echo "  - PHP App:      http://localhost:8080"
echo "  - Ruby App:     http://localhost:3000"
echo "  - Grafana Alloy: http://localhost:12345"
echo ""
echo "To view logs: docker compose logs -f"
echo "To stop:      docker compose down"
