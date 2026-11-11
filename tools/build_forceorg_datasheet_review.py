#!/usr/bin/env python3
"""Build a local review crosswalk from ForceOrg visuals to the verified 11e export.

This is a name-ranking and source-text-presence aid only. It never certifies that a
visual loadout is a legal combination or that an asset is the correct sculpt.
All derived output is constrained to the ignored .tools/ directory.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import html
import json
import re
import sys
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_VARIANTS = PROJECT_ROOT / ".tools/forceorg-model-table/TS_AutoSave_3_latest_visual_candidates_variants.csv"
DEFAULT_SNAPSHOT = PROJECT_ROOT / ".tools/wahapedia/11e/space-marines/20261021T130623Z"
DEFAULT_OUTPUT = PROJECT_ROOT / ".tools/forceorg-model-table/forceorg_datasheet_review.csv"
DEFAULT_RUNTIME_IDENTITIES = PROJECT_ROOT / ".tools/forceorg-model-table/runtime_visual_datasheet_identities.json"
DEFAULT_EXCEPTIONS_OUTPUT = PROJECT_ROOT / ".tools/forceorg-model-table/forceorg_non11_datasheet_candidates.csv"
DEFAULT_DUPLICATES_OUTPUT = PROJECT_ROOT / ".tools/forceorg-model-table/duplicate_datasheet_names.csv"
DEFAULT_FLAT_CROSSWALK_OUTPUT = PROJECT_ROOT / ".tools/forceorg-model-table/forceorg_visual_variant_datasheet_candidates.csv"
DEFAULT_DATASHEET_PROFILES_OUTPUT = PROJECT_ROOT / ".tools/forceorg-model-table/forceorg_datasheet_profiles_11e.csv"
DEFAULT_RUNTIME_COVERAGE_OUTPUT = PROJECT_ROOT / ".tools/forceorg-model-table/runtime_profile_visual_coverage.csv"
REQUIRED_SOURCE_FILES = [
    "Datasheets.csv",
    "Datasheets_options.csv",
    "Datasheets_unit_composition.csv",
    "Datasheets_models.csv",
    "Datasheets_wargear.csv",
    "Factions.csv",
    "Source.csv",
]
STOP_WORDS = {
    "a", "an", "and", "of", "the", "with", "w", "for", "to", "from", "in",
    "unit", "model", "models", "squad", "space", "marine", "marines", "primaris",
    "sergeant", "sargeant", "sgt", "custom", "assetbundle", "variant", "base",
}
GROUP_FACTION_ALIASES = {
    **{name: "Space Marines" for name in [
        "Ultramarines", "Imperial Fists", "Iron Hands", "Raven Guard", "Salamanders",
        "White Scars", "Raptors", "Black Templars", "Blood Angels", "Dark Angels",
        "Deathwatch", "Space Wolves", "Space Wolfes",
    ]},
    **{name: "Tyranids" for name in ["Tyranids", "Behemoth", "Kraken", "Kronos", "Gorgon", "Jormungandr"]},
    **{name: "Chaos Space Marines" for name in ["Chaos Marines", "Chaos Space Marines", "Alpha Legion", "Night Lords", "Word Bearers", "Red Corsairs"]},
}
SPECIFIC_LEGACY_WEAPON_PHRASES = ["auto bolt rifle", "stalker bolt rifle", "auto br", "stalker br"]
WEAPON_HINT_ALIASES = {
    "power-sword": ["power weapon", "power sword"],
    "knives-and-fists": ["knives and fists"],
    "combat-knife": ["combat knife", "combat knives"],
    "lightning-claws": ["lightning claws", "lightning claw"],
    "macro-plasma-incinerator": ["macro plasma incinerator", "plasma incinerator"],
    "plasma-incinerator": ["plasma incinerator"],
}
LEGACY_AND_COMPOUND_WEAPON_PHRASES = [
    "master crafted bolt rifle", "heavy onslaught gatling cannon", "stalker bolt rifle",
    "auto bolt rifle", "heavy bolt rifle", "twin assault cannon", "twin heavy bolter",
    "twin lascannon", "fragstorm grenade launcher", "boltstorm gauntlet", "plasma incinerator",
    "heavy flamer", "multi melta", "missile launcher", "plasma cannon", "assault bolter",
    "bolt rifle", "power sword", "power weapon", "power fist", "thunder hammer",
    "grenade launcher", "plasma pistol", "heavy bolter", "storm bolter", "combi weapon",
    "bolt carbine", "bolt pistol", "chainsword", "auto melta", "melta rifle", "assault cannon",
    "lascannon", "gatling cannon", "power klaw", "twin linked lascannon", "twin linked assault cannon",
]


def read_pipe_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream, delimiter="|"))


def read_comma_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def clean_source_text(value: str) -> str:
    text = html.unescape(value or "")
    text = re.sub(r"<\s*li\b[^>]*>", " • ", text, flags=re.I)
    text = re.sub(r"<\s*/\s*(?:li|p|div|ul|ol|br|h[1-6])\s*>", " ; ", text, flags=re.I)
    text = re.sub(r"<[^>]+>", " ", text)
    return re.sub(r"\s+", " ", text).strip(" ;")


def normalized(value: str) -> str:
    folded = unicodedata.normalize("NFKD", value or "")
    plain = "".join(char for char in folded if not unicodedata.combining(char)).lower()
    return re.sub(r"\s+", " ", re.sub(r"[^a-z0-9]+", " ", plain)).strip()


def tokens(value: str) -> set[str]:
    result: set[str] = set()
    for token in normalized(value).split():
        if token in STOP_WORDS or token.isdigit():
            continue
        if len(token) > 4 and token.endswith("ies"):
            token = token[:-3] + "y"
        elif len(token) > 4 and token.endswith("s") and not token.endswith("ss"):
            token = token[:-1]
        result.add(token)
    return result


def validate_snapshot(snapshot: Path) -> tuple[dict[str, Any], dict[str, str], dict[str, list[dict[str, str]]]]:
    manifest_path = snapshot / "manifest.json"
    manifest_bytes = manifest_path.read_bytes()
    manifest = json.loads(manifest_bytes.decode("utf-8-sig"))
    if manifest.get("edition") != "11e":
        raise ValueError(f"Expected 11e local export, got {manifest.get('edition')!r}.")
    if snapshot.name != manifest.get("snapshot_id"):
        raise ValueError("Snapshot folder name does not match manifest snapshot_id.")
    declared = {item["filename"]: item for item in manifest.get("files", [])}
    hashes: dict[str, str] = {}
    for filename in REQUIRED_SOURCE_FILES:
        if filename not in declared:
            raise ValueError(f"{filename} is absent from the manifest.")
        raw = (snapshot / filename).read_bytes()
        digest = hashlib.sha256(raw).hexdigest()
        expected = str(declared[filename].get("sha256", "")).lower()
        if digest != expected:
            raise ValueError(f"SHA-256 mismatch for {filename}; refusing to build candidate links.")
        hashes[filename] = digest
    tables = {
        filename: read_pipe_csv(snapshot / filename)
        for filename in REQUIRED_SOURCE_FILES
    }
    return manifest, hashes, tables


def build_datasheets(tables: dict[str, list[dict[str, str]]]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    factions = {row["id"]: row["name"] for row in tables["Factions.csv"] if row.get("id")}
    sources = {row["id"]: row for row in tables["Source.csv"] if row.get("id")}
    options: dict[str, list[str]] = defaultdict(list)
    compositions: dict[str, list[str]] = defaultdict(list)
    models: dict[str, list[dict[str, str]]] = defaultdict(list)
    wargear: dict[str, list[str]] = defaultdict(list)
    for row in tables["Datasheets_options.csv"]:
        if row.get("datasheet_id"):
            text = clean_source_text(row.get("description", ""))
            if text:
                options[row["datasheet_id"]].append(text)
    for row in tables["Datasheets_unit_composition.csv"]:
        if row.get("datasheet_id"):
            text = clean_source_text(row.get("description", ""))
            if text:
                compositions[row["datasheet_id"]].append(text)
    for row in tables["Datasheets_models.csv"]:
        if row.get("datasheet_id"):
            models[row["datasheet_id"]].append({
                "name": clean_source_text(row.get("name", "")),
                "base_size": clean_source_text(row.get("base_size", "")),
                "base_size_descr": clean_source_text(row.get("base_size_descr", "")),
                "line": row.get("line", ""),
            })
    for row in tables["Datasheets_wargear.csv"]:
        if row.get("datasheet_id"):
            name = clean_source_text(row.get("name", ""))
            if name:
                wargear[row["datasheet_id"]].append(name)

    records: list[dict[str, Any]] = []
    out_of_edition: list[dict[str, Any]] = []
    for row in tables["Datasheets.csv"]:
        source = sources.get(row.get("source_id", ""), {})
        edition = str(source.get("edition", "")).strip()
        identity = row.get("id", "")
        source_options = options.get(identity, [])
        role_rows = models.get(identity, [])
        source_loadout = clean_source_text(row.get("loadout", ""))
        source_composition = compositions.get(identity, [])
        source_wargear = sorted(set(wargear.get(identity, [])))
        profile_text = " ".join([
            row.get("name", ""), source_loadout, *source_options, *source_composition,
            *(role.get("name", "") for role in role_rows), *source_wargear,
        ])
        record = {
            "datasheet_id": identity,
            "name": row.get("name", ""),
            "faction_id": row.get("faction_id", ""),
            "faction_name": factions.get(row.get("faction_id", ""), ""),
            "source_id": row.get("source_id", ""),
            "source_name": source.get("name", ""),
            "source_type": source.get("type", ""),
            "source_edition": edition,
            "source_version": source.get("version", ""),
            "datasheet_role": clean_source_text(row.get("role", "")),
            "source_loadout": source_loadout,
            "source_options": source_options,
            "source_composition": source_composition,
            "model_roles_and_bases": role_rows,
            "wargear_names": source_wargear,
            "virtual": row.get("virtual", ""),
            "is_support": row.get("is_support", ""),
            "tokens": tokens(row.get("name", "")),
            "role_tokens": [tokens(role.get("name", "")) for role in role_rows],
            "profile_text_normalized": normalized(profile_text),
        }
        if edition == "11":
            records.append(record)
        else:
            if not source:
                record["edition_blocker"] = "Datasheet source identity is missing from Source.csv."
            elif edition == "0":
                record["edition_blocker"] = "Local export marks the source edition as 0; do not use as a current 11e rules profile."
            else:
                record["edition_blocker"] = f"Local export marks source edition {edition}; do not mix into current 11e rules."
            out_of_edition.append(record)
    return records, out_of_edition


def build_duplicate_name_audit(datasheets: list[dict[str, Any]]) -> list[dict[str, str]]:
    """Keep same-name 11e datasheets separate and show whether their profiles differ."""
    groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for sheet in datasheets:
        name = str(sheet.get("name", ""))
        if name:
            groups[name].append(sheet)

    compared_fields = {
        "datasheet_role": lambda sheet: sheet["datasheet_role"],
        "default_loadout": lambda sheet: sheet["source_loadout"],
        "options": lambda sheet: sorted(sheet["source_options"]),
        "unit_composition": lambda sheet: sorted(sheet["source_composition"]),
        "model_roles_and_base_sizes": lambda sheet: sorted(
            sheet["model_roles_and_bases"],
            key=lambda role: (normalized(str(role.get("name", ""))), str(role.get("base_size", "")), str(role.get("line", ""))),
        ),
        "wargear_profiles": lambda sheet: sorted(sheet["wargear_names"]),
        "virtual_flag": lambda sheet: sheet["virtual"],
        "support_flag": lambda sheet: sheet["is_support"],
    }
    result: list[dict[str, str]] = []
    for name, matches in sorted(groups.items(), key=lambda item: normalized(item[0])):
        # Distinct IDs are the unit of identity. Repeated rows with the same ID are not a duplicate datasheet.
        by_id = {str(sheet["datasheet_id"]): sheet for sheet in matches if sheet.get("datasheet_id")}
        distinct = list(by_id.values())
        if len(distinct) < 2:
            continue
        value_sets: dict[str, set[str]] = {}
        base_size_sets: set[str] = set()
        group_base_sizes: set[str] = set()
        for sheet in distinct:
            sizes = sorted({
                str(role.get("base_size", "")).strip()
                for role in sheet["model_roles_and_bases"]
                if str(role.get("base_size", "")).strip()
            })
            group_base_sizes.update(sizes)
            base_size_sets.add(json.dumps(sizes, ensure_ascii=False, separators=(",", ":")))
        for field, getter in compared_fields.items():
            value_sets[field] = {
                json.dumps(getter(sheet), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
                for sheet in distinct
            }
        differing_fields = sorted(field for field, values in value_sets.items() if len(values) > 1)
        signatures = {
            tuple(
                json.dumps(getter(sheet), ensure_ascii=False, sort_keys=True, separators=(",", ":"))
                for getter in compared_fields.values()
            )
            for sheet in distinct
        }
        signature_count = len(signatures)
        assessment = (
            "same exact name; distinct datasheet IDs; compared profile fields differ"
            if signature_count > 1
            else "same exact name; distinct datasheet IDs; compared profile fields match"
        )
        id_list = sorted(by_id)
        for sheet in sorted(distinct, key=lambda item: (normalized(str(item["faction_name"])), normalized(str(item["source_name"])), str(item["datasheet_id"]))):
            result.append({
                "datasheet_name": name,
                "duplicate_group_record_count": str(len(distinct)),
                "datasheet_id": str(sheet["datasheet_id"]),
                "duplicate_group_datasheet_ids": json.dumps(id_list, ensure_ascii=False),
                "group_profile_signature_count": str(signature_count),
                "group_assessment": assessment,
                "differing_profile_fields": "|".join(differing_fields),
                "group_base_sizes_differ": str(len(base_size_sets) > 1).lower(),
                "group_base_size_values": json.dumps(sorted(group_base_sizes), ensure_ascii=False),
                "faction_id": str(sheet["faction_id"]),
                "faction_name": str(sheet["faction_name"]),
                "source_id": str(sheet["source_id"]),
                "source_book": str(sheet["source_name"]),
                "source_edition": str(sheet["source_edition"]),
                "source_version": str(sheet["source_version"]),
                "datasheet_role": str(sheet["datasheet_role"]),
                "source_loadout": str(sheet["source_loadout"]),
                "source_options": json.dumps(sheet["source_options"], ensure_ascii=False, separators=(",", ":")),
                "source_composition": json.dumps(sheet["source_composition"], ensure_ascii=False, separators=(",", ":")),
                "model_roles_and_base_sizes": json.dumps(sheet["model_roles_and_bases"], ensure_ascii=False, separators=(",", ":")),
                "wargear_names": json.dumps(sheet["wargear_names"], ensure_ascii=False, separators=(",", ":")),
                "virtual_flag": str(sheet["virtual"]),
                "support_flag": str(sheet["is_support"]),
                "comparison_scope": "Only local verified edition-11 export profile fields; exact name and ID are preserved; no ForceOrg mapping or game-mode legality inferred.",
            })
    return result


def build_datasheet_profile_rows(
    datasheets: list[dict[str, Any]], manifest: dict[str, Any],
    source_hashes: dict[str, str], manifest_hash: str,
) -> list[dict[str, str]]:
    """Write complete current profiles once so visual candidate rows can stay compact."""
    snapshot_id = str(manifest.get("snapshot_id", ""))
    result: list[dict[str, str]] = []
    for sheet in datasheets:
        result.append({
            "datasheet_id": str(sheet["datasheet_id"]),
            "datasheet_name": str(sheet["name"]),
            "faction_id": str(sheet["faction_id"]),
            "faction_name": str(sheet["faction_name"]),
            "source_id": str(sheet["source_id"]),
            "source_book": str(sheet["source_name"]),
            "source_type": str(sheet["source_type"]),
            "source_edition": str(sheet["source_edition"]),
            "source_version": str(sheet["source_version"]),
            "datasheet_role": str(sheet["datasheet_role"]),
            "default_loadout": str(sheet["source_loadout"]),
            "options": json.dumps(sheet["source_options"], ensure_ascii=False, separators=(",", ":")),
            "unit_composition": json.dumps(sheet["source_composition"], ensure_ascii=False, separators=(",", ":")),
            "model_roles_and_base_sizes": json.dumps(sheet["model_roles_and_bases"], ensure_ascii=False, separators=(",", ":")),
            "wargear_profiles": json.dumps(sheet["wargear_names"], ensure_ascii=False, separators=(",", ":")),
            "virtual_flag": str(sheet["virtual"]),
            "support_flag": str(sheet["is_support"]),
            "runtime_profile_records": json.dumps(sheet.get("runtime_profile_records", []), ensure_ascii=False, separators=(",", ":")),
            "rules_snapshot_id": snapshot_id,
            "rules_manifest_sha256": manifest_hash,
            "datasheets_csv_sha256": source_hashes["Datasheets.csv"],
            "options_csv_sha256": source_hashes["Datasheets_options.csv"],
            "model_bases_csv_sha256": source_hashes["Datasheets_models.csv"],
            "wargear_csv_sha256": source_hashes["Datasheets_wargear.csv"],
            "source_csv_sha256": source_hashes["Source.csv"],
        })
    return result


def build_wargear_pattern(datasheets: list[dict[str, Any]]) -> re.Pattern[str] | None:
    phrases: set[str] = set()
    for sheet in datasheets:
        for weapon in sheet["wargear_names"]:
            phrase = normalized(str(weapon))
            if phrase:
                phrases.add(phrase)
                # The Data Export gives separate profile labels after a dash;
                # the TTS object name usually contains the unqualified weapon.
                for separator in [" standard ", " focused fire ", " saturation ", " supercharge ", " frag ", " krak "]:
                    if separator in phrase:
                        phrases.add(phrase.split(separator, 1)[0])
    if not phrases:
        return None
    alternatives = "|".join(re.escape(value) for value in sorted(phrases, key=lambda item: (-len(item.split()), -len(item))))
    return re.compile(rf"\b(?:{alternatives})\b")


def local_weapon_mentions(label: str, pattern: re.Pattern[str] | None) -> tuple[list[str], list[str]]:
    text = normalized(label)
    legacy: list[str] = []
    for phrase in SPECIFIC_LEGACY_WEAPON_PHRASES:
        if re.search(rf"\b{re.escape(phrase)}\b", text):
            legacy.append(phrase)
            text = re.sub(rf"\b{re.escape(phrase)}\b", " ", text)
    current = sorted(set(pattern.findall(text))) if pattern is not None else []
    return current, legacy


def group_faction_for_source(
    groups: list[str], label_text: str, faction_names: set[str], source_to_factions: dict[str, set[str]],
) -> tuple[str, str]:
    mapped: set[str] = set()
    for group in groups:
        key = normalized(group)
        alias = GROUP_FACTION_ALIASES.get(group, GROUP_FACTION_ALIASES.get(key, ""))
        if not alias and key in {normalized(item) for item in faction_names}:
            alias = next(item for item in faction_names if normalized(item) == key)
        if alias:
            mapped.add(alias)
    if len(mapped) == 1:
        faction = next(iter(mapped))
        if faction in faction_names:
            return faction, "matched_tts_group"
        return "", "group_alias_not_in_snapshot"
    if len(mapped) > 1:
        return "", "conflicting_tts_group_factions"

    normalized_label = normalized(label_text)
    faction_matches = [
        name for name in faction_names
        if len(normalized(name)) >= 5 and f" {normalized(name)} " in f" {normalized_label} "
    ]
    if faction_matches:
        longest = max(len(normalized(name)) for name in faction_matches)
        best = {name for name in faction_matches if len(normalized(name)) == longest}
        if len(best) == 1:
            return next(iter(best)), "inferred_from_exact_faction_name_in_label"
        return "", "ambiguous_faction_name_in_label"

    group_aliases: dict[str, str] = {}
    for group_name, faction_name in GROUP_FACTION_ALIASES.items():
        group_aliases[normalized(group_name)] = faction_name
    alias_matches = [name for name in group_aliases if len(name) >= 5 and f" {name} " in f" {normalized_label} "]
    if alias_matches:
        longest = max(len(name) for name in alias_matches)
        targets = {group_aliases[name] for name in alias_matches if len(name) == longest}
        if len(targets) == 1:
            faction = next(iter(targets))
            if faction in faction_names:
                return faction, "inferred_from_chapter_or_paint_name_in_label"

    book_matches = [
        (name, factions) for name, factions in source_to_factions.items()
        if len(name) >= 5 and f" {name} " in f" {normalized_label} "
    ]
    if book_matches:
        longest = max(len(name) for name, _ in book_matches)
        targets = set().union(*(factions for name, factions in book_matches if len(name) == longest))
        if len(targets) == 1:
            return next(iter(targets)), "inferred_from_datasheet_source_book_name"
        return "", "ambiguous_source_book_name_in_label"
    if groups:
        return "", "group_not_mapped_to_export_faction"
    return "", "no_tts_group_or_faction_name"


def dice_score(left: set[str], right: set[str]) -> float:
    overlap = len(left & right)
    if not overlap:
        return 0.0
    return 2.0 * overlap / (len(left) + len(right))


def candidate_matches(
    family: str,
    faction_scope: str,
    datasheets: list[dict[str, Any]],
) -> list[tuple[float, dict[str, Any]]]:
    family_tokens = tokens(family)
    if not family_tokens:
        return []
    scored: list[tuple[float, dict[str, Any]]] = []
    for sheet in datasheets:
        best = dice_score(family_tokens, sheet["tokens"])
        for role_tokens in sheet["role_tokens"]:
            best = max(best, dice_score(family_tokens, role_tokens))
        if best > 0:
            scored.append((best, sheet))
    scored.sort(key=lambda item: (-item[0], 0 if not faction_scope or item[1]["faction_name"] == faction_scope else 1, normalized(str(item[1]["name"])), str(item[1]["datasheet_id"])))
    return scored


def family_tokens_for_match(
    family: str,
    group_names: list[str],
    label_names: list[str],
    descriptor_phrases: set[str],
    weapon_pattern: re.Pattern[str] | None,
    faction_scope: str,
) -> set[str]:
    cleaned = normalized(" ".join([family, *label_names]))
    keep_faction_phrase = normalized(faction_scope)
    phrases = {phrase for phrase in descriptor_phrases if phrase != keep_faction_phrase}
    phrases.update(normalized(alias) for alias in GROUP_FACTION_ALIASES if normalized(alias) != keep_faction_phrase)
    phrases.update(normalized(name) for name in group_names if normalized(name) != keep_faction_phrase)
    phrases.update(LEGACY_AND_COMPOUND_WEAPON_PHRASES)
    for phrase in sorted((p for p in phrases if p), key=lambda value: (-len(value.split()), -len(value))):
        cleaned = re.sub(rf"\b{re.escape(phrase)}\b", " ", cleaned)
    if weapon_pattern is not None:
        cleaned = weapon_pattern.sub(" ", cleaned)
    return tokens(cleaned)


def hint_aliases(hint: str) -> list[str]:
    if hint in WEAPON_HINT_ALIASES:
        return WEAPON_HINT_ALIASES[hint]
    return [hint.replace("-", " ")]


def weapon_presence(hints: list[str], current_names: list[str], sheet: dict[str, Any]) -> tuple[str, list[str], list[str], list[str], list[str]]:
    if not hints and not current_names:
        return "no_recognized_weapon_hints", [], [], [], []
    text = sheet["profile_text_normalized"]
    found: list[str] = []
    absent: list[str] = []
    for hint in hints:
        aliases = hint_aliases(hint)
        if any(normalized(alias) in text for alias in aliases):
            found.append(hint)
        else:
            absent.append(hint)
    current_found = [name for name in current_names if normalized(name) in text]
    current_absent = [name for name in current_names if normalized(name) not in text]
    if not absent and not current_absent:
        status = "all_names_present_in_datasheet_source_text"
    elif found or current_found:
        status = "some_names_present_in_datasheet_source_text"
    else:
        status = "no_names_found_in_datasheet_source_text"
    return status, found, absent, current_found, current_absent


def candidate_payload(score: float, sheet: dict[str, Any], hints: list[str], current_names: list[str], faction_scope: str) -> dict[str, Any]:
    weapon_status, found, absent, current_found, current_absent = weapon_presence(hints, current_names, sheet)
    return {
        "lexical_score": round(score, 4),
        "datasheet_id": sheet["datasheet_id"],
        "datasheet_name": sheet["name"],
        "faction_id": sheet["faction_id"],
        "faction_name": sheet["faction_name"],
        "matches_group_faction_scope": not faction_scope or sheet["faction_name"] == faction_scope,
        "source_id": sheet["source_id"],
        "source_book": sheet["source_name"],
        "source_edition": sheet["source_edition"],
        "source_version": sheet["source_version"],
        "datasheet_role": sheet["datasheet_role"],
        "default_loadout": sheet["source_loadout"],
        "unit_composition": sheet["source_composition"],
        "model_roles_and_base_sizes": sheet["model_roles_and_bases"],
        "wargear_names": sheet["wargear_names"],
        "datasheet_options": sheet["source_options"],
        "source_text_weapon_presence": weapon_status,
        "visual_weapon_hints_found": found,
        "visual_weapon_hints_not_found": absent,
        "local_export_weapon_names_found": current_found,
        "local_export_weapon_names_not_found": current_absent,
        "support_flag": sheet["is_support"],
        "virtual_flag": sheet["virtual"],
        "runtime_profile_record_present": bool(sheet.get("runtime_profile_records", [])),
        "runtime_profile_records": sheet.get("runtime_profile_records", []),
    }


def mapping_status(candidates: list[tuple[float, dict[str, Any]]], faction_scope: str) -> tuple[str, float, int]:
    if not candidates:
        return "unmatched_no_name_overlap", 0.0, 0
    top = candidates[0][0]
    tie_count = sum(1 for score, _ in candidates if score == top)
    in_scope_top = any(score == top and sheet["faction_name"] == faction_scope for score, sheet in candidates) if faction_scope else True
    if faction_scope and not in_scope_top:
        return "top_name_candidate_outside_group_faction_review_required", top, tie_count
    if top == 1.0 and tie_count == 1:
        return "unique_exact_name_or_role_candidate_review_required", top, tie_count
    if top >= 0.8 and tie_count == 1:
        return "strong_lexical_candidate_review_required", top, tie_count
    if tie_count > 1:
        return "ambiguous_top_name_candidates_review_required", top, tie_count
    if top >= 0.4:
        return "possible_lexical_candidate_review_required", top, tie_count
    return "weak_name_overlap_review_required", top, tie_count


def build_crosswalk(
    variant_rows: list[dict[str, str]],
    datasheets: list[dict[str, Any]],
    faction_names: set[str],
    manifest: dict[str, Any],
    source_hashes: dict[str, str],
    manifest_hash: str,
    runtime_profiles_by_datasheet: dict[str, list[dict[str, Any]]],
) -> list[dict[str, str]]:
    family_groups: dict[tuple[str, str], list[dict[str, str]]] = defaultdict(list)
    source_hashes_seen = {row.get("save_sha256", "") for row in variant_rows}
    if len(source_hashes_seen) != 1 or "" in source_hashes_seen:
        raise ValueError("Variant CSV must contain one non-empty ForceOrg save hash.")
    forceorg_hash = next(iter(source_hashes_seen))
    for row in variant_rows:
        family_groups[(row.get("source_group_hints", ""), row.get("model_family_hint", ""))].append(row)

    rules_snapshot = str(manifest.get("snapshot_id", ""))
    rules_revision = str(manifest.get("source_export_updated_at", ""))
    for sheet in datasheets:
        sheet["runtime_profile_records"] = runtime_profiles_by_datasheet.get(str(sheet["datasheet_id"]), [])
    source_to_factions: dict[str, set[str]] = defaultdict(set)
    for sheet in datasheets:
        if sheet["source_name"]:
            source_to_factions[normalized(str(sheet["source_name"]))].add(str(sheet["faction_name"]))
    descriptor_phrases = {
        normalized(str(sheet[key]))
        for sheet in datasheets
        for key in ["source_name", "faction_name"]
        if normalized(str(sheet.get(key, "")))
    }
    weapon_pattern = build_wargear_pattern(datasheets)
    result: list[dict[str, str]] = []
    for (group_string, family), variants in sorted(family_groups.items(), key=lambda item: (normalized(item[0][0]), normalized(item[0][1]))):
        group_list = [part for part in group_string.split("|") if part]
        representative_labels = sorted({row.get("representative_label", "") for row in variants if row.get("representative_label")})
        full_label_text = " ".join([family, *representative_labels, group_string])
        group_faction, faction_status = group_faction_for_source(group_list, full_label_text, faction_names, source_to_factions)
        match_tokens = family_tokens_for_match(family, group_list, representative_labels, descriptor_phrases, weapon_pattern, group_faction)
        ranked = candidate_matches(" ".join(sorted(match_tokens)), group_faction, datasheets)
        status, top_score, tie_count = mapping_status(ranked, group_faction)
        weapon_hints = sorted({
            hint
            for row in variants
            for hint in (row.get("visual_weapon_hints", "").split("|") if row.get("visual_weapon_hints") else [])
        })
        visual_roles: dict[str, str] = {}
        equipment_signatures: set[str] = set()
        export_weapon_mentions: set[str] = set()
        legacy_weapon_mentions: set[str] = set()
        for row in variants:
            role = row.get("e11_model_role", "")
            if role:
                visual_roles[role] = row.get("e11_definition_id", "")
            if row.get("e11_equipment_signature"):
                equipment_signatures.add(row["e11_equipment_signature"])
            current, legacy = local_weapon_mentions(row.get("representative_label", ""), weapon_pattern)
            export_weapon_mentions.update(current)
            legacy_weapon_mentions.update(legacy)
        variant_relations = []
        for row in variants:
            try:
                occurrences = json.loads(row.get("source_occurrences", "[]"))
            except json.JSONDecodeError:
                occurrences = []
            variant_relations.append({
                "variant_key": row.get("variant_key", ""),
                "representative_label": row.get("representative_label", ""),
                "visual_weapon_hints": row.get("visual_weapon_hints", ""),
                "asset_kind": row.get("asset_kind", ""),
                "asset_fingerprint": row.get("asset_fingerprint", ""),
                "e11_model_role": row.get("e11_model_role", ""),
                "e11_equipment_signature": row.get("e11_equipment_signature", ""),
                "mapping_status": row.get("mapping_status", ""),
                "source_occurrence_count": row.get("source_occurrence_count", "0"),
                "source_occurrences": occurrences,
            })
        selected: list[tuple[float, dict[str, Any]]] = ranked[:5]
        for match in ranked[5:]:
            if match[0] == top_score:
                selected.append(match)
            else:
                break
        if group_faction:
            selected_ids = {sheet["datasheet_id"] for _, sheet in selected}
            in_scope = [(score, sheet) for score, sheet in ranked if sheet["faction_name"] == group_faction]
            for match in in_scope[:5]:
                if match[1]["datasheet_id"] not in selected_ids:
                    selected.append(match)
                    selected_ids.add(match[1]["datasheet_id"])
        candidate_records = [candidate_payload(score, sheet, weapon_hints, sorted(export_weapon_mentions), group_faction) for score, sheet in selected]
        occurrence_total = sum(int(row.get("source_occurrence_count", "0") or 0) for row in variants)
        result.append({
            "forceorg_save": variants[0].get("source_save", ""),
            "forceorg_save_sha256": forceorg_hash,
            "forceorg_source_group_hints": group_string,
            "group_faction_scope": group_faction,
            "group_faction_scope_status": faction_status,
            "model_family_hint": family,
            "visual_variant_group_count": str(len(variants)),
            "source_occurrence_count": str(occurrence_total),
            "representative_labels": json.dumps(representative_labels, ensure_ascii=False),
            "visual_weapon_hint_signatures": json.dumps(sorted({row.get("visual_weapon_hints", "") for row in variants if row.get("visual_weapon_hints")}), ensure_ascii=False),
            "visual_variant_relationships": json.dumps(variant_relations, ensure_ascii=False, separators=(",", ":")),
            "recognized_weapon_hints": "|".join(weapon_hints),
            "local_export_weapon_name_mentions": "|".join(sorted(export_weapon_mentions)),
            "recognized_legacy_weapon_label_terms": "|".join(sorted(legacy_weapon_mentions)),
            "existing_reviewed_visual_roles": json.dumps(visual_roles, ensure_ascii=False, sort_keys=True),
            "existing_reviewed_equipment_signatures": "|".join(sorted(equipment_signatures)),
            "name_match_status": status,
            "top_lexical_score": str(round(top_score, 4)),
            "top_score_tie_count": str(tie_count),
            "candidate_datasheet_count": str(len(ranked)),
            "candidate_datasheets": json.dumps(candidate_records, ensure_ascii=False, separators=(",", ":")),
            "mapping_authority": "candidate name ranking only; human review required",
            "rules_edition": str(manifest.get("edition", "")),
            "rules_snapshot_id": rules_snapshot,
            "rules_export_updated_at": rules_revision,
            "rules_game_mode_scope": "Not specified in the datasheet export; do not infer event-list restrictions.",
            "rules_manifest_sha256": manifest_hash,
            "datasheets_csv_sha256": source_hashes["Datasheets.csv"],
            "options_csv_sha256": source_hashes["Datasheets_options.csv"],
            "model_bases_csv_sha256": source_hashes["Datasheets_models.csv"],
        })
    return result


def build_non11_candidates(
    variant_rows: list[dict[str, str]],
    excluded_datasheets: list[dict[str, Any]],
    current_datasheets: list[dict[str, Any]],
) -> list[dict[str, str]]:
    family_groups: dict[tuple[str, str], list[dict[str, str]]] = defaultdict(list)
    for row in variant_rows:
        family_groups[(row.get("source_group_hints", ""), row.get("model_family_hint", ""))].append(row)
    descriptor_phrases = {
        normalized(str(sheet[key]))
        for sheet in current_datasheets
        for key in ["source_name", "faction_name"]
        if normalized(str(sheet.get(key, "")))
    }
    weapon_pattern = build_wargear_pattern(current_datasheets)
    families: list[dict[str, Any]] = []
    for (group_string, family), variants in family_groups.items():
        labels = sorted({row.get("representative_label", "") for row in variants if row.get("representative_label")})
        family_match_tokens = family_tokens_for_match(family, [x for x in group_string.split("|") if x], labels, descriptor_phrases, weapon_pattern, "")
        if not family_match_tokens:
            continue
        families.append({
            "source_group_hints": group_string,
            "model_family_hint": family,
            "representative_labels": labels,
            "variant_count": len(variants),
            "weapon_hints": sorted({
                hint for row in variants
                for hint in (row.get("visual_weapon_hints", "").split("|") if row.get("visual_weapon_hints") else [])
            }),
            "tokens": family_match_tokens,
        })
    result: list[dict[str, str]] = []
    for sheet in excluded_datasheets:
        ranked: list[tuple[float, dict[str, Any]]] = []
        for family in families:
            score = dice_score(family["tokens"], sheet["tokens"])
            for role_tokens in sheet["role_tokens"]:
                score = max(score, dice_score(family["tokens"], role_tokens))
            if score > 0:
                ranked.append((score, family))
        ranked.sort(key=lambda item: (-item[0], normalized(str(item[1]["model_family_hint"])), str(item[1]["source_group_hints"])))
        best_candidates = [
            {
                "lexical_score": round(score, 4),
                "forceorg_source_group_hints": family["source_group_hints"],
                "model_family_hint": family["model_family_hint"],
                "visual_variant_group_count": family["variant_count"],
                "representative_labels": family["representative_labels"],
                "visual_weapon_hints": family["weapon_hints"],
            }
            for score, family in ranked[:5]
        ]
        result.append({
            "datasheet_id": str(sheet["datasheet_id"]),
            "datasheet_name": str(sheet["name"]),
            "faction_name": str(sheet["faction_name"]),
            "source_id": str(sheet["source_id"]),
            "source_book": str(sheet["source_name"]),
            "source_type": str(sheet["source_type"]),
            "source_edition": str(sheet["source_edition"]),
            "source_version": str(sheet["source_version"]),
            "source_scope_disposition": str(sheet.get("edition_blocker", "")),
            "source_loadout": str(sheet["source_loadout"]),
            "source_options": json.dumps(sheet["source_options"], ensure_ascii=False),
            "model_roles_and_base_sizes": json.dumps(sheet["model_roles_and_bases"], ensure_ascii=False),
            "forceorg_model_family_candidates": json.dumps(best_candidates, ensure_ascii=False, separators=(",", ":")),
            "current_rules_mapping_authority": "excluded from current 11e candidates; inspect its source edition before any rules use",
        })
    return result


def build_flat_variant_candidates(
    crosswalk: list[dict[str, str]], datasheets: list[dict[str, Any]],
) -> list[dict[str, str]]:
    """Expand nested family candidates to filterable per-variant CSV rows."""
    weapon_pattern = build_wargear_pattern(datasheets)
    result: list[dict[str, str]] = []
    for family in crosswalk:
        try:
            variants = json.loads(family.get("visual_variant_relationships", "[]"))
            candidates = json.loads(family.get("candidate_datasheets", "[]"))
        except json.JSONDecodeError as error:
            raise ValueError(f"Invalid nested crosswalk JSON for {family.get('model_family_hint', '')!r}: {error}") from error
        if not isinstance(variants, list) or not isinstance(candidates, list):
            raise ValueError("Nested visual relationships and datasheet candidates must be arrays.")
        candidate_rows: list[dict[str, Any] | None] = candidates or [None]
        for variant in variants:
            if not isinstance(variant, dict):
                continue
            label = str(variant.get("representative_label", ""))
            hints = [item for item in str(variant.get("visual_weapon_hints", "")).split("|") if item]
            current_names, legacy_names = local_weapon_mentions(label, weapon_pattern)
            for rank, candidate in enumerate(candidate_rows, start=1):
                if candidate is None:
                    weapon_status, hints_found, hints_absent, current_found, current_absent = (
                        "no_datasheet_candidate", [], hints, [], current_names
                    )
                    candidate = {}
                else:
                    source_profile_text = " ".join([
                        str(candidate.get("datasheet_name", "")),
                        str(candidate.get("datasheet_role", "")),
                        str(candidate.get("default_loadout", "")),
                        " ".join(str(item) for item in candidate.get("unit_composition", []) if item),
                        " ".join(str(item) for item in candidate.get("datasheet_options", []) if item),
                        " ".join(str(item) for item in candidate.get("wargear_names", []) if item),
                        " ".join(
                            str(item.get("name", ""))
                            for item in candidate.get("model_roles_and_base_sizes", [])
                            if isinstance(item, dict)
                        ),
                    ])
                    weapon_status, hints_found, hints_absent, current_found, current_absent = weapon_presence(
                        hints, current_names, {"profile_text_normalized": normalized(source_profile_text)}
                    )
                candidate_role_rows = candidate.get("model_roles_and_base_sizes", [])
                if not isinstance(candidate_role_rows, list):
                    candidate_role_rows = []
                candidate_model_roles = sorted({
                    str(item.get("name", "")).strip()
                    for item in candidate_role_rows
                    if isinstance(item, dict) and str(item.get("name", "")).strip()
                }, key=normalized)
                candidate_base_sizes = sorted({
                    str(item.get("base_size", "")).strip()
                    for item in candidate_role_rows
                    if isinstance(item, dict) and str(item.get("base_size", "")).strip()
                }, key=normalized)
                result.append({
                    "forceorg_save_sha256": family.get("forceorg_save_sha256", ""),
                    "forceorg_source_group_hints": family.get("forceorg_source_group_hints", ""),
                    "group_faction_scope": family.get("group_faction_scope", ""),
                    "model_family_hint": family.get("model_family_hint", ""),
                    "family_name_match_status": family.get("name_match_status", ""),
                    "family_top_lexical_score": family.get("top_lexical_score", ""),
                    "variant_key": str(variant.get("variant_key", "")),
                    "representative_label": label,
                    "variant_weapon_hints": "|".join(hints),
                    "recognized_legacy_weapon_label_terms": "|".join(legacy_names),
                    "asset_kind": str(variant.get("asset_kind", "")),
                    "asset_fingerprint": str(variant.get("asset_fingerprint", "")),
                    "existing_reviewed_model_role": str(variant.get("e11_model_role", "")),
                    "existing_reviewed_equipment_signature": str(variant.get("e11_equipment_signature", "")),
                    "existing_visual_mapping_status": str(variant.get("mapping_status", "")),
                    "tts_occurrence_count": str(variant.get("source_occurrence_count", "0")),
                    "candidate_review_order": str(rank if candidate_rows != [None] else 0),
                    "candidate_lexical_score": str(candidate.get("lexical_score", "")),
                    "candidate_datasheet_id": str(candidate.get("datasheet_id", "")),
                    "candidate_datasheet_name": str(candidate.get("datasheet_name", "")),
                    "candidate_datasheet_role": str(candidate.get("datasheet_role", "")),
                    "candidate_model_roles": "|".join(candidate_model_roles),
                    "candidate_base_size_values": "|".join(candidate_base_sizes),
                    "candidate_faction_id": str(candidate.get("faction_id", "")),
                    "candidate_faction_name": str(candidate.get("faction_name", "")),
                    "candidate_matches_group_faction_scope": str(candidate.get("matches_group_faction_scope", "")),
                    "candidate_source_id": str(candidate.get("source_id", "")),
                    "candidate_source_book": str(candidate.get("source_book", "")),
                    "candidate_source_edition": str(candidate.get("source_edition", "")),
                    "candidate_source_version": str(candidate.get("source_version", "")),
                    "visual_weapon_terms_present_in_candidate_source_text": weapon_status,
                    "visual_weapon_hints_found_in_candidate": json.dumps(hints_found, ensure_ascii=False),
                    "visual_weapon_hints_not_found_in_candidate": json.dumps(hints_absent, ensure_ascii=False),
                    "local_export_weapon_names_found_in_candidate": json.dumps(current_found, ensure_ascii=False),
                    "local_export_weapon_names_not_found_in_candidate": json.dumps(current_absent, ensure_ascii=False),
                    "review_authority": "unverified visual-to-datasheet candidate; source text presence is not loadout legality or sculpt confirmation",
                    "rules_snapshot_id": family.get("rules_snapshot_id", ""),
                    "rules_manifest_sha256": family.get("rules_manifest_sha256", ""),
                })
    return result


def build_runtime_visual_coverage(
    runtime_identity_data: dict[str, Any],
    crosswalk: list[dict[str, str]],
    datasheets: list[dict[str, Any]],
    manifest: dict[str, Any],
    manifest_hash: str,
    forceorg_save_hash: str,
) -> list[dict[str, str]]:
    """Summarize visual-candidate coverage for each current runtime profile identity."""
    datasheets_by_id = {str(sheet["datasheet_id"]): sheet for sheet in datasheets}
    profile_candidates: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for family in crosswalk:
        try:
            variants = json.loads(family.get("visual_variant_relationships", "[]"))
            candidates = json.loads(family.get("candidate_datasheets", "[]"))
        except json.JSONDecodeError as error:
            raise ValueError(f"Invalid runtime-coverage crosswalk JSON: {error}") from error
        if not isinstance(variants, list) or not isinstance(candidates, list):
            raise ValueError("Runtime-coverage relationships and candidates must be arrays.")
        representative_labels = sorted({
            str(item.get("representative_label", ""))
            for item in variants if isinstance(item, dict) and item.get("representative_label")
        })
        weapon_hints = sorted({
            hint
            for item in variants if isinstance(item, dict)
            for hint in str(item.get("visual_weapon_hints", "")).split("|") if hint
        })
        visual_variant_keys = sorted({
            str(item.get("variant_key", ""))
            for item in variants if isinstance(item, dict) and item.get("variant_key")
        })
        occurrence_count = sum(
            int(item.get("source_occurrence_count", "0") or 0)
            for item in variants if isinstance(item, dict)
        )
        for order, candidate in enumerate(candidates, start=1):
            if not isinstance(candidate, dict):
                continue
            for profile in candidate.get("runtime_profile_records", []):
                if not isinstance(profile, dict):
                    continue
                definition_id = str(profile.get("definition_id", ""))
                if not definition_id:
                    continue
                try:
                    score = float(candidate.get("lexical_score", 0.0))
                except (TypeError, ValueError):
                    score = 0.0
                profile_candidates[definition_id].append({
                    "candidate_review_order": order,
                    "candidate_lexical_score": score,
                    "candidate_matches_group_faction_scope": bool(candidate.get("matches_group_faction_scope", False)),
                    "source_group_hints": family.get("forceorg_source_group_hints", ""),
                    "group_faction_scope": family.get("group_faction_scope", ""),
                    "model_family_hint": family.get("model_family_hint", ""),
                    "family_name_match_status": family.get("name_match_status", ""),
                    "variant_count": len(visual_variant_keys),
                    "occurrence_count": occurrence_count,
                    "representative_labels": representative_labels,
                    "weapon_hints": weapon_hints,
                    "variant_keys": visual_variant_keys,
                })

    result: list[dict[str, str]] = []
    seen_ids: set[str] = set()
    for profile in runtime_identity_data.get("profiles", []):
        if not isinstance(profile, dict):
            continue
        definition_id = str(profile.get("definition_id", ""))
        if not definition_id or definition_id in seen_ids:
            continue
        seen_ids.add(definition_id)
        candidates = sorted(
            profile_candidates.get(definition_id, []),
            key=lambda item: (
                -float(item["candidate_lexical_score"]),
                not bool(item["candidate_matches_group_faction_scope"]),
                normalized(str(item["model_family_hint"])),
                normalized(str(item["source_group_hints"])),
            ),
        )
        exact_candidates = [item for item in candidates if float(item["candidate_lexical_score"]) == 1.0]
        listed_variant_keys = {
            key for item in candidates for key in item["variant_keys"]
        }
        listed_occurrences = sum(int(item["occurrence_count"]) for item in candidates)
        best_summaries = [{
            "review_order": item["candidate_review_order"],
            "lexical_score": round(float(item["candidate_lexical_score"]), 4),
            "matches_group_faction_scope": bool(item["candidate_matches_group_faction_scope"]),
            "source_group_hints": item["source_group_hints"],
            "model_family_hint": item["model_family_hint"],
            "name_match_status": item["family_name_match_status"],
            "variant_count": item["variant_count"],
            "occurrence_count": item["occurrence_count"],
            "representative_labels": item["representative_labels"][:8],
            "weapon_hints": item["weapon_hints"],
        } for item in candidates[:10]]
        datasheet = datasheets_by_id.get(str(profile.get("source_datasheet_id", "")), {})
        result.append({
            "definition_id": definition_id,
            "profile_identity": str(profile.get("profile_identity", "")),
            "profile_name": str(profile.get("profile_name", "")),
            "runtime_catalog": str(profile.get("runtime_catalog", "")),
            "source_datasheet_id": str(profile.get("source_datasheet_id", "")),
            "source_datasheet_name": str(datasheet.get("name", "")),
            "source_faction_name": str(datasheet.get("faction_name", "")),
            "source_book_id": str(profile.get("source_book_id", "")),
            "source_book": str(datasheet.get("source_name", "")),
            "listed_candidate_family_count": str(len(candidates)),
            "listed_visual_variant_count": str(len(listed_variant_keys)),
            "listed_tts_occurrence_count": str(listed_occurrences),
            "exact_lexical_candidate_family_count": str(len(exact_candidates)),
            "group_faction_matched_candidate_family_count": str(sum(bool(item["candidate_matches_group_faction_scope"]) for item in candidates)),
            "best_candidate_lexical_score": str(round(float(candidates[0]["candidate_lexical_score"]), 4)) if candidates else "",
            "coverage_status": (
                "no_name_candidate_in_this_save" if not candidates
                else "exact_lexical_candidate_requires_review" if exact_candidates
                else "candidate_only_requires_review"
            ),
            "best_visual_candidate_families": json.dumps(best_summaries, ensure_ascii=False, separators=(",", ":")),
            "forceorg_save_sha256": forceorg_save_hash,
            "rules_snapshot_id": str(manifest.get("snapshot_id", "")),
            "rules_manifest_sha256": manifest_hash,
            "review_authority": "profile-level visual inventory only; exact names and weapon labels do not certify sculpt identity or loadout legality",
        })
    if len(seen_ids) != int(runtime_identity_data.get("profile_count", len(seen_ids))):
        raise ValueError("Runtime identity export profile_count does not match unique definition IDs.")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--variants", type=Path, default=DEFAULT_VARIANTS)
    parser.add_argument("--snapshot", type=Path, default=DEFAULT_SNAPSHOT)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--runtime-identities", type=Path, default=DEFAULT_RUNTIME_IDENTITIES)
    parser.add_argument("--exceptions-output", type=Path, default=DEFAULT_EXCEPTIONS_OUTPUT)
    parser.add_argument("--duplicates-output", type=Path, default=DEFAULT_DUPLICATES_OUTPUT)
    parser.add_argument("--flat-crosswalk-output", type=Path, default=DEFAULT_FLAT_CROSSWALK_OUTPUT)
    parser.add_argument("--datasheet-profiles-output", type=Path, default=DEFAULT_DATASHEET_PROFILES_OUTPUT)
    parser.add_argument("--runtime-coverage-output", type=Path, default=DEFAULT_RUNTIME_COVERAGE_OUTPUT)
    args = parser.parse_args()

    output = args.output.resolve()
    ignored_root = (PROJECT_ROOT / ".tools").resolve()
    try:
        output.relative_to(ignored_root)
    except ValueError:
        raise SystemExit("Refusing to write derived third-party data outside the ignored .tools/ directory.")
    if output.suffix.lower() != ".csv":
        raise SystemExit("Output must be a CSV under .tools/.")
    exceptions_output = args.exceptions_output.resolve()
    try:
        exceptions_output.relative_to(ignored_root)
    except ValueError:
        raise SystemExit("Refusing to write source-edition exceptions outside the ignored .tools/ directory.")
    if exceptions_output.suffix.lower() != ".csv":
        raise SystemExit("Exception output must be a CSV under .tools/.")
    duplicates_output = args.duplicates_output.resolve()
    try:
        duplicates_output.relative_to(ignored_root)
    except ValueError:
        raise SystemExit("Duplicate-name audit must stay under the ignored .tools/ directory.")
    if duplicates_output.suffix.lower() != ".csv":
        raise SystemExit("Duplicate-name audit output must be a CSV under .tools/.")
    flat_crosswalk_output = args.flat_crosswalk_output.resolve()
    try:
        flat_crosswalk_output.relative_to(ignored_root)
    except ValueError:
        raise SystemExit("Flat visual crosswalk must stay under the ignored .tools/ directory.")
    if flat_crosswalk_output.suffix.lower() != ".csv":
        raise SystemExit("Flat visual crosswalk output must be a CSV under .tools/.")
    datasheet_profiles_output = args.datasheet_profiles_output.resolve()
    try:
        datasheet_profiles_output.relative_to(ignored_root)
    except ValueError:
        raise SystemExit("Current datasheet profiles must stay under the ignored .tools/ directory.")
    if datasheet_profiles_output.suffix.lower() != ".csv":
        raise SystemExit("Current datasheet profiles output must be a CSV under .tools/.")
    runtime_coverage_output = args.runtime_coverage_output.resolve()
    try:
        runtime_coverage_output.relative_to(ignored_root)
    except ValueError:
        raise SystemExit("Runtime profile coverage must stay under the ignored .tools/ directory.")
    if runtime_coverage_output.suffix.lower() != ".csv":
        raise SystemExit("Runtime profile coverage output must be a CSV under .tools/.")

    try:
        variant_rows = read_comma_csv(args.variants)
        manifest, source_hashes, tables = validate_snapshot(args.snapshot)
        manifest_hash = hashlib.sha256((args.snapshot / "manifest.json").read_bytes()).hexdigest()
        datasheets, out_of_edition = build_datasheets(tables)
        duplicate_name_rows = build_duplicate_name_audit(datasheets)
        runtime_identity_data = json.loads(args.runtime_identities.read_text(encoding="utf-8-sig"))
        runtime_profiles_by_datasheet: dict[str, list[dict[str, Any]]] = defaultdict(list)
        for profile in runtime_identity_data.get("profiles", []):
            runtime_profiles_by_datasheet[str(profile.get("source_datasheet_id", ""))].append(profile)
        faction_names = {row.get("name", "") for row in tables["Factions.csv"] if row.get("name")}
        crosswalk = build_crosswalk(variant_rows, datasheets, faction_names, manifest, source_hashes, manifest_hash, runtime_profiles_by_datasheet)
        flat_crosswalk_rows = build_flat_variant_candidates(crosswalk, datasheets)
        datasheet_profile_rows = build_datasheet_profile_rows(datasheets, manifest, source_hashes, manifest_hash)
        forceorg_hash = crosswalk[0].get("forceorg_save_sha256", "") if crosswalk else ""
        runtime_coverage_rows = build_runtime_visual_coverage(
            runtime_identity_data, crosswalk, datasheets, manifest, manifest_hash, forceorg_hash
        )
        exception_rows = build_non11_candidates(variant_rows, out_of_edition, datasheets)
        output.parent.mkdir(parents=True, exist_ok=True)
        columns = [
            "forceorg_save", "forceorg_save_sha256", "forceorg_source_group_hints", "group_faction_scope",
            "group_faction_scope_status", "model_family_hint", "visual_variant_group_count", "source_occurrence_count",
            "representative_labels", "visual_weapon_hint_signatures", "recognized_weapon_hints",
            "visual_variant_relationships",
            "local_export_weapon_name_mentions", "recognized_legacy_weapon_label_terms",
            "existing_reviewed_visual_roles", "existing_reviewed_equipment_signatures", "name_match_status",
            "top_lexical_score", "top_score_tie_count", "candidate_datasheet_count", "candidate_datasheets", "mapping_authority",
            "rules_edition", "rules_snapshot_id", "rules_export_updated_at", "rules_game_mode_scope",
            "rules_manifest_sha256", "datasheets_csv_sha256", "options_csv_sha256", "model_bases_csv_sha256",
            "runtime_profile_identity_export_count",
        ]
        with output.open("w", encoding="utf-8-sig", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=columns)
            writer.writeheader()
            runtime_count = int(runtime_identity_data.get("profile_count", 0))
            for row in crosswalk:
                row["runtime_profile_identity_export_count"] = str(runtime_count)
                writer.writerow(row)
        exceptions_output.parent.mkdir(parents=True, exist_ok=True)
        exception_columns = [
            "datasheet_id", "datasheet_name", "faction_name", "source_id", "source_book", "source_type",
            "source_edition", "source_version", "source_scope_disposition", "source_loadout", "source_options",
            "model_roles_and_base_sizes", "forceorg_model_family_candidates", "current_rules_mapping_authority",
        ]
        with exceptions_output.open("w", encoding="utf-8-sig", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=exception_columns)
            writer.writeheader()
            writer.writerows(exception_rows)
        duplicate_columns = [
            "datasheet_name", "duplicate_group_record_count", "datasheet_id", "duplicate_group_datasheet_ids",
            "group_profile_signature_count", "group_assessment", "differing_profile_fields", "group_base_sizes_differ",
            "group_base_size_values", "faction_id",
            "faction_name", "source_id", "source_book", "source_edition", "source_version", "datasheet_role",
            "source_loadout", "source_options", "source_composition", "model_roles_and_base_sizes", "wargear_names",
            "virtual_flag", "support_flag", "comparison_scope",
        ]
        duplicates_output.parent.mkdir(parents=True, exist_ok=True)
        with duplicates_output.open("w", encoding="utf-8-sig", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=duplicate_columns)
            writer.writeheader()
            writer.writerows(duplicate_name_rows)
        flat_crosswalk_output.parent.mkdir(parents=True, exist_ok=True)
        flat_columns = list(flat_crosswalk_rows[0]) if flat_crosswalk_rows else [
            "forceorg_save_sha256", "variant_key", "representative_label", "candidate_datasheet_id",
        ]
        with flat_crosswalk_output.open("w", encoding="utf-8-sig", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=flat_columns)
            writer.writeheader()
            writer.writerows(flat_crosswalk_rows)
        datasheet_profiles_output.parent.mkdir(parents=True, exist_ok=True)
        profile_columns = list(datasheet_profile_rows[0]) if datasheet_profile_rows else ["datasheet_id", "datasheet_name"]
        with datasheet_profiles_output.open("w", encoding="utf-8-sig", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=profile_columns)
            writer.writeheader()
            writer.writerows(datasheet_profile_rows)
        runtime_coverage_output.parent.mkdir(parents=True, exist_ok=True)
        coverage_columns = list(runtime_coverage_rows[0]) if runtime_coverage_rows else ["definition_id", "profile_name"]
        with runtime_coverage_output.open("w", encoding="utf-8-sig", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=coverage_columns)
            writer.writeheader()
            writer.writerows(runtime_coverage_rows)
    except (OSError, ValueError, KeyError, json.JSONDecodeError, csv.Error) as error:
        print(f"Could not build ForceOrg datasheet review: {error}", file=sys.stderr)
        return 1

    unmatched = sum(row["name_match_status"] == "unmatched_no_name_overlap" for row in crosswalk)
    exact = sum(row["name_match_status"] == "unique_exact_name_or_role_candidate_review_required" for row in crosswalk)
    print(f"Wrote {len(crosswalk)} model-family review rows to {output}")
    print(f"Retained {len(exception_rows)} non-11e or provenance-incomplete datasheets separately in {exceptions_output}")
    duplicate_groups = len({row["datasheet_name"] for row in duplicate_name_rows})
    differing_groups = len({row["datasheet_name"] for row in duplicate_name_rows if row["group_profile_signature_count"] != "1"})
    print(f"Wrote {len(duplicate_name_rows)} records from {duplicate_groups} repeated exact names ({differing_groups} with differing compared profile fields) to {duplicates_output}")
    print(f"Wrote {len(flat_crosswalk_rows)} per-variant/datasheet candidate rows to {flat_crosswalk_output}")
    print(f"Wrote {len(datasheet_profile_rows)} full 11e datasheet lookup profiles to {datasheet_profiles_output}")
    unmatched_runtime = sum(row["coverage_status"] == "no_name_candidate_in_this_save" for row in runtime_coverage_rows)
    exact_runtime = sum(row["coverage_status"] == "exact_lexical_candidate_requires_review" for row in runtime_coverage_rows)
    print(f"Wrote {len(runtime_coverage_rows)} runtime profile coverage rows ({exact_runtime} with exact lexical candidates; {unmatched_runtime} without name candidates) to {runtime_coverage_output}")
    print(f"Datasheets in edition-11 snapshot: {len(datasheets)}; families without name overlap: {unmatched}; unique exact lexical candidates: {exact}")
    print(f"Snapshot: {manifest['snapshot_id']} (edition {manifest['edition']}, {manifest.get('source_export_updated_at', '')})")
    print(f"ForceOrg save SHA-256: {crosswalk[0]['forceorg_save_sha256'] if crosswalk else 'no rows'}")
    print(f"Wahapedia manifest SHA-256: {hashlib.sha256((args.snapshot / 'manifest.json').read_bytes()).hexdigest()}")
    print(f"Runtime profile identities indexed: {runtime_identity_data.get('profile_count', 0)}")
    print(f"Source-edition exceptions by value: {dict(Counter(str(row['source_edition']) or 'unknown' for row in out_of_edition))}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
