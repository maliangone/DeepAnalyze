#!/bin/bash

# DeepAnalyze Docker Start Script

set -e

echo "=================================="
echo "Starting DeepAnalyze Services"
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

# Check if services are already running
if docker compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
    echo "⚠️  Some services are already running."
    read -p "Do you want to restart them? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
    echo "Stopping existing services..."
    docker compose -f "$COMPOSE_FILE" down
fi

# Start services
echo "Starting services in detached mode..."
docker compose -f "$COMPOSE_FILE" up -d

echo ""
echo "Waiting for services to start..."
sleep 5

# Check service status
echo ""
echo "Service Status:"
echo "=================================="
docker compose -f "$COMPOSE_FILE" ps
echo ""

# Check vLLM health
echo "Checking vLLM service..."
for i in {1..30}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✓ vLLM service is healthy"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  vLLM service not responding. Check logs: docker compose -f $COMPOSE_FILE logs vllm"
    else
        echo -n "."
        sleep 2
    fi
done

# Check backend health
echo ""
echo "Checking Backend service..."
for i in {1..15}; do
    if curl -s http://localhost:8200/workspace/files?session_id=default > /dev/null 2>&1; then
        echo "✓ Backend service is healthy"
        break
    fi
    if [ $i -eq 15 ]; then
        echo "⚠️  Backend service not responding. Check logs: docker compose -f $COMPOSE_FILE logs backend"
    else
        echo -n "."
        sleep 2
    fi
done

# Check frontend
echo ""
echo "Checking Frontend service..."
for i in {1..15}; do
    if curl -s http://localhost:4000 > /dev/null 2>&1; then
        echo "✓ Frontend service is accessible"
        break
    fi
    if [ $i -eq 15 ]; then
        echo "⚠️  Frontend service not responding. Check logs: docker compose -f $COMPOSE_FILE logs frontend"
    else
        echo -n "."
        sleep 2
    fi
done

echo ""
echo "=================================="
echo "DeepAnalyze Started Successfully!"
echo "=================================="
echo ""
echo "🌐 Web UI:        http://localhost:4000"
echo "🤖 vLLM API:      http://localhost:8000"
echo "🔌 Backend API:   http://localhost:8200"
echo "📁 File Server:   http://localhost:8100"
echo ""
echo "📊 View logs:     docker compose -f $COMPOSE_FILE logs -f"
echo "⏹️  Stop services: ./stop.sh"
echo ""
echo "🎉 Ready to analyze your data!"
echo ""
