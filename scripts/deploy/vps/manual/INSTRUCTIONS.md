# Manual VPS Deployment Guide

If the automated script has issues, follow these steps manually via SSH.

## Prerequisites
- SSH access to your VPS: `ssh root@95.217.9.84`
- Your OpenAI API key ready
- Code archive ready (created with tar command)

## Step 1: Prepare VPS Directory

```bash
ssh root@95.217.9.84

# Create app directory
mkdir -p /root/apps/transcriber
cd /root/apps/transcriber
```

## Step 2: Copy Code (from Windows)

```powershell
# From your Windows terminal (NOT SSH):
scp C:\Users\brian\AppData\Local\Temp\transcriber.tar.gz root@95.217.9.84:/root/apps/transcriber/
```

## Step 3: Extract Code on VPS

```bash
# Back in SSH session:
cd /root/apps/transcriber
tar -xzf transcriber.tar.gz
rm transcriber.tar.gz
ls -la
```

## Step 4: Create .env File

```bash
# Create environment file
cat > /root/apps/transcriber/.env << 'EOF'
OPENAI_API_KEY=your-key-here
ENV=production
EOF

# Verify it was created
cat /root/apps/transcriber/.env
```

## Step 5: Setup Docker Compose

```bash
cd /root/apps/transcriber

# Rename production compose file
mv docker-compose.prod.yml docker-compose.yml

# Verify
ls docker-compose.yml
```

## Step 6: Update Caddy Configuration

```bash
# Append transcriber config to Caddyfile
cat >> /root/caddy/Caddyfile << 'EOF'

# WAV Transcriber
transcriber.anothershadeofgrey.com {
  reverse_proxy localhost:5173
  header / {
    Strict-Transport-Security "max-age=31536000; includeSubDomains"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "SAMEORIGIN"
    X-XSS-Protection "1; mode=block"
    Referrer-Policy "strict-origin-when-cross-origin"
  }
}

api.anothershadeofgrey.com {
  reverse_proxy localhost:8000
  header / {
    Strict-Transport-Security "max-age=31536000; includeSubDomains"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "SAMEORIGIN"
  }
}
EOF

# Verify the config was added
tail -30 /root/caddy/Caddyfile
```

## Step 7: Reload Caddy

```bash
# Reload Caddy reverse proxy
docker exec caddy caddy reload -c /etc/caddy/Caddyfile

# Check Caddy logs to verify
docker logs caddy -n 20
```

## Step 8: Build and Start Docker Containers

```bash
cd /root/apps/transcriber

# Build images (takes 2-3 minutes)
docker compose build

# Start services
docker compose up -d

# Check status
docker compose ps
```

Expected output:
```
NAME                        COMMAND                  SERVICE              STATUS
transcriber_backend         "python -m wav_tran…"    transcriber-backend  Up ...
transcriber_frontend        "serve -s dist -l 3…"    transcriber-frontend Up ...
```

## Step 9: Verify Everything Works

```bash
# Check container logs
docker compose logs -f

# Once backend and frontend are running, visit:
# https://transcriber.anothershadeofgrey.com

# Check if containers are healthy
docker compose ps
curl http://localhost:8000/health
```

## Troubleshooting

### Containers won't start
```bash
# Check logs
docker compose logs transcriber-backend
docker compose logs transcriber-frontend

# Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Caddy reload fails
```bash
# Check Caddy syntax
docker exec caddy caddy validate --config /etc/caddy/Caddyfile

# Restart Caddy
docker restart caddy
```

### Port already in use
```bash
# Check what's using the ports
netstat -tulpn | grep -E '8000|5173'

# Kill the process if needed
kill -9 <PID>
```

### Frontend can't reach backend
```bash
# Verify API URL in production:
# frontend/src/App.vue should have:
# const API_BASE_URL = 'https://api.anothershadeofgrey.com'

# Rebuild frontend
docker compose build transcriber-frontend
docker compose up -d transcriber-frontend
```

## Post-Deployment

1. **Check DNS propagation** (1-2 minutes):
   ```bash
   # From your local machine
   nslookup transcriber.anothershadeofgrey.com
   ```

2. **Visit the site**:
   - Frontend: https://transcriber.anothershadeofgrey.com
   - API: https://api.anothershadeofgrey.com

3. **Monitor logs**:
   ```bash
   # Backend logs
   docker compose logs -f transcriber-backend

   # Frontend logs
   docker compose logs -f transcriber-frontend
   ```

## Daily Operations

```bash
# Start/stop services
cd /root/apps/transcriber
docker compose up -d          # Start
docker compose down           # Stop
docker compose restart        # Restart

# View logs
docker compose logs -f        # All services
docker compose logs transcriber-backend -f  # Just backend

# Update code (after git pull)
cd /root/apps/transcriber
docker compose build
docker compose up -d
```
