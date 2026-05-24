# 🚀 WAV Transcriber - VPS Deployment Guide

## Overview

Your WAV Transcriber is ready to deploy to your Hetzner VPS as a subdomain: **`transcriber.anothershadeofgrey.com`**

Everything is prepared. This document explains what's been done and what you need to do.

---

## 📋 What's Been Prepared (For You)

| File | What It Does |
|------|-------------|
| **Dockerfile** | Containerizes the FastAPI backend |
| **frontend/Dockerfile** | Containerizes the Vue frontend |
| **docker-compose.prod.yml** | Orchestrates both services for production |
| **QUICK_START.md** | 20-minute deployment quickstart (READ THIS FIRST) |
| **DEPLOYMENT.md** | Complete step-by-step guide with troubleshooting |
| **DEPLOYMENT_CHECKLIST.md** | Checkbox checklist to follow during deployment |
| **DEPLOYMENT_SUMMARY.md** | Architecture overview and file structure |
| **caddy-config-snippet.txt** | Ready-to-paste Caddy reverse proxy config |

---

## 🎯 What You Need to Do (3 Steps)

### Step 1: Update Frontend API URL
**Time: 1 minute**

Edit `frontend/src/App.vue` around line 216:

```javascript
// CHANGE THIS:
const API_BASE_URL = 'http://localhost:8000'

// TO THIS:
const API_BASE_URL = 'https://transcriber.anothershadeofgrey.com'
```

### Step 2: Add DNS Record in Cloudflare
**Time: 2 minutes**

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select `anothershadeofgrey.com`
3. Go to **DNS Records** section
4. Click **Add record**
5. Fill in:
   - Type: `A`
   - Name: `transcriber`
   - Content: `95.217.9.84`
   - TTL: Auto
   - Proxy status: DNS only
6. Click **Save**

### Step 3: Deploy to VPS
**Time: 10-15 minutes**

Follow the step-by-step instructions in **DEPLOYMENT.md** or use the **DEPLOYMENT_CHECKLIST.md**.

Quick overview:
```bash
# SSH into VPS
ssh root@95.217.9.84

# Create directories
mkdir -p ~/apps/transcriber/backend ~/apps/transcriber/uploads
cd ~/apps/transcriber

# Copy your code here (multiple ways shown in DEPLOYMENT.md)

# Create .env with your OPENAI_API_KEY
nano .env

# Update Caddy reverse proxy
nano ~/caddy/Caddyfile

# Deploy
docker compose up -d

# Wait ~3 minutes for build, then visit:
# https://transcriber.anothershadeofgrey.com
```

---

## 📖 Reading Guide

**New to deployment?** Start here:
1. **QUICK_START.md** — 3-step overview
2. **DEPLOYMENT_CHECKLIST.md** — Detailed checklist to follow
3. **DEPLOYMENT.md** — Full guide with explanations

**Experienced with Docker?** Jump to:
- **DEPLOYMENT_SUMMARY.md** — Architecture overview
- **docker-compose.prod.yml** — Docker config
- **caddy-config-snippet.txt** — Reverse proxy setup

---

## 🏗️ Your VPS Architecture

```
Internet (HTTPS)
    ↓
Cloudflare (DNS: transcriber.anothershadeofgrey.com → 95.217.9.84)
    ↓
Caddy (Reverse Proxy - Auto SSL, Port 443)
    ↓
    ├→ FastAPI Backend (port 8000)
    │  - Python 3.10 + FastAPI
    │  - Handles /transcribe requests
    │  - Calls OpenAI Whisper API
    │
    └→ Vue Frontend (port 3000)
       - Node + Vue 3
       - Sends audio files to backend
       - Displays results
```

---

## 🗂️ VPS File Structure After Deployment

```
~/apps/transcriber/
├── .env                              ← Your API key
├── docker-compose.yml
├── uploads/                          ← User files saved here
└── backend/                          ← Your cloned code
    ├── wav_transcriber/              (Python package)
    ├── frontend/                     (Vue app)
    ├── requirements.txt
    ├── Dockerfile
    └── ... rest of project
```

---

## ✅ Deployment Checklist (Quick Version)

- [ ] Update `frontend/src/App.vue` with production URL
- [ ] Add `transcriber` A record in Cloudflare DNS
- [ ] SSH into VPS and create directories
- [ ] Copy code to `~/apps/transcriber/backend/`
- [ ] Create `.env` file with OPENAI_API_KEY
- [ ] Update `~/caddy/Caddyfile` with reverse proxy block
- [ ] Run `caddy reload`
- [ ] Copy `docker-compose.yml` to `~/apps/transcriber/`
- [ ] Run `docker compose up -d`
- [ ] Wait 3 minutes for build
- [ ] Visit `https://transcriber.anothershadeofgrey.com`
- [ ] Verify it loads!

**For detailed checklist:** See `DEPLOYMENT_CHECKLIST.md`

---

## 🔍 Verification Steps

After deployment, verify everything works:

```bash
# 1. Check services are running
docker compose ps

# 2. Test backend API
curl https://transcriber.anothershadeofgrey.com/debug

# 3. Visit in browser
https://transcriber.anothershadeofgrey.com

# 4. Check logs for errors
docker compose logs
```

You should see:
✅ Both services in "Up" state  
✅ Backend returns JSON response  
✅ Browser loads UI without errors  
✅ "WAV Transcriber" title visible  
✅ Drag-and-drop zone present  

---

## 🆘 Troubleshooting

**Service won't start?**
```bash
docker compose logs  # See the error
docker system prune -a  # Clean up
docker compose up -d --build  # Retry
```

**Caddy not proxying?**
```bash
caddy validate  # Check syntax
caddy reload  # Reload config
curl http://localhost:8000  # Test local API
```

**Frontend can't reach backend?**
- Check API_BASE_URL in App.vue is correct
- Check backend logs: `docker compose logs transcriber_backend`
- Check Caddy is properly configured

**Full troubleshooting:** See `DEPLOYMENT.md`

---

## 📊 What Each File Does

### Docker Files
- **Dockerfile** (Backend)
  - Python 3.10 + FastAPI
  - Installs FFmpeg for audio
  - Runs on port 8000

- **frontend/Dockerfile**
  - Node 18 + Vue 3
  - Multi-stage build (optimized)
  - Runs on port 3000

- **docker-compose.prod.yml**
  - Orchestrates both services
  - Creates network communication
  - Mounts volumes for uploads

### Configuration Files
- **.env** (You create this)
  - OPENAI_API_KEY (you provide)
  - Environment settings
  - **KEEP THIS SECRET!**

- **Caddyfile** (You edit this)
  - Reverse proxy configuration
  - Handles SSL automatically
  - Routes to backend:8000

### Documentation Files
- **QUICK_START.md** — 3-step deployment
- **DEPLOYMENT.md** — Full detailed guide
- **DEPLOYMENT_CHECKLIST.md** — Step-by-step checklist
- **DEPLOYMENT_SUMMARY.md** — Architecture & structure
- **caddy-config-snippet.txt** — Caddy config block

---

## ⏱️ Timeline

| Step | Time | Notes |
|------|------|-------|
| Update frontend API | 1 min | One line change |
| Add Cloudflare DNS | 2 min | DNS propagates in ~5 min |
| SSH and copy code | 3 min | Depends on network speed |
| Create .env file | 2 min | Add your API key |
| Update Caddy | 2 min | Paste and reload |
| Docker build | 5-10 min | Depends on internet speed |
| Verification | 5 min | Test in browser |
| **TOTAL** | **20-30 min** | All in, including DNS wait |

---

## 🔐 Security Notes

- ✅ HTTPS automatically via Caddy (free SSL)
- ✅ API key in .env (not in code)
- ✅ .env is in .gitignore
- ✅ Services restart on crash
- ✅ Firewall should allow 80, 443 (HTTP/HTTPS), 22 (SSH only)

---

## 📞 Got Questions?

1. **Read DEPLOYMENT.md** — Most questions answered there
2. **Check DEPLOYMENT_CHECKLIST.md** — See exact steps
3. **View logs** — `docker compose logs` shows what's happening
4. **Test manually** — `curl https://transcriber.anothershadeofgrey.com`

---

## 🎉 Success Indicator

You'll know it worked when:

✅ `docker compose ps` shows both services running  
✅ Browser loads `https://transcriber.anothershadeofgrey.com`  
✅ Page displays transcriber UI  
✅ You can drag files onto the drop zone  
✅ No SSL certificate warnings  
✅ No console errors in browser  

---

## 📝 Next Steps

1. **Read QUICK_START.md** (5 minutes)
2. **Follow DEPLOYMENT_CHECKLIST.md** (20 minutes)
3. **Visit your deployed site** (happy dance 🎉)

---

**Questions about the deployment?** See **DEPLOYMENT.md** for detailed explanations.

**Ready to deploy?** Start with **QUICK_START.md** or **DEPLOYMENT_CHECKLIST.md**.

Good luck! 🚀
