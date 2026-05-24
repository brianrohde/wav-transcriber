# WAV Transcriber - Complete Setup Guide

## Prerequisites

- **Python 3.10+** - [Download](https://www.python.org/downloads/)
- **Node.js 18+** - [Download](https://nodejs.org/)
- **OpenAI API Key** - [Get one here](https://platform.openai.com/account/api-keys)

## Step-by-Step Setup

### 1. Clone or Navigate to Project Directory

```bash
cd Z:\_dev-ssd\wav-transcriber
```

### 2. Set Up Python Environment

#### Create Virtual Environment
```bash
python -m venv venv
```

#### Activate Virtual Environment

**Windows (PowerShell):**
```bash
.\venv\Scripts\Activate.ps1
```

**Windows (Command Prompt):**
```bash
venv\Scripts\activate
```

**Mac/Linux:**
```bash
source venv/bin/activate
```

#### Install Python Dependencies
```bash
pip install -r requirements.txt -r requirements-dev.txt
```

### 3. Configure OpenAI API Key

#### Create .env File

Create a new file named `.env` in the root directory (copy from `config.example.py` for reference):

```
OPENAI_API_KEY=sk-your-actual-api-key-here
TRANSCRIBER_PROVIDER=whisper
LOG_LEVEL=INFO
FRONTEND_PORT=5173
BACKEND_PORT=8000
```

#### Where to Get Your API Key

1. Go to: https://platform.openai.com/account/api-keys
2. Click "Create new secret key"
3. Copy the key (it starts with `sk-`)
4. Paste it in your `.env` file
5. Keep this key private - never commit it to git!

### 4. Set Up Frontend Dependencies

```bash
cd frontend
npm install
cd ..
```

### 5. Run the Application

#### Option A: Quick Start (Recommended)

**Windows (PowerShell):**
```bash
.\run.ps1
```

This will:
- Start the backend API on port 8000
- Start the frontend dev server on port 5173
- Automatically open new windows for each process

**Mac/Linux:**
```bash
chmod +x run.sh
./run.sh
```

#### Option B: Manual Start

**Terminal 1 - Backend:**
```bash
# Make sure virtual environment is activated
source venv/bin/activate  # or venv\Scripts\activate on Windows
python -m wav_transcriber.api
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

You should see:
```
VITE v5.0.0  ready in XXX ms

➜  Local:   http://localhost:5173/
```

### 6. Access the Application

Open your browser and go to: **http://localhost:5173**

You should see the futuristic liquid glass interface!

## Troubleshooting

### Port Already in Use

If port 5173 or 8000 is already in use:

**Change frontend port:**
- Edit `frontend/vite.config.js` and change `port: 5173` to your desired port
- Edit `frontend/src/App.vue` and update `API_BASE_URL` to match your backend port

**Change backend port:**
- Edit `.env` and change `BACKEND_PORT=8000` to your desired port
- Edit `frontend/src/App.vue` and update `API_BASE_URL` accordingly

### API Key Not Working

1. Verify the key format (should start with `sk-`)
2. Check it's correctly pasted in `.env` with no extra spaces
3. Try generating a new key at https://platform.openai.com/account/api-keys
4. Restart the backend after changing the `.env` file

### Frontend Can't Connect to Backend

1. Verify backend is running on http://localhost:8000
2. Check `API_BASE_URL` in `frontend/src/App.vue` matches your backend port
3. Ensure no firewall is blocking communication
4. Check browser console for CORS errors (press F12)

### File Upload Fails

1. Ensure file is in `.wav` format
2. Try a smaller file first to test
3. Check backend logs for error messages
4. Verify OpenAI API key is valid

## Commands Reference

### Backend

```bash
# Run the API server
python -m wav_transcriber.api

# Run tests
pytest

# Run with coverage
pytest --cov=wav_transcriber

# Type checking
mypy wav_transcriber

# Linting
flake8 wav_transcriber

# Format code
black wav_transcriber
```

### Frontend

```bash
# Development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
wav-transcriber/
├── wav_transcriber/          # Python backend
│   ├── api.py               # FastAPI server
│   ├── cli.py               # Command-line interface
│   ├── config.py            # Configuration
│   ├── core/
│   │   ├── audio.py         # Audio handling
│   │   └── transcriber.py   # Transcription logic
│   └── providers/
│       ├── base.py          # Provider interface
│       └── whisper.py       # Whisper implementation
├── frontend/                 # Vue 3 frontend
│   ├── src/
│   │   ├── App.vue          # Main component
│   │   ├── main.js          # Entry point
│   │   └── styles/
│   ├── index.html
│   └── package.json
├── tests/                    # Python tests
├── requirements.txt          # Python dependencies
├── .env                     # Configuration (create this)
├── CLAUDE.md                # Development guide
└── README.md                # Project overview
```

## Next Steps

1. **Test with a real WAV file** - Try transcribing something
2. **Add more providers** - Implement Handy or other backends
3. **Customize the UI** - Modify colors and animations in `frontend/src/`
4. **Deploy** - Build frontend and host your transcriber

## Getting Help

- Check `CLAUDE.md` for architecture details
- Check `frontend/README.md` for UI customization
- Backend errors appear in the terminal
- Frontend errors appear in browser console (F12)

## Production Deployment

When ready to deploy:

1. **Build the frontend:**
   ```bash
   cd frontend
   npm run build
   # Creates `dist/` folder with static files
   ```

2. **Serve the built frontend** - Use nginx, Apache, or your preferred web server

3. **Run backend** - Can be run with:
   ```bash
   gunicorn -w 4 -k uvicorn.workers.UvicornWorker wav_transcriber.api:app
   ```

4. **Set environment variables** - In production, use proper secret management (not `.env` files)

## Support

For issues or questions, check the project README and CLAUDE.md files.
