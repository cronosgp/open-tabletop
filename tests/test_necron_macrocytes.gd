extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Macrocytes = preload("res://scripts/edition_11/canoptek_macrocytes.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const WeaponCharacteristics = preload("res://scripts/edition_11/weapon_characteristics.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const MACROCYTES_ID := "40kdc:11e:necrons:canoptek-macrocytes"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := {}
	for owner: int in [1, 2]:
		result[owner] = {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": MACROCYTES_ID, "models": 5, "copies": 1}]}
	return result

func models_for(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and Abilities.identity(unit) == "canoptek-macrocytes": result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, owner: int) -> int:
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		var living := Geometry.alive(state, squad)
		if not living.is_empty() and Abilities.identity(state.units[living[0]]) == "canoptek-macrocytes": return squad
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
	var profile := Profiles.profile("canoptek-macrocytes")
	var gauss: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var melee: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	var additional: Dictionary = profile.get("additional_weapon_profiles", {})
	var atomiser: Dictionary = additional.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var tesla: Dictionary = additional.get("ranged", [{}, {}])[1].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000004176" and profile.get("source_snapshot_id", "") == "20261031T053336Z" and profile.get("points_by_models", {}) == {5: 70} and profile.get("models", 0) == 5 and profile.get("base_size_source_mm", 0) == 28.5, "Macrocytes preserve the local App v1.2 identity, five-model size, 70-point cost and 28.5 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 8, "toughness": 3, "save_target": 4, "wounds": 1, "leadership_target": 8, "objective_control": 1, "invulnerable_target": 0}, "Macrocytes preserve their source characteristics")
	check(gauss.get("range_inches") == 18 and gauss.get("attacks") == 1 and gauss.get("skill") == 4 and gauss.get("strength") == 4 and gauss.get("ap") == -1 and gauss.get("damage") == 1 and gauss.get("keywords", {}) == {"lethal-hits": true}, "Gauss scalpel preserves its complete source profile")
	check(melee.get("attacks") == 2 and melee.get("skill") == 4 and melee.get("strength") == 4 and melee.get("ap") == -1 and melee.get("damage") == 1, "Claws preserve their complete source profile")
	check(atomiser.get("range_inches") == 12 and atomiser.get("skill") == 4 and atomiser.get("strength") == 6 and atomiser.get("ap") == -1 and tesla.get("range_inches") == 18 and tesla.get("strength") == 5 and tesla.get("keywords", {}) == {"assault": true, "sustained-hits": 1}, "Atomiser beam and Tesla caster preserve their source profiles and weapon traits")
	check(profile.get("supported_rule_ids", []).has("scouts-8") and profile.get("supported_rule_ids", []).has("harassment-swarm") and profile.get("supported_rule_ids", []).has("accelerator-mandible") and profile.get("supported_rule_ids", []).has("nanoscarab-projector") and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Macrocyte rule metadata records its complete locally checked scope")
	check(profile.get("source_options", []).size() == 3 and profile.get("source_options", []).all(func(option: Dictionary) -> bool: return option.get("implemented", false)), "All source-listed per-model Tesla and one-model specialist choices are implemented")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": MACROCYTES_ID, "models": 5, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 70, "The source-priced five-model squad is admitted to the consolidated Necron construction catalog")
	check(AbilityCatalog.RULES.get("canoptek-macrocytes", []).has("harassment-swarm") and AbilityCatalog.RULES.get("canoptek-macrocytes", []).has("accelerator-mandible") and AbilityCatalog.RULES.get("canoptek-macrocytes", []).has("nanoscarab-projector"), "The shared ability catalog binds all Macrocyte rule sources")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "Macrocyte fixture admits from the local construction catalog: " + str(state.get("error", "")))
		quit(1)
		return
	var owner_one := models_for(state, 1)
	var owner_two := models_for(state, 2)
	var squad_one := squad_for(state, 1)
	var squad_two := squad_for(state, 2)
	check(owner_one.size() == 5 and owner_two.size() == 5 and squad_one >= 0 and squad_two >= 0, "Both armies materialize the source unit size")
	if owner_one.size() != 5 or owner_two.size() != 5 or squad_one < 0 or squad_two < 0:
		quit(1)
		return

	state.unit_abilities.setup_players = [1]
	state.active = 2
	C.UnitActions.reconcile(state)
	for selection: Array in [[owner_two[0], Macrocytes.ATOMISER_PROJECTOR], [owner_two[1], Macrocytes.ACCELERATOR_MANDIBLE], [owner_two[2], Macrocytes.TESLA_CASTER]]:
		var option := find_choice(state, 2, "canoptek-macrocytes-loadout", int(selection[0]), squad_two, str(selection[1]))
		var submitted := PublicUnitCommand.submit(state, 2, option)
		check(not option.is_empty() and str(submitted.get("error", "")).is_empty(), "The public army-preparation choice configures " + Macrocytes.loadout_label(str(selection[1])))
	check(state.units[owner_two[0]].ranged_weapons.size() == 1 and state.units[owner_two[0]].ranged_weapons[0].get("id", "") == "source-ranged-1" and state.units[owner_two[0]].canoptek_macrocytes_loadout == Macrocytes.ATOMISER_PROJECTOR, "Atomiser replacement removes the default ranged weapon and grants its Projector source")
	check(state.units[owner_two[1]].ranged_weapons.is_empty() and state.units[owner_two[1]].canoptek_macrocytes_loadout == Macrocytes.ACCELERATOR_MANDIBLE, "Accelerator Mandible replaces the ranged weapon entirely")
	check(state.units[owner_two[2]].ranged_weapons[0].get("id", "") == "source-ranged-3" and state.units[owner_two[2]].canoptek_macrocytes_loadout == Macrocytes.TESLA_CASTER, "A regular model can replace its scalpel with a Tesla caster")
	check(not Macrocytes.valid_loadout_change(state, squad_two, owner_two[3], Macrocytes.ATOMISER_PROJECTOR), "The unit cannot exceed its one-model Atomiser and Projector limit")
	check(AbilityCatalog.sources(state, squad_two, "nanoscarab-projector") == [owner_two[0]] and AbilityCatalog.sources(state, squad_two, "accelerator-mandible") == [owner_two[1]], "Wargear abilities are granted only by the equipped specialist models")

	for model: int in owner_two: state.units[model].position = Vector2.ZERO
	for model: int in owner_one: state.units[model].position = Vector2(2.0, 0.0)
	check(Abilities.hit_bonus(state, squad_one, squad_two, false) == -1 and Abilities.hit_bonus(state, squad_one, squad_two, true) == -1, "Harassment Swarm worsens ranged and melee Hit rolls by 1 within 3 inches")
	for model: int in owner_one: state.units[model].position = Vector2(8.0, 0.0)
	check(Abilities.hit_bonus(state, squad_one, squad_two, false) == 0, "Harassment Swarm stops beyond 3 inches")
	for model: int in owner_one:
		state.units[model].position = Vector2(2.0, 0.0)
		if "VEHICLE" not in state.units[model].keywords: state.units[model].keywords.append("VEHICLE")
	check(Abilities.hit_bonus(state, squad_one, squad_two, false) == 0, "Harassment Swarm excludes Vehicle attackers")
	for model: int in owner_one:
		state.units[model].keywords.erase("VEHICLE")
		if "MONSTER" not in state.units[model].keywords: state.units[model].keywords.append("MONSTER")
	check(Abilities.hit_bonus(state, squad_one, squad_two, true) == 0, "Harassment Swarm excludes Monster attackers")
	for model: int in owner_one: state.units[model].keywords.erase("MONSTER")

	state.phase = "fight"
	state.active = 2
	state.turn = 2
	state.unit_abilities.phase_key = ""
	state.unit_abilities.window = {}
	C.UnitActions.reconcile(state)
	var mandible_choice := find_choice(state, 2, "canoptek-accelerator-mandible", owner_two[1], squad_two, "use")
	var mandible_result := PublicUnitCommand.submit(state, 2, mandible_choice)
	check(not mandible_choice.is_empty() and str(mandible_result.get("error", "")).is_empty(), "Accelerator Mandible is offered and resolves at the start of its owner's Fight phase")
	check(WeaponCharacteristics.modifier(state, squad_two, owner_two[1], "WS") == 1 and WeaponCharacteristics.apply_skill_modifier(4, WeaponCharacteristics.modifier(state, squad_two, owner_two[1], "WS")) == 3, "Accelerator Mandible improves the selected Canoptek melee Weapon Skill by 1")
	check(find_choice(state, 2, "canoptek-accelerator-mandible", owner_two[1], squad_two, "use").is_empty(), "The Accelerator bearer cannot use the ability twice in the same turn")
	Macrocytes.clear_fight_modifiers(state)
	check(WeaponCharacteristics.modifier(state, squad_two, owner_two[1], "WS") == 0, "The temporary Weapon Skill bonus clears after the Fight phase")

	state.phase = "command"
	state.active = 2
	state.turn = 4
	state.round = 2
	state.unit_abilities.phase_key = ""
	state.unit_abilities.window = {}
	state.reanimation.pending = {}
	state.units[owner_two[4]].wounds = 0
	state.units[owner_two[4]].on_battlefield = false
	Reanimation.start_command(state)
	check(Reanimation.open_end_command(state), "The active Necron player's living Macrocyte unit enters its Command-end Reanimation activation")
	var reanimation_decision := Reanimation.pending_decision(state)
	var has_projector_choice := false
	var has_plain_roll := false
	var projector_option: Dictionary = {}
	for option: Dictionary in reanimation_decision.get("legal_options", []):
		if option.get("action", "") != "reanimation" or int(option.get("target", -1)) != squad_two: continue
		if option.get("value", "") == "roll-projector" and int(option.get("model", -1)) == owner_two[0]:
			has_projector_choice = true
			projector_option = option
		if option.get("value", "") == "roll": has_plain_roll = true
	check(has_projector_choice and has_plain_roll, "Reanimation offers the optional Projector bonus alongside an ordinary roll")
	var projector_choice := {"action": "reanimation", "model": owner_two[0], "target": squad_two, "value": "roll-projector"}
	var projector_envelope := {"_decision_type": MatchCommands.REANIMATION_DECISION_ENVELOPE, "decision_id": str(reanimation_decision.get("decision_id", "")), "option_id": str(projector_option.get("id", "")), "choice": projector_choice}
	var projector_result := MatchCommands.execute(state, 2, {"kind": MatchCommands.RESOLVE_REANIMATION, "choice": projector_envelope, "point": Vector2.ZERO, "revision": int(state.revision)}, func() -> int: return 6)
	var projector_error := str(projector_result.get("error", ""))
	check(projector_error.is_empty() and int(Reanimation.pending(state).get("current", {}).get("budget", -1)) == 4 and int(Reanimation.pending(state).get("current", {}).get("nanoscarab_projector_bonus", -1)) == 1, "Using Nanoscarab Projector adds one wound to the D3 Reanimation budget")
	check(state.unit_abilities.used.get(Reanimation.nanoscarab_projector_use_key(owner_two[0], 2), false), "The Projector records its once-per-battle-round use")

	if failures == 0:
		print("Canoptek Macrocytes: source profile, admission, loadouts, Harassment Swarm, Accelerator Mandible and Nanoscarab Projector passed.")
		quit(0)
	else:
		quit(1)
