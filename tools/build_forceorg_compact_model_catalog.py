#!/usr/bin/env python3
"""Create one review row per TTS visual variant with its highest-ranked 11e candidate."""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parents[1]
TABLE_ROOT = PROJECT_ROOT / ".tools" / "forceorg-model-table"
DEFAULT_VARIANTS = TABLE_ROOT / "ForceOrg_catalog_visual_candidates_variants.csv"
DEFAULT_RELATIONS = TABLE_ROOT / "forceorg_source" / "forceorg_visual_variant_datasheet_candidates.csv"
DEFAULT_OUTPUT = TABLE_ROOT / "forceorg_source" / "forceorg_variant_best_matches.csv"
RULES_SNAPSHOT = "20261021T130623Z"

OUTPUT_FIELDS = [
    "source_save", "source_save_sha256", "variant_key", "representative_label", "source_group_hints",
    "model_family_hint", "visual_weapon_hints", "asset_kind", "asset_fingerprint", "component_count",
    "source_occurrence_count", "source_occurrences", "existing_mapping_status", "existing_e11_datasheet_id",
    "existing_e11_model_role", "existing_e11_definition_id", "existing_e11_equipment_signature",
    "group_faction_scope", "candidate_matches_group_faction_scope", "recognized_legacy_weapon_label_terms",
    "candidate_count", "candidate_status", "top_candidate_tie_count",
    "top_candidate_tie_datasheets", "candidate_review_order", "candidate_lexical_score",
    "candidate_datasheet_id", "candidate_datasheet_name", "candidate_datasheet_role", "candidate_model_roles",
    "candidate_base_size_values", "candidate_faction_id", "candidate_faction_name", "candidate_source_book",
    "candidate_source_edition", "candidate_source_version", "visual_weapon_terms_present_in_candidate_source_text",
    "visual_weapon_hints_found_in_candidate", "visual_weapon_hints_not_found_in_candidate",
    "rules_snapshot_id", "rules_manifest_sha256", "review_authority",
]


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def rank(row: dict[str, str]) -> tuple[float, int, str]:
    try:
        score = float(row.get("candidate_lexical_score", ""))
    except (TypeError, ValueError):
        score = float("-inf")
    # Review order is a unique ordinal, not evidence that a lexical tie is
    # resolved. Prefer the hinted faction at the same score, retain real ties.
    outside_scope = bool(row.get("group_faction_scope")) and str(row.get("candidate_matches_group_faction_scope", "")).strip().casefold() != "true"
    return -score, int(outside_scope), row.get("candidate_datasheet_id", "")


def build(variants: list[dict[str, str]], relations: list[dict[str, str]]) -> tuple[list[dict[str, Any]], dict[str, int]]:
    variant_hashes = {row.get("save_sha256", "") for row in variants}
    relation_hashes = {row.get("forceorg_save_sha256", "") for row in relations}
    rule_ids = {row.get("rules_snapshot_id", "") for row in relations}
    if len(variant_hashes) != 1 or "" in variant_hashes:
        raise ValueError(f"Expected one non-empty source hash for variants, got {sorted(variant_hashes)}")
    if len(relation_hashes) != 1 or relation_hashes != variant_hashes:
        raise ValueError(f"Visual variants and rules relations have different source hashes: {sorted(variant_hashes)} / {sorted(relation_hashes)}")
    if rule_ids != {RULES_SNAPSHOT}:
        raise ValueError(f"Expected rules snapshot {RULES_SNAPSHOT}, got {sorted(rule_ids)}")

    candidates: dict[str, list[dict[str, str]]] = defaultdict(list)
    for row in relations:
        key = row.get("variant_key", "")
        if key:
            candidates[key].append(row)
    if len(candidates) != len(variants):
        raise ValueError(f"Candidate relation covers {len(candidates)} variants; source table has {len(variants)}")

    output: list[dict[str, Any]] = []
    no_candidate = 0
    ties = 0
    for variant in variants:
        key = variant.get("variant_key", "")
        rows = candidates.get(key, [])
        real = [row for row in rows if row.get("candidate_datasheet_id", "").strip()]
        real.sort(key=rank)
        if real:
            best = real[0]
            best_rank = rank(best)[:2]
            top = [row for row in real if rank(row)[:2] == best_rank]
            status = "Candidate found; review"
            candidate_id = best.get("candidate_datasheet_id", "")
            tie_string = " | ".join(
                f"{row.get('candidate_datasheet_id', '')}: {row.get('candidate_datasheet_name', '')}"
                for row in top
            )
            ties += int(len(top) > 1)
        else:
            best = {}
            top = []
            status = "No current 11e candidate"
            candidate_id = ""
            tie_string = ""
            no_candidate += 1
        output.append({
            "source_save": variant.get("source_save", ""),
            "source_save_sha256": variant.get("save_sha256", ""),
            "variant_key": key,
            "representative_label": variant.get("representative_label", ""),
            "source_group_hints": variant.get("source_group_hints", ""),
            "model_family_hint": variant.get("model_family_hint", ""),
            "visual_weapon_hints": variant.get("visual_weapon_hints", ""),
            "asset_kind": variant.get("asset_kind", ""),
            "asset_fingerprint": variant.get("asset_fingerprint", ""),
            "component_count": variant.get("component_count", ""),
            "source_occurrence_count": variant.get("source_occurrence_count", ""),
            "source_occurrences": variant.get("source_occurrences", ""),
            "existing_mapping_status": variant.get("mapping_status", ""),
            "existing_e11_datasheet_id": variant.get("e11_datasheet_id", ""),
            "existing_e11_model_role": variant.get("e11_model_role", ""),
            "existing_e11_definition_id": variant.get("e11_definition_id", ""),
            "existing_e11_equipment_signature": variant.get("e11_equipment_signature", ""),
            "group_faction_scope": best.get("group_faction_scope", ""),
            "candidate_matches_group_faction_scope": best.get("candidate_matches_group_faction_scope", ""),
            "recognized_legacy_weapon_label_terms": best.get("recognized_legacy_weapon_label_terms", ""),
            "candidate_count": len({row.get("candidate_datasheet_id", "") for row in real}),
            "candidate_status": status,
            "top_candidate_tie_count": len(top),
            "top_candidate_tie_datasheets": tie_string,
            "candidate_review_order": best.get("candidate_review_order", ""),
            "candidate_lexical_score": best.get("candidate_lexical_score", ""),
            "candidate_datasheet_id": candidate_id,
            "candidate_datasheet_name": best.get("candidate_datasheet_name", ""),
            "candidate_datasheet_role": best.get("candidate_datasheet_role", ""),
            "candidate_model_roles": best.get("candidate_model_roles", ""),
            "candidate_base_size_values": best.get("candidate_base_size_values", ""),
            "candidate_faction_id": best.get("candidate_faction_id", ""),
            "candidate_faction_name": best.get("candidate_faction_name", ""),
            "candidate_source_book": best.get("candidate_source_book", ""),
            "candidate_source_edition": best.get("candidate_source_edition", ""),
            "candidate_source_version": best.get("candidate_source_version", ""),
            "visual_weapon_terms_present_in_candidate_source_text": best.get("visual_weapon_terms_present_in_candidate_source_text", ""),
            "visual_weapon_hints_found_in_candidate": best.get("visual_weapon_hints_found_in_candidate", ""),
            "visual_weapon_hints_not_found_in_candidate": best.get("visual_weapon_hints_not_found_in_candidate", ""),
            "rules_snapshot_id": best.get("rules_snapshot_id", RULES_SNAPSHOT),
            "rules_manifest_sha256": best.get("rules_manifest_sha256", ""),
            "review_authority": best.get("review_authority", "No candidate was found in the current local 11e crosswalk."),
        })
    return output, {"variants": len(output), "without_current_11e_candidate": no_candidate, "variants_with_top_candidate_ties": ties}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--variants", type=Path, default=DEFAULT_VARIANTS)
    parser.add_argument("--relations", type=Path, default=DEFAULT_RELATIONS)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    try:
        args.output.resolve().relative_to((PROJECT_ROOT / ".tools").resolve())
    except ValueError as error:
        raise SystemExit("Refusing to write derived third-party data outside ignored .tools/.") from error
    rows, summary = build(read_csv(args.variants), read_csv(args.relations))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=OUTPUT_FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {summary['variants']} source-specific best-match rows to {args.output}")
    print(f"Variants without current 11e candidate: {summary['without_current_11e_candidate']}; variants tied for best candidate: {summary['variants_with_top_candidate_ties']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
