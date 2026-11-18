"""Prune local verification run directories under .tools/verification.

Each ``tools/verify.py`` run and each ``tools/build_demo.py`` export writes an
isolated copy of the project plus logs and ``results.json`` into its own
timestamped directory. Nothing prunes those directories, so the folder grows by
roughly 8 MB per run and eventually reaches tens of GB.

This helper keeps every run cited by project documentation, plus recent runs,
and deletes the rest. It is a dry run unless ``--apply`` is passed. Directories
whose names are not a recognised run id (``<timestamp>`` or ``build-<timestamp>``)
are never deleted.

Pruning removes only local reconstruction history. A cited run is evidence for a
recorded claim, so citations are re-read from ``docs/`` on every invocation
rather than cached.
"""

from __future__ import annotations

import argparse
import re
import shutil
from datetime import datetime, timedelta, timezone
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_VERIFICATION = PROJECT_ROOT / ".tools" / "verification"
DEFAULT_DOCS = PROJECT_ROOT / "docs"

RUN_ID = re.compile(r"^(?:build-)?\d{8}T\d+Z$")
CITATION = re.compile(r"verification[/\\]((?:build-)?\d{8}T\d+Z)")
DOC_SUFFIXES = {".md", ".json", ".txt"}


def collect_citations(docs_root: Path) -> set[str]:
    """Return every verification run id referenced by project documentation."""
    cited: set[str] = set()
    for path in docs_root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in DOC_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        cited.update(CITATION.findall(text))
    return cited


def directory_size(path: Path) -> int:
    total = 0
    for child in path.rglob("*"):
        try:
            if child.is_file():
                total += child.stat().st_size
        except OSError:
            continue
    return total


def plan(verification_root: Path, cited: set[str], keep_recent: int, keep_days: int) -> tuple[dict[str, str], list[Path], list[Path]]:
    """Split existing directories into keep reasons, delete targets and unknown names."""
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(days=keep_days)
    runs = sorted(
        (child for child in verification_root.iterdir() if child.is_dir()),
        key=lambda item: item.name,
    )
    newest = set(child.name for child in runs[-keep_recent:]) if keep_recent > 0 else set()

    keep: dict[str, str] = {}
    delete: list[Path] = []
    unknown: list[Path] = []
    for child in runs:
        if not RUN_ID.match(child.name):
            unknown.append(child)
        elif child.name in cited:
            keep[child.name] = "cited by documentation"
        elif child.name in newest:
            keep[child.name] = "one of the newest runs"
        elif datetime.fromtimestamp(child.stat().st_mtime, timezone.utc) >= cutoff:
            keep[child.name] = "inside the recent window"
        else:
            delete.append(child)
    return keep, delete, unknown


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--verification-dir", type=Path, default=DEFAULT_VERIFICATION)
    parser.add_argument("--docs-dir", type=Path, default=DEFAULT_DOCS)
    parser.add_argument("--keep-recent", type=int, default=20, help="Always keep this many newest runs (default 20)")
    parser.add_argument("--keep-days", type=int, default=7, help="Keep uncited runs younger than this (default 7)")
    parser.add_argument("--apply", action="store_true", help="Delete the selected runs; without it this is a dry run")
    parser.add_argument("--verbose", action="store_true", help="List every directory that would be deleted")
    args = parser.parse_args()

    if args.keep_recent < 0 or args.keep_days < 0:
        parser.error("--keep-recent and --keep-days must not be negative")
    if not args.verification_dir.is_dir():
        parser.error(f"verification directory not found: {args.verification_dir}")

    cited = collect_citations(args.docs_dir)
    keep, delete, unknown = plan(args.verification_dir, cited, args.keep_recent, args.keep_days)

    reasons: dict[str, int] = {}
    for reason in keep.values():
        reasons[reason] = reasons.get(reason, 0) + 1

    print(f"cited run ids in documentation: {len(cited)}")
    print(f"present directories           : {len(keep) + len(delete) + len(unknown)}")
    for reason in sorted(reasons):
        print(f"  keep ({reason}): {reasons[reason]}")
    if unknown:
        print(f"  keep (unrecognised name): {len(unknown)}")
    print(f"delete candidates             : {len(delete)}")

    if not delete:
        print("Nothing to prune.")
        return 0

    total = 0
    for path in delete:
        total += directory_size(path)
        if args.verbose:
            print(f"  delete {path.name}")
    print(f"reclaimable                   : {total / (1024 ** 3):.2f} GB")

    if not args.apply:
        print("Dry run: pass --apply to delete the candidates above.")
        return 0

    removed = 0
    for path in delete:
        try:
            shutil.rmtree(path)
            removed += 1
        except OSError as error:
            print(f"  failed to remove {path.name}: {error}")
    print(f"removed                       : {removed}")
    return 0 if removed == len(delete) else 1


if __name__ == "__main__":
    raise SystemExit(main())
