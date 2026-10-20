"""Build the checked-in fixed-profile data for shared Marine transports.

Input is the pinned local Wahapedia e11 slice under .tools; this script does
not fetch or consult another rules source.
"""
from __future__ import annotations

import html
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / ".tools/wahapedia-marines-shared-catalog/catalog.json"
OUTPUT = ROOT / "data/edition_11/space_marines_transport_profiles.json"
UPDATED_AT = "2026-10-16T21:03:46+03:00"

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

# The source marks these vehicles as unbased models or custom geometry. These
# circular values are documented board proxies, not Wahapedia base dimensions.
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


def main() -> None:
    source = json.loads(SOURCE.read_text(encoding="utf-8"))
    profiles = {}
    for row in source["units"]:
        ds = row["source_datasheet"]
        dsid = ds["id"]
        if dsid not in IDENTITIES:
            continue
        identity = IDENTITIES[dsid]
        model = row["models"][0]
        costs = list(dict.fromkeys(int(item["cost"]) for item in row["costs"] if item.get("cost", "").isdigit() and item.get("description") == "1 model"))
        base_cost = costs[0]
        third_cost = costs[-1]
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
                profiles[profile_name] = {
                    "name": variant["name"],
                    "range_inches": number(variant["range"]),
                    "attacks": number(variant["A"]),
                    "skill": number(variant["BS_WS"]),
                    "strength": number(variant["S"]),
                    "ap": number(variant["AP"]),
                    "damage": number(variant["D"]),
                    "keywords": traits(variant["description"]),
                }
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
            if binding.get("name"):
                abilities.append({"name": binding["name"], "text": html.unescape(re.sub(r"<[^>]+>", "", binding.get("description", "")))})
        base_mm = PROXIES_MM[identity]
        profiles[identity] = {
            "name": ds["name"], "source_book_id": row["source_book_id"], "source_datasheet_id": dsid,
            "source_export_updated_at": UPDATED_AT, "points": base_cost, "points_by_models": {1: base_cost},
            "third_plus_points_by_models": {1: third_cost}, "wargear_costs": option.get("wargear_costs", {}), "models": 1, "base_size_source": model["base_size"],
            "base_size_source_mm": base_mm, "base_geometry": "circular vehicle proxy", "base_radius_inches": (base_mm / 2.0) / 25.4,
            "geometry_scope": "Game proxy only; Wahapedia identifies this vehicle as unbased or custom geometry.",
            "damaged_threshold": 0, "stats": stats,
            "keywords": [k["keyword"].upper() for k in row["keywords"]], "ranged": ranged, "melee": melee,
            "additional_weapon_profiles": additional,
            "transport": {**meta, "abilities": abilities, "options": option},
        }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps({"schema_version": 1, "source": "Wahapedia 11th edition local data export", "source_book_id": "000000139", "source_export_updated_at": UPDATED_AT, "profiles": profiles}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(profiles)} local transport profiles to {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
