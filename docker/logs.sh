#!/bin/bash

# DeepAnalyze Docker Logs Script

# Determine which compose file to use
if [ -f "docker-compose-full.yml" ]; then
    COMPOSE_FILE="docker-compose-full.yml"
else
    COMPOSE_FILE="docker-compose.yml"
fi

# Check if a service name is provided
if [ -z "$1" ]; then
    echo "Showing logs for all services..."
    echo "Use: ./logs.sh [service_name] to view specific service"
    echo "Available services: vllm, backend, frontend"
    echo ""
    docker compose -f "$COMPOSE_FILE" logs -f
else
    echo "Showing logs for: $1"
    docker compose -f "$COMPOSE_FILE" logs -f "$1"
fi
