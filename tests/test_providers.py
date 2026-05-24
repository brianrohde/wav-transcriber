"""Tests for transcription providers."""
import pytest
from unittest.mock import patch, MagicMock
from wav_transcriber.providers.whisper import WhisperTranscriber


def test_whisper_requires_api_key():
    """Test that Whisper requires OPENAI_API_KEY."""
    with patch("wav_transcriber.providers.whisper.OPENAI_API_KEY", None):
        with pytest.raises(ValueError, match="OPENAI_API_KEY"):
            WhisperTranscriber()


def test_whisper_transcribe_success():
    """Test successful Whisper transcription."""
    with patch("wav_transcriber.providers.whisper.OPENAI_API_KEY", "test-key"):
        with patch("wav_transcriber.providers.whisper.OpenAI") as mock_openai:
            mock_client = MagicMock()
            mock_openai.return_value = mock_client
            mock_client.audio.transcriptions.create.return_value = MagicMock(
                text="Hello world"
            )

            transcriber = WhisperTranscriber()
            with patch("builtins.open", create=True):
                result = transcriber.transcribe("test.wav")

            assert result == "Hello world"


def test_whisper_transcribe_file_not_found():
    """Test Whisper handles missing file gracefully."""
    with patch("wav_transcriber.providers.whisper.OPENAI_API_KEY", "test-key"):
        with patch("wav_transcriber.providers.whisper.OpenAI"):
            transcriber = WhisperTranscriber()

            with pytest.raises(Exception, match="Audio file not found"):
                transcriber.transcribe("nonexistent.wav")
