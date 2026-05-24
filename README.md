# WAV Transcriber

A flexible audio transcription system with a futuristic liquid glass UI that processes `.wav` files using multiple transcription backends.

## Features

- **Modern Web Interface**: Futuristic liquid glass design with drag-and-drop support
- **Haptic animations**: Smooth, responsive UI with animated feedback
- **Multi-backend support**: Start with OpenAI Whisper, add open-source alternatives (Handy, etc.) as fallbacks
- **Pluggable providers**: Easy to add new transcription methods
- **Automatic fallback**: If one provider fails, the system tries the next one
- **Audio validation**: Validates WAV files before transcription
- **Export options**: Copy to clipboard or save as `.txt` file

## Quick Start

### Setup

#### 1. Backend Setup
```bash
# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies (if not done already)
pip install -r requirements.txt -r requirements-dev.txt
```

#### 2. Configure OpenAI API Key

Edit the `.env` file in the root directory and set your OpenAI API key:

```
OPENAI_API_KEY=sk-your-actual-api-key-here
```

Get your API key from: https://platform.openai.com/account/api-keys

#### 3. Frontend Setup
```bash
cd frontend
npm install
```

### Running the Application

#### Option 1: Start everything with one command (recommended)

**On Windows:**
```bash
.\deploy.ps1
```

**On Mac/Linux:**
```bash
chmod +x deploy.sh
./deploy.sh
```

#### Option 2: Start backend and frontend separately

**Terminal 1 - Backend:**
```bash
source venv/bin/activate  # Or: venv\Scripts\activate on Windows
python -m wav_transcriber.api
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

Then open your browser to: **http://localhost:5173**

### Usage

Transcribe a WAV file:

```bash
python -m wav_transcriber transcribe path/to/audio.wav
```

Save output to a file:

```bash
python -m wav_transcriber transcribe path/to/audio.wav -o output.txt
```

Specify a provider:

```bash
python -m wav_transcriber transcribe path/to/audio.wav --provider whisper
```

Get audio file info:

```bash
python -m wav_transcriber info path/to/audio.wav
```

### Testing

Run all tests:

```bash
pytest
```

Run with coverage:

```bash
pytest --cov=wav_transcriber
```

Run specific test:

```bash
pytest tests/test_audio.py -v
```

### Code Quality

```bash
# Type checking
mypy wav_transcriber

# Linting
flake8 wav_transcriber

# Format code
black wav_transcriber
```

## Adding a New Provider

1. Create a new file in `wav_transcriber/providers/` (e.g., `handy.py`)
2. Inherit from `BaseTranscriber`:

```python
from wav_transcriber.providers.base import BaseTranscriber
from wav_transcriber.config import register_provider

class HandyTranscriber(BaseTranscriber):
    def transcribe(self, audio_path: str) -> str:
        # Your implementation
        pass

register_provider("handy", HandyTranscriber)
```

3. Import the provider in `wav_transcriber/cli.py` to register it
4. Add tests in `tests/test_providers.py`

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Architecture and development guidance for contributors
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Detailed deployment guide
- **[docs/QUICKSTART.md](docs/QUICKSTART.md)** - 5-minute quick start guide
- **[docs/SETUP.md](docs/SETUP.md)** - Complete setup instructions
- **[docs/ENV_SETUP.md](docs/ENV_SETUP.md)** - Environment variable configuration

## Architecture

See `CLAUDE.md` for detailed architecture and development guidance.
