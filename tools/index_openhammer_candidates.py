"""Build a local identity-only index from the OpenHammer planner cache.

This cache omits datasheet characteristics, weapons, and ability records. The
output is useful for finding candidate names and preserving provider IDs; it
must never be loaded as a playable data pack.
"""
import argparse
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CACHE = ROOT / ".tools" / "army-live" / "catalogs" / "11e.json"
DEFAULT_LEDGER = ROOT / "docs" / "space-marines-rules-ledger.json"
DEFAULT_OUTPUT = ROOT / ".tools" / "openhammer-api" / "space-marines-candidate-index.json"


def digest_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def normalized_name(value: str) -> str:
    folded = unicodedata.normalize("NFKD", value).casefold()
    ascii_text = "".join(char for char in folded if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", " ", ascii_text).strip()


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"Cannot read {path}: {error}") from error


def build(cache: dict, ledger: dict, cache_digest: str, ledger_path: Path) -> dict:
    if not isinstance(cache, dict) or cache.get("edition") != "11e" or not isinstance(cache.get("units"), list):
        raise ValueError("Planner cache must be an 11e object with a units array")
    if not isinstance(ledger, dict) or ledger.get("edition") != "11th":
        raise ValueError("Rules ledger must target 11th edition")

    units = cache["units"]
    marine_records = [unit for unit in units if isinstance(unit, dict) and unit.get("faction") == "Space Marines"]
    seen_ids = set()
    for unit in marine_records:
        source_id = unit.get("source_id")
        name = unit.get("name")
        if not isinstance(source_id, str) or not source_id or not isinstance(name, str) or not name:
            raise ValueError("Every Space Marines candidate requires a name and provider source_id")
        if source_id in seen_ids:
            raise ValueError(f"Duplicate OpenHammer source_id: {source_id}")
        seen_ids.add(source_id)

    official_candidates = ledger.get("datasheets", [])
    official_by_name = {}
    for sheet in official_candidates:
        if isinstance(sheet, dict) and isinstance(sheet.get("name"), str):
            official_by_name.setdefault(normalized_name(sheet["name"]), []).append(sheet)

    indexed = []
    for unit in sorted(marine_records, key=lambda item: (normalized_name(item["name"]), item["source_id"])):
        matches = official_by_name.get(normalized_name(unit["name"]), [])
        indexed.append({
            "candidate_id": f"openhammer:11e:Space Marines:{unit['source_id']}",
            "name": unit["name"],
            "provider": "OpenHammer",
            "provider_source_id": unit["source_id"],
            "faction_bucket": unit["faction"],
            "candidate_keywords": unit.get("keywords", []),
            "candidate_role": unit.get("role"),
            "candidate_options": unit.get("options", []),
            "composition_bounds_valid_in_cache": unit.get("composition_bounds_valid"),
            "composition_verified": False,
            "profile_details_in_cache": False,
            "matched_rules_ledger_ids_by_name_only": [sheet.get("id") for sheet in matches],
            "identity_status": "provider_candidate_unreconciled",
            "playable": False,
        })

    return {
        "index_id": "openhammer-space-marines-11e-candidate-index",
        "schema_version": 1,
        "edition": "11th",
        "status": "identity_only_reference",
        "generated_from": {
            "provider": cache.get("provider", "OpenHammer"),
            "catalog_url": cache.get("url"),
            "retrieved_at": cache.get("fetched_at"),
            "planner_catalog_digest": cache.get("digest"),
            "source_file_sha256": cache_digest,
            "rules_ledger": str(ledger_path),
        },
        "limitations": [
            "The local planner cache is an identity/roster index and omits stats, weapons, and ability records.",
            "Name matches are hints only; book identity, chapter, mode, current profile, and matched-play status are unresolved.",
            "All candidates remain unplayable until checked against the current e11 reference and applicable official sources.",
        ],
        "candidate_count": len(indexed),
        "candidates": indexed,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cache", type=Path, default=DEFAULT_CACHE)
    parser.add_argument("--ledger", type=Path, default=DEFAULT_LEDGER)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    try:
        cache_bytes = args.cache.read_bytes()
        cache = json.loads(cache_bytes.decode("utf-8"))
        ledger = load_json(args.ledger)
        result = build(cache, ledger, digest_bytes(cache_bytes), args.ledger)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        if args.output.exists():
            raise ValueError(f"Output already exists; remove it or choose another path: {args.output}")
        args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        exact_matches = sum(bool(item["matched_rules_ledger_ids_by_name_only"]) for item in result["candidates"])
        print(f"Wrote {result['candidate_count']} identity-only candidates ({exact_matches} name matches) to {args.output}")
        print("No characteristics, weapons, ability text, or playable profiles were generated.")
        return 0
    except (OSError, UnicodeError, json.JSONDecodeError, ValueError) as error:
        print(f"Candidate indexing failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
