"""Configuration and provider registry."""
import os
import json
from pathlib import Path
from typing import Dict, Type
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
TRANSCRIBER_PROVIDER = os.getenv("TRANSCRIBER_PROVIDER", "whisper")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# Load debug config from JSON
DEBUG_FLAG = False
DEBUG_MESSAGE = ""
try:
    debug_config_path = Path(__file__).parent.parent / "debug_config.json"
    if debug_config_path.exists():
        with open(debug_config_path) as f:
            debug_config = json.load(f)
            DEBUG_FLAG = debug_config.get("enabled", False)
            DEBUG_MESSAGE = debug_config.get("message", "")
except Exception:
    pass  # Silently fail if debug config doesn't exist

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
