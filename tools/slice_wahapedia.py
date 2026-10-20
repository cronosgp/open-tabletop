"""Extract a source-bounded, structurally checked e11 audit slice; no runtime admission."""
import argparse
import csv
import io
from pathlib import Path
import urllib.parse

import import_wahapedia as w


def select_tables(tables, source_id, datasheet_ids=None):
    sources = [r for r in tables["Source"] if r["id"] == source_id]
    if len(sources) != 1 or sources[0]["edition"] != "11":
        raise ValueError("Select exactly one existing e11 source ID")
    subjects = [r for r in tables["Datasheets"] if r["source_id"] == source_id]
    if datasheet_ids is not None:
        requested = set(datasheet_ids)
        subjects = [r for r in subjects if r["id"] in requested]
        if {r["id"] for r in subjects} != requested:
            raise ValueError("Requested datasheet is absent or belongs to another source book")
    if not subjects:
        raise ValueError("No subjects in selected source")
    if len({r["id"] for r in subjects}) != len(subjects):
        raise ValueError("Ambiguous subject identity")
    for row in subjects:
        link = urllib.parse.urlsplit(row["link"])
        if link.hostname not in ["wahapedia.ru", "www.wahapedia.ru"] or not link.path.startswith("/wh40k11ed/"):
            raise ValueError("Subject has a non-e11 source URL")
    ids = {r["id"] for r in subjects}
    selected = {name: [] for name in w.HEADERS}
    for name in w.HEADERS:
        if "datasheet_id" in w.HEADERS[name].split():
            selected[name] = [r for r in tables[name] if r["datasheet_id"] in ids]
    # Keep both directions of Leader relationships and identity-only external endpoints.
    selected["Datasheets_leader"] = [r for r in tables["Datasheets_leader"]
                                     if r["leader_id"] in ids or r["attached_id"] in ids]
    endpoint_ids = {r[k] for r in selected["Datasheets_leader"] for k in ["leader_id", "attached_id"]}
    selected["Datasheets"] = [r for r in tables["Datasheets"] if r["id"] in ids | endpoint_ids]
    # Dependencies are selected by IDs, not faction/name guesses. Missing targets stay missing
    # and are reported by structural validation; their referencing rows are never dropped.
    for relation, column, target in [
        ("Datasheets_abilities", "ability_id", "Abilities"),
        ("Datasheets_stratagems", "stratagem_id", "Stratagems"),
        ("Datasheets_enhancements", "enhancement_id", "Enhancements"),
        ("Datasheets_detachment_abilities", "detachment_ability_id", "Detachment_abilities"),
    ]:
        linked = {r[column] for r in selected[relation] if r[column]}
        selected[target] = [r for r in tables[target] if r["id"] in linked]
    enhancement_ids = {r["id"] for r in selected["Enhancements"]}
    selected["Enhancements_wargear"] = [r for r in tables["Enhancements_wargear"] if r["enhancement_id"] in enhancement_ids]
    detachment_ids = {r["detachment_id"] for name in ["Stratagems", "Enhancements", "Detachment_abilities"] for r in selected[name] if r["detachment_id"]}
    selected["Detachments"] = [r for r in tables["Detachments"] if r["id"] in detachment_ids]
    selected["Detachments_chapter_dp"] = [r for r in tables["Detachments_chapter_dp"] if r["detachment_id"] in detachment_ids]
    source_ids = {r["source_id"] for r in selected["Datasheets"]}
    selected["Source"] = [r for r in tables["Source"] if r["id"] in source_ids]
    faction_ids = {r["faction_id"] for rows in selected.values() for r in rows if r.get("faction_id")}
    selected["Factions"] = [r for r in tables["Factions"] if r["id"] in faction_ids]
    selected["Last_update"] = tables["Last_update"]
    return selected, sources[0], sorted(ids), sorted(endpoint_ids - ids)


def serialize(name, rows):
    header = w.HEADERS[name].split()
    # Preserve added source fields as well as the known schema.
    header += sorted({k for row in rows for k in row} - set(header))
    text = io.StringIO(newline="")
    writer = csv.writer(text, delimiter="|")
    writer.writerow(header + [""])
    for row in rows:
        writer.writerow([row.get(k, "") for k in header] + [""])
    return text.getvalue().encode("utf-8-sig")


def build_catalog(tables, source, subjects):
    """Join source records without interpreting prose, stats or rule applicability."""
    units = []
    sheets = {r["id"]: r for r in tables["Datasheets"]}
    for subject in subjects:
        sheet = sheets[subject]
        def related(name):
            return [row for row in tables[name] if row["datasheet_id"] == subject]
        abilities = []
        for row in related("Datasheets_abilities"):
            definitions = [a for a in tables["Abilities"] if row["ability_id"] and a["id"] == row["ability_id"]]
            # Keep all source bindings; ambiguity must not become last-row-wins behavior.
            abilities.append({"binding": row, "referenced_definition_keys": [
                {"id": a["id"], "faction_id": a["faction_id"]} for a in definitions]})
        linked_rules = {}
        for relation, column, target in [
            ("Datasheets_stratagems", "stratagem_id", "Stratagems"),
            ("Datasheets_enhancements", "enhancement_id", "Enhancements"),
            ("Datasheets_detachment_abilities", "detachment_ability_id", "Detachment_abilities"),
        ]:
            links = related(relation)
            identifiers = {r[column] for r in links}
            linked_rules[target] = {"bindings": links,
                                    "definition_ids": [r["id"] for r in tables[target] if r["id"] in identifiers]}
        units.append({"id": "wahapedia:11e:" + subject, "source_datasheet": sheet,
                      "source_book_id": source["id"], "models": related("Datasheets_models"),
                      "weapons": related("Datasheets_wargear"), "keywords": related("Datasheets_keywords"),
                      "composition": related("Datasheets_unit_composition"), "costs": related("Datasheets_models_cost"),
                      "options": related("Datasheets_options"), "abilities": abilities,
                      "leader_links": [r for r in tables["Datasheets_leader"] if subject in [r["leader_id"], r["attached_id"]]],
                      "linked_rules": linked_rules, "playable": False,
                      "implementation_status": "source_inventory_only"})
    return units


def extract(snapshot, output, source_id, datasheet_ids=None):
    output = Path(output)
    if output.exists():
        raise ValueError("Output already exists")
    parent, tables, parent_hash = w.load_snapshot(snapshot)
    if parent.get("artifact_type") == "scoped_audit_slice":
        raise ValueError("Extract from a full capture, not a previously reduced slice")
    selected, source, subjects, external = select_tables(tables, source_id, datasheet_ids)
    notes = []
    errors = w.validate(selected, notes)
    global_errors = w.validate(tables)
    files = {name: serialize(name, rows) for name, rows in selected.items()}
    catalog = {"schema_version": 1, "provider": "wahapedia", "edition": "11e",
               "parent_manifest_sha256": parent_hash, "export_updated_at": parent["export_updated_at"],
               "source_book": source, "source_books": selected["Source"], "factions": selected["Factions"],
               "units": build_catalog(selected, source, subjects),
               "external_datasheet_identities": [r for r in selected["Datasheets"] if r["id"] in external],
               "definitions": {name: selected[name] for name in ["Abilities", "Stratagems", "Enhancements", "Detachment_abilities", "Detachments", "Enhancements_wargear", "Detachments_chapter_dp"]},
               "scope": "Joined source inventory; characteristic strings and HTML preserved as inert data. No executable effects or runtime admission.",
               "playable": False}
    catalog_bytes = w.encode(catalog)
    manifest = {"schema_version": 1, "provider": "wahapedia", "edition": "11e",
                "artifact_type": "scoped_audit_slice", "source_policy": parent["source_policy"],
                "parent_manifest_sha256": parent_hash, "export_updated_at": parent["export_updated_at"],
                "source_book": source, "subject_datasheet_ids": subjects,
                "external_identity_only_datasheet_ids": external,
                "files": {name: {"sha256": w.sha(data), "bytes": len(data)} for name, data in files.items()},
                "table_rows": {name: len(rows) for name, rows in selected.items()},
                "catalog_sha256": w.sha(catalog_bytes), "catalog_units": len(catalog["units"]),
                "parent_validation_errors": global_errors,
                "validation_errors": errors, "parser_notes": notes, "structurally_valid": not errors,
                "scope": "Source-bounded subjects plus directly linked definitions and identity-only Leader endpoints. Dependencies retain their original chapter/game-mode context; structural validity does not establish rule applicability or legality.",
                "implementation": "audit-only", "playable": False, "full_match_certified": False}
    (output / "raw").mkdir(parents=True)
    for name, data in files.items():
        (output / "raw" / (name + ".csv")).write_bytes(data)
    (output / "manifest.json").write_bytes(w.encode(manifest))
    (output / "catalog.json").write_bytes(catalog_bytes)
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", required=True, type=Path)
    parser.add_argument("--source-id", required=True)
    parser.add_argument("--datasheet-id", action="append", help="Optional repeated exact subject IDs within the source book")
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    try:
        manifest = extract(args.snapshot, args.output, args.source_id, args.datasheet_id)
    except (ValueError, OSError, KeyError) as error:
        parser.exit(1, str(error) + "\n")
    print(w.encode({"subjects": len(manifest["subject_datasheet_ids"]),
                    "external_identity_only": len(manifest["external_identity_only_datasheet_ids"]),
                    "parent_errors": len(manifest["parent_validation_errors"]),
                    "slice_errors": manifest["validation_errors"][:10],
                    "slice_error_count": len(manifest["validation_errors"])}).decode())
    return 0 if manifest["structurally_valid"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
