"""Retrieve pinned community data for Space Marines and Necrons; no runtime SDK."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import urllib.request

from import_openhammer import encode

REPO = "wn-mitch/40kdc-data"
FACTIONS = {"adeptus-astartes": "Space Marines", "necrons": "Necrons"}


def retrieve(url):
    request = urllib.request.Request(url, headers={"Accept": "application/json", "User-Agent": "OpenTabletop-import/0.1"})
    with urllib.request.urlopen(request, timeout=30) as response:
        content = response.read(16_000_001)
    if len(content) > 16_000_000:
        raise ValueError("Source exceeds size limit")
    return json.loads(content)


def normalize_unit(unit, weapons, abilities, faction):
    profiles = unit.get("profiles") or []
    if not profiles or not isinstance(profiles[0], dict):
        raise ValueError(f"Missing profiles for {unit.get('id')}")
    profile = profiles[0]
    base = unit.get("base_size_mm")
    normalized_base = None
    if isinstance(base, dict) and base.get("shape") == "round":
        diameter = base.get("diameter")
        if isinstance(diameter, (int, float)) and diameter > 0:
            normalized_base = {"shape": "circle", "radius_inches": diameter / 50.8, "diameter_mm": diameter}
    linked_weapons = [weapons[id] for id in unit.get("weapon_ids", []) if id in weapons]
    linked_abilities = [a for a in abilities if a.get("ability_id") in unit.get("ability_ids", [])]
    unresolved = [id for id in unit.get("weapon_ids", []) if id not in weapons]
    return {
        "id": f"40kdc:11e:{faction}:{unit['id']}", "source_id": unit["id"], "name": unit["name"],
        "faction": FACTIONS[faction], "external_refs": unit.get("external_refs", []),
        "stats": {"movement_inches": profile.get("M"), "toughness": profile.get("T"),
                  "save_target": profile.get("Sv"), "wounds": profile.get("W"),
                  "leadership_target": profile.get("Ld"), "objective_control": profile.get("OC"),
                  "invulnerable_target": profile.get("invuln_sv")},
        "profiles": profiles, "base": normalized_base, "composition": unit.get("model_count"),
        "points": unit.get("points", []), "points_provisional": unit.get("points_provisional", False),
        "keywords": unit.get("keywords", []), "faction_keywords": unit.get("faction_keywords", []),
        "source_game_version": unit.get("game_version"),
        # Retain structured source definitions as namespaced data, not executable code.
        "source_weapon_definitions": linked_weapons, "source_ability_definitions": linked_abilities,
        "unsupported_rules": unit.get("ability_ids", []), "playable": False,
        "warnings": ["Faction rules and full-unit interactions not enabled", "Community data requires publication verification"]
                    + [f"Unresolved weapon: {id}" for id in unresolved],
    }


def import_factions(output, revision=None):
    if revision is None:
        revision = retrieve(f"https://api.github.com/repos/{REPO}/commits/main")["sha"]
    if len(revision) != 40 or any(c not in "0123456789abcdef" for c in revision):
        raise ValueError("Revision must be a full lowercase commit SHA")
    output = Path(output)
    if output.exists():
        raise ValueError("Output exists; use a new snapshot directory")
    packages = {}
    report = {"revision": revision, "factions": {}}
    for faction in FACTIONS:
        base_url = f"https://raw.githubusercontent.com/{REPO}/{revision}/data"
        paths = {"units": f"core/{faction}/units.json", "weapons": f"core/{faction}/weapons.json",
                 "abilities": f"enrichment/{faction}/abilities.json"}
        source = {key: retrieve(f"{base_url}/{path}") for key, path in paths.items()}
        if not all(isinstance(records, list) for records in source.values()):
            raise ValueError("Expected arrays in source files")
        weapons = {weapon["id"]: weapon for weapon in source["weapons"]}
        units = [normalize_unit(unit, weapons, source["abilities"], faction) for unit in source["units"]]
        ids = [unit["id"] for unit in units]
        if not units or len(ids) != len(set(ids)):
            raise ValueError("Empty faction or duplicate unit IDs")
        content = encode(units)
        manifest = {"schema_version": 1, "id": f"starter-{faction}-11e", "edition": "11e",
                    "implementation": "reference-only", "units_sha256": hashlib.sha256(content).hexdigest(),
                    "source": {"provider": "40kdc-data", "url": f"https://github.com/{REPO}", "revision": revision,
                               "retrieved_at": datetime.now(timezone.utc).isoformat(),
                               "records_sha256": hashlib.sha256(encode(source)).hexdigest(),
                               "files": paths, "license_status": "see-notices"},
                    "supported_mechanics": []}
        packages[faction] = (content, manifest)
        report["factions"][faction] = {"units": len(units), "provisional_units": sum(
            "provisional" in str(unit["source_game_version"]) or unit["points_provisional"] for unit in units)}
    # Fetch and validate both factions before writing a snapshot.
    output.mkdir(parents=True)
    notices = ("Community snapshot from https://github.com/wn-mitch/40kdc-data at " + revision + "\n"
               "Enrichment attribution: Alpaca Software and the 40kdc community contributors.\n"
               "CC BY 4.0: https://creativecommons.org/licenses/by/4.0/\n"
               "Changes: normalized units and base dimensions; selected linked source definitions.\n"
               "Source schemas CC0; no upstream software is bundled.\n"
               "Underlying third-party game content rights are not granted by this notice.\n")
    for faction, (content, manifest) in packages.items():
        directory = output / faction
        directory.mkdir()
        (directory / "units.json").write_bytes(content)
        (directory / "manifest.json").write_bytes(encode(manifest))
        (directory / "NOTICES.txt").write_text(notices, encoding="utf-8")
    (output / "report.json").write_bytes(encode(report))
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--revision", help="Full commit SHA; defaults to pinning current main")
    args = parser.parse_args()
    try:
        print(json.dumps(import_factions(args.output, args.revision), indent=2))
    except (ValueError, OSError, KeyError) as error:
        parser.exit(1, f"Import failed: {error}\n")


if __name__ == "__main__":
    main()
