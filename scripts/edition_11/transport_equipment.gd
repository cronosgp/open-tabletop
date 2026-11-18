extends RefCounted
## Pure inventory/selection data shared by saved armies and legacy transport setup.
## Editor support is restricted to the individually source-reviewed identities below.
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const IDS := ["land-raider", "land-raider-crusader", "land-raider-redeemer", "land-raider-excelsior", "razorback", "relic-razorback", "repulsor", "repulsor-executioner", "black-templars-repulsor", "black-templars-repulsor-executioner", "impulsor", "black-templars-impulsor", "corvus-blackstar", "mastodon"]
const SYSTEM_NAMES := {"none": "No optional system", "bellicatus-missile-array": "Bellicatus Missile Array", "orbital-comms-array": "Orbital Comms Array", "ironhail-skytalon-array": "Ironhail Skytalon Array", "shield-dome": "Shield Dome"}

static func supports(definition: String) -> bool:
	var id := definition.get_slice(":", 3)
	return id in IDS and definition == "40kdc:11e:adeptus-astartes:" + id

static func is_impulsor(definition: String) -> bool:
	return definition.get_slice(":", 3) in ["impulsor", "black-templars-impulsor"]

static func weapon_id(profile: Dictionary, name: String) -> String:
	for weapon: Dictionary in profile.get("ranged", []) + profile.get("additional_weapon_profiles", {}).get("ranged", []):
		for stats: Dictionary in weapon.get("profiles", {}).values():
			if str(stats.get("name", "")).begins_with(name): return str(weapon.get("id", ""))
	return ""

static func append_weapon(weapons: Array, profile: Dictionary, id: String) -> void:
	for weapon: Dictionary in profile.get("additional_weapon_profiles", {}).get("ranged", []):
		if str(weapon.get("id", "")) == id:
			weapons.append(weapon.duplicate(true))
			return

static func optional_inventory(profile: Dictionary, unit: Dictionary) -> Array:
	var weapons: Array = profile.get("ranged", []).duplicate(true)
	var options: Dictionary = profile.get("transport", {}).get("options", {})
	for group_id: String in options.get("replacement_groups", {}):
		var group: Dictionary = options.replacement_groups[group_id]
		var selected: Variant = unit.get("optional_transport_replacement_groups", {}).get(group_id, "")
		var to_ids: Array = group.get("to_ids", [])
		if group.get("choices") is Dictionary:
			if not group.choices.has(str(selected)): continue
			to_ids = group.choices[str(selected)].get("to_ids", [])
		elif not bool(selected): continue
		var from_ids: Array = group.get("from_ids", [])
		if from_ids.is_empty() or to_ids.is_empty(): continue
		weapons = weapons.filter(func(w: Dictionary) -> bool: return str(w.get("id", "")) not in from_ids)
		for id: String in to_ids: append_weapon(weapons, profile, id)
	for base_name: String in options.get("replacements", {}):
		var base := weapon_id(profile, base_name)
		var replacement := weapon_id(profile, str(options.replacements[base_name]))
		var selected := str(unit.get("optional_transport_replacements", {}).get(base, base))
		if base.is_empty() or replacement.is_empty() or selected == base: continue
		weapons = weapons.filter(func(w: Dictionary) -> bool: return str(w.get("id", "")) != base)
		append_weapon(weapons, profile, selected)
	for name: String in options.get("add", []):
		var id := weapon_id(profile, name)
		if bool(unit.get("optional_transport_weapons", {}).get(id, false)): append_weapon(weapons, profile, id)
	return weapons

static func impulsor_inventory(profile: Dictionary, unit: Dictionary) -> Array:
	var weapons: Array = profile.get("ranged", []).duplicate(true)
	if bool(unit.get("impulsor_fragstorm_launchers", false)):
		weapons = weapons.filter(func(w: Dictionary) -> bool: return str(w.get("id", "")) != "storm-bolters")
		append_weapon(weapons, profile, "fragstorm-grenade-launchers")
	var system := str(unit.get("impulsor_system", "none"))
	if system in ["bellicatus-missile-array", "ironhail-skytalon-array"]: append_weapon(weapons, profile, system)
	var pintle := str(unit.get("impulsor_pintle", "ironhail-heavy-stubber" if bool(unit.get("impulsor_heavy_stubber", false)) else "none"))
	if pintle != "none": append_weapon(weapons, profile, pintle)
	return weapons

static func _field(kind: String, id: String) -> String:
	return "transport_" + kind + "_" + id.replace("-", "_")

static func _priced_label(profile: Dictionary, name: String) -> String:
	var points := int(profile.get("wargear_costs", {}).get(name, 0))
	return name + (" (+%d points)" % points if points > 0 else "")

static func controls(definition: String) -> Array[Dictionary]:
	if not supports(definition): return []
	var profile := Marines.profile(definition.get_slice(":", 3))
	var options: Dictionary = profile.get("transport", {}).get("options", {})
	var result: Array[Dictionary] = []
	if is_impulsor(definition):
		var systems: Array[Dictionary] = [{"id": "none", "label": SYSTEM_NAMES.none}]
		for id: String in SYSTEM_NAMES:
			if SYSTEM_NAMES[id] in options.get("one_of", []): systems.append({"id": id, "label": _priced_label(profile, SYSTEM_NAMES[id])})
		var pintles: Array[Dictionary] = [{"id": "none", "label": "Not equipped"}, {"id": "ironhail-heavy-stubber", "label": "Ironhail Heavy Stubber"}]
		if definition.ends_with(":black-templars-impulsor"): pintles.append({"id": "multi-melta", "label": _priced_label(profile, "Multi-melta")})
		return [
			{"field": "impulsor_system", "label": "Optional system", "choices": systems},
			{"field": "impulsor_fragstorm_launchers", "label": "Storm Bolters replacement", "choices": [{"id": false, "label": "Storm Bolters"}, {"id": true, "label": "Fragstorm Grenade Launchers"}]},
			{"field": "impulsor_pintle", "label": "Optional pintle weapon", "choices": pintles}
		]
	for name: String in options.get("add", []):
		result.append({"field": _field("add", weapon_id(profile, name)), "label": name, "choices": [{"id": false, "label": "Not equipped"}, {"id": true, "label": _priced_label(profile, name)}]})
	for name: String in options.get("replacements", {}):
		var replacement := str(options.replacements[name])
		result.append({"field": _field("replace", weapon_id(profile, name)), "label": name + " replacement", "choices": [{"id": weapon_id(profile, name), "label": _priced_label(profile, name)}, {"id": weapon_id(profile, replacement), "label": _priced_label(profile, replacement)}]})
	for id: String in options.get("replacement_groups", {}):
		var group: Dictionary = options.replacement_groups[id]
		if not group.get("choices") is Dictionary:
			result.append({"field": _field("group", id), "label": str(group.name), "choices": [{"id": false, "label": "Keep original pair"}, {"id": true, "label": "Use replacement pair"}]})
			continue
		var choices: Array[Dictionary] = [{"id": "default", "label": str(group.name)}]
		for choice: String in group.get("choices", {}): choices.append({"id": choice, "label": str(group.choices[choice].name)})
		result.append({"field": _field("group", id), "label": str(group.name) + " replacement", "choices": choices})
	return result

static func defaults(definition: String) -> Dictionary:
	var result := {}
	for descriptor: Dictionary in controls(definition): result[descriptor.field] = descriptor.choices[0].id
	return result

static func valid(definition: String, equipment: Variant, models: int) -> bool:
	if not supports(definition) or models != 1 or not equipment is Dictionary: return false
	var descriptors := controls(definition)
	if descriptors.is_empty() or equipment.size() != descriptors.size(): return false
	for descriptor: Dictionary in descriptors:
		if not equipment.has(descriptor.field): return false
		var found := false
		for choice: Dictionary in descriptor.choices:
			if typeof(equipment[descriptor.field]) == typeof(choice.id) and equipment[descriptor.field] == choice.id: found = true
		if not found: return false
	return true

static func prepare(unit: Dictionary, definition: String, equipment: Dictionary) -> void:
	if not valid(definition, equipment, 1): return
	var profile := Marines.profile(definition.get_slice(":", 3))
	unit.melee_weapons = profile.melee.duplicate(true)
	if is_impulsor(definition):
		for field: String in equipment: unit[field] = equipment[field]
		unit.impulsor_heavy_stubber = str(equipment.impulsor_pintle) == "ironhail-heavy-stubber"
		unit.ranged_weapons = impulsor_inventory(profile, unit)
	else:
		unit.optional_transport_weapons = {}
		unit.optional_transport_replacements = {}
		unit.optional_transport_replacement_groups = {}
		var options: Dictionary = profile.transport.options
		for name: String in options.get("add", []):
			var id := weapon_id(profile, name)
			unit.optional_transport_weapons[id] = bool(equipment[_field("add", id)])
		for name: String in options.get("replacements", {}):
			var id := weapon_id(profile, name)
			unit.optional_transport_replacements[id] = str(equipment[_field("replace", id)])
		for id: String in options.get("replacement_groups", {}):
			if options.replacement_groups[id].get("choices") is Dictionary:
				var value := str(equipment[_field("group", id)])
				if value != "default": unit.optional_transport_replacement_groups[id] = value
			else:
				unit.optional_transport_replacement_groups[id] = bool(equipment[_field("group", id)])
		unit.ranged_weapons = optional_inventory(profile, unit)
	unit.transport_loadout_locked = true

static func points(definition: String, equipment: Variant, models: int) -> int:
	if not valid(definition, equipment, models): return 0
	var profile := Marines.profile(definition.get_slice(":", 3))
	var unit := {}
	prepare(unit, definition, equipment)
	var ids: Array = unit.ranged_weapons.map(func(w: Dictionary) -> String: return str(w.id))
	var result := 0
	for name: String in profile.get("wargear_costs", {}):
		if weapon_id(profile, name) in ids or (name == "Orbital Comms Array" and str(equipment.get("impulsor_system", "none")) == "orbital-comms-array"):
			result += int(profile.wargear_costs[name])
	return result
