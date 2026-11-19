#!/usr/bin/env python3
"""Build a provenance-preserving index of visual asset fingerprints across TTS sources.

This exact-fingerprint comparison does not certify that two differently hashed assets
are different sculpts, nor does a shared fingerprint prove datasheet or loadout identity.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from collections import defaultdict
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parents[1]
TABLE_ROOT = PROJECT_ROOT / ".tools" / "forceorg-model-table"
DEFAULT_AUTOSAVE_VARIANTS = TABLE_ROOT / "TS_AutoSave_3_latest_visual_candidates_variants.csv"
DEFAULT_WORKSHOP_VARIANTS = TABLE_ROOT / "ForceOrg_catalog_visual_candidates_variants.csv"
DEFAULT_AUTOSAVE_SNAPSHOT = TABLE_ROOT / "TS_AutoSave_3_latest_snapshot.json"
DEFAULT_WORKSHOP_SAVE = PROJECT_ROOT / "ForceOrg.json"
DEFAULT_OUTPUT = TABLE_ROOT / "forceorg_source_fingerprint_index.csv"
DEFAULT_SUMMARY = TABLE_ROOT / "forceorg_source_fingerprint_index.json"

EXPECTED_AUTOSAVE_SHA256 = "0ee5ce7e5742f1c9705b57e4131b55b9e65785f2073b746fb136fd1e8468a0cf"
EXPECTED_WORKSHOP_SHA256 = "ed0b66dc0518f03ea746a485d2739deb57ea2094117d552c02925983c3bcba44"
SOURCE_NAMES = ("TTS AutoSave", "ForceOrg Workshop catalog")

OUTPUT_FIELDS = [
    "asset_fingerprint",
    "fingerprint_source_match",
    "match_basis",
    "autosave_variant_count",
    "autosave_occurrence_count",
    "autosave_variant_keys",
    "autosave_labels",
    "autosave_model_families",
    "autosave_weapon_hints",
    "autosave_group_hints",
    "workshop_variant_count",
    "workshop_occurrence_count",
    "workshop_variant_keys",
    "workshop_labels",
    "workshop_model_families",
    "workshop_weapon_hints",
    "workshop_group_hints",
    "label_relation",
    "autosave_sha256",
    "workshop_sha256",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def read_variants(path: Path, expected_hash: str, source_label: str) -> dict[str, list[dict[str, str]]]:
    grouped: dict[str, list[dict[str, str]]] = defaultdict(list)
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        required = {"save_sha256", "asset_fingerprint", "variant_key", "representative_label"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"{path}: missing columns {sorted(missing)}")
        row_count = 0
        for row in reader:
            row_count += 1
            if row.get("save_sha256", "").strip() != expected_hash:
                raise ValueError(f"{path}: unexpected source hash at row {row_count + 1}")
            fingerprint = row.get("asset_fingerprint", "").strip()
            if not fingerprint:
                raise ValueError(f"{path}: blank asset fingerprint at row {row_count + 1}")
            grouped[fingerprint].append(row)
    if not grouped:
        raise ValueError(f"{path}: no visual variants found")
    print(f"Read {sum(map(len, grouped.values()))} {source_label} variants across {len(grouped)} fingerprints")
    return grouped


def unique_values(rows: list[dict[str, str]], key: str) -> list[str]:
    return sorted({row.get(key, "").strip() for row in rows if row.get(key, "").strip()}, key=str.casefold)


def encode_values(rows: list[dict[str, str]], key: str) -> str:
    return json.dumps(unique_values(rows, key), ensure_ascii=False, separators=(",", ":"))


def occurrence_total(rows: list[dict[str, str]]) -> int:
    return sum(int(row.get("source_occurrence_count", "0") or 0) for row in rows)


def build_index(
    autosave: dict[str, list[dict[str, str]]],
    workshop: dict[str, list[dict[str, str]]],
    autosave_hash: str,
    workshop_hash: str,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    shared_fingerprints = set(autosave) & set(workshop)
    for fingerprint in sorted(set(autosave) | set(workshop)):
        auto_rows = autosave.get(fingerprint, [])
        workshop_rows = workshop.get(fingerprint, [])
        if auto_rows and workshop_rows:
            match = "both_source_saves"
            auto_labels = {value.casefold() for value in unique_values(auto_rows, "representative_label")}
            workshop_labels = {value.casefold() for value in unique_values(workshop_rows, "representative_label")}
            label_relation = "same_label_set" if auto_labels == workshop_labels else "different_label_sets"
        elif auto_rows:
            match = "autosave_only"
            label_relation = "only_autosave"
        else:
            match = "workshop_only"
            label_relation = "only_workshop"
        rows.append({
            "asset_fingerprint": fingerprint,
            "fingerprint_source_match": match,
            "match_basis": "Exact asset_fingerprint: saved asset references and component-local transforms; TTS table placement excluded.",
            "autosave_variant_count": len(auto_rows),
            "autosave_occurrence_count": occurrence_total(auto_rows),
            "autosave_variant_keys": encode_values(auto_rows, "variant_key"),
            "autosave_labels": encode_values(auto_rows, "representative_label"),
            "autosave_model_families": encode_values(auto_rows, "model_family_hint"),
            "autosave_weapon_hints": encode_values(auto_rows, "visual_weapon_hints"),
            "autosave_group_hints": encode_values(auto_rows, "source_group_hints"),
            "workshop_variant_count": len(workshop_rows),
            "workshop_occurrence_count": occurrence_total(workshop_rows),
            "workshop_variant_keys": encode_values(workshop_rows, "variant_key"),
            "workshop_labels": encode_values(workshop_rows, "representative_label"),
            "workshop_model_families": encode_values(workshop_rows, "model_family_hint"),
            "workshop_weapon_hints": encode_values(workshop_rows, "visual_weapon_hints"),
            "workshop_group_hints": encode_values(workshop_rows, "source_group_hints"),
            "label_relation": label_relation,
            "autosave_sha256": autosave_hash,
            "workshop_sha256": workshop_hash,
        })

    summary = {
        "source_hashes": {
            "tts_autosave": autosave_hash,
            "forceorg_workshop_catalog": workshop_hash,
        },
        "source_variant_counts": {
            "tts_autosave": sum(map(len, autosave.values())),
            "forceorg_workshop_catalog": sum(map(len, workshop.values())),
        },
        "unique_fingerprint_counts": {
            "tts_autosave": len(autosave),
            "forceorg_workshop_catalog": len(workshop),
            "shared_exact_fingerprints": len(shared_fingerprints),
            "union": len(rows),
        },
        "fingerprints_with_different_label_sets": sum(row["label_relation"] == "different_label_sets" for row in rows),
        "match_semantics": "Exact fingerprint comparison only; it does not certify datasheet, unit role, weapon/loadout or sculpt equivalence for nonmatching fingerprints.",
    }
    return rows, summary


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--autosave-variants", type=Path, default=DEFAULT_AUTOSAVE_VARIANTS)
    parser.add_argument("--workshop-variants", type=Path, default=DEFAULT_WORKSHOP_VARIANTS)
    parser.add_argument("--autosave-snapshot", type=Path, default=DEFAULT_AUTOSAVE_SNAPSHOT)
    parser.add_argument("--workshop-save", type=Path, default=DEFAULT_WORKSHOP_SAVE)
    parser.add_argument("--expected-autosave-sha256", default=EXPECTED_AUTOSAVE_SHA256)
    parser.add_argument("--expected-workshop-sha256", default=EXPECTED_WORKSHOP_SHA256)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--summary", type=Path, default=DEFAULT_SUMMARY)
    args = parser.parse_args()

    for output in (args.output.resolve(), args.summary.resolve()):
        try:
            output.relative_to((PROJECT_ROOT / ".tools").resolve())
        except ValueError as error:
            raise SystemExit("Refusing to write derived third-party data outside ignored .tools/.") from error

    actual_auto_hash = sha256(args.autosave_snapshot)
    actual_workshop_hash = sha256(args.workshop_save)
    if actual_auto_hash != args.expected_autosave_sha256:
        raise SystemExit(f"AutoSave snapshot hash changed: expected {args.expected_autosave_sha256}, got {actual_auto_hash}")
    if actual_workshop_hash != args.expected_workshop_sha256:
        raise SystemExit(f"Workshop source hash changed: expected {args.expected_workshop_sha256}, got {actual_workshop_hash}")

    autosave = read_variants(args.autosave_variants, args.expected_autosave_sha256, SOURCE_NAMES[0])
    workshop = read_variants(args.workshop_variants, args.expected_workshop_sha256, SOURCE_NAMES[1])
    rows, summary = build_index(autosave, workshop, args.expected_autosave_sha256, args.expected_workshop_sha256)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.summary.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=OUTPUT_FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    args.summary.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    print(f"Wrote {len(rows)} source fingerprint rows to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
