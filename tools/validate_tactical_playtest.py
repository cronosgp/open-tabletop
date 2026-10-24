"""Validate the structure and declared outcome of a human tactical playtest record.

This tool checks evidence hygiene only. A passing record means that the human
session fields were filled with accepted outcome labels; it does not certify
rules accuracy, usability, competitive balance or network support.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys


EXPECTED_SCENARIO = "marine-tactical-training-v1"
OUTCOMES = {"pass", "partial", "blocked", "not observed"}
PLACEHOLDER_NOTES = {"observed", "n/a", "na", "none", "ok", "done", "pass", "passed", "tbd", "todo"}
REQUIRED_GATES = (
    "Both forces, model counts and points understood",
    "Warlord and Leader attachments completed",
    "Deployment and next-unit ownership understood",
    "At least one legal ability or stratagem discovered",
    "Experiment progress checklist understood",
    "Plasma choice and Hazardous consequence understood",
    "Bladeguard stance understood when offered",
    "Pending decision ownership and phase lock understood",
    "Save/resume preserves the intended decision",
    "Five-round result reached without technical intervention",
    "Opening guide and required controls readable without clipping",
    "Optional roll kept without CP and paid reroll cost understood",
    "Defender chose a legal recipient and understood restrictions",
    "Invalid movement explained locally and corrected",
    "Attack dice damage and destroyed models explained",
    "Combat pacing symbols and reduced-motion controls understood",
)


def _metadata(text: str, key: str) -> str:
    match = re.search(rf"(?m)^{re.escape(key)}:\s*(.*?)\s*$", text)
    return match.group(1).strip() if match else ""


def _gate_rows(text: str) -> dict[str, tuple[str, str]]:
    rows: dict[str, tuple[str, str]] = {}
    for gate in REQUIRED_GATES:
        pattern = rf"(?m)^\|\s*{re.escape(gate)}\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*$"
        match = re.search(pattern, text)
        rows[gate] = (match.group(1).strip().lower(), match.group(2).strip()) if match else ("", "")
    return rows


def validate(path: Path) -> tuple[int, list[str]]:
    if not path.is_file():
        return 2, [f"Record not found: {path}"]
    text = path.read_text(encoding="utf-8-sig")
    errors: list[str] = []
    warnings: list[str] = []
    if _metadata(text, "Scenario") != EXPECTED_SCENARIO:
        errors.append(f"Scenario must be {EXPECTED_SCENARIO}.")
    if _metadata(text, "Mode") != "shared computer, two participants alternating control":
        errors.append("Mode must identify the shared-computer two-participant session.")
    if not _metadata(text, "Date"):
        errors.append("Date is missing.")
    if not _metadata(text, "Code revision"):
        errors.append("Code revision is missing.")
    rows = _gate_rows(text)
    outcomes = {gate: row[0] for gate, row in rows.items()}
    for gate, (outcome, notes) in rows.items():
        if not outcome:
            errors.append(f"Outcome is missing: {gate}.")
        elif outcome not in OUTCOMES:
            errors.append(f"Unsupported outcome '{outcome}' for: {gate}.")
        elif not notes:
            errors.append(f"Notes are missing: {gate}.")
        elif notes.casefold() in PLACEHOLDER_NOTES:
            errors.append(f"Notes must describe the observed evidence: {gate}.")
        elif outcome == "blocked":
            warnings.append(f"Blocked gate: {gate}.")
        elif outcome == "partial":
            warnings.append(f"Partial gate: {gate}.")
        elif outcome == "not observed":
            warnings.append(f"Opportunity or gate not observed: {gate}.")
    if errors:
        return 2, errors + warnings
    if any(outcome != "pass" for outcome in outcomes.values()):
        return 3, warnings
    return 0, ["All human playtest gates are declared pass. This is evidence for the recorded session only."]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("record", type=Path, help="Path to tactical-training-session.md")
    args = parser.parse_args()
    code, messages = validate(args.record)
    for message in messages:
        print(message)
    return code


if __name__ == "__main__":
    sys.exit(main())
