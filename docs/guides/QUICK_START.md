# WAV Transcriber - VPS Deployment Quick Start

**Goal:** Deploy to `transcriber.anothershadeofgrey.com` in 20 minutes

---

## 3 Things You Must Do

### 1️⃣ Update Frontend API URL (1 line)
```bash
# Edit: frontend/src/App.vue
# Line ~216, change:
const API_BASE_URL = 'http://localhost:8000'
# To:
const API_BASE_URL = 'https://transcriber.anothershadeofgrey.com'
```

### 2️⃣ Add DNS in Cloudflare (2 minutes)
- Name: `transcriber`
- Type: `A`
- Content: `95.217.9.84`
- Click Save

### 3️⃣ Deploy to VPS (10 minutes)
```bash
# SSH into server
ssh root@95.217.9.84

# Create directories
mkdir -p ~/apps/transcriber/backend ~/apps/transcriber/uploads
cd ~/apps/transcriber

# Copy code (replace with actual path)
scp -r /path/to/wav-transcriber/* root@95.217.9.84:~/apps/transcriber/backend/

# On VPS, create .env
nano .env
# Paste:
# OPENAI_API_KEY=sk_your_actual_key_here
# Save: Ctrl+X → Y → Enter

# Update Caddy
nano ~/caddy/Caddyfile
# Add at the end:
# transcriber.anothershadeofgrey.com {
#     reverse_proxy localhost:8000
# }
# Reload
caddy reload

# Deploy
docker compose up -d

# Wait 3 minutes, then visit:
# https://transcriber.anothershadeofgrey.com
```

---

## Done? Verify:

```bash
# Check services
docker compose ps

# Test API
curl https://transcriber.anothershadeofgrey.com/debug

# View browser
https://transcriber.anothershadeofgrey.com
```

✅ Should see the transcriber interface!

---

## Files Prepared For You

| File | Purpose |
|------|---------|
| `Dockerfile` | Backend container |
| `frontend/Dockerfile` | Frontend container |
| `docker-compose.prod.yml` | Production compose setup |
| `DEPLOYMENT.md` | Full detailed guide |
| `DEPLOYMENT_CHECKLIST.md` | Step-by-step checklist |
| `DEPLOYMENT_SUMMARY.md` | Overview & architecture |
| `caddy-config-snippet.txt` | Caddy config block |

---

## If Something Goes Wrong

```bash
# View logs
docker compose logs -f

# Stop everything
docker compose down

# Rebuild
docker compose up -d --build
```

---

**Read DEPLOYMENT.md for full details and troubleshooting!**
