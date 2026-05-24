#!/bin/bash
# WAV Transcriber Deployment Script (Mac/Linux)
# Usage: ./deploy.sh

echo "🚀 WAV Transcriber Deployment"
echo ""

# Kill existing processes
echo "🛑 Stopping existing services..."
pkill -f "python.*api" 2>/dev/null || true
pkill -f "npm.*dev" 2>/dev/null || true
sleep 2

# Activate venv and install dependencies
echo "📦 Installing/updating dependencies..."
source venv/bin/activate 2>/dev/null || . ./venv/bin/activate
pip install -q -r requirements.txt

# Install/update frontend dependencies
echo "🎨 Installing frontend dependencies..."
cd frontend
npm install -q 2>/dev/null
cd ..

# Start backend
echo "🔧 Starting backend API..."
python -m wav_transcriber.api > /tmp/backend.log 2>&1 &
sleep 3

# Start frontend
echo "🎨 Starting frontend..."
cd frontend
npm run dev > /tmp/frontend.log 2>&1 &
cd ..
sleep 3

# Verify health
echo ""
echo "✅ Deployment complete!"
echo ""
echo "Services running:"
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
  echo "  ✓ Backend: http://localhost:8000"
fi
if curl -s http://localhost:5173 > /dev/null 2>&1; then
  echo "  ✓ Frontend: http://localhost:5173"
fi

echo ""
echo "📝 Debug message: Check debug_config.json to update deployment message"
echo "🌐 Open browser: http://localhost:5173"
echo ""
