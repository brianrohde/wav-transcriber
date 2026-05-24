# WAV Transcriber - VPS Deployment Summary

## What's Been Prepared

I've created everything you need to deploy the transcriber to your Hetzner VPS as `transcriber.anothershadeofgrey.com`.

### Files Created Locally (in your wav-transcriber directory)

1. **docker-compose.prod.yml** — Production Docker Compose configuration
   - Builds both backend and frontend
   - Exposes ports 8000 (API) and 5173 (Frontend)
   - Creates network for service communication

2. **Dockerfile** — Backend containerization
   - Python 3.10 slim base
   - Installs FFmpeg for audio processing
   - Runs FastAPI server on port 8000

3. **frontend/Dockerfile** — Frontend containerization
   - Node 18 Alpine (lightweight)
   - Multi-stage build (builder → production)
   - Uses `serve` to run built React app on port 3000

4. **DEPLOYMENT.md** — Complete step-by-step guide
   - 10 deployment steps with exact commands
   - Troubleshooting section
   - Daily operations guide
   - Security checklist

5. **caddy-config-snippet.txt** — Ready-to-add Caddy config
   - Just copy and paste into your Caddyfile
   - Includes security headers
   - Automatic SSL via Caddy

---

## Quick Deployment Path

### Phase 1: Prepare (5 minutes)
```bash
# 1. Get your OPENAI_API_KEY ready
# 2. In Cloudflare, add DNS record:
#    - Name: transcriber
#    - Content: 95.217.9.84
#    - Type: A record
```

### Phase 2: Setup on VPS (10 minutes)
```bash
ssh root@95.217.9.84

# Create directory
mkdir -p ~/apps/transcriber/backend ~/apps/transcriber/uploads
cd ~/apps/transcriber

# Copy your code (from local machine or git)
# If using SCP from your machine:
# scp -r ./backend/* root@95.217.9.84:~/apps/transcriber/backend/

# Create .env file
nano .env
# Paste: OPENAI_API_KEY=sk_your_key_here

# Update Caddy
nano ~/caddy/Caddyfile
# Add the transcriber block
caddy reload
```

### Phase 3: Deploy (5 minutes)
```bash
cd ~/apps/transcriber

# Copy docker-compose.yml (from your code)
# Copy the two Dockerfiles

# Build and start
docker compose up -d

# Watch logs
docker compose logs -f
```

### Phase 4: Verify (2 minutes)
```bash
# Check services
docker compose ps

# Test in browser
# Visit: https://transcriber.anothershadeofgrey.com
```

**Total Time: ~20 minutes**

---

## Your VPS Structure

```
~/
├── caddy/                          (existing)
├── apps/
│   ├── fork-Clean-Clode/          (existing)
│   └── transcriber/               ← NEW
│       ├── .env                   (OPENAI_API_KEY)
│       ├── docker-compose.yml
│       ├── uploads/               (user uploads go here)
│       └── backend/               (your wav-transcriber code)
│           ├── wav_transcriber/
│           ├── frontend/
│           ├── Dockerfile
│           ├── requirements.txt
│           └── ... rest of project
```

---

## Next Steps (in order)

### ✅ Already Done
- [x] Created docker-compose.prod.yml
- [x] Created Dockerfile for backend
- [x] Created Dockerfile for frontend
- [x] Created DEPLOYMENT.md with detailed steps
- [x] Created caddy-config-snippet.txt

### 🔲 You Need to Do
1. **Add Cloudflare DNS Record**
   - Go to Cloudflare dashboard
   - Add: `transcriber` → `95.217.9.84`
   - Proxy: DNS only

2. **Update Frontend API URL** (one line change)
   - Edit `frontend/src/App.vue`
   - Change `API_BASE_URL` from `http://localhost:8000` to `https://transcriber.anothershadeofgrey.com`

3. **Push/Copy Code to VPS**
   ```bash
   # Option 1: Via git (if you have a repo)
   ssh root@95.217.9.84
   cd ~/apps/transcriber/backend
   git clone <your-repo> .
   
   # Option 2: Via SCP (from your local machine)
   scp -r ./backend/* root@95.217.9.84:~/apps/transcriber/backend/
   
   # Option 3: Via git init on server
   # Initialize git on VPS, set origin, push from local
   ```

4. **Follow DEPLOYMENT.md**
   - Create .env file with your OPENAI_API_KEY
   - Add Caddy config block
   - Reload Caddy
   - Run `docker compose up -d`

---

## Key Environment Variables

Create a `.env` file in `~/apps/transcriber/` with:

```env
OPENAI_API_KEY=sk_your_actual_api_key_here
ENV=production
API_HOST=0.0.0.0
API_PORT=8000
FRONTEND_URL=https://transcriber.anothershadeofgrey.com
```

**Important:** Do NOT commit `.env` to git. Use `.gitignore`.

---

## Architecture Overview

```
Internet
   ↓
Cloudflare DNS (transcriber.anothershadeofgrey.com)
   ↓
Caddy Reverse Proxy (port 443/80) ← handles SSL automatically
   ↓
   ├→ Backend (FastAPI on localhost:8000)
   │  - Receives /transcribe requests
   │  - Calls OpenAI Whisper API
   │  - Returns transcription
   │
   └→ Frontend (Vue app on localhost:3000 inside container)
      - Sends files to backend
      - Displays results
      - Manages UI state
```

---

## Testing & Verification

Once deployed, test with:

```bash
# 1. Check services are running
docker compose ps

# 2. Test backend API
curl https://transcriber.anothershadeofgrey.com/debug

# 3. Visit in browser
https://transcriber.anothershadeofgrey.com

# 4. View logs
docker compose logs -f transcriber_backend
```

---

## Rollback / Stop

If something goes wrong:

```bash
cd ~/apps/transcriber

# Stop everything
docker compose down

# Remove all data (careful!)
docker compose down -v

# See logs to debug
docker compose logs
```

---

## File Checklist Before Deploying

You'll need these files on the VPS in `~/apps/transcriber/backend/`:

- [ ] `wav_transcriber/` directory (Python package)
- [ ] `frontend/` directory with all Vue code
- [ ] `requirements.txt` (Python dependencies)
- [ ] `config.py` (configuration file)
- [ ] `Dockerfile` (we created this)
- [ ] `frontend/Dockerfile` (we created this)
- [ ] `frontend/src/App.vue` (with updated API_BASE_URL)

---

## Support Files Included

📄 **DEPLOYMENT.md** — Read this first, detailed step-by-step  
📄 **caddy-config-snippet.txt** — Copy/paste into your Caddyfile  
📄 **docker-compose.prod.yml** — Use this for production  
📄 **Dockerfile** — Backend container  
📄 **frontend/Dockerfile** — Frontend container  

---

## Questions?

- **Port conflicts?** See troubleshooting in DEPLOYMENT.md
- **Caddy not reloading?** Run `caddy validate` to check syntax
- **Frontend can't reach backend?** Check CORS in FastAPI (should be enabled)
- **SSL certificate issues?** Caddy handles this automatically, just wait ~5 minutes

---

**Status:** ✅ Ready to Deploy  
**Estimated Total Time:** 20-30 minutes  
**Estimated Downtime:** 5 minutes (build time)  

Good luck! 🚀
