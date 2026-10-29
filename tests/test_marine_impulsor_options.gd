extends SceneTree
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Fixture = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Scouts = preload("res://scripts/edition_11/scout_moves.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const FiringDeck = preload("res://scripts/edition_11/firing_deck.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0
var impulsor_model := 100
const TEST_TARGET_SQUAD := 9900
const TEST_TARGET_MODEL := 9901

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var selections := Fixture.current_marine_selections()
	selections[1].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:impulsor", "models": 1, "copies": 1}]
	selections[2].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	var state := Prepared.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections)
	if state.has("error"): return state
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.points_limit = 1000
	state.unit_abilities.window = {}
	var found_impulsor := false
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1 and UnitAbilities.identity(state.units[model]) == "impulsor":
			impulsor_model = model
			found_impulsor = true
			state.units[model].position = Vector2(-10, 0)
			break
	if not found_impulsor: return {"error": "The current catalog did not materialize the prepared Impulsor."}
	return state

func choose(state: Dictionary, category: int, value: String) -> String:
	for option: Dictionary in UnitActions.choices(state, 1):
		if option.get("action", "") == "impulsor-loadout" and int(option.get("target", -1)) == category and str(option.get("value", "")) == value:
			return str(PublicUnitCommand.submit(state, 1, option).get("error", ""))
	return "Impulsor loadout choice is not offered: %d/%s" % [category, value]

func weapon_ids(state: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for weapon: Dictionary in state.units[impulsor_model].ranged_weapons: ids.append(str(weapon.id))
	return ids

func assert_weapon_plan(state: Dictionary, melee: bool, weapon_id: String, profile_id: String, expected: Dictionary) -> void:
	var planning_state: Dictionary = state
	if melee:
		planning_state = state.duplicate(true)
		planning_state.phase = "fight"
		planning_state.active = 1
		planning_state.units[impulsor_model].position = Vector2.ZERO
		planning_state.units[TEST_TARGET_MODEL].position = Vector2(1.8, 0.0)
	var selected := Equipment.select(planning_state, impulsor_model, melee, weapon_id, profile_id)
	var label := "%s/%s" % [weapon_id, profile_id]
	check(not selected.has("error"), "%s is selectable from the equipped Impulsor inventory" % label)
	if selected.has("error"): return
	var matches := true
	var stats: Dictionary = selected.stats
	for field: String in ["name", "attacks", "skill", "strength", "ap", "damage", "keywords"]:
		if stats.get(field) != expected.get(field): matches = false
	if not is_equal_approx(float(stats.get("range_inches", -1.0)), float(expected.get("range_inches", -2.0))): matches = false
	check(matches, "%s matches every extracted weapon profile field; actual=%s expected=%s" % [label, str(stats), str(expected)])
	check(not AttackPlan.legal_targets(planning_state, impulsor_model, melee, weapon_id, profile_id).is_empty(), "%s reaches the legal-target stage of AttackPlan" % label)

func run() -> void:
	var state := make_state()
	if state.has("error"):
		check(false, "Impulsor test state is prepared from the current Space Marines catalog: " + str(state.get("error", "unknown error")))
		quit(1)
		return
	var impulsor_profile := Profiles.profile("impulsor")
	check(impulsor_profile.source_book_id == "000000139" and impulsor_profile.source_datasheet_id == "000002568" and impulsor_profile.source_snapshot_id == "20261021T130623Z", "The Impulsor keeps its shared-book identity and verified local export snapshot")
	check(impulsor_profile.models == 1, "The Impulsor source composition contains one model")
	check(impulsor_profile.points_by_models.get(1, -1) == 70 and impulsor_profile.third_plus_points_by_models.get(1, -1) == 70, "The first three Impulsor copy prices match the source")
	check(impulsor_profile.fourth_plus_points_by_models.get(1, -1) == 80, "The source fourth-plus Impulsor price tier remains cataloged")
	check(impulsor_profile.wargear_costs == {"Orbital Comms Array": 10}, "Orbital Comms Array's source points surcharge is retained: " + str(impulsor_profile.wargear_costs))
	check(impulsor_profile.base_size_source_mm == 100 and impulsor_profile.base_geometry == "circle" and impulsor_profile.geometry_scope == "Wahapedia specifies a 100 mm diameter circle; runtime uses the corresponding circular footprint." and is_equal_approx(float(impulsor_profile.base_radius_inches), 50.0 / 25.4), "The source-listed 100 mm circular footprint is represented with its matching runtime radius")
	check(impulsor_profile.stats == {"movement_inches": 12, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 2, "invulnerable_target": 0}, "All fixed Impulsor characteristics match the local export")
	check(impulsor_profile.keywords == ["ADEPTUS ASTARTES", "VEHICLE", "TRANSPORT", "IMPERIUM", "DEDICATED TRANSPORT", "FRAME"], "The complete source keyword set is retained")
	check(impulsor_profile.transport.capacity == 7 and impulsor_profile.transport.required == ["ADEPTUS ASTARTES", "INFANTRY"] and impulsor_profile.transport.forbidden == ["TERMINATOR", "JUMP PACK"] and impulsor_profile.transport.double_space == ["GRAVIS"], "Transport capacity, required types, exclusions and Gravis occupancy match the source")
	check(FiringDeck.model_limit({"units": {impulsor_model: {"transport_profile": impulsor_profile.transport}}}, impulsor_model) == 7 and UnitAbilities.deadly_demise_value(state, impulsor_model) == "D3", "Firing Deck 7 and Deadly Demise D3 use their source parameters")
	var options := UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return option.action == "impulsor-loadout")
	check(options.size() == 6, "Army preparation presents each source-listed Impulsor system, Storm Bolter replacement and stubber choice")
	check(options.filter(func(option: Dictionary) -> bool: return option.target == 0).map(func(option: Dictionary) -> String: return str(option.value)).size() == 4, "The mutually exclusive system slot offers its four source-listed choices")
	state.terrain.areas = []
	state.squads[TEST_TARGET_SQUAD] = {"owner": 2, "name": "Test Enemy", "starting_strength": 1, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "objective_control": 1}}
	state.units[TEST_TARGET_MODEL] = {"owner": 2, "squad": TEST_TARGET_SQUAD, "definition_id": "40kdc:11e:test:enemy", "position": Vector2(2, 0), "radius": 0.5, "keywords": ["INFANTRY", "FLY"], "wounds": 2, "max_wounds": 2, "on_battlefield": true}
	assert_weapon_plan(state, false, "storm-bolters", "standard", {"name": "Storm Bolters", "range_inches": 24.0, "attacks": 4, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 4}})
	assert_weapon_plan(state, true, "armoured-hull", "standard", {"name": "Armoured Hull", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}})
	check(UnitAbilities.scout_distance(state, 1) == 0 and not Transport.datasheet_has_ability(state, impulsor_model, "Orbital Comms Array"), "The Impulsor has no Orbital Comms benefit before its optional system is chosen")
	var orbital := options.filter(func(option: Dictionary) -> bool: return option.target == 0 and option.value == "orbital-comms-array")
	check(not orbital.is_empty(), "Impulsor setup exposes Orbital Comms Array")
	if not orbital.is_empty():
		var before_wrong_owner := var_to_bytes(state)
		var wrong_owner := PublicUnitCommand.submit(state, 2, orbital[0], Vector2.ZERO, Callable())
		check(not str(wrong_owner.get("error", "")).is_empty() and before_wrong_owner == var_to_bytes(state), "Another player cannot change the Impulsor loadout or mutate the prepared state")
		var result := PublicUnitCommand.submit(state, 1, orbital[0], Vector2.ZERO, Callable())
		check(result.get("error", "").is_empty(), "Orbital Comms Array can be selected through the shared preparation action")
	check(state.training_points[1] == 80 and UnitAbilities.scout_distance(state, 1) == 6, "Orbital Comms Array adds 10 local points and grants Scouts 6")
	check(Transport.datasheet_has_ability(state, impulsor_model, "Orbital Comms Array"), "The local Impulsor profile records the optional Orbital Comms ability")
	if not orbital.is_empty():
		var before_stale := var_to_bytes(state)
		var stale := PublicUnitCommand.submit(state, 1, orbital[0], Vector2.ZERO, Callable())
		check(not str(stale.get("error", "")).is_empty() and before_stale == var_to_bytes(state), "A stale Impulsor system choice is rejected without mutation")
	var scout_state := state.duplicate(true)
	scout_state.units[impulsor_model].position = scout_state.deployment.zones[1].get_center()
	Scouts.begin(scout_state)
	check(Scouts.actor(scout_state) == 1 and scout_state.unit_abilities.window.get("squad", -1) == 1, "Orbital Comms Array enters the Impulsor into the Core Scout move sequence")
	var defense := Groups.profile(state, impulsor_model)
	check(defense.get("error", "").is_empty() and defense.invulnerable_target == 0, "Orbital Comms Array does not grant the Shield Dome save")
	check(choose(state, 0, "shield-dome").is_empty() and state.training_points[1] == 70, "Switching the one-of option to Shield Dome removes the Orbital Comms surcharge")
	defense = Groups.profile(state, impulsor_model)
	check(defense.get("error", "").is_empty() and defense.invulnerable_target == 5 and UnitAbilities.scout_distance(state, 1) == 0, "Shield Dome grants 5+ invulnerable while removing Scouts 6")
	check(choose(state, 0, "ironhail-skytalon-array").is_empty() and "ironhail-skytalon-array" in weapon_ids(state), "Ironhail Skytalon Array enters the ranged weapon inventory")
	assert_weapon_plan(state, false, "ironhail-skytalon-array", "standard", {"name": "Ironhail Skytalon Array", "range_inches": 36.0, "attacks": 6, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 6}})
	check(choose(state, 0, "bellicatus-missile-array").is_empty() and "bellicatus-missile-array" in weapon_ids(state), "Bellicatus Missile Array enters the ranged weapon inventory")
	assert_weapon_plan(state, false, "bellicatus-missile-array", "frag", {"name": "Bellicatus Missile Array - Frag", "range_inches": 48.0, "attacks": 4, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 1}})
	assert_weapon_plan(state, false, "bellicatus-missile-array", "icarus", {"name": "Bellicatus Missile Array - Icarus", "range_inches": 48.0, "attacks": 3, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"anti-fly": 2}})
	assert_weapon_plan(state, false, "bellicatus-missile-array", "krak", {"name": "Bellicatus Missile Array - Krak", "range_inches": 48.0, "attacks": 1, "skill": 3, "strength": 10, "ap": -2, "damage": "D3+3", "keywords": {}})
	var missile_profiles: Array[String] = []
	for option: Dictionary in Equipment.choices(state, impulsor_model, false):
		if option.weapon == "bellicatus-missile-array": missile_profiles.append(str(option.profile))
	check(missile_profiles.size() == 3 and "frag" in missile_profiles and "icarus" in missile_profiles and "krak" in missile_profiles, "Bellicatus exposes all three Wahapedia firing profiles through the weapon selector")
	for profile_id: String in ["frag", "icarus", "krak"]:
		var selected := Equipment.select(state, impulsor_model, false, "bellicatus-missile-array", profile_id)
		check(not selected.has("error") and not AttackPlan.legal_targets(state, impulsor_model, false, "bellicatus-missile-array", profile_id).is_empty(), "Bellicatus %s profile can be selected for a legal ranged target" % profile_id)
	check(choose(state, 0, "none").is_empty() and "bellicatus-missile-array" not in weapon_ids(state) and state.training_points[1] == 70, "The one-of system can be removed and restores the base loadout and cost")
	check(choose(state, 1, "on").is_empty() and "fragstorm-grenade-launchers" in weapon_ids(state) and "storm-bolters" not in weapon_ids(state), "Fragstorm Grenade Launchers replace the Storm Bolters")
	assert_weapon_plan(state, false, "fragstorm-grenade-launchers", "standard", {"name": "Fragstorm Grenade Launchers", "range_inches": 18.0, "attacks": 6, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"blast": 2}})
	check(choose(state, 1, "off").is_empty() and "storm-bolters" in weapon_ids(state) and "fragstorm-grenade-launchers" not in weapon_ids(state), "Restoring Storm Bolters reverses the weapon replacement")
	check(choose(state, 2, "on").is_empty() and "ironhail-heavy-stubber" in weapon_ids(state), "Ironhail Heavy Stubber is added to the ranged inventory")
	assert_weapon_plan(state, false, "ironhail-heavy-stubber", "standard", {"name": "Ironhail Heavy Stubber", "range_inches": 36.0, "attacks": 3, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 3}})
	check(choose(state, 2, "off").is_empty() and "ironhail-heavy-stubber" not in weapon_ids(state), "Ironhail Heavy Stubber can be removed before deployment")
	var orbital_again := UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return option.action == "impulsor-loadout" and option.target == 0 and option.value == "orbital-comms-array")
	if not orbital_again.is_empty():
		state.training_points[1] = 1000
		var rejected := PublicUnitCommand.submit(state, 1, orbital_again[0], Vector2.ZERO, Callable())
		check(not rejected.get("error", "").is_empty() and state.units[impulsor_model].impulsor_system == "none", "Orbital Comms surcharge is rejected if it exceeds the army points limit")
	print("Impulsor option rules: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
