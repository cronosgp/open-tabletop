extends RefCounted
## Local e11 transport identity, capacity and Embarking rules.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Terrain = preload("res://scripts/edition_11/terrain.gd")
const Prevention = preload("res://scripts/edition_11/wound_prevention.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Stratagems = preload("res://scripts/edition_11/stratagems.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Hazardous = preload("res://scripts/edition_11/hazardous.gd")
const FightQueue = preload("res://scripts/edition_11/fight_queue.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const ChaplainGrimaldus = preload("res://scripts/edition_11/chaplain_grimaldus.gd")
const EMERGENCY_WINDOW := "transport-emergency"
const DISEMBARK_WINDOW := "transport-disembark"
const COMBAT_EMBARKATION_WINDOW := "repulsor-combat-embarkation"
const IMPULSOR_SYSTEMS := ["none", "bellicatus-missile-array", "orbital-comms-array", "ironhail-skytalon-array", "shield-dome"]
const IMPULSOR_SYSTEM_NAMES := {"none": "No optional array or Shield Dome", "bellicatus-missile-array": "Bellicatus Missile Array", "orbital-comms-array": "Orbital Comms Array", "ironhail-skytalon-array": "Ironhail Skytalon Array", "shield-dome": "Shield Dome"}

static func identity(unit: Dictionary) -> String:
	return str(unit.get("definition_id", "")).get_slice(":", 3)

static func _is_impulsor_identity(identity_id: String) -> bool:
	return identity_id in ["impulsor", "black-templars-impulsor"]

static func _is_repulsor_identity(identity_id: String) -> bool:
	return identity_id in ["repulsor", "black-templars-repulsor"]

static func drop_pod_model(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and identity(state.units[model]) == "drop-pod": return model
	return -1

static func is_drop_pod(state: Dictionary, squad: int) -> bool:
	return drop_pod_model(state, squad) >= 0

static func _combat_embarkation_candidates(state: Dictionary, defender: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var pending: Dictionary = state.get("pending_charge", {})
	if pending.is_empty() or int(state.get("active", -1)) == defender: return result
	var charger := int(pending.get("squad", -1))
	if not state.squads.has(charger) or int(state.squads[charger].owner) == defender: return result
	for target_squad: int in pending.get("targets", []):
		if not state.squads.has(target_squad) or int(state.squads[target_squad].owner) != defender or FightQueue.engaged(state, target_squad): continue
		if bool(state.squads[target_squad].get("set_up_this_turn", false)): continue
		for transport_model: int in state.units:
			var transport: Dictionary = state.units[transport_model]
			if int(transport.get("owner", -1)) != defender or not _is_repulsor_identity(identity(transport)): continue
			if not eligibility_error(state, transport_model, target_squad, true).is_empty(): continue
			result.append({"transport": transport_model, "passenger_squad": target_squad})
	return result

static func begin_combat_embarkation_reaction(state: Dictionary, charger: int) -> bool:
	if not state.get("unit_abilities", {}).get("transport_window", {}).is_empty(): return false
	if not state.get("unit_abilities", {}).get("window", {}).is_empty(): return false
	var pending: Dictionary = state.get("pending_charge", {})
	if state.phase != "charge" or pending.is_empty() or int(pending.get("squad", -1)) != charger or pending.get("targets", []).is_empty() or pending.get("combat_embarkation_resolved", false): return false
	var defender := 3 - int(state.squads[charger].owner)
	if _combat_embarkation_candidates(state, defender).is_empty(): return false
	state.unit_abilities.window = {"kind": COMBAT_EMBARKATION_WINDOW, "owners": [defender], "charger": charger}
	return true

static func combat_embarkation_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != COMBAT_EMBARKATION_WINDOW or window.get("owners", []) != [player]: return result
	for candidate: Dictionary in _combat_embarkation_candidates(state, player):
		var passenger := int(candidate.passenger_squad)
		var transport := int(candidate.transport)
		result.append({"label": "Repulsor Combat Embarkation: embark %s in %s" % [state.squads[passenger].name, state.squads[state.units[transport].squad].name], "action": "repulsor-combat-embarkation-embark", "model": models(state, passenger)[0], "target": transport, "value": str(passenger)})
	result.append({"label": "Repulsor Combat Embarkation: pass and continue the charge", "action": "repulsor-combat-embarkation-pass", "model": -1, "target": int(window.charger), "value": ""})
	return result

static func apply_combat_embarkation(state: Dictionary, player: int, selected: Dictionary) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	if window.get("kind", "") != COMBAT_EMBARKATION_WINDOW or window.get("owners", []) != [player]: return "No Repulsor Combat Embarkation reaction is pending for this player."
	var pending: Dictionary = state.get("pending_charge", {})
	if pending.is_empty() or int(pending.get("squad", -1)) != int(window.get("charger", -2)): return "The charge declaration changed before the Repulsor reaction resolved."
	if selected.get("action", "") == "repulsor-combat-embarkation-embark":
		var passenger_squad := int(selected.get("value", "-1"))
		var transport_model := int(selected.get("target", -1))
		var found := false
		for candidate: Dictionary in _combat_embarkation_candidates(state, player):
			if int(candidate.passenger_squad) == passenger_squad and int(candidate.transport) == transport_model: found = true
		if not found or int(selected.get("model", -1)) not in models(state, passenger_squad): return "That unit is no longer eligible to use Repulsor Combat Embarkation."
		_set_embarked(state, passenger_squad, transport_model)
		pending.targets.erase(passenger_squad)
		pending.combat_embarkation_embarked = passenger_squad
	elif selected.get("action", "") != "repulsor-combat-embarkation-pass":
		return "Unsupported Repulsor Combat Embarkation response."
	pending.combat_embarkation_resolved = true
	state.unit_abilities.window = {}
	return ""

static func models(state: Dictionary, squad: int, living_only: bool = true) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if state.units[model].squad != squad: continue
		if living_only and int(state.units[model].get("wounds", 0)) <= 0: continue
		result.append(model)
	return result

static func profile(state: Dictionary, transport_model: int) -> Dictionary:
	if not state.units.has(transport_model): return {}
	return state.units[transport_model].get("transport_profile", {}).duplicate(true)

static func datasheet_has_ability(state: Dictionary, transport_model: int, ability_name: String) -> bool:
	if not is_transport(state, transport_model): return false
	var transport_profile := profile(state, transport_model)
	for option_name: String in transport_profile.get("options", {}).get("one_of", []):
		if option_name != ability_name: continue
		for system: String in IMPULSOR_SYSTEMS:
			if IMPULSOR_SYSTEM_NAMES[system] == option_name: return str(state.units[transport_model].get("impulsor_system", "none")) == system
		return false
	for ability: Dictionary in transport_profile.get("abilities", []):
		if str(ability.get("name", "")) == ability_name: return true
	return false

static func impulsor_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.phase != "deployment": return result
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or not _is_impulsor_identity(identity(unit)): continue
		var profile_data := MarineProfiles.profile(identity(unit))
		var offered_systems: Array = profile_data.get("transport", {}).get("options", {}).get("one_of", [])
		var current_system := str(unit.get("impulsor_system", "none"))
		for system: String in IMPULSOR_SYSTEMS:
			if system != "none" and IMPULSOR_SYSTEM_NAMES[system] not in offered_systems: continue
			if system == current_system: continue
			result.append({"label": "Impulsor %d: %s" % [model, IMPULSOR_SYSTEM_NAMES[system]], "action": "impulsor-loadout", "model": model, "target": 0, "value": system})
		var fragstorm := bool(unit.get("impulsor_fragstorm_launchers", false))
		result.append({"label": "Impulsor %d: %s" % [model, "restore Storm Bolters" if fragstorm else "replace Storm Bolters with Fragstorm Grenade Launchers"], "action": "impulsor-loadout", "model": model, "target": 1, "value": "off" if fragstorm else "on"})
		var stubber := bool(unit.get("impulsor_heavy_stubber", false))
		result.append({"label": "Impulsor %d: %s Ironhail Heavy Stubber" % [model, "remove" if stubber else "equip"], "action": "impulsor-loadout", "model": model, "target": 2, "value": "off" if stubber else "on"})
	return result

static func transport_weapon_loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		var identity_id := identity(unit)
		if int(unit.get("owner", -1)) != player or _is_impulsor_identity(identity_id): continue
		var data := MarineProfiles.profile(identity_id)
		var choices: Array = data.get("transport", {}).get("options", {}).get("add", [])
		var selected: Dictionary = unit.get("optional_transport_weapons", {})
		for weapon_name: String in choices:
			var weapon_id := _transport_weapon_id(data, weapon_name)
			if weapon_id.is_empty(): continue
			var equipped := bool(selected.get(weapon_id, false))
			result.append({"label": "%s %d: %s %s" % [data.name, model, "remove" if equipped else "add", weapon_name], "action": "transport-weapon-loadout", "model": model, "target": 0, "value": "%s:%s" % [weapon_id, "off" if equipped else "on"]})
		var replacements: Dictionary = data.get("transport", {}).get("options", {}).get("replacements", {})
		var selected_replacements: Dictionary = unit.get("optional_transport_replacements", {})
		for base_name: String in replacements:
			var base_id := _transport_weapon_id(data, base_name)
			var replacement_name: String = str(replacements[base_name])
			var replacement_id := _transport_weapon_id(data, replacement_name)
			if base_id.is_empty() or replacement_id.is_empty(): continue
			var current_id := str(selected_replacements.get(base_id, base_id))
			var next_id := base_id if current_id == replacement_id else replacement_id
			var next_name := base_name if next_id == base_id else replacement_name
			result.append({"label": "%s %d: replace %s with %s" % [data.name, model, replacement_name if current_id == replacement_id else base_name, next_name], "action": "transport-weapon-loadout", "model": model, "target": 1, "value": "replace:%s:%s" % [base_id, next_id]})
		var replacement_groups: Dictionary = data.get("transport", {}).get("options", {}).get("replacement_groups", {})
		var selected_groups: Dictionary = unit.get("optional_transport_replacement_groups", {})
		for group_id: String in replacement_groups:
			var group: Dictionary = replacement_groups[group_id]
			var equipped := bool(selected_groups.get(group_id, false))
			var verb := "restore" if equipped else "replace"
			result.append({"label": "%s %d: %s %s" % [data.name, model, verb, str(group.get("name", group_id))], "action": "transport-weapon-loadout", "model": model, "target": 2, "value": "group:%s:%s" % [group_id, "off" if equipped else "on"]})
	return result

static func configure_optional_transport_weapon(state: Dictionary, model: int, value: String) -> String:
	if state.phase != "deployment" or not is_transport(state, model) or _is_impulsor_identity(identity(state.units[model])): return "This transport wargear is selected during army preparations."
	var parts := value.split(":", false, 2)
	var profile_data := MarineProfiles.profile(identity(state.units[model]))
	if parts.size() == 3 and parts[0] == "group":
		var groups: Dictionary = profile_data.get("transport", {}).get("options", {}).get("replacement_groups", {})
		if not groups.has(parts[1]) or parts[2] not in ["on", "off"]: return "That grouped weapon replacement is not listed for this transport datasheet."
		var selected_groups: Dictionary = state.units[model].get("optional_transport_replacement_groups", {}).duplicate(true)
		selected_groups[parts[1]] = parts[2] == "on"
		state.units[model].optional_transport_replacement_groups = selected_groups
	elif parts.size() == 3 and parts[0] == "replace":
		var base_id: String = parts[1]
		var next_id: String = parts[2]
		var replacements: Dictionary = profile_data.get("transport", {}).get("options", {}).get("replacements", {})
		var base_name := ""
		var replacement_name := ""
		for candidate_name: String in replacements:
			if _transport_weapon_id(profile_data, candidate_name) == base_id:
				base_name = candidate_name
				replacement_name = str(replacements[candidate_name])
				break
		var replacement_id := _transport_weapon_id(profile_data, replacement_name)
		if base_name.is_empty() or replacement_id.is_empty() or next_id not in [base_id, replacement_id]: return "That weapon replacement is not listed for this transport datasheet."
		var selected_replacements: Dictionary = state.units[model].get("optional_transport_replacements", {}).duplicate(true)
		var current_id := str(selected_replacements.get(base_id, base_id))
		var current_name := base_name if current_id == base_id else replacement_name
		var next_name := base_name if next_id == base_id else replacement_name
		var costs: Dictionary = profile_data.get("wargear_costs", {})
		var delta := int(costs.get(next_name, 0)) - int(costs.get(current_name, 0))
		var current_points := int(state.get("training_points", {}).get(int(state.units[model].owner), 0))
		if delta > 0 and int(state.get("points_limit", 0)) > 0 and current_points + delta > int(state.points_limit): return "That weapon choice would put this army over its points limit."
		if delta != 0:
			if not state.has("training_points") or not state.get("training_points") is Dictionary: state.training_points = {}
			state.training_points[int(state.units[model].owner)] = maxi(0, current_points + delta)
		selected_replacements[base_id] = next_id
		state.units[model].optional_transport_replacements = selected_replacements
	elif parts.size() == 2 and parts[1] in ["on", "off"]:
		var weapon_id: String = parts[0]
		var allowed: Array = profile_data.get("transport", {}).get("options", {}).get("add", [])
		var weapon_name := ""
		for candidate: String in allowed:
			if _transport_weapon_id(profile_data, candidate) == weapon_id: weapon_name = candidate
		if weapon_name.is_empty(): return "That optional weapon is not listed for this transport datasheet."
		var selected: Dictionary = state.units[model].get("optional_transport_weapons", {}).duplicate(true)
		selected[weapon_id] = parts[1] == "on"
		state.units[model].optional_transport_weapons = selected
	else:
		return "Choose a source-listed optional weapon or replacement."
	state.units[model].ranged_weapons = _optional_transport_inventory(profile_data, state.units[model])
	return ""

static func _transport_weapon_id(profile_data: Dictionary, weapon_name: String) -> String:
	for weapon: Dictionary in profile_data.get("ranged", []) + profile_data.get("additional_weapon_profiles", {}).get("ranged", []):
		for weapon_profile: Dictionary in weapon.get("profiles", {}).values():
			if str(weapon_profile.get("name", "")).begins_with(weapon_name): return str(weapon.get("id", ""))
	return ""

static func _optional_transport_inventory(profile_data: Dictionary, unit: Dictionary) -> Array:
	var weapons: Array = profile_data.get("ranged", []).duplicate(true)
	var selected_groups: Dictionary = unit.get("optional_transport_replacement_groups", {})
	var groups: Dictionary = profile_data.get("transport", {}).get("options", {}).get("replacement_groups", {})
	for group_id: String in groups:
		if not bool(selected_groups.get(group_id, false)): continue
		var group: Dictionary = groups[group_id]
		var from_ids: Array = group.get("from_ids", [])
		var to_ids: Array = group.get("to_ids", [])
		if from_ids.is_empty() or to_ids.is_empty(): continue
		weapons = weapons.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) not in from_ids)
		for weapon_id: String in to_ids: _append_impulsor_weapon(weapons, profile_data, weapon_id)
	var selected_replacements: Dictionary = unit.get("optional_transport_replacements", {})
	var replacements: Dictionary = profile_data.get("transport", {}).get("options", {}).get("replacements", {})
	for base_name: String in replacements:
		var base_id := _transport_weapon_id(profile_data, base_name)
		var replacement_id := _transport_weapon_id(profile_data, str(replacements[base_name]))
		var active_id := str(selected_replacements.get(base_id, base_id))
		if base_id.is_empty() or replacement_id.is_empty() or active_id == base_id: continue
		weapons = weapons.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) != base_id)
		_append_impulsor_weapon(weapons, profile_data, active_id)
	var selected: Dictionary = unit.get("optional_transport_weapons", {})
	for weapon_name: String in profile_data.get("transport", {}).get("options", {}).get("add", []):
		var weapon_id := _transport_weapon_id(profile_data, weapon_name)
		if bool(selected.get(weapon_id, false)): _append_impulsor_weapon(weapons, profile_data, weapon_id)
	return weapons

static func configure_impulsor(state: Dictionary, model: int, category: int, value: String) -> String:
	if state.phase != "deployment" or not state.units.has(model) or not _is_impulsor_identity(identity(state.units[model])): return "Impulsor wargear is selected during army preparations."
	var unit: Dictionary = state.units[model]
	var profile_data := MarineProfiles.profile(identity(state.units[model]))
	if profile_data.is_empty(): return "The local Wahapedia Impulsor profile is missing."
	match category:
		0:
			if value not in IMPULSOR_SYSTEMS: return "Choose one source-listed Impulsor system or no optional system."
			var offered_systems: Array = profile_data.get("transport", {}).get("options", {}).get("one_of", [])
			if value != "none" and IMPULSOR_SYSTEM_NAMES.get(value, "") not in offered_systems: return "That array or Shield Dome is not listed for this Impulsor datasheet."
			var previous := str(unit.get("impulsor_system", "none"))
			var previous_cost := int(profile_data.get("wargear_costs", {}).get("Orbital Comms Array", 0)) if previous == "orbital-comms-array" else 0
			var next_cost := int(profile_data.get("wargear_costs", {}).get("Orbital Comms Array", 0)) if value == "orbital-comms-array" else 0
			var delta := next_cost - previous_cost
			if delta > 0:
				var current_points := int(state.get("training_points", {}).get(int(unit.owner), 0))
				if int(state.get("points_limit", 0)) > 0 and current_points + delta > int(state.points_limit): return "Orbital Comms Array would put this army over its points limit."
			if delta != 0:
				if not state.has("training_points") or not state.get("training_points") is Dictionary: state.training_points = {}
				state.training_points[int(unit.owner)] = maxi(0, int(state.training_points.get(int(unit.owner), 0)) + delta)
			unit.impulsor_system = value
		1:
			if value not in ["on", "off"]: return "Choose whether the Fragstorm Grenade Launchers replace the Storm Bolters."
			unit.impulsor_fragstorm_launchers = value == "on"
		2:
			if value not in ["on", "off"]: return "Choose whether to add the Ironhail Heavy Stubber."
			unit.impulsor_heavy_stubber = value == "on"
		_:
			return "Unsupported Impulsor wargear choice."
	var weapons: Array = profile_data.get("ranged", []).duplicate(true)
	if unit.get("impulsor_fragstorm_launchers", false):
		weapons = weapons.filter(func(weapon: Dictionary) -> bool: return weapon.get("id", "") != "storm-bolters")
		_append_impulsor_weapon(weapons, profile_data, "fragstorm-grenade-launchers")
	if unit.get("impulsor_system", "none") in ["bellicatus-missile-array", "ironhail-skytalon-array"]:
		_append_impulsor_weapon(weapons, profile_data, str(unit.impulsor_system))
	if unit.get("impulsor_heavy_stubber", false): _append_impulsor_weapon(weapons, profile_data, "ironhail-heavy-stubber")
	unit.ranged_weapons = weapons
	return ""

static func _append_impulsor_weapon(weapons: Array, profile_data: Dictionary, weapon_id: String) -> void:
	for weapon: Dictionary in profile_data.get("additional_weapon_profiles", {}).get("ranged", []):
		if str(weapon.get("id", "")) == weapon_id:
			weapons.append(weapon.duplicate(true))
			return

static func is_transport(state: Dictionary, model: int) -> bool:
	if not state.units.has(model): return false
	return not profile(state, model).is_empty() and "TRANSPORT" in state.units[model].get("keywords", [])

static func squad_embarked(state: Dictionary, squad: int) -> bool:
	for model: int in state.units:
		if state.units[model].squad == squad and int(state.units[model].get("embarked_transport", -1)) >= 0: return true
	return false

static func capacity_cost(state: Dictionary, squad: int, profile_data: Dictionary) -> int:
	var total := 0
	var double_space: Array = profile_data.get("double_space", [])
	for model: int in models(state, squad):
		if str(state.units[model].get("chaplain_grimaldus_role", "")) == "cenobyte": continue
		var keywords: Array = state.units[model].get("keywords", [])
		var doubled := false
		for keyword: String in double_space:
			if keyword in keywords: doubled = true
		if UnitAbilities.has(state, squad, "bestial-forms") and "WULFEN" in keywords: doubled = true
		total += 2 if doubled else 1
	return total

static func occupied_capacity(state: Dictionary, transport_model: int) -> int:
	var total := 0
	var data := profile(state, transport_model)
	if data.is_empty(): return 0
	var visited: Dictionary = {}
	for model: int in state.units:
		if int(state.units[model].get("embarked_transport", -1)) != transport_model: continue
		var squad: int = int(state.units[model].squad)
		if visited.has(squad) or models(state, squad).is_empty(): continue
		visited[squad] = true
		total += capacity_cost(state, squad, data)
	return total

static func eligibility_error(state: Dictionary, transport_model: int, passenger_squad: int, require_range: bool = false) -> String:
	if not is_transport(state, transport_model): return "Select a living transport with a source-recorded capacity."
	var transport: Dictionary = state.units[transport_model]
	if transport.wounds <= 0 or not transport.get("on_battlefield", true): return "The transport must be alive and on the battlefield."
	if not state.squads.has(passenger_squad): return "Select a complete friendly passenger unit."
	var passenger_models := models(state, passenger_squad)
	if passenger_models.is_empty(): return "The passenger unit has no living models."
	if int(state.squads[passenger_squad].owner) != int(transport.owner): return "A unit can embark only within a friendly transport."
	if int(state.squads[passenger_squad].owner) != int(state.squads[transport.squad].owner): return "A unit can embark only within a friendly transport."
	var data := profile(state, transport_model)
	if data.is_empty(): return "The transport's local profile is missing its transport record."
	if identity(transport) == "drop-pod" and bool(transport.get("drop_pod_deployment_complete", false)): return "Deployment Complete prevents units embarking in this Drop Pod."
	for model: int in passenger_models:
		var unit: Dictionary = state.units[model]
		if int(unit.get("embarked_transport", -1)) >= 0: return "The passenger unit is already embarked."
		for keyword: String in data.get("required", []):
			if keyword not in unit.get("keywords", []): return "This transport can carry only models with %s." % keyword
		for keyword: String in data.get("forbidden", []):
			if keyword in unit.get("keywords", []): return "This transport cannot carry %s models." % keyword
	if int(data.get("capacity", 0)) - occupied_capacity(state, transport_model) < capacity_cost(state, passenger_squad, data): return "The transport does not have enough remaining capacity for the whole unit."
	if require_range:
		for model: int in passenger_models:
			if not state.units[model].get("on_battlefield", true): return "Each passenger model must be on the battlefield to embark during the battle."
			if Geometry.edge(state.units[model], transport) > 3.001: return "Every passenger model must be within 3 inches of the transport."
	return ""

static func _set_embarked(state: Dictionary, passenger_squad: int, transport_model: int) -> void:
	for model: int in models(state, passenger_squad):
		state.units[model].on_battlefield = false
		state.units[model].embarked_transport = transport_model
	state.squads[passenger_squad].embarked_in = transport_model
	state.squads[passenger_squad].embarked_this_turn = int(state.turn) if state.phase == "movement" else -1

static func gauntlet_duty_error(state: Dictionary, player: int, passenger_squad: int, transport_model: int, require_end_window: bool = true) -> String:
	var stratagem_error := DetachmentStratagems.error(state, player, passenger_squad, DetachmentStratagems.GAUNTLET_DUTY_IS_NEVER_DONE, transport_model, -1, -1, -1, require_end_window)
	if not stratagem_error.is_empty(): return stratagem_error
	var transport_error := eligibility_error(state, transport_model, passenger_squad, false)
	if not transport_error.is_empty(): return transport_error
	var transport_squad := int(state.units[transport_model].get("squad", -1))
	for model: int in models(state, passenger_squad):
		if not state.units[model].get("on_battlefield", true): return "Every model in the passenger unit must be on the battlefield."
		if Geometry.distance_to_target(state, state.units[model], transport_squad) > 6.001: return "Every passenger model must be within 6 inches of the Transport."
	return ""

static func gauntlet_duty_candidates(state: Dictionary, player: int, require_end_window: bool = true) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for passenger_squad: int in state.squads:
		if not state.squads.has(passenger_squad) or int(state.squads[passenger_squad].get("owner", -1)) != player: continue
		for transport_model: int in state.units:
			if int(state.units[transport_model].get("owner", -1)) != player: continue
			if not gauntlet_duty_error(state, player, passenger_squad, transport_model, require_end_window).is_empty(): continue
			var cost := DetachmentStratagems.gauntlet_duty_cost(state, player, passenger_squad)
			result.append({"label": "Duty is Never Done: embark %s in %s (%d CP)" % [str(state.squads[passenger_squad].get("name", "Infantry unit")), str(state.squads[int(state.units[transport_model].squad)].get("name", "Transport")), cost], "action": "detachment-stratagem", "model": transport_model, "target": passenger_squad, "value": DetachmentStratagems.GAUNTLET_DUTY_IS_NEVER_DONE})
	return result

static func resolve_gauntlet_duty_embark(state: Dictionary, passenger_squad: int, transport_model: int) -> void:
	## Call only after gauntlet_duty_error succeeds and the stratagem has been applied.
	_set_embarked(state, passenger_squad, transport_model)

static func embark_error(state: Dictionary, player: int, transport_model: int, passenger_squad: int) -> String:
	if state.phase != "movement" or int(state.active) != player: return "Embark after a move in your Movement phase."
	if not state.squads.has(passenger_squad) or int(state.squads[passenger_squad].owner) != player: return "Choose your own passenger unit."
	if int(state.squads[passenger_squad].get("cannot_embark_until_turn", -1)) == int(state.turn): return "This unit cannot embark in a Transport until the end of the turn."
	if not state.squads[passenger_squad].get("moved", false) or state.squads[passenger_squad].get("move_type", "") not in ["normal", "advance", "ordered_retreat", "desperate_escape"]: return "A passenger unit can embark only after making a Normal, Advance or Fall Back move."
	if state.squads[passenger_squad].get("set_up_this_turn", false): return "A unit set up on the battlefield this turn cannot embark."
	return eligibility_error(state, transport_model, passenger_squad, true)

static func embark(state: Dictionary, player: int, transport_model: int, passenger_squad: int) -> String:
	var error := embark_error(state, player, transport_model, passenger_squad)
	if not error.is_empty(): return error
	_set_embarked(state, passenger_squad, transport_model)
	return ""

static func start_embark_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	for squad: int in state.squads:
		if int(state.squads[squad].owner) != player or models(state, squad).is_empty(): continue
		if int(state.squads[squad].get("cannot_embark_until_turn", -1)) == int(state.turn): continue
		for model: int in state.units:
			if int(state.units[model].owner) != player or not is_transport(state, model) or int(state.units[model].wounds) <= 0 or not state.units[model].get("on_battlefield", true): continue
			if not eligibility_error(state, model, squad).is_empty(): continue
			choices.append({"label": "Start %s embarked in %s" % [state.squads[squad].name, state.squads[state.units[model].squad].name], "action": "transport-embark-start", "model": models(state, squad)[0], "target": model, "value": ""})
	return choices

static func start_embark(state: Dictionary, player: int, transport_model: int, passenger_squad: int) -> String:
	if state.phase != "deployment": return "Starting embarked units is selected in army preparations before deployment."
	var error := eligibility_error(state, transport_model, passenger_squad)
	if not error.is_empty(): return error
	_set_embarked(state, passenger_squad, transport_model)
	return ""

static func _has_ability(state: Dictionary, transport_model: int, ability_name: String) -> bool:
	for ability: Dictionary in profile(state, transport_model).get("abilities", []):
		if str(ability.get("name", "")) == ability_name: return true
	return false

static func _passengers(state: Dictionary, transport_model: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("embarked_transport", -1)) != transport_model: continue
		var squad := int(state.units[model].squad)
		if squad not in result and not models(state, squad).is_empty(): result.append(squad)
	return result

static func _drop_pod_action_id(state: Dictionary, transport_model: int, player: int) -> String:
	return "drop-pod-assault:%d:%d:%d:%d" % [int(state.get("turn", 0)), transport_model, player, int(state.get("revision", -1))]

static func _mark_drop_pod_disembark_window(window: Dictionary, transport_model: int, player: int, remaining: Array[int], frame_id: String, parent_frame_id: String) -> void:
	window.mandatory_drop_pod = true
	window.drop_pod_assault = true
	window.drop_pod_transport = transport_model
	window.drop_pod_player = player
	window.drop_pod_remaining = remaining.duplicate()
	window.resolution_frame_id = frame_id
	window.parent_frame_id = parent_frame_id

static func _offer_drop_pod_aggressive_choice(state: Dictionary, transport_model: int, player: int) -> bool:
	var window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
	if window.get("kind", "") != "disembark" or not window.get("mandatory_drop_pod", false) or not window.get("drop_pod_assault", false): return false
	var passenger_squad := int(window.get("passenger_squad", -1))
	var previous_stage := str(window.get("stage", "placement"))
	window.stage = "aggressive-choice"
	if not gauntlet_aggressive_disembarkation_error(state, player, transport_model, passenger_squad, str(window.get("mode", ""))).is_empty():
		window.stage = previous_stage
		return false
	_set_window_actor(state, player, DISEMBARK_WINDOW)
	return true

static func _finish_drop_pod_passenger(state: Dictionary, window: Dictionary, roller: Callable) -> String:
	var transport_model := int(window.get("drop_pod_transport", -1))
	var frame_id := str(window.get("resolution_frame_id", ""))
	var parent_frame_id := str(window.get("parent_frame_id", ""))
	var frame := ResolutionFrames.current(state)
	if frame_id.is_empty() or str(frame.get("frame_id", "")) != frame_id or str(frame.get("kind", "")) != "transport-drop-pod-assault":
		return "The Drop Pod Assault continuation is missing."
	var remaining: Array = window.get("drop_pod_remaining", []).duplicate()
	if remaining.is_empty() and not parent_frame_id.is_empty():
		var raw_frames: Variant = state.get("resolution_frames", [])
		if typeof(raw_frames) != TYPE_ARRAY: return "The ingress continuation beneath Drop Pod Assault is missing."
		var frames: Array = raw_frames
		if frames.size() < 2 or typeof(frames[frames.size() - 2]) != TYPE_DICTIONARY: return "The ingress continuation beneath Drop Pod Assault is missing."
		var parent_frame: Dictionary = frames[frames.size() - 2]
		if str(parent_frame.get("frame_id", "")) != parent_frame_id:
			return "The ingress continuation beneath Drop Pod Assault is missing."
	state.unit_abilities.transport_window = {}
	state.unit_abilities.window = {}
	if remaining.is_empty():
		var frame_error := ResolutionFrames.complete(state, frame_id)
		if not frame_error.is_empty(): return frame_error
		if not parent_frame_id.is_empty():
			var parent_frame := ResolutionFrames.current(state)
			if str(parent_frame.get("frame_id", "")) != parent_frame_id: return "The ingress continuation beneath Drop Pod Assault is missing."
			var parent_error := ResolutionFrames.complete(state, parent_frame_id)
			if not parent_error.is_empty(): return parent_error
		if state.units.has(transport_model): state.units[transport_model].drop_pod_deployment_complete = true
		return ""
	var next_squad := int(remaining.pop_front())
	var player := int(window.get("drop_pod_player", state.active))
	var error := begin_disembark(state, player, transport_model, next_squad, "rapid", roller, true)
	if not error.is_empty(): return error
	_mark_drop_pod_disembark_window(state.unit_abilities.transport_window, transport_model, player, remaining, frame_id, parent_frame_id)
	_offer_drop_pod_aggressive_choice(state, transport_model, player)
	return ""

static func begin_drop_pod_arrival(state: Dictionary, player: int, transport_model: int, roller: Callable) -> String:
	if not is_transport(state, transport_model) or identity(state.units[transport_model]) != "drop-pod" or not state.units[transport_model].get("on_battlefield", false): return "Drop Pod Assault requires a Drop Pod just set up on the battlefield."
	var passenger_squads := _passengers(state, transport_model)
	if passenger_squads.is_empty():
		state.units[transport_model].drop_pod_deployment_complete = true
		return ""
	var first_squad: int = passenger_squads.pop_front()
	var error := begin_disembark(state, player, transport_model, first_squad, "rapid", roller, true)
	if not error.is_empty(): return error
	var parent_frame_id := ""
	var parent_frame := ResolutionFrames.current(state)
	if str(parent_frame.get("kind", "")) == "unit-action" and str(parent_frame.get("action_id", "")).begins_with("ingress:"):
		parent_frame_id = str(parent_frame.get("frame_id", ""))
	var frame := ResolutionFrames.begin(state, "transport-drop-pod-assault", _drop_pod_action_id(state, transport_model, player), "drop-pod-passenger-disembark")
	if frame.is_empty():
		state.unit_abilities.transport_window = {}
		state.unit_abilities.window = {}
		return "Could not open the Drop Pod Assault continuation frame."
	var frame_id := str(frame.get("frame_id", ""))
	var suspend_error := ResolutionFrames.suspend(state, frame_id, "drop-pod-passenger-disembark")
	if not suspend_error.is_empty():
		ResolutionFrames.complete(state, frame_id)
		state.unit_abilities.transport_window = {}
		state.unit_abilities.window = {}
		return suspend_error
	_mark_drop_pod_disembark_window(state.unit_abilities.transport_window, transport_model, player, passenger_squads, frame_id, parent_frame_id)
	_offer_drop_pod_aggressive_choice(state, transport_model, player)
	return ""

static func passengers_of_destroyed(state: Dictionary, destroyed_models: Array[int]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for transport_model: int in destroyed_models:
		if not is_transport(state, transport_model): continue
		for passenger_squad: int in _passengers(state, transport_model):
			result.append({"transport": transport_model, "passenger_squad": passenger_squad})
	return result

static func _set_window_actor(state: Dictionary, player: int, kind: String = EMERGENCY_WINDOW) -> void:
	state.unit_abilities.window = {"kind": kind, "owners": [player]}

static func _offer_transport_hazard_reroll(state: Dictionary, window: Dictionary, player: int) -> bool:
	var rolls: Array = window.get("hazard_rolls", [])
	if rolls.is_empty() or not state.get("stratagems", {}).get("hazard_rerolls", false) or not Stratagems.pending(state).is_empty(): return false
	if not Stratagems.eligibility_error(state, player, int(window.passenger_squad), "command-re-roll").is_empty(): return false
	var eligible: Array[int] = []
	for index in range(rolls.size()): eligible.append(index)
	state.stratagems.pending = {"kind": "after_transport_hazard_roll", "player": player,
		"squad": int(window.passenger_squad), "phase_key": Stratagems.phase_key(state),
		"rolls": rolls.duplicate(), "eligible": eligible}
	state.unit_abilities.transport_window.stage = "hazard-reroll"
	state.unit_abilities.transport_window.player = player
	_set_window_actor(state, player, EMERGENCY_WINDOW if window.get("kind", "") == "emergency" else DISEMBARK_WINDOW)
	return true

static func _emergency_finish(state: Dictionary, window: Dictionary) -> void:
	var passenger_squad := int(window.passenger_squad)
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) != passenger_squad: continue
		state.units[model].on_battlefield = false
		state.units[model].erase("embarked_transport")
	state.squads[passenger_squad].erase("embarked_in")
	state.squads[passenger_squad].erase("embarked_this_turn")
	state.unit_abilities.transport_window = {}
	state.unit_abilities.window = {}

static func _roll_emergency_hazard(state: Dictionary, window: Dictionary, roller: Callable) -> String:
	var passenger_squad := int(window.passenger_squad)
	var passenger_models: Array[int] = window.get("models", [])
	var rolls: Array[int] = []
	for _model: int in passenger_models:
		if not roller.is_valid(): return "Emergency Disembark requires one Hazard D6 per passenger model."
		var die: Variant = roller.call()
		if not die is int or die < 1 or die > 6: return "Hazard dice must be integers from 1 to 6."
		rolls.append(die)
	var hazard := Hazardous.from_rolls(state, passenger_squad, rolls)
	if not hazard.error.is_empty(): return hazard.error
	var hazard_total := int(hazard.total)
	var owner := int(state.squads[passenger_squad].owner)
	var current_player := int(window.get("active_player", state.active))
	window.hazard_rolls = rolls
	window.hazard_total = hazard_total
	window.hazard_remaining = hazard_total
	window.hazard_allocations = []
	window.stage = "hazard" if hazard_total > 0 else "placement"
	window.player = owner if hazard_total > 0 else current_player
	state.unit_abilities.transport_window = window
	_set_window_actor(state, int(window.player))
	if not passenger_models.is_empty(): _offer_transport_hazard_reroll(state, window, owner)
	if passenger_models.is_empty(): _emergency_finish(state, window)
	return ""

static func begin_emergency(state: Dictionary, transport_model: int, passenger_squad: int, roller: Callable) -> String:
	if not is_transport(state, transport_model) or passenger_squad not in _passengers(state, transport_model): return "The passenger unit is not embarked in this destroyed transport."
	var passenger_models := models(state, passenger_squad)
	var owner := int(state.squads[passenger_squad].owner)
	var current_player := int(state.active)
	var window := {"kind": "emergency", "transport": transport_model, "passenger_squad": passenger_squad,
		"models": passenger_models, "placements": {}, "mode": "emergency", "stage": "aggressive-choice",
		"hazard_rolls": [], "hazard_total": 0, "hazard_remaining": 0, "hazard_allocations": [], "player": owner,
		"active_player": current_player, "destroyed_turn": int(state.turn)}
	var working: Dictionary = state.duplicate(true)
	working.unit_abilities.transport_window = window
	_set_window_actor(working, owner)
	if not passenger_models.is_empty() and gauntlet_aggressive_disembarkation_error(working, owner, transport_model, passenger_squad, "emergency").is_empty():
		state.clear()
		state.merge(working, true)
		return ""
	var roll_error := _roll_emergency_hazard(working, working.unit_abilities.transport_window, roller)
	if not roll_error.is_empty(): return roll_error
	state.clear()
	state.merge(working, true)
	return ""

static func _move_modes(state: Dictionary, transport_model: int, passenger_squad: int, aggressive_disembarkation: bool = false) -> Array[String]:
	var result: Array[String] = []
	var transport_squad := int(state.units[transport_model].squad)
	var move_type := str(state.squads[transport_squad].get("move_type", "unselected"))
	var embarked_turn := int(state.squads[passenger_squad].get("embarked_this_turn", -1))
	if embarked_turn == int(state.turn): return result
	if move_type in ["stationary", "unselected"]:
		result.append("tactical" if _tactical_setup_possible(state, transport_model, passenger_squad, aggressive_disembarkation) else "combat")
	elif move_type in ["normal", "ingress"]:
		result.append("rapid")
		if move_type == "normal" and _has_ability(state, transport_model, "Assault Ramp"): result.append("assault")
	elif move_type == "advance" and _has_ability(state, transport_model, "Rapid Disembarkation"):
		result.append("shock")
	return result

static func disembark_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state.phase != "movement" or int(state.active) != player: return result
	for transport_model: int in state.units:
		if not is_transport(state, transport_model) or int(state.units[transport_model].owner) != player or int(state.units[transport_model].wounds) <= 0 or not state.units[transport_model].get("on_battlefield", true): continue
		var transport_squad := int(state.units[transport_model].squad)
		var move_type := str(state.squads[transport_squad].get("move_type", "unselected"))
		if move_type in ["ordered_retreat", "desperate_escape", "failed_fall_back"]: continue
		for passenger_squad: int in _passengers(state, transport_model):
			var modes := _move_modes(state, transport_model, passenger_squad)
			for mode: String in modes:
				var label := "Disembark %s from %s (%s)" % [state.squads[passenger_squad].name, state.squads[transport_squad].name, mode]
				result.append({"label": label, "action": "transport-disembark-start", "model": transport_model, "target": passenger_squad, "value": mode})
			if not DetachmentStratagems.error(state, player, passenger_squad, DetachmentStratagems.GAUNTLET_AGGRESSIVE_DISEMBARKATION, transport_model).is_empty(): continue
			var aggressive_modes := _move_modes(state, transport_model, passenger_squad, true)
			for mode: String in aggressive_modes:
				if not gauntlet_aggressive_disembarkation_error(state, player, transport_model, passenger_squad, mode).is_empty(): continue
				var cost := DetachmentStratagems.gauntlet_aggressive_disembarkation_cost(state, player, passenger_squad)
				var aggressive_label := "Aggressive Disembarkation: %s from %s (%s, %d CP)" % [state.squads[passenger_squad].name, state.squads[transport_squad].name, mode, cost]
				result.append({"label": aggressive_label, "action": "transport-disembark-start-aggressive", "model": transport_model, "target": passenger_squad, "value": mode})
	return result

static func gauntlet_aggressive_disembarkation_error(state: Dictionary, player: int, transport_model: int, passenger_squad: int, mode: String) -> String:
	var stratagem_error := DetachmentStratagems.error(state, player, passenger_squad, DetachmentStratagems.GAUNTLET_AGGRESSIVE_DISEMBARKATION, transport_model)
	if not stratagem_error.is_empty(): return stratagem_error
	var emergency: bool = mode == "emergency"
	var window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
	var drop_pod_context: bool = not emergency and window.get("kind", "") == "disembark" and window.get("stage", "") == "aggressive-choice" and bool(window.get("mandatory_drop_pod", false)) and bool(window.get("drop_pod_assault", false))
	if emergency:
		if window.get("kind", "") != "emergency" or window.get("stage", "") != "aggressive-choice" or int(window.get("player", -1)) != player or int(window.get("transport", -1)) != transport_model or int(window.get("passenger_squad", -1)) != passenger_squad: return "Aggressive Disembarkation requires the current Emergency Disembark move selection."
	elif drop_pod_context:
		if int(window.get("player", -1)) != player or int(window.get("drop_pod_player", -1)) != player or int(window.get("transport", -1)) != transport_model or int(window.get("drop_pod_transport", -1)) != transport_model or int(window.get("passenger_squad", -1)) != passenger_squad: return "Aggressive Disembarkation requires the current Drop Pod passenger move."
		if mode != "rapid" or str(window.get("mode", "")) != "rapid": return "Drop Pod Assault passengers must use Rapid Disembark."
	else:
		if state.phase != "movement" or int(state.active) != player: return "Aggressive Disembarkation currently uses the supported Movement-phase disembark flow."
		if not state.get("pending_move", {}).is_empty() or not state.get("pending_contact", {}).is_empty(): return "Finish the current model movement before disembarking."
	if not is_transport(state, transport_model) or int(state.units[transport_model].get("owner", -1)) != player or not state.units[transport_model].get("on_battlefield", true): return "Select your Transport on the battlefield."
	if drop_pod_context and identity(state.units[transport_model]) != "drop-pod": return "Drop Pod Assault requires a Drop Pod transport."
	var transport_wounds := int(state.units[transport_model].get("wounds", 0))
	if emergency and transport_wounds > 0: return "Emergency Disembark requires the Transport that was just destroyed."
	if not emergency and transport_wounds <= 0: return "Select your living Transport on the battlefield."
	if passenger_squad not in _passengers(state, transport_model): return "The selected unit is not embarked within this Transport."
	for model: int in models(state, passenger_squad):
		if "ADEPTUS ASTARTES" not in state.units[model].get("keywords", []): return "Aggressive Disembarkation requires a friendly ADEPTUS ASTARTES unit."
	if not emergency and mode not in _move_modes(state, transport_model, passenger_squad, true): return "That disembark mode is not available for Aggressive Disembarkation."
	return ""

static func _tactical_candidates(state: Dictionary, transport_model: int, model: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var transport: Dictionary = state.units[transport_model]
	var lower := float(transport.radius) + float(state.units[model].radius)
	var radius := lower
	while radius <= lower + 3.001:
		for degrees in range(0, 360, 5):
			var angle := deg_to_rad(float(degrees))
			result.append(transport.position + Vector2(cos(angle), sin(angle)) * radius)
		radius += 0.1
	return result

static func _tactical_setup_search(state: Dictionary, window: Dictionary, model_ids: Array[int], candidates: Array, index: int, placements: Dictionary, budget: Array[int]) -> bool:
	if index >= model_ids.size(): return true
	var model := model_ids[index]
	for position: Vector2 in candidates[index]:
		budget[0] = int(budget[0]) - 1
		# If the bounded search cannot prove Tactical placement impossible, keep Tactical mandatory.
		if int(budget[0]) < 0: return true
		if not _position_error(state, window, model, position).is_empty(): continue
		if not placements.is_empty():
			var connected := false
			var exceeds_unit_coherency := false
			for other: int in placements:
				var edge_distance := maxf(0.0, position.distance_to(placements[other]) - float(state.units[model].radius) - float(state.units[other].radius))
				if edge_distance > 9.001: exceeds_unit_coherency = true
				if edge_distance <= 2.001: connected = true
			if not connected or exceeds_unit_coherency: continue
		placements[model] = position
		window.placements = placements
		if _tactical_setup_search(state, window, model_ids, candidates, index + 1, placements, budget): return true
		placements.erase(model)
		window.placements = placements
	return false

static func _tactical_setup_possible(state: Dictionary, transport_model: int, passenger_squad: int, aggressive_disembarkation: bool = false) -> bool:
	var model_ids := models(state, passenger_squad)
	if model_ids.is_empty(): return false
	var candidates: Array = []
	for model: int in model_ids: candidates.append(_tactical_candidates(state, transport_model, model))
	var window := {"transport": transport_model, "passenger_squad": passenger_squad, "mode": "tactical", "placements": {}, "aggressive_disembarkation": aggressive_disembarkation}
	return _tactical_setup_search(state, window, model_ids, candidates, 0, {}, [12000])

static func _position_error(state: Dictionary, window: Dictionary, model: int, position: Vector2) -> String:
	if not position.is_finite(): return "Choose a valid model position."
	var transport_model := int(window.transport)
	var mode := str(window.mode)
	var placement_elevation := float(state.units[transport_model].get("elevation", 0.0)) if state.units.has(transport_model) else 0.0
	var distance_limit := 6.0 if mode in ["combat", "emergency"] else 3.0
	if not state.units.has(transport_model) or not state.units[transport_model].get("on_battlefield", true): return "The transport must remain on the battlefield during disembarkation."
	var placed_base := {"position": position, "radius": float(state.units[model].radius)}
	var distance_to_transport := Geometry.edge(placed_base, state.units[transport_model])
	if bool(window.get("aggressive_disembarkation", false)):
		if distance_to_transport > distance_limit + 0.001: return "Set each model within %.0f inches of the transport." % distance_limit
	else:
		var farthest_base_edge := maxf(0.0, position.distance_to(state.units[transport_model].position) + float(state.units[model].radius) - float(state.units[transport_model].radius))
		if farthest_base_edge > distance_limit + 0.001: return "Set each model wholly within %.0f inches of the transport." % distance_limit
	if window.get("drop_pod_assault", false):
		for enemy: int in state.units:
			var enemy_model: Dictionary = state.units[enemy]
			if enemy_model.get("wounds", 0) <= 0 or not enemy_model.get("on_battlefield", true) or int(enemy_model.get("owner", -1)) == int(state.units[model].owner): continue
			if Geometry.edge({"position": position, "radius": state.units[model].radius}, enemy_model) <= 8.001: return "Drop Pod Assault passengers must be set up more than 8 inches from every enemy unit."
	if absf(position.x) + float(state.units[model].radius) > state.board_size.x / 2.0 + 0.001 or absf(position.y) + float(state.units[model].radius) > state.board_size.y / 2.0 + 0.001: return "The whole model must fit on the battlefield."
	var positioned_model: Dictionary = state.units[model].duplicate(true)
	positioned_model.position = position
	positioned_model.elevation = placement_elevation
	for area: Dictionary in Terrain.areas(state):
		for feature: Dictionary in area.get("features", []):
			if feature.get("blocks_end", false) and Terrain.within(positioned_model, feature.bounds): return "A disembarking model cannot be placed inside a terrain wall or barricade."
	for other: int in state.units:
		if other == model or int(state.units[other].wounds) <= 0 or not state.units[other].get("on_battlefield", true): continue
		if other == transport_model: continue
		if absf(placement_elevation - float(state.units[other].get("elevation", 0.0))) <= 0.001 and position.distance_to(state.units[other].position) < float(state.units[model].radius) + float(state.units[other].radius) - 0.001: return "Disembarking bases cannot overlap."
		if int(state.units[other].owner) == int(state.units[model].owner): continue
		var placed: Dictionary = state.units[model].duplicate(true)
		placed.position = position
		placed.elevation = placement_elevation
		if Geometry.within_engagement(placed, state.units[other]):
			var emergency_engaged_allowed: bool = mode == "emergency" and bool(window.get("allow_engaged", false))
			if mode != "combat" and not emergency_engaged_allowed or (mode == "combat" and not _transport_engaged_squads(state, transport_model).has(int(state.units[other].squad))):
				return "A disembarking unit must be set up unengaged; Combat Disembark only permits enemies engaged with the transport."
	for placed_model: int in window.placements:
		if placed_model == model: continue
		if position.distance_to(window.placements[placed_model]) < float(state.units[model].radius) + float(state.units[placed_model].radius) - 0.001: return "Disembarking bases cannot overlap."
	return ""

static func _transport_engaged_squads(state: Dictionary, transport_model: int) -> Array[int]:
	var result: Array[int] = []
	if not state.units.has(transport_model): return result
	var transport: Dictionary = state.units[transport_model]
	for enemy: int in state.units:
		var unit: Dictionary = state.units[enemy]
		if int(unit.get("wounds", 0)) <= 0 or not unit.get("on_battlefield", true) or int(unit.get("owner", -1)) == int(transport.get("owner", -1)): continue
		if Geometry.within_engagement(transport, unit) and int(unit.squad) not in result: result.append(int(unit.squad))
	return result

static func _nearest_emergency_edge(state: Dictionary, window: Dictionary, model: int) -> float:
	var transport_model := int(window.transport)
	if not state.units.has(transport_model): return INF
	var transport: Dictionary = state.units[transport_model]
	var lower := float(transport.radius) + float(state.units[model].radius)
	var upper := lower + 6.0
	var radius := lower
	while radius <= upper + 0.001:
		for degrees in range(0, 360, 5):
			var angle := deg_to_rad(float(degrees))
			var candidate: Vector2 = transport.position + Vector2(cos(angle), sin(angle)) * radius
			if _position_error(state, window, model, candidate).is_empty(): return maxf(0.0, radius - lower)
		radius += 0.1
	return INF

static func _nearest_emergency_engaged_edge(state: Dictionary, window: Dictionary, model: int) -> float:
	var transport_model := int(window.transport)
	if not state.units.has(transport_model): return INF
	var transport: Dictionary = state.units[transport_model]
	var engaged_window: Dictionary = window.duplicate(true)
	engaged_window.allow_engaged = true
	var lower := float(transport.radius) + float(state.units[model].radius)
	var upper := lower + 6.0
	var radius := lower
	while radius <= upper + 0.001:
		for degrees in range(0, 360, 5):
			var angle := deg_to_rad(float(degrees))
			var candidate: Vector2 = transport.position + Vector2(cos(angle), sin(angle)) * radius
			if _position_error(state, engaged_window, model, candidate).is_empty(): return maxf(0.0, radius - lower)
		radius += 0.1
	return INF

static func _coherent_preview(state: Dictionary, window: Dictionary) -> bool:
	var passenger_squad := int(window.passenger_squad)
	var ids := models(state, passenger_squad)
	if ids.size() <= 1: return true
	var positions: Dictionary = window.placements
	for id: int in ids:
		var neighbor := false
		for other: int in ids:
			if id == other: continue
			var a: Vector2 = positions[id]
			var b: Vector2 = positions[other]
			var edge_distance: float = maxf(0.0, a.distance_to(b) - float(state.units[id].radius) - float(state.units[other].radius))
			if edge_distance > 9.001: return false
			if edge_distance <= 2.001: neighbor = true
		if not neighbor: return false
	var reached: Dictionary = {ids[0]: true}
	var frontier: Array[int] = [ids[0]]
	while not frontier.is_empty():
		var current: int = frontier.pop_back()
		for other: int in ids:
			if reached.has(other): continue
			var edge_distance: float = maxf(0.0, positions[current].distance_to(positions[other]) - float(state.units[current].radius) - float(state.units[other].radius))
			if edge_distance <= 2.001:
				reached[other] = true
				frontier.append(other)
	return reached.size() == ids.size()

static func choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
	if window.is_empty(): return disembark_choices(state, player)
	if int(window.player) != player: return []
	var result: Array[Dictionary] = []
	if window.get("stage", "") == "hazard-reroll": return result
	if window.get("stage", "") == "aggressive-choice":
		var emergency: bool = window.get("kind", "") == "emergency"
		var drop_pod: bool = window.get("kind", "") == "disembark" and bool(window.get("mandatory_drop_pod", false)) and bool(window.get("drop_pod_assault", false))
		if not emergency and not drop_pod: return result
		var transport_model := int(window.get("transport", -1))
		var passenger_squad := int(window.get("passenger_squad", -1))
		var mode := str(window.get("mode", ""))
		var action_prefix := "transport-emergency-aggressive" if emergency else "transport-disembark-aggressive"
		var normal_move_name := "Emergency Disembark" if emergency else "Drop Pod Assault Rapid Disembark"
		var normal_move_details := "; roll Hazard, then set up wholly within 6 inches and as close as possible" if emergency else ": set up each model wholly within 3 inches of the Drop Pod and more than 8 inches from every enemy unit"
		if gauntlet_aggressive_disembarkation_error(state, player, transport_model, passenger_squad, mode).is_empty():
			var cost := DetachmentStratagems.gauntlet_aggressive_disembarkation_cost(state, player, passenger_squad)
			var setup_distance := 6 if emergency else 3
			var aggressive_restriction := " and more than 8 inches from every enemy unit" if drop_pod else ""
			result.append({"label": "Aggressive Disembarkation (%d CP): set up within %d inches%s%s" % [cost, setup_distance, ", still as close as possible" if emergency else "", aggressive_restriction], "action": action_prefix + "-use", "model": transport_model, "target": passenger_squad, "value": ""})
		result.append({"label": "%s normally%s" % [normal_move_name, normal_move_details], "action": action_prefix + "-pass", "model": transport_model, "target": passenger_squad, "value": ""})
		return result
	if window.get("stage", "") == "hazard":
		for model: int in _emergency_mortal_candidates(state, window):
			var label := "Emergency Disembark" if window.get("kind", "") == "emergency" else "Disembark"
			result.append({"label": "%s: allocate 1 mortal wound to model %d (%d remaining)" % [label, model, int(window.hazard_remaining)], "action": "transport-disembark-hazard-allocate", "model": model, "target": int(window.passenger_squad), "value": ""})
		return result
	for model: int in window.models:
		if window.placements.has(model): continue
		var distance := 6 if window.mode in ["combat", "emergency"] else 3
		var setup_range_phrase := "within" if window.get("aggressive_disembarkation", false) else "wholly within"
		if window.get("kind", "") == "emergency" and is_inf(_nearest_emergency_edge(state, window, model)):
			if not is_inf(_nearest_emergency_engaged_edge(state, window, model)):
				result.append({"label": "Emergency Disembark: place model %d engaged (no unengaged position is possible)" % model, "action": "transport-disembark-place", "model": model, "target": int(window.passenger_squad), "value": "engaged"})
			else:
				result.append({"label": "Emergency Disembark: model %d cannot be set up and is destroyed" % model, "action": "transport-emergency-unplaceable", "model": model, "target": int(window.passenger_squad), "value": ""})
		else:
			var move_name := "Emergency Disembark" if window.get("kind", "") == "emergency" else "Disembark"
			result.append({"label": "%s: place model %d %s %d inches" % [move_name, model, setup_range_phrase, distance], "action": "transport-disembark-place", "model": model, "target": int(window.passenger_squad), "value": ""})
	if not result.is_empty(): return result
	result.append({"label": "Confirm disembarkation" if confirm_error(state).is_empty() else "Finish disembarkation positions", "action": "transport-disembark-confirm", "model": -1, "target": int(window.passenger_squad), "value": ""})
	result.append({"label": "Reset disembarkation positions", "action": "transport-disembark-reset", "model": -1, "target": int(window.passenger_squad), "value": ""})
	return result

static func begin_disembark(state: Dictionary, player: int, transport_model: int, passenger_squad: int, mode: String, roller: Callable = Callable(), drop_pod_assault: bool = false, aggressive_disembarkation: bool = false) -> String:
	var forced_drop_pod := drop_pod_assault and is_transport(state, transport_model) and identity(state.units[transport_model]) == "drop-pod" and int(state.units[transport_model].owner) == player
	if not forced_drop_pod and (state.phase != "movement" or int(state.active) != player): return "Disembark only in your Movement phase."
	if not state.get("pending_move", {}).is_empty() or not state.get("pending_contact", {}).is_empty(): return "Finish the current model movement before disembarking."
	if not is_transport(state, transport_model) or int(state.units[transport_model].owner) != player or not state.units[transport_model].get("on_battlefield", true): return "Select your living transport on the battlefield."
	if passenger_squad not in _passengers(state, transport_model): return "The selected unit is not embarked within this transport."
	if mode not in _move_modes(state, transport_model, passenger_squad, aggressive_disembarkation): return "That disembark mode is not available for the transport's movement this phase."
	var transport_squad := int(state.units[transport_model].squad)
	var move_type := str(state.squads[transport_squad].get("move_type", "unselected"))
	if move_type in ["ordered_retreat", "desperate_escape", "failed_fall_back"]: return "A transport that Fell Back cannot make this disembark move."
	if move_type == "advance" and mode != "shock": return "A transport that Advanced can disembark only with a source-listed Shock Disembark ability."
	var passenger_models := models(state, passenger_squad)
	var hazard: Dictionary = {"error": "", "rolls": [], "failures": 0, "total": 0}
	if mode == "combat": hazard = Hazardous.roll(state, passenger_squad, passenger_models.size(), roller)
	if not hazard.error.is_empty(): return hazard.error
	var hazard_total := int(hazard.total)
	var resolution_frame_id := ""
	if not forced_drop_pod:
		var action_id := "transport-disembark:%d:%d:%d:%d" % [int(state.get("turn", 0)), transport_model, passenger_squad, int(state.get("revision", -1))]
		var frame := ResolutionFrames.begin(state, "transport-disembark", action_id, "transport-hazard-and-placement")
		if frame.is_empty(): return "Could not open the transport disembarkation continuation frame."
		resolution_frame_id = str(frame.get("frame_id", ""))
		var suspend_error := ResolutionFrames.suspend(state, resolution_frame_id, "transport-hazard-and-placement")
		if not suspend_error.is_empty():
			ResolutionFrames.complete(state, resolution_frame_id)
			return suspend_error
	state.unit_abilities.transport_window = {"kind": "disembark", "player": player, "transport": transport_model, "passenger_squad": passenger_squad, "mode": mode, "models": passenger_models, "placements": {}, "origins": {}, "prior_flags": {}, "hazard_rolls": hazard.rolls, "hazard_total": hazard_total, "hazard_remaining": hazard_total, "hazard_allocations": [], "stage": "placement", "aggressive_disembarkation": aggressive_disembarkation}
	if not resolution_frame_id.is_empty(): state.unit_abilities.transport_window.resolution_frame_id = resolution_frame_id
	_set_window_actor(state, player, DISEMBARK_WINDOW)
	if hazard_total > 0:
		state.unit_abilities.transport_window.stage = "hazard"
	if mode == "combat": _offer_transport_hazard_reroll(state, state.unit_abilities.transport_window, player)
	for model: int in passenger_models:
		state.unit_abilities.transport_window.origins[model] = state.units[model].position
		state.unit_abilities.transport_window.prior_flags[model] = state.units[model].get("on_battlefield", false)
	return ""

static func confirm_error(state: Dictionary) -> String:
	var window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
	if window.is_empty(): return "No pending transport placement."
	if window.get("stage", "") != "placement":
		var label := "Emergency Disembark" if window.get("kind", "") == "emergency" else "Combat Disembark"
		return "Resolve %s Hazard decisions before placing the unit." % label
	for model: int in window.models:
		if not window.placements.has(model): return "Place every model in the disembarking unit."
	if not _coherent_preview(state, window): return "Disembarked models must be in unit coherency."
	return ""

static func resolve_hazard_reaction(state: Dictionary, player: int, squad: int, stratagem: String, revision: int, die: int, roller: Callable) -> String:
	var reaction := Stratagems.pending(state)
	if reaction.get("kind", "") != "after_transport_hazard_roll": return "There is no pending transport Hazard decision."
	var error := Stratagems.choice_error(state, player, squad, revision)
	if not error.is_empty(): return error
	if stratagem not in ["", "command-re-roll"]: return "Invalid stratagem for this transport Hazard decision."
	if not stratagem.is_empty():
		error = Stratagems.use_error(state, player, squad, stratagem, revision)
		if not error.is_empty(): return error
		if die not in reaction.get("eligible", []): return "Select one die from this transport Hazard pool."
	var working: Dictionary = state.duplicate(true)
	var pending: Dictionary = Stratagems.pending(working)
	var window: Dictionary = working.get("unit_abilities", {}).get("transport_window", {})
	if window.is_empty() or window.get("stage", "") != "hazard-reroll" or int(window.get("passenger_squad", -1)) != squad:
		return "The transport Hazard continuation is missing."
	var original: Array = pending.get("rolls", []).duplicate()
	var final_rolls: Array = original.duplicate()
	if not stratagem.is_empty():
		if not roller.is_valid(): return "Missing hazard dice provider."
		var replacement: Variant = roller.call()
		if not replacement is int or replacement < 1 or replacement > 6: return "Hazard dice must be integers from 1 to 6."
		final_rolls[die] = replacement
	var hazard := Hazardous.from_rolls(working, squad, final_rolls)
	if not hazard.error.is_empty(): return hazard.error
	if not stratagem.is_empty():
		var rerolls: Array = window.get("hazard_rerolls", []).duplicate(true)
		rerolls.append({"index": die, "original": original[die], "replacement": final_rolls[die], "source": "Command Re-roll"})
		window.hazard_rerolls = rerolls
		Stratagems.consume(working, player, squad, stratagem)
	window.hazard_rolls = hazard.rolls
	window.hazard_total = int(hazard.total)
	window.hazard_remaining = int(hazard.total)
	window.stage = "hazard" if int(hazard.total) > 0 else "placement"
	var decision_player := int(working.squads[squad].owner)
	if window.get("kind", "") == "emergency" and int(hazard.total) == 0:
		decision_player = int(window.get("active_player", working.active))
	window.player = decision_player
	_set_window_actor(working, decision_player, EMERGENCY_WINDOW if window.get("kind", "") == "emergency" else DISEMBARK_WINDOW)
	working.last_command_roll = {"kind": "after_transport_hazard_roll", "squad": squad,
		"original_rolls": original, "rolls": final_rolls, "rerolled": not stratagem.is_empty(), "die": die, "source": stratagem}
	working.stratagems.pending = {}
	state.clear()
	state.merge(working, true)
	return ""

static func _emergency_mortal_candidates(state: Dictionary, window: Dictionary) -> Array[int]:
	var ordinary: Array[int] = []
	var characters: Array[int] = []
	for model: int in window.models:
		if int(state.units[model].get("wounds", 0)) <= 0: continue
		if Groups.character(state.units[model]): characters.append(model)
		else: ordinary.append(model)
	var candidates := ordinary if not ordinary.is_empty() else characters
	var wounded: Array[int] = []
	for model: int in candidates:
		if int(state.units[model].wounds) < int(state.units[model].get("max_wounds", state.units[model].wounds)): wounded.append(model)
	return wounded if not wounded.is_empty() else candidates

static func _emergency_hazards_complete(state: Dictionary, window: Dictionary) -> void:
	window.models = window.models.filter(func(model: int) -> bool: return int(state.units[model].get("wounds", 0)) > 0)
	window.stage = "placement"
	window.player = int(window.active_player)
	_set_window_actor(state, int(window.active_player))
	if window.models.is_empty(): _emergency_finish(state, window)

static func _disembark_hazards_complete(state: Dictionary, window: Dictionary, roller: Callable) -> String:
	window.models = window.models.filter(func(model: int) -> bool: return int(state.units[model].get("wounds", 0)) > 0)
	window.stage = "placement"
	_set_window_actor(state, int(window.player), DISEMBARK_WINDOW)
	if window.models.is_empty():
		var resolution_frame_id := str(window.get("resolution_frame_id", ""))
		if not resolution_frame_id.is_empty() and not window.get("mandatory_drop_pod", false):
			var active_frame := ResolutionFrames.current(state)
			if str(active_frame.get("frame_id", "")) != resolution_frame_id or str(active_frame.get("kind", "")) != "transport-disembark":
				return "The active transport disembarkation continuation is missing."
			var frame_error := ResolutionFrames.complete(state, resolution_frame_id)
			if not frame_error.is_empty(): return frame_error
		var passenger_squad := int(window.passenger_squad)
		for model: int in state.units:
			if int(state.units[model].get("squad", -1)) == passenger_squad: state.units[model].erase("embarked_transport")
		state.squads[passenger_squad].erase("embarked_in")
		state.squads[passenger_squad].erase("embarked_this_turn")
		state.unit_abilities.transport_window = {}
		state.unit_abilities.window = {}
	if window.get("mandatory_drop_pod", false) and window.models.is_empty(): return _finish_drop_pod_passenger(state, window, roller)
	return ""

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2, roller: Callable = Callable()) -> String:
	var action := str(selected.get("action", ""))
	if action in ["transport-emergency-aggressive-use", "transport-emergency-aggressive-pass", "transport-disembark-aggressive-use", "transport-disembark-aggressive-pass"]:
		var window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
		var emergency_choice: bool = action.begins_with("transport-emergency-")
		var drop_pod_choice: bool = action.begins_with("transport-disembark-")
		var correct_context: bool = window.get("kind", "") == "emergency" if emergency_choice else window.get("kind", "") == "disembark" and bool(window.get("mandatory_drop_pod", false)) and bool(window.get("drop_pod_assault", false))
		if not correct_context or window.get("stage", "") != "aggressive-choice" or int(window.get("player", -1)) != player or int(selected.get("target", -1)) != int(window.get("passenger_squad", -2)) or int(selected.get("model", -1)) != int(window.get("transport", -2)): return "No matching transport stratagem choice is pending."
		var working: Dictionary = state.duplicate(true)
		var working_window: Dictionary = working.unit_abilities.transport_window
		var use_aggressive := action.ends_with("-use")
		if use_aggressive:
			var aggressive_error := gauntlet_aggressive_disembarkation_error(working, player, int(working_window.transport), int(working_window.passenger_squad), str(working_window.mode))
			if not aggressive_error.is_empty(): return aggressive_error
			var stratagem_choice := {"action": "detachment-stratagem", "model": int(working_window.transport), "target": int(working_window.passenger_squad), "value": DetachmentStratagems.GAUNTLET_AGGRESSIVE_DISEMBARKATION}
			var stratagem_result := DetachmentStratagems.apply(working, player, stratagem_choice, roller)
			if not str(stratagem_result.get("error", "")).is_empty(): return str(stratagem_result.error)
		elif not action.ends_with("-pass"):
			return "Unsupported transport stratagem response."
		working_window.aggressive_disembarkation = use_aggressive
		if emergency_choice:
			var hazard_error := _roll_emergency_hazard(working, working_window, roller)
			if not hazard_error.is_empty(): return hazard_error
		elif drop_pod_choice:
			working_window.stage = "placement"
			_set_window_actor(working, player, DISEMBARK_WINDOW)
		state.clear()
		state.merge(working, true)
		return ""
	if action == "transport-embark":
		var model := int(selected.get("model", -1))
		if not state.units.has(model): return "Select a living passenger model."
		return embark(state, player, int(selected.target), int(state.units[model].squad))
	if action == "transport-embark-start":
		if not state.units.has(int(selected.get("model", -1))): return "Select a living passenger model."
		return start_embark(state, player, int(selected.target), int(state.units[int(selected.model)].squad))
	if action == "transport-disembark-start":
		return begin_disembark(state, player, int(selected.model), int(selected.target), str(selected.value), roller)
	if action == "transport-disembark-start-aggressive":
		var transport_model := int(selected.get("model", -1))
		var passenger_squad := int(selected.get("target", -1))
		var mode := str(selected.get("value", ""))
		var aggressive_error := gauntlet_aggressive_disembarkation_error(state, player, transport_model, passenger_squad, mode)
		if not aggressive_error.is_empty(): return aggressive_error
		var working: Dictionary = state.duplicate(true)
		var stratagem_choice := {"action": "detachment-stratagem", "model": transport_model, "target": passenger_squad, "value": DetachmentStratagems.GAUNTLET_AGGRESSIVE_DISEMBARKATION}
		var stratagem_result := DetachmentStratagems.apply(working, player, stratagem_choice, roller)
		if not str(stratagem_result.get("error", "")).is_empty(): return str(stratagem_result.error)
		var begin_error := begin_disembark(working, player, transport_model, passenger_squad, mode, roller, false, true)
		if not begin_error.is_empty(): return begin_error
		state.clear()
		state.merge(working, true)
		return ""
	var window: Dictionary = state.get("unit_abilities", {}).get("transport_window", {})
	if window.is_empty() or int(window.player) != player: return "No transport decision is active for this player."
	if action == "transport-disembark-hazard-allocate":
		if window.get("kind", "") not in ["emergency", "disembark"] or window.get("stage", "") != "hazard" or int(selected.model) not in _emergency_mortal_candidates(state, window): return "Select a living eligible passenger model for the Hazard mortal wound."
		var model := int(selected.model)
		var prevention := Prevention.resolve(1, int(state.units[model].wounds), UnitPrevention.rules(state, model), "mortal", roller)
		if not prevention.error.is_empty():
			# Feel No Pain may require dice; the caller retries through the roller-aware overload.
			return prevention.error
		state.units[model].wounds -= int(prevention.lost)
		window.hazard_allocations.append({"model": model, "prevention": prevention})
		window.hazard_remaining = int(window.hazard_remaining) - 1
		if state.units[model].wounds <= 0:
			DetachmentStratagems.record_destroyed(state, model)
			for cenobyte: int in ChaplainGrimaldus.destroy_cenobytes(state, model): DetachmentStratagems.record_destroyed(state, cenobyte)
		if int(window.hazard_remaining) <= 0 or _emergency_mortal_candidates(state, window).is_empty():
			window.hazard_remaining = 0
			if window.kind == "emergency": _emergency_hazards_complete(state, window)
			else:
				var hazard_error := _disembark_hazards_complete(state, window, roller)
				if not hazard_error.is_empty(): return hazard_error
		return ""
	if action == "transport-emergency-unplaceable":
		if window.get("kind", "") != "emergency" or window.get("stage", "") != "placement" or int(selected.model) not in window.models: return "Select a passenger model still awaiting emergency placement."
		var destroyed_model := int(selected.model)
		state.units[destroyed_model].wounds = 0
		state.units[destroyed_model].on_battlefield = false
		state.units[destroyed_model].erase("embarked_transport")
		DetachmentStratagems.record_destroyed(state, destroyed_model)
		for cenobyte: int in ChaplainGrimaldus.destroy_cenobytes(state, destroyed_model): DetachmentStratagems.record_destroyed(state, cenobyte)
		window.models.erase(destroyed_model)
		if window.models.is_empty(): _emergency_finish(state, window)
		return ""
	match action:
		"transport-disembark-place":
			if window.get("stage", "") != "placement": return "Resolve Hazard decisions before placing disembarking models."
			var model := int(selected.model)
			if model not in window.models or window.placements.has(model): return "Select a model that still needs a disembark position."
			var error := _position_error(state, window, model, point)
			if window.get("kind", "") == "emergency":
				var no_unengaged_position := is_inf(_nearest_emergency_edge(state, window, model))
				if str(selected.get("value", "")) == "engaged":
					if not no_unengaged_position: return "Use an unengaged position when one is possible."
					if is_inf(_nearest_emergency_engaged_edge(state, window, model)): return "No legal emergency position exists; declare this model unable to be set up."
					var engaged_window: Dictionary = window.duplicate(true)
					engaged_window.allow_engaged = true
					error = _position_error(state, engaged_window, model, point)
				else:
					if no_unengaged_position: return "This model must be set up engaged because no unengaged position is possible."
			if not error.is_empty(): return error
			if window.get("kind", "") == "emergency":
				var nearest_edge := _nearest_emergency_edge(state, window, model)
				if str(selected.get("value", "")) == "engaged": nearest_edge = _nearest_emergency_engaged_edge(state, window, model)
				if is_inf(nearest_edge): return "No legal emergency position exists; declare this model unable to be set up."
				var actual_edge := Geometry.edge({"position": point, "radius": state.units[model].radius}, state.units[int(window.transport)])
				if actual_edge > nearest_edge + 0.101: return "Emergency Disembark must set this model up as close as possible to the destroyed transport."
			window.placements[model] = point
		"transport-disembark-reset":
			window.placements = {}
		"transport-disembark-confirm":
			var error := confirm_error(state)
			if not error.is_empty(): return error
			var resolution_frame_id := str(window.get("resolution_frame_id", ""))
			if not resolution_frame_id.is_empty():
				var active_frame := ResolutionFrames.current(state)
				var expected_frame_kind := "transport-drop-pod-assault" if window.get("mandatory_drop_pod", false) else "transport-disembark"
				if str(active_frame.get("frame_id", "")) != resolution_frame_id or str(active_frame.get("kind", "")) != expected_frame_kind:
					return "The active transport disembarkation continuation is missing."
			var passenger_squad := int(window.passenger_squad)
			for model: int in window.models:
				state.units[model].position = window.placements[model]
				state.units[model].elevation = float(state.units[int(window.transport)].get("elevation", 0.0))
				state.units[model].on_battlefield = true
				state.units[model].erase("embarked_transport")
			if window.get("kind", "") == "emergency":
				state.squads[passenger_squad].battle_shocked = true
				state.squads[passenger_squad].cannot_charge_until_turn = int(state.turn)
				state.squads[passenger_squad].move_type = "emergency-disembark"
				state.squads[passenger_squad].moved = true
				state.squads[passenger_squad].set_up_this_turn = true
				state.squads[passenger_squad].disembarked_turn = int(state.turn)
				state.squads[passenger_squad].erase("embarked_in")
				state.squads[passenger_squad].erase("embarked_this_turn")
				state.unit_abilities.transport_window = {}
				state.unit_abilities.window = {}
			else:
				state.squads[passenger_squad].erase("embarked_in")
				state.squads[passenger_squad].erase("embarked_this_turn")
				state.squads[passenger_squad].set_up_this_turn = true
				state.squads[passenger_squad].move_type = "disembark-" + str(window.mode)
				state.squads[passenger_squad].moved = window.mode != "tactical"
				state.squads[passenger_squad].moved_distance = 0.0
				state.squads[passenger_squad].disembarked_turn = int(state.turn)
				if window.mode in ["rapid", "shock", "combat"]: state.squads[passenger_squad].cannot_charge_until_turn = int(state.turn)
				if window.mode == "combat": state.squads[passenger_squad].battle_shocked = true
				if window.get("mandatory_drop_pod", false):
					var chain_error := _finish_drop_pod_passenger(state, window, roller)
					if not chain_error.is_empty(): return chain_error
				else:
					state.unit_abilities.transport_window = {}
					state.unit_abilities.window = {}
			if not resolution_frame_id.is_empty() and not window.get("mandatory_drop_pod", false):
				var frame_error := ResolutionFrames.complete(state, resolution_frame_id)
				if not frame_error.is_empty(): return frame_error
			return ""
		_:
			return "Unsupported transport action."
	return ""

