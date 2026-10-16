extends RefCounted
## Explicit core-profile admission, independent of display names and API prices.
const Pack = preload("res://scripts/data_pack.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const ID := "mixed-core-profiles-v1"
const DIRECTORY := "res://data/imported/starter-11e-v1"
const MAX_SQUADS := 6
const SPECS := {
	"intercessor-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1,
		"aliases": ["8da0-4570-c3c-819f"], "gun": ["bolt-rifle-intercessor-squad", "Saturation"], "blade": ["close-combat-weapon-intercessor-squad", "Knives and Fists"]},
	"terminator-squad": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 5, "template": 1,
		"aliases": ["4808-a80b-309a-7933", "80ad-6e62-65e3-e667"], "gun": ["storm-bolter-terminator-squad", "Storm Bolter"], "blade": ["power-fist-terminator-squad", "Power Fist"],
		"sergeant": ["power-weapon-terminator-squad", "Power Weapon"]},
	"necron-warriors": {"faction": "Necrons", "folder": "necrons", "models": 10, "template": 2,
		"aliases": ["58e9-5212-f5a6-c12d"], "gun": ["gauss-flayer", "Gauss flayer"], "blade": ["close-combat-weapon", "Close combat weapon"]},
	"immortals": {"faction": "Necrons", "folder": "necrons", "models": 5, "template": 2,
		"aliases": ["f81-b23c-e183-39d7"], "gun": ["gauss-blaster", "Gauss blaster"], "blade": ["close-combat-weapon-immortals", "Close combat weapon"]},
	"captain": {"faction": "Space Marines", "folder": "adeptus-astartes", "models": 1, "template": 1,
		"aliases": [], "gun": ["master-crafted-bolter", "Master-crafted Bolter"], "blade": ["master-crafted-power-weapon-captain", "Master-crafted Power Weapon"]},
	"overlord": {"faction": "Necrons", "folder": "necrons", "models": 1, "template": 2,
		"aliases": [], "gun": ["staff-of-light-overlord", "Ranged"], "blade": ["staff-of-light-overlord", "Melee"]}}

static func weapon(unit: Dictionary, choice: Array) -> Dictionary:
	for item: Dictionary in unit.get("source_weapon_definitions", []):
		if item.id != choice[0]: continue
		for profile: Dictionary in item.profiles:
			if profile.name != choice[1]: continue
			var stats: Dictionary = profile.stats
			return {"name": item.name + " / " + profile.name, "attacks": stats.get("A"), "skill": stats.get("BS", stats.get("WS")),
				"strength": stats.get("S"), "ap": stats.get("AP"), "damage": stats.get("D"), "range_inches": profile.get("range"),
				"keywords": Attacks.Traits.import_profile(profile)}
	return {}

static func canonical_id(faction: String, identity: String) -> String:
	for source: String in SPECS:
		var spec: Dictionary = SPECS[source]
		if spec.faction != faction: continue
		for alias: String in spec.get("aliases", []):
			if identity == "openhammer:11e:%s:%s" % [faction.uri_encode(), alias]: return "40kdc:11e:%s:%s" % [spec.folder, source]
	return identity

static func resolve(faction: String, identity: String) -> Dictionary:
	identity = canonical_id(faction, identity)
	for source: String in SPECS:
		var spec: Dictionary = SPECS[source]
		if spec.faction != faction: continue
		var canonical := "40kdc:11e:%s:%s" % [spec.folder, source]
		if identity != canonical: continue
		var pack := Pack.load_pack(DIRECTORY.path_join(spec.folder))
		if not pack.error.is_empty(): return pack
		for unit: Dictionary in pack.units:
			if unit.id != canonical: continue
			if not unit.get("base") is Dictionary or unit.base.get("shape") != "circle": return {"error": "Unresolved base geometry: " + source}
			for key: String in ["movement_inches", "toughness", "save_target", "wounds", "leadership_target", "objective_control"]:
				if not Roster.integer(unit.stats.get(key), 1): return {"error": "Unresolved characteristic: " + source + "/" + key}
				unit.stats[key] = int(unit.stats[key])
			var invulnerable: Variant = unit.stats.get("invulnerable_target", 0)
			if invulnerable == null: invulnerable = 0
			if not Roster.integer(invulnerable, 0, 6) or int(invulnerable) not in [0, 2, 3, 4, 5, 6]: return {"error": "Unresolved invulnerable save: " + source}
			unit.stats.invulnerable_target = int(invulnerable)
			var cost := 0
			for price: Dictionary in unit.get("points", []):
				if price.get("models") == spec.models and not price.has("models_max") and not price.has("unit_count_min") and Roster.integer(price.get("cost"), 1): cost = int(price.cost)
			if cost == 0: return {"error": "Unresolved canonical cost: " + source}
			var weapons: Dictionary = {}
			for key: String in ["gun", "blade", "sergeant"]:
				if not spec.has(key): continue
				var profile := weapon(unit, spec[key])
				if profile.is_empty(): return {"error": "Unresolved default weapon: " + source + "/" + key}
				var issue := Attacks._validate(profile, {"toughness": 4, "save_target": 4, "wounds_per_model": 1, "remaining_wounds": [1]}, {"distance_inches": 0.0, "heavy_eligible": false, "target_model_count": 1, "target_engaged": false})
				if not issue.is_empty(): return {"error": source + ": " + issue}
				weapons[key] = profile
			return {"error": "", "unit": unit, "spec": spec, "cost": cost, "models": spec.models, "weapons": weapons,
				"pack_hash": pack.manifest.units_sha256, "unsupported_abilities": unit.get("unsupported_rules", []).duplicate()}
	return {"error": "Unit is not implemented for this faction: " + identity}

static func admit(selection: Variant) -> Dictionary:
	if not selection is Dictionary or selection.size() != 5 or selection.get("schema_version") != 2: return {"error": "Invalid mixed army selection."}
	if not selection.get("faction") is String or not selection.get("category") is String or selection.category not in Roster.LIMITS: return {"error": "Invalid army identity or category."}
	if not Roster.integer(selection.get("points_limit"), 100, 100000) or (selection.category != "custom" and selection.points_limit != Roster.LIMITS[selection.category]): return {"error": "Category and points limit do not match."}
	if not selection.get("entries") is Array or selection.entries.is_empty() or selection.entries.size() > MAX_SQUADS: return {"error": "Choose 1–6 supported units per army."}
	var counts: Dictionary = {}
	var definitions: Dictionary = {}
	for entry: Variant in selection.entries:
		if not entry is Dictionary or entry.size() != 3 or not entry.get("definition_id") is String or not Roster.integer(entry.get("models"), 1, 20) or not Roster.integer(entry.get("copies"), 1, MAX_SQUADS): return {"error": "Invalid mixed army entry."}
		var identity := canonical_id(selection.faction, entry.definition_id)
		var resolved: Dictionary = definitions.get(identity, {})
		if resolved.is_empty(): resolved = resolve(selection.faction, identity)
		if not resolved.error.is_empty(): return resolved
		definitions[identity] = resolved
		if entry.models != resolved.models: return {"error": "%s requires %d models in this core-profile mode." % [resolved.unit.name, resolved.models]}
		counts[resolved.unit.id] = int(counts.get(resolved.unit.id, 0)) + int(entry.copies)
	var canonical: Array[Dictionary] = []
	var warnings: Array[String] = []
	var total := 0
	var count := 0
	var keys := counts.keys()
	keys.sort()
	for identity: String in keys:
		var resolved: Dictionary = definitions[identity]
		count += int(counts[identity])
		var battleline: bool = "Battleline" in resolved.unit.get("keywords", [])
		if counts[identity] > (6 if battleline else 3): return {"error": "Core-profile repetition limit exceeded: " + resolved.unit.name}
		total += int(resolved.cost) * int(counts[identity])
		canonical.append({"definition_id": identity, "models": resolved.models, "copies": int(counts[identity])})
		definitions[identity] = resolved
		if not resolved.unsupported_abilities.is_empty(): warnings.append(resolved.unit.name + ": " + ", ".join(resolved.unsupported_abilities))
	if count > MAX_SQUADS: return {"error": "The core-profile mode supports at most six units per player."}
	if total > selection.points_limit: return {"error": "The list exceeds the training-pack budget: %d/%d." % [total, selection.points_limit]}
	return {"error": "", "selection": {"schema_version": 2, "faction": selection.faction, "entries": canonical, "category": selection.category, "points_limit": int(selection.points_limit)},
		"total": total, "unit_count": count, "definitions": definitions, "warnings": warnings}

static func reference_army(faction: String) -> Dictionary:
	if faction not in ["Space Marines", "Necrons"]: return {"error": "No reference army for this faction."}
	var list := Roster.new_list("11e", faction, "training", 500)
	list.id = "reference:core-v1:" + faction
	list.name = "Mixed reference — " + faction
	list.pricing_source = "starter-training-v1"
	list.notes = "Core-profile training. Fixed weapons; unit/faction abilities and official legality are not implemented."
	for source: String in (["intercessor-squad", "terminator-squad"] if faction == "Space Marines" else ["necron-warriors", "immortals"]):
		var spec: Dictionary = SPECS[source]
		var resolved := resolve(faction, "40kdc:11e:%s:%s" % [spec.folder, source])
		if not resolved.error.is_empty(): return resolved
		list.catalog_digest = resolved.pack_hash
		list.entries.append({"unit_id": resolved.unit.id, "name": resolved.unit.name, "edition": "11e", "faction": faction,
			"role": Roster.role(resolved.unit.keywords), "models": resolved.models, "cost": resolved.cost,
			"copies": 4 if source == "necron-warriors" else 2, "source_digest": resolved.pack_hash})
	return {"error": "", "list": list}
