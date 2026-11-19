#!/usr/bin/env python3
"""Build/query a local model database; visual names never grant rules options."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
from collections import Counter

from build_forceorg_model_weapon_catalog import (
    EXPECTED_RULES_MANIFEST, EXPECTED_RULES_SNAPSHOT, ensure_outputs_are_local,
    read_csv, require_rules_provenance,
)
from build_forceorg_datasheet_review import build_wargear_pattern, local_weapon_mentions

ROOT = Path(__file__).resolve().parents[1]


def normalized(value: str) -> str:
    return " ".join(re.sub(r"[^\w]+", " ", value.casefold()).split())


def terms(value: str) -> list[str]:
    return sorted({normalized(item).replace(" ", "-") for item in value.split("|") if item.strip()})


def relation_in_scope(row: dict) -> bool:
    # CSV writers in this pipeline emit both Python 'True' and lowercase 'true'.
    # Preserve the raw evidence and normalize only the derived decision.
    return not row.get("group_faction_scope") or str(row.get("candidate_matches_group_faction_scope", "")).strip().casefold() == "true"


def visual_weapons(row: dict, pattern: re.Pattern | None) -> list[str]:
    """Use the complete selected export vocabulary, plus existing abbreviations.

    These are label claims. Recognizing a weapon does not validate a combination.
    Historical labels stay distinct rather than inventing current equivalents.
    """
    current, legacy = local_weapon_mentions(row["representative_label"], pattern)
    return sorted(set(terms(row.get("visual_weapon_hints", ""))) |
                  {normalized(item).replace(" ", "-") for item in current + legacy})


def source_weapon_aliases(hints: list[str], source_names: list[str]) -> dict[str, str]:
    """Expand a short visual term only to a unique weapon on the same sheet."""
    physical = {normalized(re.split(r"\s+[–—-]\s+", name, maxsplit=1)[0]).replace(" ", "-") for name in source_names}
    aliases = {}
    for hint in hints:
        term = normalized(hint).replace(" ", "-")
        words = set(term.split("-"))
        if term in physical or len(words) < 2:
            continue
        matches = [name for name in physical if words <= set(name.split("-"))]
        if len(matches) == 1:
            aliases[term] = matches[0]
    return aliases


def role_tokens(value: str) -> set[str]:
    words = normalized(value).split()
    return {("sergeant" if w == "sgt" else w[:-1] if len(w) > 4 and w.endswith("s") else w)
            for w in words if w not in {"with", "and", "the", "of"}}


def abbreviated_label_weapon(label: str, model_names: list[str], source_names: list[str]) -> tuple[str, str] | None:
    """Resolve a complete model-name prefix followed by one unique weapon suffix.

    This is label evidence, not sculpt certification. Unknown modifiers, historic
    prefixes and ambiguous suffixes are deliberately retained as unresolved.
    """
    def words(value: str) -> list[str]:
        # Retain conjunctions: "Chariot of Tzeentch" is an extended identity,
        # not evidence for a weapon whose name happens to end in "Tzeentch".
        return [next(iter(role_tokens(w)), w) for w in normalized(value).split()]

    label_words = words(label)
    prefixes = [words(name) for name in model_names if words(name)]
    prefixes = [p for p in prefixes if label_words[:len(p)] == p and len(label_words) > len(p)]
    if not prefixes:
        return None
    longest = max(map(len, prefixes))
    suffix = label_words[longest:]
    if suffix[0] == "with":
        suffix = suffix[1:]
    if not suffix or suffix[0] in {"of", "and", "the"}:
        return None
    physical = {normalized(re.split(r"\s+[–—-]\s+", name, maxsplit=1)[0]).replace(" ", "-")
                for name in source_names}
    matches = [name for name in physical if len(words(name)) >= len(suffix)
               and words(name)[-len(suffix):] == suffix]
    if len(matches) != 1:
        return None
    return matches[0], " ".join(suffix)


def model_role_links(label: str, source_models: list[dict], explicit_role: str = "") -> tuple[str, list[str]]:
    """Identify a member of a mixed datasheet without guessing a tied role."""
    if explicit_role:
        return "explicit_role", [explicit_role]
    names = sorted({r["name"] for r in source_models if r.get("name")})
    if len(names) <= 1:
        return "single_model_role", []
    label_words = role_tokens(label)
    matches = [(len(role_tokens(name)), name) for name in names
               if role_tokens(name) and role_tokens(name) <= label_words]
    if not matches:
        return "unresolved_model_role", []
    most_specific = max(size for size, _ in matches)
    roles = sorted(name for size, name in matches if size == most_specific)
    return ("label_model_role" if len(roles) == 1 else "ambiguous_model_role"), roles


def literal_profile_index(profiles: list[dict]) -> dict[str, list[dict]]:
    """Index complete source names; permitted suffixes come from that sheet only."""
    result: dict[str, list[dict]] = {}
    for row in profiles:
        name = role_tokens(row["datasheet_name"])
        allowed = set().union(*(role_tokens(w) for w in json.loads(row["wargear_profiles"])))
        allowed.update(set().union(*(role_tokens(m["name"]) for m in json.loads(row["model_roles_and_base_sizes"]))))
        allowed.update(set().union(*(role_tokens(c) for c in json.loads(row.get("unit_composition", "[]")))))
        entry = {"id": row["datasheet_id"], "faction": row["faction_name"], "name": name, "suffix": allowed}
        for word in name:
            result.setdefault(word, []).append(entry)
    return result


def literal_profile_matches(row: dict, index: dict[str, list[dict]]) -> list[str]:
    label = {w for w in role_tokens(row["representative_label"]) if not w.isdigit()}
    group = role_tokens(row.get("source_group_hints", ""))
    found: set[str] = set()
    for word in label:
        for profile in index.get(word, []):
            if row.get("group_faction_scope") and row["group_faction_scope"] != profile["faction"]:
                continue
            # Do not erase words which are part of the target's identity.
            cleaned = label - ((group | {"primaris"}) - profile["name"])
            if profile["name"] <= cleaned and cleaned - profile["name"] <= profile["suffix"]:
                found.add(profile["id"])
    return sorted(found)


def occurrence_inventory(paths: list[Path], source_hashes: set[str]) -> dict[tuple[str, str], dict]:
    result: dict[tuple[str, str], dict] = {}
    for path in paths:
        rows = read_csv(path)
        hashes = {r.get("save_sha256", "") for r in rows}
        if len(hashes) != 1 or not hashes <= source_hashes:
            raise ValueError("Detailed visual inventory belongs to another source save")
        for row in rows:
            key = (row["save_sha256"], row["tts_path"])
            if key in result:
                raise ValueError("Duplicate source path in detailed visual inventories")
            result[key] = row
    return result


def classify(row: dict) -> tuple[str, str]:
    """Conservative label classification, with evidence retained for correction."""
    # Pose/mount notes must not turn a named miniature into scenery (e.g.
    # "Kayvaan Shrike (without tactical wall)"). Preserve the original label.
    label = normalized(re.sub(r"\([^)]*\)", "", row["representative_label"]))
    paths = json.loads(row.get("source_occurrences") or "[]")
    if paths and all("/ChildObjects/" in item["tts_path"] for item in paths):
        return "component", "all source occurrences are child parts"
    if re.search(r"\b(card|cards|token|tokens|totem|totems|dice|counter|counters)\b", label):
        return "ignored", "accessory label"
    if re.fullmatch(r"(?:\d+\s*(?:mm|inch)\s*)?(?:round |oval )?base(?: \d+)?", label) or re.fullmatch(r"\d+(?:\s*x\s*\d+)?\s*mm", label):
        return "base", "standalone base label"
    if re.search(r"\b(terrain|ruins?|barricades?|craters?|buildings?|walls?)\b", label):
        return "terrain", "terrain label; not inferred from a datasheet name"
    return "miniature", "source model label; completeness remains subject to asset import"


def object_inventory(
    paths: list[Path], source_hashes: set[str], allow_additional_sources: bool = False,
) -> dict[tuple[str, str], dict]:
    result = {}
    seen_sources = set()
    for path in paths:
        payload = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(payload, dict):
            raise ValueError("Object inventory must be a JSON object")
        source = payload.get("source_sha256")
        objects = payload.get("objects")
        source_is_known = isinstance(source, str) and source in source_hashes
        source_is_valid_additional = (
            allow_additional_sources and isinstance(source, str)
            and re.fullmatch(r"[0-9a-f]{64}", source) is not None
        )
        if (payload.get("schema_version") != 1 or not isinstance(source, str)
                or (not source_is_known and not source_is_valid_additional) or source in seen_sources):
            raise ValueError("Object inventory has an unsupported schema, duplicate or unknown source")
        if payload.get("warnings") != [] or not isinstance(objects, list) or len(objects) != payload.get("scanned_object_count"):
            raise ValueError("Object inventory is incomplete or has scanner warnings")
        seen_sources.add(source)
        local = {}
        for row in objects:
            if not isinstance(row, dict) or any(not isinstance(row.get(k), str) for k in ["path", "parent_path", "guid", "label", "source_label", "tts_type"]):
                raise ValueError("Invalid source object fields")
            if not isinstance(row.get("asset_kinds"), list) or any(not isinstance(k, str) for k in row["asset_kinds"]):
                raise ValueError("Invalid source object asset kinds")
            if row["path"] in local:
                raise ValueError("Duplicate source object path")
            local[row["path"]] = row
        for key, row in local.items():
            parent = row["parent_path"]
            if (parent and (parent not in local or not key.startswith(parent + "/"))) or (not parent and not re.fullmatch(r"ObjectStates/\d+", key)):
                raise ValueError("Invalid or missing source object parent")
            result[source, key] = row
    if paths and not source_hashes.issubset(seen_sources):
        raise ValueError("Object inventories must cover every selected source")
    if paths and not allow_additional_sources and seen_sources != source_hashes:
        raise ValueError("Object inventories include an unselected source")
    return result


def classify_source_object(row: dict, visual_category: str = "") -> tuple[str, str]:
    kind = row["tts_type"]
    label = normalized(row["label"])
    if kind in {"Card", "CardCustom", "Deck", "DeckCustom", "Notecard", "Custom_Token", "Custom_Dice", "Dice", "3DText", "HandTrigger", "reversi_chip"} or kind.startswith("go_game_piece_"):
        return "ignored", "TTS accessory/interface type"
    if kind in {"Bag", "Infinite_Bag", "Custom_Model_Bag", "Custom_Model_Infinite_Bag"}:
        return "container", "TTS container type; contents indexed separately"
    if re.search(r"\b(?:dropdown|model searcher)\b|find model by guid|cleanerblock", label):
        return "ignored", "TTS board search/control utility"
    if kind == "BlockSquare" and label == "yellow machine":
        return "ignored", "reviewed ForceOrg scripted model utility label"
    category, evidence = classify({"representative_label": row["label"], "source_occurrences": json.dumps([{"tts_path": row["path"]}])})
    if category != "miniature":
        return category, evidence
    if visual_category:
        return visual_category, "existing visual-catalog category"
    asset_kinds = set(row.get("asset_kinds", []))
    if kind == "Custom_Tile" and "CustomImage" in asset_kinds and not asset_kinds & {"CustomMesh", "CustomAssetbundle"}:
        return "ignored", "image-only tile has no supported 3D model reference"
    return "unclassified", "no visual-catalog association or explicit category evidence"


SCHEMA = """
PRAGMA foreign_keys=ON;
CREATE TABLE metadata(key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE TABLE variants(
 id TEXT PRIMARY KEY, source_sha256 TEXT NOT NULL, variant_key TEXT NOT NULL,
 fingerprint TEXT NOT NULL, label TEXT NOT NULL, search_name TEXT NOT NULL,
 category TEXT NOT NULL, category_evidence TEXT NOT NULL, model_role TEXT NOT NULL,
 source_group TEXT NOT NULL, asset_kind TEXT NOT NULL, provenance TEXT NOT NULL,
 UNIQUE(source_sha256,variant_key));
CREATE INDEX variant_fingerprint ON variants(fingerprint);
CREATE INDEX variant_category ON variants(category,search_name);
CREATE TABLE occurrences(variant_id TEXT REFERENCES variants(id), path TEXT NOT NULL,
 guid TEXT NOT NULL, state_key TEXT NOT NULL, source_group TEXT NOT NULL, label TEXT NOT NULL,
 PRIMARY KEY(variant_id,path));
CREATE TABLE weapons(variant_id TEXT REFERENCES variants(id), weapon TEXT NOT NULL,
 PRIMARY KEY(variant_id,weapon));
CREATE INDEX weapon_lookup ON weapons(weapon,variant_id);
CREATE TABLE datasheets(id TEXT PRIMARY KEY, name TEXT NOT NULL, faction TEXT NOT NULL,
 role TEXT NOT NULL, source_book TEXT NOT NULL, source_version TEXT NOT NULL,
 is_character INTEGER NOT NULL, provenance TEXT NOT NULL);
CREATE TABLE links(variant_id TEXT REFERENCES variants(id), datasheet_id TEXT REFERENCES datasheets(id),
 score REAL NOT NULL, faction_match TEXT NOT NULL, status TEXT NOT NULL,
 PRIMARY KEY(variant_id,datasheet_id));
CREATE INDEX datasheet_lookup ON links(datasheet_id,status,variant_id);
CREATE TABLE model_role_links(variant_id TEXT NOT NULL, datasheet_id TEXT NOT NULL,
 model_role TEXT NOT NULL, status TEXT NOT NULL,
 FOREIGN KEY(variant_id,datasheet_id) REFERENCES links(variant_id,datasheet_id) ON DELETE CASCADE,
 PRIMARY KEY(variant_id,datasheet_id,model_role));
CREATE TABLE runtime_profiles(definition_id TEXT PRIMARY KEY, datasheet_id TEXT REFERENCES datasheets(id));
CREATE TABLE fallback_links(variant_id TEXT REFERENCES variants(id), datasheet_id TEXT REFERENCES datasheets(id),
 authority_sha256 TEXT NOT NULL, source_label TEXT NOT NULL, PRIMARY KEY(variant_id,datasheet_id));
CREATE INDEX fallback_datasheet_lookup ON fallback_links(datasheet_id,variant_id);
CREATE TABLE weapon_aliases(datasheet_id TEXT REFERENCES datasheets(id), visual_term TEXT NOT NULL,
 physical_term TEXT NOT NULL, evidence TEXT NOT NULL, PRIMARY KEY(datasheet_id,visual_term));
CREATE TABLE weapon_label_resolutions(variant_id TEXT NOT NULL, datasheet_id TEXT NOT NULL,
 weapon TEXT NOT NULL, label_suffix TEXT NOT NULL, evidence TEXT NOT NULL,
 FOREIGN KEY(variant_id,datasheet_id) REFERENCES links(variant_id,datasheet_id) ON DELETE CASCADE,
 PRIMARY KEY(variant_id,datasheet_id,weapon));
CREATE TABLE source_objects(source_sha256 TEXT NOT NULL, path TEXT NOT NULL,
 parent_path TEXT, guid TEXT NOT NULL, label TEXT NOT NULL, source_label TEXT NOT NULL,
 search_name TEXT NOT NULL, tts_type TEXT NOT NULL, category TEXT NOT NULL,
 category_evidence TEXT NOT NULL, asset_kinds TEXT NOT NULL,
 PRIMARY KEY(source_sha256,path),
 FOREIGN KEY(source_sha256,parent_path) REFERENCES source_objects(source_sha256,path) DEFERRABLE INITIALLY DEFERRED);
CREATE INDEX source_object_category ON source_objects(category,search_name);
CREATE INDEX source_object_parent ON source_objects(parent_path,source_sha256);
"""


def build(args: argparse.Namespace) -> dict:
    ensure_outputs_are_local([args.database])
    rows = read_csv(args.catalog)
    if not rows or "candidate_count" not in rows[0] or not any(r["candidate_datasheet_id"] for r in rows):
        raise ValueError("Catalog has no consolidated candidate links; rebuild it with the source relations first")
    require_rules_provenance(rows, "consolidated catalog")
    source_hashes = {r["source_sha256"] for r in rows}
    detailed = occurrence_inventory(args.visual_inventory, source_hashes)
    object_inventory_paths = [*args.object_inventory, *args.object_only_inventory]
    objects = object_inventory(args.object_inventory, source_hashes)
    object_only = object_inventory(args.object_only_inventory, set(), allow_additional_sources=True)
    regular_object_sources = {source for source, _path in objects}
    object_only_sources = {source for source, _path in object_only}
    if regular_object_sources & object_only_sources or source_hashes & object_only_sources:
        raise ValueError("Object-only inventories must use additional, non-duplicate source saves")
    objects.update(object_only)
    used_occurrences: set[tuple[str, str]] = set()
    profiles = read_csv(args.datasheets)
    require_rules_provenance(profiles, "datasheet profiles")
    if not profiles or any(r.get("rules_snapshot_id") != EXPECTED_RULES_SNAPSHOT or
                           r.get("rules_manifest_sha256") != EXPECTED_RULES_MANIFEST or
                           r.get("source_edition") != "11" for r in profiles):
        raise ValueError("Datasheet profiles must all belong to the selected verified edition-11 snapshot")
    sheet_ids = {r["datasheet_id"] for r in profiles}
    source_models = {r["datasheet_id"]: json.loads(r["model_roles_and_base_sizes"]) for r in profiles}
    literal_names = literal_profile_index(profiles)
    weapon_pattern = build_wargear_pattern([
        {"wargear_names": json.loads(r["wargear_profiles"])} for r in profiles
    ])
    corrections = json.loads(args.corrections.read_text(encoding="utf-8")) if args.corrections else {}
    if not isinstance(corrections, dict) or any(not isinstance(value, dict) for value in corrections.values()):
        raise ValueError("Corrections must be an object keyed by asset fingerprint")
    known_fingerprints = {r["asset_fingerprint"] for r in rows}
    if set(corrections) - known_fingerprints:
        raise ValueError("Correction refers to an unknown asset fingerprint")
    args.database.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.database.with_name(args.database.name + ".building")
    if temporary.exists():
        temporary.unlink()
    db = sqlite3.connect(temporary)
    try:
        db.executescript(SCHEMA)
        for r in profiles:
            role = r["datasheet_role"]
            db.execute("INSERT INTO datasheets VALUES(?,?,?,?,?,?,?,?)", (
                r["datasheet_id"], r["datasheet_name"], r["faction_name"], role,
                r["source_book"], r["source_version"], int("Character" in role or "Epic Hero" in role), json.dumps(r)))
        source_variants: dict[tuple[str, str], str] = {}
        variant_labels: dict[str, tuple[str, str]] = {}
        miniature_labels: dict[str, list[str]] = {}
        categories: Counter = Counter()
        for r in rows:
            source_key = (r["source_sha256"], r["variant_key"])
            identity = hashlib.sha256(":".join(source_key).encode()).hexdigest()
            if source_key in source_variants:
                raise ValueError(f"Duplicate source variant: {source_key}")
            source_variants[source_key] = identity
            category, evidence = classify(r)
            correction = corrections.get(r["asset_fingerprint"], {})
            if set(correction) - {"category", "model_role", "weapons", "datasheet_ids", "note"}:
                raise ValueError("Unknown correction field")
            category = correction.get("category", category)
            if category not in {"miniature", "terrain", "component", "base", "ignored"}:
                raise ValueError("Invalid category correction")
            role = correction.get("model_role", "sergeant" if re.search(r"\b(sgt|sergeant)\b", normalized(r["representative_label"])) else "")
            if not isinstance(role, str):
                raise ValueError("Model role corrections must be strings")
            variant_labels[identity] = (r["representative_label"], role)
            categories[category] += 1
            if category == "miniature":
                miniature_labels.setdefault(r["representative_label"].strip().casefold(), []).append(identity)
            db.execute("INSERT INTO variants VALUES(?,?,?,?,?,?,?,?,?,?,?,?)", (
                identity, *source_key, r["asset_fingerprint"], r["representative_label"],
                normalized(r["representative_label"]), category,
                correction.get("note", "user correction") if correction else evidence, role,
                r["source_group_hints"], r["asset_kind"], json.dumps(r)))
            for occurrence in json.loads(r.get("source_occurrences") or "[]"):
                key = (r["source_sha256"], occurrence["tts_path"])
                original = detailed.get(key)
                label = occurrence.get("label", r["representative_label"])
                if args.visual_inventory:
                    if not original or original["guid"] != occurrence.get("guid", "") or original["asset_fingerprint"] != r["asset_fingerprint"]:
                        raise ValueError("Detailed occurrence identity/fingerprint does not match the variant catalog")
                    label = original["variant_label"]
                    used_occurrences.add(key)
                db.execute("INSERT INTO occurrences VALUES(?,?,?,?,?,?)", (
                    identity, occurrence["tts_path"], occurrence.get("guid", ""),
                    occurrence.get("state_key", ""), occurrence.get("source_group_hint", ""), label))
            weapons = correction.get("weapons", visual_weapons(r, weapon_pattern))
            if not isinstance(weapons, list) or any(not isinstance(w, str) or not w.strip() for w in weapons):
                raise ValueError("Weapon corrections must be a list of nonempty names")
            for weapon in sorted({normalized(w).replace(" ", "-") for w in weapons}):
                db.execute("INSERT INTO weapons VALUES(?,?)", (identity, weapon))
        if detailed and used_occurrences != set(detailed):
            raise ValueError("Detailed inventory includes source occurrences missing from the variant catalog")
        if objects:
            visual_categories = {}
            for source, path, label, guid, category in db.execute("""SELECT v.source_sha256,o.path,o.label,o.guid,v.category
                FROM occurrences o JOIN variants v ON v.id=o.variant_id"""):
                record = objects.get((source, path))
                if not record or record["label"] != label or record["guid"] != guid:
                    raise ValueError("Object inventory does not cover an exact visual occurrence")
                visual_categories[source, path] = category
            for (source, path), record in objects.items():
                category, evidence = classify_source_object(record, visual_categories.get((source, path), ""))
                db.execute("INSERT INTO source_objects VALUES(?,?,?,?,?,?,?,?,?,?,?)", (
                    source, path, record["parent_path"] or None, record["guid"], record["label"],
                    record["source_label"], normalized(record["label"]), record["tts_type"], category,
                    evidence, json.dumps(record["asset_kinds"])))
        seen_sources: set[str] = set()
        for path in args.relations:
            relations = read_csv(path)
            require_rules_provenance(relations, str(path))
            hashes = {r["forceorg_save_sha256"] for r in relations}
            if len(hashes) != 1 or hashes & seen_sources:
                raise ValueError("Each relation input must cover a different single source save")
            seen_sources.update(hashes)
            covered: set[str] = set()
            for r in relations:
                key = (r["forceorg_save_sha256"], r["variant_key"])
                if key not in source_variants:
                    raise ValueError("Relation belongs to a variant/source absent from the catalog")
                identity = source_variants[key]
                covered.add(identity)
                if not r["candidate_datasheet_id"]:
                    continue
                score = float(r["candidate_lexical_score"])
                in_scope = relation_in_scope(r)
                status = "label_association" if score == 1.0 and in_scope else "candidate"
                db.execute("INSERT INTO links VALUES(?,?,?,?,?)", (
                    identity, r["candidate_datasheet_id"], score,
                    r["candidate_matches_group_faction_scope"], status))
            expected = {v for (h, _), v in source_variants.items() if h in hashes}
            if covered != expected:
                raise ValueError("Relation input does not cover every variant of its source")
        if seen_sources != {r["source_sha256"] for r in rows}:
            raise ValueError("Missing relations for a catalog source")
        for row in rows:
            identity = source_variants[row["source_sha256"], row["variant_key"]]
            if db.execute("SELECT category FROM variants WHERE id=?", (identity,)).fetchone()[0] != "miniature":
                continue
            for sheet_id in literal_profile_matches(row, literal_names):
                previous = db.execute("SELECT status FROM links WHERE variant_id=? AND datasheet_id=?", (identity, sheet_id)).fetchone()
                if previous is None:
                    db.execute("INSERT INTO links VALUES(?,?,1,'','literal_label_association')", (identity, sheet_id))
                elif previous[0] == "candidate":
                    # Preserve the original family score. The full source name
                    # supplies separate, stronger identity evidence.
                    db.execute("UPDATE links SET status='literal_label_association' WHERE variant_id=? AND datasheet_id=?", (identity, sheet_id))
        for fingerprint, correction in corrections.items():
            if "datasheet_ids" not in correction:
                continue
            ids = correction["datasheet_ids"]
            if not isinstance(ids, list) or set(ids) - sheet_ids:
                raise ValueError("Correction refers to an unknown current datasheet ID")
            for (identity,) in db.execute("SELECT id FROM variants WHERE fingerprint=?", (fingerprint,)).fetchall():
                db.execute("DELETE FROM links WHERE variant_id=?", (identity,))
                for sheet_id in sorted(set(ids)):
                    db.execute("INSERT INTO links VALUES(?,?,1,'','user_association')", (identity, sheet_id))
        for identity, sheet_id in db.execute("SELECT variant_id,datasheet_id FROM links").fetchall():
            label, explicit_role = variant_labels[identity]
            role_status, roles = model_role_links(label, source_models[sheet_id], explicit_role)
            for role in roles or [""]:
                db.execute("INSERT INTO model_role_links VALUES(?,?,?,?)", (identity, sheet_id, role, role_status))
        profiles_by_id = {p["datasheet_id"]: p for p in profiles}
        for identity, label, fingerprint in db.execute("""SELECT v.id,v.label,v.fingerprint FROM variants v
            WHERE v.category='miniature' AND NOT EXISTS(SELECT 1 FROM weapons w WHERE w.variant_id=v.id)""").fetchall():
            if "weapons" in corrections.get(fingerprint, {}):
                continue
            sheets = [r[0] for r in db.execute("""SELECT datasheet_id FROM links WHERE variant_id=?
                AND status IN ('label_association','literal_label_association','user_association')""", (identity,))]
            resolutions = []
            for sheet_id in sheets:
                profile = profiles_by_id[sheet_id]
                names = [profile["datasheet_name"]] + [m["name"] for m in source_models[sheet_id]]
                resolution = abbreviated_label_weapon(label, names, json.loads(profile["wargear_profiles"]))
                if resolution:
                    resolutions.append((sheet_id, *resolution))
            # A global visual term must agree across every admitted association.
            if not sheets or len(resolutions) != len(sheets) or len({r[1] for r in resolutions}) != 1:
                continue
            db.execute("INSERT INTO weapons VALUES(?,?)", (identity, resolutions[0][1]))
            for sheet_id, weapon, suffix in resolutions:
                db.execute("INSERT INTO weapon_label_resolutions VALUES(?,?,?,?,?)",
                           (identity, sheet_id, weapon, suffix, "unique_source_weapon_suffix_after_model_name"))
        for profile in profiles:
            sheet_id = profile["datasheet_id"]
            hints = [r[0] for r in db.execute("""SELECT DISTINCT w.weapon FROM weapons w JOIN links l ON l.variant_id=w.variant_id
                WHERE l.datasheet_id=? AND l.status IN ('label_association','literal_label_association','user_association')""", (sheet_id,))]
            for visual, physical in source_weapon_aliases(hints, json.loads(profile["wargear_profiles"])).items():
                db.execute("INSERT INTO weapon_aliases VALUES(?,?,?,'unique_weapon_in_selected_source_sheet')", (sheet_id, visual, physical))
        runtime = json.loads(args.runtime_profiles.read_text(encoding="utf-8"))
        alias_hash = runtime.get("visual_alias_registry_sha256", "")
        if alias_hash and alias_hash != hashlib.sha256((ROOT / "scripts/forceorg_matcher.gd").read_bytes()).hexdigest():
            raise ValueError("Visual alias registry changed; re-export current runtime identities before building")
        for r in runtime["profiles"]:
            if r["source_datasheet_id"] not in sheet_ids:
                raise ValueError("Runtime identity absent from the selected rules snapshot")
            db.execute("INSERT INTO runtime_profiles VALUES(?,?)", (r["definition_id"], r["source_datasheet_id"]))
            labels = r.get("visual_fallback_labels", [])
            if labels and not alias_hash:
                raise ValueError("Visual fallback labels require a hash-verified runtime alias registry")
            if not isinstance(labels, list) or any(not isinstance(label, str) or not label.strip() for label in labels):
                raise ValueError("Visual fallback labels must be a list of nonempty source names")
            for label in labels:
                for identity in miniature_labels.get(label.strip().casefold(), []):
                    db.execute("INSERT OR IGNORE INTO fallback_links VALUES(?,?,?,?)", (identity, r["source_datasheet_id"], alias_hash, label))
        metadata = {"schema_version": 8, "rules_snapshot_id": EXPECTED_RULES_SNAPSHOT,
                    "rules_manifest_sha256": EXPECTED_RULES_MANIFEST,
                    "categories": dict(categories), "variants": len(rows),
                    "association_policy": "ForceOrg labels; not visual certification or rules admission"}
        metadata["visual_alias_registry_sha256"] = alias_hash or None
        metadata["occurrence_labels"] = "verified_detailed_inventory" if detailed else "exported_or_representative_label"
        metadata["source_object_count"] = len(objects)
        metadata["object_only_source_hashes"] = sorted(object_only_sources)
        inputs = [args.catalog, args.datasheets, args.runtime_profiles, *args.relations,
                  *args.visual_inventory, *object_inventory_paths]
        if args.corrections:
            inputs.append(args.corrections)
        for path in inputs:
            metadata.setdefault("inputs", {})[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
        for key, value in metadata.items():
            db.execute("INSERT INTO metadata VALUES(?,?)", (key, json.dumps(value)))
        db.commit()
        if db.execute("PRAGMA integrity_check").fetchone()[0] != "ok" or db.execute("PRAGMA foreign_key_check").fetchall():
            raise ValueError("Generated database failed integrity checks")
        metadata["links"] = db.execute("SELECT count(*) FROM links").fetchone()[0]
        db.close()
        os.replace(temporary, args.database)
        return metadata
    except BaseException:
        db.close()
        temporary.unlink(missing_ok=True)
        raise


def search(args: argparse.Namespace) -> list[dict]:
    db = sqlite3.connect(args.database.resolve().as_uri() + "?mode=ro", uri=True)
    try:
        db.row_factory = sqlite3.Row
        datasheet_role = getattr(args, "datasheet_role", "")
        conditions, values = [], []
        if args.name:
            conditions.append("v.search_name LIKE ? ESCAPE '\\'")
            escaped = normalized(args.name).replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
            values.append("%" + escaped + "%")
        conditions.append("v.category=?")
        values.append(args.category)
        if args.datasheet:
            conditions.append("(EXISTS(SELECT 1 FROM links l WHERE l.variant_id=v.id AND l.datasheet_id=?) OR EXISTS(SELECT 1 FROM fallback_links f WHERE f.variant_id=v.id AND f.datasheet_id=?))")
            values.extend([args.datasheet, args.datasheet])
        if args.weapon:
            conditions.append("EXISTS(SELECT 1 FROM weapons w WHERE w.variant_id=v.id AND w.weapon=?)")
            values.append(normalized(args.weapon).replace(" ", "-"))
        if args.model_role:
            role_filter = "EXISTS(SELECT 1 FROM model_role_links m WHERE m.variant_id=v.id AND lower(m.model_role) LIKE ?"
            role_values = ["%" + normalized(args.model_role).replace(" ", "%") + "%"]
            if args.datasheet:
                role_filter += " AND m.datasheet_id=?"
                role_values.append(args.datasheet)
            conditions.append(role_filter + ")")
            values.extend(role_values)
        role_term = "%" + normalized(datasheet_role).replace(" ", "%") + "%" if datasheet_role else ""
        if datasheet_role:
            if args.datasheet:
                conditions.append("""(EXISTS(SELECT 1 FROM links role_link JOIN datasheets role_sheet ON role_sheet.id=role_link.datasheet_id
                    WHERE role_link.variant_id=v.id AND role_link.datasheet_id=? AND lower(role_sheet.role) LIKE ?)
                    OR EXISTS(SELECT 1 FROM fallback_links role_fallback JOIN datasheets role_sheet ON role_sheet.id=role_fallback.datasheet_id
                    WHERE role_fallback.variant_id=v.id AND role_fallback.datasheet_id=? AND lower(role_sheet.role) LIKE ?))""")
                values.extend([args.datasheet, role_term, args.datasheet, role_term])
            else:
                conditions.append("""(EXISTS(SELECT 1 FROM links role_link JOIN datasheets role_sheet ON role_sheet.id=role_link.datasheet_id
                    WHERE role_link.variant_id=v.id AND lower(role_sheet.role) LIKE ?)
                    OR EXISTS(SELECT 1 FROM fallback_links role_fallback JOIN datasheets role_sheet ON role_sheet.id=role_fallback.datasheet_id
                    WHERE role_fallback.variant_id=v.id AND lower(role_sheet.role) LIKE ?))""")
                values.extend([role_term, role_term])
        character = "EXISTS(SELECT 1 FROM links cl JOIN datasheets cd ON cd.id=cl.datasheet_id WHERE cl.variant_id=v.id AND cd.is_character=1 AND cl.status IN ('label_association','literal_label_association','user_association'))"
        if args.character:
            conditions.append(character)
        sql = "SELECT v.id,v.label,v.search_name AS _search_name,v.category,v.model_role,v.source_group,v.fingerprint," + character + " AS is_character FROM variants v WHERE "
        order_values = []
        if args.datasheet:
            order = """CASE
                WHEN EXISTS(SELECT 1 FROM links ranked WHERE ranked.variant_id=v.id AND ranked.datasheet_id=?
                    AND ranked.status IN ('label_association','literal_label_association','user_association')) THEN 0
                WHEN EXISTS(SELECT 1 FROM fallback_links ranked WHERE ranked.variant_id=v.id AND ranked.datasheet_id=?) THEN 1
                WHEN EXISTS(SELECT 1 FROM links ranked WHERE ranked.variant_id=v.id AND ranked.datasheet_id=?
                    AND ranked.status='candidate') THEN 2 ELSE 3 END,
                COALESCE((SELECT max(ranked.score) FROM links ranked WHERE ranked.variant_id=v.id AND ranked.datasheet_id=?),0) DESC,
                v.search_name,v.id"""
            order_values = [args.datasheet] * 4
        elif datasheet_role:
            order = """CASE
                WHEN EXISTS(SELECT 1 FROM links ranked JOIN datasheets ranked_sheet ON ranked_sheet.id=ranked.datasheet_id
                    WHERE ranked.variant_id=v.id AND lower(ranked_sheet.role) LIKE ?
                    AND ranked.status IN ('label_association','literal_label_association','user_association')) THEN 0
                WHEN EXISTS(SELECT 1 FROM fallback_links ranked JOIN datasheets ranked_sheet ON ranked_sheet.id=ranked.datasheet_id
                    WHERE ranked.variant_id=v.id AND lower(ranked_sheet.role) LIKE ?) THEN 1
                WHEN EXISTS(SELECT 1 FROM links ranked JOIN datasheets ranked_sheet ON ranked_sheet.id=ranked.datasheet_id
                    WHERE ranked.variant_id=v.id AND lower(ranked_sheet.role) LIKE ? AND ranked.status='candidate') THEN 2
                ELSE 3 END,
                COALESCE((SELECT max(ranked.score) FROM links ranked JOIN datasheets ranked_sheet ON ranked_sheet.id=ranked.datasheet_id
                    WHERE ranked.variant_id=v.id AND lower(ranked_sheet.role) LIKE ?),0) DESC,
                v.search_name,v.id"""
            order_values = [role_term] * 4
        else:
            order = """CASE
                WHEN EXISTS(SELECT 1 FROM links ranked WHERE ranked.variant_id=v.id
                    AND ranked.status IN ('label_association','literal_label_association','user_association')) THEN 0
                WHEN EXISTS(SELECT 1 FROM fallback_links ranked WHERE ranked.variant_id=v.id) THEN 1
                WHEN EXISTS(SELECT 1 FROM links ranked WHERE ranked.variant_id=v.id AND ranked.status='candidate') THEN 2
                ELSE 3 END,v.search_name,v.id"""
        result = [dict(r) for r in db.execute(sql + " AND ".join(conditions) + f" ORDER BY {order} LIMIT ?", [*values, *order_values, args.limit])]
        for item in result:
            item["source_labels"] = [r[0] for r in db.execute("SELECT DISTINCT label FROM occurrences WHERE variant_id=? ORDER BY label", (item["id"],))]
            item["weapons"] = [r[0] for r in db.execute("SELECT weapon FROM weapons WHERE variant_id=? ORDER BY weapon", (item["id"],))]
            item["datasheets"] = []
            if datasheet_role:
                links = db.execute("""SELECT d.id,d.name,d.faction,d.role,d.source_book,d.is_character,l.status,l.score,l.faction_match FROM links l
                    JOIN datasheets d ON d.id=l.datasheet_id WHERE l.variant_id=?
                    ORDER BY CASE WHEN lower(d.role) LIKE ? THEN 0 ELSE 1 END,l.score DESC,d.name,d.id""",
                    (item["id"], role_term)).fetchall()
            else:
                links = db.execute("""SELECT d.id,d.name,d.faction,d.role,d.source_book,d.is_character,l.status,l.score,l.faction_match FROM links l
                    JOIN datasheets d ON d.id=l.datasheet_id WHERE l.variant_id=?
                    ORDER BY l.score DESC,d.name,d.id""", (item["id"],)).fetchall()
            for link in links:
                linked = dict(link)
                if linked["status"] == "candidate":
                    exact_name = item["_search_name"] == normalized(linked["name"])
                    scope_conflict = str(linked.get("faction_match", "")).strip().casefold() == "false"
                    linked["candidate_evidence"] = (
                        "exact_datasheet_name_with_faction_scope_conflict" if exact_name and scope_conflict
                        else "exact_datasheet_name" if exact_name
                        else "lexical_candidate"
                    )
                linked["model_roles"] = [dict(r) for r in db.execute("SELECT model_role,status FROM model_role_links WHERE variant_id=? AND datasheet_id=? ORDER BY model_role", (item["id"], link["id"]))]
                linked["weapon_term_aliases"] = [dict(r) for r in db.execute("SELECT visual_term,physical_term,evidence FROM weapon_aliases WHERE datasheet_id=? ORDER BY visual_term", (link["id"],))]
                linked["weapon_label_resolutions"] = [dict(r) for r in db.execute("SELECT weapon,label_suffix,evidence FROM weapon_label_resolutions WHERE variant_id=? AND datasheet_id=? ORDER BY weapon", (item["id"], link["id"]))]
                item["datasheets"].append(linked)
            for fallback in db.execute("""SELECT d.id,d.name,d.faction,d.role,d.source_book,d.is_character,
                f.authority_sha256,f.source_label FROM fallback_links f
                JOIN datasheets d ON d.id=f.datasheet_id WHERE f.variant_id=? ORDER BY d.name,d.id""", (item["id"],)):
                linked = next((d for d in item["datasheets"] if d["id"] == fallback["id"]), None)
                if linked is None:
                    linked = {"id": fallback["id"], "name": fallback["name"], "faction": fallback["faction"],
                              "role": fallback["role"], "source_book": fallback["source_book"],
                              "is_character": fallback["is_character"], "status": "reviewed_visual_fallback",
                              "score": None, "model_roles": []}
                    item["datasheets"].append(linked)
                linked["visual_fallback"] = {"authority_sha256": fallback["authority_sha256"], "source_label": fallback["source_label"],
                                              "scope": "presentation substitute; not model identity or equipped weapons"}
            if datasheet_role:
                role_status_rank = {"label_association": 0, "literal_label_association": 0,
                                    "user_association": 0, "reviewed_visual_fallback": 1, "candidate": 2}
                requested_role = normalized(datasheet_role)
                item["datasheets"].sort(key=lambda link: (
                    0 if requested_role in normalized(link.get("role", "")) else 1,
                    role_status_rank.get(link.get("status", ""), 3),
                    -float(link["score"]) if link.get("score") is not None else 0.0,
                    link.get("name", ""), link.get("id", "")))
            item.pop("_search_name", None)
        return result
    finally:
        db.close()


def search_objects(args: argparse.Namespace) -> list[dict]:
    """Search all static source objects, including unsupported/unclassified items."""
    db = sqlite3.connect(args.database.resolve().as_uri() + "?mode=ro", uri=True)
    db.row_factory = sqlite3.Row
    try:
        if not db.execute("SELECT 1 FROM source_objects LIMIT 1").fetchone():
            raise ValueError("No source-object inventory; rebuild with --object-inventory for every source")
        conditions, values = [], []
        if args.category:
            conditions.append("category=?")
            values.append(args.category)
        else:
            conditions.append("category NOT IN ('ignored','container')")
        if args.name:
            conditions.append("search_name LIKE ?")
            values.append("%" + normalized(args.name) + "%")
        if args.source:
            conditions.append("source_sha256=?")
            values.append(args.source)
        if args.parent:
            conditions.append("parent_path=?")
            values.append(args.parent)
        rows = [dict(row) for row in db.execute("SELECT * FROM source_objects WHERE " + " AND ".join(conditions) + " ORDER BY search_name,source_sha256,path LIMIT ?", [*values, args.limit])]
        for row in rows:
            row.pop("search_name")
            row["asset_kinds"] = json.loads(row["asset_kinds"])
            row["visual_reference_status"] = "visual_reference_only" if set(row["asset_kinds"]) & {"CustomMesh", "CustomAssetbundle"} else "no_supported_visual_reference"
            row["catalog_variant_ids"] = [r[0] for r in db.execute("""SELECT v.id FROM variants v JOIN occurrences o ON o.variant_id=v.id
                WHERE v.source_sha256=? AND o.path=? ORDER BY v.id""", (row["source_sha256"], row["path"]))]
        return rows
    finally:
        db.close()


def coverage(args: argparse.Namespace) -> dict:
    """Account for every runtime identity without equating a proxy to a sculpt."""
    db = sqlite3.connect(args.database.resolve().as_uri() + "?mode=ro", uri=True)
    try:
        db.row_factory = sqlite3.Row
        profiles = []
        counts: Counter = Counter()
        for r in db.execute("SELECT p.definition_id,d.id,d.name FROM runtime_profiles p JOIN datasheets d ON d.id=p.datasheet_id ORDER BY d.name,d.id").fetchall():
            identity = r["id"]
            named = db.execute("""SELECT count(*) FROM links l JOIN variants v ON v.id=l.variant_id
                WHERE l.datasheet_id=? AND l.status IN ('label_association','literal_label_association','user_association') AND v.category='miniature'""", (identity,)).fetchone()[0]
            fallbacks = [row[0] for row in db.execute("SELECT DISTINCT source_label FROM fallback_links WHERE datasheet_id=? ORDER BY source_label", (identity,))]
            candidates = db.execute("SELECT count(*) FROM links WHERE datasheet_id=? AND status='candidate'", (identity,)).fetchone()[0]
            role_eligible = db.execute("""SELECT count(DISTINCT l.variant_id) FROM links l
                JOIN model_role_links m ON m.variant_id=l.variant_id AND m.datasheet_id=l.datasheet_id
                JOIN variants v ON v.id=l.variant_id WHERE l.datasheet_id=? AND v.category='miniature'
                AND l.status IN ('label_association','literal_label_association','user_association')
                AND m.status NOT IN ('unresolved_model_role','ambiguous_model_role')""", (identity,)).fetchone()[0]
            status = "label_associations" if named else "reviewed_visual_fallback_only" if fallbacks else "candidate_only" if candidates else "no_source_candidate"
            counts[status] += 1
            profiles.append({"definition_id": r["definition_id"], "datasheet_id": identity, "name": r["name"], "status": status,
                             "label_association_variants": named, "role_eligible_variants": role_eligible,
                             "reviewed_visual_fallback_labels": fallbacks, "other_candidates": candidates})
        metadata = {r["key"]: json.loads(r["value"]) for r in db.execute("SELECT key,value FROM metadata")}
        report = {"scope": "source inventory and existing visual fallbacks; asset import/weapon fidelity not certified",
                  "rules_snapshot_id": metadata["rules_snapshot_id"], "runtime_identities": len(profiles), "status_counts": dict(counts), "profiles": profiles}
        if args.output:
            ensure_outputs_are_local([args.output])
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            return {"runtime_identities": len(profiles), "status_counts": dict(counts), "output": str(args.output)}
        return report
    finally:
        db.close()


def datasheet_coverage(args: argparse.Namespace) -> dict:
    """Summarize model links for every current datasheet in the source catalog."""
    db = sqlite3.connect(args.database.resolve().as_uri() + "?mode=ro", uri=True)
    try:
        db.row_factory = sqlite3.Row
        relation_rows = db.execute("""WITH relation_counts AS (
                SELECT l.datasheet_id,
                    COUNT(DISTINCT CASE WHEN v.category='miniature'
                        AND l.status IN ('label_association','literal_label_association','user_association')
                        THEN l.variant_id END) AS confirmed_variants,
                    COUNT(DISTINCT CASE WHEN v.category='miniature' AND l.status='candidate'
                        THEN l.variant_id END) AS candidate_variants
                FROM links l JOIN variants v ON v.id=l.variant_id
                GROUP BY l.datasheet_id
            ), fallback_counts AS (
                SELECT datasheet_id,COUNT(DISTINCT variant_id) AS fallback_variants
                FROM fallback_links GROUP BY datasheet_id
            )
            SELECT d.id,d.name,d.faction,d.role,d.source_book,d.is_character,
                rp.definition_id,
                COALESCE(r.confirmed_variants,0) AS confirmed_variants,
                COALESCE(r.candidate_variants,0) AS candidate_variants,
                COALESCE(f.fallback_variants,0) AS fallback_variants
            FROM datasheets d
            LEFT JOIN runtime_profiles rp ON rp.datasheet_id=d.id
            LEFT JOIN relation_counts r ON r.datasheet_id=d.id
            LEFT JOIN fallback_counts f ON f.datasheet_id=d.id
            ORDER BY lower(d.faction),lower(d.name),d.id""").fetchall()
        fallback_labels: dict[str, list[str]] = {}
        for row in db.execute("SELECT datasheet_id,source_label FROM fallback_links ORDER BY datasheet_id,source_label"):
            labels = fallback_labels.setdefault(row["datasheet_id"], [])
            if row["source_label"] not in labels:
                labels.append(row["source_label"])
        sheet_names = {row["id"]: normalized(row["name"]) for row in relation_rows}
        exact_name_candidates: dict[str, set[str]] = {}
        exact_name_scope_conflicts: dict[str, set[str]] = {}
        exact_name_candidate_labels: dict[str, set[str]] = {}
        exact_candidate_rows: list[dict] = []
        for row in db.execute("""SELECT l.datasheet_id,l.variant_id,l.score,l.faction_match,
                v.label,v.search_name,v.source_sha256,v.variant_key,v.source_group,v.fingerprint,
                v.model_role,v.asset_kind
            FROM links l JOIN variants v ON v.id=l.variant_id
            WHERE l.status='candidate' AND v.category='miniature'"""):
            sheet_id = row["datasheet_id"]
            if row["search_name"] != sheet_names.get(sheet_id):
                continue
            exact_candidate_rows.append(dict(row))
            exact_name_candidates.setdefault(sheet_id, set()).add(row["variant_id"])
            exact_name_candidate_labels.setdefault(sheet_id, set()).add(row["label"])
            if str(row["faction_match"]).strip().casefold() == "false":
                exact_name_scope_conflicts.setdefault(sheet_id, set()).add(row["variant_id"])

        review_queue: list[dict] = []
        if args.review_queue:
            exact_variant_ids = {row["variant_id"] for row in exact_candidate_rows}
            occurrence_map: dict[str, list[dict]] = {}
            for row in db.execute("""SELECT o.variant_id,v.source_sha256,o.path,o.guid,o.state_key,o.source_group,o.label
                FROM occurrences o JOIN variants v ON v.id=o.variant_id
                ORDER BY o.variant_id,v.source_sha256,o.path,o.guid"""):
                if row["variant_id"] in exact_variant_ids:
                    occurrence_map.setdefault(row["variant_id"], []).append({
                        "source_sha256": row["source_sha256"], "path": row["path"], "guid": row["guid"],
                        "state_key": row["state_key"], "source_group": row["source_group"], "label": row["label"],
                    })
            weapon_map: dict[str, list[str]] = {}
            for identity, weapon in db.execute("SELECT variant_id,weapon FROM weapons ORDER BY variant_id,weapon"):
                if identity in exact_variant_ids:
                    weapon_map.setdefault(identity, []).append(weapon)
            confirmed_map: dict[str, list[dict]] = {}
            for row in db.execute("""SELECT l.variant_id,d.id,d.name,d.faction,d.role,l.status
                FROM links l JOIN datasheets d ON d.id=l.datasheet_id
                WHERE l.status IN ('label_association','literal_label_association','user_association')
                ORDER BY l.variant_id,d.name,d.id"""):
                if row["variant_id"] in exact_variant_ids:
                    confirmed_map.setdefault(row["variant_id"], []).append({
                        "datasheet_id": row["id"], "name": row["name"], "faction": row["faction"],
                        "role": row["role"], "association": row["status"],
                    })
            role_map: dict[tuple[str, str], list[dict]] = {}
            for row in db.execute("SELECT variant_id,datasheet_id,model_role,status FROM model_role_links ORDER BY variant_id,datasheet_id,model_role"):
                if row["variant_id"] in exact_variant_ids:
                    role_map.setdefault((row["variant_id"], row["datasheet_id"]), []).append({
                        "model_role": row["model_role"], "status": row["status"],
                    })
            sheet_rows = {row["id"]: row for row in relation_rows}
            for candidate in exact_candidate_rows:
                if str(candidate["faction_match"]).strip().casefold() != "false":
                    continue
                sheet = sheet_rows[candidate["datasheet_id"]]
                variant_id = candidate["variant_id"]
                review_queue.append({
                    "review_status": "pending_visual_and_faction_scope_review",
                    "review_evidence": "exact_datasheet_name_with_faction_scope_conflict",
                    "datasheet_id": sheet["id"], "datasheet_name": sheet["name"],
                    "faction": sheet["faction"], "datasheet_role": sheet["role"],
                    "source_book": sheet["source_book"], "runtime_definition": sheet["definition_id"] or "",
                    "variant_id": variant_id, "label": candidate["label"],
                    "source_sha256": candidate["source_sha256"], "variant_key": candidate["variant_key"],
                    "source_group": candidate["source_group"], "asset_kind": candidate["asset_kind"],
                    "model_role": candidate["model_role"], "asset_fingerprint": candidate["fingerprint"],
                    "candidate_score": candidate["score"], "faction_match": candidate["faction_match"],
                    "weapon_label_hints": json.dumps(weapon_map.get(variant_id, []), ensure_ascii=False),
                    "target_model_role_evidence": json.dumps(role_map.get((variant_id, sheet["id"]), []), ensure_ascii=False),
                    "other_confirmed_datasheets": json.dumps(confirmed_map.get(variant_id, []), ensure_ascii=False),
                    "source_occurrences": json.dumps(occurrence_map.get(variant_id, []), ensure_ascii=False),
                    "review_guidance": "Exact name is identity evidence only; confirm model and source-group scope before using it as a visual association. Weapon/loadout fidelity remains separate.",
                })
            review_queue.sort(key=lambda row: (
                row["faction"].casefold(), row["datasheet_name"].casefold(),
                row["source_group"].casefold(), row["label"].casefold(), row["variant_id"],
            ))
        metadata = {r["key"]: json.loads(r["value"]) for r in db.execute("SELECT key,value FROM metadata")}

        counts: Counter = Counter()
        profiles = []
        confirmed_total = candidate_total = fallback_total = runtime_total = 0
        for row in relation_rows:
            confirmed = int(row["confirmed_variants"])
            candidates = int(row["candidate_variants"])
            fallbacks = int(row["fallback_variants"])
            runtime_definition = row["definition_id"] or ""
            runtime_total += bool(runtime_definition)
            confirmed_total += confirmed
            candidate_total += candidates
            fallback_total += fallbacks
            if confirmed:
                status = "label_associations"
            elif fallbacks:
                status = "reviewed_fallback_without_label_association"
            elif candidates:
                status = "candidate_only"
            else:
                status = "no_miniature_candidate"
            counts[status] += 1
            profiles.append({
                "datasheet_id": row["id"],
                "name": row["name"],
                "faction": row["faction"],
                "datasheet_role": row["role"],
                "source_book": row["source_book"],
                "is_character": bool(row["is_character"]),
                "runtime_definition": runtime_definition,
                "status": status,
                "confirmed_miniature_variants": confirmed,
                "candidate_miniature_variants": candidates,
                "reviewed_fallback_variants": fallbacks,
                "reviewed_fallback_labels": fallback_labels.get(row["id"], []),
                "exact_name_candidate_variants": len(exact_name_candidates.get(row["id"], set())),
                "exact_name_scope_conflict_variants": len(exact_name_scope_conflicts.get(row["id"], set())),
                "exact_name_candidate_labels": sorted(exact_name_candidate_labels.get(row["id"], set()))[:12],
            })

        report = {
            "scope": "miniature association evidence for all current source datasheets; source labels and reviewed fallbacks are not sculpt, loadout-legality or import certification",
            "rules_snapshot_id": metadata["rules_snapshot_id"],
            "database_schema_version": metadata["schema_version"],
            "datasheet_count": len(profiles),
            "runtime_identity_count": runtime_total,
            "status_counts": dict(counts),
            "confirmed_variant_datasheet_links": confirmed_total,
            "candidate_variant_datasheet_links": candidate_total,
            "reviewed_fallback_variant_datasheet_links": fallback_total,
            "datasheets_with_exact_name_candidates": sum(bool(value) for value in exact_name_candidates.values()),
            "exact_name_candidate_variant_datasheet_links": sum(len(value) for value in exact_name_candidates.values()),
            "exact_name_scope_conflict_variant_datasheet_links": sum(len(value) for value in exact_name_scope_conflicts.values()),
            "datasheets": profiles,
        }
        outputs = [path for path in (args.output, args.review_queue) if path]
        if len({path.resolve() for path in outputs}) != len(outputs):
            raise ValueError("JSON report and CSV review queue must use different output paths")
        if outputs:
            ensure_outputs_are_local(outputs)
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        if args.review_queue:
            args.review_queue.parent.mkdir(parents=True, exist_ok=True)
            columns = [
                "review_status", "review_evidence", "datasheet_id", "datasheet_name", "faction",
                "datasheet_role", "source_book", "runtime_definition", "variant_id", "label",
                "source_sha256", "variant_key", "source_group", "asset_kind", "model_role",
                "asset_fingerprint", "candidate_score", "faction_match", "weapon_label_hints",
                "target_model_role_evidence", "other_confirmed_datasheets", "source_occurrences",
                "review_guidance",
            ]
            with args.review_queue.open("w", encoding="utf-8-sig", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=columns)
                writer.writeheader()
                writer.writerows(review_queue)
        if outputs:
            return {key: report[key] for key in (
                "datasheet_count", "runtime_identity_count", "status_counts",
                "confirmed_variant_datasheet_links", "candidate_variant_datasheet_links",
                "reviewed_fallback_variant_datasheet_links", "datasheets_with_exact_name_candidates",
                "exact_name_candidate_variant_datasheet_links", "exact_name_scope_conflict_variant_datasheet_links",
            )} | ({"output": str(args.output)} if args.output else {}) | (
                {"review_queue_rows": len(review_queue), "review_queue": str(args.review_queue)} if args.review_queue else {})
        return report
    finally:
        db.close()


def weapon_coverage(args: argparse.Namespace) -> dict:
    """Compare current datasheet weapon profiles with source-label weapon terms.

    This reports searchable label evidence only. It does not certify that a
    weapon is physically visible, legal on a particular member, or a valid
    combined loadout.
    """
    db = sqlite3.connect(args.database.resolve().as_uri() + "?mode=ro", uri=True)
    try:
        db.row_factory = sqlite3.Row
        metadata = {r["key"]: json.loads(r["value"]) for r in db.execute("SELECT key,value FROM metadata")}
        runtime_definitions = {r["datasheet_id"]: r["definition_id"]
                               for r in db.execute("SELECT datasheet_id,definition_id FROM runtime_profiles")}
        aliases: dict[str, dict[str, str]] = {}
        for row in db.execute("SELECT datasheet_id,visual_term,physical_term FROM weapon_aliases"):
            aliases.setdefault(row["datasheet_id"], {})[row["visual_term"]] = row["physical_term"]

        sheets: dict[str, dict] = {}
        for row in db.execute("SELECT id,name,faction,role,source_book,provenance FROM datasheets ORDER BY name,id"):
            if args.datasheet and row["id"] != args.datasheet: continue
            if args.runtime_only and row["id"] not in runtime_definitions: continue
            source = json.loads(row["provenance"])
            profiles = json.loads(source.get("wargear_profiles", "[]"))
            physical: dict[str, list[str]] = {}
            for name in profiles:
                # Mode/profile labels after a dash describe one physical weapon.
                base_name = re.split(r"\s+[–—-]\s+", str(name), maxsplit=1)[0]
                term = normalized(base_name).replace(" ", "-")
                if term: physical.setdefault(term, []).append(str(name))
            sheets[row["id"]] = {
                "datasheet_id": row["id"], "name": row["name"], "faction": row["faction"],
                "datasheet_role": row["role"], "source_book": row["source_book"],
                "runtime_definition": runtime_definitions.get(row["id"], ""),
                "weapons": {term: {"profile_names": sorted(set(names)), "confirmed": {}, "candidates": {}}
                            for term, names in physical.items()},
            }
        if args.datasheet and not sheets:
            raise ValueError(f"No current datasheet found for ID {args.datasheet}")

        conditions = ["v.category='miniature'", "l.status IN ('label_association','literal_label_association','user_association','candidate')"]
        values: list[str] = []
        if args.datasheet:
            conditions.append("l.datasheet_id=?")
            values.append(args.datasheet)
        if args.runtime_only:
            conditions.append("EXISTS(SELECT 1 FROM runtime_profiles rp WHERE rp.datasheet_id=l.datasheet_id)")
        sql = """SELECT l.datasheet_id,l.variant_id,v.label,l.status,w.weapon
            FROM links l JOIN variants v ON v.id=l.variant_id
            JOIN weapons w ON w.variant_id=v.id WHERE """ + " AND ".join(conditions)
        for row in db.execute(sql, values):
            sheet = sheets.get(row["datasheet_id"])
            if sheet is None: continue
            term = aliases.get(row["datasheet_id"], {}).get(row["weapon"], row["weapon"])
            weapon = sheet["weapons"].get(term)
            if weapon is None: continue
            bucket = "confirmed" if row["status"] in {"label_association", "literal_label_association", "user_association"} else "candidates"
            weapon[bucket][row["variant_id"]] = row["label"]

        totals = Counter()
        for sheet in sheets.values():
            weapon_rows = []
            for term, evidence in sorted(sheet["weapons"].items()):
                confirmed = evidence["confirmed"]
                candidates = evidence["candidates"]
                status = "confirmed_label_evidence" if confirmed else "candidate_only" if candidates else "no_recognized_visual_weapon_term"
                totals[status] += 1
                weapon_rows.append({
                    "weapon": term,
                    "datasheet_weapon_profiles": evidence["profile_names"],
                    "status": status,
                    "confirmed_variant_count": len(confirmed),
                    "candidate_variant_count": len(candidates),
                    "example_confirmed_labels": sorted(set(confirmed.values()))[:12],
                    "example_candidate_labels": sorted(set(candidates.values()))[:12],
                })
            sheet["weapons"] = weapon_rows
            sheet["weapon_profile_count"] = len(weapon_rows)
            sheet["confirmed_weapon_count"] = sum(w["status"] == "confirmed_label_evidence" for w in weapon_rows)
            sheet["candidate_only_weapon_count"] = sum(w["status"] == "candidate_only" for w in weapon_rows)
            sheet["unmatched_weapon_count"] = sum(w["status"] == "no_recognized_visual_weapon_term" for w in weapon_rows)
            totals["datasheets_with_weapon_profiles"] += bool(weapon_rows)
            totals["datasheets_with_any_confirmed_weapon"] += sheet["confirmed_weapon_count"] > 0

        report = {
            "scope": "datasheet weapon profile names compared with recognized source-label weapon terms; no sculpt, visible-weapon, loadout-legality or combination certification",
            "rules_snapshot_id": metadata["rules_snapshot_id"],
            "database_schema_version": metadata["schema_version"],
            "filter": {"datasheet_id": args.datasheet or "", "runtime_only": args.runtime_only},
            "datasheet_count": len(sheets),
            "totals": dict(totals),
            "datasheets": list(sheets.values()),
        }
        if args.output:
            ensure_outputs_are_local([args.output])
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            return {"datasheet_count": report["datasheet_count"], "totals": report["totals"], "output": str(args.output)}
        return report
    finally:
        db.close()


def export_index(args: argparse.Namespace) -> dict:
    """Small Godot bridge: data stays local and is keyed by exact save/path."""
    ensure_outputs_are_local([args.output])
    db = sqlite3.connect(args.database.resolve().as_uri() + "?mode=ro", uri=True)
    try:
        sources: dict = {}
        sql = """WITH associations AS (
                    SELECT l.variant_id,p.definition_id FROM links l
                    JOIN runtime_profiles p ON p.datasheet_id=l.datasheet_id
                    WHERE l.status IN ('label_association','literal_label_association','user_association'))
                 SELECT v.id,v.source_sha256,o.label,v.category,v.model_role,o.path,o.guid,
                        o.source_group,p.definition_id
                 FROM variants v JOIN occurrences o ON o.variant_id=v.id
                 LEFT JOIN associations p ON p.variant_id=v.id AND v.category='miniature'
                 ORDER BY v.id,o.path,p.definition_id"""
        weapon_map: dict[str, list[str]] = {}
        for identity, weapon in db.execute("SELECT variant_id,weapon FROM weapons ORDER BY weapon"):
            weapon_map.setdefault(identity, []).append(weapon)
        linked_sheets: dict[str, list[dict]] = {}
        for identity, datasheet_id, name, status in db.execute("""SELECT l.variant_id,d.id,d.name,l.status
            FROM links l JOIN datasheets d ON d.id=l.datasheet_id
            WHERE l.status IN ('label_association','literal_label_association','user_association')
            ORDER BY d.name,d.id"""):
            linked_sheets.setdefault(identity, []).append({"id": datasheet_id, "name": name, "association": status})
        constraints: dict[tuple[str, str], dict] = {}
        aliases: dict[str, dict[str, str]] = {}
        for definition, visual, physical in db.execute("""SELECT p.definition_id,a.visual_term,a.physical_term
            FROM weapon_aliases a JOIN runtime_profiles p ON p.datasheet_id=a.datasheet_id ORDER BY a.visual_term"""):
            aliases.setdefault(definition, {})[visual] = physical
        for identity, definition, role, status in db.execute("""SELECT m.variant_id,p.definition_id,m.model_role,m.status
            FROM model_role_links m JOIN runtime_profiles p ON p.datasheet_id=m.datasheet_id
            WHERE m.status != 'single_model_role' ORDER BY m.model_role"""):
            constraint = constraints.setdefault((identity, definition), {"status": status, "roles": []})
            if role:
                constraint["roles"].append(role)
        for identity, source, label, category, role, path, guid, group, definition in db.execute(sql):
            record = sources.setdefault(source, {}).setdefault(path, {
                "label": label, "guid": guid, "category": category, "model_role": role,
                "source_group": group, "weapons": weapon_map.get(identity, []),
                "datasheets": linked_sheets.get(identity, []), "definitions": [],
                "role_constraints": {}, "weapon_aliases": {}})
            if definition and definition not in record["definitions"]:
                record["definitions"].append(definition)
                if (identity, definition) in constraints:
                    record["role_constraints"][definition] = constraints[identity, definition]
                relevant = {term: physical for term, physical in aliases.get(definition, {}).items() if term in record["weapons"]}
                if relevant:
                    record["weapon_aliases"][definition] = relevant
        payload = {"schema_version": 1, "policy": "label_association_not_rules_certification", "sources": sources}
        args.output.parent.mkdir(parents=True, exist_ok=True)
        temporary = args.output.with_suffix(".building")
        temporary.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
        os.replace(temporary, args.output)
        return {"source_count": len(sources), "indexed_occurrences": sum(len(v) for v in sources.values()),
                "runtime_associated_occurrences": sum(bool(r["definitions"]) for s in sources.values() for r in s.values()),
                "output": str(args.output)}
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    builder = commands.add_parser("build")
    for field in ["catalog", "datasheets", "runtime-profiles", "database"]:
        builder.add_argument("--" + field, type=Path, required=True)
    builder.add_argument("--relations", type=Path, action="append", required=True)
    builder.add_argument("--corrections", type=Path)
    builder.add_argument("--visual-inventory", type=Path, action="append", default=[], help="Detailed per-occurrence CSV; repeat for each source to preserve exact source-label aliases")
    builder.add_argument("--object-inventory", type=Path, action="append", default=[], help="Complete bounded static-object JSON; repeat for every selected source")
    builder.add_argument("--object-only-inventory", type=Path, action="append", default=[], help="Additional local scenery/object JSON sources without catalog variants or datasheet relations")
    query = commands.add_parser("search")
    query.add_argument("--database", type=Path, required=True)
    query.add_argument("--name", default="")
    query.add_argument("--category", choices=["miniature", "terrain", "component", "base", "ignored"], default="miniature")
    query.add_argument("--datasheet", default="")
    query.add_argument("--weapon", default="")
    query.add_argument("--model-role", default="", help="Filter source model roles, such as Sergeant or Cenobyte")
    query.add_argument("--datasheet-role", default="", help="Filter linked datasheet roles, such as Character or Fortifications")
    query.add_argument("--character", action="store_true", help="Require a label/user association to a Character or Epic Hero datasheet")
    query.add_argument("--limit", type=int, choices=range(1, 201), default=20)
    objects = commands.add_parser("objects", help="Search static objects, including scenery, components and unclassified non-mesh objects")
    objects.add_argument("--database", type=Path, required=True)
    objects.add_argument("--name", default="")
    objects.add_argument("--category", choices=["miniature", "terrain", "component", "base", "ignored", "container", "unclassified"])
    objects.add_argument("--source", default="", help="Exact source SHA-256")
    objects.add_argument("--parent", default="", help="Exact parent TTS path")
    objects.add_argument("--limit", type=int, choices=range(1, 201), default=20)
    exporter = commands.add_parser("export-index")
    exporter.add_argument("--database", type=Path, required=True)
    exporter.add_argument("--output", type=Path, required=True)
    reporter = commands.add_parser("coverage")
    reporter.add_argument("--database", type=Path, required=True)
    reporter.add_argument("--output", type=Path)
    datasheet_reporter = commands.add_parser("datasheet-coverage", help="Summarize model associations for every current datasheet")
    datasheet_reporter.add_argument("--database", type=Path, required=True)
    datasheet_reporter.add_argument("--output", type=Path)
    datasheet_reporter.add_argument("--review-queue", type=Path, help="Write exact-name candidates with source-faction conflicts to a local CSV")
    weapon_reporter = commands.add_parser("weapon-coverage", help="Compare datasheet weapon profiles with source-label weapon terms")
    weapon_reporter.add_argument("--database", type=Path, required=True)
    weapon_reporter.add_argument("--datasheet", default="", help="Limit the report to one current datasheet ID")
    weapon_reporter.add_argument("--runtime-only", action="store_true", help="Limit the report to existing runtime profiles")
    weapon_reporter.add_argument("--output", type=Path)
    args = parser.parse_args()
    action = {"build": build, "search": search, "objects": search_objects, "export-index": export_index,
              "coverage": coverage, "datasheet-coverage": datasheet_coverage,
              "weapon-coverage": weapon_coverage}[args.command]
    print(json.dumps(action(args), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
