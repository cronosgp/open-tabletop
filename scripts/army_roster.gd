extends RefCounted
## Local list planning, independent of the implemented match rules.
const EDITIONS := ["10e", "11e"]
const LIMITS := {"training": 500, "incursion": 1000, "strike_force": 2000, "onslaught": 3000, "custom": 0}
const CHAPTERS := ["Black Templars", "Blood Angels", "Dark Angels", "Deathwatch", "Imperial Fists", "Iron Hands", "Raven Guard", "Salamanders", "Space Wolves", "Ultramarines", "White Scars"]

static func integer(value: Variant, minimum: int = 0, maximum: int = 1000000) -> bool:
	return (value is int or value is float) and is_finite(value) and value == floor(value) and value >= minimum and value <= maximum

static func role(keywords: Array) -> String:
	var lower := str(keywords).to_lower()
	if "character" in lower: return "Personagem"
	if "battleline" in lower and "non-battleline" not in lower: return "Linha de batalha"
	if "dedicated transport" in lower: return "Transporte dedicado"
	return "Other units"

static func faction_allowed(army: String, unit: String, allies: bool) -> bool:
	return allies or army == unit or (army in CHAPTERS and unit == "Space Marines")

static func normalize(raw: Variant, edition: String) -> Dictionary:
	if edition not in EDITIONS or not raw is Dictionary: return {"error": "Invalid catalog record."}
	for key in ["id", "name", "faction"]:
		if not raw.get(key) is String or raw[key].strip_edges().is_empty(): return {"error": "Unit is missing an identifier: " + key}
	var bounds: Variant = raw.get("composition", {})
	if not bounds is Dictionary: bounds = {}
	var low: Variant = bounds.get("min_models")
	var high: Variant = bounds.get("max_models")
	var valid_bounds: bool = integer(low, 1, 1000) and integer(high, 1, 1000) and high >= low
	var prices: Variant = raw.get("points", {})
	if not prices is Dictionary: prices = {}
	var costs: Dictionary = {}
	if valid_bounds and integer(prices.get("base"), 1): costs[int(low)] = int(prices.base)
	var variants: Variant = prices.get("variants", [])
	if not variants is Array: variants = []
	for variant: Variant in variants:
		if not variant is Dictionary or not integer(variant.get("models"), 1, 1000) or not integer(variant.get("points"), 1): continue
		var count := int(variant.models)
		var cost := int(variant.points)
		if costs.has(count) and costs[count] != cost: costs[count] = null
		elif not costs.has(count): costs[count] = cost
	var options: Array[Dictionary] = []
	var counts := costs.keys()
	counts.sort()
	for count: int in counts: options.append({"models": count, "cost": costs[count]})
	if options.is_empty(): options.append({"models": 0, "cost": null})
	var keywords: Array = raw.get("keywords", []) if raw.get("keywords", []) is Array else []
	return {"error": "", "unit": {"id": "openhammer:%s:%s:%s" % [edition, raw.faction.uri_encode(), raw.id], "source_id": raw.id,
		"edition": edition, "name": raw.name, "faction": raw.faction, "role": role(keywords), "keywords": keywords,
		"options": options, "composition_verified": false, "composition_bounds_valid": valid_bounds, "source_digest": JSON.stringify(raw).sha256_text()}}

static func new_list(edition: String, faction: String, category: String = "incursion", limit: int = 1000) -> Dictionary:
	return {"id": "", "name": "My Army", "edition": edition, "faction": faction, "category": category,
		"points_limit": limit, "allow_allies": false, "entries": [], "notes": "", "catalog_digest": ""}

static func entry(unit: Dictionary, option: int, copies: int = 1) -> Dictionary:
	return {"unit_id": unit.id, "name": unit.name, "edition": unit.edition, "faction": unit.faction, "role": unit.role,
		"models": unit.options[option].models, "cost": unit.options[option].cost, "copies": copies, "source_digest": unit.source_digest}

static func summary(list: Dictionary) -> Dictionary:
	var points := 0
	var unknown := 0
	var units := 0
	for item: Dictionary in list.entries:
		units += int(item.copies)
		if item.cost == null: unknown += int(item.copies)
		else: points += int(item.cost) * int(item.copies)
	return {"points": points, "unknown": unknown, "units": units, "remaining": int(list.points_limit) - points,
		"within_budget": units > 0 and unknown == 0 and points <= list.points_limit}

static func validate(list: Variant) -> String:
	if not list is Dictionary: return "Invalid list."
	for key in ["id", "name", "edition", "faction", "category", "notes", "catalog_digest"]:
		if not list.get(key) is String: return "Invalid list field: " + key
	if list.name.strip_edges().is_empty() or list.name.length() > 120: return "Give the list a name of up to 120 characters."
	if list.edition not in EDITIONS or list.faction.is_empty(): return "Choose an edition and army."
	if list.category not in LIMITS or not integer(list.get("points_limit"), 100, 100000): return "Invalid points limit."
	if list.category != "custom" and list.points_limit != LIMITS[list.category]: return "The points limit does not match the category."
	if not list.get("allow_allies") is bool or not list.get("entries") is Array or list.entries.size() > 100 or list.notes.length() > 5000: return "Invalid list structure or size."
	for item: Variant in list.entries:
		if not item is Dictionary: return "Invalid entry."
		for key in ["unit_id", "name", "edition", "faction", "role", "source_digest"]:
			if not item.get(key) is String: return "Invalid unit entry field: " + key
		if item.unit_id.is_empty() or item.edition != list.edition: return "Cannot mix editions."
		if not faction_allowed(list.faction, item.faction, list.allow_allies): return "Allow allies to include another faction."
		if not integer(item.get("models"), 0, 1000) or not integer(item.get("copies"), 1, 20): return "Invalid unit/model count."
		if not item.has("cost") or (item.cost != null and not integer(item.cost, 1)): return "Invalid cost."
		if item.has("visual_variants"):
			if not item.visual_variants is Array or item.visual_variants.size() != int(item.models) * int(item.copies): return "Invalid local miniature appearance assignments."
			for visual_id: Variant in item.visual_variants:
				if not visual_id is String or visual_id.length() > 128: return "Invalid local miniature appearance assignment."
	return ""

static func reprice(list: Dictionary, catalog: Dictionary) -> Dictionary:
	var updated := list.duplicate(true)
	var by_id: Dictionary = {}
	for unit: Dictionary in catalog.units: by_id[unit.id] = unit
	for index in range(updated.entries.size()):
		var old: Dictionary = updated.entries[index]
		if not by_id.has(old.unit_id): return {"error": "Unit is missing from the current catalog: " + old.name}
		var unit: Dictionary = by_id[old.unit_id]
		var option := -1
		for choice in range(unit.options.size()):
			if unit.options[choice].models == old.models: option = choice
		if option < 0: return {"error": "Composition changed in the catalog: " + old.name}
		var refreshed := entry(unit, option, int(old.copies))
		if old.has("visual_variants"): refreshed.visual_variants = old.visual_variants.duplicate(true)
		updated.entries[index] = refreshed
	updated.catalog_digest = catalog.digest
	return {"error": "", "list": updated}

static func standard(catalog: Dictionary, faction: String, category: String, limit: int) -> Dictionary:
	var list := new_list(catalog.edition, faction, category, limit)
	list.name = "Editable Base — " + faction
	list.notes = "Core generated from the lowest available costs: up to one character and two battleline units. This is not an official list or competitive recommendation."
	list.catalog_digest = catalog.digest
	for wanted in ["Personagem", "Linha de batalha", "Linha de batalha"]:
		var best: Dictionary = {}
		for unit: Dictionary in catalog.units:
			if not faction_allowed(faction, unit.faction, false) or unit.role != wanted: continue
			for option in range(unit.options.size()):
				if unit.options[option].cost == null: continue
				var candidate := entry(unit, option)
				if summary(list).points + int(candidate.cost) > limit: continue
				if best.is_empty() or int(candidate.cost) < int(best.cost): best = candidate
		if not best.is_empty(): list.entries.append(best)
	return list

static func read_json(path: String, maximum: int = 16777216) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": "Could not open " + path}
	if file.get_length() > maximum: return {"error": "File exceeds the size limit."}
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK: return {"error": "Invalid JSON; the file was preserved."}
	return {"error": "", "data": json.data}

static func catalog_error(catalog: Variant) -> String:
	if not catalog is Dictionary or catalog.get("schema_version") != 1 or catalog.get("edition") not in EDITIONS or not catalog.get("units") is Array or not catalog.get("digest") is String or not catalog.get("fetched_at") is String: return "Incompatible catalog."
	if catalog.units.is_empty() or catalog.units.size() > 10000: return "Invalid unit count."
	var ids: Dictionary = {}
	for unit: Variant in catalog.units:
		if not unit is Dictionary: return "Invalid unit in catalog."
		for key in ["id", "source_id", "edition", "name", "faction", "role", "source_digest"]:
			if not unit.get(key) is String: return "Invalid catalog field: " + key
		if ids.has(unit.id) or unit.id.is_empty() or unit.edition != catalog.edition or unit.faction.is_empty(): return "Invalid unit identity."
		ids[unit.id] = true
		if not unit.get("options") is Array or unit.options.is_empty() or unit.options.size() > 200: return "Invalid points options."
		for option: Variant in unit.options:
			if not option is Dictionary or not integer(option.get("models"), 0, 1000) or not option.has("cost") or (option.cost != null and not integer(option.cost, 1)): return "Invalid cost/composition in catalog."
	if catalog_digest(catalog.units) != catalog.digest: return "Catalog integrity check failed."
	return ""

static func catalog_digest(units: Array) -> String:
	# JSON parses numeric tokens as floats; normalize integer-valued fields before hashing.
	var canonical := units.duplicate(true)
	for unit: Dictionary in canonical:
		for option: Dictionary in unit.options:
			option.models = int(option.models)
			if option.cost != null: option.cost = int(option.cost)
	return JSON.stringify(canonical).sha256_text()

static func write_json(path: String, data: Dictionary, maximum: int = 16777216) -> String:
	var text := JSON.stringify(data, "\t")
	if text.to_utf8_buffer().size() > maximum: return "The file exceeds the storage limit; the previous version was preserved."
	var error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if error != OK: return "Could not create the profile folder."
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null: return "Could not write the temporary file."
	file.store_string(text)
	file.flush()
	error = file.get_error()
	file.close()
	if error != OK: return "Could not write the file; the previous version was preserved."
	error = DirAccess.rename_absolute(temporary, path)
	return "" if error == OK else "Could not finish writing; the previous file was preserved."
