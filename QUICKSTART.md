# WAV Transcriber - Quick Start

## 🚀 Get Running in 5 Minutes

### 1. Set Your OpenAI API Key

Create a `.env` file in the project root:

```
OPENAI_API_KEY=sk-your-key-from-https://platform.openai.com/account/api-keys
```

### 2. Start Everything

**Windows (PowerShell):**
```bash
.\run.ps1
```

**Mac/Linux:**
```bash
chmod +x run.sh
./run.sh
```

### 3. Open Your Browser

Go to: **http://localhost:5173**

## 🎨 Features

✨ **Futuristic Liquid Glass UI** - Beautiful glassmorphism design
🎯 **Drag & Drop** - Drag files or click to browse
⚡ **Lightning Fast** - Powered by OpenAI Whisper
📋 **Export** - Copy to clipboard or save as `.txt`
🔄 **Smart Fallback** - Automatic provider switching (ready for Handy integration)

## 📝 Manual Start (if needed)

**Terminal 1 - Backend:**
```bash
venv\Scripts\activate  # or: source venv/bin/activate on Mac/Linux
python -m wav_transcriber.api
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 5173/8000 in use | Edit `.env` to change ports, then edit `frontend/src/App.vue` API_BASE_URL |
| API key error | Check key format (should start with `sk-`), verify it's in `.env`, restart backend |
| "Can't connect to backend" | Verify backend is running, check browser console (F12), ensure no firewall blocks it |
| File upload fails | Ensure file is `.wav` format, try a smaller file first |

## 📚 Full Documentation

- **Setup Guide:** See `SETUP.md`
- **Architecture:** See `CLAUDE.md`
- **Frontend Docs:** See `frontend/README.md`
- **Backend Tests:** Run `pytest`

## 🔧 Command Reference

```bash
# Run backend API
python -m wav_transcriber.api

# CLI transcription (no web UI)
python -m wav_transcriber transcribe file.wav

# Run tests
pytest

# Frontend development
cd frontend && npm run dev

# Build frontend for production
cd frontend && npm run build
```

## 🎁 What's Included

- ✅ Full-stack web application
- ✅ Modern Vue 3 + Vite frontend
- ✅ FastAPI backend with CORS
- ✅ OpenAI Whisper integration
- ✅ Comprehensive test suite
- ✅ Type checking with mypy
- ✅ Code formatting with black
- ✅ Pluggable provider system

## 🌟 Next Steps

1. **Test it** - Drag a WAV file and transcribe it
2. **Customize** - Edit colors in `frontend/tailwind.config.js`
3. **Deploy** - Build frontend with `npm run build` and serve static files
4. **Extend** - Add more providers by following the pattern in `wav_transcriber/providers/`

Enjoy! 🎉
