"""Configuration and provider registry."""
import os
from typing import Dict, Type
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
TRANSCRIBER_PROVIDER = os.getenv("TRANSCRIBER_PROVIDER", "whisper")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

PROVIDER_PRIORITY = [
    "whisper",
]

PROVIDER_REGISTRY: Dict[str, Type] = {}


def register_provider(name: str, provider_class: Type) -> None:
    """Register a transcription provider."""
    PROVIDER_REGISTRY[name] = provider_class


def get_provider(name: str):
    """Get a provider by name."""
    if name not in PROVIDER_REGISTRY:
        raise ValueError(f"Unknown provider: {name}. Available: {list(PROVIDER_REGISTRY.keys())}")
    return PROVIDER_REGISTRY[name]
