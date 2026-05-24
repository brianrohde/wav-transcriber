# WAV Transcriber - VPS Deployment Guide
**Environment:** Hetzner VPS (95.217.9.84)  
**Domain:** transcriber.anothershadeofgrey.com  
**Reverse Proxy:** Caddy  

---

## Pre-Deployment Checklist

- [ ] OPENAI_API_KEY available
- [ ] Cloudflare DNS record created for `transcriber` subdomain
- [ ] Caddy configuration updated
- [ ] Code committed and ready to push
- [ ] Docker installed on VPS (should already be there)

---

## Deployment Steps

### 1. SSH into VPS

```bash
ssh root@95.217.9.84
cd ~/apps
```

### 2. Create Transcriber Directory Structure

```bash
mkdir -p transcriber
cd transcriber
mkdir -p backend uploads
```

### 3. Clone or Copy Code to VPS

**Option A: Clone from Git** (if you have a Git repo)
```bash
cd backend
git clone https://github.com/yourusername/wav-transcriber.git .
cd ..
```

**Option B: Copy files via SCP** (from your local machine)
```bash
# From your local machine (in wav-transcriber directory)
scp -r ./* root@95.217.9.84:~/apps/transcriber/backend/
```

### 4. Create .env File

On the VPS:
```bash
nano .env
```

Paste this (update with your actual API key):
```env
OPENAI_API_KEY=sk_your_actual_key_here
ENV=production
API_HOST=0.0.0.0
API_PORT=8000
FRONTEND_URL=https://transcriber.anothershadeofgrey.com
```

Save: `Ctrl+X` → `Y` → `Enter`

### 5. Update Caddy Configuration

On the VPS:
```bash
cd ~/caddy
nano Caddyfile
```

Add this block at the end (before any closing braces):
```caddy
transcriber.anothershadeofgrey.com {
    reverse_proxy localhost:8000 {
        header_uri / ?
        header_down Strict-Transport-Security "max-age=31536000; includeSubDomains"
    }
}
```

Save and reload Caddy:
```bash
caddy reload
```

### 6. Update Frontend API URL

Edit the frontend to use production URL.

On the VPS, edit the App.vue file:
```bash
nano ~/apps/transcriber/backend/frontend/src/App.vue
```

Find this line (around line 216):
```javascript
const API_BASE_URL = 'http://localhost:8000'
```

Replace with:
```javascript
const API_BASE_URL = 'https://transcriber.anothershadeofgrey.com'
```

Save and exit.

### 7. Create Docker Compose File

On the VPS:
```bash
cd ~/apps/transcriber
nano docker-compose.yml
```

Paste this:
```yaml
version: '3.8'

services:
  transcriber-backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: transcriber_backend
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ENV=production
    volumes:
      - ./uploads:/app/uploads
    networks:
      - transcriber_net

  transcriber-frontend:
    build:
      context: ./backend/frontend
      dockerfile: Dockerfile
    container_name: transcriber_frontend
    restart: unless-stopped
    ports:
      - "3000:3000"
    depends_on:
      - transcriber-backend
    networks:
      - transcriber_net

networks:
  transcriber_net:
    driver: bridge
```

Save and exit.

### 8. Build and Deploy

On the VPS:
```bash
cd ~/apps/transcriber
docker compose up -d
```

Monitor the build:
```bash
docker compose logs -f
```

Wait for both services to start (should see "Application startup complete" for backend).

### 9. Verify Deployment

Check services are running:
```bash
docker compose ps
```

Should show:
```
NAME                      STATUS
transcriber_backend       Up
transcriber_frontend      Up
```

Check logs:
```bash
docker compose logs transcriber_backend
docker compose logs transcriber_frontend
```

### 10. Test in Browser

Visit: `https://transcriber.anothershadeofgrey.com`

You should see the transcriber interface!

---

## Cloudflare DNS Setup

1. Go to Cloudflare Dashboard
2. Select `anothershadeofgrey.com`
3. Go to DNS Records
4. Add new record:
   - Type: `CNAME` (or `A`)
   - Name: `transcriber`
   - Content: `95.217.9.84` (or point to existing domain)
   - Proxy status: `DNS only` (or let Caddy handle SSL)
   - TTL: Auto

---

## Troubleshooting

### Port Already in Use
```bash
# Find what's using port 8000
netstat -tlnp | grep 8000

# Kill the process if needed
kill -9 <PID>
```

### Caddy Not Picking Up New Config
```bash
caddy validate  # Check syntax
caddy reload    # Reload config
caddy quit      # Force restart if needed
caddy start     # Start again
```

### Frontend Can't Reach Backend
1. Check backend is running: `curl http://localhost:8000/debug`
2. Check Caddy is proxying: `curl https://transcriber.anothershadeofgrey.com/debug`
3. Check CORS is enabled in FastAPI (should be in api.py)

### Build Fails
```bash
# Clean up and rebuild
docker compose down
docker system prune -a
docker compose up -d --build
```

---

## File Structure on VPS

```
~/apps/transcriber/
├── .env                          (your API key)
├── docker-compose.yml
├── uploads/                      (generated, for file uploads)
├── backend/                      (your cloned code)
│   ├── wav_transcriber/
│   ├── frontend/
│   ├── requirements.txt
│   ├── Dockerfile
│   └── ... rest of project
```

---

## Daily Operations

### View Logs
```bash
cd ~/apps/transcriber
docker compose logs -f transcriber_backend
docker compose logs -f transcriber_frontend
```

### Stop Services
```bash
docker compose down
```

### Restart Services
```bash
docker compose restart
```

### Update Code
```bash
cd ~/apps/transcriber/backend
git pull  # if using git
# or scp files again

cd ..
docker compose up -d --build
```

### View Uploaded Files
```bash
ls -la ~/apps/transcriber/uploads/
```

---

## Security Notes

- [ ] HTTPS is automatically handled by Caddy
- [ ] API key stored in .env (not in code)
- [ ] Caddy handles SSL certificate renewal (automatic)
- [ ] Docker containers run with `restart: unless-stopped`
- [ ] Firewall should only expose ports 80, 443, and 22 (SSH)

---

## Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `OPENAI_API_KEY` | OpenAI API authentication | `sk_...` |
| `ENV` | Environment mode | `production` |
| `API_HOST` | Backend listen address | `0.0.0.0` |
| `API_PORT` | Backend port | `8000` |
| `FRONTEND_URL` | Frontend public URL | `https://transcriber.anothershadeofgrey.com` |

---

## Success Indicators

✅ `docker compose ps` shows both services running  
✅ `curl https://transcriber.anothershadeofgrey.com` returns HTML  
✅ Browser shows the WAV Transcriber interface  
✅ Drag-and-drop zone is visible and interactive  
✅ No errors in `docker compose logs`  

---

**Last Updated:** 2026-05-24  
**Created for:** Transcriber v1.0 Production Deployment
