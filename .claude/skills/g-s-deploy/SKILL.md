---
name: g-s-deploy
description: |
  Deploy any web application from local development to production VPS in minutes. 
  Use this skill whenever a user mentions deployment, production setup, Docker, domain configuration, 
  VPS setup, or needs guidance on deploying a self-coded or open-source web project to the internet. 
  This includes applications built with Node.js, Python, Go, Rust, React, Vue, Next.js, FastAPI, 
  or any other modern web stack. The skill provides: (1) local development scripts for Windows/Mac/Linux, 
  (2) automated VPS deployment with Docker + Caddy reverse proxy, (3) domain/subdomain management via Cloudflare DNS, 
  (4) customizable templates for any tech stack, (5) multi-app scaling strategies, (6) security best practices, 
  and (7) comprehensive troubleshooting guides. Always offer to help with deployment setup, even if the user 
  doesn't explicitly use the word "deploy."
compatibility: |
  - Requires: Docker, docker-compose, bash/PowerShell, SSH access (for VPS)
  - Optional: Caddy reverse proxy, Cloudflare DNS account, GitHub
---

# g-s-deploy: Portable Deployment Framework for Any Web Project

This skill helps you deploy any web application from local development to production VPS using a proven, portable framework. It works with any modern tech stack (Python, Node.js, Go, Rust, React, Vue, Next.js, FastAPI, Express, etc.) and can be applied to new projects in under 30 minutes.

## What This Skill Does

1. **Local Development** — Start any app locally with one command (Windows/Mac/Linux)
2. **VPS Deployment** — Automated Docker-based deployment with HTTPS via Let's Encrypt
3. **Domain Management** — Set up custom domains and subdomains with Cloudflare DNS
4. **Docker Templates** — Pre-made Dockerfiles and docker-compose configs for any stack
5. **Scaling** — Deploy multiple applications to the same VPS
6. **Security** — Built-in HTTPS, environment variable management, API key protection
7. **Troubleshooting** — Comprehensive guides for common issues

## Framework Structure

The deployment framework lives in `scripts/deploy/` and contains:

```
scripts/deploy/
├── 00-START-HERE.md              # 5-min entry point
├── INDEX.md                       # Master navigation & learning paths
├── README.md                      # Main deployment guide
├── DEPLOYMENT-PLAYBOOK.md         # 11-phase end-to-end walkthrough
├── local/                         # Local development
│   ├── run.ps1                   (Windows startup)
│   ├── run.sh                    (Mac/Linux startup)
│   └── deploy.ps1               (Windows rebuild after code changes)
├── vps/                          # VPS production
│   ├── deploy.ps1               (Automated VPS deployment)
│   └── manual/
│       └── INSTRUCTIONS.md      (SSH fallback guide)
└── templates/                    # Customizable configs
    ├── Dockerfile.backend
    ├── Dockerfile.frontend
    ├── docker-compose.prod.yml
    ├── caddy-config.example
    └── README.md
```

## How to Apply This Skill

### For a New Project

1. **Copy the framework** — Copy `scripts/deploy/` from wav-transcriber to your new project
2. **Read the entry point** — Open `scripts/deploy/00-START-HERE.md`
3. **Choose your path** — Pick "Deploy Locally" (5 min), "Deploy to VPS" (20 min), or "Learn Everything" (1 hour)
4. **Customize templates** — Edit `templates/Dockerfile.backend`, `Dockerfile.frontend`, and `docker-compose.prod.yml` for your stack
5. **Run the scripts** — Use `scripts/deploy/local/run.ps1` or `scripts/deploy/local/run.sh` to start locally
6. **Deploy to VPS** — Run `scripts/deploy/vps/deploy.ps1` to push to production

### For an Existing Project

Help the user:
1. Identify their current tech stack (frontend framework, backend language, database)
2. Navigate to the appropriate section of the deployment guide
3. Customize the templates for their stack
4. Walk them through the deployment process step-by-step

## Recommended Workflow

### If the user wants to deploy an existing project:

1. **Assess the project** — Ask about:
   - Frontend tech (React, Vue, Next.js, etc.)
   - Backend tech (Python, Node.js, Go, Rust, etc.)
   - Database (if any)
   - Domain/VPS hosting
   - Local dev setup

2. **Provide the entry point** — Share `scripts/deploy/00-START-HERE.md`

3. **Customize templates** — Help them:
   - Edit `Dockerfile.backend` for their language/framework
   - Edit `Dockerfile.frontend` for their frontend framework
   - Update `docker-compose.prod.yml` with their services and ports
   - Configure `caddy-config.example` with their domain

4. **Walk through deployment** — Guide them through:
   - Local development setup (`run.ps1` or `run.sh`)
   - DNS configuration (Cloudflare A record for VPS IP)
   - VPS deployment (`deploy.ps1`)
   - Post-deployment verification

### If the user wants to create a new portable skill:

1. **Document the framework** — Help them create a `scripts/deploy/` folder with all necessary files
2. **Create templates** — Generate customized Dockerfiles and configs for their stack
3. **Write guides** — Draft deployment documentation tailored to their project
4. **Test locally** — Verify the framework works on their local machine
5. **Test on VPS** — Run one full end-to-end deployment
6. **Mark as reusable** — Document that the entire `scripts/deploy/` folder can be copied to new projects

## Key Concepts

### Provider-Agnostic Docker Stack
- **Backend Dockerfile** — Can be customized for Python, Node.js, Go, Rust, etc.
- **Frontend Dockerfile** — Supports React, Vue, Svelte, Next.js, Angular, etc.
- **docker-compose.prod.yml** — Orchestrates both services with networking and health checks
- **Caddy reverse proxy** — Routes HTTPS traffic to backend and frontend services

### Archive Method for Deployment
- Uses `tar.gz` to bundle all project files
- Automatically excludes: `.git/`, `node_modules/`, `venv/`, `__pycache__/`, `.pytest_cache/`, `dist/`, `.env`, `.vscode/`, `.idea/`
- **Critical:** `.env` files are NEVER included in the archive (security best practice)
- Transmits entire project in a single file (faster SCP than individual file transfers)
- On VPS, archive is extracted and Docker Compose handles the rest

### Environment Variables
- `.env` files contain sensitive data (API keys, database URLs, secrets)
- Must be created manually on VPS via the deployment script
- User prompted for values (e.g., `OPENAI_API_KEY`) at deployment time
- Never committed to git (`add .env to .gitignore`)

### Health Checks
- Backend and frontend services include health checks
- Docker Compose waits for services to be healthy before starting dependents
- Frontend waits for backend to be healthy (if dependency exists)
- Prevents race conditions and cascading failures

### Caddy Reverse Proxy
- Automatic HTTPS via Let's Encrypt (free SSL certificates)
- Automatic HTTP → HTTPS redirect
- Routes traffic to backend and frontend services on different subdomains
- Example: `transcriber.example.com` → frontend on port 5173, `api.example.com` → backend on port 8000

## Common Customization Scenarios

### Python FastAPI Backend
- Use `templates/Dockerfile.backend` as-is (already configured for Python)
- Install system dependencies (FFmpeg, etc.) in the RUN statement
- Ensure `requirements.txt` is in project root

### Node.js Express Backend
- Replace `FROM python:3.10-slim` with `FROM node:18-alpine`
- Replace `pip install -r requirements.txt` with `npm ci --only=production`
- Update health check to use `curl` or `wget`
- Update startup command: `CMD ["node", "server.js"]`

### React Frontend
- Use `templates/Dockerfile.frontend` and swap `dist` for `build`
- Update build output path in docker-compose: `COPY --from=builder /app/build ./build`
- Update serve command: `CMD ["serve", "-s", "build", "-l", "3000"]`

### Next.js Frontend
- Use `templates/Dockerfile.frontend` but change Stage 2 command
- Replace: `CMD ["serve", "-s", "dist", "-l", "3000"]`
- With: `CMD ["npm", "start"]` (Next.js production start)

### Database (PostgreSQL/Redis)
- Add service block to `docker-compose.prod.yml`:
  ```yaml
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app_net
  ```
- Update backend `depends_on` to include database service
- Add environment variable: `DATABASE_URL=postgresql://user:password@postgres:5432/dbname`

## Deployment Timeline Estimates

- **First local setup** — 5 minutes (run `run.ps1` or `run.sh`)
- **First VPS deployment** — 20 minutes (includes DNS propagation wait)
- **Subsequent deployments** — 10 minutes (skip DNS setup)
- **Learning the full framework** — 1 hour (read all guides)
- **Applying to new project** — 30 minutes (copy, customize, deploy)

## When to Use This Skill

✅ **Use this skill when:**
- User mentions "deploy", "production", "VPS", "Docker", "domain setup"
- User asks "How do I get my app online?"
- User wants to automate their deployment process
- User needs to scale from one to many applications
- User needs HTTPS/SSL guidance
- User is setting up CI/CD integration with GitHub

❌ **Don't use this skill when:**
- User is asking for general programming help (use your base capabilities)
- User is debugging application code (not deployment-related)
- User needs help with a different deployment tool (Kubernetes, Vercel, Heroku, etc.)

## Success Criteria

A successful deployment should show:
1. ✅ Local dev starts without errors (`run.ps1` or `run.sh` completes)
2. ✅ Backend API responds to health check (e.g., `/health` endpoint)
3. ✅ Frontend loads in browser (localhost:5173 or localhost:3000)
4. ✅ VPS deployment completes without errors
5. ✅ Domain resolves to VPS IP (DNS propagated)
6. ✅ HTTPS works (certificate auto-generated by Let's Encrypt)
7. ✅ Services visible in `docker compose ps` (all running)
8. ✅ Application accessible at custom domain

## Related Documentation

- **Quick start:** `scripts/deploy/00-START-HERE.md`
- **Navigation guide:** `scripts/deploy/INDEX.md`
- **Main guide:** `scripts/deploy/README.md`
- **Deep dive:** `scripts/deploy/DEPLOYMENT-PLAYBOOK.md` (11-phase walkthrough)
- **Manual fallback:** `scripts/deploy/vps/manual/INSTRUCTIONS.md`
- **Template customization:** `scripts/deploy/templates/README.md`

---

## How to Ask Claude to Use This Skill

If you're asking Claude to help with deployment, try prompts like:

- "Help me deploy my Node.js + React app to a VPS"
- "I built a FastAPI backend + Vue frontend. How do I get it online?"
- "Set up Docker containers and HTTPS for my application"
- "I need to deploy my app locally first, then to production"
- "Help me create a reusable deployment framework for future projects"
- "Configure my domain and set up subdomains for my app"
- "Walk me through deploying to production step-by-step"

Claude will recognize these as deployment tasks and apply the g-s-deploy skill to help you.
