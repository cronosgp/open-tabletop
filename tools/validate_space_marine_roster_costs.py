"""Compare every runtime Space Marine copy-cost tier with a verified local e11 export."""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import tempfile
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path

import import_wahapedia as importer


REPO_ROOT = Path(__file__).resolve().parents[1]
EXPORT_SCRIPT = "tools/export_space_marine_runtime_identities.gd"
BOOKS = {
    "000000139": ("Space Marines", 85),
    "000000036": ("Space Wolves", 21),
    "000000023": ("Dark Angels", 16),
    "000000162": ("Black Templars", 15),
    "000000021": ("Blood Angels", 14),
    "000000035": ("Deathwatch", 10),
}
HEADTAKERS_ID = "000004131"
DECIMUS_ID = "000004175"
EXPECTED_HEADTAKERS_AMBIGUITY = {
    "first": {"6": [115, 170]},
    "second": {"6": [115, 170]},
    "third": {"6": [125, 180]},
    "fourth_plus": {"6": [125, 180]},
}
ADMITTED_HEADTAKERS_COSTS = {
    0: {6: 115, 12: 230},
    1: {6: 115, 12: 230},
    2: {6: 125, 12: 240},
    3: {6: 125, 12: 240},
}
WITHHELD_SOURCE_COSTS = {
    HEADTAKERS_ID: {
        0: {3: 85},
        1: {3: 85},
        2: {3: 95},
        3: {3: 95},
    },
    DECIMUS_ID: {
        0: {5: 110},
        1: {5: 110},
        2: {5: 110},
        3: {5: 110},
    },
}
WITHHELD_CONSTRUCTION_SIZES = {
    HEADTAKERS_ID: {3},
    DECIMUS_ID: {5},
}
COST_HEADINGS = {
    "YOUR UNIT COSTS": (0, 1, 2, 3),
    "YOUR 1ST UNIT COSTS": (0,),
    "YOUR 1ST TO 2ND UNITS COST": (0, 1),
    "YOUR 1ST TO 3RD UNITS COST": (0, 1, 2),
    "YOUR 2ND+ UNIT COSTS": (1, 2, 3),
    "YOUR 3RD+ UNIT COSTS": (2, 3),
    "YOUR 4TH+ UNIT COSTS": (3,),
}
MODEL_COUNT = re.compile(r"^(\d+)\s+models?$", re.IGNORECASE)
COMPOSITION_COUNT = re.compile(r"^\s*(\d+)(?:\s*-\s*(\d+))?\s+")
COPY_TIER_NAMES = ("first", "second", "third", "fourth_plus")
EXPECTED_CONFLICTING_COMPOSITIONS = {
    HEADTAKERS_ID: [(3, 6), (3, 6)],
    DECIMUS_ID: [(1, 1), (1, 1), (1, 2), (1, 2), (1, 2), (1, 2)],
}
EXPECTED_CONFLICT_PROFILE_NAMES = {
    HEADTAKERS_ID: "wolf guard headtakers",
    DECIMUS_ID: "decimus kill team",
}


def _normalize_name(value: str) -> str:
    value = unicodedata.normalize("NFKC", value)
    return value.replace("\u2018", "'").replace("\u2019", "'").strip().casefold()


def _composition_ranges(rows: list[dict], sheet_id: str) -> list[tuple[int, int]]:
    ranges: list[tuple[int, int]] = []
    for row in rows:
        if str(row["datasheet_id"]) != sheet_id:
            continue
        description = str(row["description"]).strip()
        match = COMPOSITION_COUNT.match(description)
        if not match:
            raise ValueError(f"Cannot parse a model count from {sheet_id} composition row: {description}")
        minimum = int(match.group(1))
        maximum = int(match.group(2) or match.group(1))
        ranges.append((minimum, maximum))
    if not ranges:
        raise ValueError(f"Missing source unit-composition rows for {sheet_id}")
    return sorted(ranges)


def _export_runtime_profiles(godot: Path, destination: Path) -> dict:
    command = [
        str(godot), "--headless", "--path", str(REPO_ROOT), "--script", EXPORT_SCRIPT,
        "--", "--output", str(destination),
    ]
    completed = subprocess.run(command, cwd=REPO_ROOT, capture_output=True, text=True, check=False)
    if completed.returncode:
        raise RuntimeError(
            "Godot runtime-profile export failed:\n" + completed.stdout + completed.stderr
        )
    return json.loads(destination.read_text(encoding="utf-8"))


def _verify_snapshot(snapshot: Path) -> tuple[dict, dict, dict, str, int]:
    manifest, tables, manifest_hash = importer.load_snapshot(snapshot)
    if manifest.get("mode") != "live_download" or manifest.get("live_timestamp_bracket_checked") is not True:
        raise ValueError("Expected a timestamp-bracketed live Wahapedia export snapshot")
    if not str(manifest.get("source_policy", "")).startswith("wahapedia-e11-definitive-"):
        raise ValueError("Snapshot does not identify the selected Wahapedia 11e source policy")

    raw_root = snapshot / "raw"
    files = manifest.get("files", {})
    if not isinstance(files, dict) or not files:
        raise ValueError("Live snapshot manifest has no file hash map")
    verified_files = 0
    for name, entry in files.items():
        filename = str(name) if str(name).endswith(".csv") else f"{name}.csv"
        path = raw_root / filename
        expected = entry.get("sha256") if isinstance(entry, dict) else None
        if not path.is_file() or not expected or importer.sha(path.read_bytes()) != str(expected).lower():
            raise ValueError(f"Snapshot file hash check failed: {filename}")
        verified_files += 1

    source_by_id = {str(row["id"]): row for row in tables["Source"]}
    sheets_by_id = {
        str(row["id"]): row for row in tables["Datasheets"]
        if str(row["source_id"]) in BOOKS
    }
    if len(sheets_by_id) != sum(count for _, count in BOOKS.values()):
        raise ValueError("The six standard Marine books do not match the expected 161-sheet inventory")
    counts = Counter(str(row["source_id"]) for row in sheets_by_id.values())
    for book_id, (book_name, expected_count) in BOOKS.items():
        source = source_by_id.get(book_id)
        if not source or source.get("name") != book_name or source.get("edition") != "11":
            raise ValueError(f"Source book identity or edition mismatch: {book_id}")
        if counts[book_id] != expected_count:
            raise ValueError(f"{book_name} has {counts[book_id]} sheets; expected {expected_count}")
    return manifest, tables, sheets_by_id, manifest_hash, verified_files


def _source_costs(rows: list[dict], sheet_ids: set[str]) -> tuple[dict, int]:
    current_slots: dict[str, tuple[int, ...]] = defaultdict(lambda: (0,))
    observed: dict[str, dict[int, dict[int, set[int]]]] = defaultdict(
        lambda: defaultdict(lambda: defaultdict(set))
    )
    unknown_headings: list[str] = []
    cost_rows = 0
    for row in rows:
        sheet_id = str(row["datasheet_id"])
        if sheet_id not in sheet_ids:
            continue
        description = str(row["description"]).strip()
        if description in COST_HEADINGS:
            current_slots[sheet_id] = COST_HEADINGS[description]
            continue
        if description.upper().startswith("YOUR "):
            unknown_headings.append(f"{sheet_id}: {description}")
            continue
        match = MODEL_COUNT.fullmatch(description)
        cost_text = str(row["cost"]).strip()
        if match and cost_text.isdecimal():
            for slot in current_slots[sheet_id]:
                observed[sheet_id][slot][int(match.group(1))].add(int(cost_text))
            cost_rows += 1
        elif cost_text.isdecimal() and not description.casefold().startswith("per "):
            unknown_headings.append(f"{sheet_id}: unclassified cost row {description!r}")
    if unknown_headings:
        raise ValueError("Unclassified source-cost rows:\n" + "\n".join(unknown_headings))
    return observed, cost_rows


def _profile_cost_maps(profile: dict) -> dict[int, dict[int, int]]:
    source_points = profile.get("source_roster_points", {})
    field_by_slot = {
        0: "points_by_models",
        1: "second_plus_points_by_models",
        2: "third_plus_points_by_models",
        3: "fourth_plus_points_by_models",
    }
    maps: dict[int, dict[int, int]] = {}
    for slot, field in field_by_slot.items():
        values = source_points.get(field, {})
        if not isinstance(values, dict):
            raise ValueError(f"{profile.get('identity')}: {field} is not a map")
        maps[slot] = {int(size): int(cost) for size, cost in values.items()}
    return maps


def audit(snapshot: Path, godot: Path) -> dict:
    manifest, tables, sheets_by_id, manifest_hash, verified_files = _verify_snapshot(snapshot)
    with tempfile.TemporaryDirectory(prefix="space-marine-roster-costs-") as temp_dir:
        runtime_path = Path(temp_dir) / "runtime-identities.json"
        runtime = _export_runtime_profiles(godot, runtime_path)

    profiles = runtime.get("profiles", [])
    profile_by_id: dict[str, dict] = {}
    for profile in profiles:
        sheet_id = str(profile.get("source_datasheet_id", ""))
        if not sheet_id or sheet_id in profile_by_id:
            raise ValueError(f"Missing or duplicate runtime source ID: {sheet_id}")
        profile_by_id[sheet_id] = profile
    if len(profile_by_id) != int(runtime.get("profile_count", -1)):
        raise ValueError("Runtime profile count disagrees with its exported identity map")
    if runtime.get("missing_source_ids"):
        raise ValueError("Runtime export contains profiles without source IDs")

    source_ids, runtime_ids = set(sheets_by_id), set(profile_by_id)
    if runtime_ids - source_ids:
        raise ValueError("Runtime identities fall outside the six standard Marine books")
    missing_ids = source_ids - runtime_ids

    observed, cost_rows = _source_costs(tables["Datasheets_models_cost"], source_ids)
    composition_minimums: dict[str, int] = {}
    for sheet_id, expected_ranges in EXPECTED_CONFLICTING_COMPOSITIONS.items():
        if _normalize_name(str(sheets_by_id[sheet_id]["name"])) != EXPECTED_CONFLICT_PROFILE_NAMES[sheet_id]:
            raise ValueError(f"Known source-conflict identity changed for {sheet_id}")
        actual_ranges = _composition_ranges(tables["Datasheets_unit_composition"], sheet_id)
        if actual_ranges != sorted(expected_ranges):
            raise ValueError(f"Known source composition changed for {sheet_id}; review its withheld sizes")
        minimum_models = sum(low for low, _high in actual_ranges)
        if max(WITHHELD_CONSTRUCTION_SIZES[sheet_id]) >= minimum_models:
            raise ValueError(f"The configured withheld size is no longer below the source minimum for {sheet_id}")
        composition_minimums[sheet_id] = minimum_models

    ambiguous: dict[str, dict[str, dict[str, list[int]]]] = {}
    for sheet_id, tiers in observed.items():
        for slot, sizes in tiers.items():
            for size, costs in sizes.items():
                if len(costs) > 1:
                    ambiguous.setdefault(sheet_id, {}).setdefault(COPY_TIER_NAMES[slot], {})[str(size)] = sorted(costs)

    for sheet_id, tier_rows in WITHHELD_SOURCE_COSTS.items():
        for slot, sizes in tier_rows.items():
            for size, expected_cost in sizes.items():
                if observed.get(sheet_id, {}).get(slot, {}).get(size) != {expected_cost}:
                    raise ValueError(f"Known withheld source row changed for {sheet_id}, tier {slot}, {size} models")

    if missing_ids:
        raise ValueError(f"Source datasheets missing runtime profiles: {sorted(missing_ids)}")
    if ambiguous:
        if set(ambiguous) != {HEADTAKERS_ID}:
            raise ValueError(f"Unexpected source-cost ambiguities: {sorted(ambiguous)}")
        blocker_name = _normalize_name(str(sheets_by_id[HEADTAKERS_ID]["name"]))
        if blocker_name != "wolf guard headtakers":
            raise ValueError("The known ambiguous-cost profile is no longer Wolf Guard Headtakers")
        if ambiguous[HEADTAKERS_ID] != EXPECTED_HEADTAKERS_AMBIGUITY:
            raise ValueError("Headtakers source-cost ambiguity changed; review its admission blocker")
    else:
        raise ValueError("The expected Headtakers composition-cost ambiguity is missing; review its admission mapping")

    mismatch_count = 0
    checked_profiles = 0
    checked_catalog_profiles = 0
    mismatch_details: list[str] = []
    for sheet_id, profile in profile_by_id.items():
        sheet = sheets_by_id[sheet_id]
        if str(profile.get("source_book_id", "")) != str(sheet["source_id"]):
            mismatch_count += 1
            mismatch_details.append(f"{sheet_id}: source book differs")
            continue
        if _normalize_name(str(profile.get("source_name", ""))) != _normalize_name(str(sheet["name"])):
            mismatch_count += 1
            mismatch_details.append(f"{sheet_id}: source name differs")
            continue
        tiers = observed.get(sheet_id, {})
        try:
            profile_maps = _profile_cost_maps(profile)
        except (TypeError, ValueError) as error:
            mismatch_count += 1
            mismatch_details.append(f"{sheet_id}: {error}")
            continue
        source_sizes = set(tiers.get(0, {}))
        runtime_sizes = set(profile_maps[0])
        withheld_sizes = WITHHELD_CONSTRUCTION_SIZES.get(sheet_id, set())
        if not withheld_sizes <= source_sizes \
            or source_sizes - runtime_sizes != ({3} if sheet_id == HEADTAKERS_ID else set()) \
            or runtime_sizes - source_sizes:
            mismatch_count += 1
            mismatch_details.append(f"{sheet_id}: source/runtime model-size options differ")
            continue
        source_schedule: dict[int, dict[int, int]] = {}
        effective_maps = {0: profile_maps[0]}
        for slot in range(1, len(COPY_TIER_NAMES)):
            effective_maps[slot] = {
                size: profile_maps[slot].get(size, effective_maps[slot - 1].get(size))
                for size in runtime_sizes
            }
        for slot, tier_name in enumerate(COPY_TIER_NAMES):
            source_map: dict[int, int] = {}
            for size, costs in tiers.get(slot, {}).items():
                if size not in runtime_sizes:
                    expected_withheld = WITHHELD_SOURCE_COSTS.get(sheet_id, {}).get(slot, {}).get(size)
                    if expected_withheld is not None and costs == {expected_withheld}:
                        continue
                    mismatch_count += 1
                    mismatch_details.append(f"{sheet_id}: unexpected source-only {tier_name} row for {size} models")
                    continue
                if len(costs) != 1:
                    expected_admitted = ADMITTED_HEADTAKERS_COSTS.get(slot, {}).get(size) if sheet_id == HEADTAKERS_ID else None
                    if expected_admitted is not None and expected_admitted in costs:
                        source_map[size] = expected_admitted
                        continue
                    mismatch_count += 1
                    mismatch_details.append(f"{sheet_id}: ambiguous {tier_name} cost for {size} models")
                    continue
                source_map[size] = next(iter(costs))
            runtime_map = effective_maps[slot]
            if source_map != runtime_map:
                mismatch_count += 1
                mismatch_details.append(f"{sheet_id}: {tier_name} copy-cost export/runtime mismatch")
            source_schedule[slot] = source_map

        construction_options = profile.get("construction_options", [])
        if not isinstance(construction_options, list) or not construction_options:
            mismatch_count += 1
            mismatch_details.append(f"{sheet_id}: profile is missing from the selectable construction catalog")
            checked_profiles += 1
            continue
        catalog_by_size: dict[int, dict] = {}
        for option in construction_options:
            try:
                size = int(option["models"])
                if size in catalog_by_size:
                    raise ValueError("duplicate construction option")
                catalog_by_size[size] = option
            except (KeyError, TypeError, ValueError):
                mismatch_count += 1
                mismatch_details.append(f"{sheet_id}: invalid or duplicate catalog size option")
        expected_catalog_sizes = runtime_sizes - withheld_sizes
        if set(catalog_by_size) != expected_catalog_sizes:
            mismatch_count += 1
            mismatch_details.append(f"{sheet_id}: construction choices include a withheld size or omit an admitted size")
        else:
            catalog_consistent = True
            for size, option in catalog_by_size.items():
                try:
                    first = int(option["cost"])
                    second = int(option.get("second_plus_cost", first))
                    third = int(option.get("third_plus_cost", second))
                    fourth = int(option.get("fourth_plus_cost", third))
                except (KeyError, TypeError, ValueError):
                    catalog_consistent = False
                    break
                actual = (first, second, third, fourth)
                expected = tuple(source_schedule[slot].get(size) for slot in range(4))
                if actual != expected:
                    catalog_consistent = False
                    break
            if not catalog_consistent:
                mismatch_count += 1
                mismatch_details.append(f"{sheet_id}: construction catalog copy costs differ from the source schedule")
            else:
                checked_catalog_profiles += 1
        checked_profiles += 1
    if mismatch_count:
        raise ValueError("Marine copy-cost parity failed:\n" + "\n".join(mismatch_details))

    return {
        "snapshot_id": str(manifest.get("snapshot_id", Path(snapshot).name)),
        "snapshot_manifest_sha256": manifest_hash,
        "manifest_files_verified": verified_files,
        "source_sheet_count": len(sheets_by_id),
        "runtime_profile_count": len(profile_by_id),
        "copy_cost_rows_checked": cost_rows,
        "copy_cost_profiles_checked": checked_profiles,
        "construction_catalog_profiles_checked": checked_catalog_profiles,
        "copy_cost_mismatches": 0,
        "known_source_cost_ambiguity": ambiguous.get(HEADTAKERS_ID),
        "known_composition_minimum_models": composition_minimums,
        "known_withheld_construction_sizes": {
            sheet_id: sorted(sizes) for sheet_id, sizes in WITHHELD_CONSTRUCTION_SIZES.items()
        },
        "known_source_withheld_cost_rows": {
            sheet_id: {
                str(slot): {str(size): cost for size, cost in sizes.items()}
                for slot, sizes in tiers.items()
            }
            for sheet_id, tiers in WITHHELD_SOURCE_COSTS.items()
        },
        "network": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", type=Path, required=True)
    parser.add_argument("--godot", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    try:
        result = audit(args.snapshot, args.godot.resolve())
    except (OSError, ValueError, RuntimeError, json.JSONDecodeError) as error:
        parser.exit(1, f"{error}\n")
    encoded = json.dumps(result, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded, encoding="utf-8")
    print(
        "Space Marine roster-cost audit: "
        f"{result['copy_cost_profiles_checked']}/{result['runtime_profile_count']} runtime profiles and "
        f"{result['construction_catalog_profiles_checked']}/{result['runtime_profile_count']} catalog choices exact; "
        f"{result['manifest_files_verified']} snapshot files hash-verified; "
        f"known source conflicts: Headtakers ambiguous composition costs and Decimus 5-model composition row withheld; network=False"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
