# WAV Transcriber - Deployment Guide

Master guide for deploying WAV Transcriber locally and to production VPS.

**Quick Links:**
- **Local Development:** See [Local Development](#local-development) below
- **VPS Production:** See [VPS Deployment](#vps-deployment) below
- **Manual VPS Setup:** See `vps/manual/INSTRUCTIONS.md` (SSH fallback)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Deployment Options                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  LOCAL DEVELOPMENT (Windows/Mac/Linux)                       │
│  ├─ run.ps1 (Windows) or run.sh (Mac/Linux)                 │
│  ├─ Frontend: http://localhost:5173                          │
│  ├─ Backend: http://localhost:8000                           │
│  └─ For development/testing                                  │
│                                                               │
│  VPS PRODUCTION (Hetzner 95.217.9.84)                        │
│  ├─ Automated: ./vps/deploy.ps1                              │
│  ├─ Manual: See vps/manual/INSTRUCTIONS.md                   │
│  ├─ Frontend: https://transcriber.anothershadeofgrey.com     │
│  ├─ Backend: https://api.anothershadeofgrey.com              │
│  └─ Running in Docker with Caddy reverse proxy               │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Local Development

### Prerequisites
- Python 3.10+
- Node.js 18+
- Virtual environment (`venv`)
- Dependencies installed (`pip install -r requirements.txt`, `npm install` in frontend/)

### Starting Local Dev Server

**Windows:**
```powershell
.\scripts\deploy\local\run.ps1
```

**Mac/Linux:**
```bash
./scripts/deploy/local/run.sh
```

This will:
1. Activate Python virtual environment
2. Install backend dependencies
3. Start backend API on port 8000
4. Install frontend dependencies
5. Start frontend dev server on port 5173

Open: http://localhost:5173

### Redeploying Locally (After Code Changes)

**Windows:**
```powershell
.\scripts\deploy\local\deploy.ps1
```

This script:
- Kills existing processes
- Reinstalls dependencies
- Restarts both services
- Useful for testing changes without manual process management

---

## VPS Deployment

### Quick Start (5 minutes)

**Prerequisites:**
- OpenAI API key
- DNS record configured (see DNS Setup below)
- SSH access to VPS (root@95.217.9.84)

**Steps:**

```powershell
# From your local machine (Windows)
.\scripts\deploy\vps\deploy.ps1

# You'll be prompted for:
# 1. OpenAI API key
# 2. Caddy configuration will be updated automatically

# Wait 2-3 minutes for Docker build
# Then visit: https://transcriber.anothershadeofgrey.com
```

### What the Deployment Script Does

1. **Archives your code** — Excludes `.env`, `.git`, `node_modules`, `venv`, etc.
2. **Uploads to VPS** — Uses SCP to transfer archive securely
3. **Extracts on VPS** — Unpacks to `/root/apps/transcriber/`
4. **Prompts for API key** — Securely creates `.env` file on VPS
5. **Updates Caddy** — Configures reverse proxy for your domain
6. **Builds Docker** — Containerizes backend and frontend
7. **Starts services** — Deploys containers with `docker compose`
8. **Verifies** — Checks both services are running

### DNS Setup (Required First)

Before deploying, create DNS records in Cloudflare:

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select `anothershadeofgrey.com`
3. Go to **DNS Records**
4. Add **A record:**
   - Name: `transcriber`
   - Type: `A`
   - Content: `95.217.9.84`
   - TTL: Auto
   - Proxy: DNS only
5. Click Save (DNS propagates in ~5 minutes)

### VPS File Structure After Deployment

```
/root/apps/transcriber/
├── .env                          ← API key (created by script)
├── docker-compose.yml            ← Production config
├── Dockerfile                    ← Backend container
├── frontend/
│   ├── Dockerfile               ← Frontend container
│   ├── src/
│   ├── package.json
│   └── ... rest of frontend
├── wav_transcriber/              ← Python package
├── requirements.txt
├── config.py
└── uploads/                      ← User uploads stored here
```

### Environment Variables (VPS)

The deployment script creates `.env` with:
```env
OPENAI_API_KEY=sk_your_key_here
ENV=production
```

**IMPORTANT:** `.env` is:
- Created on VPS only (never in archives or git)
- Excluded from the deployment archive for security
- Prompted for during deployment script

### Post-Deployment Verification

After the script completes, verify everything works:

```bash
# SSH into VPS
ssh root@95.217.9.84

# Check services
cd /root/apps/transcriber
docker compose ps

# Expected output:
# NAME                    STATUS
# transcriber_backend     Up ...
# transcriber_frontend    Up ...

# View logs if needed
docker compose logs -f

# Test API
curl https://transcriber.anothershadeofgrey.com/debug

# Visit in browser
https://transcriber.anothershadeofgrey.com
```

**Success indicators:**
✅ Both Docker containers running  
✅ API responds with JSON  
✅ Browser loads transcriber UI  
✅ "WAV Transcriber" title visible  
✅ Drag-and-drop zone present  

### Manual VPS Deployment

If the automated script has issues, follow manual SSH steps:

```bash
ssh root@95.217.9.84
cd scripts/deploy/vps/manual
# See INSTRUCTIONS.md for step-by-step commands
```

---

## Troubleshooting

### Local Development Issues

**Port already in use:**
```powershell
# Windows - find and kill process
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Mac/Linux
lsof -i :8000
kill -9 <PID>
```

**Dependencies not installing:**
```powershell
# Clear pip cache and reinstall
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall
```

**Frontend won't start:**
```powershell
cd frontend
npm cache clean --force
rm -r node_modules
npm install
npm run dev
```

### VPS Deployment Issues

**Docker containers won't start:**
```bash
ssh root@95.217.9.84
cd /root/apps/transcriber

# Check logs
docker compose logs -f

# Clean and rebuild
docker compose down
docker system prune -a
docker compose up -d --build
```

**Caddy not proxying:**
```bash
# Validate config
docker exec caddy caddy validate -c /etc/caddy/Caddyfile

# Reload
docker exec caddy caddy reload -c /etc/caddy/Caddyfile

# Check Caddy logs
docker logs caddy -n 50
```

**Frontend can't reach backend:**
- Check `API_BASE_URL` in `frontend/src/App.vue` is set to `https://transcriber.anothershadeofgrey.com`
- Check backend logs: `docker compose logs transcriber_backend`
- Verify CORS is enabled in FastAPI (should be in `wav_transcriber/api.py`)

**SSL certificate not issued:**
- DNS must propagate first (5-10 minutes)
- Check DNS is resolving: `nslookup transcriber.anothershadeofgrey.com`
- Caddy handles SSL automatically, just wait

**Port conflicts:**
```bash
# Check what's using ports
netstat -tlnp | grep -E '8000|5173|3000'

# Kill if needed
kill -9 <PID>
```

---

## Daily Operations (VPS)

### Viewing Logs
```bash
cd /root/apps/transcriber

# All services
docker compose logs -f

# Just backend
docker compose logs -f transcriber_backend

# Just frontend
docker compose logs -f transcriber_frontend
```

### Restarting Services
```bash
cd /root/apps/transcriber

# Restart all
docker compose restart

# Restart specific service
docker compose restart transcriber_backend

# Stop all
docker compose down

# Start all
docker compose up -d
```

### Updating Code
```bash
cd /root/apps/transcriber

# If using git
git pull

# Rebuild and restart
docker compose build
docker compose up -d

# Or use the deployment script from your local machine
.\scripts\deploy\vps\deploy.ps1
```

### Viewing Uploads
```bash
cd /root/apps/transcriber
ls -la uploads/
```

---

## Security Notes

### Local Development
- `.env` file is in `.gitignore` (never commit)
- API keys stored locally only
- Not accessible from outside your machine

### VPS Production
- HTTPS automatically handled by Caddy (free SSL)
- API key in `.env` on VPS only
- `.env` excluded from deployment archives
- Docker containers restart automatically on crash
- Firewall should allow: 80 (HTTP), 443 (HTTPS), 22 (SSH only)

---

## Architecture Decisions

### Why Docker on VPS?
- **Reproducibility** — Same environment everywhere
- **Isolation** — Services don't interfere with each other
- **Easy updates** — Just rebuild and restart
- **Resource efficiency** — Run multiple apps on one VPS

### Why Caddy?
- **Automatic HTTPS** — Free SSL certificates via Let's Encrypt
- **Reverse proxy** — Routes traffic to backend/frontend
- **Simple config** — Easy to add subdomains later
- **Security headers** — Automatically adds security best practices

### Why tar.gz Archive?
- **Efficiency** — Single file upload instead of thousands of files
- **Security** — Excludes sensitive files (`.env`, `.git`, `node_modules`)
- **Speed** — Faster than SCP for large codebases
- **Reliability** — Atomic transfer (all or nothing)

---

## Scaling to Multiple Subdomains

Once you've deployed transcriber, scaling to other apps is easy:

1. Create new VPS deployment script: `scripts/deploy/vps/deploy-new-app.ps1`
2. Update Caddy config block for new domain
3. Adjust ports (backend: 8001, frontend: 3001, etc.)
4. Run deployment script

Example additional subdomains:
- `api.anothershadeofgrey.com` (currently shares 8000)
- `chat.anothershadeofgrey.com` (new app on 8001/3001)
- `analytics.anothershadeofgrey.com` (another app)

See `DEPLOYMENT-PLAYBOOK.md` in docs for detailed phase-by-phase walkthrough.

---

## Timeline Estimates

| Task | Time | Notes |
|------|------|-------|
| Local dev setup | 5 min | One-time |
| Starting local dev | <1 min | `run.ps1` or `run.sh` |
| Code changes + redeploy | 2-3 min | Using `deploy.ps1` |
| VPS DNS setup | 2 min | Wait 5 min for propagation |
| VPS automated deployment | 10-15 min | Including Docker build |
| VPS manual deployment | 15-20 min | SSH steps (if script fails) |
| **Total first-time VPS** | **20-30 min** | Includes DNS wait |

---

## File Structure

```
scripts/deploy/
├── README.md                  ← You are here
├── local/
│   ├── run.ps1               (Windows local dev startup)
│   ├── run.sh                (Mac/Linux local dev startup)
│   └── deploy.ps1            (Windows local rebuild)
└── vps/
    ├── deploy.ps1            (Automated VPS deployment)
    └── manual/
        └── INSTRUCTIONS.md   (SSH fallback steps)
```

---

## Next Steps

1. **Local Development?** → Run `.\scripts\deploy\local\run.ps1` (Windows) or `./scripts/deploy/local/run.sh` (Mac/Linux)

2. **Deploy to VPS?** → Follow these steps:
   - Add DNS record in Cloudflare (2 minutes)
   - Run `.\scripts\deploy\vps\deploy.ps1` (10 minutes)
   - Visit `https://transcriber.anothershadeofgrey.com`

3. **Manual deployment?** → See `scripts/deploy/vps/manual/INSTRUCTIONS.md`

4. **Full walkthrough?** → See `docs/DEPLOYMENT-PLAYBOOK.md` (comprehensive 11-phase guide)

---

**Status:** ✅ Ready to Deploy  
**Last Updated:** 2026-05-26  
**Architecture:** Vue 3 Frontend + FastAPI Backend + Docker + Caddy Reverse Proxy
