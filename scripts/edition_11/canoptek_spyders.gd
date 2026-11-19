extends RefCounted
## Source-bounded Canoptek Spyders equipment, auras and Command-phase returns.
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const NecronProfiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const ReturnPlacement = preload("res://scripts/edition_11/return_placement.gd")

const IDENTITY := "canoptek-spyders"
const LOADOUT_ACTION := "canoptek-spyders-loadout"
const SWARM_ACTION := "canoptek-swarm"
const PLACE_ACTION := "canoptek-swarm-place"
const UNPLACEABLE_ACTION := "canoptek-swarm-unplaceable"
const RESET_ACTION := "canoptek-swarm-reset"
const CONFIRM_ACTION := "canoptek-swarm-confirm"
const BEAMERS := "particle-beamers"
const FABRICATOR := "fabricator-claw-array"
const GLOOM := "gloom-prism"
const OPTIONS := [BEAMERS, FABRICATOR, GLOOM]
const EQUIPMENT_FIELDS := [
	"canoptek_spyders_particle_beamers",
	"canoptek_spyders_fabricator_claw_array",
	"canoptek_spyders_gloom_prism"
]

static func equipment_label(option: String) -> String:
	return {
		BEAMERS: "2 Particle Beamers",
		FABRICATOR: "Fabricator Claw Array",
		GLOOM: "Gloom Prism"
	}.get(option, "")

static func equipment_field(option: String) -> String:
	return _field(option)

static func _profile() -> Dictionary:
	return NecronProfiles.profile(IDENTITY)

static func _field(option: String) -> String:
	return str({
		BEAMERS: "canoptek_spyders_particle_beamers",
		FABRICATOR: "canoptek_spyders_fabricator_claw_array",
		GLOOM: "canoptek_spyders_gloom_prism"
	}.get(option, ""))

static func setup_actor(state: Dictionary) -> int:
	if str(state.get("phase", "")) != "deployment": return -1
	var prepared: Array = state.get("unit_abilities", {}).get("setup_players", [])
	for player: int in [1, 2]:
		if player not in prepared: return player
	return -1

static func _loadout_weapon_inventory(unit: Dictionary) -> Dictionary:
	return weapon_inventory(unit)

static func weapon_inventory(unit: Dictionary) -> Dictionary:
	var profile := _profile()
	if profile.is_empty(): return {}
	var ranged: Array = profile.get("ranged", []).duplicate(true)
	var melee: Array = profile.get("melee", []).duplicate(true)
	if melee.is_empty(): return {}
	if bool(unit.get(_field(BEAMERS), false)):
		var beamer: Dictionary = {}
		for option: Dictionary in profile.get("additional_weapon_profiles", {}).get("ranged", []):
			if str(option.get("name", "")).to_lower() == "particle beamer": beamer = option.duplicate(true)
		if beamer.is_empty(): return {}
		for index in range(2):
			var weapon := beamer.duplicate(true)
			weapon.id = "canoptek-spyders-particle-beamer-%d" % (index + 1)
			ranged.append(weapon)
	return {"ranged": ranged, "melee": melee}

static func prepare_model(unit: Dictionary) -> String:
	for option: String in OPTIONS:
		var field := _field(option)
		unit[field] = bool(unit.get(field, false))
	var inventory := _loadout_weapon_inventory(unit)
	if inventory.is_empty(): return "Canoptek Spyders requires source-listed local weapons and equipment."
	unit.ranged_weapons = inventory.ranged
	unit.melee_weapons = inventory.melee
	return ""

static func configure_model(state: Dictionary, player: int, model: int, squad: int, option: String, enabled: bool) -> String:
	if setup_actor(state) != player: return "Canoptek Spyders equipment is selected during your army preparations."
	if not state.get("units", {}).has(model): return "Choose a Canoptek Spyder from your army."
	var unit: Dictionary = state.units[model]
	if int(unit.get("owner", -1)) != player or int(unit.get("squad", -1)) != squad or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY:
		return "Choose a living Canoptek Spyder from its own unit."
	if bool(unit.get("canoptek_spyders_loadout_locked", false)):
		return "This saved-list Canoptek Spyder equipment is fixed for the match. Edit the saved list before starting another match."
	var field := _field(option)
	if field.is_empty(): return "Choose a source-listed Canoptek Spyders equipment option."
	unit[field] = enabled
	var inventory := _loadout_weapon_inventory(unit)
	if inventory.is_empty(): return "A source-listed Canoptek Spyders weapon profile is missing."
	unit.ranged_weapons = inventory.ranged
	unit.melee_weapons = inventory.melee
	return ""

static func loadout_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if setup_actor(state) != player: return result
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != player or int(unit.get("wounds", 0)) <= 0 or AbilityCatalog.identity(unit) != IDENTITY: continue
		if bool(unit.get("canoptek_spyders_loadout_locked", false)): continue
		var squad := int(unit.get("squad", -1))
		for option: String in OPTIONS:
			var field := _field(option)
			var equipped := bool(unit.get(field, false))
			var action_text := "Remove" if equipped else "Equip"
			var equipment_name := equipment_label(option)
			if option in [FABRICATOR, GLOOM]: equipment_name += " (Aura)"
			result.append({
				"label": "Canoptek Spyder %d: %s %s" % [model, action_text, equipment_name],
				"action": LOADOUT_ACTION,
				"model": model,
				"target": squad,
				"value": option + (":off" if equipped else ":on")
			})
	return result

static func _on_battlefield(state: Dictionary, model: int) -> bool:
	if not state.get("units", {}).has(model): return false
	var unit: Dictionary = state.units[model]
	if int(unit.get("wounds", 0)) <= 0 or not bool(unit.get("on_battlefield", true)): return false
	var squad := int(unit.get("squad", -1))
	if state.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	return int(unit.get("embarked_transport", -1)) < 0

static func _has_keyword(state: Dictionary, squad: int, keyword: String) -> bool:
	for model: int in Geometry.alive(state, squad):
		for entry: Variant in state.units[model].get("keywords", []):
			if str(entry).strip_edges().to_upper() == keyword.to_upper(): return true
	return false

static func _unit_on_battlefield(state: Dictionary, squad: int) -> bool:
	if not state.get("squads", {}).has(squad) or state.get("unit_abilities", {}).get("reserves", {}).has(squad): return false
	if Geometry.alive(state, squad).is_empty(): return false
	for unit: Dictionary in state.get("units", {}).values():
		if int(unit.get("squad", -1)) == squad and int(unit.get("embarked_transport", -1)) >= 0: return false
	return true

static func feel_no_pain_grants(state: Dictionary, target_squad: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not state.get("squads", {}).has(target_squad) or not _unit_on_battlefield(state, target_squad): return result
	var target_owner := int(state.squads[target_squad].get("owner", -1))
	var has_necrons := _has_keyword(state, target_squad, "NECRONS")
	var has_vehicle := _has_keyword(state, target_squad, "VEHICLE")
	for source_squad: int in state.get("squads", {}):
		if int(state.squads[source_squad].get("owner", -2)) != target_owner: continue
		for bearer: int in AbilityCatalog.sources(state, source_squad, "fabricator-claw-array"):
			if not _on_battlefield(state, bearer) or Geometry.distance_to_target(state, state.units[bearer], target_squad) > 6.0 + 0.001: continue
			if has_necrons and has_vehicle:
				var fabricator := {"target": 6, "against": "any"}
				if fabricator not in result: result.append(fabricator)
		for bearer: int in AbilityCatalog.sources(state, source_squad, "gloom-prism"):
			if not has_necrons or not _on_battlefield(state, bearer) or Geometry.distance_to_target(state, state.units[bearer], target_squad) > 6.0 + 0.001: continue
			for protection: Dictionary in [{"target": 5, "against": "mortal"}, {"target": 5, "against": "psychic"}]:
				if protection not in result: result.append(protection)
	return result

static func _source_squads(state: Dictionary, player: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != player: continue
		if not AbilityCatalog.sources(state, squad, "canoptek-swarm").is_empty(): result.append(squad)
	result.sort()
	return result

static func _destroyed_scarabs(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("squad", -1)) == squad and int(unit.get("wounds", 0)) <= 0 and AbilityCatalog.identity(unit) == "canoptek-scarab-swarms": result.append(model)
	result.sort()
	return result

static func _spyder_model_count(state: Dictionary, squad: int) -> int:
	# The local sentence counts Spyder models in the unit but does not say destroyed
	# Spyders continue contributing; the scoped reading uses surviving models.
	if not state.get("squads", {}).has(squad): return 0
	return Geometry.alive(state, squad).size()

static func _targets(state: Dictionary, source_squad: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var owner := int(state.squads.get(source_squad, {}).get("owner", -1))
	var source_models := AbilityCatalog.sources(state, source_squad, "canoptek-swarm")
	if owner not in [1, 2] or source_models.is_empty() or _spyder_model_count(state, source_squad) <= 0: return result
	var maximum := _spyder_model_count(state, source_squad)
	for target_squad: int in state.get("squads", {}):
		if int(state.squads[target_squad].get("owner", -2)) != owner or not _unit_on_battlefield(state, target_squad): continue
		var living := Geometry.alive(state, target_squad)
		if living.is_empty() or AbilityCatalog.identity(state.units[living[0]]) != "canoptek-scarab-swarms": continue
		var destroyed := _destroyed_scarabs(state, target_squad)
		if destroyed.is_empty(): continue
		var within_range := false
		for source: int in source_models:
			if not _on_battlefield(state, source): continue
			if Geometry.distance_to_target(state, state.units[source], target_squad) <= 6.0 + 0.001:
				within_range = true
				break
		if within_range: result.append({"squad": target_squad, "models": destroyed, "count": mini(maximum, destroyed.size())})
	return result

static func command_start_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if str(state.get("phase", "")) != "command" or int(state.get("active", -1)) != player: return result
	for source_squad: int in _source_squads(state, player):
		var use_key := "canoptek-swarm:%d:%d" % [source_squad, int(state.get("turn", -1))]
		if state.get("unit_abilities", {}).get("used", {}).get(use_key, false): continue
		var source_models := AbilityCatalog.sources(state, source_squad, "canoptek-swarm")
		if source_models.is_empty(): continue
		var source_model := source_models[0]
		for target: Dictionary in _targets(state, source_squad):
			var label := "Canoptek Swarm: return up to %d destroyed model%s to %s" % [int(target.count), "s" if int(target.count) != 1 else "", str(state.squads[int(target.squad)].get("name", "Canoptek Scarab Swarms"))]
			result.append({"label": label, "action": SWARM_ACTION, "model": source_model, "target": int(target.squad), "value": str(source_squad)})
	return result

static func command_start_required(state: Dictionary, player: int) -> bool:
	return not command_start_choices(state, player).is_empty()

static func pending(state: Dictionary) -> Dictionary:
	return state.get("unit_abilities", {}).get("canoptek_spyders_return", {})

static func return_choices(state: Dictionary, player: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var current := pending(state)
	if current.is_empty() or int(current.get("owner", -1)) != player or int(current.get("turn", -1)) != int(state.get("turn", -2)): return result
	var assigned: int = current.get("placements", {}).size() + current.get("unplaced", []).size()
	for model: int in current.get("models", []):
		if current.placements.has(model) or model in current.unplaced: continue
		result.append({"label": "Choose a return position for Scarab model %d" % model, "action": PLACE_ACTION, "model": model, "target": int(current.target_squad), "value": "position", "details": {"position": "validated-by-rules"}})
		result.append({"label": "Declare Scarab model %d unplaceable" % model, "action": UNPLACEABLE_ACTION, "model": model, "target": int(current.target_squad)})
	if assigned > 0: result.append({"label": "Reset Canoptek Swarm placement preview", "action": RESET_ACTION, "target": int(current.target_squad)})
	if confirm_error(state).is_empty(): result.append({"label": "Confirm Canoptek Swarm returns", "action": CONFIRM_ACTION, "target": int(current.target_squad)})
	return result

static func _engaged_enemy_units(state: Dictionary, squad: int) -> Array[int]:
	var result: Array[int] = []
	var living := Geometry.alive(state, squad)
	if living.is_empty(): return result
	for enemy: int in state.get("squads", {}):
		if int(state.squads[enemy].get("owner", -1)) == int(state.squads[squad].get("owner", -2)): continue
		for model: int in living:
			if Geometry.distance_to_target_at_height(state, state.units[model], enemy) > 2.0 + 0.001: continue
			result.append(enemy)
			break
	result.sort()
	return result

static func _begin_return(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var source_model := int(selected.get("model", -1))
	var target_squad := int(selected.get("target", -1))
	if str(state.get("phase", "")) != "command" or int(state.get("active", -1)) != player or window.get("kind", "") != "start" or window.get("owners", []).is_empty() or int(window.owners[0]) != player:
		return {"error": "Canoptek Swarm is resolved during its controller's Command phase."}
	if not state.get("units", {}).has(source_model) or int(state.units[source_model].get("owner", -1)) != player or not AbilityCatalog.sources(state, int(state.units[source_model].get("squad", -1)), "canoptek-swarm").has(source_model):
		return {"error": "Choose a living Canoptek Spyders unit with Canoptek Swarm."}
	var source_squad := int(state.units[source_model].get("squad", -1))
	var use_key := "canoptek-swarm:%d:%d" % [source_squad, int(state.get("turn", -1))]
	if state.get("unit_abilities", {}).get("used", {}).get(use_key, false): return {"error": "This Canoptek Spyders unit has already used Canoptek Swarm this Command phase."}
	var selected_is_current := false
	for choice: Dictionary in command_start_choices(state, player):
		if choice.get("action", "") == SWARM_ACTION and int(choice.get("model", -1)) == source_model and int(choice.get("target", -1)) == target_squad: selected_is_current = true
	if not selected_is_current: return {"error": "Choose a friendly Canoptek Scarab Swarm within 6 inches with destroyed models."}
	var target_data: Dictionary = {}
	for candidate: Dictionary in _targets(state, source_squad):
		if int(candidate.squad) == target_squad: target_data = candidate
	if target_data.is_empty(): return {"error": "That Canoptek Scarab Swarm is no longer eligible for Canoptek Swarm."}
	var anchors: Array = state.get("reanimation", {}).get("anchors", {}).get(target_squad, []).duplicate()
	if anchors.is_empty(): return {"error": "Canoptek Swarm requires a surviving Scarab that started the Command phase on the battlefield."}
	var models: Array[int] = []
	for model: int in target_data.models:
		if models.size() >= int(target_data.count): break
		models.append(model)
	if models.is_empty(): return {"error": "That unit has no destroyed Scarab models to return."}
	state.unit_abilities.used[use_key] = true
	state.unit_abilities.canoptek_spyders_return = {
		"owner": player,
		"turn": int(state.get("turn", -1)),
		"source_squad": source_squad,
		"target_squad": target_squad,
		"squad": target_squad,
		"models": models,
		"slots": models.size(),
		"placements": {},
		"unplaced": [],
		"anchors": anchors,
		"engaged": _engaged_enemy_units(state, target_squad),
		"revive_on_battlefield": true
	}
	return {"error": "", "message": "Canoptek Swarm: preview positions for %d destroyed Scarab model%s, then confirm." % [models.size(), "s" if models.size() != 1 else ""]}

static func position_error(state: Dictionary, model: int, destination: Vector2) -> String:
	var current := pending(state)
	if current.is_empty() or model not in current.get("models", []): return "Choose a destroyed Scarab model from the active Canoptek Swarm return."
	if model in current.get("unplaced", []): return "Reset the placement preview before placing a model declared unplaceable."
	if current.get("placements", {}).has(model): return "Reset the placement preview before changing this model's position."
	return ReturnPlacement.error(state, model, destination, current)

static func place_model(state: Dictionary, model: int, destination: Vector2) -> Dictionary:
	var error := position_error(state, model, destination)
	if not error.is_empty(): return {"error": error}
	pending(state).placements[model] = destination
	return {"error": "", "message": "Scarab model %d placement previewed; confirm Canoptek Swarm to return it." % model}

static func declare_unplaceable(state: Dictionary, model: int) -> Dictionary:
	var current := pending(state)
	if current.is_empty() or model not in current.get("models", []) or model in current.get("unplaced", []): return {"error": "Choose a destroyed Scarab model that has not already been resolved."}
	if current.get("placements", {}).has(model): return {"error": "Reset the preview before declaring a placed model unplaceable."}
	current.unplaced.append(model)
	return {"error": "", "message": "Scarab model %d remains destroyed because its controller declared it unplaceable." % model}

static func reset_preview(state: Dictionary) -> Dictionary:
	var current := pending(state)
	if current.is_empty(): return {"error": "No Canoptek Swarm placement preview is pending."}
	current.placements = {}
	current.unplaced = []
	return {"error": "", "message": "Canoptek Swarm placement preview reset."}

static func confirm_error(state: Dictionary) -> String:
	var current := pending(state)
	if current.is_empty(): return "Resolve the Canoptek Swarm return first."
	if current.get("placements", {}).size() + current.get("unplaced", []).size() != int(current.get("slots", 0)): return "Place each returnable Scarab model or record an inability to place it."
	for model: int in current.placements:
		var error := ReturnPlacement.error(state, model, current.placements[model], current)
		if not error.is_empty(): return error
	if not current.placements.is_empty() and not Geometry.coherent(ReturnPlacement.projected(state, current), int(current.target_squad)): return "Returned Scarab models must leave their unit in coherency."
	return ""

static func _confirm_return(state: Dictionary, player: int) -> Dictionary:
	var current := pending(state)
	if current.is_empty() or int(current.get("owner", -1)) != player: return {"error": "No Canoptek Swarm return is pending for this player."}
	var error := confirm_error(state)
	if not error.is_empty(): return {"error": error}
	var returned := 0
	for model: int in current.placements:
		state.units[model].wounds = int(state.units[model].get("max_wounds", 1))
		state.units[model].position = current.placements[model]
		state.units[model].on_battlefield = true
		returned += 1
	var source_squad := int(current.source_squad)
	var target_squad := int(current.target_squad)
	var failures: int = current.unplaced.size()
	state.unit_abilities.canoptek_spyders_last_result = {"source_squad": source_squad, "target_squad": target_squad, "returned": returned, "unplaced": current.unplaced.duplicate()}
	state.unit_abilities.canoptek_spyders_return = {}
	return {"error": "", "message": "%s: Canoptek Swarm returned %d destroyed model%s; %d declared unplaceable remain destroyed." % [str(state.squads.get(target_squad, {}).get("name", "Canoptek Scarab Swarms")), returned, "s" if returned != 1 else "", failures]}

static func apply(state: Dictionary, player: int, selected: Dictionary, point: Vector2) -> Dictionary:
	var action := str(selected.get("action", ""))
	if action == LOADOUT_ACTION:
		var selection: PackedStringArray = str(selected.get("value", "")).split(":")
		if selection.size() != 2 or selection[1] not in ["on", "off"]: return {"error": "Choose an equip or remove action from the source-listed options."}
		var error := configure_model(state, player, int(selected.get("model", -1)), int(selected.get("target", -1)), selection[0], selection[1] == "on")
		return {"error": error, "message": "Canoptek Spyders equipment updated from the local Necrons datasheet." if error.is_empty() else ""}
	if action == SWARM_ACTION: return _begin_return(state, player, selected)
	var current := pending(state)
	if current.is_empty() or int(current.get("owner", -1)) != player or int(current.get("turn", -1)) != int(state.get("turn", -2)): return {"error": "No Canoptek Swarm placement decision is pending for this player."}
	if action == PLACE_ACTION: return place_model(state, int(selected.get("model", -1)), point)
	if action == UNPLACEABLE_ACTION: return declare_unplaceable(state, int(selected.get("model", -1)))
	if action == RESET_ACTION: return reset_preview(state)
	if action == CONFIRM_ACTION: return _confirm_return(state, player)
	return {"error": "Unknown Canoptek Spyders action."}
