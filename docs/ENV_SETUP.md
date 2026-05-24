# .env File Configuration

## How to Create Your .env File

1. Create a new file named `.env` in the project root (same directory as README.md)
2. Copy the content below
3. Replace `sk-xxx` with your actual OpenAI API key
4. Save the file

## .env File Content

```bash
# ============================================================================
# REQUIRED: OpenAI API Configuration
# ============================================================================
# Get your API key from: https://platform.openai.com/account/api-keys
# It should look like: sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# NEVER commit this file to git or share your key publicly!
OPENAI_API_KEY=sk-your-api-key-here

# ============================================================================
# Optional: Transcription Provider
# ============================================================================
# Available: whisper (default), handy (when implemented)
# The system will try providers in order if primary fails
TRANSCRIBER_PROVIDER=whisper

# ============================================================================
# Optional: Logging Level
# ============================================================================
# DEBUG: Show all details (very verbose)
# INFO: General information (recommended)
# WARNING: Only warnings and errors
# ERROR: Only errors
# CRITICAL: Only critical errors
LOG_LEVEL=INFO

# ============================================================================
# Optional: Frontend Port
# ============================================================================
# Change if port 5173 is already in use on your system
# After changing, update API_BASE_URL in frontend/src/App.vue
FRONTEND_PORT=5173

# ============================================================================
# Optional: Backend API Port
# ============================================================================
# Change if port 8000 is already in use on your system
# After changing, update API_BASE_URL in frontend/src/App.vue
BACKEND_PORT=8000
```

## Where to Get Your OpenAI API Key

### Step-by-step:

1. Go to: **https://platform.openai.com/account/api-keys**
2. Sign in with your OpenAI account (create one if needed)
3. Click **"Create new secret key"** button
4. A new key will appear (starts with `sk-`)
5. Click the copy icon to copy it
6. Paste it in your `.env` file after `OPENAI_API_KEY=`
7. **Don't share this key!** It's secret!

### Important Security Notes:

- ⚠️ **Never commit `.env` to git** - It's already in `.gitignore`
- ⚠️ **Never share your API key** - It can be used to incur costs
- ⚠️ **Never post it on GitHub/forums** - Bots scan for leaked keys
- ✅ **Keep it safe** - Treat it like a password
- ✅ **Regenerate if leaked** - Delete old key, create new one at API keys page

## Changing Ports

If ports 5173 or 8000 are already in use:

### Option 1: Change in .env (Easy)

```bash
FRONTEND_PORT=5174
BACKEND_PORT=8001
```

Then update `frontend/src/App.vue`:
```javascript
const API_BASE_URL = 'http://localhost:8001'  // Match BACKEND_PORT
```

### Option 2: Use Different Ports

```bash
# Terminal 1 - Custom backend port
BACKEND_PORT=8001 python -m wav_transcriber.api

# Terminal 2 - Custom frontend port
cd frontend
VITE_PORT=5174 npm run dev
```

## Example .env File (Filled In)

```bash
OPENAI_API_KEY=sk-proj-ZXhhbXBsZWtleXRoYXRzdGFydHN3aXRoc2twcm9q
TRANSCRIBER_PROVIDER=whisper
LOG_LEVEL=INFO
FRONTEND_PORT=5173
BACKEND_PORT=8000
```

## Verifying Your Setup

After creating `.env`, verify everything works:

```bash
# Test backend can find API key
python -c "import os; from dotenv import load_dotenv; load_dotenv(); print('✓ API Key loaded' if os.getenv('OPENAI_API_KEY') else '✗ API Key not found')"

# Start backend
python -m wav_transcriber.api

# In another terminal, test API
curl http://localhost:8000/health
# Should respond: {"status":"ok"}
```

## Troubleshooting

### Error: "OPENAI_API_KEY environment variable not set"
- Create `.env` file
- Add `OPENAI_API_KEY=sk-...`
- Restart the backend

### Error: "Invalid API key"
- Check key format: should start with `sk-`
- No extra spaces: `sk-xxx ` (space) is invalid
- Generate new key if old one is deactivated

### Ports already in use
- Change `FRONTEND_PORT` and `BACKEND_PORT` in `.env`
- Update `API_BASE_URL` in `frontend/src/App.vue` to match backend port

### .env file not found
- File must be named exactly `.env` (with the dot)
- Must be in project root (same level as README.md)
- Not in `/frontend` or any subdirectory

## For Production

When deploying to production:

1. **Don't use .env files** - Use proper secret management:
   - Environment variables (set by deployment platform)
   - Secret management service (AWS Secrets Manager, Vault, etc.)
   - Configuration management

2. **Rotate keys regularly** - Regenerate API keys periodically

3. **Use minimal permissions** - If possible, create API key with limited scope

4. **Monitor usage** - Check API usage at https://platform.openai.com/account/billing

## Need Help?

- Check `SETUP.md` for full setup instructions
- Check `QUICKSTART.md` for quick reference
- Check backend logs: they show configuration errors
- Check browser console (F12) for frontend errors
