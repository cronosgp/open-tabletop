"""Compare a captured e11 CSV snapshot with selected exported runtime Marine profiles."""
import argparse
import json
from pathlib import Path

import import_wahapedia as importer
import wahapedia_fixed_checks as fixed_checks
from wahapedia_fixed_checks import plain, number

KEYWORD_CONTEXT = Path(__file__).parents[1] / "docs/wahapedia-keyword-context.json"


def review_keywords(rows, profile, sheet, identity, export_updated_at, chapter, context):
    raw = {plain(r["keyword"]).upper() for r in rows if r["model"] in ["", "ALL MODELS"] and r["is_faction_keyword"] == "false"}
    applicable = set(raw)
    excluded, applied, issues = [], [], []
    for rule in context.get("conditional_keywords", []):
        if rule["datasheet_id"] != sheet["id"] or rule["source_book_id"] != sheet["source_id"] or rule["keyword"] not in raw:
            continue
        if context["export_updated_at"] != export_updated_at:
            issues.append("Keyword context must be rechecked for this export revision: " + rule["keyword"])
            continue
        if rule["requires_chapter"] == chapter:
            applied.append(rule)
        else:
            applicable.remove(rule["keyword"])
            excluded.append(rule)
    runtime = set(profile["keywords"])
    internal = {r["tag"] for r in context.get("internal_identity_tags", []) if r["runtime_identity"] == identity}
    missing = sorted(applicable - runtime)
    extra = sorted(runtime - applicable - internal)
    return {"chapter_context": chapter, "raw_source_only_keywords": sorted(raw - runtime),
            "missing_from_runtime": missing, "runtime_extra_or_identity_tags": sorted(runtime - applicable),
            "internal_identity_tags": sorted(internal & runtime), "unresolved_runtime_extras": extra,
            "excluded_chapter_keywords": excluded, "applied_chapter_keywords": applied,
            "context_issues": issues, "scope_consistent": not (missing or extra or issues),
            "conditional_source_rows": [r for r in rows if r["model"]]}


def compare(snapshot, runtime, chapter="shared", keyword_context=None):
    root = Path(snapshot)
    manifest, tables, manifest_digest = importer.load_snapshot(root)
    if chapter not in ["shared", "dark-angels"]:
        raise ValueError("Unsupported keyword audit chapter context")
    if keyword_context is None:
        keyword_context = json.loads(KEYWORD_CONTEXT.read_text(encoding="utf-8"))
    sources = {r["id"]: r for r in tables["Source"]}
    reports = []
    url_slugs = {"brutalis-dreadnought": "Brutalis-Dreadnought-UL"}
    if not runtime.get("profiles"):
        raise ValueError("Runtime export must contain at least one Marine profile")
    for identity, profile in runtime["profiles"].items():
        url = importer.BASE + "factions/space-marines/" + url_slugs.get(identity, "-".join(p.capitalize() for p in identity.split("-")))
        rows = [r for r in tables["Datasheets"] if r["link"].rstrip("/").lower() == url.lower()
                and sources.get(r["source_id"], {}).get("edition") == "11"]
        result = {"identity": identity, "source_url": url, "differences": [], "playable_certified": False}
        reports.append(result)
        if len(rows) != 1:
            result["differences"].append({"field": "identity", "issue": f"Expected one e11 source record; found {len(rows)}"})
            continue
        sheet = rows[0]
        result.update(source_id=sheet["id"], book=sources[sheet["source_id"]])
        def related(table):
            return [r for r in tables[table] if r["datasheet_id"] == sheet["id"]]
        def check(field, actual, expected):
            if actual != expected:
                result["differences"].append({"field": field, "runtime": actual, "export": expected})
        models = related("Datasheets_models")
        if not models:
            result["differences"].append({"field": "models", "issue": "Missing model characteristics"})
        for row in models:
            for internal, external in {"movement_inches": "M", "toughness": "T", "save_target": "Sv", "wounds": "W", "leadership_target": "Ld", "objective_control": "OC", "invulnerable_target": "inv_sv"}.items():
                expected_value = 0 if external == "inv_sv" and row[external] in ["", "-"] else number(row[external])
                check("model." + row["name"] + "." + internal, profile["stats"][internal], expected_value)
        weapons = related("Datasheets_wargear")
        result["weapon_trait_checks"] = []
        for group in ["ranged", "melee"]:
            for weapon in profile[group] + profile.get("additional_weapon_profiles", {}).get(group, []):
                for mode, stats in weapon["profiles"].items():
                    matches = [r for r in weapons if plain(r["name"]).casefold() == stats["name"].casefold()
                               and (r["type"].lower() == "melee") == (group == "melee")]
                    field = "weapon." + weapon["id"] + "." + mode
                    if len(matches) != 1:
                        result["differences"].append({"field": field, "issue": f"Expected one weapon row; found {len(matches)}"})
                        continue
                    row = matches[0]
                    result["weapon_trait_checks"].append({"weapon": field, **fixed_checks.traits(row["description"], stats.get("keywords", {}), stats.get("target_restricted_traits", {}))})
                    for internal, external in {"range_inches": "range", "attacks": "A", "skill": "BS_WS", "strength": "S", "ap": "AP", "damage": "D"}.items():
                        if internal == "range_inches" and group == "melee":
                            expected_value = 0
                        elif internal == "skill" and group == "ranged" and row[external] in ["", "-"] and "torrent" in stats.get("keywords", {}):
                            # Wahapedia exports Torrent weapons with BS "-"; runtime 0 is its auto-hit sentinel.
                            expected_value = 0
                        elif internal == "skill" and group == "ranged" and row[external] == "0" and "torrent" in stats.get("keywords", {}):
                            # The extraction can also encode the same auto-hit profile as BS 0.
                            expected_value = 0
                        else:
                            expected_value = number(row[external])
                        actual_value = 0 if internal == "skill" and group == "ranged" and stats[internal] is None and "torrent" in stats.get("keywords", {}) else stats[internal]
                        check(field + "." + internal, actual_value, expected_value)
        keywords = related("Datasheets_keywords")
        result["keyword_review"] = review_keywords(keywords, profile, sheet, identity,
                                                   manifest["export_updated_at"], chapter, keyword_context)
        result["ability_inventory"], result["ability_resolution_issues"] = [], []
        for row in related("Datasheets_abilities"):
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
            result["fixed_cost_check"] = fixed_checks.costs(result["cost_rows"], fixed)
        else:
            result["composition_check"] = result["fixed_cost_check"] = {"consistent": False, "issues": ["Runtime fixed-roster metadata was not exported"]}
        result["fixed_data_scope_consistent"] = (not result["differences"] and result["keyword_review"]["scope_consistent"]
            and bool(result["weapon_trait_checks"]) and all(r["consistent"] for r in result["weapon_trait_checks"])
            and all(result[k]["consistent"] for k in ["default_loadout_check", "composition_check", "fixed_cost_check"]))
        result["scope"] = "Fixed numeric/trait/default-loadout/size/cost source checks only. Optional wargear, model-role assignment and executable ability interactions are not certified."
    return {"snapshot_manifest_sha256": manifest_digest,
            "keyword_context_id": keyword_context.get("id"), "keyword_context_sha256": importer.sha(importer.encode(keyword_context)),
            "export_updated_at": manifest["export_updated_at"], "runtime_id": runtime["id"],
            "runtime_digest": runtime["digest"], "snapshot_structurally_valid": manifest["structurally_valid"],
            "runtime_roster_digest": runtime.get("roster_digest"),
            "profiles": reports, "full_match_certified": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, required=True)
    parser.add_argument("--runtime-profiles", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--chapter", choices=["shared", "dark-angels"], default="shared", help="Keyword audit context only; does not grant runtime chapter rules")
    parser.add_argument("--require-fixed-data", action="store_true", help="Exit 1 unless all exported bounded data checks and snapshot structural validation pass; never certifies executable rules")
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Output already exists")
    try:
        report = compare(args.snapshot, json.loads(args.runtime_profiles.read_text(encoding="utf-8")), chapter=args.chapter)
    except (ValueError, OSError, KeyError) as error:
        parser.exit(1, str(error) + "\n")
    args.output.write_bytes(importer.encode(report))
    print(json.dumps({"profiles": len(report["profiles"]), "numeric_or_identity_differences": sum(len(p["differences"]) for p in report["profiles"]),
                      "fixed_data_profiles_consistent": sum(p.get("fixed_data_scope_consistent", False) for p in report["profiles"]),
                      "snapshot_structurally_valid": report["snapshot_structurally_valid"], "report": str(args.output)}))
    return 1 if args.require_fixed_data and (not report["snapshot_structurally_valid"] or not all(p.get("fixed_data_scope_consistent", False) for p in report["profiles"])) else 0


if __name__ == "__main__":
    raise SystemExit(main())
