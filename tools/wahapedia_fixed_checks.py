"""Bounded source checks for uniform, default-equipment experimental profiles."""
from html import unescape
from html.parser import HTMLParser
import re


class Text(HTMLParser):
    def __init__(self):
        super().__init__()
        self.parts = []

    def handle_data(self, data):
        self.parts.append(data)

    def handle_starttag(self, tag, attrs):
        if tag in ["br", "li", "p"]:
            self.parts.append(" ")


def plain(value):
    parser = Text()
    parser.feed(value)
    return unescape("".join(parser.parts)).strip()


def number(value):
    value = plain(str(value)).strip().rstrip('+"')
    if re.fullmatch(r"D\d+(?:[+-]\d+)?", value, re.IGNORECASE):
        return value.upper()
    return float(value) if re.fullmatch(r"-?\d+(?:\.\d+)?", value) else None


def traits(description, runtime, target_restricted_traits=None):
    expected, unknown = {}, []
    expected_restrictions = {}
    target_restricted_traits = target_restricted_traits or {}
    simple = {"assault", "heavy", "close-quarters", "torrent", "hazardous", "devastating-wounds", "lethal-hits", "precision", "ignores-cover", "extra-attacks", "psychic", "twin-linked", "indirect-fire"}
    for part in plain(description).split(","):
        text = re.sub(r"\s+", " ", part.strip().strip("[]").lower())
        if not text:
            continue
        key = text.replace(" ", "-")
        match = re.fullmatch(r"(rapid fire|sustained hits|blast|melta|cleave) (\d+)", text)
        if match:
            expected[match[1].replace(" ", "-")] = int(match[2])
        elif re.fullmatch(r"anti-fly \d+\+", text):
            expected["anti-fly"] = int(re.search(r"\d+", text).group())
        elif re.fullmatch(r"anti-vehicle \d+\+", text):
            expected["anti-vehicle"] = int(re.search(r"\d+", text).group())
        elif key in simple:
            expected[key] = True
        elif re.fullmatch(r"(lethal hits|devastating wounds|sustained hits \d+): non-monster/vehicle", text):
            base = text.split(":", 1)[0]
            if base.startswith("sustained hits "):
                expected["sustained-hits"] = int(base.split()[-1])
                trait = "sustained-hits"
            else:
                trait = base.replace(" ", "-")
                expected[trait] = True
            expected_restrictions[trait] = ["MONSTER", "VEHICLE"]
        else:
            unknown.append(text)
    # A boolean is not a numerical trait parameter, even though Python equates True and 1.
    different = {key: {"runtime": runtime.get(key), "export": expected.get(key)}
                 for key in set(expected) | set(runtime)
                 if runtime.get(key) != expected.get(key) or type(runtime.get(key)) is not type(expected.get(key))}
    restriction_differences = {key: {"runtime": target_restricted_traits.get(key), "export": value}
                               for key, value in expected_restrictions.items()
                               if target_restricted_traits.get(key) != value}
    unexpected_restrictions = {key: value for key, value in target_restricted_traits.items()
                               if key not in expected_restrictions}
    restriction_differences.update({key: {"runtime": value, "export": None}
                                    for key, value in unexpected_restrictions.items()})
    return {"consistent": not (unknown or different or restriction_differences), "expected": expected,
            "differences": different, "target_restriction_differences": restriction_differences,
            "uninterpreted_source_traits": unknown}


def loadout(source, profile):
    roles = profile.get("default_loadout_by_role")
    if roles:
        blocks, issues, actual = {}, [], {}
        for match in re.finditer(r"<b>(?:The|Every) (.+?) is equipped with:</b>(.*?)(?=<br\s*/?>\s*<br\s*/?>|$)", source, re.I | re.S):
            role, equipment = match[1].strip(), plain(match[2])
            counts = {}
            for item in equipment.rstrip(". ").split(";"):
                entry = re.fullmatch(r"\s*(\d+)\s+(.+?)\s*", item)
                if entry is None:
                    issues.append("Unparsed equipment for " + role + ": " + item)
                    continue
                name = entry[2].casefold()
                counts[name] = counts.get(name, 0) + int(entry[1])
            blocks[role] = counts
        for role, expected in roles.items():
            if blocks.get(role) != expected:
                actual[role] = blocks.get(role)
        unexpected = sorted(set(blocks) - set(roles))
        if unexpected:
            issues.append("Unreviewed source equipment roles: " + ", ".join(unexpected))
        return {"consistent": not issues and not actual, "runtime_by_role": roles,
                "source_by_role": blocks, "differences": actual, "issues": issues,
                "scope": "Source default equipment compared separately for each named model role; optional replacements are not admitted."}
    text = plain(source)
    match = re.fullmatch(r"(?:Every model|This model) is equipped with:\s*(.+?)\.?", text)
    expected, actual, issues = {}, {}, []
    if match is None:
        issues.append("Default loadout is outside the supported uniform-equipment grammar")
    else:
        for item in match[1].rstrip(".").split(";"):
            entry = re.fullmatch(r"\s*(\d+)\s+(.+?)\s*", item)
            if entry is None:
                issues.append("Unparsed default equipment entry: " + item)
                continue
            name = entry[2].casefold()
            expected[name] = expected.get(name, 0) + int(entry[1])
    seen_physical_weapons = set()
    for group in ["ranged", "melee"]:
        for weapon in profile[group]:
            physical_id = weapon.get("physical_weapon_id")
            if physical_id and physical_id in seen_physical_weapons:
                continue
            names = {stats["name"].split(" - ", 1)[0].casefold() for stats in weapon["profiles"].values()}
            if len(names) != 1:
                issues.append("Weapon modes do not identify exactly one physical default weapon: " + weapon["id"])
                continue
            name = next(iter(names))
            actual[name] = actual.get(name, 0) + 1
            if physical_id:
                seen_physical_weapons.add(physical_id)
    return {"consistent": not issues and expected == actual, "runtime_per_model": actual,
            "source_per_model": expected, "issues": issues,
            "scope": "Uniform default equipment only; alternate profiles count as one physical weapon. Optional replacements are not admitted."}


def composition(rows, fixed):
    parts, issues = [], []
    for row in rows:
        match = re.fullmatch(r"(\d+)(?:-(\d+))?\s+(.+?)\s+models?\.?", plain(row["description"]))
        if match is None:
            issues.append("Unparsed composition row: " + row["line"])
            continue
        low, high = int(match[1]), int(match[2] or match[1])
        if low < 1 or high < low:
            issues.append("Invalid composition bounds")
        parts.append({"model": match[3], "minimum": low, "maximum": high})
    low = sum(p["minimum"] for p in parts)
    high = sum(p["maximum"] for p in parts)
    size = fixed.get("models")
    return {"consistent": bool(parts) and not issues and type(size) is int and low <= size <= high,
            "runtime_models": size, "source_minimum": low, "source_maximum": high,
            "source_model_roles": parts, "issues": issues, "model_role_assignment_certified": False}


def costs(rows, fixed):
    sections, issues, current = {}, [], None
    headings = {"YOUR UNIT COSTS": "ordinary", "YOUR 1ST TO 2ND UNITS COST": "first_second",
                "YOUR 3RD+ UNIT COSTS": "third_plus", "WARGEAR OPTIONS": "optional_wargear"}
    try:
        ordered = sorted(rows, key=lambda r: int(r["line"]))
    except ValueError:
        return {"consistent": False, "issues": ["Cost rows have no unambiguous source order"]}
    for row in ordered:
        description = plain(row["description"])
        if not row["cost"]:
            current = headings.get(description)
            if current is None:
                issues.append("Unrecognized cost section: " + description)
            continue
        if current == "optional_wargear":
            match = re.fullmatch(r"per\s+(.+)", description, re.IGNORECASE)
            price = number(row["cost"])
            if match is None or price is None:
                issues.append("Unparsed optional wargear cost row: " + row["line"])
                continue
            option = re.sub(r"[^a-z0-9]+", "-", match[1].strip().casefold()).strip("-")
            actual = sections.setdefault("optional_wargear", {})
            if option in actual and actual[option] != price:
                issues.append("Conflicting optional wargear costs for " + option)
            actual[option] = price
            continue
        match = re.fullmatch(r"(\d+) models?", description)
        price = number(row["cost"])
        if current is None or not match or price is None:
            issues.append("Unparsed model cost row: " + row["line"])
            continue
        size = match[1]
        table = sections.setdefault(current, {})
        if size in table and table[size] != price:
            issues.append("Conflicting cost values for size " + size)
        table[size] = price
    normal = sections.get("ordinary", sections.get("first_second", {}))
    if "ordinary" in sections and "first_second" in sections:
        issues.append("Ambiguous ordinary and tiered prices")
    size = str(fixed.get("models"))
    expected = normal.get(size)
    if expected is None:
        issues.append("No source price for the runtime fixed size")
    if fixed.get("cost") != expected:
        issues.append("Runtime fixed-unit price differs from source")
    if "third_cost" in fixed and fixed["third_cost"] != sections.get("third_plus", {}).get(size):
        issues.append("Stored third-unit reference price differs from source")
    for section, field in [("first_second", "sizes"), ("ordinary", "sizes"), ("third_plus", "third_plus_sizes")]:
        advertised = fixed.get(field)
        actual_sizes = sections.get(section)
        if advertised is None or actual_sizes is None:
            continue
        advertised = {str(k): v for k, v in advertised.items()}
        if advertised != actual_sizes:
            issues.append("Runtime model-count prices differ from source in " + section)
    optional_advertised = fixed.get("wargear_costs")
    optional_source = sections.get("optional_wargear")
    if optional_advertised is not None and optional_source is not None and optional_advertised != optional_source:
        issues.append("Runtime optional wargear costs differ from source")
    return {"consistent": not issues, "runtime_unit_cost": fixed.get("cost"), "source_unit_cost": expected,
            "source_sections": sections, "runtime_optional_wargear_costs": optional_advertised, "issues": issues,
            "scope": "Fixed size and default loadout price; priced optional wargear is checked where mapped. Third-unit reference is not admission above Incursion repetition limits; other sizes and general army legality remain outside scope."}
