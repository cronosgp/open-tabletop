#!/usr/bin/env python3
"""Explicitly cache the three 11e Event Companion preview diagrams locally.

This tool is opt-in. The game never downloads third-party images automatically.
The destination lives under the ignored .tools/ directory and is not packaged.
"""
from __future__ import annotations

import argparse
from pathlib import Path
from urllib.request import Request, urlopen


BASE_URL = "https://wahapedia.ru/wh40k11ed/img/maps/layouts/"
FILES = (
    "43_Take_and_Hold_vs_Take_and_Hold_Layout_A.png",
    "44_Take_and_Hold_vs_Take_and_Hold_Layout_B.png",
    "45_Take_and_Hold_vs_Take_and_Hold_Layout_C.png",
)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(".tools/wahapedia/11e/event-layouts/take-and-hold-mirror"),
        help="local ignored cache directory (default: %(default)s)",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    for filename in FILES:
        target = args.output / filename
        request = Request(BASE_URL + filename, headers={"User-Agent": "OpenTabletop local preview cache"})
        with urlopen(request, timeout=30) as response:
            if response.status != 200:
                raise RuntimeError(f"Could not fetch {filename}: HTTP {response.status}")
            data = response.read()
        if not data.startswith(b"\x89PNG\r\n\x1a\n"):
            raise RuntimeError(f"The response for {filename} was not a PNG image")
        target.write_bytes(data)
        print(f"Cached {filename} ({len(data)} bytes) -> {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
