"""Build a source-bounded visual weapon review queue from local ForceOrg and Wahapedia exports.

The output is a local review aid. Name overlap and option-text matches are not a
confirmed sculpt, equipped loadout, or legality decision.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
from collections import Counter
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_ROOT = PROJECT_ROOT / ".tools" / "forceorg-model-table"
DEFAULT_CANDIDATES = DATA_ROOT / "forceorg_visual_variant_datasheet_candidates.csv"
DEFAULT_PROFILES = DATA_ROOT / "forceorg_datasheet_profiles_11e.csv"
DEFAULT_RUNTIME_IDENTITIES = DATA_ROOT / "runtime_visual_datasheet_identities.json"
DEFAULT_OUTPUT = DATA_ROOT / "forceorg_visual_weapon_review_queue.csv"

OUTPUT_COLUMNS = [
    "review_status",
    "review_scope",
    "forceorg_save_sha256",
    "rules_snapshot_id",
    "rules_manifest_sha256",
    "variant_key",
    "representative_label",
    "model_family_hint",
    "forceorg_source_group_hints",
    "group_faction_scope",
    "asset_kind",
    "asset_fingerprint",
    "tts_occurrence_count",
    "candidate_review_order",
    "family_name_match_status",
    "family_top_lexical_score",
    "candidate_lexical_score",
    "candidate_datasheet_id",
    "candidate_datasheet_name",
    "candidate_faction_name",
    "candidate_source_id",
    "candidate_source_book",
    "candidate_source_edition",
    "candidate_matches_group_faction_scope",
    "candidate_model_roles",
    "candidate_base_size_values",
    "runtime_supported_profile",
    "default_loadout",
    "options",
    "visual_weapon_hints",
    "weapon_hint_evidence",
    "weapon_option_match_status",
    "all_label_hints_in_current_options",
    "all_label_hints_in_current_profile_text",
    "visual_weapon_hints_found_in_candidate",
    "visual_weapon_hints_not_found_in_candidate",
    "review_authority",
]


def read_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def normalize_text(value: str) -> str:
    return " ".join(re.findall(r"[a-z0-9]+", value.casefold()))


def mentioned(needle: str, haystack: str) -> bool:
    normalized_needle = normalize_text(needle)
    normalized_haystack = f" {normalize_text(haystack)} "
    return bool(normalized_needle) and f" {normalized_needle} " in normalized_haystack


def parse_json_list(value: str, label: str, row_id: str) -> list[str]:
    if not value:
        return []
    parsed: Any = json.loads(value)
    if not isinstance(parsed, list):
        raise ValueError(f"{label} is not a JSON list for {row_id}.")
    return [str(item) for item in parsed]


def load_runtime_ids(path: Path) -> set[str]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    profiles = payload.get("profiles") if isinstance(payload, dict) else None
    if not isinstance(profiles, list):
        raise ValueError("Runtime identity file does not contain a profiles array.")
    return {str(item.get("source_datasheet_id", "")) for item in profiles if item.get("source_datasheet_id")}


def build_rows(
    candidates: list[dict[str, str]],
    profiles: dict[str, dict[str, str]],
    runtime_ids: set[str],
    scope: str,
) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    save_hashes: set[str] = set()
    rule_identities: set[tuple[str, str]] = set()

    for candidate in candidates:
        if candidate.get("candidate_review_order") != "1":
            continue
        if not candidate.get("candidate_datasheet_id") or not candidate.get("variant_weapon_hints"):
            continue
        profile_id = candidate["candidate_datasheet_id"]
        if scope == "runtime" and profile_id not in runtime_ids:
            continue
        profile = profiles.get(profile_id)
        if profile is None:
            raise ValueError(f"Candidate references missing local 11e profile {profile_id}.")
        if profile.get("source_edition") != "11":
            raise ValueError(f"Candidate references non-11e profile {profile_id}.")

        save_hashes.add(candidate.get("forceorg_save_sha256", ""))
        rule_identities.add((profile.get("rules_snapshot_id", ""), profile.get("rules_manifest_sha256", "")))
        options = parse_json_list(profile.get("options", ""), "options", profile_id)
        default_loadout = profile.get("default_loadout", "")
        option_text = "\n".join(options)
        profile_text = f"{default_loadout}\n{option_text}"
        hints = [item for item in candidate.get("variant_weapon_hints", "").split("|") if item]
        evidence = [
            {
                "label_hint": hint,
                "default_loadout_exact_text": mentioned(hint, default_loadout),
                "current_option_exact_text": mentioned(hint, option_text),
            }
            for hint in hints
        ]
        all_options = all(item["current_option_exact_text"] for item in evidence)
        all_profile_text = all(
            item["default_loadout_exact_text"] or item["current_option_exact_text"]
            for item in evidence
        )
        any_profile_text = any(
            item["default_loadout_exact_text"] or item["current_option_exact_text"]
            for item in evidence
        )
        if all_options:
            option_status = "all_label_hints_in_current_options"
        elif all_profile_text:
            option_status = "all_label_hints_in_default_or_options"
        elif any_profile_text:
            option_status = "some_label_hints_in_current_profile_text"
        else:
            option_status = "no_exact_label_hint_in_current_profile_text"

        row = {
            "review_status": "pending_visual_review",
            "review_scope": "current_runtime" if profile_id in runtime_ids else "other_11e_candidate",
            "forceorg_save_sha256": candidate.get("forceorg_save_sha256", ""),
            "rules_snapshot_id": profile.get("rules_snapshot_id", ""),
            "rules_manifest_sha256": profile.get("rules_manifest_sha256", ""),
            "variant_key": candidate.get("variant_key", ""),
            "representative_label": candidate.get("representative_label", ""),
            "model_family_hint": candidate.get("model_family_hint", ""),
            "forceorg_source_group_hints": candidate.get("forceorg_source_group_hints", ""),
            "group_faction_scope": candidate.get("group_faction_scope", ""),
            "asset_kind": candidate.get("asset_kind", ""),
            "asset_fingerprint": candidate.get("asset_fingerprint", ""),
            "tts_occurrence_count": candidate.get("tts_occurrence_count", ""),
            "candidate_review_order": candidate.get("candidate_review_order", ""),
            "family_name_match_status": candidate.get("family_name_match_status", ""),
            "family_top_lexical_score": candidate.get("family_top_lexical_score", ""),
            "candidate_lexical_score": candidate.get("candidate_lexical_score", ""),
            "candidate_datasheet_id": profile_id,
            "candidate_datasheet_name": candidate.get("candidate_datasheet_name", ""),
            "candidate_faction_name": candidate.get("candidate_faction_name", ""),
            "candidate_source_id": candidate.get("candidate_source_id", ""),
            "candidate_source_book": candidate.get("candidate_source_book", ""),
            "candidate_source_edition": candidate.get("candidate_source_edition", ""),
            "candidate_matches_group_faction_scope": candidate.get("candidate_matches_group_faction_scope", ""),
            "candidate_model_roles": candidate.get("candidate_model_roles", ""),
            "candidate_base_size_values": candidate.get("candidate_base_size_values", ""),
            "runtime_supported_profile": "yes" if profile_id in runtime_ids else "no",
            "default_loadout": default_loadout,
            "options": json.dumps(options, ensure_ascii=False),
            "visual_weapon_hints": candidate.get("variant_weapon_hints", ""),
            "weapon_hint_evidence": json.dumps(evidence, ensure_ascii=False),
            "weapon_option_match_status": option_status,
            "all_label_hints_in_current_options": str(all_options).lower(),
            "all_label_hints_in_current_profile_text": str(all_profile_text).lower(),
            "visual_weapon_hints_found_in_candidate": candidate.get("visual_weapon_hints_found_in_candidate", "[]"),
            "visual_weapon_hints_not_found_in_candidate": candidate.get("visual_weapon_hints_not_found_in_candidate", "[]"),
            "review_authority": (
                "Unverified visual candidate. Exact label text in an option is only a review clue; "
                "it does not confirm the sculpt, selected combination, or loadout legality."
            ),
        }
        rows.append(row)

    if len(save_hashes) != 1 or not next(iter(save_hashes), ""):
        raise ValueError(f"Expected one non-empty ForceOrg source hash, found {sorted(save_hashes)}.")
    if len(rule_identities) != 1 or not next(iter(rule_identities), ("", ""))[0]:
        raise ValueError(f"Expected one verified local rules identity, found {sorted(rule_identities)}.")

    rows.sort(
        key=lambda row: (
            row["candidate_faction_name"].casefold(),
            row["candidate_datasheet_name"].casefold(),
            row["model_family_hint"].casefold(),
            row["visual_weapon_hints"].casefold(),
            row["representative_label"].casefold(),
            row["variant_key"],
        )
    )
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--candidates", type=Path, default=DEFAULT_CANDIDATES)
    parser.add_argument("--profiles", type=Path, default=DEFAULT_PROFILES)
    parser.add_argument("--runtime-identities", type=Path, default=DEFAULT_RUNTIME_IDENTITIES)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--scope", choices=("runtime", "all-11e"), default="runtime")
    args = parser.parse_args()

    profiles = {row["datasheet_id"]: row for row in read_csv(args.profiles)}
    runtime_ids = load_runtime_ids(args.runtime_identities)
    rows = build_rows(read_csv(args.candidates), profiles, runtime_ids, args.scope)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=OUTPUT_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)

    option_counts = Counter(row["weapon_option_match_status"] for row in rows)
    print(
        f"Wrote {len(rows)} {args.scope} weapon-hinted candidate rows to {args.output}; "
        f"option evidence: {dict(sorted(option_counts.items()))}"
    )
    print("All rows remain pending visual review; option-text overlap is not a rules or sculpt certification.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
