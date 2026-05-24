"""Audio file handling and validation."""
import os
from pathlib import Path
from scipy.io import wavfile


class AudioError(Exception):
    """Base exception for audio-related errors."""
    pass


class AudioValidator:
    """Validates and inspects WAV audio files."""

    @staticmethod
    def validate(audio_path: str) -> dict:
        """
        Validate a WAV file and return its metadata.

        Returns:
            dict with keys: sample_rate, channels, duration_seconds, file_size_mb

        Raises:
            AudioError: if file is invalid or doesn't exist
        """
        path = Path(audio_path)

        if not path.exists():
            raise AudioError(f"File not found: {audio_path}")

        if not path.suffix.lower() == ".wav":
            raise AudioError(f"Not a WAV file: {audio_path}")

        try:
            sample_rate, audio_data = wavfile.read(audio_path)
        except Exception as e:
            raise AudioError(f"Failed to read WAV file: {e}")

        # Get file size
        file_size_mb = os.path.getsize(audio_path) / (1024 * 1024)

        # Determine channels
        if len(audio_data.shape) == 1:
            channels = 1
            duration_seconds = len(audio_data) / sample_rate
        else:
            channels = audio_data.shape[1]
            duration_seconds = audio_data.shape[0] / sample_rate

        return {
            "sample_rate": sample_rate,
            "channels": channels,
            "duration_seconds": duration_seconds,
            "file_size_mb": file_size_mb,
        }
