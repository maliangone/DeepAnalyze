# 🐳 DeepAnalyze Docker Deployment

Complete Docker setup for deploying DeepAnalyze with GPU acceleration on your H100 server.

## 🎯 What You Get

A fully containerized deployment with:
- **vLLM Service**: DeepAnalyze-8B model with GPU acceleration (port 8000)
- **Backend API**: FastAPI server for chat and file management (port 8200)
- **File Server**: Static file serving for generated content (port 8100)
- **Web UI**: Next.js chat interface (port 4000)

## ⚡ Quick Start (3 Steps)

### 1. Run Setup
```bash
cd /workspace/docker
./setup.sh
```

### 2. Download Model
```bash
pip install -U huggingface-hub
huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ./models/DeepAnalyze-8B
```

### 3. Start Services
```bash
./start.sh
```

**Access UI**: http://localhost:4000

---

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Fast 5-minute guide
- **[DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md)** - Comprehensive deployment documentation

---

## 🛠️ Management Scripts

| Script | Description |
|--------|-------------|
| `./setup.sh` | Check prerequisites and prepare environment |
| `./start.sh` | Start all services |
| `./stop.sh` | Stop all services |
| `./logs.sh [service]` | View logs (all or specific service) |
| `./health-check.sh` | Verify all services are healthy |

---

## 📋 Available Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Original Docker Compose config |
| `docker-compose-full.yml` | Enhanced config with all 3 services |
| `Dockerfile` | Base image with vLLM and dependencies |
| `setup.sh` | Environment setup script |
| `start.sh` | Service startup script |
| `stop.sh` | Service shutdown script |
| `logs.sh` | Log viewing script |
| `health-check.sh` | Health check script |

---

## 🔧 Common Commands

```bash
# Start everything
./start.sh

# Stop everything
./stop.sh

# View all logs
./logs.sh

# View specific service logs
./logs.sh vllm
./logs.sh backend
./logs.sh frontend

# Check health
./health-check.sh

# Check status
docker compose -f docker-compose-full.yml ps

# Restart a service
docker compose -f docker-compose-full.yml restart backend
```

---

## 🐛 Troubleshooting

### Services won't start?
```bash
./logs.sh  # Check what's failing
```

### GPU not detected?
```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### Port conflicts?
```bash
sudo lsof -i :8000  # Check what's using the port
```

### Out of GPU memory?
Edit `docker-compose-full.yml` and reduce `--gpu-memory-utilization` from 0.9 to 0.7

---

## 🌐 Remote Access

### Option 1: SSH Tunnel (Secure)
```bash
ssh -L 4000:localhost:4000 user@server-ip
# Access: http://localhost:4000
```

### Option 2: Configure IPs
1. Edit `/workspace/demo/backend.py` (line 136): Change `localhost` to your server IP
2. Edit `/workspace/demo/chat/lib/config.ts` (lines 4-10): Update all URLs
3. Restart: `./stop.sh && ./start.sh`

---

## 📦 Docker Images

### Pre-built Image (Recommended)
```bash
docker pull facdbe/deepanalyze-env:latest
```

### Build from Source
```bash
docker build -t deepanalyze-env:latest .
```

### Image Contents
- **Base**: NVIDIA CUDA 12.1 on Ubuntu 22.04
- **Python**: 3.10+ with pip
- **ML Stack**: vLLM, PyTorch, Transformers
- **Data Science**: pandas, numpy, scipy, matplotlib, seaborn, plotly, etc.
- **Size**: ~17GB

---

## 🔍 Health Checks

Run comprehensive health check:
```bash
./health-check.sh
```

This checks:
- Container status
- GPU accessibility
- Service endpoints
- Model loading
- Inference capability

---

## 📊 Monitoring

### View GPU Usage
```bash
watch -n 1 nvidia-smi
```

### View Container GPU Usage
```bash
docker exec deepanalyze-vllm nvidia-smi
```

### View Container Stats
```bash
docker stats
```

---

## 🔒 Production Notes

For production deployments:
1. Set up HTTPS with nginx/traefik
2. Add authentication
3. Configure firewall rules
4. Set resource limits in docker-compose.yml
5. Use secrets management for API keys

---

## 📧 Support

- **Issues**: https://github.com/ruc-datalab/DeepAnalyze/issues
- **Documentation**: See DEPLOYMENT_GUIDE.md
- **Model**: https://huggingface.co/RUC-DataLab/DeepAnalyze-8B

---

## ✅ Quick Health Check

```bash
curl http://localhost:8000/health        # vLLM
curl http://localhost:8200/workspace/files?session_id=default  # Backend
curl http://localhost:4000               # Frontend
```

All should return success!

---

## 🎉 Next Steps

1. Access UI at http://localhost:4000
2. Upload your data files (CSV, Excel, JSON, etc.)
3. Ask questions like:
   - "Generate a comprehensive data analysis report"
   - "Find correlations and create visualizations"
   - "Analyze patterns in this dataset"

Happy analyzing! 🚀
