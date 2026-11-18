extends RefCounted
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
## Local list planning, independent of the implemented match rules.
const MarineEnhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const CanoptekMacrocytes = preload("res://scripts/edition_11/canoptek_macrocytes.gd")
const CanoptekSpyders = preload("res://scripts/edition_11/canoptek_spyders.gd")
const CanoptekTombCrawlers = preload("res://scripts/edition_11/canoptek_tomb_crawlers.gd")
const NecronVehicleLoadouts = preload("res://scripts/edition_11/necron_vehicle_loadouts.gd")
const CurrentMarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const EDITIONS := ["10e", "11e"]
const LIMITS := {"training": 500, "incursion": 1000, "strike_force": 2000, "onslaught": 3000, "custom": 0}
const CHAPTERS := ["Black Templars", "Blood Angels", "Dark Angels", "Deathwatch", "Imperial Fists", "Iron Hands", "Raven Guard", "Salamanders", "Space Wolves", "Ultramarines", "White Scars"]
const INTERCESSOR_RIFLE_CHOICES := {
	"bolt-rifle": "Bolt Rifle",
	"chainsword": "Chainsword",
	"hand-flamer": "Hand Flamer",
	"plasma-pistol": "Plasma Pistol",
	"power-weapon": "Power Weapon"
}
const INTERCESSOR_MELEE_CHOICES := {
	"knives-and-fists": "Knives and Fists",
	"chainsword": "Chainsword",
	"power-fist": "Power Fist",
	"power-weapon": "Power Weapon",
	"thunder-hammer": "Thunder Hammer"
}
const ASSAULT_INTERCESSOR_SERGEANT_PISTOLS := ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]
const ASSAULT_INTERCESSOR_SERGEANT_MELEE := ["chainsword", "power-fist", "power-weapon", "thunder-hammer"]
const INVADER_ATV_MULTI_MELTA_COST := 5
const SCOUT_TROOPER_GUN_CHOICES := ["boltgun", "shotgun", "sniper-rifle", "heavy-bolter", "missile-launcher"]
const ELIMINATOR_SERGEANT_WEAPONS := {
	"sniper": "Bolt Sniper Rifle",
	"las": "Las Fusil",
	"carbine": "Instigator Bolt Carbine"
}
const NECRON_WARRIOR_WEAPONS := {"gauss-flayer": "Gauss flayer", "gauss-reaper": "Gauss reaper"}
const IMMORTAL_WEAPONS := {"gauss-blaster": "Gauss blaster", "tesla-carbine": "Tesla carbine"}

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
		"points_limit": limit, "allow_allies": false, "entries": [], "notes": "", "catalog_digest": "",
		"warlord_model_id": "", "leader_assignments": []}

static func entry(unit: Dictionary, option: int, copies: int = 1, composition_choice: Dictionary = {}) -> Dictionary:
	var result := {"unit_id": unit.id, "name": unit.name, "edition": unit.edition, "faction": unit.faction, "role": unit.role,
		"models": unit.options[option].models, "cost": unit.options[option].cost, "copies": copies, "source_digest": unit.source_digest}
	result.copy_instance_ids = []
	normalize_copy_instance_ids(result)
	normalize_model_equipment(result, true)
	if str(unit.get("id", "")).ends_with(":reiver-squad") or SavedEquipment.supports_unit(str(unit.get("id", ""))): normalize_unit_equipment(result)
	if not str(unit.get("source_scope", "")).is_empty(): result.source_scope = str(unit.source_scope)
	if unit.options[option].has("second_plus_cost"): result.second_plus_cost = unit.options[option].second_plus_cost
	if unit.options[option].has("third_plus_cost"): result.third_plus_cost = unit.options[option].third_plus_cost
	if unit.options[option].has("fourth_plus_cost"): result.fourth_plus_cost = unit.options[option].fourth_plus_cost
	if unit.options[option].has("enhancement_id"): result.enhancement_id = str(unit.options[option].enhancement_id)
	if not composition_choice.is_empty():
		result.composition_choice_id = str(composition_choice.get("id", ""))
		result.wargear_cost = int(composition_choice.get("wargear_cost", 0))
	return result

static func tiered_cost(cost: Variant, third_plus_cost: Variant, copies: int, already_counted: int = 0, fourth_plus_cost: Variant = null, second_plus_cost: Variant = null) -> Variant:
	if cost == null: return null
	var second_cost := int(second_plus_cost) if integer(second_plus_cost, 1) else int(cost)
	var third_cost := int(third_plus_cost) if integer(third_plus_cost, 1) else int(cost)
	if not integer(third_plus_cost, 1): third_cost = second_cost
	var fourth_cost := int(fourth_plus_cost) if integer(fourth_plus_cost, 1) else third_cost
	var total := 0
	for offset in range(copies):
		var copy_number := already_counted + offset + 1
		if copy_number == 1: total += int(cost)
		elif copy_number == 2: total += second_cost
		elif copy_number == 3: total += third_cost
		else: total += fourth_cost
	return total

static func addition_cost(list: Dictionary, unit_id: String, option: Dictionary, copies: int, wargear_cost_per_unit: int = 0) -> Variant:
	var already_counted := 0
	for item: Dictionary in list.get("entries", []):
		if item.get("unit_id", "") == unit_id: already_counted += int(item.get("copies", 0))
	var base: Variant = tiered_cost(option.get("cost"), option.get("third_plus_cost"), copies, already_counted, option.get("fourth_plus_cost"), option.get("second_plus_cost"))
	return null if base == null else int(base) + (wargear_cost_per_unit + default_equipment_points(unit_id, int(option.get("models", 0)))) * copies

static func default_equipment_points(definition: String, models: int) -> int:
	if not SavedEquipment.supports(definition): return 0
	var loadout: Variant = SavedEquipment.defaults(definition)
	if SavedEquipment.is_model_scoped(definition):
		var per_model: Array[Dictionary] = []
		for index in range(models): per_model.append(SavedEquipment.defaults_for_model(definition, models, index))
		loadout = per_model
	return SavedEquipment.points_for_loadout(definition, loadout, models)

static func entry_cost(entries: Array, index: int) -> Variant:
	if index < 0 or index >= entries.size(): return null
	var item: Dictionary = entries[index]
	var already_counted := 0
	for previous in range(index):
		if entries[previous].get("unit_id", "") == item.get("unit_id", ""): already_counted += int(entries[previous].get("copies", 0))
	var result: Variant = tiered_cost(item.get("cost"), item.get("third_plus_cost"), int(item.get("copies", 0)), already_counted, item.get("fourth_plus_cost"), item.get("second_plus_cost"))
	if result != null: result = int(result) + int(item.get("wargear_cost", 0)) * int(item.get("copies", 0))
	if result != null:
		for copy_index in range(int(item.get("copies", 0))): result = int(result) + equipment_points_for_copy(item, copy_index)
	if result != null and item.get("enhancement_id", "") != "": result = int(result) + enhancement_cost(str(item.enhancement_id))
	return result

static func enhancement_cost(enhancement_id: String) -> int:
	return int(MarineEnhancements.RECORDS.get(enhancement_id, {}).get("cost", 0))

static func summary(list: Dictionary) -> Dictionary:
	var points := 0
	var unknown := 0
	var units := 0
	var already_counted: Dictionary = {}
	for item: Dictionary in list.entries:
		var copies := int(item.copies)
		units += copies
		if item.cost == null: unknown += copies
		else: points += int(tiered_cost(item.cost, item.get("third_plus_cost"), copies, int(already_counted.get(item.unit_id, 0)), item.get("fourth_plus_cost"), item.get("second_plus_cost")))
		points += int(item.get("wargear_cost", 0)) * copies
		for copy_index in range(copies): points += equipment_points_for_copy(item, copy_index)
		if item.get("enhancement_id", "") != "": points += enhancement_cost(str(item.enhancement_id))
		already_counted[item.unit_id] = int(already_counted.get(item.unit_id, 0)) + copies
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
	var seen_copy_ids: Dictionary = {}
	var palette: Variant = list.get("visual_palette", {})
	if not palette is Dictionary or palette.size() > 100: return "Invalid local army paint palette."
	for definition: Variant in palette:
		if not definition is String or definition.is_empty() or definition.length() > 160: return "Invalid local paint palette unit."
		var appearances: Variant = palette[definition]
		if not appearances is Array or appearances.is_empty() or appearances.size() > 16: return "Invalid local paint palette choices."
		for appearance: Variant in appearances:
			if not appearance is String or appearance.is_empty() or appearance.length() > 128: return "Invalid local paint palette choice."
	for item: Variant in list.entries:
		if not item is Dictionary: return "Invalid entry."
		for key in ["unit_id", "name", "edition", "faction", "role", "source_digest"]:
			if not item.get(key) is String: return "Invalid unit entry field: " + key
		if item.unit_id.is_empty() or item.edition != list.edition: return "Cannot mix editions."
		if item.has("source_scope") and (not item.source_scope is String or item.source_scope.length() > 64): return "Invalid unit source scope."
		if not faction_allowed(list.faction, item.faction, list.allow_allies): return "Allow allies to include another faction."
		if not integer(item.get("models"), 0, 1000) or not integer(item.get("copies"), 1, 20): return "Invalid unit/model count."
		if item.has("copy_instance_ids"):
			if not item.copy_instance_ids is Array or item.copy_instance_ids.size() != int(item.copies): return "Invalid saved unit-copy identities."
			for instance_id: Variant in item.copy_instance_ids:
				if not instance_id is String or instance_id.is_empty() or instance_id.length() > 128 or seen_copy_ids.has(instance_id): return "Saved unit-copy identities must be unique strings."
				seen_copy_ids[instance_id] = true
		if not item.has("cost") or (item.cost != null and not integer(item.cost, 1)): return "Invalid cost."
		if item.has("third_plus_cost") and not integer(item.third_plus_cost, 1): return "Invalid third-plus unit cost."
		if item.has("fourth_plus_cost") and not integer(item.fourth_plus_cost, 1): return "Invalid fourth-plus unit cost."
		if item.has("composition_choice_id") and (not item.composition_choice_id is String or item.composition_choice_id.is_empty() or item.composition_choice_id.length() > 64): return "Invalid unit composition choice."
		if item.has("intercessor_sergeant_loadouts"):
			if not str(item.get("unit_id", "")).ends_with(":intercessor-squad") or not item.intercessor_sergeant_loadouts is Array or item.intercessor_sergeant_loadouts.size() != int(item.copies): return "Invalid Intercessor Sergeant equipment choices."
			for loadout: Variant in item.intercessor_sergeant_loadouts:
				if not loadout is Dictionary or loadout.size() != 2 or not INTERCESSOR_RIFLE_CHOICES.has(str(loadout.get("rifle_choice", ""))) or not INTERCESSOR_MELEE_CHOICES.has(str(loadout.get("melee_choice", ""))): return "Invalid Intercessor Sergeant equipment choice."
		if item.has("wargear_cost") and not integer(item.wargear_cost, 0, 10000): return "Invalid optional wargear cost."
		if item.has("wargear_cost") != item.has("composition_choice_id"): return "A composition choice and its optional wargear cost must be saved together."
		if item.has("enhancement_id") and (not item.enhancement_id is String or item.enhancement_id.is_empty() or int(item.copies) != 1): return "An enhancement must be assigned to exactly one unit entry."
		if item.has("visual_variants"):
			if not item.visual_variants is Array or item.visual_variants.size() != int(item.models) * int(item.copies): return "Invalid local unit appearance assignments."
			for visual_id: Variant in item.visual_variants:
				if not visual_id is String or visual_id.length() > 128: return "Invalid local unit appearance assignment."
		if item.has("visual_model_overrides"):
			if not item.visual_model_overrides is Array or item.visual_model_overrides.size() != int(item.models) * int(item.copies): return "Invalid local model appearance overrides."
			for visual_id: Variant in item.visual_model_overrides:
				if not visual_id is String or visual_id.length() > 128: return "Invalid local model appearance override."
		if item.has("visual_model_overrides_by_id"):
			if not item.visual_model_overrides_by_id is Dictionary or item.visual_model_overrides_by_id.size() > 20000: return "Invalid stable model appearance overrides."
			var copy_ids: Array = item.get("copy_instance_ids", []) if item.get("copy_instance_ids", []) is Array else []
			for model_id: Variant in item.visual_model_overrides_by_id:
				if not model_id is String or not item.visual_model_overrides_by_id[model_id] is String or str(item.visual_model_overrides_by_id[model_id]).length() > 128: return "Invalid stable model appearance override."
				var belongs_to_entry := false
				for copy_id: Variant in copy_ids:
					if str(model_id).begins_with(str(copy_id) + ":model:"):
						var model_index_text := str(model_id).trim_prefix(str(copy_id) + ":model:")
						belongs_to_entry = model_index_text.is_valid_int() and int(model_index_text) >= 0 and int(model_index_text) < 1000
						break
				if not belongs_to_entry: return "A model appearance override is not linked to a saved unit copy."
		if item.has("model_visual_selection_modes_by_id"):
			if not item.model_visual_selection_modes_by_id is Dictionary or item.model_visual_selection_modes_by_id.size() > 20000: return "Invalid saved model appearance selection modes."
			var model_modes: Dictionary = item.model_visual_selection_modes_by_id
			var mode_copy_ids: Array = item.get("copy_instance_ids", []) if item.get("copy_instance_ids", []) is Array else []
			for model_id: Variant in model_modes:
				if not model_id is String or model_modes[model_id] not in ["auto", "manual"]: return "Invalid saved model appearance selection mode."
				var mode_copy_index := -1
				var mode_model_index := -1
				for candidate_copy_index in range(mode_copy_ids.size()):
					var prefix := str(mode_copy_ids[candidate_copy_index]) + ":model:"
					if not str(model_id).begins_with(prefix): continue
					var model_index_text := str(model_id).trim_prefix(prefix)
					if model_index_text.is_valid_int():
						mode_copy_index = candidate_copy_index
						mode_model_index = int(model_index_text)
					break
				if mode_copy_index < 0 or mode_model_index < 0 or mode_model_index >= int(item.models): return "A model appearance mode is not linked to a saved miniature."
				var has_override := not model_visual_override(item, mode_copy_index, mode_model_index).is_empty()
				if (str(model_modes[model_id]) == "manual") != has_override: return "Saved model appearance mode does not match its override."
		if item.has("model_equipment_by_id"):
			if not item.model_equipment_by_id is Dictionary or item.model_equipment_by_id.size() > 20000: return "Invalid saved model equipment."
			var equipment_copy_ids: Array = item.get("copy_instance_ids", []) if item.get("copy_instance_ids", []) is Array else []
			for model_id: Variant in item.model_equipment_by_id:
				if not model_id is String or not item.model_equipment_by_id[model_id] is Dictionary: return "Invalid saved model equipment record."
				var copy_id := ""
				var model_index := -1
				for candidate_copy_id: Variant in equipment_copy_ids:
					var prefix := str(candidate_copy_id) + ":model:"
					if str(model_id).begins_with(prefix):
						var model_index_text := str(model_id).trim_prefix(prefix)
						if model_index_text.is_valid_int():
							copy_id = str(candidate_copy_id)
							model_index = int(model_index_text)
						break
				if copy_id.is_empty() or not _valid_model_equipment(str(item.unit_id), model_index, item.model_equipment_by_id[model_id], int(item.models)): return "Saved model equipment does not match this profile or model."
		if SavedEquipment.is_model_scoped(str(item.unit_id)):
			for copy_index in range(int(item.copies)):
				if not SavedEquipment.valid_saved_loadout(str(item.unit_id), model_equipment_loadouts(item, copy_index), int(item.models)):
					return "Saved model equipment violates this unit's source-listed limits or model roles."
		if item.has("unit_equipment_by_copy_id"):
			if not item.unit_equipment_by_copy_id is Dictionary or item.unit_equipment_by_copy_id.size() > 20: return "Invalid saved squad equipment."
			var unit_equipment_copy_ids: Array = item.get("copy_instance_ids", []) if item.get("copy_instance_ids", []) is Array else []
			for copy_id: Variant in item.unit_equipment_by_copy_id:
				if not copy_id is String or not unit_equipment_copy_ids.has(str(copy_id)) or not _valid_unit_equipment(str(item.unit_id), item.unit_equipment_by_copy_id[copy_id]): return "Saved squad equipment does not match this profile or unit copy."
		if str(item.get("unit_id", "")).ends_with(":intercessor-squad"):
			for copy_index in range(int(item.copies)):
				var launchers := 0
				for equipped: bool in intercessor_grenade_launcher_loadouts(item, copy_index):
					if equipped: launchers += 1
				if launchers > int(int(item.models) / 5.0): return "An Intercessor unit exceeds its per-five-model Grenade Launcher limit."
		if str(item.get("unit_id", "")).ends_with(":outrider-squad"):
			for copy_index in range(int(item.copies)):
				var plasma_pistols := 0
				for equipped: bool in outrider_plasma_pistol_loadouts(item, copy_index):
					if equipped: plasma_pistols += 1
				if plasma_pistols > int(int(item.models) / 3.0): return "An Outrider unit exceeds its per-three-model Plasma Pistol limit."
	var formation_error := _formation_error(list)
	if not formation_error.is_empty(): return formation_error
	return ""

static func _formation_error(list: Dictionary) -> String:
	var warlord: Variant = list.get("warlord_model_id", "")
	var assignments: Variant = list.get("leader_assignments", [])
	if not warlord is String or str(warlord).length() > 128: return "Invalid saved Warlord model reference."
	if not assignments is Array or assignments.size() > 100: return "Invalid saved Leader assignments."
	var models := {}
	var copies := {}
	for item: Variant in list.get("entries", []):
		if not item is Dictionary: continue
		var copy_ids: Variant = item.get("copy_instance_ids", [])
		if not copy_ids is Array: continue
		for copy_id_value: Variant in copy_ids:
			var copy_id := str(copy_id_value)
			copies[copy_id] = true
			for model_index in range(int(item.get("models", 0))): models["%s:model:%d" % [copy_id, model_index]] = true
	if not str(warlord).is_empty() and not models.has(str(warlord)): return "The saved Warlord no longer belongs to a model in this army."
	var assigned_leaders := {}
	for assignment: Variant in assignments:
		if not assignment is Dictionary or assignment.size() != 2: return "Invalid saved Leader assignment."
		var leader_model_id: Variant = assignment.get("leader_model_id", null)
		var target_copy_id: Variant = assignment.get("target_copy_id", null)
		if not leader_model_id is String or not target_copy_id is String or not models.has(str(leader_model_id)) or not copies.has(str(target_copy_id)): return "A saved Leader assignment no longer belongs to this army."
		var leader_copy_id := str(leader_model_id).get_slice(":model:", 0)
		if leader_copy_id == str(target_copy_id) or assigned_leaders.has(str(leader_model_id)): return "A saved Leader assignment is duplicated or targets its own unit."
		assigned_leaders[str(leader_model_id)] = true
	return ""

static func normalize_formation_assignments(list: Dictionary) -> void:
	if not list.get("entries", []) is Array: return
	var models := {}
	var copies := {}
	for item: Variant in list.entries:
		if not item is Dictionary: continue
		var copy_ids := normalize_copy_instance_ids(item)
		for copy_id in copy_ids:
			copies[copy_id] = true
			for model_index in range(int(item.get("models", 0))): models["%s:model:%d" % [copy_id, model_index]] = true
	var warlord := str(list.get("warlord_model_id", ""))
	if not warlord.is_empty() and not models.has(warlord): list.warlord_model_id = ""
	var retained: Array[Dictionary] = []
	var seen_leaders := {}
	var assignments: Variant = list.get("leader_assignments", [])
	if assignments is Array:
		for assignment: Variant in assignments:
			if not assignment is Dictionary: continue
			var leader_model_id := str(assignment.get("leader_model_id", ""))
			var target_copy_id := str(assignment.get("target_copy_id", ""))
			if not models.has(leader_model_id) or not copies.has(target_copy_id) or leader_model_id.get_slice(":model:", 0) == target_copy_id or seen_leaders.has(leader_model_id): continue
			retained.append({"leader_model_id": leader_model_id, "target_copy_id": target_copy_id})
			seen_leaders[leader_model_id] = true
	list.leader_assignments = retained

static func normalize_copy_instance_ids(item: Dictionary) -> Array[String]:
	return normalize_copy_instance_ids_with_seen(item, {})

static func normalize_copy_instance_ids_with_seen(item: Dictionary, seen: Dictionary) -> Array[String]:
	var wanted := clampi(int(item.get("copies", 0)), 0, 20)
	var current: Variant = item.get("copy_instance_ids", [])
	var ids: Array = current.duplicate(true) if current is Array else []
	while ids.size() > wanted: ids.pop_back()
	while ids.size() < wanted: ids.append("")
	var normalized: Array[String] = []
	for copy_index in range(wanted):
		var instance_id: Variant = ids[copy_index]
		if not instance_id is String or str(instance_id).is_empty() or seen.has(str(instance_id)):
			instance_id = _new_copy_instance_id(seen)
		ids[copy_index] = str(instance_id)
		normalized.append(str(instance_id))
		seen[str(instance_id)] = true
	item.copy_instance_ids = ids
	return normalized

static func _new_copy_instance_id(seen: Dictionary) -> String:
	var instance_id := ""
	while instance_id.is_empty() or seen.has(instance_id):
		instance_id = Crypto.new().generate_random_bytes(16).hex_encode()
	return instance_id

static func model_instance_id(item: Dictionary, copy_index: int, model_index: int) -> String:
	var ids: Variant = item.get("copy_instance_ids", [])
	if not ids is Array or copy_index < 0 or copy_index >= ids.size() or model_index < 0 or model_index >= int(item.get("models", 0)): return ""
	var copy_id: Variant = ids[copy_index]
	return "%s:model:%d" % [str(copy_id), model_index] if copy_id is String and not str(copy_id).is_empty() else ""

static func split_copy(item: Dictionary, copy_index: int) -> Dictionary:
	var copy_count := int(item.get("copies", 0))
	var model_count := int(item.get("models", 0))
	if copy_count < 2 or copy_index < 0 or copy_index >= copy_count: return {"error": "Choose one copy from an entry with at least two copies."}
	var source := item.duplicate(true)
	var copy_ids := normalize_copy_instance_ids(source)
	normalize_visual_variants(source)
	normalize_model_visual_overrides(source)
	normalize_model_visual_selection_modes(source)
	if source.has("intercessor_sergeant_loadouts"): normalize_intercessor_sergeant_loadouts(source)
	var selected: Dictionary = source.duplicate(true)
	var remaining: Dictionary = source.duplicate(true)
	selected.copies = 1
	selected.copy_instance_ids = [copy_ids[copy_index]]
	remaining.copies = copy_count - 1
	remaining.copy_instance_ids = []
	for index in range(copy_ids.size()):
		if index != copy_index: remaining.copy_instance_ids.append(copy_ids[index])
	for key: String in ["visual_variants", "visual_model_overrides"]:
		var slots: Array = source.get(key, [])
		var selected_slots: Array = []
		var remaining_slots: Array = []
		for model_index in range(model_count):
			var selected_slot := copy_index * model_count + model_index
			selected_slots.append(slots[selected_slot] if selected_slot < slots.size() else "")
		for other_copy in range(copy_count):
			if other_copy == copy_index: continue
			for model_index in range(model_count):
				var slot := other_copy * model_count + model_index
				remaining_slots.append(slots[slot] if slot < slots.size() else "")
		if source.has(key):
			selected[key] = selected_slots
			remaining[key] = remaining_slots
	if source.has("visual_model_overrides_by_id"):
		var selected_overrides: Dictionary = {}
		var remaining_overrides: Dictionary = {}
		var overrides: Dictionary = source.visual_model_overrides_by_id
		for old_copy_index in range(copy_ids.size()):
			var copy_id := str(copy_ids[old_copy_index])
			for model_id: Variant in overrides:
				if not str(model_id).begins_with(copy_id + ":model:"): continue
				if old_copy_index == copy_index: selected_overrides[str(model_id)] = overrides[model_id]
				else: remaining_overrides[str(model_id)] = overrides[model_id]
		selected.visual_model_overrides_by_id = selected_overrides
		remaining.visual_model_overrides_by_id = remaining_overrides
	if source.has("model_equipment_by_id"):
		var selected_equipment: Dictionary = {}
		var remaining_equipment: Dictionary = {}
		var equipment_by_model: Dictionary = source.model_equipment_by_id
		for old_copy_index in range(copy_ids.size()):
			var copy_id := str(copy_ids[old_copy_index])
			for model_id: Variant in equipment_by_model:
				if not str(model_id).begins_with(copy_id + ":model:"): continue
				if old_copy_index == copy_index: selected_equipment[str(model_id)] = equipment_by_model[model_id].duplicate(true)
				else: remaining_equipment[str(model_id)] = equipment_by_model[model_id].duplicate(true)
		selected.model_equipment_by_id = selected_equipment
		remaining.model_equipment_by_id = remaining_equipment
	if source.has("unit_equipment_by_copy_id"):
		var selected_unit_equipment: Dictionary = {}
		var remaining_unit_equipment: Dictionary = {}
		var equipment_by_copy: Dictionary = source.unit_equipment_by_copy_id
		for old_copy_index in range(copy_ids.size()):
			var copy_id := str(copy_ids[old_copy_index])
			if not equipment_by_copy.has(copy_id): continue
			if old_copy_index == copy_index: selected_unit_equipment[copy_id] = equipment_by_copy[copy_id].duplicate(true)
			else: remaining_unit_equipment[copy_id] = equipment_by_copy[copy_id].duplicate(true)
		selected.unit_equipment_by_copy_id = selected_unit_equipment
		remaining.unit_equipment_by_copy_id = remaining_unit_equipment
	if source.has("intercessor_sergeant_loadouts"):
		var loadouts: Array = source.intercessor_sergeant_loadouts
		selected.intercessor_sergeant_loadouts = [loadouts[copy_index]]
		remaining.intercessor_sergeant_loadouts = []
		for index in range(loadouts.size()):
			if index != copy_index: remaining.intercessor_sergeant_loadouts.append(loadouts[index])
	normalize_model_visual_overrides(selected)
	normalize_model_visual_selection_modes(selected)
	normalize_model_visual_overrides(remaining)
	normalize_model_visual_selection_modes(remaining)
	return {"error": "", "selected": selected, "remaining": remaining}

static func intercessor_sergeant_loadout(item: Dictionary, copy_index: int) -> Dictionary:
	var defaults := {"rifle_choice": "bolt-rifle", "melee_choice": "knives-and-fists"}
	if copy_index < 0: return defaults
	var loadouts: Variant = item.get("intercessor_sergeant_loadouts", [])
	if not loadouts is Array or copy_index >= loadouts.size() or not loadouts[copy_index] is Dictionary: return defaults
	var loadout: Dictionary = loadouts[copy_index]
	var rifle := str(loadout.get("rifle_choice", defaults.rifle_choice))
	var melee := str(loadout.get("melee_choice", defaults.melee_choice))
	if not INTERCESSOR_RIFLE_CHOICES.has(rifle) or not INTERCESSOR_MELEE_CHOICES.has(melee): return defaults
	return {"rifle_choice": rifle, "melee_choice": melee}

static func valid_intercessor_sergeant_loadout(loadout: Variant) -> bool:
	return loadout is Dictionary and loadout.size() == 2 and INTERCESSOR_RIFLE_CHOICES.has(str(loadout.get("rifle_choice", ""))) and INTERCESSOR_MELEE_CHOICES.has(str(loadout.get("melee_choice", "")))

static func set_intercessor_sergeant_loadout(item: Dictionary, copy_index: int, rifle_choice: String, melee_choice: String) -> void:
	if not str(item.get("unit_id", "")).ends_with(":intercessor-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)):
		return
	if not INTERCESSOR_RIFLE_CHOICES.has(rifle_choice) or not INTERCESSOR_MELEE_CHOICES.has(melee_choice):
		return
	var loadouts := normalize_intercessor_sergeant_loadouts(item)
	loadouts[copy_index] = {"rifle_choice": rifle_choice, "melee_choice": melee_choice}
	item.intercessor_sergeant_loadouts = loadouts

static func normalize_intercessor_sergeant_loadouts(item: Dictionary) -> Array:
	var copies := clampi(int(item.get("copies", 0)), 0, 20)
	var current: Variant = item.get("intercessor_sergeant_loadouts", [])
	var loadouts: Array = current.duplicate(true) if current is Array else []
	while loadouts.size() > copies: loadouts.pop_back()
	while loadouts.size() < copies: loadouts.append({"rifle_choice": "bolt-rifle", "melee_choice": "knives-and-fists"})
	for copy_index in range(loadouts.size()):
		if not loadouts[copy_index] is Dictionary:
			loadouts[copy_index] = {"rifle_choice": "bolt-rifle", "melee_choice": "knives-and-fists"}
		else:
			var loadout: Dictionary = loadouts[copy_index]
			var rifle := str(loadout.get("rifle_choice", "bolt-rifle"))
			var melee := str(loadout.get("melee_choice", "knives-and-fists"))
			loadouts[copy_index] = {"rifle_choice": rifle if INTERCESSOR_RIFLE_CHOICES.has(rifle) else "bolt-rifle", "melee_choice": melee if INTERCESSOR_MELEE_CHOICES.has(melee) else "knives-and-fists"}
	item.intercessor_sergeant_loadouts = loadouts
	return loadouts

static func palette_variant(list: Dictionary, definition: String, slot: int) -> String:
	var palette: Dictionary = list.get("visual_palette", {})
	var choices: Array = palette.get(definition, [])
	return str(choices[posmod(slot, choices.size())]) if not choices.is_empty() else ""

## A local-only appearance snapshot for a saved match. Rule selections and prices
## are deliberately excluded; stable model IDs keep manual sculpts attached to
## the same miniature if the source army is edited after the match is saved.
static func visual_snapshot(list: Dictionary) -> Dictionary:
	var faction := str(list.get("faction", ""))
	var source_entries: Variant = list.get("entries", [])
	if faction.is_empty() or not source_entries is Array: return {}
	var entries: Array[Dictionary] = []
	for source: Variant in source_entries:
		if not source is Dictionary: return {}
		var entry: Dictionary = source.duplicate(true)
		normalize_copy_instance_ids(entry)
		normalize_visual_variants(entry)
		normalize_model_visual_overrides(entry)
		normalize_model_visual_selection_modes(entry)
		var appearance := {
			"unit_id": str(entry.get("unit_id", "")),
			"models": int(entry.get("models", 0)),
			"copies": int(entry.get("copies", 0)),
			"copy_instance_ids": entry.get("copy_instance_ids", []).duplicate(true),
			"visual_variants": entry.get("visual_variants", []).duplicate(true),
			"visual_model_overrides_by_id": entry.get("visual_model_overrides_by_id", {}).duplicate(true),
			"model_visual_selection_modes_by_id": entry.get("model_visual_selection_modes_by_id", {}).duplicate(true),
		}
		if entry.has("match_unit_indices") or entry.has("match_appearance_indices"):
			if not entry.has("match_unit_indices") or not entry.has("match_appearance_indices"): return {}
			appearance.match_unit_indices = entry.match_unit_indices.duplicate(true) if entry.match_unit_indices is Array else entry.match_unit_indices
			appearance.match_appearance_indices = entry.match_appearance_indices.duplicate(true) if entry.match_appearance_indices is Array else entry.match_appearance_indices
		entries.append(appearance)
	var snapshot := {"schema_version": 3, "faction": faction, "entries": entries}
	var palette: Variant = list.get("visual_palette", {})
	if list.has("visual_palette") and not palette is Dictionary: return {}
	if palette is Dictionary and not palette.is_empty(): snapshot.visual_palette = palette.duplicate(true)
	return snapshot if valid_visual_snapshot(snapshot) else {}

static func valid_visual_snapshot(value: Variant) -> bool:
	if not value is Dictionary or value.get("schema_version") not in [1, 2, 3] or not value.get("faction") is String or str(value.faction).is_empty(): return false
	if not value.get("entries") is Array or value.entries.size() > 100: return false
	var seen_copy_ids: Dictionary = {}
	var seen_match_unit_indices: Dictionary = {}
	var explicit_selection_modes := int(value.schema_version) >= 3
	var snapshot_binding_state := -1
	for entry: Variant in value.entries:
		if not entry is Dictionary: return false
		var has_any_match_binding: bool = entry.has("match_unit_indices") or entry.has("match_appearance_indices")
		var entry_bound_snapshot: bool = int(value.schema_version) == 2 or (explicit_selection_modes and has_any_match_binding)
		if (int(value.schema_version) == 2 and not has_any_match_binding) or (has_any_match_binding and (not entry.has("match_unit_indices") or not entry.has("match_appearance_indices"))): return false
		if snapshot_binding_state < 0: snapshot_binding_state = 1 if entry_bound_snapshot else 0
		elif snapshot_binding_state != (1 if entry_bound_snapshot else 0): return false
		var expected_entry_size := 9 if explicit_selection_modes and entry_bound_snapshot else (7 if explicit_selection_modes else (8 if entry_bound_snapshot else 6))
		if entry.size() != expected_entry_size: return false
		if not entry.get("unit_id") is String or str(entry.unit_id).is_empty() or not integer(entry.get("models"), 1, 1000) or not integer(entry.get("copies"), 1, 20): return false
		if not entry.get("copy_instance_ids") is Array or entry.copy_instance_ids.size() != int(entry.copies): return false
		for copy_id: Variant in entry.copy_instance_ids:
			if not copy_id is String or str(copy_id).is_empty() or str(copy_id).length() > 128 or seen_copy_ids.has(str(copy_id)): return false
			seen_copy_ids[str(copy_id)] = true
		var slots := int(entry.models) * int(entry.copies)
		if not entry.get("visual_variants") is Array or entry.visual_variants.size() != slots: return false
		for visual_id: Variant in entry.visual_variants:
			if not visual_id is String or str(visual_id).length() > 128: return false
		if not entry.get("visual_model_overrides_by_id") is Dictionary or entry.visual_model_overrides_by_id.size() > slots: return false
		for model_id: Variant in entry.visual_model_overrides_by_id:
			if not model_id is String or not entry.visual_model_overrides_by_id[model_id] is String or str(entry.visual_model_overrides_by_id[model_id]).length() > 128: return false
			var belongs_to_entry := false
			for copy_id: Variant in entry.copy_instance_ids:
				var prefix := str(copy_id) + ":model:"
				if not str(model_id).begins_with(prefix): continue
				var model_index_text := str(model_id).trim_prefix(prefix)
				belongs_to_entry = model_index_text.is_valid_int() and int(model_index_text) >= 0 and int(model_index_text) < int(entry.models)
				break
			if not belongs_to_entry: return false
		if explicit_selection_modes:
			if not entry.get("model_visual_selection_modes_by_id") is Dictionary or entry.model_visual_selection_modes_by_id.size() != slots: return false
			for copy_id: Variant in entry.copy_instance_ids:
				for model_index in range(int(entry.models)):
					var model_id := "%s:model:%d" % [str(copy_id), model_index]
					if not entry.model_visual_selection_modes_by_id.has(model_id): return false
					var mode: Variant = entry.model_visual_selection_modes_by_id[model_id]
					if mode not in ["auto", "manual"]: return false
					var has_override := not str(entry.visual_model_overrides_by_id.get(model_id, "")).is_empty()
					if (str(mode) == "manual") != has_override: return false
		if entry_bound_snapshot:
			for field: String in ["match_unit_indices", "match_appearance_indices"]:
				if not entry.get(field) is Array or entry[field].size() != int(entry.copies): return false
			for raw_unit_index: Variant in entry.match_unit_indices:
				if not integer(raw_unit_index, 0, 9999) or seen_match_unit_indices.has(int(raw_unit_index)): return false
				seen_match_unit_indices[int(raw_unit_index)] = true
			for raw_appearance_index: Variant in entry.match_appearance_indices:
				if not integer(raw_appearance_index, 0, 9999): return false
	if value.has("visual_palette"):
		var palette: Variant = value.visual_palette
		if not palette is Dictionary or palette.size() > 100: return false
		for definition: Variant in palette:
			if not definition is String or str(definition).is_empty() or str(definition).length() > 160: return false
			var appearances: Variant = palette[definition]
			if not appearances is Array or appearances.is_empty() or appearances.size() > 16: return false
			for appearance: Variant in appearances:
				if not appearance is String or str(appearance).is_empty() or str(appearance).length() > 128: return false
	return true

static func restore_visual_snapshot(snapshot: Dictionary) -> Dictionary:
	if not valid_visual_snapshot(snapshot): return {}
	var restored := {"faction": str(snapshot.faction), "entries": snapshot.entries.duplicate(true)}
	if snapshot.has("visual_palette"): restored.visual_palette = snapshot.visual_palette.duplicate(true)
	return restored

static func unit_visual_variant(item: Dictionary, copy_index: int) -> String:
	var models := int(item.get("models", 0))
	var slots: Variant = item.get("visual_variants", [])
	if models <= 0 or copy_index < 0 or not slots is Array: return ""
	var start := copy_index * models
	for model_index in range(models):
		var slot := start + model_index
		if slot >= slots.size(): break
		if slots[slot] is String and not str(slots[slot]).is_empty(): return str(slots[slot])
	return ""

static func set_unit_visual_variant(item: Dictionary, copy_index: int, visual_id: String) -> void:
	normalize_visual_variants(item)
	var models := int(item.get("models", 0))
	if models <= 0 or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return
	var start := copy_index * models
	for model_index in range(models): item.visual_variants[start + model_index] = visual_id

static func model_visual_override(item: Dictionary, copy_index: int, model_index: int) -> String:
	var models := int(item.get("models", 0))
	if models <= 0 or copy_index < 0 or model_index < 0 or model_index >= models: return ""
	var stable_id := model_instance_id(item, copy_index, model_index)
	var keyed: Variant = item.get("visual_model_overrides_by_id", {})
	if not stable_id.is_empty() and keyed is Dictionary and keyed.has(stable_id): return str(keyed[stable_id])
	var slots: Variant = item.get("visual_model_overrides", [])
	if not slots is Array: return ""
	var slot := copy_index * models + model_index
	return str(slots[slot]) if slot < slots.size() and slots[slot] is String else ""

static func model_visual_override_by_id(item: Dictionary, model_id: String) -> String:
	if model_id.is_empty(): return ""
	var keyed: Variant = item.get("visual_model_overrides_by_id", {})
	if keyed is Dictionary and keyed.has(model_id) and keyed[model_id] is String: return str(keyed[model_id])
	var ids: Variant = item.get("copy_instance_ids", [])
	if not ids is Array: return ""
	for copy_index in range(ids.size()):
		for model_index in range(int(item.get("models", 0))):
			if model_instance_id(item, copy_index, model_index) == model_id: return model_visual_override(item, copy_index, model_index)
	return ""

static func model_visual_selection_mode(item: Dictionary, copy_index: int, model_index: int) -> String:
	var model_id := model_instance_id(item, copy_index, model_index)
	if model_id.is_empty(): return "auto"
	var modes: Variant = item.get("model_visual_selection_modes_by_id", {})
	if modes is Dictionary and modes.get(model_id, "") in ["auto", "manual"]: return str(modes[model_id])
	return "manual" if not model_visual_override(item, copy_index, model_index).is_empty() else "auto"

static func normalize_model_visual_selection_modes(item: Dictionary) -> Dictionary:
	normalize_model_visual_overrides(item)
	var modes: Dictionary = item.get("model_visual_selection_modes_by_id", {}) if item.get("model_visual_selection_modes_by_id", {}) is Dictionary else {}
	var copy_ids := normalize_copy_instance_ids(item)
	var retained: Dictionary = {}
	for copy_index in range(copy_ids.size()):
		for model_index in range(int(item.get("models", 0))):
			var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
			var override_id := model_visual_override(item, copy_index, model_index)
			# A saved override is explicit even when its local asset is unavailable.
			retained[model_id] = "manual" if not override_id.is_empty() else "auto"
	item.model_visual_selection_modes_by_id = retained
	return retained

static func set_model_visual_override(item: Dictionary, copy_index: int, model_index: int, visual_id: String) -> void:
	normalize_model_visual_overrides(item)
	var models := int(item.get("models", 0))
	if models <= 0 or copy_index < 0 or copy_index >= int(item.get("copies", 0)) or model_index < 0 or model_index >= models: return
	var stable_id := model_instance_id(item, copy_index, model_index)
	if stable_id.is_empty(): return
	if not item.visual_model_overrides_by_id is Dictionary: item.visual_model_overrides_by_id = {}
	if visual_id.is_empty(): item.visual_model_overrides_by_id.erase(stable_id)
	else: item.visual_model_overrides_by_id[stable_id] = visual_id
	item.visual_model_overrides[copy_index * models + model_index] = visual_id
	var selection_modes: Variant = item.get("model_visual_selection_modes_by_id", {})
	if not selection_modes is Dictionary: selection_modes = {}
	selection_modes[stable_id] = "manual" if not visual_id.is_empty() else "auto"
	item.model_visual_selection_modes_by_id = selection_modes

static func model_equipment(item: Dictionary, copy_index: int, model_index: int) -> Dictionary:
	var models := int(item.get("models", 0))
	if copy_index < 0 or copy_index >= int(item.get("copies", 0)) or model_index < 0 or model_index >= models: return {}
	var stable_id := model_instance_id(item, copy_index, model_index)
	var by_model: Variant = item.get("model_equipment_by_id", {})
	if not stable_id.is_empty() and by_model is Dictionary and by_model.has(stable_id) and by_model[stable_id] is Dictionary:
		return by_model.get(stable_id, {}).duplicate(true)
	var saved_definition := str(item.get("unit_id", item.get("definition_id", "")))
	if SavedEquipment.supports(saved_definition):
		return SavedEquipment.defaults_for_model(saved_definition, models, model_index) if SavedEquipment.is_model_scoped(saved_definition) else SavedEquipment.defaults(saved_definition)
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":eliminator-squad") and model_index >= 0 and model_index < int(item.get("models", 0)):
		return {"eliminator_sergeant_ranged" if model_index == 0 else "eliminator_trooper_ranged": "sniper"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":necron-warriors"):
		return {"necron_ranged_weapon": "gauss-flayer"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":immortals"):
		return {"necron_ranged_weapon": "gauss-blaster"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":canoptek-macrocytes"):
		return {"canoptek_macrocytes_loadout": CanoptekMacrocytes.GAUSS_SCALPEL}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":canoptek-spyders"):
		return _default_canoptek_spyder_equipment()
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":intercessor-squad") and model_index > 0:
		return {"intercessor_grenade_launcher": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":outrider-squad"):
		return {"outrider_sergeant_melee": "chainsword", "outrider_plasma_pistol": false} if model_index == 0 else {"outrider_plasma_pistol": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":ravenwing-darkshroud"):
		return {"ravenwing_darkshroud_cannon": "heavy-bolter"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":land-speeder"):
		return {"land_speeder_cannon": "onslaught"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":land-speeder-vengeance"):
		return {"land_speeder_vengeance_cannon": "heavy-bolter"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":baal-predator"):
		return {"baal_predator_primary_cannon": "twin-assault-cannon", "baal_predator_sponson_package": "none", "baal_predator_storm_bolter": false, "baal_predator_hunter_killer_missile": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":predator-destructor"):
		return {"predator_destructor_heavy_bolters": false, "predator_destructor_hunter_killer_missile": false, "predator_destructor_storm_bolter": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":predator-annihilator"):
		return {"predator_annihilator_heavy_bolters": false, "predator_annihilator_hunter_killer_missile": false, "predator_annihilator_storm_bolter": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":invader-atvs"):
		return {"invader_atv_multi_melta": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":hellblaster-squad") and model_index == 0:
		return {"hellblaster_sergeant_pistol": "bolt-pistol"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":assault-intercessor-squad") and model_index == 0:
		return {"assault_intercessor_sergeant_pistol": "heavy-bolt-pistol", "assault_intercessor_sergeant_melee": "chainsword"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":heavy-intercessor-squad") and model_index > 0:
		return {"heavy_intercessor_bolter": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":aggressor-squad"):
		return {"aggressor_boltstorm": false}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":inceptor-squad"):
		return {"inceptor_weapon": "assault-bolters"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":scout-squad"):
		return {"scout_gun": "boltgun", "scout_sergeant_blade": "combat-knife"} if model_index == 0 else {"scout_gun": "boltgun"}
	if str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":canoptek-tomb-crawlers"):
		return {"canoptek_tomb_crawlers_loadout": CanoptekTombCrawlers.GAUSS_REAPER}
	var unit_id := str(item.get("unit_id", item.get("definition_id", "")))
	if unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE):
		return {"necron_annihilation_barge_loadout": NecronVehicleLoadouts.BARGE_GAUSS}
	if unit_id.ends_with(":" + NecronVehicleLoadouts.MONOLITH):
		return {"necron_monolith_loadout": NecronVehicleLoadouts.MONOLITH_ARCS}
	return {}

static func model_equipment_loadouts(item: Dictionary, copy_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model_index in range(int(item.get("models", 0))):
		result.append(model_equipment(item, copy_index, model_index))
	return result

## A visual role may share an appearance only when the saved equipment schema
## identifies both role and loadout for this model.
static func model_equipment_role(item: Dictionary, copy_index: int, model_index: int) -> String:
	var equipment := model_equipment(item, copy_index, model_index)
	if equipment.has("eliminator_sergeant_ranged"): return "sergeant"
	if equipment.has("eliminator_trooper_ranged"): return "eliminator"
	var definition := str(item.get("unit_id", item.get("definition_id", "")))
	if SavedEquipment.supports(definition):
		var role := SavedEquipment.visual_model_role(definition, int(item.get("models", 0)), model_index)
		return definition + ("|role=" + role if not role.is_empty() else "") + "|" + JSON.stringify(equipment)
	if equipment.has("intercessor_grenade_launcher") and definition.ends_with(":intercessor-squad"):
		return "intercessor-grenadier" if bool(equipment.intercessor_grenade_launcher) else "intercessor-trooper"
	if equipment.has("outrider_plasma_pistol") and definition.ends_with(":outrider-squad"):
		if model_index == 0:
			return "outrider-sergeant|%s|plasma=%s" % [str(equipment.get("outrider_sergeant_melee", "chainsword")), str(bool(equipment.get("outrider_plasma_pistol", false)))]
		return "outrider-trooper|plasma=%s" % str(bool(equipment.get("outrider_plasma_pistol", false)))
	if equipment.has("ravenwing_darkshroud_cannon") and definition.ends_with(":ravenwing-darkshroud"):
		return "ravenwing-darkshroud|%s" % str(equipment.get("ravenwing_darkshroud_cannon", "heavy-bolter"))
	if equipment.has("land_speeder_cannon") and definition.ends_with(":land-speeder"):
		return "land-speeder|%s" % str(equipment.get("land_speeder_cannon", "onslaught"))
	if equipment.has("land_speeder_vengeance_cannon") and definition.ends_with(":land-speeder-vengeance"):
		return "land-speeder-vengeance|%s" % str(equipment.get("land_speeder_vengeance_cannon", "heavy-bolter"))
	if equipment.has("baal_predator_primary_cannon") and definition.ends_with(":baal-predator"):
		return "baal-predator|%s|%s|storm=%s|missile=%s" % [str(equipment.get("baal_predator_primary_cannon", "twin-assault-cannon")), str(equipment.get("baal_predator_sponson_package", "none")), str(bool(equipment.get("baal_predator_storm_bolter", false))), str(bool(equipment.get("baal_predator_hunter_killer_missile", false)))]
	if equipment.has("predator_destructor_heavy_bolters") and definition.ends_with(":predator-destructor"):
		return "predator-destructor|heavy-bolters=%s|storm=%s|missile=%s" % [str(bool(equipment.get("predator_destructor_heavy_bolters", false))), str(bool(equipment.get("predator_destructor_storm_bolter", false))), str(bool(equipment.get("predator_destructor_hunter_killer_missile", false)))]
	if equipment.has("predator_annihilator_heavy_bolters") and definition.ends_with(":predator-annihilator"):
		return "predator-annihilator|heavy-bolters=%s|storm=%s|missile=%s" % [str(bool(equipment.get("predator_annihilator_heavy_bolters", false))), str(bool(equipment.get("predator_annihilator_storm_bolter", false))), str(bool(equipment.get("predator_annihilator_hunter_killer_missile", false)))]
	if equipment.has("invader_atv_multi_melta") and definition.ends_with(":invader-atvs"):
		return "invader-atv|%s" % ("multi-melta" if bool(equipment.invader_atv_multi_melta) else "onslaught-gatling-cannon")
	if equipment.has("hellblaster_sergeant_pistol") and definition.ends_with(":hellblaster-squad"):
		return "hellblaster-sergeant|%s" % str(equipment.get("hellblaster_sergeant_pistol", "bolt-pistol"))
	if definition.ends_with(":assault-intercessor-squad") and equipment.has("assault_intercessor_sergeant_pistol"):
		return "assault-intercessor-sergeant|%s|%s" % [str(equipment.get("assault_intercessor_sergeant_pistol", "heavy-bolt-pistol")), str(equipment.get("assault_intercessor_sergeant_melee", "chainsword"))]
	if equipment.has("heavy_intercessor_bolter") and definition.ends_with(":heavy-intercessor-squad"):
		return "heavy-intercessor|%s" % ("heavy-bolter" if bool(equipment.heavy_intercessor_bolter) else "heavy-bolt-rifle")
	if equipment.has("inceptor_weapon") and definition.ends_with(":inceptor-squad"):
		return "inceptor|%s" % str(equipment.get("inceptor_weapon", "assault-bolters"))
	if equipment.has("aggressor_boltstorm") and definition.ends_with(":aggressor-squad"):
		var role := "aggressor-sergeant" if model_index == 0 else "aggressor"
		return "%s|%s" % [role, "boltstorm-fragstorm" if bool(equipment.aggressor_boltstorm) else "flamestorm"]
	if equipment.has("scout_gun") and definition.ends_with(":scout-squad"):
		return "scout-sergeant|%s|%s" % [str(equipment.scout_gun), str(equipment.get("scout_sergeant_blade", "combat-knife"))] if model_index == 0 else "scout-trooper|%s" % str(equipment.scout_gun)
	if equipment.has("necron_ranged_weapon"):
		if definition.ends_with(":necron-warriors"): return "necron-warrior"
		if definition.ends_with(":immortals"): return "immortal"
	if equipment.has("canoptek_macrocytes_loadout") and definition.ends_with(":canoptek-macrocytes"):
		return "canoptek-macrocyte"
	if definition.ends_with(":canoptek-spyders") and not equipment.is_empty():
		return "canoptek-spyder"
	if equipment.has("canoptek_tomb_crawlers_loadout") and definition.ends_with(":canoptek-tomb-crawlers"):
		return "canoptek-tomb-crawler"
	if equipment.has("necron_annihilation_barge_loadout") and definition.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE):
		return NecronVehicleLoadouts.ANNIHILATION_BARGE
	if equipment.has("necron_monolith_loadout") and definition.ends_with(":" + NecronVehicleLoadouts.MONOLITH):
		return NecronVehicleLoadouts.MONOLITH
	return ""

static func eliminator_sergeant_loadouts(item: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":eliminator-squad"): return result
	for copy_index in range(int(item.get("copies", 0))):
		result.append(str(model_equipment(item, copy_index, 0).get("eliminator_sergeant_ranged", "sniper")))
	return result

static func eliminator_trooper_loadouts(item: Dictionary) -> Array[Array]:
	var result: Array[Array] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":eliminator-squad"): return result
	for copy_index in range(int(item.get("copies", 0))):
		var copy_loadouts: Array[String] = []
		for model_index in range(1, int(item.get("models", 0))):
			copy_loadouts.append(str(model_equipment(item, copy_index, model_index).get("eliminator_trooper_ranged", "sniper")))
		result.append(copy_loadouts)
	return result

static func necron_warrior_loadouts(item: Dictionary, copy_index: int) -> Array[String]:
	var result: Array[String] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":necron-warriors") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(str(model_equipment(item, copy_index, model_index).get("necron_ranged_weapon", "gauss-flayer")))
	return result

static func immortal_loadouts(item: Dictionary, copy_index: int) -> Array[String]:
	var result: Array[String] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":immortals") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(str(model_equipment(item, copy_index, model_index).get("necron_ranged_weapon", "gauss-blaster")))
	return result

static func canoptek_macrocytes_loadouts(item: Dictionary, copy_index: int) -> Array[String]:
	var result: Array[String] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":canoptek-macrocytes") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(str(model_equipment(item, copy_index, model_index).get("canoptek_macrocytes_loadout", CanoptekMacrocytes.GAUSS_SCALPEL)))
	return result

static func canoptek_spyders_loadouts(item: Dictionary, copy_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":canoptek-spyders") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(model_equipment(item, copy_index, model_index))
	return result

static func canoptek_tomb_crawlers_loadouts(item: Dictionary, copy_index: int) -> Array[String]:
	var result: Array[String] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":canoptek-tomb-crawlers") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(str(model_equipment(item, copy_index, model_index).get("canoptek_tomb_crawlers_loadout", CanoptekTombCrawlers.GAUSS_REAPER)))
	return result

static func necron_vehicle_loadouts(item: Dictionary, copy_index: int) -> Array[String]:
	var result: Array[String] = []
	if copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	var unit_id := str(item.get("unit_id", item.get("definition_id", "")))
	if not unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) and not unit_id.ends_with(":" + NecronVehicleLoadouts.MONOLITH): return result
	var field := "necron_annihilation_barge_loadout" if unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else "necron_monolith_loadout"
	var default_choice := NecronVehicleLoadouts.default_choice(unit_id)
	for model_index in range(int(item.get("models", 0))):
		result.append(str(model_equipment(item, copy_index, model_index).get(field, default_choice)))
	return result

static func invader_atv_loadouts(item: Dictionary, copy_index: int) -> Array[bool]:
	var result: Array[bool] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":invader-atvs") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(bool(model_equipment(item, copy_index, model_index).get("invader_atv_multi_melta", false)))
	return result

static func equipment_points_for_copy(item: Dictionary, copy_index: int) -> int:
	var definition := str(item.get("unit_id", item.get("definition_id", "")))
	if SavedEquipment.supports(definition):
		var models := int(item.get("models", 0))
		var loadout: Variant = model_equipment_loadouts(item, copy_index) if SavedEquipment.is_model_scoped(definition) else model_equipment(item, copy_index, 0)
		return SavedEquipment.points_for_loadout(definition, loadout, models)
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":invader-atvs"): return 0
	var result := 0
	for equipped: bool in invader_atv_loadouts(item, copy_index):
		if equipped: result += INVADER_ATV_MULTI_MELTA_COST
	return result

static func intercessor_grenade_launcher_loadouts(item: Dictionary, copy_index: int) -> Array[bool]:
	var result: Array[bool] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":intercessor-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(false if model_index == 0 else bool(model_equipment(item, copy_index, model_index).get("intercessor_grenade_launcher", false)))
	return result

static func outrider_plasma_pistol_loadouts(item: Dictionary, copy_index: int) -> Array[bool]:
	var result: Array[bool] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":outrider-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(bool(model_equipment(item, copy_index, model_index).get("outrider_plasma_pistol", false)))
	return result

static func ravenwing_darkshroud_loadout(item: Dictionary, copy_index: int) -> String:
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":ravenwing-darkshroud") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return ""
	return str(model_equipment(item, copy_index, 0).get("ravenwing_darkshroud_cannon", "heavy-bolter"))

static func inceptor_loadouts(item: Dictionary, copy_index: int) -> Array[String]:
	var result: Array[String] = []
	for model_index in range(int(item.get("models", 0))):
		result.append(str(model_equipment(item, copy_index, model_index).get("inceptor_weapon", "assault-bolters")))
	return result

static func hellblaster_sergeant_pistol_loadouts(item: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":hellblaster-squad"): return result
	for copy_index in range(int(item.get("copies", 0))):
		result.append(str(model_equipment(item, copy_index, 0).get("hellblaster_sergeant_pistol", "bolt-pistol")))
	return result

static func assault_intercessor_sergeant_loadouts(item: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":assault-intercessor-squad"): return result
	for copy_index in range(int(item.get("copies", 0))):
		var equipment := model_equipment(item, copy_index, 0)
		result.append({"pistol_choice": str(equipment.get("assault_intercessor_sergeant_pistol", "heavy-bolt-pistol")), "melee_choice": str(equipment.get("assault_intercessor_sergeant_melee", "chainsword"))})
	return result

static func valid_assault_intercessor_sergeant_loadout(loadout: Variant) -> bool:
	return loadout is Dictionary and loadout.size() == 2 and str(loadout.get("pistol_choice", "")) in ASSAULT_INTERCESSOR_SERGEANT_PISTOLS and str(loadout.get("melee_choice", "")) in ASSAULT_INTERCESSOR_SERGEANT_MELEE

static func heavy_intercessor_bolter_loadouts(item: Dictionary, copy_index: int) -> Array[bool]:
	var result: Array[bool] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":heavy-intercessor-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(false if model_index == 0 else bool(model_equipment(item, copy_index, model_index).get("heavy_intercessor_bolter", false)))
	return result

static func valid_heavy_intercessor_bolter_loadout(choices: Variant, model_count: int) -> bool:
	if not choices is Array or choices.size() != model_count or model_count < 5: return false
	var equipped_count := 0
	for model_index in range(choices.size()):
		if not choices[model_index] is bool or (model_index == 0 and bool(choices[model_index])): return false
		if bool(choices[model_index]): equipped_count += 1
	return equipped_count <= int(model_count / 5.0)

static func aggressor_model_loadouts(item: Dictionary, copy_index: int) -> Array[bool]:
	var result: Array[bool] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":aggressor-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))):
		result.append(bool(model_equipment(item, copy_index, model_index).get("aggressor_boltstorm", false)))
	return result

static func scout_loadout(item: Dictionary, copy_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":scout-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return result
	for model_index in range(int(item.get("models", 0))): result.append(model_equipment(item, copy_index, model_index))
	return result

static func has_model_equipment(item: Dictionary, copy_index: int, model_index: int) -> bool:
	var stable_id := model_instance_id(item, copy_index, model_index)
	var by_model: Variant = item.get("model_equipment_by_id", {})
	return not stable_id.is_empty() and by_model is Dictionary and by_model.has(stable_id)

static func scout_gun_options(item: Dictionary, copy_index: int, model_index: int) -> Array[String]:
	var result: Array[String] = []
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":scout-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)) or model_index < 0 or model_index >= int(item.get("models", 0)): return result
	if model_index == 0: return ["boltgun", "shotgun"]
	var loadouts := scout_loadout(item, copy_index)
	var sniper_count := 0
	var heavy_count := 0
	for candidate_index in range(1, loadouts.size()):
		if candidate_index == model_index: continue
		var candidate := str(loadouts[candidate_index].get("scout_gun", "boltgun"))
		if candidate == "sniper-rifle": sniper_count += 1
		if candidate in ["heavy-bolter", "missile-launcher"]: heavy_count += 1
	var current := str(loadouts[model_index].get("scout_gun", "boltgun"))
	var quota := int(int(item.get("models", 0)) / 5.0)
	result = ["boltgun", "shotgun"]
	if current == "sniper-rifle" or sniper_count < quota: result.append("sniper-rifle")
	if current in ["heavy-bolter", "missile-launcher"] or heavy_count < quota: result.append_array(["heavy-bolter", "missile-launcher"])
	return result

static func set_scout_gun(item: Dictionary, copy_index: int, model_index: int, gun: String) -> bool:
	if gun not in scout_gun_options(item, copy_index, model_index): return false
	var current := str(model_equipment(item, copy_index, model_index).get("scout_gun", "boltgun"))
	if current == gun: return false
	set_model_equipment(item, copy_index, model_index, "scout_gun", gun)
	return str(model_equipment(item, copy_index, model_index).get("scout_gun", "boltgun")) == gun

static func set_scout_sergeant_blade(item: Dictionary, copy_index: int, blade: String) -> bool:
	if not str(item.get("unit_id", "")).ends_with(":scout-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)) or blade not in ["combat-knife", "chainsword"]: return false
	var current := str(model_equipment(item, copy_index, 0).get("scout_sergeant_blade", "combat-knife"))
	if current == blade: return false
	set_model_equipment(item, copy_index, 0, "scout_sergeant_blade", blade)
	return str(model_equipment(item, copy_index, 0).get("scout_sergeant_blade", "combat-knife")) == blade

static func valid_scout_loadout(unit_id: String, loadouts: Variant, model_count: int) -> bool:
	if not unit_id.ends_with(":scout-squad") or not loadouts is Array or loadouts.size() != model_count or model_count not in [5, 10]: return false
	var sniper_count := 0
	var heavy_count := 0
	for model_index in range(model_count):
		if not _valid_model_equipment(unit_id, model_index, loadouts[model_index], model_count): return false
		if model_index == 0: continue
		var gun := str(loadouts[model_index].get("scout_gun", "boltgun"))
		if gun == "sniper-rifle": sniper_count += 1
		if gun in ["heavy-bolter", "missile-launcher"]: heavy_count += 1
	var quota := int(model_count / 5.0)
	return sniper_count <= quota and heavy_count <= quota

static func outrider_loadout(item: Dictionary, copy_index: int) -> Dictionary:
	if not str(item.get("unit_id", item.get("definition_id", ""))).ends_with(":outrider-squad") or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return {}
	var plasma_choices: Array[bool] = []
	plasma_choices = outrider_plasma_pistol_loadouts(item, copy_index)
	return {"sergeant_melee_choice": str(model_equipment(item, copy_index, 0).get("outrider_sergeant_melee", "chainsword")), "plasma_pistol_choices": plasma_choices}

static func set_outrider_plasma_pistol(item: Dictionary, copy_index: int, model_index: int, equipped: bool) -> bool:
	if not str(item.get("unit_id", "")).ends_with(":outrider-squad") or model_index < 0 or model_index >= int(item.get("models", 0)) or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return false
	var loadout := outrider_loadout(item, copy_index)
	var choices: Array = loadout.get("plasma_pistol_choices", [])
	if model_index >= choices.size() or bool(choices[model_index]) == equipped: return false
	if equipped:
		var equipped_count := 0
		for current: bool in choices:
			if current: equipped_count += 1
		if equipped_count >= int(int(item.get("models", 0)) / 3.0): return false
	set_model_equipment(item, copy_index, model_index, "outrider_plasma_pistol", equipped)
	return bool(model_equipment(item, copy_index, model_index).get("outrider_plasma_pistol", false)) == equipped

static func valid_outrider_loadout(loadout: Variant, model_count: int) -> bool:
	if not loadout is Dictionary or loadout.size() != 2: return false
	if str(loadout.get("sergeant_melee_choice", "")) not in ["chainsword", "power-weapon", "thunder-hammer"]: return false
	var choices: Variant = loadout.get("plasma_pistol_choices", null)
	if not choices is Array or choices.size() != model_count: return false
	var equipped_count := 0
	for equipped: Variant in choices:
		if not equipped is bool: return false
		if equipped: equipped_count += 1
	return equipped_count <= int(model_count / 3.0)

static func set_intercessor_grenade_launcher(item: Dictionary, copy_index: int, model_index: int, equipped: bool) -> bool:
	if not str(item.get("unit_id", "")).ends_with(":intercessor-squad") or model_index <= 0 or model_index >= int(item.get("models", 0)) or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return false
	var loadouts := intercessor_grenade_launcher_loadouts(item, copy_index)
	if model_index >= loadouts.size() or loadouts[model_index] == equipped: return false
	if equipped:
		var equipped_count := 0
		for current: bool in loadouts:
			if current: equipped_count += 1
		if equipped_count >= int(int(item.get("models", 0)) / 5.0): return false
	set_model_equipment(item, copy_index, model_index, "intercessor_grenade_launcher", equipped)
	return bool(model_equipment(item, copy_index, model_index).get("intercessor_grenade_launcher", false)) == equipped

static func set_model_equipment(item: Dictionary, copy_index: int, model_index: int, slot_id: String, choice_id: Variant) -> bool:
	normalize_model_equipment(item, true)
	if copy_index < 0 or copy_index >= int(item.get("copies", 0)) or model_index < 0 or model_index >= int(item.get("models", 0)): return false
	var stable_id := model_instance_id(item, copy_index, model_index)
	if stable_id.is_empty(): return false
	var current: Dictionary = item.model_equipment_by_id.get(stable_id, {}).duplicate(true)
	var candidate := current
	candidate[slot_id] = choice_id
	var definition := str(item.get("unit_id", ""))
	if not _valid_model_equipment(definition, model_index, candidate, int(item.get("models", 0))): return false
	if SavedEquipment.is_model_scoped(definition):
		var loadouts := model_equipment_loadouts(item, copy_index)
		loadouts[model_index] = candidate
		if not SavedEquipment.valid_saved_loadout(definition, loadouts, int(item.get("models", 0))): return false
	if not item.model_equipment_by_id is Dictionary: item.model_equipment_by_id = {}
	item.model_equipment_by_id[stable_id] = candidate
	return true

static func normalize_model_equipment(item: Dictionary, seed_scout_defaults: bool = false) -> Dictionary:
	var copy_ids := normalize_copy_instance_ids(item)
	var by_model: Dictionary = item.get("model_equipment_by_id", {}) if item.get("model_equipment_by_id", {}) is Dictionary else {}
	var unit_id := str(item.get("unit_id", ""))
	var legacy_unit_equipment: Variant = item.get("unit_equipment_by_copy_id", {})
	if unit_id.ends_with(":aggressor-squad") and legacy_unit_equipment is Dictionary:
		var remaining_unit_equipment: Dictionary = legacy_unit_equipment.duplicate(true)
		for copy_index in range(copy_ids.size()):
			var copy_id := str(copy_ids[copy_index])
			var old_loadout: Variant = remaining_unit_equipment.get(copy_id, {})
			if not _valid_unit_equipment(unit_id, old_loadout): continue
			for model_index in range(int(item.get("models", 0))):
				var stable_model_id := "%s:model:%d" % [copy_id, model_index]
				if not by_model.has(stable_model_id): by_model[stable_model_id] = {"aggressor_boltstorm": bool(old_loadout.aggressor_boltstorm)}
			remaining_unit_equipment.erase(copy_id)
		if remaining_unit_equipment.is_empty(): item.erase("unit_equipment_by_copy_id")
		else: item.unit_equipment_by_copy_id = remaining_unit_equipment
	for model_id: Variant in by_model.keys():
		var retained := false
		for copy_index in range(copy_ids.size()):
			var prefix := str(copy_ids[copy_index]) + ":model:"
			if not str(model_id).begins_with(prefix): continue
			var model_index_text := str(model_id).trim_prefix(prefix)
			retained = model_index_text.is_valid_int() and _valid_model_equipment(str(item.get("unit_id", "")), int(model_index_text), by_model[model_id], int(item.get("models", 0)))
			break
		if not retained: by_model.erase(model_id)
	if SavedEquipment.supports(unit_id):
		for copy_id: String in copy_ids:
			var model_limit := int(item.get("models", 0)) if SavedEquipment.is_model_scoped(unit_id) else 1
			for model_index in range(model_limit):
				var model_id := "%s:model:%d" % [copy_id, model_index]
				if not by_model.has(model_id):
					by_model[model_id] = SavedEquipment.defaults_for_model(unit_id, int(item.get("models", 0)), model_index) if SavedEquipment.is_model_scoped(unit_id) else SavedEquipment.defaults(unit_id)
	elif unit_id.ends_with(":eliminator-squad"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"eliminator_sergeant_ranged" if model_index == 0 else "eliminator_trooper_ranged": "sniper"}
	elif unit_id.ends_with(":necron-warriors") or unit_id.ends_with(":immortals"):
		var default_weapon := "gauss-flayer" if unit_id.ends_with(":necron-warriors") else "gauss-blaster"
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"necron_ranged_weapon": default_weapon}
	elif unit_id.ends_with(":canoptek-macrocytes"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"canoptek_macrocytes_loadout": CanoptekMacrocytes.GAUSS_SCALPEL}
	elif unit_id.ends_with(":canoptek-spyders"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				var equipment: Dictionary = by_model.get(model_id, {}).duplicate(true)
				for field: String in CanoptekSpyders.EQUIPMENT_FIELDS:
					if not equipment.has(field): equipment[field] = false
				by_model[model_id] = equipment
	elif unit_id.ends_with(":canoptek-tomb-crawlers"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"canoptek_tomb_crawlers_loadout": CanoptekTombCrawlers.GAUSS_REAPER}
	elif unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) or unit_id.ends_with(":" + NecronVehicleLoadouts.MONOLITH):
		var field := "necron_annihilation_barge_loadout" if unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE) else "necron_monolith_loadout"
		var default_choice := NecronVehicleLoadouts.default_choice(unit_id)
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {field: default_choice}
	elif unit_id.ends_with(":baal-predator"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id):
				by_model[model_id] = {"baal_predator_primary_cannon": "twin-assault-cannon", "baal_predator_sponson_package": "none", "baal_predator_storm_bolter": false, "baal_predator_hunter_killer_missile": false}
	elif unit_id.ends_with(":predator-destructor"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id): by_model[model_id] = {"predator_destructor_heavy_bolters": false, "predator_destructor_hunter_killer_missile": false, "predator_destructor_storm_bolter": false}
	elif unit_id.ends_with(":predator-annihilator"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id): by_model[model_id] = {"predator_annihilator_heavy_bolters": false, "predator_annihilator_hunter_killer_missile": false, "predator_annihilator_storm_bolter": false}
	elif unit_id.ends_with(":intercessor-squad"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(1, int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"intercessor_grenade_launcher": false}
	elif unit_id.ends_with(":outrider-squad"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id):
					by_model[model_id] = {"outrider_plasma_pistol": false}
					if model_index == 0: by_model[model_id].outrider_sergeant_melee = "chainsword"
	elif unit_id.ends_with(":ravenwing-darkshroud"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id): by_model[model_id] = {"ravenwing_darkshroud_cannon": "heavy-bolter"}
	elif unit_id.ends_with(":land-speeder"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id): by_model[model_id] = {"land_speeder_cannon": "onslaught"}
	elif unit_id.ends_with(":land-speeder-vengeance"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id): by_model[model_id] = {"land_speeder_vengeance_cannon": "heavy-bolter"}
	elif unit_id.ends_with(":hellblaster-squad"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id): by_model[model_id] = {"hellblaster_sergeant_pistol": "bolt-pistol"}
	elif unit_id.ends_with(":assault-intercessor-squad"):
		for copy_index in range(copy_ids.size()):
			var model_id := "%s:model:0" % str(copy_ids[copy_index])
			if not by_model.has(model_id): by_model[model_id] = {"assault_intercessor_sergeant_pistol": "heavy-bolt-pistol", "assault_intercessor_sergeant_melee": "chainsword"}
	elif unit_id.ends_with(":heavy-intercessor-squad"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(1, int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"heavy_intercessor_bolter": false}
	elif unit_id.ends_with(":inceptor-squad"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"inceptor_weapon": "assault-bolters"}
	elif unit_id.ends_with(":invader-atvs"):
		for copy_index in range(copy_ids.size()):
			for model_index in range(int(item.get("models", 0))):
				var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
				if not by_model.has(model_id): by_model[model_id] = {"invader_atv_multi_melta": false}
	elif unit_id.ends_with(":scout-squad"):
		if seed_scout_defaults:
			for copy_index in range(copy_ids.size()):
				for model_index in range(int(item.get("models", 0))):
					var model_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
					if not by_model.has(model_id): by_model[model_id] = {"scout_gun": "boltgun"} if model_index > 0 else {"scout_gun": "boltgun", "scout_sergeant_blade": "combat-knife"}
	item.model_equipment_by_id = by_model
	return by_model

static func unit_equipment(item: Dictionary, copy_index: int) -> Dictionary:
	var unit_id := str(item.get("unit_id", item.get("definition_id", "")))
	if (not unit_id.ends_with(":reiver-squad") and not SavedEquipment.supports_unit(unit_id)) or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return {}
	var copy_ids: Variant = item.get("copy_instance_ids", [])
	if not copy_ids is Array or copy_index >= copy_ids.size(): return _default_unit_equipment(unit_id)
	var by_copy: Variant = item.get("unit_equipment_by_copy_id", {})
	var equipment: Variant = by_copy.get(str(copy_ids[copy_index]), {}) if by_copy is Dictionary else {}
	return equipment.duplicate(true) if _valid_unit_equipment(unit_id, equipment) else _default_unit_equipment(unit_id)

static func has_unit_equipment(item: Dictionary, copy_index: int) -> bool:
	if copy_index < 0 or copy_index >= int(item.get("copies", 0)): return false
	var copy_ids: Variant = item.get("copy_instance_ids", [])
	var by_copy: Variant = item.get("unit_equipment_by_copy_id", {})
	if not copy_ids is Array or copy_index >= copy_ids.size() or not by_copy is Dictionary: return false
	var copy_id := str(copy_ids[copy_index])
	return by_copy.has(copy_id) and _valid_unit_equipment(str(item.get("unit_id", item.get("definition_id", ""))), by_copy[copy_id])

static func set_unit_equipment(item: Dictionary, copy_index: int, field: String, equipped: bool) -> bool:
	var unit_id := str(item.get("unit_id", item.get("definition_id", "")))
	if (not unit_id.ends_with(":reiver-squad") and not SavedEquipment.supports_unit(unit_id)) or field not in _default_unit_equipment(unit_id) or copy_index < 0 or copy_index >= int(item.get("copies", 0)): return false
	normalize_unit_equipment(item)
	var copy_ids: Variant = item.get("copy_instance_ids", [])
	if not copy_ids is Array or copy_index >= copy_ids.size(): return false
	var copy_id := str(copy_ids[copy_index])
	var equipment: Dictionary = item.unit_equipment_by_copy_id.get(copy_id, {}).duplicate(true)
	if bool(equipment.get(field, false)) == equipped: return false
	equipment[field] = equipped
	if not _valid_unit_equipment(str(item.get("unit_id", "")), equipment): return false
	item.unit_equipment_by_copy_id[copy_id] = equipment
	return true

static func normalize_unit_equipment(item: Dictionary) -> Dictionary:
	var unit_id := str(item.get("unit_id", item.get("definition_id", "")))
	if not unit_id.ends_with(":reiver-squad") and not SavedEquipment.supports_unit(unit_id): return {}
	var copy_ids := normalize_copy_instance_ids(item)
	var source: Variant = item.get("unit_equipment_by_copy_id", {})
	var by_copy: Dictionary = source.duplicate(true) if source is Dictionary else {}
	for copy_id: Variant in by_copy.keys():
		if str(copy_id) not in copy_ids or not _valid_unit_equipment(str(item.get("unit_id", "")), by_copy[copy_id]): by_copy.erase(copy_id)
	for copy_id: String in copy_ids:
		if not by_copy.has(copy_id): by_copy[copy_id] = _default_unit_equipment(unit_id)
	item.unit_equipment_by_copy_id = by_copy
	return by_copy

static func _valid_unit_equipment(unit_id: String, equipment: Variant) -> bool:
	if SavedEquipment.supports_unit(unit_id): return SavedEquipment.valid_unit(unit_id, equipment)
	if not equipment is Dictionary: return false
	if unit_id.ends_with(":reiver-squad"):
		if equipment.size() != 2: return false
		return equipment.has("reiver_grav_chutes") and equipment.reiver_grav_chutes is bool and equipment.has("reiver_grapnel_launchers") and equipment.reiver_grapnel_launchers is bool
	# Read the former whole-unit Aggressor record and migrate it to model IDs.
	if unit_id.ends_with(":aggressor-squad"):
		return equipment.size() == 1 and equipment.has("aggressor_boltstorm") and equipment.aggressor_boltstorm is bool
	return false

static func _default_unit_equipment(unit_id: String) -> Dictionary:
	if SavedEquipment.supports_unit(unit_id): return SavedEquipment.unit_defaults(unit_id)
	if unit_id.ends_with(":reiver-squad"): return {"reiver_grav_chutes": false, "reiver_grapnel_launchers": false}
	return {}

static func _valid_model_equipment(unit_id: String, model_index: int, equipment: Variant, model_count: int = 1000) -> bool:
	if not equipment is Dictionary or model_index < 0 or model_index >= model_count: return false
	if SavedEquipment.supports(unit_id): return SavedEquipment.valid_for_model(unit_id, model_index, equipment, model_count)
	if unit_id.ends_with(":canoptek-spyders"):
		if equipment.is_empty() or equipment.size() > CanoptekSpyders.EQUIPMENT_FIELDS.size(): return false
		for field: Variant in equipment:
			if str(field) not in CanoptekSpyders.EQUIPMENT_FIELDS or not equipment[field] is bool: return false
		return true
	if unit_id.ends_with(":outrider-squad"):
		var valid_keys := ["outrider_plasma_pistol"]
		if not equipment.has("outrider_plasma_pistol") or not equipment.outrider_plasma_pistol is bool: return false
		if model_index == 0:
			valid_keys.append("outrider_sergeant_melee")
			if not equipment.has("outrider_sergeant_melee") or str(equipment.get("outrider_sergeant_melee", "")) not in ["chainsword", "power-weapon", "thunder-hammer"]: return false
		elif equipment.has("outrider_sergeant_melee"):
			return false
		if equipment.size() != valid_keys.size(): return false
		for key: Variant in equipment:
			if str(key) not in valid_keys: return false
		return true
	if unit_id.ends_with(":ravenwing-darkshroud"):
		return model_index == 0 and equipment.size() == 1 and equipment.has("ravenwing_darkshroud_cannon") and str(equipment.get("ravenwing_darkshroud_cannon", "")) in ["heavy-bolter", "assault-cannon"]
	if unit_id.ends_with(":land-speeder"):
		return model_index == 0 and equipment.size() == 1 and equipment.has("land_speeder_cannon") and str(equipment.get("land_speeder_cannon", "")) in ["onslaught", "pyrecannon"]
	if unit_id.ends_with(":land-speeder-vengeance"):
		return model_index == 0 and equipment.size() == 1 and equipment.has("land_speeder_vengeance_cannon") and str(equipment.get("land_speeder_vengeance_cannon", "")) in ["heavy-bolter", "assault-cannon"]
	if unit_id.ends_with(":baal-predator"):
		if model_index != 0 or equipment.size() != 4: return false
		var profile := CurrentMarineProfiles.profile("baal-predator")
		var options: Dictionary = profile.get("options", {})
		return equipment.has("baal_predator_primary_cannon") and str(equipment.get("baal_predator_primary_cannon", "")) in options.get("primary_cannon", []) \
			and equipment.has("baal_predator_sponson_package") and str(equipment.get("baal_predator_sponson_package", "")) in options.get("sponson_package", []) \
			and equipment.has("baal_predator_storm_bolter") and equipment.baal_predator_storm_bolter is bool \
			and equipment.has("baal_predator_hunter_killer_missile") and equipment.baal_predator_hunter_killer_missile is bool
	if unit_id.ends_with(":predator-destructor"):
		if model_index != 0 or equipment.size() != 3: return false
		var profile := CurrentMarineProfiles.profile("predator-destructor")
		var options: Dictionary = profile.get("options", {})
		return options.has("replace_two_lascannons_with_two_heavy_bolters") and options.replace_two_lascannons_with_two_heavy_bolters is bool \
			and options.has("add_optional_hunter_killer_missile") and options.add_optional_hunter_killer_missile is bool \
			and options.has("add_optional_storm_bolter") and options.add_optional_storm_bolter is bool \
			and equipment.has("predator_destructor_heavy_bolters") and equipment.predator_destructor_heavy_bolters is bool \
			and equipment.has("predator_destructor_hunter_killer_missile") and equipment.predator_destructor_hunter_killer_missile is bool \
			and equipment.has("predator_destructor_storm_bolter") and equipment.predator_destructor_storm_bolter is bool
	if unit_id.ends_with(":predator-annihilator"):
		if model_index != 0 or equipment.size() != 3: return false
		var profile := CurrentMarineProfiles.profile("predator-annihilator")
		var options: Dictionary = profile.get("options", {})
		return options.has("replace_two_lascannons_with_two_heavy_bolters") and options.replace_two_lascannons_with_two_heavy_bolters is bool \
			and options.has("add_optional_hunter_killer_missile") and options.add_optional_hunter_killer_missile is bool \
			and options.has("add_optional_storm_bolter") and options.add_optional_storm_bolter is bool \
			and equipment.has("predator_annihilator_heavy_bolters") and equipment.predator_annihilator_heavy_bolters is bool \
			and equipment.has("predator_annihilator_hunter_killer_missile") and equipment.predator_annihilator_hunter_killer_missile is bool \
			and equipment.has("predator_annihilator_storm_bolter") and equipment.predator_annihilator_storm_bolter is bool
	if unit_id.ends_with(":hellblaster-squad"):
		return model_index == 0 and equipment.size() == 1 and equipment.has("hellblaster_sergeant_pistol") and str(equipment.get("hellblaster_sergeant_pistol", "")) in ["bolt-pistol", "plasma-pistol"]
	if unit_id.ends_with(":assault-intercessor-squad"):
		return model_index == 0 and equipment.size() == 2 and equipment.has("assault_intercessor_sergeant_pistol") and str(equipment.get("assault_intercessor_sergeant_pistol", "")) in ASSAULT_INTERCESSOR_SERGEANT_PISTOLS and equipment.has("assault_intercessor_sergeant_melee") and str(equipment.get("assault_intercessor_sergeant_melee", "")) in ASSAULT_INTERCESSOR_SERGEANT_MELEE
	if unit_id.ends_with(":heavy-intercessor-squad"):
		return model_index > 0 and equipment.size() == 1 and equipment.has("heavy_intercessor_bolter") and equipment.heavy_intercessor_bolter is bool
	if unit_id.ends_with(":inceptor-squad"):
		return equipment.size() == 1 and equipment.has("inceptor_weapon") and str(equipment.get("inceptor_weapon", "")) in ["assault-bolters", "plasma-exterminators"]
	if unit_id.ends_with(":invader-atvs"):
		return equipment.size() == 1 and equipment.has("invader_atv_multi_melta") and equipment.invader_atv_multi_melta is bool
	if unit_id.ends_with(":scout-squad"):
		if model_index == 0:
			return equipment.size() == 2 and equipment.has("scout_gun") and str(equipment.scout_gun) in ["boltgun", "shotgun"] and equipment.has("scout_sergeant_blade") and str(equipment.scout_sergeant_blade) in ["combat-knife", "chainsword"]
		return equipment.size() == 1 and equipment.has("scout_gun") and str(equipment.scout_gun) in SCOUT_TROOPER_GUN_CHOICES
	if unit_id.ends_with(":aggressor-squad"):
		return equipment.size() == 1 and equipment.has("aggressor_boltstorm") and equipment.aggressor_boltstorm is bool
	if equipment.size() != 1: return false
	if unit_id.ends_with(":eliminator-squad"):
		if model_index == 0: return equipment.has("eliminator_sergeant_ranged") and ELIMINATOR_SERGEANT_WEAPONS.has(str(equipment.get("eliminator_sergeant_ranged", "")))
		return equipment.has("eliminator_trooper_ranged") and str(equipment.get("eliminator_trooper_ranged", "")) in ["sniper", "las"]
	if unit_id.ends_with(":intercessor-squad"):
		return model_index > 0 and equipment.has("intercessor_grenade_launcher") and equipment.intercessor_grenade_launcher is bool
	if unit_id.ends_with(":necron-warriors"): return equipment.has("necron_ranged_weapon") and NECRON_WARRIOR_WEAPONS.has(str(equipment.get("necron_ranged_weapon", "")))
	if unit_id.ends_with(":immortals"): return equipment.has("necron_ranged_weapon") and IMMORTAL_WEAPONS.has(str(equipment.get("necron_ranged_weapon", "")))
	if unit_id.ends_with(":canoptek-macrocytes"):
		return equipment.has("canoptek_macrocytes_loadout") and str(equipment.get("canoptek_macrocytes_loadout", "")) in CanoptekMacrocytes.LOADOUTS
	if unit_id.ends_with(":canoptek-tomb-crawlers"):
		return equipment.has("canoptek_tomb_crawlers_loadout") and str(equipment.get("canoptek_tomb_crawlers_loadout", "")) in [CanoptekTombCrawlers.GAUSS_REAPER, CanoptekTombCrawlers.ISOLATOR]
	if unit_id.ends_with(":" + NecronVehicleLoadouts.ANNIHILATION_BARGE):
		return equipment.has("necron_annihilation_barge_loadout") and NecronVehicleLoadouts.valid_choice(unit_id, str(equipment.get("necron_annihilation_barge_loadout", "")))
	if unit_id.ends_with(":" + NecronVehicleLoadouts.MONOLITH):
		return equipment.has("necron_monolith_loadout") and NecronVehicleLoadouts.valid_choice(unit_id, str(equipment.get("necron_monolith_loadout", "")))
	return false

static func valid_model_equipment(unit_id: String, model_index: int, equipment: Variant, model_count: int = 1000) -> bool:
	return _valid_model_equipment(unit_id, model_index, equipment, model_count)

static func valid_unit_equipment(unit_id: String, equipment: Variant) -> bool:
	return _valid_unit_equipment(unit_id, equipment)

static func _default_canoptek_spyder_equipment() -> Dictionary:
	var result := {}
	for field: String in CanoptekSpyders.EQUIPMENT_FIELDS: result[field] = false
	return result

static func normalize_model_visual_overrides(item: Dictionary) -> Array:
	var wanted := mini(maxi(0, int(item.get("models", 0))) * maxi(0, int(item.get("copies", 0))), 20000)
	var slots: Array = item.get("visual_model_overrides", []) if item.get("visual_model_overrides", []) is Array else []
	var keyed: Dictionary = item.get("visual_model_overrides_by_id", {}) if item.get("visual_model_overrides_by_id", {}) is Dictionary else {}
	while slots.size() > wanted: slots.pop_back()
	while slots.size() < wanted: slots.append("")
	var copy_ids := normalize_copy_instance_ids(item)
	for existing_id: Variant in keyed.keys():
		var retained := false
		for copy_id: String in copy_ids:
			if str(existing_id).begins_with(copy_id + ":model:"):
				var model_index_text := str(existing_id).trim_prefix(copy_id + ":model:")
				retained = model_index_text.is_valid_int() and int(model_index_text) >= 0 and int(model_index_text) < 1000 and keyed[existing_id] is String and str(keyed[existing_id]).length() <= 128
				break
		if not retained: keyed.erase(existing_id)
	for copy_index in range(int(item.get("copies", 0))):
		for model_index in range(int(item.get("models", 0))):
			var slot := copy_index * int(item.get("models", 0)) + model_index
			var stable_id := "%s:model:%d" % [str(copy_ids[copy_index]), model_index]
			var legacy_value := str(slots[slot]) if slot < slots.size() and slots[slot] is String else ""
			var value := str(keyed.get(stable_id, legacy_value))
			if value.is_empty(): keyed.erase(stable_id)
			else: keyed[stable_id] = value
			slots[slot] = value
	item.visual_model_overrides = slots
	item.visual_model_overrides_by_id = keyed
	return slots

static func normalize_visual_variants(item: Dictionary) -> Array:
	var models := maxi(0, int(item.get("models", 0)))
	var copies := maxi(0, int(item.get("copies", 0)))
	var wanted := mini(models * copies, 20000)
	var slots: Array = item.get("visual_variants", []) if item.get("visual_variants", []) is Array else []
	while slots.size() > wanted: slots.pop_back()
	while slots.size() < wanted: slots.append("")
	for copy_index in range(copies):
		var start := copy_index * models
		var selected := ""
		for model_index in range(models):
			var candidate: Variant = slots[start + model_index]
			if candidate is String and not candidate.is_empty():
				selected = candidate
				break
		for model_index in range(models): slots[start + model_index] = selected
	item.visual_variants = slots
	return slots

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
		var composition_choice: Dictionary = {}
		if unit.has("composition_options"):
			var choice_id := str(old.get("composition_choice_id", "ancient-champion"))
			for candidate: Dictionary in unit.composition_options:
				if int(candidate.get("models", -1)) == int(old.models) and str(candidate.get("id", "")) == choice_id:
					composition_choice = candidate
					break
			if composition_choice.is_empty(): return {"error": "Unit composition changed in the catalog: " + old.name}
		var refreshed := entry(unit, option, int(old.copies), composition_choice)
		if old.has("source_scope") and not unit.has("source_scope"): refreshed.source_scope = str(old.source_scope)
		if old.has("copy_instance_ids"): refreshed.copy_instance_ids = old.copy_instance_ids.duplicate(true)
		if old.has("intercessor_sergeant_loadouts"): refreshed.intercessor_sergeant_loadouts = old.intercessor_sergeant_loadouts.duplicate(true)
		if old.has("visual_variants"): refreshed.visual_variants = old.visual_variants.duplicate(true)
		if old.has("visual_model_overrides"): refreshed.visual_model_overrides = old.visual_model_overrides.duplicate(true)
		if old.has("visual_model_overrides_by_id"): refreshed.visual_model_overrides_by_id = old.visual_model_overrides_by_id.duplicate(true)
		if old.has("model_equipment_by_id"): refreshed.model_equipment_by_id = old.model_equipment_by_id.duplicate(true)
		if old.has("unit_equipment_by_copy_id"): refreshed.unit_equipment_by_copy_id = old.unit_equipment_by_copy_id.duplicate(true)
		normalize_unit_equipment(refreshed)
		if old.has("enhancement_id"): refreshed.enhancement_id = old.enhancement_id
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
	if catalog.has("enhancements") and not catalog.enhancements is Array: return "Invalid enhancement catalog."
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
			if option.has("third_plus_cost") and not integer(option.third_plus_cost, 1): return "Invalid third-plus cost/composition in catalog."
			if option.has("second_plus_cost") and not integer(option.second_plus_cost, 1): return "Invalid second-plus cost/composition in catalog."
			if option.has("fourth_plus_cost") and not integer(option.fourth_plus_cost, 1): return "Invalid fourth-plus cost/composition in catalog."
	if catalog_digest(catalog.units, catalog.get("enhancements", [])) != catalog.digest: return "Catalog integrity check failed."
	return ""

static func catalog_digest(units: Array, enhancements: Array = []) -> String:
	# JSON parses numeric tokens as floats; normalize integer-valued fields before hashing.
	var canonical := units.duplicate(true)
	for unit: Dictionary in canonical:
		for option: Dictionary in unit.options:
			option.models = int(option.models)
			if option.cost != null: option.cost = int(option.cost)
			if option.has("second_plus_cost"): option.second_plus_cost = int(option.second_plus_cost)
			if option.has("third_plus_cost"): option.third_plus_cost = int(option.third_plus_cost)
			if option.has("fourth_plus_cost"): option.fourth_plus_cost = int(option.fourth_plus_cost)
	return JSON.stringify({"units": canonical, "enhancements": enhancements}).sha256_text()

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
