"""Abstract base class for transcription providers."""
from abc import ABC, abstractmethod


class BaseTranscriber(ABC):
    """Base class for all transcription providers."""

    @abstractmethod
    def transcribe(self, audio_path: str) -> str:
        """
        Transcribe an audio file.

        Args:
            audio_path: Path to WAV audio file

        Returns:
            Transcribed text

        Raises:
            Exception: on transcription failure
        """
        pass
