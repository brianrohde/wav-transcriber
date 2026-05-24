"""OpenAI Whisper transcription provider."""
import os
import logging
from openai import OpenAI
from wav_transcriber.providers.base import BaseTranscriber

logger = logging.getLogger(__name__)


class WhisperTranscriber(BaseTranscriber):
    """Transcriber using OpenAI's Whisper API."""

    def __init__(self):
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set")
        self.client = OpenAI(api_key=api_key)

    def transcribe(self, audio_path: str) -> str:
        """
        Transcribe audio using OpenAI Whisper.

        Args:
            audio_path: Path to WAV audio file

        Returns:
            Transcribed text

        Raises:
            Exception: if Whisper API fails
        """
        logger.info(f"Sending audio to Whisper API: {audio_path}")

        try:
            with open(audio_path, "rb") as audio_file:
                transcript = self.client.audio.transcriptions.create(
                    model="whisper-1",
                    file=audio_file,
                )
            text = transcript.text
            logger.debug(f"Whisper transcription: {text[:100]}...")
            return text
        except FileNotFoundError:
            raise Exception(f"Audio file not found: {audio_path}")
        except Exception as e:
            raise Exception(f"Whisper API error: {e}")


def register():
    """Register the Whisper provider."""
    from wav_transcriber.config import register_provider
    register_provider("whisper", WhisperTranscriber)

register()
