# ✅ DeepAnalyze Deployment Checklist

Use this checklist to deploy DeepAnalyze on your H100 GPU Ubuntu server.

---

## 📋 Pre-Deployment Checklist

### System Requirements
- [ ] Ubuntu 22.04+ installed
- [ ] H100 GPU available (`nvidia-smi` works)
- [ ] 32GB+ RAM
- [ ] 50GB+ free disk space
- [ ] Internet connection for downloads

### Software Prerequisites
- [ ] Docker installed (`docker --version`)
- [ ] Docker Compose available (`docker compose version`)
- [ ] NVIDIA Container Toolkit installed
- [ ] User in docker group (`docker ps` works without sudo)

**Quick Test:**
```bash
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```
✅ Should show your GPU info

---

## 🚀 Deployment Steps

### Step 1: Navigate to Docker Directory
```bash
cd /workspace/docker
```
- [ ] Confirmed in `/workspace/docker/` directory

### Step 2: Run Setup Script
```bash
./setup.sh
```
- [ ] Script checks prerequisites
- [ ] Creates `models/` and `workspace/` directories
- [ ] Pulls Docker image successfully

### Step 3: Download Model
```bash
# Install huggingface-cli if needed
pip install -U huggingface-hub

# Download model (~16GB, takes 10-20 min)
huggingface-cli download RUC-DataLab/DeepAnalyze-8B --local-dir ./models/DeepAnalyze-8B
```
- [ ] Model downloaded to `./models/DeepAnalyze-8B/`
- [ ] File `./models/DeepAnalyze-8B/config.json` exists

**Alternative if you already have the model:**
```bash
ln -s /path/to/existing/DeepAnalyze-8B ./models/DeepAnalyze-8B
```

### Step 4: Start Services
```bash
./start.sh
```
- [ ] vLLM container starts
- [ ] Backend container starts
- [ ] Frontend container starts
- [ ] Script reports all services healthy

### Step 5: Verify Deployment
```bash
./health-check.sh
```
- [ ] Container status: All running
- [ ] GPU status: Accessible
- [ ] vLLM API: Responding
- [ ] Backend API: Responding
- [ ] File Server: Responding
- [ ] Frontend UI: Accessible
- [ ] Model: Loaded successfully
- [ ] Inference: Working

---

## 🧪 Testing Checklist

### Test 1: Access Web UI
```bash
# Open in browser
http://localhost:4000
```
- [ ] Page loads successfully
- [ ] No console errors
- [ ] Chat interface visible

### Test 2: Upload Test File
- [ ] Click "Upload Files" button
- [ ] Select a CSV file
- [ ] File uploads successfully
- [ ] File appears in workspace

### Test 3: Simple Query
Type in chat: "Hi, what can you help me with?"
- [ ] Response starts streaming
- [ ] Response completes
- [ ] No errors shown

### Test 4: Data Analysis (Optional but Recommended)
Upload a CSV file and ask: "Generate a data analysis report"
- [ ] Model analyzes the data
- [ ] Code is generated and shown
- [ ] Code executes successfully
- [ ] Results/visualizations generated
- [ ] Files downloadable

---

## 🔍 Verification Commands

Run these commands and check results:

```bash
# 1. Container status
docker compose -f docker-compose-full.yml ps
```
- [ ] 3 containers running (vllm, backend, frontend)

```bash
# 2. vLLM health
curl http://localhost:8000/health
```
- [ ] Returns success response

```bash
# 3. Backend health
curl http://localhost:8200/workspace/files?session_id=default
```
- [ ] Returns JSON response with files list

```bash
# 4. Frontend
curl -I http://localhost:4000
```
- [ ] Returns HTTP 200 OK

```bash
# 5. GPU access in container
docker exec deepanalyze-vllm nvidia-smi
```
- [ ] Shows GPU info from inside container

```bash
# 6. Model loaded
curl http://localhost:8000/v1/models
```
- [ ] Lists DeepAnalyze-8B model

---

## 🌐 Remote Access Setup (Optional)

If accessing from another machine:

### Option A: SSH Tunnel (Recommended)
```bash
ssh -L 4000:localhost:4000 user@server-ip
```
- [ ] SSH tunnel established
- [ ] Can access http://localhost:4000 on local machine

### Option B: Configure IPs
- [ ] Edit `/workspace/demo/backend.py` (line 136)
- [ ] Edit `/workspace/demo/chat/lib/config.ts` (lines 4-10)
- [ ] Replace `localhost` with server IP
- [ ] Restart services: `./stop.sh && ./start.sh`
- [ ] Can access http://server-ip:4000

---

## 📊 Monitoring Checklist

### Check GPU Usage
```bash
nvidia-smi
```
- [ ] GPU memory used (~16GB for model)
- [ ] GPU utilization shown
- [ ] No errors

### Check Docker Resources
```bash
docker stats
```
- [ ] All containers using resources normally
- [ ] No excessive CPU/memory usage

### Check Logs
```bash
./logs.sh vllm
./logs.sh backend
./logs.sh frontend
```
- [ ] No error messages
- [ ] Services responding normally

---

## 🎯 Success Criteria

You've successfully deployed when:

✅ **All containers running**
```bash
docker compose -f docker-compose-full.yml ps
# Shows 3 containers with status "Up"
```

✅ **Health check passes**
```bash
./health-check.sh
# Shows all checks passed
```

✅ **Web UI accessible**
- Open http://localhost:4000
- Chat interface loads
- Can upload files

✅ **Can perform analysis**
- Upload a CSV file
- Ask for data analysis
- Get response with code and visualizations

---

## 🐛 Troubleshooting Checklist

If something doesn't work:

### Services won't start
- [ ] Run `./logs.sh` to see error
- [ ] Check GPU: `nvidia-smi`
- [ ] Check ports: `sudo lsof -i :8000`
- [ ] Try restart: `./stop.sh && ./start.sh`

### GPU not detected
- [ ] Verify NVIDIA driver: `nvidia-smi`
- [ ] Verify Docker GPU access:
  ```bash
  docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
  ```
- [ ] Reinstall nvidia-container-toolkit if needed

### Out of memory
- [ ] Check GPU memory: `nvidia-smi`
- [ ] Edit `docker-compose-full.yml`
- [ ] Reduce `--gpu-memory-utilization` to 0.7
- [ ] Reduce `--max-model-len` to 16384
- [ ] Restart: `./stop.sh && ./start.sh`

### Port conflicts
- [ ] Find conflicting process: `sudo lsof -i :8000`
- [ ] Kill process: `sudo kill -9 <PID>`
- [ ] Or change port in `docker-compose-full.yml`

### Frontend can't connect to backend
- [ ] Check backend is running: `docker ps`
- [ ] Check backend health:
  ```bash
  curl http://localhost:8200/workspace/files?session_id=default
  ```
- [ ] Check browser console for errors
- [ ] Verify config in `/workspace/demo/chat/lib/config.ts`

---

## 📁 File Structure Verification

Your directory should look like this:

```
/workspace/docker/
├── Dockerfile
├── docker-compose.yml
├── docker-compose-full.yml          ← Use this one
├── README.md
├── DEPLOYMENT_GUIDE.md
├── DEPLOYMENT_SUMMARY.md
├── DEPLOYMENT_CHECKLIST.md          ← You are here
├── QUICKSTART.md
├── setup.sh                         ← Run this first
├── start.sh                         ← Then run this
├── stop.sh
├── logs.sh
├── health-check.sh
├── models/
│   └── DeepAnalyze-8B/
│       ├── config.json              ← Should exist
│       ├── pytorch_model.bin
│       └── ... (other model files)
└── workspace/                       ← Generated files go here
```

- [ ] All scripts exist and are executable
- [ ] Model directory exists with files
- [ ] Workspace directory exists

---

## 🎊 Post-Deployment

After successful deployment:

### Daily Operations
- [ ] Start: `./start.sh`
- [ ] Stop: `./stop.sh`
- [ ] Monitor: `./logs.sh` or `./health-check.sh`

### Maintenance
- [ ] Clean old workspaces: `rm -rf workspace/*`
- [ ] Update Docker images: `docker pull facdbe/deepanalyze-env:latest`
- [ ] Monitor disk space: `df -h`
- [ ] Monitor GPU: `nvidia-smi`

### Backup Important Data
- [ ] Backup generated reports from `workspace/`
- [ ] Document any custom configurations

---

## 📞 Support Resources

If you need help:

1. **Check documentation**
   - [ ] Read QUICKSTART.md
   - [ ] Read DEPLOYMENT_GUIDE.md
   - [ ] Read README.md

2. **Run diagnostics**
   - [ ] `./health-check.sh`
   - [ ] `./logs.sh`
   - [ ] `nvidia-smi`

3. **GitHub**
   - [ ] Check existing issues
   - [ ] Open new issue with logs

---

## ✅ Final Verification

Run this complete verification:

```bash
# 1. Navigate to directory
cd /workspace/docker

# 2. Check all services running
docker compose -f docker-compose-full.yml ps

# 3. Run health check
./health-check.sh

# 4. Test vLLM
curl http://localhost:8000/health

# 5. Test Backend
curl http://localhost:8200/workspace/files?session_id=default

# 6. Test Frontend
curl -I http://localhost:4000

# 7. Test inference
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "DeepAnalyze-8B", "messages": [{"role": "user", "content": "Hi"}], "max_tokens": 20}'
```

All tests should pass ✅

---

## 🎉 Ready!

If all items are checked, you're ready to use DeepAnalyze!

**Access your deployment**: http://localhost:4000

**Start analyzing data!** 🚀

---

**Deployment Date**: _____________  
**Deployed By**: _____________  
**Server IP**: _____________  
**Notes**: _____________
