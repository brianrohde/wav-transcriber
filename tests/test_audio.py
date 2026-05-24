"""Tests for audio handling."""
import pytest
from pathlib import Path
from wav_transcriber.core.audio import AudioValidator, AudioError


def test_validate_nonexistent_file():
    """Test validation of non-existent file."""
    with pytest.raises(AudioError, match="File not found"):
        AudioValidator.validate("nonexistent.wav")


def test_validate_non_wav_file(tmp_path):
    """Test validation of non-WAV file."""
    fake_file = tmp_path / "test.txt"
    fake_file.write_text("not audio")

    with pytest.raises(AudioError, match="Not a WAV file"):
        AudioValidator.validate(str(fake_file))
