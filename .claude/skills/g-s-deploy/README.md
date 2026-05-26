# g-s-deploy: Global Deployment Skill

A portable, generalizable deployment framework that can be applied to **any web project** — Node.js, Python, Go, Rust, React, Vue, Next.js, FastAPI, Express, or any modern web stack.

## What This Skill Does

This skill guides you through deploying applications from **local development** to **production VPS** in 20-30 minutes. It provides:

- **Local Development Setup** — Start any app locally with one command (Windows/Mac/Linux)
- **VPS Deployment** — Automated Docker-based deployment with HTTPS
- **Domain Management** — Configure custom domains and subdomains via Cloudflare DNS
- **Docker Templates** — Pre-made, customizable Dockerfiles for any tech stack
- **Multi-App Scaling** — Deploy multiple services to the same VPS
- **Security Best Practices** — HTTPS, environment variable handling, API key protection
- **Troubleshooting Guides** — Common issues and their solutions

## Skill Structure

```
g-s-deploy/
├── SKILL.md                      # Main skill instructions
├── README.md                     # This file
├── evals/
│   └── evals.json              # Test cases for evaluating the skill
├── references/
│   ├── tech-stack-guide.md      # Customization examples for all frameworks
│   └── troubleshooting-checklist.md  # Common issues and fixes
└── scripts/
    └── (scripts go here if needed)
```

## How to Use This Skill

### As a Claude Code User

When you want to deploy an app, ask Claude:

```
"Help me deploy my Node.js + React app to a VPS"
"Set up Docker for my FastAPI backend + Vue frontend"
"I need to deploy to production with HTTPS and a custom domain"
```

Claude will recognize this as a deployment task and automatically apply the g-s-deploy skill to help you.

### From the Skill Directly

The skill provides:

1. **START-HERE guidance** — For users new to deployment
2. **Tech stack customization** — Examples for every popular framework
3. **Step-by-step workflows** — Local dev, VPS deployment, domain setup
4. **Troubleshooting** — Solutions for common issues

## Key Concepts

### The Deployment Framework

Based on `scripts/deploy/` from the wav-transcriber project, this skill uses:

- **Docker Compose** — Orchestrates multiple services
- **Caddy Reverse Proxy** — Routes HTTPS traffic automatically
- **Archive Method** — Bundles entire project in tar.gz, excludes `.env` and `node_modules`
- **Health Checks** — Ensures services are running before starting dependents
- **Environment Variables** — Sensitive data is never in Docker images

### File Structure (Universal)

Every deployable project should have:

```
your-project/
├── scripts/deploy/              # Copy from wav-transcriber
│   ├── 00-START-HERE.md
│   ├── INDEX.md
│   ├── README.md
│   ├── DEPLOYMENT-PLAYBOOK.md
│   ├── local/
│   │   ├── run.ps1
│   │   ├── run.sh
│   │   └── deploy.ps1
│   ├── vps/
│   │   ├── deploy.ps1
│   │   └── manual/INSTRUCTIONS.md
│   └── templates/               # Customize for your stack
│       ├── Dockerfile.backend
│       ├── Dockerfile.frontend
│       ├── docker-compose.prod.yml
│       └── caddy-config.example
├── .env                         # Create this locally (NEVER commit)
├── Dockerfile                   # For backend (symlink or copy from templates)
├── docker-compose.yml           # For local dev
└── [your app files...]
```

## Common Workflows

### Deploy a New Node.js + React App (30 min)

1. **Copy the framework:**
   ```bash
   cp -r [wav-transcriber]/scripts/deploy ./scripts/deploy
   ```

2. **Customize templates:**
   - Edit `templates/Dockerfile.frontend` for React
   - Edit `templates/Dockerfile.backend` for Node.js Express
   - Update `templates/docker-compose.prod.yml` with your services

3. **Run locally:**
   ```bash
   ./scripts/deploy/local/run.ps1   # Windows
   ./scripts/deploy/local/run.sh    # Mac/Linux
   ```

4. **Deploy to VPS:**
   ```bash
   ./scripts/deploy/vps/deploy.ps1
   # Follow prompts for: VPS IP, API keys, domain name
   ```

### Deploy a FastAPI + Vue App (25 min)

- Dockerfile.backend is already configured for Python FastAPI
- Customize Dockerfile.frontend for Vue (it's already Vite-ready)
- Same deployment flow as above

### Add a Database (PostgreSQL)

Edit `templates/docker-compose.prod.yml`:

```yaml
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app_net
  
  backend:
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://user:${DB_PASSWORD}@postgres:5432/appdb
```

See `references/tech-stack-guide.md` for more examples.

## References

- **SKILL.md** — Complete skill instructions and guidance
- **references/tech-stack-guide.md** — Framework customization for any stack (Python, Node.js, Go, Rust, React, Vue, Next.js, Angular, Svelte, etc.)
- **references/troubleshooting-checklist.md** — Solutions for common deployment issues
- **evals/evals.json** — Test cases demonstrating the skill's usage

## When to Use This Skill

✅ **Use when:**
- Deploying a new application
- Setting up local development environment
- Configuring VPS production deployment
- Managing domains and subdomains
- Adding Docker containerization
- Scaling to multiple services/applications
- Setting up HTTPS/SSL

❌ **Don't use when:**
- Debugging application code (not deployment-related)
- Using alternative deployment tools (Kubernetes, Vercel, Heroku)
- General programming questions

## Success Metrics

A successful deployment shows:

1. ✅ Local dev starts without errors
2. ✅ Backend API responds to health checks
3. ✅ Frontend loads in browser
4. ✅ VPS deployment completes successfully
5. ✅ Domain resolves to VPS IP (DNS propagated)
6. ✅ HTTPS works (certificate auto-generated)
7. ✅ All services running (`docker compose ps`)
8. ✅ Application accessible at custom domain

## Contributing / Improving This Skill

To improve the skill:

1. Add new test cases to `evals/evals.json`
2. Update `references/tech-stack-guide.md` with new framework examples
3. Add solutions to `references/troubleshooting-checklist.md` as new issues arise
4. Improve the SKILL.md instructions based on user feedback

## Example: Complete Deployment (20 minutes)

**Project:** Node.js Express backend + React frontend

**Steps:**
1. Copy `scripts/deploy/` to new project (1 min)
2. Customize Dockerfiles for Node + React (5 min)
3. Run locally: `./scripts/deploy/local/run.ps1` (2 min)
4. Create `.env` with API keys (2 min)
5. Run `./scripts/deploy/vps/deploy.ps1` (5 min, includes DNS wait)
6. Verify domain + HTTPS working (5 min)
7. ✅ Deployed!

## Questions?

Check:
- **"How do I...?"** → See SKILL.md for detailed guidance
- **"What about [tech stack]?"** → See `references/tech-stack-guide.md`
- **"Something's broken"** → See `references/troubleshooting-checklist.md`
- **"I need step-by-step"** → Run `./scripts/deploy/local/run.ps1` then follow prompts

---

**Status:** ✅ Ready to use
**Applicable to:** Any modern web project
**Time to deployment:** 20-30 minutes
**VPS:** Tested with Hetzner, DigitalOcean, Linode (any Linux VPS with Docker)
