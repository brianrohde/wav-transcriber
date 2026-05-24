#!/bin/bash
# Start both backend and frontend for wav-transcriber

set -e

echo "🚀 Starting WAV Transcriber..."

# Activate Python virtual environment
source venv/bin/activate

# Install backend dependencies if needed
echo "📦 Checking backend dependencies..."
pip install -q -r requirements.txt

# Start backend
echo "🔧 Starting backend API on port 8000..."
python -m wav_transcriber.api &
BACKEND_PID=$!

# Install frontend dependencies if needed
if [ ! -d "frontend/node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
fi

# Start frontend
echo "🎨 Starting frontend on port 5173..."
cd frontend
npm run dev &
FRONTEND_PID=$!

cd ..

echo ""
echo "✅ WAV Transcriber is running!"
echo "   Frontend: http://localhost:5173"
echo "   Backend:  http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop"

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID
