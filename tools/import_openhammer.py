"""Optional, standard-library-only data importer. Never used by the game runtime."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import urllib.parse
import urllib.request
from datetime import datetime, timezone

API = "https://openhammer-api-production.up.railway.app"


def number(value, suffix=""):
    text = str(value).strip().replace('\\"', '"')
    if suffix and text.endswith(suffix):
        text = text[:-len(suffix)]
    if not re.fullmatch(r"\d+(\.\d+)?", text):
        return None
    result = float(text)
    return result if math.isfinite(result) else None


def normalize(source, edition):
    if not isinstance(source, dict) or not source.get("id") or not source.get("name"):
        raise ValueError("Every source record requires an ID and name")
    stats = source.get("stats") or {}
    if not isinstance(stats, dict):
        raise ValueError("stats must be an object")
    warnings = ["Complete official rules implementation is not available", "Base geometry requires verification"]
    normalized_stats = {}
    for key, external, suffix in [("movement_inches", "M", '"'), ("toughness", "T", ""),
                                  ("save_target", "SV", "+"), ("wounds", "W", ""),
                                  ("leadership_target", "LD", "+"), ("objective_control", "OC", "")]:
        normalized_stats[key] = number(stats.get(external), suffix)
        if normalized_stats[key] is None:
            warnings.append(f"Unresolved stat: {external}")
    abilities = source.get("abilities") or []
    special_rules = source.get("special_rules") or []
    if not isinstance(abilities, list) or not isinstance(special_rules, list):
        raise ValueError("abilities and special_rules must be arrays")
    # Preserve names for auditing; prose is neither executed nor copied into packs.
    unsupported = [str(a.get("name", "Unnamed ability")) for a in abilities if isinstance(a, dict)]
    unsupported.extend(str(rule) for rule in special_rules)
    composition = source.get("composition")
    if isinstance(composition, dict):
        low, high = composition.get("min_models"), composition.get("max_models")
        if not isinstance(low, int) or not isinstance(high, int) or low < 1 or high < low:
            warnings.append("Invalid source composition: verify model counts against another source")
    return {
        "id": f"openhammer:{edition}:{source['id']}", "name": str(source["name"]),
        "source_id": str(source["id"]), "faction": str(source.get("faction", "")),
        "stats": normalized_stats, "base": None,
        "composition": source.get("composition"), "points": source.get("points"),
        "weapons": source.get("weapons", {}), "keywords": source.get("keywords", []),
        "unsupported_rules": sorted(set(unsupported)), "warnings": warnings,
        "playable": False,
    }


def encode(value):
    return (json.dumps(value, ensure_ascii=False, indent=2, allow_nan=False) + "\n").encode("utf-8")


def write_pack(records, output, edition, source_url, revision=None):
    if not records:
        raise ValueError("No records returned; pack was not written")
    units = [normalize(record, edition) for record in records]
    ids = [unit["id"] for unit in units]
    if len(ids) != len(set(ids)):
        raise ValueError("Duplicate source IDs")
    content = encode(units)
    manifest = {
        "schema_version": 1, "id": f"openhammer-{edition}-reference", "edition": edition,
        "implementation": "reference-only", "units_sha256": hashlib.sha256(content).hexdigest(),
        "source": {"provider": "openhammer", "url": source_url, "revision": revision,
                   "records_sha256": hashlib.sha256(encode(records)).hexdigest(),
                   "retrieved_at": datetime.now(timezone.utc).isoformat(),
                   "license_status": "unverified"},
        "supported_mechanics": [],
    }
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    # Refuse overwrites: updates produce new reviewable snapshots.
    if (output / "manifest.json").exists() or (output / "units.json").exists():
        raise ValueError("Output already contains a pack; select a new directory")
    (output / "units.json").write_bytes(content)
    (output / "manifest.json").write_bytes(encode(manifest))
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--edition", choices=["10e", "11e"], required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--input", type=Path, help="Import an existing JSON array without network access")
    parser.add_argument("--name", help="Partial unit name; required for a live query")
    parser.add_argument("--faction", help="Exact provider faction name")
    parser.add_argument("--limit", type=int, default=2)
    parser.add_argument("--source-revision", help="Verified upstream release identifier, if known")
    args = parser.parse_args()
    if not 1 <= args.limit <= 50:
        parser.error("limit must be between 1 and 50")
    try:
        if args.input:
            records = json.loads(args.input.read_text(encoding="utf-8"))
            source_url = args.input.name
        else:
            if not args.name and not args.faction:
                parser.error("provide --name, --faction or --input")
            filters = {"limit": args.limit}
            if args.name:
                filters["name"] = args.name
            if args.faction:
                filters["faction"] = args.faction
            query = urllib.parse.urlencode(filters)
            source_url = f"{API}/v1/{args.edition}/units?{query}"
            request = urllib.request.Request(source_url, headers={"Accept": "application/json"})
            with urllib.request.urlopen(request, timeout=30) as response:
                body = response.read(8_000_001)
            if len(body) > 8_000_000:
                raise ValueError("Response exceeds import size limit")
            records = json.loads(body)
        if not isinstance(records, list):
            raise ValueError("Expected a JSON array of unit records")
        result = write_pack(records, args.output, args.edition, source_url, args.source_revision)
        print(f"Imported {len(records)} reference records: {result['units_sha256']}")
        print("Not playable: source version, geometry, and mechanics require verification.")
    except (ValueError, OSError) as error:
        parser.exit(1, f"Import failed: {error}\n")


if __name__ == "__main__":
    main()
