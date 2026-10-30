"""Bounded source checks for uniform, default-equipment experimental profiles."""
from html import unescape
from html.parser import HTMLParser
import re
import unicodedata


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


def name_key(value):
    """Normalize source/runtime labels without treating distinct words as aliases."""
    text = unicodedata.normalize("NFKD", plain(str(value))).casefold()
    return "".join(char for char in text if char.isalnum())


# Preserve source labels but reconcile this known Data Export spelling variant.
EQUIPMENT_LABEL_ALIASES = {"artificiercrozius": "artificercrozius"}


def equipment_key(value):
    key = name_key(value)
    return EQUIPMENT_LABEL_ALIASES.get(key, key)


def _equipment_blocks(source):
    blocks, issues = {}, []
    pattern = r"<b>(?:(?:The|Every) )?(.+?) is equipped with:</b>(.*?)(?=<br\s*/?>\s*<br\s*/?>|$)"
    for match in re.finditer(pattern, source, re.I | re.S):
        role, equipment = match[1].strip(), plain(match[2])
        counts = {}
        for item in equipment.rstrip(". ").split(";"):
            if not item.strip():
                continue
            entry = re.fullmatch(r"\s*(\d+)\s+(.+?)\s*", item)
            if entry is None:
                # Wahapedia omits an explicit quantity for singular equipment names.
                name, quantity = equipment_key(item), 1
            else:
                name, quantity = equipment_key(entry[2]), int(entry[1])
            counts[name] = counts.get(name, 0) + quantity
        blocks[role] = counts
    return blocks, issues


def traits(description, runtime, target_restricted_traits=None, target_required_traits=None):
    expected, unknown = {}, []
    expected_restrictions = {}
    expected_requirements = {}
    target_restricted_traits = target_restricted_traits or {}
    target_required_traits = target_required_traits or {}
    simple = {"assault", "heavy", "close-quarters", "torrent", "hazardous", "devastating-wounds", "lethal-hits", "precision", "ignores-cover", "extra-attacks", "psychic", "twin-linked", "indirect-fire", "lance", "one-shot"}
    for part in plain(description).split(","):
        text = re.sub(r"\s+", " ", part.strip().strip("[]").lower())
        if not text:
            continue
        key = text.replace(" ", "-")
        match = re.fullmatch(r"(rapid fire|sustained hits|blast|melta|cleave) (\d+)", text)
        if match:
            trait = match[1].replace(" ", "-")
            value = int(match[2])
            expected[trait] = value
        elif re.fullmatch(r"anti-[a-z/-]+ \d+\+", text):
            match = re.fullmatch(r"anti-([a-z/-]+) (\d+)\+", text)
            target, value = match[1].replace("/", "-"), int(match[2])
            if target == "monster-vehicle":
                expected["anti-monster"] = value
                expected["anti-vehicle"] = value
            elif target == "non-monster-vehicle":
                expected["anti-non-monster-vehicle"] = value
            else:
                expected["anti-" + target] = value
        elif key in simple:
            expected[key] = True
        elif key == "pistol":
            # The runtime represents the Pistol weapon type through its close-range gate.
            expected["close-quarters"] = True
        elif re.fullmatch(r"(lethal hits|devastating wounds|sustained hits \d+): (?:non-monster/vehicle|infantry)", text):
            base = text.split(":", 1)[0]
            target = text.split(":", 1)[1].strip()
            if base.startswith("sustained hits "):
                expected["sustained-hits"] = int(base.split()[-1])
                trait = "sustained-hits"
            else:
                trait = base.replace(" ", "-")
                expected[trait] = True
            if target == "infantry":
                expected_requirements[trait] = ["INFANTRY"]
            else:
                expected_restrictions[trait] = ["MONSTER", "VEHICLE"]
        else:
            unknown.append(text)
    # Keep parameterized traits type-strict. Blast 1 and boolean Blast have the
    # same supported attack-count effect in runtime, though the source/runtime
    # profiles encode that one-step value differently.
    def same_value(key, actual, source):
        if key == "blast":
            blast_one = lambda value: value is True or (type(value) is int and value == 1)
            if blast_one(actual) and blast_one(source):
                return True
        if isinstance(actual, bool) or isinstance(source, bool):
            return type(actual) is type(source) and actual == source
        return actual == source
    different = {key: {"runtime": runtime.get(key), "export": expected.get(key)}
                 for key in set(expected) | set(runtime)
                 if not same_value(key, runtime.get(key), expected.get(key))}
    restriction_differences = {key: {"runtime": target_restricted_traits.get(key), "export": value}
                               for key, value in expected_restrictions.items()
                               if target_restricted_traits.get(key) != value}
    unexpected_restrictions = {key: value for key, value in target_restricted_traits.items()
                               if key not in expected_restrictions}
    restriction_differences.update({key: {"runtime": value, "export": None}
                                    for key, value in unexpected_restrictions.items()})
    requirement_differences = {key: {"runtime": target_required_traits.get(key), "export": value}
                               for key, value in expected_requirements.items()
                               if target_required_traits.get(key) != value}
    unexpected_requirements = {key: value for key, value in target_required_traits.items()
                               if key not in expected_requirements}
    requirement_differences.update({key: {"runtime": value, "export": None}
                                    for key, value in unexpected_requirements.items()})
    return {"consistent": not (unknown or different or restriction_differences or requirement_differences), "expected": expected,
            "differences": different, "target_restriction_differences": restriction_differences,
            "target_requirement_differences": requirement_differences,
            "uninterpreted_source_traits": unknown}


def loadout(source, profile):
    roles = profile.get("default_loadout_by_role")
    if roles:
        blocks, issues = _equipment_blocks(source)
        normalized_blocks = {name_key(role): counts for role, counts in blocks.items()}
        actual = {}
        generic_keys = {"model", "thismodel", "everymodel", "allmodels"}
        generic_source_keys = [key for key in normalized_blocks if key in generic_keys]
        broadcast_generic = len(blocks) == 1 and len(generic_source_keys) == 1
        for role, expected in roles.items():
            expected = {equipment_key(name): count for name, count in expected.items()}
            source_counts = normalized_blocks.get(name_key(role))
            if source_counts is None and broadcast_generic:
                source_counts = normalized_blocks[generic_source_keys[0]]
            if source_counts != expected:
                actual[role] = source_counts
        expected_roles = {name_key(role) for role in roles}
        unexpected = sorted(role for role in blocks
                            if name_key(role) not in expected_roles
                            and not (broadcast_generic and name_key(role) in generic_keys))
        if unexpected:
            issues.append("Unreviewed source equipment roles: " + ", ".join(unexpected))
        return {"consistent": not issues and not actual, "runtime_by_role": roles,
                "source_by_role": blocks, "differences": actual, "issues": issues,
                "scope": "Source default equipment compared by model role; a sole generic source role applies to each runtime role. Optional replacements are not admitted."}
    model_loadouts = profile.get("model_loadouts", [])
    if model_loadouts and any(item.get("source_loadout_name", item.get("source_model_name", "")) for item in model_loadouts):
        blocks, issues = _equipment_blocks(source)
        runtime, runtime_by_key = {}, {}
        for item in model_loadouts:
            role = item.get("source_loadout_name", item.get("source_model_name", item.get("role", "")))
            if not role:
                issues.append("Runtime model loadout has no source model name")
                continue
            counts, seen_physical = {}, set()
            for group in ["ranged", "melee"]:
                for weapon in item.get(group, []):
                    physical_id = weapon.get("physical_weapon_id")
                    if physical_id and physical_id in seen_physical:
                        continue
                    names = {equipment_key(stats["name"].split(" - ", 1)[0]) for stats in weapon.get("profiles", {}).values()}
                    if len(names) != 1:
                        issues.append("Weapon modes do not identify one physical model weapon for " + role + ": " + weapon.get("id", "unknown"))
                        continue
                    name = next(iter(names))
                    counts[name] = counts.get(name, 0) + 1
                    if physical_id:
                        seen_physical.add(physical_id)
            fingerprint = tuple(sorted(counts.items()))
            key = (name_key(role), fingerprint)
            runtime_by_key.setdefault(key, (role, counts))
            runtime[role] = counts
        unmatched = dict(runtime_by_key)
        differences = {}
        for source_role, source_counts in blocks.items():
            source_key = name_key(source_role)
            source_fingerprint = tuple(sorted(source_counts.items()))
            named_candidates = [key for key, (runtime_role, _) in unmatched.items()
                                if source_key == key[0]
                                or (min(len(source_key), len(key[0])) >= 12
                                    and (source_key.startswith(key[0]) or key[0].startswith(source_key)))]
            matching_candidates = [key for key in named_candidates if key[1] == source_fingerprint]
            if not matching_candidates and not named_candidates:
                matching_candidates = [key for key in unmatched if key[1] == source_fingerprint]
            if matching_candidates:
                del unmatched[matching_candidates[0]]
                continue
            candidate = named_candidates[0] if named_candidates else next(iter(unmatched), None)
            runtime_counts = unmatched[candidate][1] if candidate is not None else None
            differences[source_role] = {"runtime": runtime_counts, "source": source_counts}
            if candidate is not None:
                del unmatched[candidate]
        for role, counts in unmatched.values():
            differences[role] = {"runtime": counts, "source": None}
        return {"consistent": not issues and not differences, "runtime_by_model": runtime,
                "source_by_model": blocks, "differences": differences, "issues": issues,
                "scope": "Default equipment is compared by source role and physical-equipment signature; role labels may include equipment names. Optional replacements are not admitted."}
    text = plain(source)
    if not text and not profile.get("ranged") and not profile.get("melee"):
        return {"consistent": True, "runtime_per_model": {}, "source_per_model": {}, "issues": [],
                "scope": "No fixed equipment is listed in the source or runtime profile."}
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
            name = equipment_key(entry[2])
            expected[name] = expected.get(name, 0) + int(entry[1])
    seen_physical_weapons = set()
    for group in ["ranged", "melee"]:
        for weapon in profile[group]:
            physical_id = weapon.get("physical_weapon_id")
            if physical_id and physical_id in seen_physical_weapons:
                continue
            names = {name_key(stats["name"].split(" - ", 1)[0]) for stats in weapon["profiles"].values()}
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
        if low < 0 or high < low:
            issues.append("Invalid composition bounds")
        parts.append({"model": match[3], "minimum": low, "maximum": high})
    low = sum(p["minimum"] for p in parts)
    high = sum(p["maximum"] for p in parts)
    size = fixed.get("models")
    return {"consistent": bool(parts) and not issues and type(size) is int and low <= size <= high,
            "runtime_models": size, "source_minimum": low, "source_maximum": high,
            "source_model_roles": parts, "issues": issues, "model_role_assignment_certified": False}


def _composition_costs(rows, fixed, max_supported_copies):
    """Compare duplicated total-size rows when a verified source maps each to a role mix."""
    headings = {"YOUR UNIT COSTS": "ordinary", "YOUR 1ST TO 2ND UNITS COST": "first_second",
                "YOUR 3RD+ UNIT COSTS": "third_plus"}
    source_rows, issues, current = [], [], None
    for row in rows:
        description = plain(row["description"])
        if not row["cost"]:
            current = headings.get(description)
            if current is None:
                issues.append("Unrecognized composition-cost section: " + description)
            continue
        match = re.fullmatch(r"(\d+) models?", description)
        price = number(row["cost"])
        if current not in ["first_second", "third_plus"] or match is None or price is None:
            issues.append("Unparsed composition-cost row: " + row["line"])
            continue
        source_rows.append((current, int(match[1]), int(price)))

    mapped_rows = fixed.get("mfm_composition_cost_rows", [])
    mapped_source_rows = []
    legal_first, legal_third = {}, {}
    seen_first, seen_third = {}, {}
    for row in mapped_rows:
        try:
            models = int(row["models"])
            headtakers = int(row["headtakers"])
            wolves = int(row["hunting_wolves"])
            first = int(row["first_to_second_points"])
            third = int(row["third_plus_points"])
            compatible = row["wahapedia_composition_compatible"] is True
        except (KeyError, TypeError, ValueError):
            issues.append("Malformed official role-composition cost mapping")
            continue
        if models <= 0 or headtakers < 0 or wolves < 0 or headtakers + wolves != models or first <= 0 or third <= 0:
            issues.append("Invalid official role-composition cost mapping")
            continue
        mapped_source_rows.extend([("first_second", models, first), ("third_plus", models, third)])
        if not compatible:
            continue
        for table, seen, key, price in [(legal_first, seen_first, "first_second", first),
                                        (legal_third, seen_third, "third_plus", third)]:
            if models in seen and seen[models] != price:
                issues.append("Conflicting prices for a legal role composition at %d models" % models)
            seen[models] = price
            table[str(models)] = price

    if sorted(source_rows) != sorted(mapped_source_rows):
        issues.append("Official role-price mapping does not account for every source cost row")
    if not legal_first:
        issues.append("No source-priced role composition is compatible with the selected datasheet composition")
    if int(fixed.get("models", -1)) not in [int(size) for size in legal_first]:
        issues.append("Runtime default size has no compatible role-priced composition")
    elif int(fixed.get("cost", -1)) != legal_first.get(str(fixed.get("models"))):
        issues.append("Runtime default price differs from its compatible role composition")
    advertised_first = {str(k): int(v) for k, v in fixed.get("sizes", {}).items()}
    if advertised_first != legal_first:
        issues.append("Runtime selectable sizes differ from the compatible role-priced compositions")
    if max_supported_copies is None or max_supported_copies >= 3:
        advertised_third = {str(k): int(v) for k, v in fixed.get("third_plus_sizes", {}).items()}
        if advertised_third != legal_third:
            issues.append("Runtime third-copy prices differ from the compatible role-priced compositions")

    return {"consistent": not issues, "price_scope_complete": bool(legal_first) and advertised_first == legal_first
            and (max_supported_copies is not None and max_supported_copies < 3 or
                 {str(k): int(v) for k, v in fixed.get("third_plus_sizes", {}).items()} == legal_third),
            "optional_wargear_scope_complete": True, "runtime_unit_cost": fixed.get("cost"),
            "source_unit_cost": legal_first.get(str(fixed.get("models"))),
            "source_sections": {"first_second": legal_first, "third_plus": legal_third},
            "runtime_optional_wargear_costs": fixed.get("wargear_costs"), "issues": issues,
            "role_price_scope_complete": not bool(fixed.get("unpriced_source_permitted_role_mix_note", "")),
            "unpriced_source_permitted_role_mix_note": fixed.get("unpriced_source_permitted_role_mix_note", ""),
            "source_role_cost_rows": mapped_rows,
            "scope": "Every selectable role composition is checked against its mapped official role-price row; incompatible source rows stay excluded. Unpriced source-permitted role mixes are disclosed and unavailable."}


def costs(rows, fixed, max_supported_copies=None):
    if fixed.get("mfm_composition_cost_rows"):
        return _composition_costs(rows, fixed, max_supported_copies)
    sections, issues, current = {}, [], None
    headings = {"YOUR UNIT COSTS": "ordinary", "YOUR 1ST TO 2ND UNITS COST": "first_second",
                "YOUR 3RD+ UNIT COSTS": "third_plus", "WARGEAR OPTIONS": "optional_wargear",
                "YOUR 1ST TO 3RD UNITS COST": "first_third",
                "YOUR 1ST TO 3RD UNITS COSTS": "first_third",
                "YOUR 4TH+ UNIT COSTS": "fourth_plus",
                "YOUR 1ST UNIT COSTS": "first",
                "YOUR 2ND+ UNIT COSTS": "second_plus"}
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
    size = str(fixed.get("models"))
    def price_for_copy(copy_number, model_size):
        if "ordinary" in sections:
            return sections["ordinary"].get(model_size)
        if copy_number >= 4 and "fourth_plus" in sections:
            return sections["fourth_plus"].get(model_size)
        if "first_second" in sections:
            if copy_number <= 2:
                return sections["first_second"].get(model_size)
            return sections.get("third_plus", {}).get(model_size, sections["first_second"].get(model_size))
        if "first_third" in sections:
            if copy_number <= 3:
                return sections["first_third"].get(model_size)
            return sections.get("fourth_plus", {}).get(model_size, sections["first_third"].get(model_size))
        if "first" in sections:
            if copy_number == 1:
                return sections["first"].get(model_size)
            if copy_number == 2:
                return sections.get("second_plus", {}).get(model_size, sections["first"].get(model_size))
            if copy_number == 3:
                return sections.get("third_plus", {}).get(model_size, sections.get("second_plus", {}).get(model_size, sections["first"].get(model_size)))
            return sections.get("fourth_plus", {}).get(model_size, sections.get("third_plus", {}).get(model_size, sections.get("second_plus", {}).get(model_size, sections["first"].get(model_size))))
        if "first_second" in sections or "first_third" in sections or "first" in sections:
            issues.append("Source copy-price tier is missing a required continuation")
        return None

    expected = price_for_copy(1, size)
    expected_third = price_for_copy(3, size)
    if expected is None:
        issues.append("No source price for the runtime fixed size")
    if fixed.get("cost") != expected:
        issues.append("Runtime fixed-unit price differs from source")
    advertised_first = fixed.get("sizes")
    price_sections = {"ordinary", "first_second", "third_plus", "first_third", "fourth_plus", "first", "second_plus"}
    source_sizes = sorted({model_size for name, table in sections.items() if name in price_sections
                            for model_size in table})
    if advertised_first is not None:
        advertised_first = {str(k): v for k, v in advertised_first.items()}
        source_first = {model_size: price_for_copy(1, model_size) for model_size in source_sizes}
        if advertised_first != source_first:
            issues.append("Runtime first-copy model-count prices differ from source")
    expected_second = price_for_copy(2, size)
    second_copy_in_scope = max_supported_copies is None or max_supported_copies >= 2
    advertised_second = fixed.get("second_plus_sizes")
    if advertised_second is None:
        advertised_second = fixed.get("second_plus_cost")
        if advertised_second is not None:
            advertised_second = {size: advertised_second}
    if advertised_second is not None and expected_second is not None and second_copy_in_scope:
        advertised_second = {str(k): v for k, v in advertised_second.items()}
        source_second = {model_size: price_for_copy(2, model_size) for model_size in source_sizes}
        if advertised_second != source_second:
            issues.append("Runtime second-copy model-count prices differ from source")
    elif expected_second is not None and expected_second != expected and second_copy_in_scope:
        issues.append("Runtime does not represent the source price change by the second copy")
    advertised_third = fixed.get("third_plus_sizes")
    if advertised_third is None and fixed.get("second_plus_sizes") is not None:
        advertised_third = fixed.get("second_plus_sizes")
    legacy_third_scalar = False
    if advertised_third is None:
        advertised_third = fixed.get("third_cost")
        if advertised_third is not None:
            advertised_third = {size: advertised_third}
            legacy_third_scalar = True
    third_copy_in_scope = max_supported_copies is None or max_supported_copies >= 3
    if advertised_third is not None and expected_third is not None and third_copy_in_scope:
        advertised_third = {str(k): v for k, v in advertised_third.items()}
        source_third = {model_size: price_for_copy(3, model_size) for model_size in source_sizes}
        if legacy_third_scalar:
            source_third = {size: expected_third}
        if advertised_third != source_third:
            issues.append("Runtime third-copy model-count prices differ from source")
    elif expected_third is not None and expected_third != expected and third_copy_in_scope:
        issues.append("Runtime does not represent a source price change by the third copy")

    fourth_plus = sections.get("fourth_plus")
    source_tier_after_third = None
    if fourth_plus:
        if max_supported_copies is None:
            advertised_fourth = fixed.get("fourth_plus_sizes")
            expected_fourth = {model_size: fourth_plus.get(model_size) for model_size in source_sizes}
            if advertised_fourth is None:
                source_tier_after_third = "not_checked_copy_limit_unknown"
            else:
                advertised_fourth = {str(k): v for k, v in advertised_fourth.items()}
                source_tier_after_third = "represented" if advertised_fourth == expected_fourth else "mismatch"
                if source_tier_after_third == "mismatch":
                    issues.append("Runtime fourth-and-later copy prices differ from source")
        elif max_supported_copies >= 4:
            advertised_fourth = fixed.get("fourth_plus_sizes")
            expected_fourth = {model_size: fourth_plus.get(model_size) for model_size in source_sizes}
            if advertised_fourth is None:
                source_tier_after_third = "not_represented"
                issues.append("Runtime does not represent the source fourth-and-later copy price")
            else:
                advertised_fourth = {str(k): v for k, v in advertised_fourth.items()}
                if advertised_fourth != expected_fourth:
                    source_tier_after_third = "mismatch"
                    issues.append("Runtime fourth-and-later copy prices differ from source")
                else:
                    source_tier_after_third = "represented"
        else:
            source_tier_after_third = "outside_declared_copy_limit"
    optional_advertised = fixed.get("wargear_costs")
    optional_source = sections.get("optional_wargear")
    optional_scope_complete = not optional_source or optional_advertised is not None
    if optional_advertised is not None and optional_source is not None:
        normalized_advertised = {name_key(k): v for k, v in optional_advertised.items()}
        normalized_source = {name_key(k): v for k, v in optional_source.items()}
        if normalized_advertised != normalized_source:
            issues.append("Runtime optional wargear costs differ from source")
    if "ordinary" in sections or "second_plus" in sections:
        price_scope_complete = True
    elif ("third_plus" in sections or "first_third" in sections) and max_supported_copies is not None and max_supported_copies <= 3:
        price_scope_complete = True
    elif "fourth_plus" in sections and (max_supported_copies is not None and max_supported_copies <= 3
                                         or source_tier_after_third == "represented"):
        price_scope_complete = True
    elif "first_second" in sections and max_supported_copies is not None and max_supported_copies <= 2:
        price_scope_complete = True
    elif "first" in sections and max_supported_copies == 1:
        price_scope_complete = True
    else:
        price_scope_complete = False
    return {"consistent": not issues, "price_scope_complete": price_scope_complete,
            "optional_wargear_scope_complete": optional_scope_complete,
            "runtime_unit_cost": fixed.get("cost"), "source_unit_cost": expected,
            "source_sections": sections, "runtime_optional_wargear_costs": optional_advertised, "issues": issues,
            "source_fourth_plus_status": source_tier_after_third,
            "scope": "First-copy, second-copy, third-copy, source-listed size tiers and mapped optional wargear. Copy tiers beyond the source or runtime cap remain explicitly incomplete."}
