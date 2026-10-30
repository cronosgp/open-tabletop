"""Rank standard 11e faction datasheet counts from a hash-verified local export.

This read-only planning report never creates runtime profiles or admits units.
"""
import argparse
from collections import defaultdict
from pathlib import Path

import import_wahapedia as wahapedia


BASE_SOURCE_TYPES = {"App", "Faction Pack", "Codex"}


def _is_true(value):
    return str(value).strip().casefold() == "true"


def faction_inventories(tables):
    """Count unique non-Legends datasheets from each faction's own e11 book."""
    factions = {row["id"]: row["name"].strip() for row in tables["Factions"]}
    sources = {row["id"]: row for row in tables["Source"]}
    identities = defaultdict(set)
    books = defaultdict(set)

    for sheet in tables["Datasheets"]:
        faction_id = sheet.get("faction_id", "")
        faction_name = factions.get(faction_id, "")
        source = sources.get(sheet.get("source_id", ""), {})
        if not faction_name or source.get("edition") != "11":
            continue
        if source.get("type") not in BASE_SOURCE_TYPES:
            continue
        if source.get("name", "").strip().casefold() != faction_name.casefold():
            continue
        if _is_true(sheet.get("legend", "")) or _is_true(sheet.get("virtual", "")):
            continue

        identities[faction_id].add(sheet["id"])
        books[faction_id].add((source["id"], source["name"], source["type"], source.get("version", "")))

    ranked = []
    for faction_id, sheet_ids in identities.items():
        source_labels = sorted(
            f"{name} [{source_id}] {source_type} {version}".strip()
            for source_id, name, source_type, version in books[faction_id]
        )
        ranked.append({
            "faction_id": faction_id,
            "name": factions[faction_id],
            "datasheets": len(sheet_ids),
            "sources": source_labels,
        })
    return sorted(ranked, key=lambda row: (row["datasheets"], row["name"].casefold()))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("snapshot", type=Path, help="Path to a full local Wahapedia 11e export snapshot")
    parser.add_argument("--top", type=int, default=10, help="Number of smallest faction inventories to show")
    args = parser.parse_args()
    if args.top < 1:
        parser.error("--top must be at least 1")

    manifest, tables, manifest_hash = wahapedia.load_snapshot(args.snapshot)
    if manifest.get("artifact_type") == "scoped_audit_slice":
        parser.error("A scoped audit slice cannot rank a cross-faction inventory")
    if str(manifest.get("faction_context", "")).casefold() == "space-marines" and "Complete relational" not in manifest.get("dataset_scope", ""):
        parser.error("The snapshot does not declare a complete cross-faction dataset")

    findings = wahapedia.validate(tables)
    datasheets_hash = wahapedia.manifest_file_hash(manifest, "Datasheets")
    retrieval_times = [
        str(entry["retrieved_at"])
        for entry in manifest.get("files", {}).values()
        if isinstance(entry, dict) and entry.get("retrieved_at")
    ]
    last_update = manifest.get("last_update_after", {})
    if isinstance(last_update, dict) and last_update.get("retrieved_at"):
        retrieval_times.append(str(last_update["retrieved_at"]))
    retrieval_window = "unknown"
    if retrieval_times:
        ordered_times = sorted(retrieval_times)
        retrieval_window = ordered_times[0] if len(ordered_times) == 1 else f"{ordered_times[0]} through {ordered_times[-1]}"
    snapshot_id = manifest.get("snapshot_id") or args.snapshot.name
    print(f"Snapshot: {snapshot_id} | file retrieval window: {retrieval_window}")
    print(f"Parent manifest SHA-256: {manifest_hash}")
    print(f"Datasheets.csv SHA-256: {datasheets_hash or 'missing'}")
    print(f"Parent export structural findings: {len(findings)} (inventory only; not source certification)")
    print("Filter: unique IDs from each faction's own 11e App/Faction Pack/Codex; excludes Legends, virtual records, Forge World, supplements and alternate modes.")
    print()
    for rank, row in enumerate(faction_inventories(tables)[:args.top], start=1):
        print(f"{rank:2}. {row['name']}: {row['datasheets']} datasheets — {'; '.join(row['sources'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
