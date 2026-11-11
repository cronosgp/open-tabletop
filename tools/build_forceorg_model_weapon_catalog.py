#!/usr/bin/env python3
"""Build a provenance-preserving cross-source ForceOrg model/weapon catalog.

The catalog is an inventory and review aid. Lexical/datasheet candidates are not
visual certifications, equipment legality decisions, or interchangeable sculpt links.
All generated third-party-derived outputs stay under the ignored .tools directory.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from collections import defaultdict
from pathlib import Path
from typing import Any

from build_forceorg_compact_model_catalog import build as compact_candidates


PROJECT_ROOT = Path(__file__).resolve().parents[1]
TABLE_ROOT = PROJECT_ROOT / ".tools" / "forceorg-model-table"
DEFAULT_AUTOSAVE_SNAPSHOT = TABLE_ROOT / "TS_AutoSave_3_latest_snapshot.json"
DEFAULT_WORKSHOP_SAVE = PROJECT_ROOT / "ForceOrg.json"
DEFAULT_AUTOSAVE_VARIANTS = TABLE_ROOT / "variant_best_matches.csv"
DEFAULT_WORKSHOP_VARIANTS = TABLE_ROOT / "forceorg_source" / "forceorg_variant_best_matches.csv"
DEFAULT_AUTOSAVE_WEAPON_QUEUE = TABLE_ROOT / "forceorg_visual_weapon_review_queue.csv"
DEFAULT_WORKSHOP_WEAPON_QUEUE = TABLE_ROOT / "forceorg_source" / "forceorg_visual_weapon_review_queue.csv"
DEFAULT_FINGERPRINT_INDEX = TABLE_ROOT / "forceorg_source_fingerprint_index.csv"
DEFAULT_CATALOG = TABLE_ROOT / "forceorg_model_weapon_catalog.csv"
DEFAULT_REVIEW_LEDGER_INPUT = TABLE_ROOT / "user_visual_review_ledger.csv"
DEFAULT_REVIEW_LEDGER = TABLE_ROOT / "user_visual_review_ledger.csv"
DEFAULT_WEAPON_REVIEW_QUEUE = TABLE_ROOT / "forceorg_unique_weapon_review_queue.csv"
DEFAULT_SUMMARY = TABLE_ROOT / "forceorg_model_weapon_catalog.json"

EXPECTED_AUTOSAVE_SHA256 = "0ee5ce7e5742f1c9705b57e4131b55b9e65785f2073b746fb136fd1e8468a0cf"
EXPECTED_WORKSHOP_SHA256 = "ed0b66dc0518f03ea746a485d2739deb57ea2094117d552c02925983c3bcba44"
EXPECTED_RULES_SNAPSHOT = "20261021T130623Z"
EXPECTED_RULES_MANIFEST = "169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf"

CATALOG_FIELDS = [
    "catalog_source",
    "source_save",
    "source_sha256",
    "variant_key",
    "asset_fingerprint",
    "exact_fingerprint_source_match",
    "counterpart_variant_keys",
    "counterpart_labels",
    "cross_source_label_relation",
    "source_group_hints",
    "group_faction_scope",
    "model_family_hint",
    "representative_label",
    "visual_weapon_hints",
    "recognized_legacy_weapon_label_terms",
    "asset_kind",
    "component_count",
    "source_occurrence_count",
    "source_occurrences",
    "existing_mapping_status",
    "existing_e11_datasheet_id",
    "existing_e11_definition_id",
    "existing_e11_model_role",
    "existing_e11_equipment_signature",
    "candidate_count",
    "candidate_status",
    "top_candidate_tie_count",
    "top_candidate_tie_datasheets",
    "candidate_review_order",
    "candidate_lexical_score",
    "candidate_datasheet_id",
    "candidate_datasheet_name",
    "candidate_datasheet_role",
    "candidate_model_roles",
    "candidate_base_size_values",
    "candidate_faction_id",
    "candidate_faction_name",
    "candidate_matches_group_faction_scope",
    "candidate_source_book",
    "candidate_source_edition",
    "candidate_source_version",
    "visual_weapon_terms_present_in_candidate_source_text",
    "visual_weapon_hints_found_in_candidate",
    "visual_weapon_hints_not_found_in_candidate",
    "weapon_review_status",
    "weapon_option_match_status",
    "all_label_hints_in_current_options",
    "all_label_hints_in_current_profile_text",
    "review_authority",
    "rules_snapshot_id",
    "rules_manifest_sha256",
]

REVIEW_FIELDS = [
    "review_date",
    "reviewer",
    "unit_role",
    "weapon_signature",
    "tts_label_reviewed",
    "review_level",
    "reported_result",
    "review_scope_note",
]

WEAPON_REVIEW_FIELDS = [
    "asset_fingerprint",
    "source_match_status",
    "catalog_sources",
    "representative_labels",
    "source_group_hints",
    "candidate_datasheet_ids",
    "candidate_datasheet_names",
    "candidate_model_roles",
    "visual_weapon_hints",
    "weapon_option_match_statuses",
    "variant_keys_by_source",
    "source_occurrences_by_variant",
    "review_status",
    "rules_snapshot_id",
    "rules_manifest_sha256",
]

def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def require_source_hash(rows: list[dict[str, str]], field: str, expected: str, label: str) -> None:
    found = {row.get(field, "").strip() for row in rows}
    if found != {expected}:
        raise ValueError(f"{label} has unexpected {field} values: {sorted(found)}")


def require_variant_source_hash(rows: list[dict[str, str]], expected: str, label: str) -> None:
    field = "source_save_sha256" if rows and "source_save_sha256" in rows[0] else "save_sha256"
    require_source_hash(rows, field, expected, label)


def require_rules_provenance(rows: list[dict[str, str]], label: str) -> None:
    snapshots = {row.get("rules_snapshot_id", "").strip() for row in rows if row.get("rules_snapshot_id", "").strip()}
    manifests = {row.get("rules_manifest_sha256", "").strip() for row in rows if row.get("rules_manifest_sha256", "").strip()}
    if snapshots - {EXPECTED_RULES_SNAPSHOT}:
        raise ValueError(f"{label} has unexpected rules snapshots: {sorted(snapshots)}")
    if manifests - {EXPECTED_RULES_MANIFEST}:
        raise ValueError(f"{label} has unexpected rules manifests: {sorted(manifests)}")
    for row in rows:
        if not row.get("candidate_datasheet_id", "").strip():
            continue
        if row.get("rules_snapshot_id", "").strip() != EXPECTED_RULES_SNAPSHOT or row.get("rules_manifest_sha256", "").strip() != EXPECTED_RULES_MANIFEST:
            raise ValueError(f"{label} has a datasheet candidate without the expected verified rules provenance")


def enrich_variants(variants: list[dict[str, str]], relations_path: Path | None, label: str) -> list[dict[str, str]]:
    """Join raw inventories to their own crosswalk, never another save's names.

    Raw inventories legitimately lack candidate columns. Previously accepting them
    silently produced a catalog with every datasheet link blank.
    """
    if not relations_path:
        if not variants or "candidate_count" not in variants[0]:
            raise ValueError(f"{label}: raw variants require an explicit --*-relations CSV")
        return variants
    relations = read_csv(relations_path)
    require_rules_provenance(relations, str(relations_path))
    compact, _ = compact_candidates(variants, relations)
    best = {row["variant_key"]: row for row in compact}
    # Preserve source occurrences, full source identity and any additional columns.
    return [{**row, **best[row["variant_key"]]} for row in variants]


def require_unique(rows: list[dict[str, str]], fields: tuple[str, ...], label: str) -> None:
    seen: set[tuple[str, ...]] = set()
    for row in rows:
        key = tuple(row.get(field, "").strip() for field in fields)
        if not all(key) or key in seen:
            raise ValueError(f"{label} has a blank or duplicate key: {key}")
        seen.add(key)


def load_crosswalk(path: Path, autosave_hash: str, workshop_hash: str) -> dict[str, dict[str, str]]:
    rows = read_csv(path)
    expected_fields = {
        "asset_fingerprint", "fingerprint_source_match", "autosave_variant_keys",
        "workshop_variant_keys", "autosave_labels", "workshop_labels", "label_relation",
        "autosave_sha256", "workshop_sha256",
    }
    if not rows or not expected_fields.issubset(rows[0]):
        raise ValueError(f"{path}: fingerprint index is missing required columns")
    require_unique(rows, ("asset_fingerprint",), "fingerprint index")
    for row in rows:
        if row["autosave_sha256"] != autosave_hash or row["workshop_sha256"] != workshop_hash:
            raise ValueError(f"{path}: fingerprint index source hashes do not match the approved captures")
    return {row["asset_fingerprint"]: row for row in rows}


def load_weapon_reviews(path: Path, expected_hash: str) -> dict[str, dict[str, str]]:
    rows = read_csv(path)
    if not rows:
        raise ValueError(f"{path}: empty weapon review queue")
    require_source_hash(rows, "forceorg_save_sha256", expected_hash, str(path))
    require_rules_provenance(rows, str(path))
    require_unique(rows, ("variant_key",), f"{path} weapon review queue")
    return {row["variant_key"]: row for row in rows}


def compact_json_list(value: str) -> str:
    """Validate existing JSON list cells without changing their evidence."""
    if not value:
        return "[]"
    parsed = json.loads(value)
    if not isinstance(parsed, list):
        raise ValueError("Expected a JSON list in source table")
    return json.dumps(parsed, ensure_ascii=False, separators=(",", ":"))


def normalized_row(
    source: str,
    row: dict[str, str],
    review: dict[str, str] | None,
    fingerprints: dict[str, dict[str, str]],
) -> dict[str, Any]:
    source_hash = row.get("save_sha256", row.get("source_save_sha256", "")).strip()
    variant_key = row.get("variant_key", "").strip()
    asset_fingerprint = row.get("asset_fingerprint", "").strip()
    if not source_hash or not variant_key or not asset_fingerprint:
        raise ValueError(f"{source}: variant row is missing its source hash, key, or asset fingerprint")
    cross = fingerprints.get(asset_fingerprint)
    if cross is None:
        raise ValueError(f"{source}: missing exact fingerprint index row for {variant_key}")
    if source == "TTS AutoSave":
        counterpart_keys = cross["workshop_variant_keys"]
        counterpart_labels = cross["workshop_labels"]
    else:
        counterpart_keys = cross["autosave_variant_keys"]
        counterpart_labels = cross["autosave_labels"]
    out: dict[str, Any] = {field: row.get(field, "") for field in CATALOG_FIELDS}
    out.update({
        "catalog_source": source,
        "source_save": row.get("source_save", ""),
        "source_sha256": source_hash,
        "asset_fingerprint": asset_fingerprint,
        "exact_fingerprint_source_match": cross["fingerprint_source_match"],
        "counterpart_variant_keys": compact_json_list(counterpart_keys),
        "counterpart_labels": compact_json_list(counterpart_labels),
        "cross_source_label_relation": cross["label_relation"],
        "weapon_review_status": review.get("review_status", "not_weapon_hinted") if review else "not_weapon_hinted",
        "weapon_option_match_status": review.get("weapon_option_match_status", "") if review else "",
        "all_label_hints_in_current_options": review.get("all_label_hints_in_current_options", "") if review else "",
        "all_label_hints_in_current_profile_text": review.get("all_label_hints_in_current_profile_text", "") if review else "",
    })
    if out["source_occurrences"]:
        compact_json_list(str(out["source_occurrences"]))
    return out


def write_csv(path: Path, fields: list[str], rows: list[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="raise")
        writer.writeheader()
        writer.writerows(rows)


def review_rows(path: Path) -> list[dict[str, str]]:
    rows = read_csv(path)
    missing = set(REVIEW_FIELDS) - set(rows[0] if rows else [])
    if not rows or missing:
        raise ValueError(f"{path}: review ledger is empty or missing columns {sorted(missing)}")
    require_unique(rows, ("unit_role", "weapon_signature", "tts_label_reviewed"), str(path))
    return rows


def weapon_review_rows(rows: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Collapse pending weapon hints by exact asset fingerprint, retaining every source identity."""
    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for row in rows:
        if row.get("weapon_review_status") == "pending_visual_review":
            grouped[str(row["asset_fingerprint"])].append(row)

    result: list[dict[str, Any]] = []
    for fingerprint, variants in grouped.items():
        variants.sort(key=lambda row: (str(row["catalog_source"]), str(row["variant_key"])))
        collect = lambda field: sorted({str(row.get(field, "")).strip() for row in variants if str(row.get(field, "")).strip()})
        variants_by_source: dict[str, list[str]] = defaultdict(list)
        occurrences: list[dict[str, Any]] = []
        for row in variants:
            variants_by_source[str(row["catalog_source"])].append(str(row["variant_key"]))
            occurrences.append({
                "catalog_source": row["catalog_source"],
                "variant_key": row["variant_key"],
                "representative_label": row["representative_label"],
                "source_occurrences": json.loads(str(row.get("source_occurrences", "[]") or "[]")),
            })
        result.append({
            "asset_fingerprint": fingerprint,
            "source_match_status": "both_source_saves" if len({str(row["catalog_source"]) for row in variants}) > 1 else str(variants[0]["exact_fingerprint_source_match"]),
            "catalog_sources": json.dumps(collect("catalog_source"), ensure_ascii=False, separators=(",", ":")),
            "representative_labels": json.dumps(collect("representative_label"), ensure_ascii=False, separators=(",", ":")),
            "source_group_hints": json.dumps(collect("source_group_hints"), ensure_ascii=False, separators=(",", ":")),
            "candidate_datasheet_ids": json.dumps(collect("candidate_datasheet_id"), ensure_ascii=False, separators=(",", ":")),
            "candidate_datasheet_names": json.dumps(collect("candidate_datasheet_name"), ensure_ascii=False, separators=(",", ":")),
            "candidate_model_roles": json.dumps(collect("candidate_model_roles"), ensure_ascii=False, separators=(",", ":")),
            "visual_weapon_hints": json.dumps(collect("visual_weapon_hints"), ensure_ascii=False, separators=(",", ":")),
            "weapon_option_match_statuses": json.dumps(collect("weapon_option_match_status"), ensure_ascii=False, separators=(",", ":")),
            "variant_keys_by_source": json.dumps({source: sorted(keys) for source, keys in sorted(variants_by_source.items())}, ensure_ascii=False, separators=(",", ":")),
            "source_occurrences_by_variant": json.dumps(occurrences, ensure_ascii=False, separators=(",", ":")),
            "review_status": "pending_visual_review",
            "rules_snapshot_id": EXPECTED_RULES_SNAPSHOT,
            "rules_manifest_sha256": EXPECTED_RULES_MANIFEST,
        })
    result.sort(key=lambda row: (str(row["candidate_datasheet_names"]).casefold(), str(row["visual_weapon_hints"]).casefold(), str(row["representative_labels"]).casefold(), str(row["asset_fingerprint"])))
    return result


def ensure_outputs_are_local(paths: list[Path]) -> None:
    local_root = (PROJECT_ROOT / ".tools").resolve()
    for path in paths:
        try:
            path.resolve().relative_to(local_root)
        except ValueError as error:
            raise ValueError(f"Refusing to write derived third-party data outside {local_root}") from error


def build(args: argparse.Namespace) -> dict[str, Any]:
    for raw, expected, label in [
        (args.autosave_snapshot, args.expected_autosave_sha256, "TTS AutoSave snapshot"),
        (args.workshop_save, args.expected_workshop_sha256, "ForceOrg Workshop save"),
    ]:
        actual = file_sha256(raw)
        if actual != expected:
            raise ValueError(f"{label} hash changed: expected {expected}, got {actual}")

    autosave = enrich_variants(read_csv(args.autosave_variants), args.autosave_relations, "AutoSave")
    workshop = enrich_variants(read_csv(args.workshop_variants), args.workshop_relations, "Workshop")
    require_variant_source_hash(autosave, args.expected_autosave_sha256, "TTS AutoSave variants")
    require_variant_source_hash(workshop, args.expected_workshop_sha256, "ForceOrg Workshop variants")
    for label, source_rows in [("TTS AutoSave variants", autosave), ("ForceOrg Workshop variants", workshop)]:
        require_rules_provenance(source_rows, label)
    autosave_hash_field = "source_save_sha256" if autosave and "source_save_sha256" in autosave[0] else "save_sha256"
    workshop_hash_field = "source_save_sha256" if workshop and "source_save_sha256" in workshop[0] else "save_sha256"
    require_unique(autosave, (autosave_hash_field, "variant_key"), "TTS AutoSave variants")
    require_unique(workshop, (workshop_hash_field, "variant_key"), "ForceOrg Workshop variants")

    fingerprints = load_crosswalk(args.fingerprint_index, args.expected_autosave_sha256, args.expected_workshop_sha256)
    autosave_reviews = load_weapon_reviews(args.autosave_weapon_queue, args.expected_autosave_sha256)
    workshop_reviews = load_weapon_reviews(args.workshop_weapon_queue, args.expected_workshop_sha256)

    rows: list[dict[str, Any]] = []
    for source, variants, reviews in [
        ("TTS AutoSave", autosave, autosave_reviews),
        ("ForceOrg Workshop catalog", workshop, workshop_reviews),
    ]:
        for variant in variants:
            key = variant["variant_key"]
            rows.append(normalized_row(source, variant, reviews.get(key), fingerprints))
    rows.sort(key=lambda row: (str(row["catalog_source"]), str(row["representative_label"]).casefold(), str(row["variant_key"])))

    reviews = review_rows(args.review_ledger_input)
    compact_weapon_queue = weapon_review_rows(rows)
    write_csv(args.catalog, CATALOG_FIELDS, rows)
    write_csv(args.review_ledger, REVIEW_FIELDS, reviews)
    write_csv(args.weapon_review_queue, WEAPON_REVIEW_FIELDS, compact_weapon_queue)

    shared = sum(row["fingerprint_source_match"] == "both_source_saves" for row in fingerprints.values())
    autosave_only = sum(row["fingerprint_source_match"] == "autosave_only" for row in fingerprints.values())
    workshop_only = sum(row["fingerprint_source_match"] == "workshop_only" for row in fingerprints.values())
    pending_by_source = {
        "TTS AutoSave": sum(row.get("review_status") == "pending_visual_review" for row in autosave_reviews.values()),
        "ForceOrg Workshop catalog": sum(row.get("review_status") == "pending_visual_review" for row in workshop_reviews.values()),
    }
    summary = {
        "schema_version": 1,
        "generated_from_verified_local_tables": True,
        "rules_source": {
            "snapshot_id": EXPECTED_RULES_SNAPSHOT,
            "manifest_sha256": EXPECTED_RULES_MANIFEST,
            "use": "candidate ranking context only; not sculpt certification",
        },
        "sources": {
            "TTS AutoSave": {"sha256": args.expected_autosave_sha256, "variant_rows": len(autosave), "weapon_review_rows": len(autosave_reviews)},
            "ForceOrg Workshop catalog": {"sha256": args.expected_workshop_sha256, "variant_rows": len(workshop), "weapon_review_rows": len(workshop_reviews)},
        },
        "combined_source_variant_rows": len(rows),
        "rows_with_datasheet_candidate": sum(bool(row["candidate_datasheet_id"]) for row in rows),
        "unique_exact_asset_fingerprints": len(fingerprints),
        "exact_fingerprint_counts": {"both_sources": shared, "autosave_only": autosave_only, "workshop_only": workshop_only},
        "weapon_review_rows_pending_by_source": pending_by_source,
        "unique_pending_weapon_asset_fingerprints": len(compact_weapon_queue),
        "user_review_ledger_rows": len(reviews),
        "review_note": "The user tentatively replied that all seven Intercessor Sergeant labels were probably correct. This collective response is not exact-object, paint, or per-entry confirmation. All other visual/loadout candidates remain pending; text and fingerprint matches do not certify unit identity or weapon fit.",
        "outputs": {
            "catalog": str(args.catalog.resolve().relative_to(PROJECT_ROOT.resolve())),
            "user_review_ledger": str(args.review_ledger.resolve().relative_to(PROJECT_ROOT.resolve())),
            "unique_weapon_review_queue": str(args.weapon_review_queue.resolve().relative_to(PROJECT_ROOT.resolve())),
        },
    }
    args.summary.parent.mkdir(parents=True, exist_ok=True)
    args.summary.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return summary


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--autosave-snapshot", type=Path, default=DEFAULT_AUTOSAVE_SNAPSHOT)
    parser.add_argument("--workshop-save", type=Path, default=DEFAULT_WORKSHOP_SAVE)
    parser.add_argument("--expected-autosave-sha256", default=EXPECTED_AUTOSAVE_SHA256)
    parser.add_argument("--expected-workshop-sha256", default=EXPECTED_WORKSHOP_SHA256)
    parser.add_argument("--autosave-variants", type=Path, default=DEFAULT_AUTOSAVE_VARIANTS)
    parser.add_argument("--workshop-variants", type=Path, default=DEFAULT_WORKSHOP_VARIANTS)
    parser.add_argument("--autosave-relations", type=Path, help="Crosswalk for a raw AutoSave variant inventory")
    parser.add_argument("--workshop-relations", type=Path, help="Crosswalk for a raw Workshop variant inventory")
    parser.add_argument("--autosave-weapon-queue", type=Path, default=DEFAULT_AUTOSAVE_WEAPON_QUEUE)
    parser.add_argument("--workshop-weapon-queue", type=Path, default=DEFAULT_WORKSHOP_WEAPON_QUEUE)
    parser.add_argument("--fingerprint-index", type=Path, default=DEFAULT_FINGERPRINT_INDEX)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--review-ledger-input", type=Path, default=DEFAULT_REVIEW_LEDGER_INPUT)
    parser.add_argument("--review-ledger", type=Path, default=DEFAULT_REVIEW_LEDGER)
    parser.add_argument("--weapon-review-queue", type=Path, default=DEFAULT_WEAPON_REVIEW_QUEUE)
    parser.add_argument("--summary", type=Path, default=DEFAULT_SUMMARY)
    args = parser.parse_args()
    ensure_outputs_are_local([args.catalog, args.review_ledger, args.weapon_review_queue, args.summary])
    try:
        summary = build(args)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        raise SystemExit(f"Catalog build failed: {error}") from error
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
