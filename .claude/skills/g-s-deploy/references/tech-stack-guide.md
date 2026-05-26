# Technology Stack Customization Guide

This reference provides quick customization paths for different frontend and backend stacks.

## Frontend Frameworks

### React (Create React App or Vite)
**Dockerfile changes:**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
RUN npm install -g serve
COPY --from=builder /app/build ./build
EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]
```

**docker-compose.prod.yml changes:**
- Port: `"3000:3000"`
- Build path: `./` (assuming React is in project root)
- Volume: None needed unless you need to persist static files

### Vue (Vite)
**Same as the default Dockerfile.frontend template** — Vite builds to `dist/` by default and `serve -s dist -l 3000` works perfectly.

### Next.js
**Dockerfile changes:**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package*.json ./
EXPOSE 3000
CMD ["npm", "start"]
```

**docker-compose.prod.yml changes:**
- Port: `"3000:3000"`
- Environment: Add `NODE_ENV=production`
- No serve needed — Next.js handles production serving

### Angular
**Dockerfile changes:**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
RUN npm install -g http-server
COPY --from=builder /app/dist/your-app-name ./dist
EXPOSE 3000
CMD ["http-server", "dist", "-p", "3000"]
```

### Svelte
**Dockerfile changes:**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/build ./build
EXPOSE 3000
CMD ["node", "build/index.js"]
```

## Backend Frameworks

### Python FastAPI (Default Template)
Already configured in `Dockerfile.backend`. Key points:
- Python 3.10-slim base
- Installs FFmpeg for audio processing
- Uses uvicorn to serve the app
- Health check via Python requests library

### Python Django
**Dockerfile changes:**
```dockerfile
FROM python:3.10-slim
WORKDIR /app
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

### Node.js Express
**Dockerfile changes:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8000/health || exit 1
CMD ["node", "server.js"]
```

### Go
**Dockerfile changes:**
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o app .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/app .
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8000/health || exit 1
CMD ["./app"]
```

### Rust
**Dockerfile changes:**
```dockerfile
FROM rust:latest AS builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/app /app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
CMD ["./app"]
```

## Database Integration

### PostgreSQL
**Add to docker-compose.prod.yml:**
```yaml
postgres:
  image: postgres:15-alpine
  container_name: app_postgres
  restart: unless-stopped
  environment:
    POSTGRES_USER: ${DB_USER:-postgres}
    POSTGRES_PASSWORD: ${DB_PASSWORD}
    POSTGRES_DB: ${DB_NAME:-app_db}
  volumes:
    - postgres_data:/var/lib/postgresql/data
  networks:
    - app_net
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres}"]
    interval: 10s
    timeout: 5s
    retries: 5

volumes:
  postgres_data:
```

**Backend environment variables:**
```env
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}
```

**Backend depends_on:**
```yaml
depends_on:
  postgres:
    condition: service_healthy
  backend_api:
    condition: service_healthy
```

### Redis
**Add to docker-compose.prod.yml:**
```yaml
redis:
  image: redis:7-alpine
  container_name: app_redis
  restart: unless-stopped
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
  networks:
    - app_net
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5

volumes:
  redis_data:
```

**Backend environment variable:**
```env
REDIS_URL=redis://redis:6379
```

## System Dependencies

### Common System Packages (apt-get)
- **Audio processing:** `ffmpeg`
- **Image processing:** `libpng-dev`, `libjpeg-dev`
- **PDF handling:** `ghostscript`, `poppler-utils`
- **Video processing:** `libavcodec-extra`
- **Database clients:** `postgresql-client`, `mysql-client`
- **Compression:** `bzip2`, `xz-utils`

**Example in Dockerfile:**
```dockerfile
RUN apt-get update && apt-get install -y \
    ffmpeg \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*
```

### Node.js Package Management
- **Production only:** `npm ci --only=production` (faster, more reliable than npm install)
- **Development:** Use `npm ci` (include dev dependencies)
- **Alpine Linux:** Node images are ~150MB smaller than Debian-based

### Python Package Management
- **Production:** `pip install --no-cache-dir -r requirements.txt` (saves space)
- **Development:** Can use pip install directly
- **Version pinning:** Always use pinned versions in requirements.txt for reproducibility

## Environment Variables

### Critical Variables (Never Hardcode)
- API keys (OpenAI, AWS, etc.)
- Database passwords
- Secret tokens (JWT, session tokens)
- Third-party service credentials
- Private encryption keys

**Example .env file:**
```env
# API Keys
OPENAI_API_KEY=sk-xxx
AWS_ACCESS_KEY=xxx
AWS_SECRET_KEY=xxx

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
REDIS_URL=redis://localhost:6379

# App Config
ENV=production
DEBUG=false
LOG_LEVEL=info
```

### Safe to Hardcode (in docker-compose.yml or Dockerfile)
- Port numbers
- Service hostnames
- Timeout values
- Feature flags (non-sensitive)
- Log levels

## Security Considerations

1. **Never include .env in Docker image** — Use docker-compose environment variables only
2. **Use .dockerignore** — Exclude `.env`, `.git`, `node_modules`, etc.
3. **Run as non-root** — Create dedicated user in Dockerfile if possible
4. **Minimal base images** — Use Alpine Linux instead of full OS images
5. **Health checks** — Detect hung services and force restart
6. **Log sensitive data carefully** — Never log API keys or passwords
7. **HTTPS only** — Caddy handles this automatically via Let's Encrypt

---

For more detailed guidance, see `scripts/deploy/DEPLOYMENT-PLAYBOOK.md` Phase 2 (Frontend) and Phase 3 (Backend).
