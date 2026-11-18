"""Render the local Godot coverage audit as a reviewable TSV and Markdown summary."""
import argparse
import collections
import csv
import json
from pathlib import Path


def review_matches(record, review):
    """Keep extraction and subsequent verification provenance as distinct pairs."""
    if any(str(record.get(field, "")) != review.get(field, "") for field in (
        "source_book_id", "source_datasheet_id", "source_digest",
    )):
        return False
    basis = review.get("source_review_basis", "extraction")
    if basis == "extraction":
        snapshot_key, manifest_key = "source_snapshot_id", "source_manifest_sha256"
    elif basis == "verified_against":
        snapshot_key = "source_verified_against_snapshot_id"
        manifest_key = "source_verified_against_manifest_sha256"
        if not record.get("source_verified_against_slice_manifest_sha256"):
            return False
    else:
        return False
    return all(
        bool(review.get(review_key))
        and str(record.get(record_key, "")) == review[review_key]
        for record_key, review_key in (
            (snapshot_key, "source_snapshot_id"),
            (manifest_key, "source_manifest_sha256"),
        )
    )


def schema_review_matches(record, review):
    """A schema needs an explicit source audit bound to its exact saved fields."""
    return (
        review.get("classification") == "saved_equipment_options_reviewed"
        and review.get("review_method") == "saved_equipment_source_audit"
        and bool(record.get("saved_fields"))
        and bool(review.get("evidence"))
        and review_matches(record, review)
        and sorted(record["saved_fields"]) == sorted(review.get("schema_fields", "").split(";"))
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument(
        "--source-review",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "docs/project/army-builder-source-review.tsv",
    )
    args = parser.parse_args()
    audit = json.loads(args.input.read_text(encoding="utf-8"))
    records = audit["records"]
    reviews = {}
    if args.source_review.exists():
        with args.source_review.open(encoding="utf-8", newline="") as source:
            for row in csv.DictReader(source, delimiter="\t"):
                identity = row["identity"]
                if not identity or identity in reviews:
                    raise ValueError(f"Duplicate or empty equipment review identity: {identity!r}")
                reviews[identity] = row

    reviewed_fixed = 0
    reviewed_schemas = 0
    reviewed_options = 0
    waiting_source_review = 0
    stale_source_review = 0
    for record in records:
        identity = record["identity"]
        review = reviews.get(identity)
        record["equipment_review_classification"] = "unreviewed"
        record["equipment_review_summary"] = ""
        record["equipment_review_evidence"] = ""
        record["equipment_reviewed_on"] = ""
        record["equipment_review_source_basis"] = review.get("source_review_basis", "extraction") if review else ""
        record["equipment_review_method"] = review.get("review_method", "per_datasheet_audit") if review else ""
        record["equipment_review_snapshot_id"] = review.get("source_snapshot_id", "") if review else ""
        record["equipment_review_manifest_sha256"] = review.get("source_manifest_sha256", "") if review else ""
        if record["saved_fields"] or (review and review.get("classification") == "saved_equipment_options_reviewed"):
            record["status"] = "saved_schema_present_review_scope"
            record["equipment_review_classification"] = "saved_schema_source_review_required"
            if review and review.get("classification") == "saved_equipment_options_reviewed":
                if schema_review_matches(record, review):
                    record["status"] = "saved_schema_source_reviewed"
                    record["equipment_review_classification"] = review["classification"]
                    reviewed_schemas += 1
                else:
                    record["status"] = "saved_schema_review_stale"
                    record["equipment_review_classification"] = "source_review_stale"
                    stale_source_review += 1
                record["equipment_review_summary"] = review.get("summary", "")
                record["equipment_review_evidence"] = review.get("evidence", "")
                record["equipment_reviewed_on"] = review.get("reviewed_on", "")
            continue
        if not review:
            record["status"] = "source_classification_required"
            waiting_source_review += 1
            continue

        if not review_matches(record, review):
            record["status"] = "source_review_stale"
            record["equipment_review_classification"] = "source_review_stale"
            record["equipment_review_summary"] = review.get("summary", "")
            record["equipment_review_evidence"] = review.get("evidence", "")
            record["equipment_reviewed_on"] = review.get("reviewed_on", "")
            stale_source_review += 1
            continue

        classification = review.get("classification", "")
        if classification not in ("fixed_equipment_no_options", "equipment_options_present"):
            raise ValueError(f"Unsupported equipment classification {classification!r} for {identity}")
        record["status"] = "equipment_migration_required" if classification == "equipment_options_present" else "fixed_equipment_source_reviewed"
        record["equipment_review_classification"] = classification
        record["equipment_review_summary"] = review.get("summary", "")
        record["equipment_review_evidence"] = review.get("evidence", "")
        record["equipment_reviewed_on"] = review.get("reviewed_on", "")
        if classification == "equipment_options_present":
            reviewed_options += 1
        else:
            reviewed_fixed += 1

    args.output.mkdir(parents=True, exist_ok=True)
    fields = list(records[0])
    with (args.output / "army-builder-coverage.tsv").open("w", encoding="utf-8", newline="") as target:
        writer = csv.DictWriter(target, fieldnames=fields, delimiter="\t")
        writer.writeheader()
        for record in records:
            writer.writerow({key: ";".join(value) if isinstance(value, list) else value for key, value in record.items()})
    counts = collections.Counter(record["faction"] for record in records)
    saved = sum(bool(record["saved_fields"]) for record in records)
    lines = ["# Army Builder coverage inventory", "", "Generated from the consolidated local construction catalog. This is schema discovery and source-review tracking, not rules certification or a count of fully migrated units.", "", f"Admitted profiles: **{len(records)}**. Profiles with detected saved equipment fields: **{saved}**. Of those, schemas with an explicit source-option completeness review: **{reviewed_schemas}**. Profiles source-reviewed as fixed equipment with no options: **{reviewed_fixed}**. Profiles with source-reviewed equipment options awaiting migration: **{reviewed_options}**. Profiles with a stale or unbound source review: **{stale_source_review}**. Profiles with no fixed/option source classification yet: **{waiting_source_review}**.", "", "| Faction | Admitted profiles |", "|---|---:|"]
    lines.extend(f"| {name} | {count} |" for name, count in sorted(counts.items()))
    lines.extend(["", "The [TSV ledger](army-builder-coverage.tsv) records every admitted identity, source book/datasheet identifiers where present, runtime source digest, detected fields, equipment review classification and separate verification gates. The [source review registry](army-builder-source-review.tsv) classifies a profile only when its book, datasheet, snapshot, manifest and runtime profile digest still match. Each review explicitly uses its extraction provenance or the separately exported `source_verified_against_*` provenance; snapshot/manifest pairs are never mixed. Verified-against reviews require a runtime slice-manifest binding and a separate local equipment-source audit; they do not rewrite original extraction metadata. `equipment_migration_required` means the selected local source lists equipment options but no saved schema was detected; these options remain implementation work. `source_classification_required` means no source classification is recorded; it does not mean a migration is required. `source_review_stale` means a review record exists but its provenance does not match the current runtime profile. `saved_schema_source_reviewed` means an explicit equipment-source audit matches the runtime provenance and exact saved-field set; runtime verification gates remain separate. `saved_schema_review_stale` means that audit no longer matches. `saved_schema_source_review_required` means fields were detected but does not prove that they cover all source choices. `not_audited` means the exporter did not check that verification gate.", "", f"Excluded catalog entries/reasons: **{len(audit['excluded'])}** (including blocked compositions; not necessarily distinct datasheets). Exclusions remain in the ignored JSON audit and are never added as construction choices.", "", "## Reproduce", "", "```powershell", "& .tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/export_army_builder_coverage.gd -- --output .tools/army-builder-coverage.json", "python tools/render_army_builder_coverage.py --input .tools/army-builder-coverage.json --output docs/project", "```", "", "The ignored JSON contains runtime audit metadata only. This tool does not fetch online catalogs or alter source provenance. See the [implementation review](army-builder-implementation-review.md) for the remaining integration gates.", ""])
    (args.output / "army-builder-coverage.md").write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()
