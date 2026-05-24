"""Command-line interface for wav_transcriber."""
import sys
import logging
import argparse
from pathlib import Path

from wav_transcriber.core.transcriber import Transcriber, TranscriptionError
from wav_transcriber.core.audio import AudioError
from wav_transcriber.config import PROVIDER_REGISTRY, LOG_LEVEL
from wav_transcriber.providers import whisper  # noqa: F401 - import to register

logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def main():
    """Main CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Transcribe WAV audio files using multiple backends",
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    # Transcribe command
    transcribe_parser = subparsers.add_parser("transcribe", help="Transcribe a WAV file")
    transcribe_parser.add_argument("audio_path", help="Path to WAV file")
    transcribe_parser.add_argument(
        "--provider",
        help="Preferred transcription provider",
        choices=list(PROVIDER_REGISTRY.keys()),
    )
    transcribe_parser.add_argument(
        "--output",
        "-o",
        help="Save transcription to file",
    )

    # Info command
    info_parser = subparsers.add_parser("info", help="Show audio file info")
    info_parser.add_argument("audio_path", help="Path to WAV file")

    args = parser.parse_args()

    if args.command == "transcribe":
        return handle_transcribe(args)
    elif args.command == "info":
        return handle_info(args)
    else:
        parser.print_help()
        return 0


def handle_transcribe(args):
    """Handle transcribe command."""
    audio_path = args.audio_path

    try:
        logger.info(f"Transcribing: {audio_path}")
        transcriber = Transcriber()
        result = transcriber.transcribe(audio_path, preferred_provider=args.provider)

        print("\n--- Transcription Result ---\n")
        print(result)
        print("\n")

        if args.output:
            output_path = Path(args.output)
            output_path.write_text(result)
            logger.info(f"Saved to: {args.output}")

        return 0

    except AudioError as e:
        logger.error(f"Audio error: {e}")
        return 1
    except TranscriptionError as e:
        logger.error(f"Transcription error: {e}")
        return 1
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return 1


def handle_info(args):
    """Handle info command."""
    from wav_transcriber.core.audio import AudioValidator

    audio_path = args.audio_path

    try:
        logger.info(f"Analyzing: {audio_path}")
        metadata = AudioValidator.validate(audio_path)

        print("\n--- Audio File Info ---\n")
        print(f"File: {audio_path}")
        print(f"Sample Rate: {metadata['sample_rate']} Hz")
        print(f"Channels: {metadata['channels']}")
        print(f"Duration: {metadata['duration_seconds']:.2f} seconds")
        print(f"File Size: {metadata['file_size_mb']:.2f} MB")
        print("\n")

        return 0

    except AudioError as e:
        logger.error(f"Audio error: {e}")
        return 1
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
