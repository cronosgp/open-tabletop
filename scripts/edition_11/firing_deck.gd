extends RefCounted
## Firing Deck projects selected passenger weapons into the transport's ranged inventory.
const PREFIX := "firing-deck@"

static func model_limit(state: Dictionary, transport_model: int) -> int:
	if not state.units.has(transport_model): return 0
	var transport_profile: Dictionary = state.units[transport_model].get("transport_profile", {})
	for ability: Dictionary in transport_profile.get("abilities", []):
		if str(ability.get("name", "")) == "Firing Deck":
			var parameter: Variant = ability.get("parameter", "")
			return int(parameter) if str(parameter).is_valid_int() else 0
	return 0

static func embarked_model_count(state: Dictionary, transport_model: int) -> int:
	var count := 0
	for unit: Dictionary in state.get("units", {}).values():
		if int(unit.get("embarked_transport", -1)) == transport_model and int(unit.get("wounds", 0)) > 0: count += 1
	return count

static func _virtual_weapon(source_model: int, source_weapon: Dictionary) -> Dictionary:
	var source_id := str(source_weapon.get("id", ""))
	if source_id.is_empty(): return {}
	var result: Dictionary = source_weapon.duplicate(true)
	result.id = PREFIX + str(source_model) + "@" + source_id
	result.firing_deck_source_model = source_model
	result.firing_deck_source_weapon = source_id
	return result

static func _weapon_options(weapon: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var source_model := int(weapon.get("firing_deck_source_model", -1))
	for profile: String in weapon.get("profiles", {}):
		var stats: Dictionary = weapon.profiles[profile]
		if stats.get("keywords", {}).get("one-shot", false): continue
		var label := "Firing Deck — %s — passenger model %d" % [str(stats.get("name", weapon.get("name", "Ranged weapon"))), source_model]
		result.append({"weapon": str(weapon.id), "profile": profile, "label": label, "stats": stats, "firing_deck_source_model": source_model})
	return result

static func weapon_choices(state: Dictionary, transport_model: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if model_limit(state, transport_model) <= 0 or not state.units.has(transport_model): return result
	var transport: Dictionary = state.units[transport_model]
	if state.phase != "shooting" or int(transport.get("owner", -1)) != int(state.get("active", -2)): return result
	for active_weapon: Dictionary in transport.get("firing_deck_active_weapons", []):
		result.append_array(_weapon_options(active_weapon))
	var active_ids: Dictionary = {}
	for active_weapon: Dictionary in transport.get("firing_deck_active_weapons", []): active_ids[str(active_weapon.get("id", ""))] = true
	for source_model: int in state.units:
		var source: Dictionary = state.units[source_model]
		if int(source.get("embarked_transport", -1)) != transport_model or int(source.get("wounds", 0)) <= 0: continue
		var source_squad := int(source.get("squad", -1))
		if not state.squads.has(source_squad) or bool(state.squads[source_squad].get("shot", false)): continue
		if int(state.squads[source_squad].get("firing_deck_blocked_until_turn", -1)) == int(state.get("turn", -2)): continue
		var inventory: Array = source.get("ranged_weapons", [])
		if inventory.is_empty():
			var legacy: Dictionary = state.squads[source_squad].get("weapon", {})
			if not legacy.is_empty(): inventory = [{"id": "default", "name": legacy.get("name", "Default weapon"), "profiles": {"default": legacy}}]
		for source_weapon: Dictionary in inventory:
			var virtual_weapon := _virtual_weapon(source_model, source_weapon)
			if virtual_weapon.is_empty() or active_ids.has(str(virtual_weapon.id)): continue
			result.append_array(_weapon_options(virtual_weapon))
	return result

static func validate_assignments(state: Dictionary, transport_model: int, entries: Array) -> String:
	var limit := model_limit(state, transport_model)
	var selected_models: Dictionary = {}
	for row: Variant in entries:
		if not row is Dictionary: continue
		var weapon_id := str(row.get("weapon", ""))
		if not weapon_id.begins_with(PREFIX): continue
		if int(row.get("model", -1)) != transport_model: return "Firing Deck weapons are assigned to the transport's attack plan."
		var found: Dictionary = {}
		for option: Dictionary in weapon_choices(state, transport_model):
			if str(option.weapon) == weapon_id and str(option.profile) == str(row.get("profile", "")):
				found = option
				break
		if found.is_empty(): return "That passenger weapon is no longer eligible for Firing Deck."
		var source_model := int(found.get("firing_deck_source_model", -1))
		if source_model < 0: return "Firing Deck passenger source is missing."
		var selection_token := weapon_id + "#" + str(row.get("profile", ""))
		if selected_models.has(source_model) and str(selected_models[source_model]) != selection_token: return "Firing Deck selects only one ranged weapon profile from each passenger model."
		selected_models[source_model] = selection_token
	if selected_models.size() > limit: return "Firing Deck %d can select at most %d passenger models." % [limit, limit]
	return ""

static func declare_transport_shooting(state: Dictionary, transport_model: int, entries: Array) -> String:
	if state.phase != "shooting" or model_limit(state, transport_model) <= 0: return ""
	if not state.units.has(transport_model): return "The Firing Deck transport is missing."
	var passengers: Dictionary = {}
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("embarked_transport", -1)) != transport_model or int(unit.get("wounds", 0)) <= 0: continue
		var squad := int(unit.get("squad", -1))
		if state.squads.has(squad): passengers[squad] = true
	if passengers.is_empty(): return ""
	var error := validate_assignments(state, transport_model, entries)
	if not error.is_empty(): return error
	var active_weapons: Array[Dictionary] = []
	var selected_ids: Dictionary = {}
	for row: Variant in entries:
		if not row is Dictionary or not str(row.get("weapon", "")).begins_with(PREFIX): continue
		if selected_ids.has(str(row.weapon)): continue
		for option: Dictionary in weapon_choices(state, transport_model):
			if str(option.weapon) != str(row.weapon) or str(option.profile) != str(row.get("profile", "")): continue
			var source_model := int(option.firing_deck_source_model)
			var source: Dictionary = state.units.get(source_model, {})
			var inventory: Array = source.get("ranged_weapons", [])
			if inventory.is_empty():
				var source_squad := int(source.get("squad", -1))
				if not state.squads.has(source_squad): continue
				var legacy: Dictionary = state.squads[source_squad].get("weapon", {})
				if not legacy.is_empty(): inventory = [{"id": "default", "name": legacy.get("name", "Default weapon"), "profiles": {"default": legacy}}]
			for source_weapon: Dictionary in inventory:
				var virtual_weapon := _virtual_weapon(source_model, source_weapon)
				if str(virtual_weapon.get("id", "")) == str(row.weapon):
					active_weapons.append(virtual_weapon)
					selected_ids[str(row.weapon)] = true
			break
	state.units[transport_model].firing_deck_active_weapons = active_weapons
	for squad: int in passengers: state.squads[squad].firing_deck_blocked_until_turn = int(state.turn)
	return ""

static func finish_transport_shooting(state: Dictionary, transport_model: int) -> void:
	if not state.units.has(transport_model): return
	state.units[transport_model].erase("firing_deck_active_weapons")
