# WAV Transcriber - Developer Cheatsheet

## 🚀 Getting Started

```bash
# Activate Python environment
source venv/bin/activate              # Mac/Linux
venv\Scripts\Activate.ps1             # Windows PowerShell

# Create .env (ONE TIME)
# Copy this into a new .env file:
# OPENAI_API_KEY=sk-your-api-key-here

# Start everything (easy way)
./run.sh                              # Mac/Linux
.\run.ps1                             # Windows

# Open browser
http://localhost:5173
```

## 🛠️ Backend Development

### Start Backend Only
```bash
source venv/bin/activate
python -m wav_transcriber.api
# Runs on http://localhost:8000
```

### CLI Transcription (No Web UI)
```bash
python -m wav_transcriber transcribe /path/to/audio.wav
python -m wav_transcriber transcribe /path/to/audio.wav --provider whisper
python -m wav_transcriber transcribe /path/to/audio.wav -o output.txt
python -m wav_transcriber info /path/to/audio.wav
```

### Testing
```bash
pytest                              # Run all tests
pytest tests/test_audio.py          # Specific test file
pytest tests/test_providers.py -v   # With verbose output
pytest --cov=wav_transcriber        # With coverage report
```

### Code Quality
```bash
mypy wav_transcriber                # Type checking
flake8 wav_transcriber              # Linting
black wav_transcriber               # Auto-format code
```

## 🎨 Frontend Development

### Start Frontend Only
```bash
cd frontend
npm run dev
# Runs on http://localhost:5173
```

### Build Frontend
```bash
cd frontend
npm run build
# Creates dist/ folder
```

### Edit UI
- Main component: `frontend/src/App.vue`
- Styles: `frontend/src/styles/index.css`
- Colors: Edit `frontend/tailwind.config.js`
- Animations: Modify `@keyframes blob` in CSS

## 🔌 Adding a New Provider

### 1. Create Provider File
```bash
# Create: wav_transcriber/providers/handy.py
```

### 2. Implement Provider
```python
from wav_transcriber.providers.base import BaseTranscriber
from wav_transcriber.config import register_provider

class HandyTranscriber(BaseTranscriber):
    def transcribe(self, audio_path: str) -> str:
        # Your implementation here
        pass

register_provider("handy", HandyTranscriber)
```

### 3. Import in CLI
```python
# Add to wav_transcriber/cli.py
from wav_transcriber.providers import handy  # noqa: F401
```

### 4. Add Tests
```python
# Add to tests/test_providers.py
def test_handy_transcribe():
    # Your test here
    pass
```

## 🔧 Configuration

### Change Ports
```bash
# Edit .env
FRONTEND_PORT=5174
BACKEND_PORT=8001

# Update frontend API URL in frontend/src/App.vue
const API_BASE_URL = 'http://localhost:8001'
```

### Change Log Level
```bash
# Edit .env
LOG_LEVEL=DEBUG      # Most verbose
LOG_LEVEL=INFO       # Normal
LOG_LEVEL=WARNING    # Less verbose
```

## 📊 API Endpoints

### POST /transcribe
Upload and transcribe a file
```bash
curl -X POST -F "file=@audio.wav" http://localhost:8000/transcribe
```

### POST /transcribe-local
Transcribe a file by path
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"audio_path": "/path/to/file.wav"}' \
  http://localhost:8000/transcribe-local
```

### GET /health
Health check
```bash
curl http://localhost:8000/health
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `.env` | API keys & config (YOU CREATE THIS) |
| `wav_transcriber/api.py` | FastAPI server |
| `wav_transcriber/core/transcriber.py` | Main orchestrator |
| `frontend/src/App.vue` | Frontend UI |
| `frontend/tailwind.config.js` | Color/style config |
| `requirements.txt` | Python dependencies |

## 🐛 Troubleshooting

### "OPENAI_API_KEY not set"
```bash
# Check .env exists in project root
# Check it has: OPENAI_API_KEY=sk-...
# Restart backend after adding .env
```

### Port Already in Use
```bash
# Change in .env
FRONTEND_PORT=5174
BACKEND_PORT=8001

# Update API_BASE_URL in frontend/src/App.vue
const API_BASE_URL = 'http://localhost:8001'
```

### Can't Upload Files
```bash
# Check file is .wav format
# Check file size isn't too large
# Check backend is running
# Check browser console for errors (F12)
```

## 🧪 Testing Checklist

Before pushing code:
```bash
pytest                              # All tests pass?
mypy wav_transcriber                # Type errors?
flake8 wav_transcriber              # Linting issues?
black --check wav_transcriber       # Formatting ok?
```

## 📦 Installing New Packages

### Python
```bash
pip install package-name
pip freeze > requirements.txt    # Update requirements
```

### Node (Frontend)
```bash
cd frontend
npm install package-name
```

## 🚀 Deploy Checklist

```bash
# Backend
python -m wav_transcriber.api    # Works locally?
pytest                           # All tests pass?

# Frontend  
cd frontend
npm run build                    # Build succeeds?
npm run preview                  # Preview works?

# Ready to deploy!
```

## 💡 Pro Tips

1. **Use CLI for testing**: `python -m wav_transcriber transcribe file.wav`
2. **Check logs**: Backend prints detailed error messages
3. **Browser DevTools**: F12 shows frontend errors and network requests
4. **Git ignore .env**: Already in `.gitignore` - safe to use
5. **Save often**: Frontend hot-reloads, backend needs restart
6. **Run tests**: Quick feedback on changes
7. **Type hints**: Add them to any new code
8. **Docstrings**: Keep them short and clear

## 🔗 Useful Links

- OpenAI API: https://platform.openai.com/account/api-keys
- Vue 3 Docs: https://vuejs.org/guide/
- FastAPI Docs: https://fastapi.tiangolo.com/
- Tailwind CSS: https://tailwindcss.com/docs
- pytest Docs: https://docs.pytest.org/

---

**Need more help?** Check `SETUP.md`, `CLAUDE.md`, or the code comments!
