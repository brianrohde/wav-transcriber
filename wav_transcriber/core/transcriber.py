"""Main transcription orchestrator."""
import logging
from typing import Optional
from wav_transcriber.core.audio import AudioValidator, AudioError
from wav_transcriber.config import PROVIDER_PRIORITY, get_provider

logger = logging.getLogger(__name__)


class TranscriptionError(Exception):
    """Base exception for transcription errors."""
    pass


class Transcriber:
    """Orchestrates transcription with provider fallback."""

    def __init__(self, provider_order: Optional[list] = None):
        self.provider_order = provider_order or PROVIDER_PRIORITY
        self.validators = []

    def transcribe(self, audio_path: str, preferred_provider: Optional[str] = None) -> str:
        """
        Transcribe an audio file using the provider chain.

        Args:
            audio_path: Path to WAV file
            preferred_provider: If specified, try this provider first

        Returns:
            Transcribed text

        Raises:
            AudioError: if audio file is invalid
            TranscriptionError: if all providers fail
        """
        # Validate audio file
        try:
            metadata = AudioValidator.validate(audio_path)
            logger.info(f"Audio valid: {metadata['duration_seconds']:.1f}s, {metadata['sample_rate']}Hz")
        except AudioError as e:
            logger.error(f"Audio validation failed: {e}")
            raise

        # Build provider chain
        providers_to_try = []
        if preferred_provider:
            providers_to_try.append(preferred_provider)
        providers_to_try.extend([p for p in self.provider_order if p != preferred_provider])

        # Try each provider
        last_error = None
        for provider_name in providers_to_try:
            try:
                logger.info(f"Attempting transcription with {provider_name}...")
                provider_class = get_provider(provider_name)
                provider = provider_class()
                result = provider.transcribe(audio_path)
                logger.info(f"Transcription succeeded with {provider_name}")
                return result
            except Exception as e:
                last_error = e
                logger.warning(f"Provider {provider_name} failed: {e}")
                continue

        raise TranscriptionError(f"All providers failed. Last error: {last_error}")
