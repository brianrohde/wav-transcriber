#!/bin/bash

# WAV Transcriber VPS Deployment Script
# This script pushes the code to your Hetzner VPS and sets up Docker

set -e

# Configuration
VPS_IP="95.217.9.84"
VPS_USER="root"
APP_DIR="/root/apps/transcriber"

echo "🚀 WAV Transcriber VPS Deployment Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Create app directory on VPS
echo "📁 Step 1: Creating app directory on VPS..."
ssh $VPS_USER@$VPS_IP "mkdir -p $APP_DIR && cd $APP_DIR && echo 'Directory ready'"

# Step 2: Copy code to VPS
echo "📤 Step 2: Copying code to VPS..."
echo "   (This may take a minute...)"

# Create a temporary tar file
tar --exclude='.git' \
    --exclude='node_modules' \
    --exclude='venv' \
    --exclude='__pycache__' \
    --exclude='.pytest_cache' \
    --exclude='dist' \
    --exclude='.env' \
    -czf /tmp/transcriber.tar.gz .

# Copy to VPS
scp /tmp/transcriber.tar.gz $VPS_USER@$VPS_IP:$APP_DIR/

# Extract on VPS
ssh $VPS_USER@$VPS_IP "cd $APP_DIR && tar -xzf transcriber.tar.gz && rm transcriber.tar.gz && echo '✅ Code extracted'"

# Clean up local temp file
rm /tmp/transcriber.tar.gz

# Step 3: Setup .env on VPS
echo ""
echo "🔐 Step 3: Setting up environment on VPS..."
echo "   Please provide your OpenAI API key when prompted."
echo ""
read -p "Enter your OPENAI_API_KEY: " openai_key

ssh $VPS_USER@$VPS_IP "cat > $APP_DIR/.env << 'EOF'
OPENAI_API_KEY=$openai_key
ENV=production
EOF
echo '✅ .env created'"

# Step 4: Update docker-compose.yml on VPS
echo ""
echo "🐳 Step 4: Updating Docker Compose configuration..."
ssh $VPS_USER@$VPS_IP "cd $APP_DIR && mv docker-compose.prod.yml docker-compose.yml"

# Step 5: Update Caddy config
echo ""
echo "🔄 Step 5: Updating Caddy configuration..."
ssh $VPS_USER@$VPS_IP "cd /root/caddy && cat >> Caddyfile << 'EOF'

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
echo '✅ Caddy config updated'"

# Step 6: Reload Caddy
echo ""
echo "🔄 Step 6: Reloading Caddy reverse proxy..."
ssh $VPS_USER@$VPS_IP "docker exec caddy caddy reload -c /etc/caddy/Caddyfile"

# Step 7: Build and run containers
echo ""
echo "🐳 Step 7: Building and running Docker containers..."
echo "   (This will take 2-3 minutes on first run...)"
ssh $VPS_USER@$VPS_IP "cd $APP_DIR && docker compose build && docker compose up -d"

# Step 8: Verify deployment
echo ""
echo "✅ Step 8: Verifying deployment..."
ssh $VPS_USER@$VPS_IP "docker compose ps"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Deployment Complete!"
echo ""
echo "Your transcriber is now running at:"
echo "   🌐 https://transcriber.anothershadeofgrey.com"
echo ""
echo "Give DNS a minute to propagate, then visit the URL!"
echo ""
