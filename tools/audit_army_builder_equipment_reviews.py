"""Check fixed-equipment review continuity against two local Wahapedia exports.

No downloads, raw-data output, runtime mutations or registry updates are performed.
The ignored report establishes equipment-review provenance, not rules certification.
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path

from render_army_builder_coverage import review_matches


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot(root):
    manifest_path = root / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("edition") != "11e":
        raise ValueError(f"Not an 11e snapshot: {root}")
    files = manifest["files"]
    if isinstance(files, dict):
        if manifest.get("provider") != "wahapedia":
            raise ValueError("Not a Wahapedia export")
        raw = root / "raw"
        entries = [(name + ".csv", entry) for name, entry in files.items()]
    else:
        if manifest.get("source_page") != "https://wahapedia.ru/wh40k11ed/the-rules/data-export/":
            raise ValueError("Not the selected Wahapedia export page")
        raw = root
        entries = [(entry["filename"], entry) for entry in files]
    hashes = {}
    for filename, entry in entries:
        if Path(filename).name != filename:
            raise ValueError(f"Invalid source filename: {filename}")
        actual = digest(raw / filename)
        if actual != entry["sha256"]:
            raise ValueError(f"Source hash mismatch: {root / filename}")
        hashes[filename] = actual
    for filename in ("Source.csv", "Datasheets.csv", "Datasheets_options.csv"):
        if filename not in hashes:
            raise ValueError(f"Required source table absent from manifest: {filename}")
    return raw, {
        "snapshot_id": manifest.get("snapshot_id", root.name),
        "manifest_sha256": digest(manifest_path),
        "retrieved_at_utc": manifest.get("retrieved_at_utc", manifest.get("last_update_after", {}).get("retrieved_at")),
        "export_updated_at": manifest.get("export_updated_at", manifest.get("source_export_updated_at")),
        "verified_file_hashes": hashes,
    }


def table(raw, name):
    with (raw / name).open(encoding="utf-8-sig", newline="") as source:
        return list(csv.DictReader(source, delimiter="|"))


def audit(runtime, reviews, previous_root, current_root):
    previous_raw, previous = snapshot(previous_root)
    current_raw, current = snapshot(current_root)
    old_sheets = {row["id"]: row for row in table(previous_raw, "Datasheets.csv")}
    new_sheets = {row["id"]: row for row in table(current_raw, "Datasheets.csv")}
    books = {row["id"]: row for row in table(current_raw, "Source.csv")}
    option_ids = {row["datasheet_id"] for row in table(current_raw, "Datasheets_options.csv")}
    old_option_ids = {row["datasheet_id"] for row in table(previous_raw, "Datasheets_options.csv")}
    records = {record["identity"]: record for record in runtime["records"]}
    checked = []
    for review in reviews:
        if review.get("review_method") != "fixed_equipment_continuity":
            continue
        if review.get("source_review_basis") != "verified_against":
            raise ValueError("Continuity review must bind to runtime verification provenance")
        identity = review["identity"]
        record = records[identity]
        if review["classification"] != "fixed_equipment_no_options" or record["saved_fields"]:
            raise ValueError(f"Not a fixed-equipment continuity review: {identity}")
        if not review_matches(record, review):
            raise ValueError(f"Runtime review provenance mismatch: {identity}")
        if (review["source_snapshot_id"] != current["snapshot_id"]
                or review["source_manifest_sha256"] != current["manifest_sha256"]):
            raise ValueError(f"Review does not name the supplied snapshot: {identity}")
        sheet_id = review["source_datasheet_id"]
        before, after = old_sheets[sheet_id], new_sheets[sheet_id]
        book = books[review["source_book_id"]]
        if book["edition"] != "11":
            raise ValueError(f"Wrong book edition: {identity}")
        if before["source_id"] != book["id"] or after["source_id"] != book["id"]:
            raise ValueError(f"Wrong source book: {identity}")
        if sheet_id in option_ids or sheet_id in old_option_ids:
            raise ValueError(f"Equipment options require individual review: {identity}")
        for field in ("loadout", "source_id", "legend", "faction_id"):
            if before[field] != after[field]:
                raise ValueError(f"Changed {field} requires individual review: {identity}")
        checked.append({"identity": identity, "source_book_id": book["id"],
                        "source_datasheet_id": sheet_id, "source_book_name": book["name"],
                        "source_book_type": book["type"], "flavour_text_unchanged": True,
                        "loadout_unchanged": True, "option_rows": 0})
    if not checked:
        raise ValueError("No verified-against equipment reviews selected")
    return {"scope": "Fixed-equipment source continuity only; no rules, visual, army-legality or LAN certification.",
            "previous": previous, "current": current, "checked": checked}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime-audit", type=Path, required=True)
    parser.add_argument("--source-review", type=Path, default=Path("docs/project/army-builder-source-review.tsv"))
    parser.add_argument("--previous", type=Path, required=True)
    parser.add_argument("--current", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    with args.source_review.open(encoding="utf-8", newline="") as source:
        reviews = list(csv.DictReader(source, delimiter="\t"))
    result = audit(json.loads(args.runtime_audit.read_text(encoding="utf-8")), reviews,
                   args.previous, args.current)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"Verified fixed-equipment continuity for {len(result['checked'])} runtime profiles")


if __name__ == "__main__":
    main()
