#!/bin/bash

# DeepAnalyze Docker Stop Script

echo "=================================="
echo "Stopping DeepAnalyze Services"
echo "=================================="
echo ""

# Determine which compose file to use
if [ -f "docker-compose-full.yml" ]; then
    COMPOSE_FILE="docker-compose-full.yml"
else
    COMPOSE_FILE="docker-compose.yml"
fi

echo "Using compose file: $COMPOSE_FILE"
echo ""

# Stop services
docker compose -f "$COMPOSE_FILE" down

echo ""
echo "=================================="
echo "Services Stopped"
echo "=================================="
echo ""
echo "To start again: ./start.sh"
echo ""
