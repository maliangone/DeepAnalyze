#!/bin/bash

# DeepAnalyze Health Check Script

echo "=================================="
echo "DeepAnalyze Health Check"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters
PASS=0
FAIL=0

check_service() {
    local name=$1
    local url=$2
    local description=$3
    
    echo -n "Checking $description... "
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAIL++))
        return 1
    fi
}

# Check Docker containers
echo "1. Container Status"
echo "-------------------"
if [ -f "docker-compose-full.yml" ]; then
    COMPOSE_FILE="docker-compose-full.yml"
else
    COMPOSE_FILE="docker-compose.yml"
fi

RUNNING=$(docker compose -f "$COMPOSE_FILE" ps --filter "status=running" -q | wc -l)
TOTAL=$(docker compose -f "$COMPOSE_FILE" ps -q | wc -l)

if [ "$RUNNING" -eq "$TOTAL" ] && [ "$RUNNING" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} All containers running ($RUNNING/$TOTAL)"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Some containers not running ($RUNNING/$TOTAL)"
    ((FAIL++))
fi
echo ""

# Check GPU
echo "2. GPU Status"
echo "-------------"
if nvidia-smi > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} GPU is accessible"
    nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu --format=csv,noheader
    ((PASS++))
else
    echo -e "${RED}✗${NC} GPU not accessible"
    ((FAIL++))
fi
echo ""

# Check services
echo "3. Service Health"
echo "-----------------"
check_service "vllm" "http://localhost:8000/health" "vLLM API"
check_service "backend" "http://localhost:8200/workspace/files?session_id=default" "Backend API"
check_service "file-server" "http://localhost:8100" "File Server"
check_service "frontend" "http://localhost:4000" "Frontend UI"
echo ""

# Check model
echo "4. Model Status"
echo "---------------"
if curl -s http://localhost:8000/v1/models 2>/dev/null | grep -q "DeepAnalyze"; then
    echo -e "${GREEN}✓${NC} Model loaded successfully"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Model not loaded or not accessible"
    ((FAIL++))
fi
echo ""

# Test inference
echo "5. Inference Test"
echo "-----------------"
RESPONSE=$(curl -s -X POST http://localhost:8000/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "DeepAnalyze-8B",
        "messages": [{"role": "user", "content": "Hi"}],
        "max_tokens": 10
    }' 2>/dev/null)

if echo "$RESPONSE" | grep -q "choices"; then
    echo -e "${GREEN}✓${NC} Inference working"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Inference failed"
    ((FAIL++))
fi
echo ""

# GPU memory check inside container
echo "6. Container GPU Access"
echo "-----------------------"
if docker exec deepanalyze-vllm nvidia-smi > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Container can access GPU"
    ((PASS++))
else
    echo -e "${RED}✗${NC} Container cannot access GPU"
    ((FAIL++))
fi
echo ""

# Summary
echo "=================================="
echo "Health Check Summary"
echo "=================================="
echo ""
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! System is healthy.${NC}"
    echo ""
    echo "🌐 Access the UI at: http://localhost:4000"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the errors above.${NC}"
    echo ""
    echo "Debugging tips:"
    echo "  - View logs:    ./logs.sh"
    echo "  - Restart:      ./stop.sh && ./start.sh"
    echo "  - Check GPU:    nvidia-smi"
    exit 1
fi
