# WAV Transcriber VPS Deployment Script (PowerShell)
# Windows to Linux VPS deployment

$VpsIp = "95.217.9.84"
$VpsUser = "root"
$AppDir = "/root/apps/transcriber"

Write-Host "`n`u{1F680} WAV Transcriber VPS Deployment`n" -ForegroundColor Cyan

# Step 1: Create directory
Write-Host "`u{1F4C1} Step 1: Creating app directory..." -ForegroundColor Yellow
ssh $VpsUser@$VpsIp "mkdir -p $AppDir"

# Step 2: Copy code to VPS
Write-Host "`u{1F4E4} Step 2: Copying code to VPS..." -ForegroundColor Yellow
Write-Host "   Creating archive..." -ForegroundColor Gray

$ArchivePath = "$env:TEMP\transcriber.tar.gz"

# Use tar
tar --exclude='.git' `
    --exclude='node_modules' `
    --exclude='venv' `
    --exclude='__pycache__' `
    --exclude='.pytest_cache' `
    --exclude='dist' `
    --exclude='.env' `
    --exclude='memory' `
    --exclude='docs/.archive' `
    -czf $ArchivePath .

Write-Host "   Uploading..." -ForegroundColor Gray
scp $ArchivePath "$VpsUser@$VpsIp`:$AppDir/" 2>&1 | Out-Null

Write-Host "   Extracting..." -ForegroundColor Gray
ssh $VpsUser@$VpsIp "cd $AppDir; tar -xzf transcriber.tar.gz; rm transcriber.tar.gz"

Remove-Item $ArchivePath -Force

# Step 3: Get API key
Write-Host ""
Write-Host "`u{1F510} Step 3: Setting up environment..." -ForegroundColor Yellow
$ApiKey = Read-Host "Enter your OpenAI API Key"

# Step 4: Create .env file on VPS
Write-Host "   Creating .env..." -ForegroundColor Gray
ssh $VpsUser@$VpsIp "cat > $AppDir/.env << 'ENVEOF'
OPENAI_API_KEY=$ApiKey
ENV=production
ENVEOF"

# Step 5: Setup docker-compose.yml
Write-Host "   Setting up docker-compose..." -ForegroundColor Gray
ssh $VpsUser@$VpsIp "cd $AppDir; mv docker-compose.prod.yml docker-compose.yml"

# Step 6: Update Caddy config
Write-Host ""
Write-Host "`u{1F504} Step 5: Updating Caddy reverse proxy..." -ForegroundColor Yellow

ssh $VpsUser@$VpsIp "cat >> /root/caddy/Caddyfile << 'CADDYEOF'

# WAV Transcriber
transcriber.anothershadeofgrey.com {
  reverse_proxy localhost:5173
  header / {
    Strict-Transport-Security `"max-age=31536000; includeSubDomains`"
    X-Content-Type-Options `"nosniff`"
    X-Frame-Options `"SAMEORIGIN`"
    X-XSS-Protection `"1; mode=block`"
    Referrer-Policy `"strict-origin-when-cross-origin`"
  }
}

api.anothershadeofgrey.com {
  reverse_proxy localhost:8000
  header / {
    Strict-Transport-Security `"max-age=31536000; includeSubDomains`"
    X-Content-Type-Options `"nosniff`"
    X-Frame-Options `"SAMEORIGIN`"
  }
}
CADDYEOF"

# Step 7: Reload Caddy
Write-Host "   Reloading Caddy..." -ForegroundColor Gray
ssh $VpsUser@$VpsIp "docker exec caddy caddy reload -c /etc/caddy/Caddyfile" 2>&1 | Out-Null

# Step 8: Build and run
Write-Host ""
Write-Host "`u{1F433} Step 6: Building and starting Docker containers..." -ForegroundColor Yellow
Write-Host "   (This takes 2-3 minutes, please wait...)" -ForegroundColor Gray
ssh $VpsUser@$VpsIp "cd $AppDir; docker compose build; docker compose up -d"

# Step 9: Verify
Write-Host ""
Write-Host "`u{2705} Step 7: Verifying deployment..." -ForegroundColor Yellow
ssh $VpsUser@$VpsIp "docker compose -f $AppDir/docker-compose.yml ps"

Write-Host "`n" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "`u{1F389} Deployment Complete!`n" -ForegroundColor Green
Write-Host "Your transcriber is running at:" -ForegroundColor Green
Write-Host "   https://transcriber.anothershadeofgrey.com`n" -ForegroundColor Cyan
Write-Host "Give DNS 1-2 minutes to propagate." -ForegroundColor Yellow
Write-Host ""
