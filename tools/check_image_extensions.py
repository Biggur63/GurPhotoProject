from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ASSETS_DIR = ROOT / "assets" / "images"
EXT_MAP = {
    ".jpg": {"jpeg", "mjpeg"},
    ".jpeg": {"jpeg", "mjpeg"},
    ".png": {"png"},
    ".webp": {"webp"},
}


def probe_codec(path: Path) -> str | None:
    cmd = [
        "ffprobe",
        "-v",
        "error",
        "-show_entries",
        "stream=codec_name",
        "-of",
        "json",
        str(path),
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    streams = data.get("streams") or []
    return streams[0].get("codec_name") if streams else None


def main() -> int:
    problems: list[tuple[Path, str, str | None]] = []

    for path in ASSETS_DIR.rglob("*"):
        if not path.is_file():
            continue
        ext = path.suffix.lower()
        if ext not in EXT_MAP:
            continue
        try:
            codec = probe_codec(path)
        except Exception as exc:  # noqa: BLE001
            problems.append((path, ext, f"probe-error: {exc}"))
            continue
        if codec not in EXT_MAP[ext]:
            problems.append((path, ext, codec))

    if not problems:
        print("OK: no mismatched image extensions found")
        return 0

    print(f"Found {len(problems)} problematic files:")
    for path, ext, codec in problems:
        print(f"- {path.relative_to(ROOT)} | ext={ext} | codec={codec}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
