"""FastAPI backend for wav_transcriber."""
import os
import logging
from pathlib import Path
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import aiofiles

from wav_transcriber.core.transcriber import Transcriber, TranscriptionError
from wav_transcriber.core.audio import AudioError
from wav_transcriber.providers import whisper  # noqa: F401 - import to register provider
from wav_transcriber.config import DEBUG_FLAG, DEBUG_MESSAGE

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="WAV Transcriber API")

# Add CORS middleware for frontend communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Temporary upload directory
UPLOAD_DIR = Path("temp_uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


@app.get("/health")
async def health():
    """Health check endpoint."""
    response = {"status": "ok"}
    if DEBUG_FLAG:
        response["debug"] = DEBUG_MESSAGE
    return response


@app.get("/debug")
async def debug():
    """Debug endpoint - returns debug flag and message."""
    return {
        "debug_enabled": DEBUG_FLAG,
        "debug_message": DEBUG_MESSAGE
    }


@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...), provider: str = "whisper"):
    """
    Transcribe an uploaded audio file.

    Args:
        file: WAV audio file
        provider: Transcription provider to use

    Returns:
        JSON with transcribed text
    """
    if not file.filename.lower().endswith(".wav"):
        raise HTTPException(status_code=400, detail="Only WAV files are supported")

    # Save uploaded file temporarily
    temp_path = UPLOAD_DIR / file.filename
    try:
        async with aiofiles.open(temp_path, "wb") as f:
            content = await file.read()
            await f.write(content)

        # Transcribe
        logger.info(f"Transcribing: {file.filename}")
        transcriber = Transcriber()
        result = transcriber.transcribe(str(temp_path), preferred_provider=provider)

        return {
            "status": "success",
            "filename": file.filename,
            "text": result,
        }

    except AudioError as e:
        logger.error(f"Audio error: {e}")
        raise HTTPException(status_code=400, detail=f"Audio error: {str(e)}")
    except TranscriptionError as e:
        logger.error(f"Transcription error: {e}")
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
    finally:
        # Clean up temporary file
        if temp_path.exists():
            temp_path.unlink()


@app.post("/transcribe-local")
async def transcribe_local(audio_path: str, provider: str = "whisper"):
    """
    Transcribe a local audio file by path.

    Args:
        audio_path: Path to WAV file on the system
        provider: Transcription provider to use

    Returns:
        JSON with transcribed text
    """
    path = Path(audio_path)

    if not path.exists():
        raise HTTPException(status_code=400, detail="File not found")

    if not path.suffix.lower() == ".wav":
        raise HTTPException(status_code=400, detail="Only WAV files are supported")

    try:
        logger.info(f"Transcribing local file: {audio_path}")
        transcriber = Transcriber()
        result = transcriber.transcribe(str(path), preferred_provider=provider)

        return {
            "status": "success",
            "filename": path.name,
            "text": result,
        }

    except AudioError as e:
        logger.error(f"Audio error: {e}")
        raise HTTPException(status_code=400, detail=f"Audio error: {str(e)}")
    except TranscriptionError as e:
        logger.error(f"Transcription error: {e}")
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("BACKEND_PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
