"""Build the checked-in fixed-profile data for shared Marine transports.

Input is the pinned local Wahapedia e11 slice under .tools; this script does
not fetch or consult another rules source.
"""
from __future__ import annotations

import csv
import html
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / ".tools/wahapedia-marines-slice-20261021-v4/catalog.json"
SLICE_MANIFEST = SOURCE.with_name("manifest.json")
SOURCE_SNAPSHOT = ROOT / ".tools/wahapedia/11e/space-marines/20261021T130623Z"
IDENTITY_MAP = ROOT / "docs/space-marines-source-identity-map.json"
OUTPUT = ROOT / "data/edition_11/space_marines_transport_profiles.json"

IDENTITIES = {
    "000000065": "land-raider",
    "000000066": "land-raider-crusader",
    "000000087": "drop-pod",
    "000002173": "land-raider-redeemer",
    "000002568": "impulsor",
    "000002721": "repulsor",
    "000002722": "repulsor-executioner",
    "000002723": "rhino",
}

# Use local circular board proxies where the source geometry is not modeled.
# These vehicle pages explicitly give a 100 mm diameter circular base.
PROXIES_MM = {
    "land-raider": 150,
    "land-raider-crusader": 150,
    "land-raider-redeemer": 150,
    "drop-pod": 80,
    "impulsor": 100,
    "repulsor": 100,
    "repulsor-executioner": 100,
    "rhino": 120,
}

TRANSPORT = {
    "land-raider": {"capacity": 14, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["JUMP PACK"], "double_space": ["GRAVIS", "TERMINATOR"]},
    "land-raider-crusader": {"capacity": 16, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["JUMP PACK"], "double_space": ["GRAVIS", "TERMINATOR"]},
    "land-raider-redeemer": {"capacity": 14, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["JUMP PACK"], "double_space": ["GRAVIS", "TERMINATOR"]},
    "drop-pod": {"capacity": 12, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["GRAVIS", "JUMP PACK", "TERMINATOR"], "double_space": []},
    "impulsor": {"capacity": 7, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["TERMINATOR", "JUMP PACK"], "double_space": ["GRAVIS"]},
    "repulsor": {"capacity": 14, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["JUMP PACK"], "double_space": ["GRAVIS", "TERMINATOR"]},
    "repulsor-executioner": {"capacity": 7, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["JUMP PACK"], "double_space": ["GRAVIS", "TERMINATOR"]},
    "rhino": {"capacity": 12, "required": ["ADEPTUS ASTARTES", "INFANTRY"], "forbidden": ["GRAVIS", "JUMP PACK", "TERMINATOR"], "double_space": []},
}

OPTIONS = {
    "land-raider": {"add": ["Hunter-killer Missile", "Multi-melta", "Storm Bolter"]},
    "land-raider-crusader": {"add": ["Hunter-killer Missile", "Multi-melta", "Storm Bolter"]},
    "land-raider-redeemer": {"add": ["Hunter-killer Missile", "Multi-melta", "Storm Bolter"]},
    "drop-pod": {},
    "impulsor": {"one_of": ["Bellicatus Missile Array", "Orbital Comms Array", "Ironhail Skytalon Array", "Shield Dome"], "replacements": {"Storm Bolters": "Fragstorm Grenade Launchers"}, "add": ["Ironhail Heavy Stubber"], "wargear_costs": {"Orbital Comms Array": 10}},
    "repulsor": {"replacements": {"Heavy Onslaught Gatling Cannon": "Las-talon", "Twin Heavy Bolter": "Twin Lascannon"}},
    "repulsor-executioner": {"replacements": {"Heavy Laser Destroyer": "Macro Plasma Incinerator"}, "wargear_costs": {"Heavy Laser Destroyer": 10}},
    "rhino": {"add": ["Hunter-killer Missile"]},
}


def slug(value: str) -> str:
    value = html.unescape(re.sub(r"<[^>]+>", "", value)).lower()
    return re.sub(r"[^a-z0-9]+", "-", value).strip("-")


def traits(description: str) -> dict:
    text = html.unescape(description).lower()
    out: dict[str, object] = {}
    for source, target in [("one shot", "one-shot"), ("twin-linked", "twin-linked"), ("torrent", "torrent"), ("heavy", "heavy"), ("hazardous", "hazardous"), ("indirect fire", "indirect-fire"), ("devastating wounds", "devastating-wounds"), ("close-quarters", "close-quarters"), ("assault", "assault"), ("precision", "precision")]:
        if source in text:
            out[target] = True
    for source, target in [("rapid fire", "rapid-fire"), ("blast", "blast"), ("melta", "melta"), ("sustained hits", "sustained-hits"), ("anti-fly", "anti-fly")]:
        match = re.search(rf"{source}\s*(\d+)", text)
        if match:
            out[target] = int(match.group(1))
    return out


def target_conditions(description: str) -> dict:
    """Translate source weapon trait clauses into target-aware runtime metadata."""
    text = html.unescape(description).lower()
    restricted: dict[str, list[str]] = {}
    required: dict[str, list[str]] = {}
    pattern = r"(devastating wounds|lethal hits|sustained hits\s+\d+)\s*:\s*(non-monster/vehicle|infantry)\b"
    for match in re.finditer(pattern, text):
        raw_trait, target_condition = match.groups()
        trait = "sustained-hits" if raw_trait.startswith("sustained hits") else raw_trait.replace(" ", "-")
        if target_condition == "non-monster/vehicle":
            restricted[trait] = ["MONSTER", "VEHICLE"]
        else:
            required[trait] = ["INFANTRY"]
    result = {}
    if restricted:
        result["target_restricted_traits"] = restricted
    if required:
        result["target_required_traits"] = required
    return result


def number(value: str, dash: int = 0):
    value = value.strip().replace('"', "")
    if not value or value == "-":
        return dash
    if re.fullmatch(r"\d+", value):
        return int(value)
    return value


def loadout_names(raw: str) -> list[tuple[int, str]]:
    clean = html.unescape(re.sub(r"<[^>]+>", "", raw))
    found = []
    for part in clean.split(";"):
        match = re.search(r"(?:equipped with:\s*)?(\d+)\s+(.+?)\.?\s*$", part.strip(), re.I)
        if match:
            found.append((int(match.group(1)), match.group(2).strip()))
    return found


def cost_tiers(rows: list[dict]) -> dict[str, dict[int, int]]:
    headings = {
        "YOUR UNIT COSTS": "ordinary",
        "YOUR 1ST UNIT COSTS": "first",
        "YOUR 2ND+ UNIT COSTS": "second_plus",
        "YOUR 1ST TO 2ND UNITS COST": "first_second",
        "YOUR 3RD+ UNIT COSTS": "third_plus",
        "YOUR 1ST TO 3RD UNITS COST": "first_third",
        "YOUR 1ST TO 3RD UNITS COSTS": "first_third",
        "YOUR 4TH+ UNIT COSTS": "fourth_plus",
    }
    sections: dict[str, dict[int, int]] = {}
    current = ""
    for row in sorted(rows, key=lambda item: int(item.get("line", "0"))):
        description = row.get("description", "").strip().upper()
        cost = row.get("cost", "").strip()
        if not cost:
            current = headings.get(description, "")
            continue
        match = re.fullmatch(r"(\d+) models?", description, re.I)
        if current and match and cost.isdigit():
            size = int(match.group(1))
            price = int(cost)
            table = sections.setdefault(current, {})
            if size in table and table[size] != price:
                raise ValueError(f"Conflicting {current} costs for {size} models")
            table[size] = price
    return sections


def verified_source_metadata() -> dict:
    """Bind derived profiles to the verified local export and its scoped slice."""
    snapshot_manifest_path = SOURCE_SNAPSHOT / "manifest.json"
    snapshot_manifest_bytes = snapshot_manifest_path.read_bytes()
    snapshot = json.loads(snapshot_manifest_bytes.decode("utf-8-sig"))
    identity = json.loads(IDENTITY_MAP.read_text(encoding="utf-8-sig"))
    slice_manifest = json.loads(SLICE_MANIFEST.read_text(encoding="utf-8-sig"))
    if snapshot.get("snapshot_id") != SOURCE_SNAPSHOT.name or snapshot.get("edition") != "11e":
        raise ValueError("The local Wahapedia snapshot identity or edition does not match this build.")
    if slice_manifest.get("structurally_valid") is not True:
        raise ValueError("The scoped Wahapedia source slice is not structurally valid.")
    if identity.get("source_subject_count") != 85 or identity.get("source_book_id") != "000000139":
        raise ValueError("The source identity map does not match the expected 85-sheet shared-book scope.")

    manifest_files = {entry["filename"]: entry["sha256"] for entry in snapshot.get("files", [])}
    for filename, expected in manifest_files.items():
        actual = hashlib.sha256((SOURCE_SNAPSHOT / filename).read_bytes()).hexdigest()
        if actual != expected:
            raise ValueError(f"The local source snapshot hash does not match its manifest: {filename}")
    slice_files = slice_manifest.get("parent_files_sha256", {})
    if not slice_files or any(manifest_files.get(name) != digest for name, digest in slice_files.items()):
        raise ValueError("The scoped slice does not match the verified local export files.")
    if manifest_files.get("Datasheets.csv") != identity.get("datasheets_csv_sha256"):
        raise ValueError("The source identity map does not match the verified Datasheets.csv.")

    return {
        "source_snapshot_id": snapshot["snapshot_id"],
        "source_retrieved_at_utc": snapshot["retrieved_at_utc"],
        "source_export_updated_at": slice_manifest["export_updated_at"],
        "source_manifest_sha256": hashlib.sha256(snapshot_manifest_bytes).hexdigest(),
        "source_slice_manifest_sha256": hashlib.sha256(SLICE_MANIFEST.read_bytes()).hexdigest(),
        "source_files": [{"name": name, "sha256": digest} for name, digest in sorted(manifest_files.items())],
    }


def main() -> None:
    provenance = verified_source_metadata()
    source = json.loads(SOURCE.read_text(encoding="utf-8"))
    core_ability_names: dict[str, str] = {}
    with (SOURCE_SNAPSHOT / "Abilities.csv").open(encoding="utf-8-sig", newline="") as stream:
        for ability in csv.DictReader(stream, delimiter="|"):
            if not ability.get("faction_id"):
                core_ability_names[ability["id"]] = ability["name"]
    if len(source.get("units", [])) != 85:
        raise ValueError("The source slice must contain exactly 85 shared Space Marine datasheets.")
    profiles = {}
    for row in source["units"]:
        ds = row["source_datasheet"]
        dsid = ds["id"]
        if dsid not in IDENTITIES:
            continue
        identity = IDENTITIES[dsid]
        model = row["models"][0]
        sections = cost_tiers(row["costs"])
        first_section = next((name for name in ["ordinary", "first", "first_second", "first_third"] if name in sections), None)
        if first_section is None or 1 not in sections[first_section]:
            raise ValueError(f"{ds['name']}: missing source price for its first 1-model copy")
        base_cost = sections[first_section][1]
        second_cost = sections.get("second_plus", {}).get(1)
        if "third_plus" in sections:
            third_cost = sections["third_plus"].get(1)
        elif "second_plus" in sections:
            third_cost = sections["second_plus"].get(1)
        elif "first_third" in sections:
            third_cost = sections["first_third"].get(1)
        else:
            third_cost = sections.get("ordinary", {}).get(1, base_cost)
        if third_cost is None:
            raise ValueError(f"{ds['name']}: missing source price for its third copy")
        fourth_cost = sections.get("fourth_plus", {}).get(1)
        stats = {
            "movement_inches": number(model["M"]),
            "toughness": number(model["T"]),
            "save_target": number(model["Sv"].replace("+", "")),
            "wounds": number(model["W"]),
            "leadership_target": number(model["Ld"].replace("+", "")),
            "objective_control": number(model["OC"]),
            "invulnerable_target": number(model["inv_sv"]),
        }
        sheet_weapons = row["weapons"]
        weapon_rows: dict[str, dict] = {}
        for weapon in sheet_weapons:
            if not weapon["name"]:
                continue
            name = weapon["name"]
            profile = {
                "name": name,
                "range_inches": number(weapon["range"]),
                "attacks": number(weapon["A"]),
                "skill": number(weapon["BS_WS"]),
                "strength": number(weapon["S"]),
                "ap": number(weapon["AP"]),
                "damage": number(weapon["D"]),
                "keywords": traits(weapon["description"]),
            }
            profile.update(target_conditions(weapon["description"]))
            weapon_rows[name] = profile

        def weapon_ref(name: str, index: int = 1) -> dict:
            variants = [w for w in sheet_weapons if w["name"] == name or w["name"].startswith(name + " - ")]
            if not variants:
                raise ValueError(f"{ds['name']}: missing source weapon {name}")
            weapon_id = slug(name) + (f"-{index}" if index > 1 else "")
            profiles = {}
            for variant in variants:
                label = variant["name"].split(" - ", 1)[1] if " - " in variant["name"] else "standard"
                profile_name = slug(label) if label != "standard" else label
                profile = {
                    "name": variant["name"],
                    "range_inches": number(variant["range"]),
                    "attacks": number(variant["A"]),
                    "skill": number(variant["BS_WS"]),
                    "strength": number(variant["S"]),
                    "ap": number(variant["AP"]),
                    "damage": number(variant["D"]),
                    "keywords": traits(variant["description"]),
                }
                profile.update(target_conditions(variant["description"]))
                profiles[profile_name] = profile
            if not profiles:
                profiles["standard"] = stats
            return {"id": weapon_id, "profiles": profiles}

        ranged, melee = [], []
        for quantity, name in loadout_names(ds.get("loadout", "")):
            # Some source loadout labels use plural nouns while weapon rows use
            # their singular datasheet names.
            normalized = name.rstrip("s") if name not in weapon_rows else name
            matches = [key for key in weapon_rows if key == name or key.lower() == name.lower() or key.lower().startswith(name.lower().rstrip("s"))]
            if not matches and normalized in weapon_rows:
                matches = [normalized]
            if not matches:
                raise ValueError(f"{ds['name']}: cannot map fixed loadout weapon {name}")
            selected_name = matches[0]
            weapon_type = next(w["type"] for w in sheet_weapons if w["name"] == selected_name)
            for copy in range(quantity):
                (ranged if weapon_type == "Ranged" else melee).append(weapon_ref(selected_name, copy + 1))

        additional: dict[str, list] = {"ranged": [], "melee": []}
        option = OPTIONS[identity]
        optional_names = list(option.get("add", [])) + list(option.get("replacements", {}).values()) + list(option.get("one_of", []))
        for name in optional_names:
            matches = [key for key in weapon_rows if key == name or key.lower() == name.lower() or key.startswith(name + " - ")]
            if matches:
                weapon_type = next(w["type"] for w in sheet_weapons if w["name"] == matches[0])
                additional["ranged" if weapon_type == "Ranged" else "melee"].append(weapon_ref(name))

        meta = TRANSPORT[identity]
        abilities = []
        for ability in row["abilities"]:
            binding = ability["binding"]
            if binding.get("type") == "Core" and binding.get("ability_id"):
                ability_name = core_ability_names.get(str(binding["ability_id"]), "")
                if ability_name:
                    abilities.append({"name": ability_name, "parameter": binding.get("parameter", ""), "type": "Core", "text": ""})
            if binding.get("name"):
                abilities.append({"name": binding["name"], "text": html.unescape(re.sub(r"<[^>]+>", "", binding.get("description", "")))})
        base_mm = PROXIES_MM[identity]
        base_geometry = "circular vehicle proxy"
        geometry_scope = "Game proxy only; this vehicle's exact source footprint is outside the local geometry model."
        explicit_circle = re.fullmatch(r"(\d+(?:\.\d+)?)mm", model["base_size"])
        if explicit_circle:
            diameter_mm = float(explicit_circle.group(1))
            if identity == "impulsor" and diameter_mm != 100:
                raise ValueError("Impulsor source geometry changed; re-check the current 11e page before rebuilding.")
            base_mm = diameter_mm
            base_geometry = "circle"
            diameter_label = str(int(diameter_mm)) if diameter_mm.is_integer() else str(diameter_mm)
            geometry_scope = f"Wahapedia specifies a {diameter_label} mm diameter circle; runtime uses the corresponding circular footprint."
        profile = {
            "name": ds["name"], "source_book_id": row["source_book_id"], "source_datasheet_id": dsid,
            **provenance, "points": base_cost, "points_by_models": {1: base_cost},
            "third_plus_points_by_models": {1: third_cost}, "wargear_costs": option.get("wargear_costs", {}), "models": 1, "base_size_source": model["base_size"],
            "source_cost_sections": {name: {str(size): price for size, price in table.items()} for name, table in sections.items()},
            "base_size_source_mm": base_mm, "base_geometry": base_geometry, "base_radius_inches": (base_mm / 2.0) / 25.4,
            "geometry_scope": geometry_scope,
            "damaged_threshold": 0, "stats": stats,
            "keywords": [k["keyword"].upper() for k in row["keywords"]], "ranged": ranged, "melee": melee,
            "additional_weapon_profiles": additional,
            "transport": {**meta, "abilities": abilities, "options": option},
        }
        if second_cost is not None:
            profile["second_plus_points_by_models"] = {1: second_cost}
        if fourth_cost is not None:
            profile["fourth_plus_points_by_models"] = {1: fourth_cost}
        profiles[identity] = profile
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps({"schema_version": 1, "source": "Wahapedia 11th edition local data export", "source_book_id": "000000139", **provenance, "profiles": profiles}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(profiles)} local transport profiles to {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
