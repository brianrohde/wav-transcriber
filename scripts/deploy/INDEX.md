# 🚀 Deployment Skill Package - Complete Guide

**This folder contains everything needed to deploy ANY web application (self-coded or open-source) to local development and production VPS with custom domains.**

This is a portable, reusable deployment framework. Copy the entire `scripts/deploy/` folder to any new project.

---

## 📋 Quick Navigation

### Getting Started
1. **First time deploying?** → Read `README.md` (5 min)
2. **Need step-by-step walkthrough?** → See `DEPLOYMENT-PLAYBOOK.md` (30 min)
3. **Ready to deploy now?** → Pick your path below

### By Scenario

| Scenario | File | Time |
|----------|------|------|
| **Local dev (Windows)** | `local/run.ps1` | 1 min |
| **Local dev (Mac/Linux)** | `local/run.sh` | 1 min |
| **Rebuild local services** | `local/deploy.ps1` | 2 min |
| **Deploy to VPS (automated)** | `vps/deploy.ps1` | 10 min |
| **Deploy to VPS (manual SSH)** | `vps/manual/INSTRUCTIONS.md` | 15 min |
| **Learn full 11-phase process** | `DEPLOYMENT-PLAYBOOK.md` | 1 hour |

---

## 📁 Folder Structure

```
scripts/deploy/              ← Everything you need is here
├── INDEX.md                 ← You are here
├── README.md                ← Master deployment guide
├── DEPLOYMENT-PLAYBOOK.md   ← 11-phase end-to-end playbook
├── local/                   ← Local development
│   ├── run.ps1             (Windows: start dev server)
│   ├── run.sh              (Mac/Linux: start dev server)
│   └── deploy.ps1          (Windows: rebuild services)
├── vps/                     ← VPS production deployment
│   ├── deploy.ps1          (Automated deployment script)
│   └── manual/
│       └── INSTRUCTIONS.md (SSH manual steps)
└── templates/               ← Reusable templates for new projects
    ├── Dockerfile.backend  (Python FastAPI template)
    ├── Dockerfile.frontend (Node.js frontend template)
    ├── docker-compose.prod.yml
    ├── .env.example
    └── caddy-config.example
```

---

## 🎯 What This Package Covers

### ✅ Local Development
- Windows PowerShell startup script
- Mac/Linux Bash startup script
- Local rebuild/redeploy after code changes
- Development on localhost (ports 5173, 8000)

### ✅ VPS Production Deployment
- Automated deployment from Windows to Linux VPS
- Manual SSH deployment (fallback)
- Docker containerization
- Caddy reverse proxy configuration
- Automatic HTTPS with Let's Encrypt

### ✅ Domain Management
- Cloudflare DNS setup (A records, CNAME)
- Subdomain routing (transcriber.domain.com, api.domain.com)
- SSL certificate handling (automatic via Caddy)
- DNS propagation wait times

### ✅ Environment Configuration
- `.env` file generation and security
- Environment variables for local vs production
- API key management
- Database connection strings (if needed)

### ✅ Docker & Containerization
- Multi-stage Docker builds
- Frontend containerization (Node.js)
- Backend containerization (Python/FastAPI)
- Docker Compose orchestration
- Volume management for uploads/data

### ✅ Scaling to Multiple Subdomains
- Deploy multiple apps to same VPS
- Port management (8000, 8001, 8002, etc.)
- Caddy config for multiple domains
- Load balancing strategies

### ✅ End-to-End Walkthrough
- 11-phase playbook from scratch
- Phase 1: Project setup
- Phase 2: Frontend development
- Phase 3: Backend development
- Phase 4: Integration & testing
- Phase 5: Deployment scripts
- Phase 6: GitHub integration
- Phase 7: Domain & subdomain setup
- Phase 8: Server deployment
- Phase 9: Environment configuration
- Phase 10: Monitoring & maintenance
- Phase 11: Scaling to multiple subdomains

---

## 🚀 Quick Start by Project Type

### New Python FastAPI + Vue.js Project

1. Copy `scripts/deploy/` to your project root
2. Copy template files from `templates/`:
   ```bash
   cp scripts/deploy/templates/Dockerfile . (backend)
   cp scripts/deploy/templates/Dockerfile.frontend frontend/
   cp scripts/deploy/templates/docker-compose.prod.yml .
   cp scripts/deploy/templates/.env.example .env
   ```
3. Start local dev: `.\scripts\deploy\local\run.ps1` (Windows)
4. Deploy to VPS: `.\scripts\deploy\vps\deploy.ps1` (Windows)

### Existing Open-Source Project (Any Stack)

1. Copy `scripts/deploy/` to your project root
2. Update `Dockerfile` and `Dockerfile.frontend` templates for your stack
3. Update `docker-compose.prod.yml` with correct service names
4. Update `.env.example` with your app's variables
5. Follow `README.md` → `DEPLOYMENT-PLAYBOOK.md`

### Node.js + React/Next.js Project

1. Copy `scripts/deploy/` to your project root
2. Customize `templates/Dockerfile.frontend` for Node.js
3. Add backend Dockerfile (or use existing)
4. Start local dev: `.\scripts\deploy\local\run.sh` (Mac/Linux)
5. Deploy to VPS: `.\scripts\deploy\vps\deploy.ps1`

---

## 📖 Documentation Hierarchy

**Read in this order based on your need:**

```
START HERE
    ↓
Need 1-min overview?
    ↓
    README.md (Quick overview + troubleshooting)
    ↓
Need to deploy now?
    ├─ Local dev? → Use local/{run.ps1,run.sh,deploy.ps1}
    ├─ VPS auto? → Use vps/deploy.ps1
    └─ VPS manual? → Use vps/manual/INSTRUCTIONS.md
    ↓
Need to understand everything?
    ↓
    DEPLOYMENT-PLAYBOOK.md (11-phase deep dive)
    ↓
Need templates for new project?
    ↓
    templates/ (Copy and customize for your stack)
```

---

## 🔧 Templates

The `templates/` directory contains reusable configurations:

### Dockerfile.backend
- Python 3.10 + FastAPI example
- Install FFmpeg, system dependencies
- Multi-stage build for optimization
- Customize for your backend stack

### Dockerfile.frontend
- Node.js 18 + Vite + React/Vue example
- Multi-stage build (builder → runtime)
- Serve static files
- Customize for your frontend framework

### docker-compose.prod.yml
- Backend + frontend services
- Network configuration
- Volume mounts
- Environment variable passing

### .env.example
- Template for environment variables
- Copy to `.env` (add to .gitignore)
- Never commit real API keys

### caddy-config.example
- Reverse proxy configuration
- Multiple domain example
- Security headers
- Automatic HTTPS setup

---

## 🎓 Learning Path

### Path A: Deploy This Project
1. Run `.\scripts\deploy\local\run.ps1` to start locally
2. Make code changes
3. Run `.\scripts\deploy\local\deploy.ps1` to rebuild
4. Follow `README.md` for VPS deployment

### Path B: Apply to New Project
1. Copy entire `scripts/deploy/` to new project
2. Read `README.md` (5 min)
3. Customize `templates/` for your stack
4. Follow `DEPLOYMENT-PLAYBOOK.md` (1 hour)
5. Deploy to VPS

### Path C: Understand Everything
1. Read `INDEX.md` (you are here)
2. Skim `README.md` (architecture overview)
3. Read `DEPLOYMENT-PLAYBOOK.md` thoroughly (11 phases)
4. Reference specific sections as needed

---

## 🌍 Real-World Example

**Scenario:** Deploy a Next.js app to production subdomain

1. **Prepare (5 min)**
   - Set up GitHub repo
   - Add `scripts/deploy/` folder
   - Customize `templates/Dockerfile.frontend` for Next.js

2. **Local Dev (1 min)**
   ```bash
   ./scripts/deploy/local/run.sh  # Mac/Linux
   ```

3. **DNS (2 min)**
   - Cloudflare: Add A record (myapp.domain.com → 95.217.9.84)

4. **Deploy (10 min)**
   ```powershell
   .\scripts\deploy\vps\deploy.ps1  # Windows
   # Or use manual INSTRUCTIONS.md
   ```

5. **Verify (2 min)**
   ```bash
   curl https://myapp.domain.com
   ```

**Total time: ~20 minutes** (including DNS wait)

---

## 🔐 Security Checklist

- [ ] `.env` file is in `.gitignore` (never commit API keys)
- [ ] `.env` not included in Docker archives
- [ ] API keys stored on VPS only (created during deployment)
- [ ] HTTPS enabled (automatic via Caddy)
- [ ] Firewall configured (80, 443 for HTTP/HTTPS, 22 for SSH)
- [ ] Database credentials in `.env` (not hardcoded)
- [ ] Docker containers run as non-root (in templates)
- [ ] Regular backups of data (see DEPLOYMENT-PLAYBOOK.md)

---

## 🛠️ Customization Guide

### For Your Stack

1. **Different backend language?**
   - Update `Dockerfile` (copy from official docs)
   - Update `.env.example` with your variables
   - Adjust `docker-compose.prod.yml` ports/services

2. **Different frontend framework?**
   - Update `Dockerfile.frontend` (Node.js, React, Vue, etc.)
   - Update build command
   - Update serve command

3. **Need a database?**
   - Add to `docker-compose.prod.yml`
   - Update `.env.example`
   - Add volume for data persistence

4. **Need background jobs?**
   - Add service to `docker-compose.prod.yml`
   - Update environment variables
   - Configure logging

---

## 📞 Common Questions

**Q: Can I use this for other projects?**  
A: Yes! Copy the entire `scripts/deploy/` folder to any new project. Customize templates for your stack.

**Q: What if my app uses a database?**  
A: Add a database service to `docker-compose.prod.yml`. See DEPLOYMENT-PLAYBOOK.md Phase 3 for examples.

**Q: How do I deploy updates?**  
A: Run `.\scripts\deploy\vps\deploy.ps1` again from Windows, or `git pull && docker compose build && docker compose up -d` on VPS.

**Q: Can I use this for multiple subdomains?**  
A: Yes! See DEPLOYMENT-PLAYBOOK.md Phase 11 for scaling strategies.

**Q: What about monitoring and logs?**  
A: See DEPLOYMENT-PLAYBOOK.md Phase 10 for monitoring setup.

**Q: Is SSL/HTTPS included?**  
A: Yes! Caddy handles it automatically. No extra configuration needed.

---

## 🗺️ Skill Application: "g-s-deployment"

This entire `scripts/deploy/` package is designed to be used as a global skill for ANY future project.

### How to Apply to New Projects

1. **Copy the framework**
   ```bash
   cp -r scripts/deploy/ /path/to/new-project/
   ```

2. **Customize for your stack**
   - Update `templates/Dockerfile.*`
   - Update `templates/docker-compose.prod.yml`
   - Update `.env.example`

3. **Use the scripts**
   - Local dev: `.\scripts\deploy\local\run.ps1`
   - VPS deploy: `.\scripts\deploy\vps\deploy.ps1`

4. **Reference the guides**
   - README.md for quick answers
   - DEPLOYMENT-PLAYBOOK.md for detailed walkthrough

### Projects Already Using This Framework

- ✅ wav-transcriber (Vue 3 + FastAPI)
- (Add more as you apply it)

---

## 📊 At a Glance

| Aspect | Coverage | Details |
|--------|----------|---------|
| **Local Dev** | ✅ | Windows/Mac/Linux scripts included |
| **VPS Deployment** | ✅ | Automated + manual methods |
| **Domain Management** | ✅ | Cloudflare DNS, subdomain routing |
| **Docker** | ✅ | Multi-service, multi-stage builds |
| **Scaling** | ✅ | Multiple subdomains, load balancing |
| **SSL/HTTPS** | ✅ | Automatic via Caddy |
| **Environment Config** | ✅ | Secure .env handling |
| **Monitoring** | ✅ | Logs, health checks, alerting |
| **Backup/Restore** | ✅ | Procedures included |
| **Troubleshooting** | ✅ | Common issues + solutions |
| **Open-Source Ready** | ✅ | Portable to any project |

---

## 🎯 Next Steps

1. **Deploying this project?**
   - Run local dev: `.\scripts\deploy\local\run.ps1`
   - Deploy to VPS: `.\scripts\deploy\vps\deploy.ps1`

2. **Using for new project?**
   - Copy `scripts/deploy/` folder
   - Read `README.md`
   - Customize templates

3. **Need detailed walkthrough?**
   - Read `DEPLOYMENT-PLAYBOOK.md`
   - Follow all 11 phases

4. **Creating "g-s-deployment" skill?**
   - This entire folder is the skill foundation
   - Use README.md as the skill description
   - Templates are the examples
   - DEPLOYMENT-PLAYBOOK.md is the advanced guide

---

**Status:** ✅ Portable | ✅ Reusable | ✅ Production-Ready  
**Created:** 2026-05-26  
**Version:** 1.0 (Stable)

---

**Ready to deploy?** Start with `README.md` →
