# Start both backend and frontend for wav-transcriber

Write-Host "🚀 Starting WAV Transcriber..." -ForegroundColor Green

# Activate Python virtual environment
. .\venv\Scripts\Activate.ps1

# Install backend dependencies if needed
Write-Host "📦 Checking backend dependencies..." -ForegroundColor Cyan
pip install -q -r requirements.txt

# Start backend in new window
Write-Host "🔧 Starting backend API on port 8000..." -ForegroundColor Cyan
Start-Process python -ArgumentList "-m wav_transcriber.api" -WindowStyle Normal

# Install frontend dependencies if needed
if (-not (Test-Path "frontend/node_modules")) {
    Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Cyan
    Push-Location frontend
    npm install
    Pop-Location
}

# Start frontend in new window
Write-Host "🎨 Starting frontend on port 5173..." -ForegroundColor Cyan
Start-Process npm -ArgumentList "-C frontend run dev" -WindowStyle Normal

Write-Host ""
Write-Host "✅ WAV Transcriber is running!" -ForegroundColor Green
Write-Host "   Frontend: http://localhost:5173" -ForegroundColor Yellow
Write-Host "   Backend:  http://localhost:8000" -ForegroundColor Yellow
Write-Host ""
