# WAV Transcriber VPS Deployment Script (PowerShell)
# This script pushes the code to your Hetzner VPS and sets up Docker

$VpsIp = "95.217.9.84"
$VpsUser = "root"
$AppDir = "/root/apps/transcriber"

Write-Host "🚀 WAV Transcriber VPS Deployment Script" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create app directory on VPS
Write-Host "📁 Step 1: Creating app directory on VPS..." -ForegroundColor Yellow
ssh $VpsUser@$VpsIp "mkdir -p $AppDir; cd $AppDir; echo 'Directory ready'"
if ($LASTEXITCODE -ne 0) { exit 1 }

# Step 2: Copy code to VPS
Write-Host "📤 Step 2: Copying code to VPS..." -ForegroundColor Yellow
Write-Host "   (This may take a minute...)" -ForegroundColor Gray

# Create temp directory for staging
$TempDir = Join-Path $env:TEMP "transcriber-deploy"
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
New-Item -ItemType Directory -Path $TempDir | Out-Null

# Copy files excluding unnecessary directories
$ExcludePatterns = @(
    '.git', 'node_modules', 'venv', '__pycache__',
    '.pytest_cache', 'dist', '.env', '.vscode', '.idea',
    'memory', 'docs\archive', '*.pyc'
)

Get-ChildItem -Path . -Recurse -Force |
    Where-Object {
        $skip = $false
        foreach ($pattern in $ExcludePatterns) {
            if ($_.FullName -match [regex]::Escape($pattern)) {
                $skip = $true
                break
            }
        }
        -not $skip
    } |
    ForEach-Object {
        $RelativePath = $_.FullName.Substring((Get-Location).Path.Length + 1)
        $TargetPath = Join-Path $TempDir $RelativePath

        if ($_.PSIsContainer) {
            if (!(Test-Path $TargetPath)) {
                New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
            }
        } else {
            New-Item -ItemType Directory -Path (Split-Path $TargetPath) -Force -ErrorAction SilentlyContinue | Out-Null
            Copy-Item -Path $_.FullName -Destination $TargetPath -Force
        }
    }

# Create tar archive
Write-Host "📦 Creating archive..." -ForegroundColor Gray
$TarFile = Join-Path $env:TEMP "transcriber.tar.gz"

# Using 7-Zip if available, otherwise tar if available
if (Get-Command 7z -ErrorAction SilentlyContinue) {
    7z a -ttar -so $TarFile $TempDir | 7z a -tgzip -si $TarFile | Out-Null
} elseif (Get-Command tar -ErrorAction SilentlyContinue) {
    tar -czf $TarFile -C $TempDir .
} else {
    Write-Host "❌ Neither 7z nor tar found. Please install one of them." -ForegroundColor Red
    exit 1
}

Write-Host "📤 Uploading to VPS..." -ForegroundColor Gray
scp $TarFile "$VpsUser@$VpsIp`:$AppDir/"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ SCP failed" -ForegroundColor Red
    exit 1
}

Write-Host "📂 Extracting on VPS..." -ForegroundColor Gray
ssh $VpsUser@$VpsIp "cd $AppDir; tar -xzf transcriber.tar.gz; rm transcriber.tar.gz; echo 'Code extracted'"

# Clean up
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $TarFile -Force -ErrorAction SilentlyContinue

# Step 3: Setup .env on VPS
Write-Host ""
Write-Host "🔐 Step 3: Setting up environment on VPS..." -ForegroundColor Yellow
$ApiKey = Read-Host "Enter your OPENAI_API_KEY"

ssh $VpsUser@$VpsIp @"
cat > $AppDir/.env << 'EOF'
OPENAI_API_KEY=$ApiKey
ENV=production
EOF
echo '.env created'
"@

# Step 4: Update docker-compose.yml on VPS
Write-Host ""
Write-Host "🐳 Step 4: Updating Docker Compose configuration..." -ForegroundColor Yellow
ssh $VpsUser@$VpsIp "cd $AppDir; mv docker-compose.prod.yml docker-compose.yml"

# Step 5: Update Caddy config
Write-Host ""
Write-Host "🔄 Step 5: Updating Caddy configuration..." -ForegroundColor Yellow

$CaddyConfig = @"
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
"@

ssh $VpsUser@$VpsIp @"
cat >> /root/caddy/Caddyfile << 'CADDYEOF'
$CaddyConfig
CADDYEOF
echo 'Caddy config updated'
"@

# Step 6: Reload Caddy
Write-Host ""
Write-Host "🔄 Step 6: Reloading Caddy reverse proxy..." -ForegroundColor Yellow
ssh $VpsUser@$VpsIp "docker exec caddy caddy reload -c /etc/caddy/Caddyfile"

# Step 7: Build and run containers
Write-Host ""
Write-Host "🐳 Step 7: Building and running Docker containers..." -ForegroundColor Yellow
Write-Host "   (This will take 2-3 minutes on first run...)" -ForegroundColor Gray
ssh $VpsUser@$VpsIp "cd $AppDir; docker compose build; docker compose up -d"

# Step 8: Verify deployment
Write-Host ""
Write-Host "✅ Step 8: Verifying deployment..." -ForegroundColor Yellow
ssh $VpsUser@$VpsIp "docker compose ps"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your transcriber is now running at:" -ForegroundColor Green
Write-Host "   🌐 https://transcriber.anothershadeofgrey.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "Give DNS a minute to propagate, then visit the URL!" -ForegroundColor Yellow
Write-Host ""
