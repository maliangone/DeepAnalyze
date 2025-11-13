# 🎯 DeepAnalyze Docker Deployment - Complete Summary

## 📦 What Has Been Prepared For You

I've set up a **complete Docker deployment solution** for DeepAnalyze on your H100 GPU Ubuntu server. Here's what you now have:

---

## 🗂️ Files Created

### Documentation
| File | Description |
|------|-------------|
| `DEPLOYMENT_GUIDE.md` | Comprehensive 200+ line deployment guide with troubleshooting |
| `QUICKSTART.md` | Fast 5-minute quick start guide |
| `README.md` | Updated Docker directory README with all commands |
| `DEPLOYMENT_SUMMARY.md` | This summary file |

### Docker Configuration
| File | Description |
|------|-------------|
| `docker-compose-full.yml` | **NEW**: Complete 3-service deployment (vLLM + Backend + Frontend) |
| `docker-compose.yml` | Original configuration (single service) |
| `Dockerfile` | Base image with CUDA 12.1, vLLM, and data science tools |

### Automation Scripts
| Script | Purpose |
|--------|---------|
| `setup.sh` | ✅ Checks prerequisites, creates directories, downloads model |
| `start.sh` | 🚀 Starts all services with health checks |
| `stop.sh` | ⏹️ Stops all services cleanly |
| `logs.sh` | 📋 View logs for all or specific services |
| `health-check.sh` | 🏥 Comprehensive health verification |

---

## 🚀 Deployment Options

### Option 1: Automated (Recommended for First-Time Users)

```bash
# Navigate to docker directory
cd /workspace/docker

# 1. Check prerequisites and setup
./setup.sh

# 2. Download model (if not done by setup.sh)
pip install -U huggingface-hub
huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ./models/DeepAnalyze-8B

# 3. Start everything
./start.sh

# 4. Verify health
./health-check.sh

# 5. Access UI
# Open browser: http://localhost:4000
```

**Estimated Time**: 15-30 minutes (model download takes longest)

---

### Option 2: Manual Step-by-Step (For Advanced Users)

```bash
cd /workspace/docker

# 1. Create directories
mkdir -p models workspace

# 2. Download model
huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ./models/DeepAnalyze-8B

# 3. Pull Docker image
docker pull facdbe/deepanalyze-env:latest

# 4. Start services
docker compose -f docker-compose-full.yml up -d

# 5. Check status
docker compose -f docker-compose-full.yml ps

# 6. View logs
docker compose -f docker-compose-full.yml logs -f
```

---

## 🏗️ Architecture Deployed

```
┌──────────────────────────────────────────────────────────────┐
│                     Your Browser                              │
│                 http://localhost:4000                         │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│  Frontend Container (deepanalyze-frontend)                    │
│  - Next.js Chat UI                                            │
│  - Port: 4000                                                 │
│  - Image: node:18-alpine                                      │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│  Backend Container (deepanalyze-backend)                      │
│  - FastAPI Server                                             │
│  - Ports: 8200 (API), 8100 (Files)                           │
│  - Handles: Chat, File Upload, Code Execution                │
│  - Image: facdbe/deepanalyze-env:latest                      │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────────────┐
│  vLLM Container (deepanalyze-vllm)                           │
│  - DeepAnalyze-8B Model                                       │
│  - Port: 8000                                                 │
│  - GPU: H100 (CUDA 12.1)                                      │
│  - OpenAI-compatible API                                      │
│  - Image: facdbe/deepanalyze-env:latest                      │
└──────────────────────────────────────────────────────────────┘
```

---

## 📊 Resource Requirements

### Hardware
- **GPU**: H100 (✅ You have this)
- **GPU Memory**: ~16GB used by model
- **RAM**: 32GB+ recommended
- **Storage**: 50GB+ (20GB for model, 17GB for Docker images, rest for data)

### Ports Used
| Port | Service | Purpose |
|------|---------|---------|
| 8000 | vLLM | LLM inference API |
| 8100 | File Server | Serve generated files |
| 8200 | Backend API | Chat & file management |
| 4000 | Frontend | Web UI |

---

## ✅ Verification Steps

After starting services, run these commands:

```bash
# 1. Check container status
docker compose -f docker-compose-full.yml ps

# 2. Test vLLM
curl http://localhost:8000/health

# 3. Test Backend
curl http://localhost:8200/workspace/files?session_id=default

# 4. Test Frontend
curl -I http://localhost:4000

# 5. Test GPU access
docker exec deepanalyze-vllm nvidia-smi

# 6. Run comprehensive health check
./health-check.sh
```

**Expected Result**: All commands return success ✅

---

## 🎮 Usage Guide

### 1. Access Web UI
Open browser: `http://localhost:4000`

### 2. Upload Data
- Click "Upload Files" button
- Select CSV, Excel, JSON, TXT, or other data files
- Files are stored in `./workspace/`

### 3. Ask Questions
Example prompts:
- "Generate a comprehensive data analysis report"
- "Find correlations between all variables"
- "Create visualizations for each column"
- "Identify outliers and anomalies"
- "Perform statistical analysis"

### 4. Review Results
- DeepAnalyze will:
  - Analyze your data
  - Write Python code
  - Execute the code
  - Generate visualizations
  - Provide insights
- All generated files are downloadable

---

## 🛠️ Management Commands

```bash
# Start services
./start.sh

# Stop services
./stop.sh

# View all logs
./logs.sh

# View specific service logs
./logs.sh vllm      # LLM service
./logs.sh backend   # API service
./logs.sh frontend  # UI service

# Check health
./health-check.sh

# Restart a specific service
docker compose -f docker-compose-full.yml restart backend

# View GPU usage
nvidia-smi
watch -n 1 nvidia-smi

# View container stats
docker stats
```

---

## 🌐 Remote Access (Optional)

### If accessing from another machine:

**Option A: SSH Tunnel (Recommended)**
```bash
# On your local machine
ssh -L 4000:localhost:4000 -L 8200:localhost:8200 user@server-ip

# Then access: http://localhost:4000
```

**Option B: Configure IPs**

1. Edit `/workspace/demo/backend.py`:
   ```python
   # Line 136
   HTTP_SERVER_BASE = f"http://YOUR_SERVER_IP:8100"
   ```

2. Edit `/workspace/demo/chat/lib/config.ts`:
   ```typescript
   // Lines 4-10
   BACKEND_BASE_URL: "http://YOUR_SERVER_IP:8200",
   FILE_SERVER_BASE: "http://YOUR_SERVER_IP:8100",
   AI_API_BASE_URL: "http://YOUR_SERVER_IP:8000",
   ```

3. Restart:
   ```bash
   ./stop.sh && ./start.sh
   ```

4. Access: `http://YOUR_SERVER_IP:4000`

---

## 🐛 Common Issues & Solutions

### Issue 1: Docker can't find GPU
**Solution:**
```bash
# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### Issue 2: Out of GPU memory
**Solution:**
Edit `docker-compose-full.yml`, in vLLM service:
```yaml
command: >
  python3 -m vllm.entrypoints.openai.api_server
  ...
  --gpu-memory-utilization 0.7  # Reduce from 0.9
  --max-model-len 16384         # Reduce from 32768
```

### Issue 3: Port already in use
**Solution:**
```bash
# Find process using port
sudo lsof -i :8000

# Kill it
sudo kill -9 <PID>

# Or change port in docker-compose-full.yml
```

### Issue 4: Services fail to start
**Solution:**
```bash
# View detailed logs
./logs.sh

# Try restarting
./stop.sh
./start.sh

# If still failing, rebuild
docker compose -f docker-compose-full.yml down -v
docker compose -f docker-compose-full.yml up --build -d
```

---

## 📈 Performance Tuning

### For Better Speed
```yaml
# In docker-compose-full.yml, vLLM service:
--tensor-parallel-size 1      # Use multiple GPUs if available
--max-num-batched-tokens 8192 # Increase for batch processing
```

### For Lower Memory Usage
```yaml
--gpu-memory-utilization 0.7  # Use less GPU memory
--max-model-len 16384         # Reduce context length
--quantization awq            # Use quantization (if model supports)
```

---

## 📚 Next Steps

1. ✅ **Deploy**: Run `./setup.sh` then `./start.sh`
2. ✅ **Verify**: Run `./health-check.sh`
3. ✅ **Access**: Open `http://localhost:4000`
4. ✅ **Test**: Upload a sample CSV and ask for analysis
5. ✅ **Explore**: Read `DEPLOYMENT_GUIDE.md` for advanced features

---

## 📖 Documentation Reference

- **Quick Start**: `QUICKSTART.md` (5 minutes)
- **Full Guide**: `DEPLOYMENT_GUIDE.md` (comprehensive)
- **This Summary**: `DEPLOYMENT_SUMMARY.md`
- **Docker README**: `README.md`

---

## 🆘 Getting Help

1. **Check logs**: `./logs.sh [service]`
2. **Run health check**: `./health-check.sh`
3. **Review troubleshooting**: See `DEPLOYMENT_GUIDE.md` section
4. **GitHub Issues**: https://github.com/ruc-datalab/DeepAnalyze/issues

---

## 🎉 Success Indicators

You're ready when all these are ✅:

- [ ] `./setup.sh` completes without errors
- [ ] Model downloaded to `./models/DeepAnalyze-8B/`
- [ ] `./start.sh` starts all 3 containers
- [ ] `./health-check.sh` passes all checks
- [ ] `http://localhost:4000` shows chat UI
- [ ] You can upload a file and get a response

---

## 🚀 Ready to Deploy!

Everything is prepared. Just run:

```bash
cd /workspace/docker
./setup.sh
./start.sh
```

Then open your browser to **http://localhost:4000** and start analyzing! 🎊

---

**Created for**: H100 GPU Ubuntu Server  
**Ready for**: Local Docker deployment with full GPU acceleration  
**Estimated Setup Time**: 20-30 minutes  
**Difficulty Level**: Easy (automated scripts provided)
