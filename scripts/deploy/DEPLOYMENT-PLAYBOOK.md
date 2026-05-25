# End-to-End Deployment Playbook

A complete, reusable guide for deploying any product idea or repository to production with subdomains.

## Phase 1: Project Setup & Architecture

### Step 1.1: Initialize Project Structure

```bash
# Create project root
mkdir my-product
cd my-product
git init
```

### Step 1.2: Define Architecture

Decide on your tech stack:
- **Frontend:** Vue 3 + Vite + Tailwind CSS (or React, Svelte, etc.)
- **Backend:** FastAPI + Python (or Node, Go, Rust, etc.)
- **Database:** Optional (SQLite, PostgreSQL, MongoDB, etc.)
- **Deployment:** Docker, VPS, Vercel, AWS, etc.

For WAV Transcriber, we chose:
- Frontend: Vue 3 + Vite + Tailwind (modern, reactive, hot-reload)
- Backend: FastAPI + Python (async, easy to integrate ML models)
- Deployment: Local dev, prepared for Docker/VPS

### Step 1.3: Create CLAUDE.md

This file guides all future Claude sessions on your codebase.

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

Brief description of what your project does.

## Architecture

### Frontend
- Framework, build tool, styling

### Backend
- Language, framework, database

## Development Setup

### Prerequisites
- Required tools and versions

### Initial Build & Environment

Commands to set up environment, install dependencies

## Running the Application

How to start dev servers and access the app

## Project Structure

```
my-product/
├── frontend/          # Vue 3 + Vite
├── backend/           # FastAPI
├── docs/              # Documentation
├── .claude/           # Claude Code config
└── deploy.ps1/sh      # Deployment scripts
```

## Common Tasks

Commands for testing, building, deploying
```

### Step 1.4: Version Control Setup

```bash
# Create .gitignore
cat > .gitignore << 'EOF'
.env
.env.local
node_modules/
dist/
build/
__pycache__/
*.pyc
.venv/
venv/
.claude/
.DS_Store
EOF

# Initial commit
git add .
git commit -m "Initial project structure"
```

---

## Phase 2: Frontend Development

### Step 2.1: Initialize Frontend with Vite

```bash
# Create Vue 3 + Vite project
npm create vite@latest frontend -- --template vue
cd frontend
npm install

# Add Tailwind CSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### Step 2.2: Design UI/UX

Using the frontend-design skill:
- Choose distinctive aesthetic (not generic)
- Design mockups in Figma or on paper
- Plan animations and interactions
- Consider accessibility

### Step 2.3: Build Components

```bash
# Structure
frontend/src/
├── App.vue           # Main component
├── main.js           # Entry point
├── components/       # Reusable components
└── styles/           # Global styles
```

### Step 2.4: Dev Server Setup

```javascript
// frontend/vite.config.js
export default {
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:8000'  // Proxy to backend
    }
  }
}
```

```bash
npm run dev  # Runs on http://localhost:5173
```

---

## Phase 3: Backend Development

### Step 3.1: Initialize Backend

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install fastapi uvicorn python-dotenv aiofiles python-multipart

# Create project structure
mkdir my_product
touch my_product/__init__.py
touch my_product/api.py
touch my_product/config.py
```

### Step 3.2: Create Core Modules

**my_product/api.py** - Main FastAPI app:

```python
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/process")
async def process(file: UploadFile = File(...)):
    # Process file
    return {"result": "processed"}
```

**my_product/config.py** - Configuration:

```python
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("API_KEY")
DEBUG = os.getenv("DEBUG", "False") == "True"
```

### Step 3.3: Create .env File

```bash
cat > .env << 'EOF'
# Backend Configuration
DEBUG=True
BACKEND_PORT=8000
FRONTEND_PORT=5173

# API Keys
API_KEY=your-api-key-here
EOF
```

### Step 3.4: Run Backend

```bash
python -m my_product.api

# Or with uvicorn directly
uvicorn my_product.api:app --reload --port 8000
```

---

## Phase 4: Integration & Testing

### Step 4.1: Connect Frontend to Backend

**frontend/src/App.vue:**

```javascript
const API_BASE_URL = 'http://localhost:8000'

const uploadFile = async (file) => {
  const formData = new FormData()
  formData.append('file', file)
  
  const response = await fetch(`${API_BASE_URL}/process`, {
    method: 'POST',
    body: formData
  })
  
  return await response.json()
}
```

### Step 4.2: Test Locally

```bash
# Terminal 1: Backend
python -m my_product.api

# Terminal 2: Frontend
cd frontend
npm run dev

# Open http://localhost:5173
```

### Step 4.3: Use dev-browser for Testing

```bash
npm install -g dev-browser
dev-browser install

# Take screenshot
dev-browser <<'EOF'
const page = await browser.getPage("main");
await page.goto("http://localhost:5173", { waitUntil: "domcontentloaded" });
const buf = await page.screenshot();
const path = await saveScreenshot(buf, "app.png");
console.log(path);
EOF
```

---

## Phase 5: Deployment Scripts

### Step 5.1: Create Deploy Script (Windows PowerShell)

**deploy.ps1:**

```powershell
Write-Host "Deploying to production..." -ForegroundColor Green

# Kill existing processes
taskkill /F /IM python.exe 2>$null | Out-Null
taskkill /F /IM node.exe 2>$null | Out-Null
Start-Sleep -Seconds 2

# Install/update dependencies
Write-Host "Installing dependencies..." -ForegroundColor Cyan
. .\.venv\Scripts\Activate.ps1
pip install -q -r requirements.txt

Push-Location frontend
npm install -q 2>$null
Pop-Location

# Start backend
Write-Host "Starting backend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit -Command `"cd '$PWD'; python -m my_product.api`""
Start-Sleep -Seconds 3

# Start frontend
Write-Host "Starting frontend..." -ForegroundColor Cyan
Push-Location frontend
Start-Process powershell -ArgumentList "-NoExit -Command `"cd '$PWD'; npm run dev`""
Pop-Location
Start-Sleep -Seconds 3

Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:5173" -ForegroundColor Yellow
Write-Host "Backend: http://localhost:8000" -ForegroundColor Yellow
```

**deploy.sh (Mac/Linux):**

```bash
#!/bin/bash
echo "Deploying to production..."

# Kill existing processes
pkill -f "python.*api" 2>/dev/null || true
pkill -f "npm.*dev" 2>/dev/null || true
sleep 2

# Install dependencies
source venv/bin/activate
pip install -q -r requirements.txt

cd frontend
npm install -q
cd ..

# Start backend
python -m my_product.api > /tmp/backend.log 2>&1 &
sleep 3

# Start frontend
cd frontend
npm run dev > /tmp/frontend.log 2>&1 &
cd ..

echo "Deployment complete!"
echo "Frontend: http://localhost:5173"
echo "Backend: http://localhost:8000"
```

### Step 5.2: Create Debug Configuration

**debug_config.json:**

```json
{
  "enabled": true,
  "message": "2026-05-26 - Deployment v1.0"
}
```

Frontend loads this on mount to show deployment status without restarting.

### Step 5.3: Add to Backend API

**my_product/api.py:**

```python
import json
from pathlib import Path

@app.get("/debug")
async def debug():
    try:
        debug_config_path = Path(__file__).parent.parent / "debug_config.json"
        if debug_config_path.exists():
            with open(debug_config_path) as f:
                config = json.load(f)
                return {
                    "debug_enabled": config.get("enabled", False),
                    "debug_message": config.get("message", "")
                }
    except Exception:
        pass
    return {"debug_enabled": False, "debug_message": ""}
```

---

## Phase 6: GitHub Integration

### Step 6.1: Create GitHub Repository

```bash
# On GitHub.com, create new repository

# Link local repo
git remote add origin https://github.com/YOUR_USERNAME/my-product.git
git branch -M main
git push -u origin main
```

### Step 6.2: Commit Regularly

```bash
git add .
git commit -m "Feature: Add user authentication"
git push origin main
```

### Step 6.3: Document Everything

Add to repository:
- **README.md** - Project overview
- **CLAUDE.md** - Development guide (for Claude sessions)
- **docs/** - Additional documentation
  - DEPLOYMENT.md
  - SETUP.md
  - API.md

---

## Phase 7: Domain & Subdomain Setup

### Step 7.1: Register Domain

Buy domain from registrar (GoDaddy, Namecheap, etc.)

### Step 7.2: Create Subdomain

In your registrar's DNS settings:

```
Type    | Name              | Value
--------|-------------------|------------------
A       | example.com       | YOUR_SERVER_IP
CNAME   | app.example.com   | example.com
CNAME   | api.example.com   | example.com
```

### Step 7.3: Set Up SSL Certificates

Using Let's Encrypt (free):

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Generate certificate
sudo certbot certonly --standalone -d example.com -d app.example.com -d api.example.com

# Certs location: /etc/letsencrypt/live/example.com/
```

---

## Phase 8: Server Deployment

### Step 8.1: Choose Hosting

Options:
- **DigitalOcean** - $5-15/month VPS
- **Linode** - Similar to DigitalOcean
- **AWS** - Scalable, pay-as-you-go
- **Vercel** - Perfect for Frontend (free tier available)
- **Render** - Easy backend hosting

For this example, using DigitalOcean VPS:

### Step 8.2: SSH Into Server

```bash
ssh root@YOUR_SERVER_IP

# Update system
apt-get update && apt-get upgrade -y
```

### Step 8.3: Install Prerequisites

```bash
# Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Python
apt-get install -y python3 python3-pip python3-venv

# Git
apt-get install -y git

# Nginx (reverse proxy)
apt-get install -y nginx
```

### Step 8.4: Clone Repository

```bash
cd /var/www
git clone https://github.com/YOUR_USERNAME/my-product.git
cd my-product
```

### Step 8.5: Set Up Backend Service

**my-product.service:**

```ini
[Unit]
Description=My Product Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/my-product
Environment="PATH=/var/www/my-product/venv/bin"
ExecStart=/var/www/my-product/venv/bin/python -m my_product.api
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo cp my-product.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable my-product
sudo systemctl start my-product
```

### Step 8.6: Configure Nginx

**/etc/nginx/sites-available/my-product:**

```nginx
# Frontend
server {
    listen 80;
    server_name app.example.com;
    
    location / {
        root /var/www/my-product/frontend/dist;
        try_files $uri $uri/ /index.html;
    }
}

# Backend API
server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/my-product /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 8.7: Build Frontend for Production

```bash
cd frontend
npm run build
# Output: dist/ directory with optimized assets
```

### Step 8.8: Enable HTTPS

```bash
sudo certbot --nginx -d app.example.com -d api.example.com
# Certbot automatically updates Nginx config
```

---

## Phase 9: Environment Configuration

### Step 9.1: Production Environment Variables

**.env.production (on server):**

```
DEBUG=False
BACKEND_PORT=8000
API_KEY=your-production-api-key
DATABASE_URL=postgresql://user:pass@localhost/db
```

### Step 9.2: Secrets Management

For production secrets, use:
- Environment variables (on server)
- Secrets manager (AWS Secrets Manager, HashiCorp Vault)
- .env file (server-only, not in git)

Never commit secrets to GitHub!

---

## Phase 10: Monitoring & Maintenance

### Step 10.1: Health Checks

Set up monitoring for:

```bash
# Backend health
curl https://api.example.com/health

# Frontend availability
curl https://app.example.com
```

Services: UptimeRobot, Pingdom, or custom

### Step 10.2: Logs

```bash
# View backend logs
sudo journalctl -u my-product -f

# View frontend logs
tail -f /var/log/nginx/access.log
```

### Step 10.3: Updates

```bash
# On server, pull latest code
cd /var/www/my-product
git pull origin main

# Rebuild frontend
cd frontend && npm run build && cd ..

# Restart backend service
sudo systemctl restart my-product
```

### Step 10.4: Database Backups

```bash
# Daily backup script
0 2 * * * pg_dump mydb > /backups/mydb-$(date +\%Y\%m\%d).sql
```

---

## Phase 11: Scaling to Multiple Subdomains

### Step 11.1: Clone for New Product

```bash
# Create new project
cp -r my-product my-product-v2
cd my-product-v2

# Update package names
sed -i 's/my-product/my-product-v2/g' package.json
sed -i 's/my_product/my_product_v2/g' my_product_v2/api.py

# Update git remote
git remote set-url origin https://github.com/YOUR_USERNAME/my-product-v2.git
```

### Step 11.2: Create New Subdomains

In DNS:
```
CNAME   | v2.example.com  | example.com
CNAME   | api-v2.example.com | example.com
```

### Step 11.3: Deploy to Subdomains

Repeat Phase 8 for each new subdomain:
- Different service file (my-product-v2.service)
- Different port (8001 for v2 backend)
- Different Nginx config
- Separate SSL certificate

### Step 11.4: Load Balancing (Optional)

For high traffic, use:
- Nginx load balancer
- HAProxy
- AWS Load Balancer

---

## Quick Reference: Complete Checklist

### Initial Setup (1-2 hours)
- [ ] Create project structure
- [ ] Write CLAUDE.md
- [ ] Initialize git repo

### Frontend (4-8 hours)
- [ ] Set up Vite + Vue 3
- [ ] Design UI/UX
- [ ] Build components
- [ ] Connect to backend API

### Backend (4-8 hours)
- [ ] Set up FastAPI
- [ ] Create core modules
- [ ] Add API endpoints
- [ ] Test locally

### Local Development (2-4 hours)
- [ ] Test full workflow
- [ ] Fix bugs
- [ ] Optimize performance
- [ ] Document API

### Deployment Scripts (1-2 hours)
- [ ] Create deploy.ps1/sh
- [ ] Test deployment script
- [ ] Add debug configuration

### GitHub (30 minutes)
- [ ] Create repository
- [ ] Push code
- [ ] Add documentation

### Server Setup (4-8 hours)
- [ ] Choose hosting provider
- [ ] Register domain
- [ ] Configure DNS/subdomains
- [ ] SSH into server
- [ ] Install prerequisites
- [ ] Clone repository
- [ ] Set up systemd service
- [ ] Configure Nginx
- [ ] Enable HTTPS
- [ ] Build frontend
- [ ] Test all endpoints

### Monitoring (2-4 hours)
- [ ] Set up health checks
- [ ] Configure logging
- [ ] Plan backup strategy
- [ ] Document maintenance

---

## Estimated Timeline

| Phase | Duration |
|-------|----------|
| Setup & Architecture | 1-2 hours |
| Frontend Development | 8-16 hours |
| Backend Development | 8-16 hours |
| Integration & Testing | 4-8 hours |
| Deployment Scripts | 2-4 hours |
| GitHub Setup | 1 hour |
| Server Deployment | 8-12 hours |
| Monitoring Setup | 2-4 hours |
| **Total** | **36-67 hours** |

---

## Tips for Speed

1. **Reuse templates** - Save your deploy scripts and config files
2. **Automate everything** - Deployment scripts save hours
3. **Use managed services** - Let providers handle infrastructure
4. **Document as you go** - CLAUDE.md and comments save future time
5. **Test incrementally** - Don't wait until the end
6. **Use version control** - Makes rolling back easy
7. **Pre-approve CLI tools** - Add to .claude/settings.json to skip permission prompts

---

## Replication for Any Product

To deploy a new product using this playbook:

1. Copy this checklist
2. Adapt tech stack to your needs (React instead of Vue, Node instead of Python, etc.)
3. Follow phases 1-11 in order
4. Automate with deployment scripts
5. Store secrets securely
6. Monitor continuously
7. Scale as needed

This entire process can be completed in **1-2 weeks** for a simple product, or **2-4 weeks** for a more complex one.

---

## Key Files to Reuse

For your next product, save these templates:
- `deploy.ps1` - Deployment script
- `deploy.sh` - Linux equivalent
- `/etc/nginx/sites-available/template` - Nginx config
- `systemd.service` - Service template
- `.claude/settings.json` - Claude Code permissions
- `.gitignore` - Standard ignore patterns
- `CLAUDE.md` - Developer guide template

This cuts setup time from hours to minutes!
