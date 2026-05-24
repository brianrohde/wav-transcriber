# WAV Transcriber - Deployment Checklist

## Pre-Deployment (Do these first)

- [ ] Have your OPENAI_API_KEY ready
- [ ] Commit all local changes to git
- [ ] Review DEPLOYMENT_SUMMARY.md
- [ ] Read DEPLOYMENT.md completely

## DNS Setup (Cloudflare)

- [ ] Log into Cloudflare dashboard
- [ ] Navigate to anothershadeofgrey.com
- [ ] Go to DNS Records
- [ ] Create A record:
  - Name: `transcriber`
  - Type: `A`
  - Content: `95.217.9.84`
  - TTL: Auto
  - Proxy status: DNS only
- [ ] Wait 5 minutes for DNS to propagate

## Code Preparation (Local Machine)

- [ ] Update `frontend/src/App.vue` line ~216:
  ```javascript
  const API_BASE_URL = 'https://transcriber.anothershadeofgrey.com'
  ```
- [ ] Verify Dockerfiles are in place:
  - [ ] `Dockerfile` (backend)
  - [ ] `frontend/Dockerfile`
  - [ ] `docker-compose.prod.yml`
- [ ] Verify `requirements.txt` exists
- [ ] Verify `frontend/package.json` exists

## VPS Setup (SSH into 95.217.9.84)

### Directory Structure
```bash
ssh root@95.217.9.84
```

- [ ] Create directories:
  ```bash
  mkdir -p ~/apps/transcriber/backend ~/apps/transcriber/uploads
  cd ~/apps/transcriber
  ```

### Copy Code to VPS
Choose one method:

**Method 1: Using Git**
```bash
cd ~/apps/transcriber/backend
git clone <your-repo-url> .
cd ..
```
- [ ] Code cloned successfully

**Method 2: Using SCP** (from local machine, run in your project directory)
```bash
scp -r ./* root@95.217.9.84:~/apps/transcriber/backend/
```
- [ ] Files copied successfully

**Method 3: Manual** (if neither above works)
```bash
cd ~/apps/transcriber/backend
nano Dockerfile  # paste the Dockerfile content
cd ../
nano docker-compose.yml  # paste docker-compose.prod.yml content
# ... copy other files similarly
```

### Create .env File
```bash
cd ~/apps/transcriber
nano .env
```

- [ ] Paste this (replace with your actual key):
  ```env
  OPENAI_API_KEY=sk_your_actual_key_here
  ENV=production
  API_HOST=0.0.0.0
  API_PORT=8000
  FRONTEND_URL=https://transcriber.anothershadeofgrey.com
  ```
- [ ] Save file (Ctrl+X → Y → Enter)

## Caddy Configuration

```bash
cd ~/caddy
nano Caddyfile
```

- [ ] Add this block at the end (before any closing braces):
  ```caddy
  transcriber.anothershadeofgrey.com {
      reverse_proxy localhost:8000 {
          header_uri / ?
          header_down Strict-Transport-Security "max-age=31536000; includeSubDomains"
      }
  }
  ```
- [ ] Save file

- [ ] Validate Caddy config:
  ```bash
  caddy validate
  ```
  - [ ] Shows "valid" message

- [ ] Reload Caddy:
  ```bash
  caddy reload
  ```
  - [ ] No errors returned

## Docker Deployment

```bash
cd ~/apps/transcriber
```

- [ ] Verify docker-compose.yml is in this directory
- [ ] Build and start containers:
  ```bash
  docker compose up -d --build
  ```
  - [ ] No errors during build

- [ ] Wait 2-3 minutes for build to complete

- [ ] Check services are running:
  ```bash
  docker compose ps
  ```
  - [ ] `transcriber_backend` shows "Up"
  - [ ] `transcriber_frontend` shows "Up"

- [ ] Check logs for errors:
  ```bash
  docker compose logs
  ```
  - [ ] Backend shows "Application startup complete"
  - [ ] Frontend shows "serving" or similar
  - [ ] No red error messages

## Verification

### Test API Endpoint
```bash
curl https://transcriber.anothershadeofgrey.com/debug
```
- [ ] Returns JSON (not an error page)

### Test in Browser
```
https://transcriber.anothershadeofgrey.com
```
- [ ] Page loads without errors
- [ ] Drag-and-drop zone is visible
- [ ] "Maximum file size: 500MB" is shown
- [ ] Title "WAV Transcriber" is visible with new font
- [ ] No console errors (F12 → Console tab)

### Test Functionality (Optional - requires microphone audio)
- [ ] Can drag a .wav file onto the drop zone
- [ ] File info appears with size and duration
- [ ] Can click "Transcribe" button
- [ ] Backend processes (watch logs: `docker compose logs -f`)
- [ ] Result appears in UI

## Post-Deployment

- [ ] Set up monitoring/alerting (optional)
  ```bash
  # Add monitoring script if desired
  ```

- [ ] Test daily operations:
  ```bash
  # View logs
  docker compose logs -f transcriber_backend
  
  # Restart if needed
  docker compose restart
  ```

- [ ] Update documentation (optional)
  ```bash
  echo "Created: $(date)" >> ~/apps/transcriber/DEPLOYED.txt
  ```

- [ ] Create backup of .env:
  ```bash
  cp ~/apps/transcriber/.env ~/backups/.env.transcriber.backup
  chmod 600 ~/backups/.env.transcriber.backup
  ```

## Troubleshooting Checklist

If something doesn't work:

- [ ] **Docker not starting?**
  ```bash
  docker compose logs
  # Check for obvious errors
  docker system prune -a  # clean up
  docker compose up -d --build  # retry
  ```

- [ ] **Port conflict (8000 or 3000)?**
  ```bash
  netstat -tlnp | grep 8000
  # Kill process if needed: kill -9 <PID>
  ```

- [ ] **Caddy not proxying?**
  ```bash
  caddy validate  # check syntax
  caddy reload     # reload config
  curl http://localhost:8000  # test local
  curl https://transcriber.anothershadeofgrey.com  # test proxied
  ```

- [ ] **Frontend can't reach backend?**
  - Check `API_BASE_URL` in App.vue is set to `https://transcriber.anothershadeofgrey.com`
  - Check backend logs: `docker compose logs transcriber_backend`
  - Check CORS is enabled in FastAPI

- [ ] **SSL certificate not issued?**
  - Wait 5 minutes
  - Check Caddy logs: `caddy logs`
  - Verify DNS is propagated: `nslookup transcriber.anothershadeofgrey.com`

## Success Indicators

✅ You'll know it's working when:

1. `docker compose ps` shows both services in "Up" state
2. Browser loads `https://transcriber.anothershadeofgrey.com` without certificate warning
3. Page displays the transcriber UI with:
   - "WAV Transcriber" title in Space Grotesk font
   - "Maximum file size: 500MB" message
   - Drag-and-drop zone
   - Feature badges (.wav, AI Powered)
4. No console errors in browser (F12)
5. Can drag a WAV file and see file info appear

---

## Rollback Plan

If deployment goes wrong:

```bash
cd ~/apps/transcriber

# Stop everything
docker compose down

# Check old Caddy config
nano ~/caddy/Caddyfile  # remove transcriber block

# Reload Caddy
caddy reload

# Remove Caddy block: edit and delete the transcriber section
# Restart from Caddy Configuration step
```

---

## Timeline

- DNS propagation: 5 minutes
- Code copy to VPS: 2-5 minutes  
- Docker build: 5-10 minutes
- Verification: 5 minutes
- **Total: 15-25 minutes**

---

## Emergency Contacts

If you get stuck:
- Check DEPLOYMENT.md troubleshooting section
- View logs: `docker compose logs`
- Stop everything: `docker compose down`
- Start fresh: `docker compose up -d --build`

---

**Deployment Date:** _______________  
**Deployed By:** _______________  
**Notes:** _______________  

---

Ready? Start with DNS setup above! ✅
