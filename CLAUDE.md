# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**wav-transcriber** is a full-stack audio transcription system with a futuristic web interface that processes `.wav` files using multiple transcription backends. It starts with OpenAI Whisper as the primary provider, with extensibility to add open-source alternatives (like Handy) as fallbacks when the primary method fails.

## Architecture

### Frontend (Vue 3 + Vite + Tailwind CSS)
- **Liquid Glass UI** - Glassmorphism design with backdrop blur effects
- **Drag & Drop Interface** - Intuitive file selection with animated feedback
- **Real-time Status** - Live transcription progress indicators
- **Export Features** - Copy to clipboard or download as `.txt`
- **Responsive Design** - Works seamlessly across devices

### Backend (FastAPI)
- **REST API** - `/transcribe` endpoint for file uploads
- **CORS enabled** - Cross-origin communication with frontend
- **Async processing** - Non-blocking file handling with aiofiles

### Core Engine
- **Pluggable provider pattern** - Swappable transcription backends
- **Provider fallback chain** - Attempts each provider in order until success
- **Audio validation** - Reads and validates `.wav` files (sample rate, channels, duration)
- **Error handling** - Graceful degradation with detailed error messages

Key design principles:
- Providers are stateless and independently swappable
- Frontend/backend communicate via REST API (no tight coupling)
- Failures fall through to the next provider without losing context
- All configuration through environment variables (`.env` file)

## Development Setup

### Prerequisites
- Python 3.10+ (audio processing and FastAPI)
- Node.js 18+ (frontend with Vite)
- OpenAI API key (for Whisper backend) — get it from https://platform.openai.com/account/api-keys
- Virtual environment recommended

### Initial Build & Environment

**Backend Setup:**
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt -r requirements-dev.txt
```

**Frontend Setup:**
```bash
cd frontend
npm install
```

**Configuration:**
```bash
# Copy example config (for reference only)
# Create your own .env file in root with:
# OPENAI_API_KEY=sk-your-key-here
# See config.example.py for all options
```

### Running the Application

**Quick Start (Recommended):**
```bash
# Windows PowerShell
.\run.ps1

# Mac/Linux
./run.sh
```

**Manual Start:**
```bash
# Terminal 1: Backend API
source venv/bin/activate
python -m wav_transcriber.api

# Terminal 2: Frontend
cd frontend
npm run dev
```

Then open: http://localhost:5173

### CLI Usage (Without Web UI)
```bash
# Transcribe a single file
python -m wav_transcriber.cli transcribe path/to/audio.wav

# Transcribe with specific provider
python -m wav_transcriber.cli transcribe path/to/audio.wav --provider whisper

# Get audio file info
python -m wav_transcriber.cli info path/to/audio.wav

# Save transcription to file
python -m wav_transcriber.cli transcribe path/to/audio.wav -o output.txt
```

### Testing & Code Quality
```bash
# Run tests
pytest

# Run specific test
pytest tests/test_audio.py -v

# Test with coverage
pytest --cov=wav_transcriber

# Type checking
mypy wav_transcriber

# Linting
flake8 wav_transcriber

# Format code
black wav_transcriber
```

## Project Structure

```
wav-transcriber/
├── wav_transcriber/              # Backend Python package
│   ├── __main__.py              # CLI entry point
│   ├── __init__.py
│   ├── api.py                   # FastAPI server
│   ├── cli.py                   # Command-line interface
│   ├── config.py                # Configuration & provider registry
│   ├── core/
│   │   ├── __init__.py
│   │   ├── audio.py            # Audio file handling & validation
│   │   └── transcriber.py      # Main transcription orchestrator
│   └── providers/
│       ├── __init__.py
│       ├── base.py             # Abstract provider base class
│       ├── whisper.py          # OpenAI Whisper implementation
│       └── handy.py            # Future: open-source alternatives
│
├── frontend/                     # Vue 3 + Vite frontend
│   ├── src/
│   │   ├── App.vue             # Main Vue component (liquid glass UI)
│   │   ├── main.js             # Entry point
│   │   └── styles/
│   │       └── index.css       # Global styles with Tailwind
│   ├── index.html              # HTML entry point
│   ├── vite.config.js          # Vite configuration
│   ├── tailwind.config.js      # Tailwind CSS configuration
│   ├── postcss.config.js       # PostCSS configuration
│   ├── package.json            # Node dependencies
│   ├── .gitignore
│   └── README.md
│
├── tests/                        # Python test suite
│   ├── __init__.py
│   ├── test_audio.py
│   └── test_providers.py
│
├── .env                         # Environment variables (create this)
├── .gitignore                   # Git ignore patterns
├── CLAUDE.md                    # This file - development guide
├── SETUP.md                     # Step-by-step setup instructions
├── README.md                    # Project overview
├── config.example.py            # Configuration template
├── requirements.txt             # Python dependencies
├── requirements-dev.txt         # Development dependencies
├── pytest.ini                   # Pytest configuration
├── run.sh                       # Start script (Mac/Linux)
├── run.ps1                      # Start script (Windows)
└── venv/                        # Python virtual environment (created locally)
```

## Key Implementation Notes

- **Provider interface**: Each provider inherits from `BaseTranscriber` with a `transcribe(audio_path: str) -> str` method
- **Error handling**: Providers should raise `TranscriptionError` on failure; the orchestrator catches these and tries the next provider
- **Audio validation**: Check sample rate, channels, and file integrity before passing to providers
- **Config**: Provider priority order and API keys should live in config or environment variables, not hardcoded

## Common Tasks

**Adding a new transcription provider:**
1. Create a new file in `providers/` (e.g., `handy.py`)
2. Inherit from `BaseTranscriber` and implement `transcribe()`
3. Register in `config.py`'s provider registry
4. Add tests in `tests/test_providers.py`
5. Update CLI `--provider` choices

**Testing a new provider:**
```bash
# Use test fixtures from tests/fixtures/
pytest tests/test_providers.py::test_handy_provider -v
```

**Debugging transcription failures:**
- Check audio file is valid `.wav` format and not corrupted
- Verify API keys are set in environment
- Check provider-specific logs (Whisper often returns 400 errors for unsupported sample rates)
