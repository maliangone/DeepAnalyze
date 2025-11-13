#!/bin/bash

# DeepAnalyze Docker Setup Script
# This script prepares your environment for DeepAnalyze deployment

set -e  # Exit on any error

echo "=================================="
echo "DeepAnalyze Docker Setup"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is designed for Linux. Detected OS: $OSTYPE"
    exit 1
fi

print_status "Running on Linux"

# Check if Docker is installed
echo ""
echo "Checking prerequisites..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_status "Docker is installed: $DOCKER_VERSION"
else
    print_error "Docker is not installed!"
    echo ""
    echo "Please install Docker first:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    exit 1
fi

# Check if docker compose is available
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    print_status "Docker Compose is installed: $COMPOSE_VERSION"
else
    print_error "Docker Compose is not available!"
    exit 1
fi

# Check if NVIDIA GPU is available
echo ""
echo "Checking GPU availability..."
if command -v nvidia-smi &> /dev/null; then
    print_status "NVIDIA GPU driver is installed"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
else
    print_warning "nvidia-smi not found. GPU acceleration may not work!"
fi

# Check if nvidia-container-toolkit is installed
if docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    print_status "NVIDIA Container Toolkit is configured correctly"
else
    print_error "NVIDIA Container Toolkit is not properly configured!"
    echo ""
    echo "Please install it:"
    echo "  distribution=\$(. /etc/os-release;echo \$ID\$VERSION_ID)"
    echo "  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -"
    echo "  curl -s -L https://nvidia.github.io/nvidia-docker/\$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list"
    echo "  sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"
    echo "  sudo systemctl restart docker"
    exit 1
fi

# Create necessary directories
echo ""
echo "Creating directory structure..."
mkdir -p ./models
mkdir -p ./workspace
print_status "Created ./models directory"
print_status "Created ./workspace directory"

# Check if model exists
echo ""
echo "Checking for DeepAnalyze-8B model..."
if [ -d "./models/DeepAnalyze-8B" ] && [ -f "./models/DeepAnalyze-8B/config.json" ]; then
    print_status "Model found at ./models/DeepAnalyze-8B"
else
    print_warning "DeepAnalyze-8B model not found!"
    echo ""
    echo "You need to download the model first. Options:"
    echo ""
    echo "Option 1: Using huggingface-cli (recommended)"
    echo "  pip install -U huggingface-hub"
    echo "  huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ./models/DeepAnalyze-8B"
    echo ""
    echo "Option 2: Using git"
    echo "  cd ./models"
    echo "  git lfs install"
    echo "  git clone https://huggingface.co/RUC-DataLab/DeepAnalyze-8B"
    echo ""
    echo "Option 3: Symlink existing model"
    echo "  ln -s /path/to/existing/DeepAnalyze-8B ./models/DeepAnalyze-8B"
    echo ""
    read -p "Would you like to download the model now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Downloading model... (this may take 10-20 minutes)"
        if command -v huggingface-cli &> /dev/null; then
            huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ./models/DeepAnalyze-8B
            print_status "Model downloaded successfully"
        else
            print_error "huggingface-cli not found. Please install it:"
            echo "  pip install -U huggingface-hub"
            exit 1
        fi
    else
        print_warning "Skipping model download. Please download it manually before starting services."
    fi
fi

# Pull Docker image
echo ""
echo "Pulling Docker image..."
if docker pull facdbe/deepanalyze-env:latest; then
    print_status "Docker image pulled successfully"
else
    print_warning "Failed to pull Docker image. Will try to build locally if needed."
fi

# Check if docker-compose-full.yml exists
if [ ! -f "docker-compose-full.yml" ]; then
    print_warning "docker-compose-full.yml not found. Using default docker-compose.yml"
    COMPOSE_FILE="docker-compose.yml"
else
    COMPOSE_FILE="docker-compose-full.yml"
fi

echo ""
echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
echo "Next steps:"
echo "  1. Review and customize $COMPOSE_FILE if needed"
echo "  2. Start services: ./start.sh"
echo "  3. Access web UI: http://localhost:4000"
echo ""
echo "Management commands:"
echo "  - Start:   ./start.sh"
echo "  - Stop:    ./stop.sh"
echo "  - Logs:    docker compose -f $COMPOSE_FILE logs -f"
echo "  - Status:  docker compose -f $COMPOSE_FILE ps"
echo ""
