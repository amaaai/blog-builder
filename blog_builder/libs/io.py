"""IO helpers."""
from pathlib import Path
from typing import Dict


def read_files(location: Path, file_type: str = "txt") -> Dict[str, str]:
    """ "Read files and put into dict."""
    return {file.stem: file.read_text() for file in location.glob(f"**/*.{file_type}")}
