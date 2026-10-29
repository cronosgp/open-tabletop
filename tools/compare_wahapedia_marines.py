"""Compare a captured e11 CSV snapshot with selected exported runtime Marine profiles."""
import argparse
import json
import re
import unicodedata
from pathlib import Path

import import_wahapedia as importer
import wahapedia_fixed_checks as fixed_checks
from wahapedia_fixed_checks import plain, number

KEYWORD_CONTEXT = Path(__file__).parents[1] / "docs/wahapedia-keyword-context.json"
# The local Data Export names Hunter profiles but omits the companion target
# gate shown in the current e11 Space Marines datasheet weapon table.
HUNTER_PROFILE_TARGETS = {
    ("000001183", "Chainfist - Hunter"): ["MONSTER", "VEHICLE"],
    ("000004249", "Melta Rifle - Hunter"): ["MONSTER", "VEHICLE"],
    ("000004249", "Multi-melta - Hunter"): ["MONSTER", "VEHICLE"],
    ("000003873", "Chainfist - Hunter"): ["MONSTER", "VEHICLE"],
    ("000000230", "Chainfist - Hunter"): ["MONSTER", "VEHICLE"],
    ("000002781", "Melta Rifle - Hunter"): ["MONSTER", "VEHICLE"],
    ("000002781", "Multi-melta - Hunter"): ["MONSTER", "VEHICLE"],
}


def _source_table_hash(manifest, filename):
    if manifest.get("artifact_type") == "scoped_audit_slice":
        parent_hash = manifest.get("parent_files_sha256", {}).get(filename)
        if parent_hash:
            return parent_hash
    return importer.manifest_file_hash(manifest, filename.removesuffix(".csv"))


def _context_source_issues(context, manifest):
    declared = context.get("source_files_sha256", {})
    if declared:
        issues = []
        for filename, expected in declared.items():
            actual = _source_table_hash(manifest, filename)
            if actual != expected:
                issues.append(f"Keyword context source hash mismatch: {filename}")
        return issues
    if context.get("export_updated_at") != manifest.get("export_updated_at"):
        return ["Keyword context has no source hashes and its export timestamp differs"]
    return []


def _identity_rows(identity_map, manifest, runtime, sheets_by_id):
    if identity_map is None:
        return None, None
    actual_datasheets_hash = _source_table_hash(manifest, "Datasheets.csv")
    source_book_id = str(identity_map.get("source_book_id", ""))
    if not source_book_id:
        raise ValueError("Source identity map has no source book ID")
    mappings = identity_map.get("identity_mappings", [])
    by_identity = {row.get("identity"): row for row in mappings}
    by_source_id = [row.get("source_datasheet_id") for row in mappings]
    if len(by_identity) != len(mappings) or len(set(by_source_id)) != len(by_source_id):
        raise ValueError("Source identity map contains duplicate identities or datasheet IDs")
    if set(runtime["profiles"]) - set(by_identity):
        raise ValueError("Source identity map is missing runtime profiles: " + ", ".join(sorted(set(runtime["profiles"]) - set(by_identity))))
    if manifest.get("artifact_type") == "scoped_audit_slice":
        subjects = set(manifest.get("subject_datasheet_ids", []))
        if subjects and set(by_source_id) != subjects:
            raise ValueError("Source identity map does not cover exactly this scoped slice's subjects")
        parent_datasheets_hash = manifest.get("parent_files_sha256", {}).get("Datasheets.csv")
        if parent_datasheets_hash and identity_map.get("datasheets_csv_sha256") != parent_datasheets_hash:
            raise ValueError("Source identity map does not match the scoped slice's parent Datasheets.csv hash")
        for row in mappings:
            sheet = sheets_by_id.get(row["source_datasheet_id"])
            if (sheet is None or sheet.get("name") != row.get("source_name")
                    or str(sheet.get("source_id", "")) != source_book_id):
                raise ValueError("Source identity map name/ID does not match the scoped source slice: " + str(row.get("identity")))
        return by_identity, "scoped_ids_and_names"
    if identity_map.get("datasheets_csv_sha256") != actual_datasheets_hash:
        raise ValueError("Source identity map does not match this snapshot's Datasheets.csv hash")
    if any(str(sheets_by_id.get(row.get("source_datasheet_id"), {}).get("source_id", "")) != source_book_id
           for row in mappings):
        raise ValueError("Source identity map contains a datasheet from a different source book")
    return by_identity, "datasheets_csv_sha256"


def _runtime_identity_check(identity, profile, sheet, sources):
    """Verify a profile's declared source IDs against the selected e11 row."""
    issues = []
    runtime_sheet_id = str(profile.get("source_datasheet_id", ""))
    runtime_book_id = str(profile.get("source_book_id", ""))
    if not runtime_sheet_id or runtime_sheet_id != str(sheet.get("id", "")):
        issues.append("Runtime datasheet ID is missing or does not match the selected source row")
    if not runtime_book_id or runtime_book_id != str(sheet.get("source_id", "")):
        issues.append("Runtime source book ID is missing or does not match the selected source row")
    source = sources.get(str(sheet.get("source_id", "")), {})
    if source.get("edition") != "11":
        issues.append("Selected source row is not from an 11th-edition book")
    runtime_name = fixed_checks.name_key(profile.get("name", ""))
    source_name = fixed_checks.name_key(sheet.get("name", ""))
    if not runtime_name or runtime_name != source_name:
        issues.append("Runtime profile name does not match the selected source row")
    return {"consistent": not issues, "runtime_source_book_id": runtime_book_id or None,
            "runtime_source_datasheet_id": runtime_sheet_id or None,
            "source_book_name": source.get("name"), "source_name": sheet.get("name"), "issues": issues}


def _model_stat_differences(row, runtime_stats, profile_stats):
    """Compare one source model row against a candidate runtime model profile."""
    differences = []
    for internal, external in {"movement_inches": "M", "toughness": "T", "save_target": "Sv",
                               "wounds": "W", "leadership_target": "Ld", "objective_control": "OC",
                               "invulnerable_target": "inv_sv"}.items():
        expected_value = 0 if row[external] in ["", "-"] or (external in ["M", "OC"] and row[external] == "-") else number(row[external])
        actual_value = runtime_stats.get(internal, profile_stats.get(internal))
        inv_condition = plain(row.get("inv_sv_descr", "")).casefold()
        if external == "inv_sv" and "melee attacks only" in inv_condition:
            if actual_value != 0:
                differences.append({"field": "model." + row["name"] + "." + internal,
                                    "runtime": actual_value, "export": 0})
            melee_value = runtime_stats.get("melee_invulnerable_target", profile_stats.get("melee_invulnerable_target", 0))
            melee_expected = number(row[external])
            if melee_value != melee_expected:
                differences.append({"field": "model." + row["name"] + ".melee_invulnerable_target",
                                    "runtime": melee_value, "export": melee_expected})
            continue
        if external == "inv_sv" and inv_condition and "only" not in inv_condition:
            differences.append({"field": "model." + row["name"] + ".invulnerable_condition",
                                "issue": "Unsupported conditional invulnerable-save description: " + row["inv_sv_descr"]})
        if actual_value != expected_value:
            differences.append({"field": "model." + row["name"] + "." + internal,
                                "runtime": actual_value, "export": expected_value})
    return differences


def _best_model_row_match(row, model_loadouts, profile_stats):
    """Match a source model type to any equivalent runtime role profile.

    Wahapedia lists distinct model types, while runtime profiles may list each
    model instance or several option variants. Names are preferred when they
    match, then numeric characteristics identify the equivalent role.
    """
    candidates = model_loadouts or [{"source_model_name": "", "stats": profile_stats}]
    source_name = fixed_checks.name_key(row.get("name", ""))
    named = [candidate for candidate in candidates
             if candidate.get("source_model_name")
             and fixed_checks.name_key(candidate["source_model_name"]) == source_name]
    preferred = named or candidates
    evaluated = []
    for candidate in preferred:
        stats = candidate.get("stats", profile_stats)
        differences = _model_stat_differences(row, stats, profile_stats)
        evaluated.append((len(differences), differences))
    return min(evaluated, key=lambda item: item[0])[1]


def _weapon_name_key(value):
    text = unicodedata.normalize("NFKD", fixed_checks.plain(str(value))).casefold()
    return "".join(char for char in text if char.isalnum())


def source_wargear_weapon_trait_projections(ability_rows):
    """Read only explicit Wargear rules that grant a weapon trait by group."""
    projections = {"ranged": set(), "melee": set()}
    pattern = re.compile(
        r"^(ranged|melee) weapons equipped by the bearer have the \[([^]]+)\] ability\.?$",
        re.IGNORECASE,
    )
    for row in ability_rows:
        if str(row.get("type", "")).casefold() != "wargear":
            continue
        description = fixed_checks.plain(row.get("description", ""))
        match = pattern.fullmatch(description.strip())
        if match:
            projections[match.group(1).casefold()].add(
                re.sub(r"\s+", "-", match.group(2).strip().casefold()))
    return projections


def source_weapon_trait_description(row, group, granted_traits=()):
    """Combine printed traits with narrowly recognized source weapon context."""
    description = str(row.get("description", ""))
    expected = set(granted_traits)
    if group == "ranged" and "pistol" in _weapon_name_key(row.get("name", "")):
        expected.add("close-quarters")
    parsed = fixed_checks.traits(description, {}).get("expected", {})
    additions = sorted(trait for trait in expected if trait not in parsed)
    if additions:
        description = ", ".join([description, *[trait.replace("-", " ") for trait in additions]])
    return description


def weapon_trait_scope_consistent(source_rows, profile, checks):
    """Treat an explicitly weaponless datasheet as a valid empty comparison."""
    source_has_weapons = any(fixed_checks.plain(row.get("name", "")).strip() for row in source_rows)
    runtime_has_weapons = any(profile.get(group) or profile.get("additional_weapon_profiles", {}).get(group)
                              for group in ["ranged", "melee"])
    if not source_has_weapons and not runtime_has_weapons:
        return not checks
    return bool(checks) and all(result.get("consistent", False) for result in checks)


def hunter_profile_target_check(datasheet_id, source_weapon_name, runtime_stats):
    """Check page-rendered Hunter gates omitted from Datasheets_wargear.csv."""
    key = (str(datasheet_id), fixed_checks.plain(str(source_weapon_name)).strip())
    expected = HUNTER_PROFILE_TARGETS.get(key)
    runtime = runtime_stats.get("keywords", {}).get("hunter")
    if expected is None:
        return {"recognized": False, "consistent": not bool(runtime),
                "source_profile": source_weapon_name, "runtime_target_keywords_any": runtime}
    actual = sorted({str(item).strip().upper() for item in runtime}) if isinstance(runtime, list) else []
    expected_normalized = sorted(expected)
    return {"recognized": True, "consistent": actual == expected_normalized,
            "source_profile": source_weapon_name, "source_target_keywords_any": expected,
            "runtime_target_keywords_any": runtime,
            "source_rule": "Wahapedia 11e Space Marines datasheet profile table; App 2.8.1, October 2026"}


def review_keywords(rows, profile, sheet, identity, context_issues, chapter, context):
    raw = {plain(r["keyword"]).upper() for r in rows if r["model"] in ["", "ALL MODELS"] and r["is_faction_keyword"] == "false"}
    applicable = set(raw)
    faction = {plain(r["keyword"]).upper() for r in rows if r["model"] in ["", "ALL MODELS"] and r["is_faction_keyword"] == "true"}
    excluded, applied, issues = [], [], []
    issues.extend(context_issues)
    for rule in context.get("conditional_keywords", []):
        if rule["datasheet_id"] != sheet["id"] or rule["source_book_id"] != sheet["source_id"] or rule["keyword"] not in raw:
            continue
        if context_issues:
            continue
        if rule["requires_chapter"] == chapter:
            applied.append(rule)
        else:
            applicable.remove(rule["keyword"])
            excluded.append(rule)
    runtime = set(profile["keywords"])
    internal = {r["tag"] for r in context.get("internal_identity_tags", []) if r["runtime_identity"] == identity}
    conditional = [r for r in context.get("conditional_keywords", [])
                   if r["datasheet_id"] == sheet["id"] and r["source_book_id"] == sheet["source_id"]]
    for rule in conditional:
        # Compare the shared profile after removing chapter-only projections. The
        # actual ChapterRules behavior is checked separately by its focused tests.
        applicable.discard(rule["keyword"])
        runtime.discard(rule["keyword"])
        if rule["requires_chapter"] == chapter:
            applicable.add(rule["keyword"])
            runtime.add(rule["keyword"])
    missing = sorted(applicable - runtime)
    missing_faction = sorted(faction - runtime - internal)
    extra = sorted(runtime - raw - faction - internal)
    return {"chapter_context": chapter, "raw_source_only_keywords": sorted(raw - runtime),
            "missing_from_runtime": missing, "runtime_extra_or_identity_tags": sorted(runtime - applicable),
            "source_faction_keywords": sorted(faction), "missing_faction_keywords": missing_faction,
            "internal_identity_tags": sorted(internal & runtime), "unresolved_runtime_extras": extra,
            "excluded_chapter_keywords": excluded, "applied_chapter_keywords": applied,
            "context_issues": issues, "scope_consistent": not (missing or missing_faction or extra or issues),
            "conditional_source_rows": [r for r in rows if r["model"]]}


def compare(snapshot, runtime, chapter="shared", keyword_context=None, source_identity_map=None):
    root = Path(snapshot)
    manifest, tables, manifest_digest = importer.load_snapshot(root)
    if chapter not in ["shared", "black-templars", "blood-angels", "dark-angels", "deathwatch", "space-wolves"]:
        raise ValueError("Unsupported keyword audit chapter context")
    if keyword_context is None:
        keyword_context = json.loads(KEYWORD_CONTEXT.read_text(encoding="utf-8"))
    context_issues = _context_source_issues(keyword_context, manifest)
    sources = {r["id"]: r for r in tables["Source"]}
    sheets_by_id = {r["id"]: r for r in tables["Datasheets"]}
    identity_rows, identity_map_verification = _identity_rows(source_identity_map, manifest, runtime, sheets_by_id)
    reports = []
    url_slugs = {"brutalis-dreadnought": "Brutalis-Dreadnought-UL"}
    if not runtime.get("profiles"):
        raise ValueError("Runtime export must contain at least one Marine profile")
    for identity, profile in runtime["profiles"].items():
        mapping = identity_rows.get(identity) if identity_rows is not None else None
        url = importer.BASE + "factions/space-marines/" + url_slugs.get(identity, "-".join(p.capitalize() for p in identity.split("-")))
        mapped_id = mapping.get("source_datasheet_id") if mapping else profile.get("source_datasheet_id")
        if mapped_id:
            candidate = sheets_by_id.get(mapped_id)
            scoped_subjects = set(manifest.get("subject_datasheet_ids", [])) if manifest.get("artifact_type") == "scoped_audit_slice" else set()
            rows = [candidate] if candidate is not None and (not scoped_subjects or mapped_id in scoped_subjects) and sources.get(candidate["source_id"], {}).get("edition") == "11" else []
        else:
            rows = [r for r in tables["Datasheets"] if r["link"].rstrip("/").lower() == url.lower()
                    and sources.get(r["source_id"], {}).get("edition") == "11"]
        result = {"identity": identity, "source_url": url, "source_match_method": "verified_identity_map" if mapping else ("runtime_source_id" if mapped_id else "derived_url"), "differences": [], "playable_certified": False}
        reports.append(result)
        if len(rows) != 1:
            result["differences"].append({"field": "identity", "issue": f"Expected one e11 source record; found {len(rows)}"})
            continue
        sheet = rows[0]
        result.update(source_id=sheet["id"], source_url=sheet["link"], book=sources[sheet["source_id"]])
        runtime_identity = _runtime_identity_check(identity, profile, sheet, sources)
        result["runtime_source_identity"] = runtime_identity
        if not runtime_identity["consistent"]:
            result["differences"].append({"field": "identity.runtime_source", "issues": runtime_identity["issues"]})
        if mapping and profile.get("source_datasheet_id") and profile["source_datasheet_id"] != mapping["source_datasheet_id"]:
            result["differences"].append({"field": "identity.source_datasheet_id", "runtime": profile["source_datasheet_id"], "verified_map": mapping["source_datasheet_id"]})
        if mapping and profile.get("name") and fixed_checks.name_key(profile["name"]) != fixed_checks.name_key(mapping.get("source_name", "")):
            result["differences"].append({"field": "identity.source_name", "runtime": profile["name"], "verified_map": mapping.get("source_name")})
        if mapping and sheet["source_id"] != source_identity_map["source_book_id"]:
            result["differences"].append({"field": "identity.source_book_id", "runtime": sheet["source_id"], "verified_map": source_identity_map["source_book_id"]})
        def related(table):
            return [r for r in tables[table] if r["datasheet_id"] == sheet["id"]]
        def check(field, actual, expected):
            if actual != expected:
                result["differences"].append({"field": field, "runtime": actual, "export": expected})
        models = sorted(related("Datasheets_models"), key=lambda row: int(row["line"]))
        if not models:
            result["differences"].append({"field": "models", "issue": "Missing model characteristics"})
        model_loadouts = profile.get("model_loadouts", [])
        for row in models:
            result["differences"].extend(
                _best_model_row_match(row, model_loadouts, profile["stats"]))
        weapons = related("Datasheets_wargear")
        source_ability_rows = related("Datasheets_abilities")
        weapon_trait_projections = source_wargear_weapon_trait_projections(source_ability_rows)
        result["source_weapon_trait_projections"] = {
            group: sorted(traits) for group, traits in weapon_trait_projections.items() if traits}
        result["weapon_trait_checks"] = []
        for group in ["ranged", "melee"]:
            for weapon in profile[group] + profile.get("additional_weapon_profiles", {}).get(group, []):
                for mode, stats in weapon["profiles"].items():
                    matches = [r for r in weapons if _weapon_name_key(r["name"]) == _weapon_name_key(stats["name"])
                               and (r["type"].lower() == "melee") == (group == "melee")]
                    field = "weapon." + weapon["id"] + "." + mode
                    if len(matches) != 1:
                        result["differences"].append({"field": field, "issue": f"Expected one weapon row; found {len(matches)}"})
                        continue
                    row = matches[0]
                    hunter_gate = hunter_profile_target_check(sheet["id"], row["name"], stats)
                    runtime_traits: dict = stats.get("keywords", {}).copy()
                    if hunter_gate.get("recognized") and hunter_gate.get("consistent"):
                        runtime_traits.pop("hunter", None)
                    trait_description = source_weapon_trait_description(
                        row, group, weapon_trait_projections.get(group, ()))
                    trait_check = fixed_checks.traits(trait_description, runtime_traits,
                        stats.get("target_restricted_traits", {}), stats.get("target_required_traits", {}))
                    trait_check["consistent"] = bool(trait_check.get("consistent", False) and hunter_gate.get("consistent", False))
                    result["weapon_trait_checks"].append({"weapon": field, "hunter_profile_gate": hunter_gate, **trait_check})
                    for internal, external in {"range_inches": "range", "attacks": "A", "skill": "BS_WS", "strength": "S", "ap": "AP", "damage": "D"}.items():
                        if internal == "range_inches" and group == "melee":
                            expected_value = 0
                            actual_value = 0 if str(stats[internal]).casefold() == "melee" else stats[internal]
                        elif internal == "skill" and group == "ranged" and "torrent" in stats.get("keywords", {}):
                            # Torrent auto-hits, so its printed BS value is unused; runtime 0 is the sentinel.
                            expected_value = 0
                            actual_value = 0 if stats[internal] is None else stats[internal]
                        elif external in ["M", "OC"] and row[external] in ["", "-"]:
                            # A dash is the source's no-movement/no-OC sentinel for this profile.
                            expected_value = 0
                            actual_value = stats[internal]
                        else:
                            expected_value = number(row[external])
                            actual_value = 0 if internal == "skill" and group == "ranged" and stats[internal] is None and "torrent" in stats.get("keywords", {}) else stats[internal]
                        check(field + "." + internal, actual_value, expected_value)
        result["weapon_trait_scope_consistent"] = weapon_trait_scope_consistent(weapons, profile, result["weapon_trait_checks"])
        keywords = related("Datasheets_keywords")
        result["keyword_review"] = review_keywords(keywords, profile, sheet, identity,
                                                   context_issues, chapter, keyword_context)
        result["ability_inventory"], result["ability_resolution_issues"] = [], []
        for row in source_ability_rows:
            if not row["ability_id"]:
                result["ability_inventory"].append(row["name"])
                continue
            matches = [a for a in tables["Abilities"] if a["id"] == row["ability_id"]]
            scoped = [a for a in matches if a["faction_id"] == sheet["faction_id"]]
            candidates = scoped or matches
            definitions = {json.dumps({k: v for k, v in a.items() if k != "faction_id"}, sort_keys=True) for a in candidates}
            if len(definitions) != 1:
                result["ability_resolution_issues"].append(row["ability_id"])
            else:
                result["ability_inventory"].append(candidates[0]["name"])
        result["cost_rows"] = related("Datasheets_models_cost")
        result["default_loadout_check"] = fixed_checks.loadout(sheet["loadout"], profile)
        fixed = profile.get("fixed_roster")
        if fixed is not None:
            result["composition_check"] = fixed_checks.composition(related("Datasheets_unit_composition"), fixed)
            result["fixed_cost_check"] = fixed_checks.costs(result["cost_rows"], fixed,
                                                              profile.get("max_supported_copies", fixed.get("max_supported_copies")))
        else:
            result["composition_check"] = result["fixed_cost_check"] = {"consistent": False, "issues": ["Runtime fixed-roster metadata was not exported"]}
        result["fixed_data_scope_consistent"] = (not result["differences"] and result["keyword_review"]["scope_consistent"]
            and result["weapon_trait_scope_consistent"]
            and all(result[k]["consistent"] for k in ["default_loadout_check", "composition_check", "fixed_cost_check"])
            and result["fixed_cost_check"].get("price_scope_complete", False)
            and result["fixed_cost_check"].get("optional_wargear_scope_complete", False))
        result["scope"] = "Fixed numeric/trait/default-loadout/size/cost source checks only. Optional wargear, model-role assignment and executable ability interactions are not certified."
    parent_validation_errors = manifest.get("parent_validation_errors", [])
    return {"snapshot_manifest_sha256": manifest_digest,
            "source_identity_map_sha256": importer.sha(importer.encode(source_identity_map)) if source_identity_map is not None else None,
            "identity_mapping_verified": identity_rows is not None,
            "runtime_source_identity_verified": all(p.get("runtime_source_identity", {}).get("consistent", False) for p in reports),
            "identity_map_verification": identity_map_verification,
            "keyword_context_source_verified": not context_issues,
            "keyword_context_source_issues": context_issues,
            "keyword_context_id": keyword_context.get("id"), "keyword_context_sha256": importer.sha(importer.encode(keyword_context)),
            "export_updated_at": manifest["export_updated_at"], "runtime_id": runtime["id"],
            "runtime_digest": runtime["digest"], "snapshot_structurally_valid": manifest["structurally_valid"],
            "parent_source_structurally_valid": not parent_validation_errors,
            "parent_source_validation_error_count": len(parent_validation_errors),
            "parent_manifest_sha256": manifest.get("parent_manifest_sha256"),
            "runtime_roster_digest": runtime.get("roster_digest"),
            "profiles": reports, "full_match_certified": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, required=True)
    parser.add_argument("--runtime-profiles", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--chapter", choices=["shared", "black-templars", "blood-angels", "dark-angels", "deathwatch", "space-wolves"], default="shared", help="Keyword audit context only; does not grant runtime chapter rules")
    parser.add_argument("--identity-map", type=Path, help="Optional verified single-book identity map; runtime source IDs are checked directly against the snapshot")
    parser.add_argument("--require-fixed-data", action="store_true", help="Exit 1 unless all exported bounded data checks and snapshot structural validation pass; never certifies executable rules")
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Output already exists")
    try:
        source_identity_map = json.loads(args.identity_map.read_text(encoding="utf-8-sig")) if args.identity_map else None
        report = compare(args.snapshot, json.loads(args.runtime_profiles.read_text(encoding="utf-8")), chapter=args.chapter, source_identity_map=source_identity_map)
    except (ValueError, OSError, KeyError) as error:
        parser.exit(1, str(error) + "\n")
    args.output.write_bytes(importer.encode(report))
    print(json.dumps({"profiles": len(report["profiles"]), "numeric_or_identity_differences": sum(len(p["differences"]) for p in report["profiles"]),
                      "fixed_data_profiles_consistent": sum(p.get("fixed_data_scope_consistent", False) for p in report["profiles"]),
                      "snapshot_structurally_valid": report["snapshot_structurally_valid"], "report": str(args.output)}))
    return 1 if args.require_fixed_data and (not report["snapshot_structurally_valid"] or not report["parent_source_structurally_valid"]
        or not report["runtime_source_identity_verified"] or not report["keyword_context_source_verified"]
        or not all(p.get("fixed_data_scope_consistent", False) for p in report["profiles"])) else 0


if __name__ == "__main__":
    raise SystemExit(main())
