FROM python:3.10-slim

WORKDIR /app

# Install system dependencies for audio processing
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt requirements-dev.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY wav_transcriber ./wav_transcriber
COPY config.py ./

# Create uploads directory
RUN mkdir -p uploads

# Expose port
EXPOSE 8000

# Run the API server
CMD ["python", "-m", "wav_transcriber.api"]
