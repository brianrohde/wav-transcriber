# Deployment Troubleshooting Checklist

Quick diagnosis and fixes for common deployment issues.

## Local Development Issues

### Issue: Port Already in Use

**Symptoms:** `Address already in use` error when starting backend/frontend

**Diagnosis:**
```bash
# Check what's using the port
Windows PowerShell:
Get-NetTCPConnection -LocalPort 8000 | Select-Object OwnerProcess
Get-Process -Id [PID]

Mac/Linux:
lsof -i :8000
```

**Fix:**
```bash
# Windows: Kill process by PID
taskkill /PID [PID] /F

# Mac/Linux: Kill process by name
kill -9 $(lsof -t -i :8000)

# Or change port in docker-compose or startup script
# Edit: local/run.ps1 or local/run.sh
```

### Issue: Dependencies Not Installing

**Symptoms:** `ModuleNotFoundError`, `Cannot find module`, missing npm packages

**Diagnosis:**
- Check if `.venv/` (Python) or `node_modules/` (Node) exist
- Verify package file exists: `requirements.txt`, `package.json`
- Check Python/Node version: `python --version`, `node -v`

**Fix:**
```bash
# Backend (Python)
python -m venv venv
source venv/bin/activate  # Mac/Linux
# or: venv\Scripts\activate  # Windows
pip install -r requirements.txt

# Frontend (Node)
cd frontend
npm install
```

### Issue: Frontend Can't Reach Backend API

**Symptoms:** Frontend loads but transcription fails with "Cannot reach API"

**Diagnosis:**
- Check backend is running: `curl http://localhost:8000/health`
- Check frontend environment variables: `VITE_API_URL` or `REACT_APP_API_URL`
- Check CORS settings in backend

**Fix:**
1. Ensure backend is running on port 8000
2. Set frontend environment variable correctly:
   - For local: `VITE_API_URL=http://localhost:8000` (or backend port)
   - For production: `VITE_API_URL=https://api.yourdomain.com`
3. Verify backend has CORS enabled:
   ```python
   from fastapi.middleware.cors import CORSMiddleware
   
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["*"],  # Local dev; restrict in production
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

### Issue: Health Check Failing

**Symptoms:** `Health check returned status code 1`, service crashes immediately

**Diagnosis:**
```bash
# Check service logs
docker logs [container_name]

# Test health check endpoint manually
curl http://localhost:8000/health
curl http://localhost:3000
```

**Fix:**
- Ensure health check endpoint exists and returns 200 status
- Increase health check `start_period` in docker-compose if startup is slow
- Check that required dependencies are installed

---

## VPS Deployment Issues

### Issue: SSH Connection Denied

**Symptoms:** `ssh: connect to host ... refused`, `Permission denied`

**Diagnosis:**
- Check VPS IP address is correct
- Verify SSH key has correct permissions
- Ensure root user is enabled (or correct user is specified)

**Fix:**
```bash
# Verify SSH access (from Windows PowerShell or Mac/Linux)
ssh -i "path/to/key" root@[VPS_IP]

# If using key file:
chmod 600 /path/to/key  # Mac/Linux only
ssh -i /path/to/key root@[VPS_IP]

# If password auth:
ssh root@[VPS_IP]  # Then enter password
```

### Issue: Docker Not Running on VPS

**Symptoms:** `docker: command not found`, `docker daemon not running`

**Diagnosis:**
```bash
# SSH into VPS
ssh root@[VPS_IP]

# Check if Docker is installed
docker --version

# Check if daemon is running
systemctl status docker
```

**Fix:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Start Docker
systemctl start docker
systemctl enable docker  # Enable on boot

# Verify
docker ps
```

### Issue: Caddy Certificate Generation Fails

**Symptoms:** `ACME challenge failed`, SSL certificate not issued, HTTPS doesn't work

**Diagnosis:**
```bash
# SSH into VPS
ssh root@[VPS_IP]

# Check Caddy logs
docker logs caddy

# Verify DNS is pointing to VPS
nslookup yourdomain.com
# Should return VPS IP address

# Check if port 80/443 are open
netstat -tlnp | grep ':80\|:443'
```

**Fix:**
1. **Verify DNS:** A record must point to VPS IP
   - Check Cloudflare DNS settings
   - Wait 5-10 minutes for propagation
   - Verify: `nslookup yourdomain.com`

2. **Check port access:**
   - Ensure firewall allows ports 80 and 443
   - On Hetzner: Check firewall rules in console
   - On DigitalOcean: Check Security Groups

3. **Check Caddy configuration:**
   ```bash
   # Inside VPS
   cat /root/caddy/Caddyfile
   
   # Validate syntax
   docker exec caddy caddy validate -c /etc/caddy/Caddyfile
   ```

4. **Restart Caddy:**
   ```bash
   docker exec caddy caddy reload -c /etc/caddy/Caddyfile
   docker restart caddy
   ```

### Issue: Docker Containers Won't Start

**Symptoms:** `docker compose up` fails, `docker-compose.yml error`

**Diagnosis:**
```bash
# SSH into VPS
ssh root@[VPS_IP]

# Navigate to app directory
cd /root/apps/[app_name]

# Check docker-compose syntax
docker-compose config

# View logs
docker-compose logs -f
docker logs [container_name]
```

**Fix:**
1. **Check file syntax:** `docker-compose config` should output valid YAML
2. **Check environment variables:**
   ```bash
   cat .env  # Should contain required variables
   # Should have: OPENAI_API_KEY, DB_PASSWORD, etc.
   ```
3. **Check volume paths:** Ensure directories exist
   ```bash
   ls -la /root/apps/[app_name]/uploads/
   ```
4. **Check port conflicts:**
   ```bash
   netstat -tlnp | grep LISTEN  # See all listening ports
   ```

### Issue: Backend and Frontend Can't Communicate on VPS

**Symptoms:** Frontend loads but fails to reach API, CORS errors in browser console

**Diagnosis:**
```bash
# SSH into VPS
ssh root@[VPS_IP]

# Check if services are running
docker ps -a

# Test backend directly
docker exec -it [backend_container] curl http://localhost:8000/health

# Check Caddy routing
docker exec caddy caddy list-routes
```

**Fix:**
1. **Verify docker-compose networking:**
   ```yaml
   networks:
     app_net:
       driver: bridge
   
   # All services should be on same network
   ```

2. **Check Caddy reverse proxy config:**
   ```
   api.yourdomain.com {
     reverse_proxy localhost:8000
   }
   
   yourdomain.com {
     reverse_proxy localhost:5173
   }
   ```

3. **Verify environment variables in frontend:**
   - Should have `API_URL=https://api.yourdomain.com`
   - Check docker-compose.yml for environment block

4. **Check CORS in backend:**
   - Ensure CORS allows requests from frontend domain
   - In production, specify exact origin (not `*`)

### Issue: Port Conflicts on VPS

**Symptoms:** `Address already in use`, service won't bind to port

**Diagnosis:**
```bash
# Check all listening ports
netstat -tlnp | grep LISTEN

# Check specific port
netstat -tlnp | grep :8000
```

**Fix:**
```bash
# If port is in use, kill the process
lsof -i :8000  # Find PID
kill -9 [PID]

# Or use different port in docker-compose.yml:
ports:
  - "8001:8000"  # Use 8001 instead of 8000

# Then update Caddy config:
api.yourdomain.com {
  reverse_proxy localhost:8001  # Changed from 8000
}
```

---

## Archive & Deployment Issues

### Issue: Archive Upload Fails

**Symptoms:** `SCP error`, `file not found`, transfer timeout

**Diagnosis:**
```powershell
# Check archive exists
Test-Path "archive.tar.gz"

# Check file size
(Get-Item "archive.tar.gz").Length / 1MB  # Size in MB
```

**Fix:**
- Ensure archive is created successfully (check deployment script output)
- Check file isn't corrupted: `tar -tzf archive.tar.gz | head -20`
- If file is very large (>500MB), split into chunks or use rsync
- Verify SSH connection works before uploading

### Issue: Archive Extraction Fails

**Symptoms:** `tar: unable to open archive`, `unexpected end of archive`

**Diagnosis:**
```bash
# SSH into VPS
ssh root@[VPS_IP]

# Check archive integrity
tar -tzf /root/apps/[app_name]/archive.tar.gz | head -20

# Check available space
df -h /root/apps/
```

**Fix:**
- Ensure enough disk space: `df -h` should show >2GB free
- Re-upload archive if corrupted
- Check tar command: should be `tar -xzf archive.tar.gz`

---

## DNS & Domain Issues

### Issue: Domain Not Resolving

**Symptoms:** `Cannot reach yourdomain.com`, `DNS resolution failed`

**Diagnosis:**
```bash
# Check DNS records (from local machine)
nslookup yourdomain.com
dig yourdomain.com

# Should return VPS IP address
# Compare with: ping yourdomain.com
```

**Fix:**
1. **Check Cloudflare DNS:**
   - A record should point to VPS IP
   - CNAME for subdomains should point to root domain
   - Ensure DNS is not proxied (orange cloud) if using Caddy

2. **Wait for propagation:**
   - DNS changes can take 5-30 minutes
   - Check propagation: https://dnschecker.org

3. **Clear DNS cache:**
   ```bash
   # Mac
   dscacheutil -flushcache
   
   # Linux
   sudo systemctl restart systemd-resolved
   
   # Windows PowerShell
   ipconfig /flushdns
   ```

### Issue: HTTPS Certificate Not Issued

**Symptoms:** Browser shows "self-signed certificate", `NET::ERR_CERT_AUTHORITY_INVALID`

**Diagnosis:**
- Check Let's Encrypt logs: `docker logs caddy | grep ACME`
- Verify DNS is resolving: `nslookup yourdomain.com`
- Check ports 80/443 are open

**Fix:**
- Same as "Caddy Certificate Generation Fails" above

---

## Environment & Configuration Issues

### Issue: Environment Variables Not Loaded

**Symptoms:** API key not found, `KeyError: 'OPENAI_API_KEY'`

**Diagnosis:**
```bash
# Check .env file exists and has correct format
cat .env

# Check environment variables inside container
docker exec [container_name] env | grep OPENAI
```

**Fix:**
1. **Recreate .env file:**
   ```bash
   # Should have format: KEY=value (no quotes)
   cat > .env <<EOF
   OPENAI_API_KEY=sk-your-key-here
   ENV=production
   EOF
   ```

2. **Rebuild and restart:**
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

### Issue: Wrong Python/Node Version in Container

**Symptoms:** `SyntaxError` (Python version mismatch), `TypeError` (Node version issue)

**Diagnosis:**
```bash
# Check version in Dockerfile
grep "FROM python\|FROM node" Dockerfile

# Check inside container
docker exec [container_name] python --version
docker exec [container_name] node --version
```

**Fix:**
- Update Dockerfile FROM statement to correct version
- Rebuild: `docker-compose build --no-cache`
- Restart: `docker-compose up -d`

---

## Monitoring & Logging

### View Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f [service_name]

# Last N lines
docker-compose logs --tail=50

# Show logs with timestamps
docker-compose logs --timestamps
```

### Monitor Resource Usage

```bash
# Check CPU/memory
docker stats [container_name]

# Check disk space
df -h
du -sh /root/apps/*

# Check running processes
docker ps
docker-compose ps
```

### Restart Services

```bash
# Restart one service
docker-compose restart [service_name]

# Restart all services
docker-compose restart

# Stop and start (more thorough)
docker-compose down
docker-compose up -d

# Rebuild and restart
docker-compose up -d --build
```

---

## Prevention Checklist

- [ ] Test deployment locally first (`./local/run.ps1` or `./local/run.sh`)
- [ ] Verify all environment variables are set
- [ ] Check firewall rules allow ports 80, 443, and app ports
- [ ] Ensure DNS is properly configured (A record points to VPS IP)
- [ ] Verify .env file has correct format and values
- [ ] Test HTTPS before switching to production
- [ ] Monitor logs regularly: `docker-compose logs -f`
- [ ] Set up backup strategy for persistent data
- [ ] Document custom port numbers and subdomains
- [ ] Keep Docker images updated

---

For more detailed guidance, see:
- `scripts/deploy/README.md` → Troubleshooting section
- `scripts/deploy/DEPLOYMENT-PLAYBOOK.md` → Phase-specific guidance
- `scripts/deploy/vps/manual/INSTRUCTIONS.md` → Step-by-step fallback
