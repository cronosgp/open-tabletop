"""Prepare or verify the pinned optional starter snapshot without overwriting packs."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import tempfile

from import_starter_factions import import_factions

ROOT = Path(__file__).resolve().parents[1]


def verify(directory, lock):
    for faction, digest in lock["units_sha256"].items():
        manifest = json.loads((directory / faction / "manifest.json").read_text(encoding="utf-8"))
        actual = hashlib.sha256((directory / faction / "units.json").read_bytes()).hexdigest()
        if manifest["source"]["revision"] != lock["revision"] or manifest["units_sha256"] != digest or actual != digest:
            raise ValueError(f"{faction}: snapshot differs from data/starter.lock.json; existing files preserved")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Verify existing files offline; never download")
    args = parser.parse_args()
    lock = json.loads((ROOT / "data/starter.lock.json").read_text(encoding="utf-8"))
    destination = ROOT / "data/imported/starter-11e-v1"
    try:
        if destination.exists() or args.check:
            verify(destination, lock)
        else:
            destination.parent.mkdir(parents=True, exist_ok=True)
            with tempfile.TemporaryDirectory(prefix="starter-", dir=destination.parent) as temporary:
                candidate = Path(temporary) / "snapshot"
                import_factions(candidate, lock["revision"])
                verify(candidate, lock)
                candidate.rename(destination)
        print("Starter snapshot matches pinned revision and content hashes.")
        return 0
    except (OSError, ValueError, KeyError) as error:
        print(f"Starter preparation failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
