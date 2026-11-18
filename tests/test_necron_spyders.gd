extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const UnitPrevention = preload("res://scripts/edition_11/unit_prevention.gd")
const WoundPrevention = preload("res://scripts/edition_11/wound_prevention.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Spyders = preload("res://scripts/edition_11/canoptek_spyders.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const SPYDER_ID := "40kdc:11e:necrons:canoptek-spyders"
const SCARAB_ID := "40kdc:11e:necrons:canoptek-scarab-swarms"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [
			{"definition_id": SPYDER_ID, "models": 2, "copies": 1},
			{"definition_id": SCARAB_ID, "models": 3, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 500, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}]}}

func models_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and Abilities.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		var living := Geometry.alive(state, squad)
		if not living.is_empty() and Abilities.identity(state.units[living[0]]) == identity: return squad
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func run() -> void:
	var profile := Profiles.profile("canoptek-spyders")
	var beamer: Dictionary = profile.get("additional_weapon_profiles", {}).get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var claws: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000000551" and profile.get("source_snapshot_id", "") == "20261031T053336Z" and profile.get("points_by_models", {}) == {1: 65, 2: 110} and profile.get("construction_model_sizes", []) == [1, 2] and profile.get("base_size_source_mm", 0) == 60, "Canoptek Spyders retain the App v1.2 identity, priced sizes and 60 mm flying base")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 7, "save_target": 3, "wounds": 6, "leadership_target": 8, "objective_control": 2, "invulnerable_target": 0}, "Canoptek Spyders retain the complete source characteristics")
	check(beamer.get("range_inches") == 18 and beamer.get("attacks") == "D6" and beamer.get("skill") == 3 and beamer.get("strength") == 6 and beamer.get("ap") == 0 and beamer.get("damage") == 1 and beamer.get("keywords", {}) == {"blast": true, "devastating-wounds": true}, "Particle beamer preserves its D6, range, characteristics and both source traits")
	check(claws.get("attacks") == 5 and claws.get("skill") == 4 and claws.get("strength") == 8 and claws.get("ap") == -2 and claws.get("damage") == 2, "Automaton claws preserve their complete source profile")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "deadly-demise-1", "fabricator-claw-array", "gloom-prism", "canoptek-swarm"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "The source profile records only the locally implemented Canoptek Spyders scope")
	check(profile.get("source_options", []).size() == 3 and profile.get("source_options", []).all(func(option: Dictionary) -> bool: return option.get("implemented", false)), "All three source-listed equipment options are exposed")
	for size: int in [1, 2]:
		var expected_cost := 65 if size == 1 else 110
		var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": SPYDER_ID, "models": size, "copies": 1}]})
		check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == expected_cost, "The source-priced %d-model Spyders configuration is admitted" % size)
	check(AbilityCatalog.RULES.get("canoptek-spyders", []).has("deadly-demise-1") and AbilityCatalog.RULES.get("canoptek-spyders", []).has("canoptek-swarm"), "The shared rules catalog binds Deadly Demise and Canoptek Swarm")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "The local two-Spyder and Scarab fixture materializes: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	var spyders := models_for(state, 1, "canoptek-spyders")
	var scarabs := models_for(state, 1, "canoptek-scarab-swarms")
	var marines := models_for(state, 2, "intercessor-squad")
	var spyder_squad := squad_for(state, 1, "canoptek-spyders")
	var scarab_squad := squad_for(state, 1, "canoptek-scarab-swarms")
	check(spyders.size() == 2 and scarabs.size() == 3 and marines.size() == 5 and spyder_squad >= 0 and scarab_squad >= 0, "Both source units materialize with their declared starting strengths")
	if spyders.size() != 2 or scarabs.size() != 3 or marines.is_empty() or spyder_squad < 0 or scarab_squad < 0:
		quit(1)
		return

	for index in range(spyders.size()): state.units[spyders[index]].position = Vector2(float(index) * 1.5, 0.0)
	for index in range(scarabs.size()): state.units[scarabs[index]].position = Vector2(7.0, float(index - 1) * 2.0)
	for index in range(marines.size()): state.units[marines[index]].position = Vector2(18.0, float(index) * 2.0)
	state.unit_abilities.setup_players = []
	state.active = 1
	state.phase = "deployment"
	state.turn = 1
	UnitActions.reconcile(state)
	for selection: Array in [[spyders[0], Spyders.BEAMERS], [spyders[0], Spyders.FABRICATOR], [spyders[1], Spyders.GLOOM]]:
		var option := find_choice(state, 1, Spyders.LOADOUT_ACTION, int(selection[0]), spyder_squad, str(selection[1]) + ":on")
		var submitted := PublicUnitCommand.submit(state, 1, option)
		check(not option.is_empty() and str(submitted.get("error", "")).is_empty(), "Army preparations resolve %s from the public choice flow" % str(selection[1]))
	check(state.units[spyders[0]].ranged_weapons.size() == 2 and str(state.units[spyders[0]].ranged_weapons[0].get("id", "")) != str(state.units[spyders[0]].ranged_weapons[1].get("id", "")) and state.units[spyders[0]].melee_weapons.size() == 1, "Equipping two beamers adds distinct ranged profiles and retains the claws")
	check(AbilityCatalog.sources(state, spyder_squad, "fabricator-claw-array") == [spyders[0]] and AbilityCatalog.sources(state, spyder_squad, "gloom-prism") == [spyders[1]] and AbilityCatalog.sources(state, spyder_squad, "canoptek-swarm") == spyders, "Only the selected living equipment bearers grant their wargear rules")
	var scarab_fnp: Array = UnitPrevention.rules(state, scarabs[0])
	check({"target": 5, "against": "mortal"} in scarab_fnp and {"target": 5, "against": "psychic"} in scarab_fnp and {"target": 6, "against": "any"} not in scarab_fnp, "Gloom Prism protects nearby Necrons against mortal and Psychic Attack damage only (grants %s, rules %s, distance %.2f)" % [str(Spyders.feel_no_pain_grants(state, scarab_squad)), str(scarab_fnp), Geometry.distance_to_target(state, state.units[spyders[1]], scarab_squad)])
	var mortal_packet := WoundPrevention.resolve(1, 4, scarab_fnp, "mortal", func() -> int: return 5)
	var psychic_packet := WoundPrevention.resolve(1, 4, scarab_fnp, "normal", func() -> int: return 5, "psychic")
	var ordinary_packet := WoundPrevention.resolve(1, 4, scarab_fnp, "normal", Callable())
	check(mortal_packet.get("target", 0) == 5 and mortal_packet.get("prevented", 0) == 1 and psychic_packet.get("target", 0) == 5 and psychic_packet.get("prevented", 0) == 1 and ordinary_packet.get("target", 0) == 0, "Gloom Prism uses the shared prevention resolver for the correct damage kinds (%s / %s / %s)" % [str(mortal_packet), str(psychic_packet), str(ordinary_packet)])
	var spyder_fnp: Array = UnitPrevention.rules(state, spyders[0])
	var fabricator_packet := WoundPrevention.resolve(1, 6, spyder_fnp, "normal", func() -> int: return 6)
	check({"target": 6, "against": "any"} in spyder_fnp and fabricator_packet.get("target", 0) == 6 and fabricator_packet.get("prevented", 0) == 1, "Fabricator Claw Array grants nearby Necrons Vehicles Feel No Pain 6+ against any damage")

	var demise_state: Dictionary = state.duplicate(true)
	demise_state.units[spyders[1]].position = Vector2(0.0, 0.0)
	demise_state.units[spyders[1]].wounds = 0
	demise_state.units[spyders[1]].on_battlefield = false
	for model: int in demise_state.units:
		if int(model) != spyders[1]: demise_state.units[model].position = Vector2(2.0, 0.0)
	var demise := DeadlyDemise.begin(demise_state, [spyders[1]], func() -> int: return 6)
	var demise_event: Dictionary = demise_state.get("pending_deadly_demise", {}).get("events", [{}])[0] if not demise_state.get("pending_deadly_demise", {}).get("events", []).is_empty() else demise_state.get("last_deadly_demise", {}).get("events", [{}])[0]
	check(str(demise.get("error", "")).is_empty() and demise_event.get("expression", "") == "1" and demise_event.get("triggered", false) and demise_event.get("targets", []).size() >= 2, "A destroyed Spyder rolls Deadly Demise 1 and affects each living unit in range on a 6")

	state.unit_abilities.setup_players = [1, 2]
	state.phase = "command"
	state.active = 1
	state.turn = 2
	state.units[scarabs[1]].wounds = 0
	state.units[scarabs[1]].on_battlefield = false
	state.units[scarabs[2]].wounds = 0
	state.units[scarabs[2]].on_battlefield = false
	Reanimation.start_command(state)
	UnitActions.reconcile(state)
	var decline_state: Dictionary = state.duplicate(true)
	var decline_choice := find_choice(decline_state, 1, "pass")
	var decline_result := PublicUnitCommand.submit(decline_state, 1, decline_choice)
	UnitActions.reconcile(decline_state)
	check(not decline_choice.is_empty() and str(decline_result.get("error", "")).is_empty() and decline_state.unit_abilities.window.is_empty(), "Canoptek Swarm remains an optional Command-phase ability that its controller can decline")
	var swarm := find_choice(state, 1, Spyders.SWARM_ACTION, spyders[0], scarab_squad)
	var swarm_result := PublicUnitCommand.submit(state, 1, swarm)
	check(not swarm.is_empty() and str(swarm_result.get("error", "")).is_empty() and Spyders.pending(state).get("models", []).size() == 2, "Command-phase Canoptek Swarm selects one nearby Scarab unit and queues one return per living Spyder")
	if Spyders.pending(state).is_empty():
		quit(1)
		return
	var returning: Array = Spyders.pending(state).models.duplicate()
	var invalid_choice := find_choice(state, 1, Spyders.PLACE_ACTION, int(returning[0]), scarab_squad)
	var invalid_placement := PublicUnitCommand.submit(state, 1, invalid_choice, Vector2(100.0, 100.0))
	check(not str(invalid_placement.get("error", "")).is_empty() and not Spyders.pending(state).get("placements", {}).has(int(returning[0])), "Canoptek Swarm rejects an off-board preview without recording it")
	for index in range(returning.size()):
		var placement := find_choice(state, 1, Spyders.PLACE_ACTION, int(returning[index]), scarab_squad)
		var destination := Vector2(7.0, 0.0 if index == 0 else -4.0)
		var placed := PublicUnitCommand.submit(state, 1, placement, destination)
		check(not placement.is_empty() and str(placed.get("error", "")).is_empty(), "Each destroyed Scarab gets a valid anchored placement preview: %s" % str(placed.get("error", "missing choice")))
	var confirm := find_choice(state, 1, Spyders.CONFIRM_ACTION, -1, scarab_squad)
	var confirmed := PublicUnitCommand.submit(state, 1, confirm)
	check(not confirm.is_empty() and str(confirmed.get("error", "")).is_empty() and Spyders.pending(state).is_empty(), "The player confirms all Canoptek Swarm placement choices through the public command (choice %s; error %s; validation %s)" % [str(confirm), str(confirmed.get("error", "")), Spyders.confirm_error(state)])
	check(Geometry.alive(state, scarab_squad).size() == 3 and state.units[returning[0]].wounds == int(state.units[returning[0]].max_wounds) and state.units[returning[1]].wounds == int(state.units[returning[1]].max_wounds), "Returned Scarabs come back at full Wounds without exceeding starting strength")
	check(find_choice(state, 1, Spyders.SWARM_ACTION, spyders[0], scarab_squad).is_empty(), "The Canoptek Swarm use is consumed for the current Command phase")

	if failures == 0:
		print("Canoptek Spyders: source profile, admission, equipment, auras, Deadly Demise and Canoptek Swarm passed.")
		quit(0)
	else:
		quit(1)
