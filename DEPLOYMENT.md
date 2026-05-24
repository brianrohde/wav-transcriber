# Deployment Guide

## Quick Deploy (Full Restart)

### Windows PowerShell
```powershell
.\deploy.ps1
```

### Mac/Linux
```bash
chmod +x deploy.sh
./deploy.sh
```

This will:
1. ✅ Stop all running services
2. ✅ Update Python dependencies
3. ✅ Update Node dependencies
4. ✅ Start backend API
5. ✅ Start frontend dev server
6. ✅ Verify both services are running

Then open: **http://localhost:5173**

## Update Debug Message

To show a deployment message to users:

1. Edit `debug_config.json`:
```json
{
  "enabled": true,
  "message": "2026_05_24-19_30 - New feature deployed"
}
```

2. **Save the file** - No restart needed! The message appears immediately when you refresh the browser.

## Manual Start (If you want to keep old processes)

**Terminal 1 - Backend:**
```bash
. .venv/Scripts/activate     # Windows: . .\.venv\Scripts\Activate.ps1
python -m wav_transcriber.api
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

## Troubleshooting

### Port Already in Use
If ports 5173 or 8000 are in use:

1. Change ports in `.env`:
```
FRONTEND_PORT=5174
BACKEND_PORT=8001
```

2. Update API URL in `frontend/src/App.vue`:
```javascript
const API_BASE_URL = 'http://localhost:8001'
```

3. Re-run `deploy.ps1` or `deploy.sh`

### Backend Won't Start
```bash
# Check if Python dependencies are installed
pip list | grep fastapi

# Reinstall if missing
pip install -r requirements.txt
```

### Frontend Won't Start
```bash
cd frontend
npm install
npm run dev
```

## Code Changes & Deployment

### After Editing Code

**Backend changes** (Python files):
- Run `./deploy.ps1` (or `deploy.sh`)
- Or manually restart: Kill backend, run `python -m wav_transcriber.api`

**Frontend changes** (Vue/CSS):
- Already auto-hot-reloads in dev mode
- If not: Kill frontend, run `npm run dev`

**Debug messages** (debug_config.json):
- Just save the file and refresh browser
- No restart needed!

## Production Deployment

When ready for production:

1. **Build frontend:**
```bash
cd frontend
npm run build
```

2. **Serve static files** - Use nginx, Apache, or any static host with `frontend/dist/`

3. **Run backend** with a production server:
```bash
pip install gunicorn
gunicorn -w 4 -k uvicorn.workers.UvicornWorker wav_transcriber.api:app
```

4. **Set environment variables** (don't use .env in production):
```bash
export OPENAI_API_KEY=sk-...
export LOG_LEVEL=INFO
```

## Deployment Checklist

- [ ] Updated `debug_config.json` with deployment message
- [ ] All code changes committed to git
- [ ] Frontend builds without errors: `npm run build`
- [ ] Backend runs without errors: `python -m wav_transcriber.api`
- [ ] Tests pass: `pytest`
- [ ] `.env` file exists with `OPENAI_API_KEY` set
- [ ] Browser opens to http://localhost:5173
- [ ] Can upload and transcribe a WAV file
- [ ] Debug message displays in UI

## Quick Reference

| Task | Command |
|------|---------|
| Full deploy | `.\deploy.ps1` |
| Update debug msg | Edit `debug_config.json` + refresh browser |
| Run tests | `pytest` |
| Format code | `black wav_transcriber` |
| Type check | `mypy wav_transcriber` |
| Frontend build | `cd frontend && npm run build` |
| Kill all services | `taskkill /F /IM python.exe && taskkill /F /IM node.exe` |
