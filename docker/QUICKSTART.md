# 🚀 DeepAnalyze Docker Quick Start

## For Impatient Users (One Command Setup)

```bash
cd /workspace/docker && \
./setup.sh && \
./start.sh
```

Then open: **http://localhost:4000**

---

## Step-by-Step (5 Minutes)

### 1️⃣ Prerequisites
```bash
# Verify you have Docker and NVIDIA toolkit
docker --version
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### 2️⃣ Get the Model
```bash
# Download DeepAnalyze-8B (~16GB, takes 10-20 min)
pip install -U huggingface-hub
cd /workspace/docker
mkdir -p models
huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ./models/DeepAnalyze-8B
```

### 3️⃣ Start Everything
```bash
./setup.sh   # Checks prerequisites
./start.sh   # Starts all services
```

### 4️⃣ Access
- **Web UI**: http://localhost:4000
- **API**: http://localhost:8200
- **vLLM**: http://localhost:8000

---

## 🎯 What Gets Deployed

```
┌─────────────────────────────────┐
│  Frontend (Next.js)   :4000    │  ← Your browser goes here
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│  Backend API (FastAPI) :8200   │  ← Handles files, code execution
│  File Server          :8100   │  ← Serves generated files
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│  vLLM (DeepAnalyze-8B) :8000   │  ← LLM inference on GPU
└─────────────────────────────────┘
```

---

## 📋 Common Commands

```bash
# Start services
./start.sh

# Stop services
./stop.sh

# View logs (all services)
./logs.sh

# View specific service logs
./logs.sh vllm
./logs.sh backend
./logs.sh frontend

# Check status
docker compose -f docker-compose-full.yml ps

# Restart single service
docker compose -f docker-compose-full.yml restart backend

# View GPU usage
watch -n 1 nvidia-smi
```

---

## 🌐 Remote Access Setup

If accessing from another machine:

### Option 1: SSH Tunnel (Secure)
```bash
# On your local machine
ssh -L 4000:localhost:4000 user@your-server-ip

# Then access: http://localhost:4000
```

### Option 2: Expose Ports (Less Secure)
Edit these files to replace `localhost` with your server IP:

1. `/workspace/demo/backend.py` (line 136)
2. `/workspace/demo/chat/lib/config.ts` (lines 4-10)

Then restart:
```bash
./stop.sh && ./start.sh
```

Access: `http://your-server-ip:4000`

---

## 🐛 Troubleshooting

### Services won't start?
```bash
# Check logs
./logs.sh

# Check GPU
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### Out of GPU memory?
Edit `docker-compose-full.yml`, find vLLM service, change:
```yaml
--gpu-memory-utilization 0.7  # Reduce from 0.9
--max-model-len 16384         # Reduce from 32768
```

Then restart: `./stop.sh && ./start.sh`

### Port already in use?
```bash
# Find what's using the port
sudo lsof -i :8000
sudo lsof -i :4000

# Kill it
sudo kill -9 <PID>
```

### Frontend stuck loading?
```bash
# Check if backend is accessible
curl http://localhost:8200/workspace/files?session_id=default

# If not, check backend logs
./logs.sh backend
```

---

## 🎨 Usage Tips

1. **Upload Files**: Click "Upload" button, select your CSV/Excel/JSON files
2. **Ask Questions**: 
   - "Generate a comprehensive data analysis report"
   - "Find correlations in this dataset"
   - "Create visualizations for each variable"
3. **Download Results**: Generated charts, reports, and files are downloadable

---

## 🔧 Advanced Configuration

### Use Less GPU Memory
Edit `docker-compose-full.yml`:
```yaml
vllm:
  command: >
    python3 -m vllm.entrypoints.openai.api_server
    --model /models/DeepAnalyze-8B
    --host 0.0.0.0
    --port 8000
    --gpu-memory-utilization 0.7  # ← Lower this
    --max-model-len 16384          # ← Lower this
```

### Use Multiple GPUs
```yaml
vllm:
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 2  # ← Change this
```

### Persist Data Across Restarts
Already configured! Data is stored in `./workspace/`

---

## 📚 Full Documentation

See `DEPLOYMENT_GUIDE.md` for comprehensive documentation.

---

## ✅ Health Check

Run this to verify everything is working:

```bash
# Test vLLM
curl http://localhost:8000/health

# Test Backend
curl http://localhost:8200/workspace/files?session_id=default

# Test Frontend
curl -I http://localhost:4000

# Test GPU
docker exec deepanalyze-vllm nvidia-smi
```

All should return success!

---

## 🎉 You're Ready!

Open your browser to **http://localhost:4000** and start analyzing data!
