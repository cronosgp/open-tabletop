"""Capture and validate Wahapedia e11 exports. Audit data only; never enables rules."""
import argparse
import csv
from datetime import datetime, timezone, timedelta
import hashlib
import io
import json
from pathlib import Path
import urllib.parse
import urllib.request

BASE = "https://wahapedia.ru/wh40k11ed/"
SPEC = BASE + "Export%20Data%20Specs.xlsx?v=20260817b"
# Names/relationships from the English sheet of the linked export specification.
HEADERS = {
    "Factions": "id name link",
    "Source": "id name type edition version errata_date errata_link",
    "Datasheets": "id name faction_id source_id legend role loadout transport virtual is_support leader_head leader_footer damaged_w damaged_description link",
    "Datasheets_abilities": "datasheet_id line ability_id model name description type parameter",
    "Datasheets_keywords": "datasheet_id keyword model is_faction_keyword",
    "Datasheets_models": "datasheet_id line name M T Sv inv_sv inv_sv_descr W Ld OC base_size base_size_descr",
    "Datasheets_options": "datasheet_id line button description",
    "Datasheets_wargear": "datasheet_id line line_in_wargear dice name description range type A BS_WS S AP D",
    "Datasheets_unit_composition": "datasheet_id line description",
    "Datasheets_models_cost": "datasheet_id line description cost",
    "Datasheets_stratagems": "datasheet_id stratagem_id",
    "Datasheets_enhancements": "datasheet_id enhancement_id",
    "Datasheets_detachment_abilities": "datasheet_id detachment_ability_id",
    "Datasheets_leader": "leader_id attached_id",
    "Stratagems": "id faction_id name type cp_cost legend turn phase description detachment detachment_id",
    "Abilities": "id name legend faction_id description",
    "Enhancements": "id faction_id name legend description cost detachment detachment_id upgrade support_leader",
    "Enhancements_wargear": "enhancement_id line line_in_wargear dice name description range type A BS_WS S AP D",
    "Detachment_abilities": "id faction_id name legend description detachment detachment_id",
    "Detachments": "id faction_id name legend type dp force_disposition",
    "Detachments_chapter_dp": "detachment_id keyword dp",
    "Last_update": "last_update",
}
REFERENCES = {
    "faction_id": "Factions", "source_id": "Source", "datasheet_id": "Datasheets",
    "ability_id": "Abilities", "stratagem_id": "Stratagems",
    "enhancement_id": "Enhancements", "detachment_id": "Detachments",
    "detachment_ability_id": "Detachment_abilities",
    "leader_id": "Datasheets", "attached_id": "Datasheets",
}
BOOLS = {"Datasheets": ["virtual", "is_support"],
         "Datasheets_keywords": ["is_faction_keyword"], "Enhancements": ["upgrade"]}
RELATION_KEYS = {
    "Datasheets_keywords": ["datasheet_id", "keyword", "model"],
    "Datasheets_wargear": ["datasheet_id", "line", "line_in_wargear"],
    "Enhancements_wargear": ["enhancement_id", "line", "line_in_wargear"],
    "Datasheets_stratagems": ["datasheet_id", "stratagem_id"],
    "Datasheets_enhancements": ["datasheet_id", "enhancement_id"],
    "Datasheets_detachment_abilities": ["datasheet_id", "detachment_ability_id"],
    "Datasheets_leader": ["leader_id", "attached_id"],
    "Detachments_chapter_dp": ["detachment_id", "keyword"],
    "Last_update": ["last_update"],
}
MAX_BYTES = 32 * 1024 * 1024


def encode(value):
    return (json.dumps(value, ensure_ascii=False, indent=2) + "\n").encode("utf-8")


def sha(data):
    return hashlib.sha256(data).hexdigest()


def parse(name, data, notes=None, allow_empty=False):
    """Read strings without interpreting HTML or stripping leading zeroes in IDs."""
    reader = csv.reader(io.StringIO(data.decode("utf-8-sig"), newline=""), delimiter="|", strict=True)
    header = next(reader, [])
    # The publisher emits an empty trailing column after the final pipe.
    trailing = bool(header and header[-1] == "")
    if trailing:
        header.pop()
    if not header or len(header) != len(set(header)) or any(not h for h in header):
        raise ValueError(f"{name}: invalid/duplicate headers")
    missing = set(HEADERS[name].split()) - set(header)
    if missing:
        raise ValueError(f"{name}: missing headers {sorted(missing)}")
    rows, pending = [], []
    for cells in reader:
        if not cells or not any(cells):
            continue
        if pending:
            pending[-1] += "\n" + cells[0]
            pending.extend(cells[1:])
            cells = pending
        width = len(header) + int(trailing)
        if len(cells) < width and cells[-1] != "":
            if notes is not None:
                notes.append(f"{name}: continued unquoted text at physical line {reader.line_num}")
            pending = cells
            continue
        pending = []
        if trailing:
            if not cells or cells[-1] != "":
                raise ValueError(f"{name}: malformed trailing column at line {reader.line_num}")
            cells.pop()
        if len(cells) != len(header):
            raise ValueError(f"{name}: wrong column count at line {reader.line_num}")
        rows.append(dict(zip(header, cells)))
    if pending:
        raise ValueError(f"{name}: incomplete record at end of file")
    if not rows and not allow_empty:
        raise ValueError(f"{name}: empty table")
    return rows


def timestamp(rows):
    if len(rows) != 1:
        raise ValueError("Last_update must contain one timestamp")
    return datetime.strptime(rows[0]["last_update"], "%Y-%m-%d %H:%M:%S").replace(
        tzinfo=timezone(timedelta(hours=3))).isoformat()


def manifest_file_hash(manifest, name):
    """Accept both importer captures and the local raw-snapshot manifest."""
    files = manifest.get("files", {})
    if isinstance(files, dict):
        entry = files.get(name, files.get(name + ".csv", {}))
        return entry.get("sha256") if isinstance(entry, dict) else None
    if isinstance(files, list):
        for entry in files:
            if isinstance(entry, dict) and entry.get("filename") == name + ".csv":
                return entry.get("sha256")
    return None


def is_wahapedia_e11_manifest(manifest):
    return (manifest.get("provider") == "wahapedia"
            and manifest.get("edition") in ["11e", "Warhammer 40,000 11th edition"])


def load_snapshot(path):
    """Verify raw hashes before returning captured or explicitly scoped tables."""
    root = Path(path)
    manifest_bytes = (root / "manifest.json").read_bytes()
    manifest = json.loads(manifest_bytes)
    if not is_wahapedia_e11_manifest(manifest):
        raise ValueError("Expected a Wahapedia e11 snapshot")
    allow_empty = manifest.get("artifact_type") == "scoped_audit_slice"
    tables = {}
    for name in HEADERS:
        data = (root / "raw" / (name + ".csv")).read_bytes()
        if sha(data) != manifest["files"][name]["sha256"]:
            raise ValueError(f"Changed snapshot file: {name}")
        tables[name] = parse(name, data, allow_empty=allow_empty)
    if timestamp(tables["Last_update"]) != manifest["export_updated_at"]:
        raise ValueError("Export timestamp disagrees with manifest")
    if "catalog_sha256" in manifest:
        if sha((root / "catalog.json").read_bytes()) != manifest["catalog_sha256"]:
            raise ValueError("Changed snapshot catalog")
    return manifest, tables, sha(manifest_bytes)


def validate(tables, notes=None):
    errors = []
    ids = {}
    for name, rows in tables.items():
        if "id" in HEADERS[name].split():
            keys = [(r["id"], r["faction_id"]) if name == "Abilities" else r["id"] for r in rows]
            if any(not r["id"] for r in rows) or len(keys) != len(set(keys)):
                errors.append(f"{name}: empty or duplicate primary ID")
            ids[name] = {r["id"] for r in rows}
            if name == "Abilities":
                definitions = {}
                for row in rows:
                    definition = {k: v for k, v in row.items() if k != "faction_id"}
                    if row["id"] in definitions:
                        if definitions[row["id"]] != definition:
                            errors.append(f"Abilities: conflicting definition for shared ID {row['id']}")
                        elif notes is not None:
                            notes.append(f"Abilities: shared ID {row['id']} also linked to faction {row['faction_id']}")
                    definitions[row["id"]] = definition
    for name, rows in tables.items():
        keys = {}
        for number, row in enumerate(rows, 1):
            # Relational uniqueness is separate from the referenced primary IDs.
            if "id" not in row:
                columns = RELATION_KEYS.get(name, ["datasheet_id", "line"])
                if name == "Datasheets_wargear" and not row["line"]:
                    columns = ["datasheet_id", "name", "type", "dice", "line_in_wargear"]
                    if notes is not None:
                        notes.append(f"{name} row {number}: missing weapon ordinal; indexed by scoped name, not source order")
                key = tuple(row[k] for k in columns)
                if key in keys:
                    if keys[key] != row:
                        errors.append(f"{name} row {number}: duplicate relation/line with conflicting values")
                    elif notes is not None:
                        notes.append(f"{name} row {number}: identical repeated relation retained in raw data")
                keys[key] = row
            for column, target in REFERENCES.items():
                if column in row and not row[column] and column in ["datasheet_id", "leader_id", "attached_id", "enhancement_id", "stratagem_id", "detachment_ability_id", "detachment_id"] and name not in ["Stratagems", "Enhancements", "Detachment_abilities"]:
                    errors.append(f"{name} row {number}: missing {column}")
                if column in row and row[column] and row[column] not in ids[target]:
                    errors.append(f"{name} row {number}: unknown {column}={row[column]}")
            for column in BOOLS.get(name, []):
                if row[column] not in ["true", "false"]:
                    errors.append(f"{name} row {number}: invalid boolean {column}")
            if name == "Datasheets" and (not row["source_id"] or not row["faction_id"]):
                errors.append(f"{name} row {number}: missing source/faction identity")
    return errors


def marine_index(tables):
    factions = {r["id"] for r in tables["Factions"]
                if urllib.parse.urlsplit(r["link"]).path.rstrip("/") == "/wh40k11ed/factions/space-marines"}
    if len(factions) != 1:
        raise ValueError("Expected exactly one Space Marines faction identity")
    sources = {r["id"]: r for r in tables["Source"]}
    output = []
    for row in tables["Datasheets"]:
        if row["faction_id"] not in factions:
            continue
        source = sources.get(row["source_id"], {})
        link = urllib.parse.urlsplit(row["link"])
        current = source.get("edition") == "11" and link.hostname in ["wahapedia.ru", "www.wahapedia.ru"] and link.path.startswith("/wh40k11ed/")
        # Source edition is only an edition boundary, not proof of Codex membership.
        output.append({"id": "wahapedia:11e:" + row["id"], "source_id": row["id"],
                       "name": row["name"], "url": row["link"], "book": source,
                       "edition_11_candidate": current, "playable": False,
                       "scope_status": "source_book_and_game_mode_review_required" if current else "excluded_edition_or_source_boundary"})
    if not output:
        raise ValueError("No Space Marines candidates found")
    return sorted(output, key=lambda r: (r["name"], r["source_id"]))


def fetch(name):
    url = BASE + name + ".csv"
    request = urllib.request.Request(url, headers={"User-Agent": "OpenTabletop-rules-import/1"})
    with urllib.request.urlopen(request, timeout=45) as response:
        final = response.geturl()
        parsed = urllib.parse.urlsplit(final)
        if parsed.scheme != "https" or parsed.hostname not in ["wahapedia.ru", "www.wahapedia.ru"] or not parsed.path.startswith("/wh40k11ed/"):
            raise ValueError(f"Unexpected export redirect: {final}")
        data = response.read(MAX_BYTES + 1)
    if len(data) > MAX_BYTES:
        raise ValueError(f"{name}: file too large")
    return data, {"requested_url": url, "final_url": final,
                  "retrieved_at": datetime.now(timezone.utc).isoformat(),
                  "sha256": sha(data), "bytes": len(data)}


def capture(output, input_dir=None):
    output = Path(output)
    if output.exists():
        raise ValueError("Output already exists; use a fresh snapshot directory")
    output.mkdir(parents=True)
    raw = output / "raw"
    raw.mkdir()
    (output / "capture-status.json").write_bytes(encode({"status": "incomplete", "playable": False}))
    blobs, provenance, tables = {}, {}, {}
    notes = []
    input_manifest = None
    input_manifest_digest = None
    input_snapshot_id = None
    if input_dir is not None:
        input_path = Path(input_dir)
        manifest_paths = [input_path / "manifest.json", input_path.parent / "manifest.json"]
        parent_path = next((path for path in manifest_paths if path.is_file()), None)
    else:
        parent_path = None
    if parent_path is not None:
        parent_data = parent_path.read_bytes()
        input_manifest = json.loads(parent_data)
        if not is_wahapedia_e11_manifest(input_manifest):
            raise ValueError("Offline parent manifest is not Wahapedia e11")
        input_manifest_digest = sha(parent_data)
        input_snapshot_id = input_manifest.get("snapshot_id")
    if input_dir is None:
        before, before_meta = fetch("Last_update")
        before_stamp = timestamp(parse("Last_update", before))
    else:
        before = (Path(input_dir) / "Last_update.csv").read_bytes()
        before_meta = {"local_path": str((Path(input_dir) / "Last_update.csv").resolve()), "sha256": sha(before)}
        before_stamp = timestamp(parse("Last_update", before))
        if input_manifest is not None and input_manifest.get("export_updated_at"):
            if input_manifest["export_updated_at"] != before_stamp:
                raise ValueError("Export timestamp disagrees with offline parent manifest")
    for name in HEADERS:
        if name == "Last_update":
            data, meta = before, before_meta
        elif input_dir is None:
            data, meta = fetch(name)
        else:
            source = Path(input_dir) / (name + ".csv")
            data = source.read_bytes()
            meta = {"local_path": str(source.resolve()), "sha256": sha(data), "bytes": len(data)}
        blobs[name] = data
        if input_manifest is not None:
            expected_hash = manifest_file_hash(input_manifest, name)
            if not expected_hash:
                raise ValueError(f"Offline parent manifest has no hash for {name}.csv")
            if sha(data) != expected_hash:
                raise ValueError(f"Changed offline snapshot file: {name}")
        (raw / (name + ".csv")).write_bytes(data)
        provenance[name] = meta
        (output / "capture-status.json").write_bytes(encode({"status": "incomplete", "playable": False, "files": provenance}))
        tables[name] = parse(name, data, notes)
    after_meta = None
    if input_dir is None:
        after, after_meta = fetch("Last_update")
        if timestamp(parse("Last_update", after)) != before_stamp:
            raise ValueError("Export changed during download; retry in a fresh directory")
    errors = validate(tables, notes)
    index = marine_index(tables)
    manifest = {"schema_version": 1, "provider": "wahapedia", "edition": "11e",
                "source_policy": "wahapedia-e11-definitive-2026-10-18",
                "specification": SPEC, "export_updated_at": before_stamp,
                "mode": "local_files" if input_dir else "live_download",
                "input_snapshot_id": input_snapshot_id,
                "input_manifest_sha256": input_manifest_digest,
                "live_timestamp_bracket_checked": input_dir is None,
                "last_update_after": after_meta, "files": provenance,
                "table_rows": {name: len(rows) for name, rows in tables.items()},
                "validation_errors": errors, "structurally_valid": not errors,
                "parser_notes": notes,
                "marine_candidates": len(index), "marine_index_sha256": sha(encode(index)),
                "implementation": "audit-only", "playable": False}
    (output / "space-marines-index.json").write_bytes(encode(index))
    (output / "manifest.json").write_bytes(encode(manifest))
    (output / "capture-status.json").write_bytes(encode({"status": "complete", "structurally_valid": not errors, "playable": False}))
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--input-dir", type=Path, help="Offline CSV directory; no live freshness claim")
    args = parser.parse_args()
    try:
        manifest = capture(args.output, args.input_dir)
    except (ValueError, OSError, csv.Error) as error:
        parser.exit(1, str(error) + "\n")
    print(json.dumps({"output": str(args.output), "export_updated_at": manifest["export_updated_at"],
                      "marine_candidates": manifest["marine_candidates"],
                      "validation_error_count": len(manifest["validation_errors"]),
                      "first_errors": manifest["validation_errors"][:10]}, indent=2))
    return 0 if manifest["structurally_valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
