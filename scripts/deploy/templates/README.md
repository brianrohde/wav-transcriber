# Deployment Templates

Reusable configuration templates for deploying web applications.

## Files in This Directory

### Dockerfile.backend
Template Docker configuration for backend services (Python FastAPI example).

**Customize for your stack:**
- Python → Node.js, Go, Rust, etc.
- FastAPI → Express, Django, etc.
- Package manager: pip → npm, cargo, etc.

### Dockerfile.frontend
Template Docker configuration for frontend services (Node.js + Vite example).

**Customize for your stack:**
- React/Vue → Next.js, Svelte, Angular, etc.
- Build tool: Vite → Webpack, Parcel, etc.
- Package manager: npm → yarn, pnpm, etc.

### docker-compose.prod.yml
Production Docker Compose configuration orchestrating frontend + backend.

**Customize for your project:**
- Service names (backend → api, python-api, etc.)
- Port numbers (8000, 5173, etc.)
- Environment variables
- Volume mounts
- Network configuration

### .env.example
Environment variables template.

**Usage:**
```bash
cp templates/.env.example .env
# Edit .env with your values
# Add .env to .gitignore (never commit)
```

### caddy-config.example
Reverse proxy configuration for Caddy.

**Usage:**
```bash
# Copy into your Caddyfile on VPS
cat templates/caddy-config.example >> /root/caddy/Caddyfile
docker exec caddy caddy reload -c /etc/caddy/Caddyfile
```

## How to Use Templates

### For a New Python FastAPI + Vue Project
1. Copy all templates as-is
2. They're already configured for this stack
3. Customize paths and ports if needed

### For a Node.js + React Project
1. Update `Dockerfile.frontend`:
   - Change Node base image version
   - Update build command (vite → next build, etc.)
   - Update serve command

2. Update `Dockerfile.backend`:
   - Use Node.js instead of Python
   - Change package manager (npm instead of pip)
   - Update startup command

3. Update `docker-compose.prod.yml`:
   - Adjust environment variables
   - Adjust port numbers if different

### For Any Stack
1. Find official Docker images for your language/framework
2. Copy the structure from templates
3. Replace dependencies and startup commands
4. Keep the multi-stage build pattern for optimization

## Template Customization Checklist

- [ ] **Dockerfile.backend** - Updated for your backend stack
- [ ] **Dockerfile.frontend** - Updated for your frontend framework
- [ ] **docker-compose.prod.yml** - Service names, ports, volumes correct
- [ ] **.env.example** - Contains all variables your app needs
- [ ] **caddy-config.example** - Domain names match your setup

## Example Customizations

### Python FastAPI Backend
```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Node.js Express Backend
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json .
RUN npm ci --only=production
COPY . .
CMD ["node", "server.js"]
```

### Next.js Frontend
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package*.json .
RUN npm ci --only=production
CMD ["npm", "start"]
```

## More Information

- See `../README.md` for deployment instructions
- See `../DEPLOYMENT-PLAYBOOK.md` for full walkthrough
- Docker docs: https://docs.docker.com
- Caddy docs: https://caddyserver.com/docs

---

**Tip:** Keep these templates in version control. Update them as you learn what works best for your stack.
