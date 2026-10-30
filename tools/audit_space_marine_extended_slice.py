"""Verify per-sheet completeness of one local Wahapedia scoped audit slice.

This tool reads only a user-prepared, locally hash-verified Data Export slice.
It does not download data, convert a datasheet into a playable profile, or admit
anything to the runtime catalog.
"""

import argparse
import csv
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys


TABLES = (
    "Source",
    "Datasheets",
    "Datasheets_abilities",
    "Datasheets_keywords",
    "Datasheets_models",
    "Datasheets_options",
    "Datasheets_wargear",
    "Datasheets_unit_composition",
    "Datasheets_models_cost",
    "Datasheets_leader",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_table(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as source:
        return list(csv.DictReader(source, delimiter="|"))


def fail(message: str) -> None:
    raise ValueError(message)


def audit_slice(root: Path, expected_book_id: str, expected_count: int | None) -> dict:
    root = root.resolve()
    manifest_path = root / "manifest.json"
    catalog_path = root / "catalog.json"
    if not manifest_path.is_file() or not catalog_path.is_file():
        fail(f"Missing manifest.json or catalog.json in {root}")

    manifest_bytes = manifest_path.read_bytes()
    manifest = json.loads(manifest_bytes)
    if manifest.get("provider") != "wahapedia" or manifest.get("edition") != "11e":
        fail("Slice is not a Wahapedia 11e artifact")
    if manifest.get("artifact_type") != "scoped_audit_slice":
        fail("Artifact is not an exact scoped audit slice")
    if manifest.get("structurally_valid") is not True or manifest.get("validation_errors"):
        fail("Scoped slice is not structurally valid")
    book = manifest.get("source_book", {})
    if str(book.get("id", "")) != expected_book_id or str(book.get("edition", "")) != "11":
        fail("Source book ID/edition does not match the requested current scope")
    if not manifest.get("parent_manifest_sha256") or not manifest.get("export_updated_at"):
        fail("Slice is missing parent snapshot provenance")

    file_records = manifest.get("files", {})
    local_hashes = {}
    for table, record in file_records.items():
        path = root / "raw" / f"{table}.csv"
        if not path.is_file():
            fail(f"Missing source table: {path.name}")
        actual = sha256(path)
        if actual != record.get("sha256") or path.stat().st_size != record.get("bytes"):
            fail(f"Source table hash/size mismatch: {path.name}")
        local_hashes[path.name] = actual
    missing_tables = sorted(set(TABLES) - set(file_records))
    if missing_tables:
        fail("Required tables missing from manifest: " + ", ".join(missing_tables))
    if sha256(catalog_path) != manifest.get("catalog_sha256"):
        fail("Derived slice catalog does not match its manifest")

    source_tables = {name: read_table(root / "raw" / f"{name}.csv") for name in TABLES}
    subject_ids = manifest.get("subject_datasheet_ids", [])
    if len(subject_ids) != len(set(subject_ids)) or (expected_count is not None and len(subject_ids) != expected_count):
        fail("Subject identity count/uniqueness does not match the requested scope")
    subjects = set(subject_ids)
    sources = {row["id"]: row for row in source_tables["Source"]}
    datasheets = [row for row in source_tables["Datasheets"] if row.get("id") in subjects]
    if {row.get("id") for row in datasheets} != subjects or len(datasheets) != len(subjects):
        fail("Subject datasheet rows are missing or duplicated")

    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    catalog_units = {unit.get("source_datasheet", {}).get("id"): unit for unit in catalog.get("units", [])}
    if set(catalog_units) != subjects or len(catalog_units) != len(subjects):
        fail("Derived local slice catalog does not cover the exact subject set")
    if catalog.get("playable") is not False:
        fail("Audit-only slice unexpectedly claims to be playable")

    profiles = []
    totals = {name: 0 for name in TABLES if name.startswith("Datasheets_")}
    for sheet in sorted(datasheets, key=lambda row: row["id"]):
        identity = sheet["id"]
        book_id = str(sheet.get("source_id", ""))
        source_book = sources.get(book_id, {})
        if book_id != expected_book_id or str(source_book.get("edition", "")) != "11":
            fail(f"Subject {identity} has a non-11e or mismatched source book")
        unit = catalog_units[identity]
        for table_name in totals:
            if table_name == "Datasheets_leader":
                # This table stores candidate Leaders on the attached bodyguard ID.
                rows = [row for row in source_tables[table_name] if row.get("attached_id") == identity]
            else:
                rows = [row for row in source_tables[table_name] if row.get("datasheet_id") == identity]
            totals[table_name] += len(rows)
            if len(rows) != len(unit.get(_catalog_field(table_name), [])):
                fail(f"Source/catalog row-count mismatch for {identity} in {table_name}")

        required_sections = ("models", "weapons", "composition", "costs", "abilities")
        empty_sections = [field for field in required_sections if not unit.get(field)]
        has_source_loadout = bool(str(sheet.get("loadout", "")).strip())
        has_explicit_model_equipment = any(
            "is equipped with:" in str(option.get("description", "")).casefold()
            for option in unit.get("options", [])
        )
        missing_core = [field for field in ("name", "source_id") if not str(sheet.get(field, "")).strip()]
        if not has_source_loadout and not has_explicit_model_equipment:
            missing_core.append("default_equipment")
        if empty_sections or missing_core:
            fail(f"Subject {identity} lacks required source fields/rows: {empty_sections + missing_core}")
        price_rows = [row for row in unit["costs"] if str(row.get("cost", "")).strip()]
        if not price_rows:
            fail(f"Subject {identity} has no numeric points rows")
        profiles.append({
            "source_datasheet_id": identity,
            "source_book_id": book_id,
            "name": sheet["name"],
            "role": sheet.get("role", ""),
            "source_url": sheet.get("link", ""),
            "model_role_rows": len(unit.get("models", [])),
            "weapon_profile_rows": len(unit.get("weapons", [])),
            "option_rows": len(unit.get("options", [])),
            "composition_rows": len(unit.get("composition", [])),
            "priced_cost_rows": len(price_rows),
            "ability_rows": len(unit.get("abilities", [])),
            "leader_link_rows": len(unit.get("leader_links", [])),
            "default_equipment_source": "sheet_loadout" if has_source_loadout else "per_model_options",
            "runtime_admitted": False,
            "playable_certified": False,
        })

    return {
        "schema_version": 1,
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "provider": "wahapedia",
        "edition": "11e",
        "slice_id": manifest.get("source_policy"),
        "source_book": book,
        "export_updated_at": manifest["export_updated_at"],
        "parent_manifest_sha256": manifest["parent_manifest_sha256"],
        "slice_manifest_sha256": hashlib.sha256(manifest_bytes).hexdigest(),
        "slice_catalog_sha256": manifest["catalog_sha256"],
        "slice_structurally_valid": True,
        "slice_validation_error_count": 0,
        "parent_validation_error_count": len(manifest.get("parent_validation_errors", [])),
        "subject_count": len(profiles),
        "required_source_sections_present": True,
        "source_row_counts": totals,
        "local_source_file_sha256": local_hashes,
        "runtime_admitted_count": sum(profile["runtime_admitted"] for profile in profiles),
        "playable_certified_count": sum(profile["playable_certified"] for profile in profiles),
        "profiles": profiles,
        "scope_note": "Source-slice completeness only. Runtime admission, rule implementation, legal roster interaction and game-mode approval require separate checks.",
    }


def _catalog_field(table_name: str) -> str:
    return {
        "Datasheets_abilities": "abilities",
        "Datasheets_keywords": "keywords",
        "Datasheets_models": "models",
        "Datasheets_options": "options",
        "Datasheets_wargear": "weapons",
        "Datasheets_unit_composition": "composition",
        "Datasheets_models_cost": "costs",
        "Datasheets_leader": "leader_links",
    }[table_name]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--slice-root", type=Path, required=True, help="Local directory containing manifest.json, catalog.json and raw/")
    parser.add_argument("--expected-book-id", required=True)
    parser.add_argument("--expected-count", type=int)
    parser.add_argument("--output", type=Path, required=True, help="Output JSON path; should be under ignored .tools/")
    args = parser.parse_args()
    try:
        result = audit_slice(args.slice_root, args.expected_book_id, args.expected_count)
        output = args.output.resolve()
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f"Space Marine source-slice audit failed: {error}", file=sys.stderr)
        return 1
    print(
        f"Verified {result['subject_count']} subjects with required source rows from book "
        f"{result['source_book']['id']} ({result['source_book']['edition']}e); "
        "runtime-admitted=0, playable-certified=0."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
