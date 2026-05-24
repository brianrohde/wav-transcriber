# WAV Transcriber Deployment Script (Windows PowerShell)
# Usage: .\deploy.ps1

Write-Host "🚀 WAV Transcriber Deployment" -ForegroundColor Green
Write-Host ""

# Kill existing processes
Write-Host "🛑 Stopping existing services..." -ForegroundColor Cyan
taskkill /F /IM python.exe 2>$null | Out-Null
taskkill /F /IM node.exe 2>$null | Out-Null
Start-Sleep -Seconds 2

# Activate venv and install dependencies
Write-Host "📦 Installing/updating dependencies..." -ForegroundColor Cyan
. .\.venv\Scripts\Activate.ps1
pip install -q -r requirements.txt

# Install/update frontend dependencies
Write-Host "🎨 Installing frontend dependencies..." -ForegroundColor Cyan
Push-Location frontend
npm install -q 2>$null
Pop-Location

# Start backend
Write-Host "🔧 Starting backend API..." -ForegroundColor Cyan
python -m wav_transcriber.api | Out-Null &
Start-Sleep -Seconds 3

# Start frontend
Write-Host "🎨 Starting frontend..." -ForegroundColor Cyan
Push-Location frontend
npm run dev | Out-Null &
Pop-Location
Start-Sleep -Seconds 3

# Verify health
Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Services running:" -ForegroundColor Yellow
$backend = curl -s http://localhost:8000/health 2>$null
$frontend = curl -s http://localhost:5173 2>$null | Select-Object -First 1
if ($backend) { Write-Host "  ✓ Backend: http://localhost:8000" -ForegroundColor Green }
if ($frontend) { Write-Host "  ✓ Frontend: http://localhost:5173" -ForegroundColor Green }

Write-Host ""
Write-Host "📝 Debug message: Check debug_config.json to update deployment message" -ForegroundColor Cyan
Write-Host "🌐 Open browser: http://localhost:5173" -ForegroundColor Yellow
Write-Host ""
