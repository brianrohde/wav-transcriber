"""Tests for FastAPI backend."""
import pytest
from fastapi.testclient import TestClient
from wav_transcriber.api import app

client = TestClient(app)


def test_health_check():
    """Test API health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_transcribe_invalid_file_type():
    """Test transcribe endpoint rejects non-WAV files."""
    from io import BytesIO

    # Create a fake MP3 file
    fake_file = BytesIO(b"fake mp3 data")
    files = {"file": ("test.mp3", fake_file, "audio/mpeg")}

    response = client.post("/transcribe", files=files)
    assert response.status_code == 400
    assert "WAV" in response.json()["detail"]


def test_transcribe_missing_file():
    """Test transcribe endpoint with no file."""
    response = client.post("/transcribe")
    assert response.status_code == 422  # Validation error
