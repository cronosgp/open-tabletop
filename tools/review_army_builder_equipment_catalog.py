"""Classify unreviewed admitted equipment against explicitly supplied local exports.

Writes project-owned review metadata only. Raw exports remain local. Source-listed
options are migration work, not implemented controls or certified army legality.
"""
import argparse
import csv
import json
from pathlib import Path

from audit_army_builder_equipment_reviews import snapshot, table
from render_army_builder_coverage import review_matches


def classify(record, sources, reviewed_on):
    basis = "verified_against" if record.get("source_verified_against_snapshot_id") else "extraction"
    prefix = "source_verified_against_" if basis == "verified_against" else "source_"
    identity = (record.get(prefix + "snapshot_id"), record.get(prefix + "manifest_sha256"))
    if identity not in sources:
        raise ValueError(f"No verified supplied snapshot for {record['identity']}: {identity}")
    source = sources[identity]
    sheet_id = record["source_datasheet_id"]
    sheet = source["sheets"].get(sheet_id)
    book = source["books"].get(record["source_book_id"])
    if not sheet or not book or book["edition"] != "11" or sheet["source_id"] != book["id"]:
        raise ValueError(f"Book/datasheet/edition mismatch for {record['identity']}")
    if not sheet.get("loadout", "").strip():
        raise ValueError(f"Missing default equipment requires individual review: {record['identity']}")
    count = len(source["options"].get(sheet_id, []))
    option_kinds = record.get("source_option_kinds", [])
    composition_only = (
        count > 0
        and len(option_kinds) == count
        and all(kind == "size_scaled_wargear_count" for kind in option_kinds)
    )
    classification = "equipment_options_present" if count and not composition_only else "fixed_equipment_no_options"
    review = {"identity": record["identity"], "classification": classification,
              "review_method": "export_equipment_classification",
              "source_book_id": book["id"], "source_datasheet_id": sheet_id,
              "source_review_basis": basis, "source_snapshot_id": identity[0],
              "source_manifest_sha256": identity[1], "source_digest": record["source_digest"],
              "reviewed_on": reviewed_on,
              "summary": f"Verified local Wahapedia 11e {book['type']} book {book['id']} v{book.get('version', '')}; "
                         f"snapshot {identity[0]}, export revision {source['metadata']['export_updated_at']}. "
                         f"Nonempty default equipment and {count} source-listed option rows. "
                         + ("All option rows are size-scaled model-composition wargear, not equipment loadout choices. " if composition_only else
                            "Equipment options require migration and source-specific validation. " if count else "No optional-equipment rows in this source scope. ")
                         + "Equipment classification only; no rules or army-legality certification.",
              "evidence": "../verification/army-builder-equipment-classification.md"}
    if not review_matches(record, review):
        raise ValueError(f"Incomplete or stale runtime provenance for {record['identity']}")
    return review


def load_source(root):
    raw, metadata = snapshot(root)
    options = {}
    for option in table(raw, "Datasheets_options.csv"):
        options.setdefault(option["datasheet_id"], []).append(option)
    return {"metadata": metadata, "sheets": {row["id"]: row for row in table(raw, "Datasheets.csv")},
            "books": {row["id"]: row for row in table(raw, "Source.csv")}, "options": options}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime-audit", type=Path, required=True)
    parser.add_argument("--source-review", type=Path, default=Path("docs/project/army-builder-source-review.tsv"))
    parser.add_argument("--snapshot", type=Path, action="append", required=True)
    parser.add_argument("--reviewed-on", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--update-registry", action="store_true")
    args = parser.parse_args()
    sources = {}
    for root in args.snapshot:
        source = load_source(root)
        metadata = source["metadata"]
        sources[(metadata["snapshot_id"], metadata["manifest_sha256"])] = source
    with args.source_review.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        fields, existing = list(reader.fieldnames), list(reader)
    identities = {review["identity"] for review in existing}
    if len(identities) != len(existing):
        raise ValueError("Duplicate source-review identities")
    runtime = json.loads(args.runtime_audit.read_text(encoding="utf-8"))
    generated = {review["identity"] for review in existing
                 if review.get("review_method") == "export_equipment_classification"}
    candidates = [classify(record, sources, args.reviewed_on) for record in runtime["records"]
                  if not record["saved_fields"] and (record["identity"] not in identities or record["identity"] in generated)]
    report = {"scope": "Equipment-source classification only; optional choices still require migration.",
              "snapshots": [source["metadata"] for source in sources.values()], "reviews": candidates}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    if args.update_registry:
        with args.source_review.open("w", encoding="utf-8", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=fields, delimiter="\t")
            writer.writeheader()
            replacements = {row["identity"]: row for row in candidates}
            writer.writerows([replacements.get(row["identity"], row) for row in existing]
                             + [row for row in candidates if row["identity"] not in identities])
    print(f"Source-classified {len(candidates)} profiles: "
          f"{sum(row['classification'] == 'fixed_equipment_no_options' for row in candidates)} fixed, "
          f"{sum(row['classification'] == 'equipment_options_present' for row in candidates)} with options")


if __name__ == "__main__":
    main()
