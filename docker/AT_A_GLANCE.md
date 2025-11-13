# 🎯 DeepAnalyze Docker Deployment - At A Glance

## 🚀 3-Step Deployment

```bash
cd /workspace/docker
./setup.sh                      # Check prerequisites
./start.sh                      # Start services
```
**Access**: http://localhost:4000

---

## 📦 What Gets Deployed

| Service | Port | Container | Purpose |
|---------|------|-----------|---------|
| Frontend | 4000 | deepanalyze-frontend | Next.js Chat UI |
| Backend | 8200 | deepanalyze-backend | FastAPI Server |
| Files | 8100 | deepanalyze-backend | File Server |
| vLLM | 8000 | deepanalyze-vllm | LLM Inference (GPU) |

---

## 📋 Quick Commands

```bash
./setup.sh              # Initial setup
./start.sh              # Start all services
./stop.sh               # Stop all services
./logs.sh               # View all logs
./logs.sh vllm          # View specific service
./health-check.sh       # Check system health
```

---

## 🔍 Quick Health Check

```bash
curl http://localhost:8000/health                              # vLLM
curl http://localhost:8200/workspace/files?session_id=default  # Backend
curl http://localhost:4000                                     # Frontend
```

---

## 📊 Resource Usage

- **GPU**: ~16GB (H100)
- **RAM**: ~8GB
- **Disk**: ~40GB (model + images + data)
- **Ports**: 4000, 8000, 8100, 8200

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| GPU not detected | `nvidia-smi` then reinstall nvidia-container-toolkit |
| Out of memory | Edit docker-compose-full.yml, reduce `--gpu-memory-utilization` |
| Port in use | `sudo lsof -i :8000` then `sudo kill -9 <PID>` |
| Services fail | `./logs.sh` then `./stop.sh && ./start.sh` |

---

## 📚 Documentation

| File | Use Case |
|------|----------|
| **AT_A_GLANCE.md** | Quick reference (you are here) |
| **QUICKSTART.md** | 5-minute setup guide |
| **DEPLOYMENT_CHECKLIST.md** | Step-by-step checklist |
| **DEPLOYMENT_SUMMARY.md** | Complete overview |
| **DEPLOYMENT_GUIDE.md** | Comprehensive guide |
| **README.md** | Docker directory README |

---

## 🌐 Remote Access

**SSH Tunnel (Easy)**:
```bash
ssh -L 4000:localhost:4000 user@server-ip
# Access: http://localhost:4000
```

**Direct Access**: Edit IPs in:
- `/workspace/demo/backend.py` (line 136)
- `/workspace/demo/chat/lib/config.ts` (lines 4-10)

---

## 🎯 Files Created for You

### Documentation (6 files)
- ✅ DEPLOYMENT_GUIDE.md (comprehensive)
- ✅ DEPLOYMENT_SUMMARY.md (overview)
- ✅ DEPLOYMENT_CHECKLIST.md (step-by-step)
- ✅ QUICKSTART.md (5-minute guide)
- ✅ AT_A_GLANCE.md (this file)
- ✅ README.md (updated)

### Scripts (5 files)
- ✅ setup.sh (setup & checks)
- ✅ start.sh (start services)
- ✅ stop.sh (stop services)
- ✅ logs.sh (view logs)
- ✅ health-check.sh (verify health)

### Docker Config (1 file)
- ✅ docker-compose-full.yml (3-service deployment)

---

## ⚡ Common Usage Patterns

### Daily Use
```bash
./start.sh              # Morning
# ... use DeepAnalyze all day ...
./stop.sh               # Evening
```

### Monitoring
```bash
./logs.sh               # View logs
./health-check.sh       # Check health
nvidia-smi              # Check GPU
docker stats            # Check resources
```

### Troubleshooting
```bash
./logs.sh vllm          # If vLLM issues
./logs.sh backend       # If backend issues
./logs.sh frontend      # If frontend issues
./stop.sh && ./start.sh # Try restart
```

---

## 🎊 Success Indicators

You're ready when:
- ✅ `./health-check.sh` passes all checks
- ✅ http://localhost:4000 shows chat UI
- ✅ Can upload file and get response
- ✅ No errors in `./logs.sh`

---

## 📞 Quick Help

1. **Not working?** → `./logs.sh`
2. **Still stuck?** → Read DEPLOYMENT_GUIDE.md
3. **Need help?** → GitHub issues

---

## 🎉 That's It!

**Start**: `cd /workspace/docker && ./setup.sh && ./start.sh`  
**Use**: http://localhost:4000  
**Stop**: `./stop.sh`

**Happy Analyzing!** 🚀
