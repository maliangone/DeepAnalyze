# DeepAnalyze Docker Deployment Guide for H100 GPU Server

## 🎯 Overview

This guide will help you deploy DeepAnalyze with:
- **Backend LLM**: DeepAnalyze-8B model served via vLLM (GPU-accelerated)
- **Chat Web UI**: Next.js-based chat interface
- **API Server**: FastAPI backend for file management and code execution

## 📦 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Frontend (Next.js)           Port 4000                     │
│  - Chat Interface                                           │
│  - File Upload/Management                                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────────┐
│  Backend API (FastAPI)        Port 8200                     │
│  - Chat completions endpoint                                │
│  - File management                                          │
│  - Code execution                                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────────┐
│  vLLM Service                 Port 8000                     │
│  - DeepAnalyze-8B Model (GPU)                              │
│  - OpenAI-compatible API                                    │
└─────────────────────────────────────────────────────────────┘

        Additional: File Server  Port 8100
```

## 🔧 Prerequisites

### 1. System Requirements

- **GPU**: H100 (you have this ✓)
- **OS**: Ubuntu 22.04+ (you have this ✓)
- **RAM**: 32GB+ recommended
- **Storage**: 50GB+ free space for model and Docker images
- **GPU Memory**: ~16GB for DeepAnalyze-8B model

### 2. Install Docker & NVIDIA Container Toolkit

```bash
# Install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to docker group (avoid using sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify Docker installation
docker --version
docker compose version
```

### 3. Install NVIDIA Container Toolkit

```bash
# Add NVIDIA repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install nvidia-container-toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA runtime
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Verify GPU access in Docker
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

## 📥 Step 1: Download DeepAnalyze Model

Download the DeepAnalyze-8B model from HuggingFace:

```bash
# Install huggingface-cli if not already installed
pip install -U huggingface-hub

# Create models directory
mkdir -p ~/models

# Download the model (this will take some time, ~16GB)
huggingface-cli download RUC-DataLab/DeepAnalyze-8B \
  --local-dir ~/models/DeepAnalyze-8B \
  --local-dir-use-symlinks False
```

**Alternative: Manual download**
```bash
# If you prefer to download manually
cd ~/models
git lfs install
git clone https://huggingface.co/RUC-DataLab/DeepAnalyze-8B
```

## 🐳 Step 2: Prepare Docker Environment

### Option A: Using Docker Compose (Recommended)

```bash
cd /workspace/docker

# Create models and workspace directories
mkdir -p ./models ./workspace

# Copy or symlink your downloaded model
ln -s ~/models/DeepAnalyze-8B ./models/DeepAnalyze-8B

# Verify the model path
ls -la ./models/DeepAnalyze-8B
```

### Option B: Pull Pre-built Docker Image

```bash
# Pull the pre-built environment image (includes vLLM and dependencies)
docker pull facdbe/deepanalyze-env:latest
```

## 🚀 Step 3: Deploy with Docker Compose

### Create Enhanced docker-compose.yml

Create or update `/workspace/docker/docker-compose.yml`:

```yaml
version: '3.8'

services:
  # vLLM Service - Serves the LLM model
  vllm:
    image: facdbe/deepanalyze-env:latest
    container_name: deepanalyze-vllm
    
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1  # Use 1 H100 GPU
              capabilities: [gpu]
    
    ports:
      - "8000:8000"
    
    volumes:
      - ./models:/models
      - ./workspace:/workspace
    
    environment:
      - CUDA_VISIBLE_DEVICES=0
    
    command: >
      python3 -m vllm.entrypoints.openai.api_server
      --model /models/DeepAnalyze-8B
      --host 0.0.0.0
      --port 8000
      --gpu-memory-utilization 0.9
      --max-model-len 32768
      --trust-remote-code
    
    restart: unless-stopped
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Backend API Service
  backend:
    image: facdbe/deepanalyze-env:latest
    container_name: deepanalyze-backend
    
    depends_on:
      - vllm
    
    ports:
      - "8200:8200"
      - "8100:8100"
    
    volumes:
      - ../demo:/app/demo
      - ./workspace:/app/workspace
    
    working_dir: /app/demo
    
    command: python3 backend.py
    
    environment:
      - PYTHONUNBUFFERED=1
    
    restart: unless-stopped

  # Frontend Service
  frontend:
    image: node:18-alpine
    container_name: deepanalyze-frontend
    
    depends_on:
      - backend
    
    ports:
      - "4000:4000"
    
    volumes:
      - ../demo/chat:/app
    
    working_dir: /app
    
    command: sh -c "npm install && npm run dev -- -p 4000"
    
    environment:
      - NEXT_PUBLIC_BACKEND_URL=http://localhost:8200
      - NEXT_PUBLIC_FILE_SERVER_BASE=http://localhost:8100
      - NEXT_PUBLIC_AI_API_URL=http://localhost:8000
    
    restart: unless-stopped
```

### Start All Services

```bash
cd /workspace/docker

# Start all services in detached mode
docker compose up -d

# View logs
docker compose logs -f

# Check service status
docker compose ps
```

## 🔍 Step 4: Verify Deployment

### Check vLLM Service

```bash
# Test vLLM health
curl http://localhost:8000/health

# List available models
curl http://localhost:8000/v1/models

# Test completion
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "DeepAnalyze-8B",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 100
  }'
```

### Check Backend API

```bash
# Test backend health
curl http://localhost:8200/workspace/files?session_id=default

# Test file server
curl http://localhost:8100/
```

### Check Frontend

Open your browser and navigate to:
```
http://localhost:4000
```

Or if accessing remotely:
```
http://<your-server-ip>:4000
```

## 🌐 Step 5: Configure for Remote Access

If you want to access the UI from another machine, you need to update IP addresses:

### Update Backend Configuration

Edit `/workspace/demo/backend.py`:

```python
# Line 125-126
API_BASE = "http://localhost:8000/v1"  # Keep this as localhost (internal)
MODEL_PATH = "DeepAnalyze-8B"

# Line 136-137 - Change localhost to your server IP
HTTP_SERVER_BASE = f"http://<YOUR_SERVER_IP>:{HTTP_SERVER_PORT}"
```

### Update Frontend Configuration

Edit `/workspace/demo/chat/lib/config.ts`:

```typescript
export const API_CONFIG = {
  BACKEND_BASE_URL: "http://<YOUR_SERVER_IP>:8200",
  FILE_SERVER_BASE: "http://<YOUR_SERVER_IP>:8100",
  AI_API_BASE_URL: "http://<YOUR_SERVER_IP>:8000",
  // ...
};
```

### Restart Services

```bash
docker compose restart backend frontend
```

## 📊 Step 6: Usage

1. **Open Web UI**: Navigate to `http://localhost:4000` (or `http://<server-ip>:4000`)

2. **Upload Data Files**: 
   - Click "Upload Files" button
   - Upload CSV, Excel, JSON, or other data files

3. **Ask Questions**:
   - Type your data analysis request
   - Example: "Generate a comprehensive data science report"
   - Example: "Analyze the correlations in this dataset"

4. **Review Results**:
   - DeepAnalyze will analyze, write code, execute it, and provide insights
   - Generated visualizations and files will be downloadable

## 🛠️ Management Commands

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f vllm
docker compose logs -f backend
docker compose logs -f frontend
```

### Restart Services

```bash
# All services
docker compose restart

# Specific service
docker compose restart vllm
```

### Stop Services

```bash
docker compose down
```

### Stop and Remove All Data

```bash
docker compose down -v
rm -rf ./workspace/*
```

### Monitor GPU Usage

```bash
# Watch GPU usage in real-time
watch -n 1 nvidia-smi

# Or check inside container
docker exec deepanalyze-vllm nvidia-smi
```

## 🐛 Troubleshooting

### Issue: vLLM fails to start

**Solution 1**: Check GPU availability
```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

**Solution 2**: Reduce GPU memory usage
```yaml
# In docker-compose.yml, modify vllm command:
--gpu-memory-utilization 0.8  # Reduce from 0.9
```

### Issue: Frontend can't connect to backend

**Solution**: Check that all services are running
```bash
docker compose ps
curl http://localhost:8200/workspace/files?session_id=default
```

### Issue: Out of memory errors

**Solution**: Monitor and adjust settings
```bash
# Check GPU memory
nvidia-smi

# Reduce max model length in docker-compose.yml:
--max-model-len 16384  # Reduce from 32768
```

### Issue: Port already in use

**Solution**: Stop conflicting services
```bash
# Find process using port
sudo lsof -i :8000
sudo lsof -i :8200
sudo lsof -i :4000

# Kill the process
sudo kill -9 <PID>

# Or change ports in docker-compose.yml
```

## 🔒 Security Considerations (Production)

If deploying for production use:

1. **Use HTTPS**: Set up reverse proxy (nginx/traefik) with SSL certificates
2. **Authentication**: Add authentication to the API and frontend
3. **Firewall**: Restrict access to necessary ports only
4. **Resource Limits**: Set memory and CPU limits in docker-compose.yml
5. **Regular Updates**: Keep Docker images and model updated

## 📚 Additional Resources

- **DeepAnalyze Repository**: https://github.com/ruc-datalab/DeepAnalyze
- **Model Page**: https://huggingface.co/RUC-DataLab/DeepAnalyze-8B
- **vLLM Documentation**: https://docs.vllm.ai/
- **Paper**: https://arxiv.org/abs/2510.16872

## ✅ Quick Start Summary

```bash
# 1. Install prerequisites
sudo apt-get update && sudo apt-get install -y docker.io nvidia-container-toolkit
sudo usermod -aG docker $USER

# 2. Download model
pip install -U huggingface-hub
huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ~/models/DeepAnalyze-8B

# 3. Prepare environment
cd /workspace/docker
mkdir -p ./models ./workspace
ln -s ~/models/DeepAnalyze-8B ./models/DeepAnalyze-8B

# 4. Start services
docker compose up -d

# 5. Access UI
# Open browser: http://localhost:4000
```

## 🎉 Success!

You should now have:
- ✅ vLLM serving DeepAnalyze-8B on port 8000
- ✅ Backend API running on port 8200
- ✅ File server running on port 8100  
- ✅ Chat Web UI accessible on port 4000

Enjoy using DeepAnalyze for your data science tasks!
