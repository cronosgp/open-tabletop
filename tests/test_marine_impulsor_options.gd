extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Scouts = preload("res://scripts/edition_11/scout_moves.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var state := F.fresh()
	state.units.clear()
	state.squads.clear()
	state.phase = "deployment"
	state.active = 1
	state.turn = 1
	state.points_limit = 1000
	state.training_points = {1: 70, 2: 0}
	state.unit_abilities.window = {}
	state.awakened_dynasty.pending = []
	state.stratagems.pending = {}
	var profile := Profiles.profile("impulsor")
	state.squads[1] = {"owner": 1, "name": "Impulsor", "starting_strength": 1, "stats": profile.stats.duplicate(true), "advanced": false, "shot": false}
	state.units[100] = {"owner": 1, "squad": 1, "definition_id": "40kdc:11e:adeptus-astartes:impulsor", "position": Vector2(-10, 0), "radius": profile.base_radius_inches, "keywords": profile.keywords.duplicate(), "wounds": profile.stats.wounds, "max_wounds": profile.stats.wounds, "on_battlefield": true, "ranged_weapons": profile.ranged.duplicate(true), "melee_weapons": profile.melee.duplicate(true), "transport_profile": profile.transport.duplicate(true)}
	UnitAbilities.enable(state)
	state.unit_abilities.window = {}
	state.awakened_dynasty.pending = []
	return state

func choose(state: Dictionary, category: int, value: String) -> String:
	for option: Dictionary in UnitActions.choices(state, 1):
		if option.get("action", "") == "impulsor-loadout" and int(option.get("target", -1)) == category and str(option.get("value", "")) == value:
			return str(PublicUnitCommand.submit(state, 1, option).get("error", ""))
	return "Impulsor loadout choice is not offered: %d/%s" % [category, value]

func weapon_ids(state: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for weapon: Dictionary in state.units[100].ranged_weapons: ids.append(str(weapon.id))
	return ids

func run() -> void:
	var state := make_state()
	var options := UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return option.action == "impulsor-loadout")
	check(options.size() == 6, "Army preparation presents each source-listed Impulsor system, Storm Bolter replacement and stubber choice")
	check(UnitAbilities.scout_distance(state, 1) == 0 and not Transport.datasheet_has_ability(state, 100, "Orbital Comms Array"), "The Impulsor has no Orbital Comms benefit before its optional system is chosen")
	var orbital := options.filter(func(option: Dictionary) -> bool: return option.target == 0 and option.value == "orbital-comms-array")
	check(not orbital.is_empty(), "Impulsor setup exposes Orbital Comms Array")
	if not orbital.is_empty():
		var result := PublicUnitCommand.submit(state, 1, orbital[0], Vector2.ZERO, Callable())
		check(result.get("error", "").is_empty(), "Orbital Comms Array can be selected through the shared preparation action")
	check(state.training_points[1] == 80 and UnitAbilities.scout_distance(state, 1) == 6, "Orbital Comms Array adds 10 local points and grants Scouts 6")
	check(Transport.datasheet_has_ability(state, 100, "Orbital Comms Array"), "The local Impulsor profile records the optional Orbital Comms ability")
	var scout_state := state.duplicate(true)
	scout_state.units[100].position = scout_state.deployment.zones[1].get_center()
	Scouts.begin(scout_state)
	check(Scouts.actor(scout_state) == 1 and scout_state.unit_abilities.window.get("squad", -1) == 1, "Orbital Comms Array enters the Impulsor into the Core Scout move sequence")
	var profile := Groups.profile(state, 100)
	check(profile.get("error", "").is_empty() and profile.invulnerable_target == 0, "Orbital Comms Array does not grant the Shield Dome save")
	check(choose(state, 0, "shield-dome").is_empty() and state.training_points[1] == 70, "Switching the one-of option to Shield Dome removes the Orbital Comms surcharge")
	profile = Groups.profile(state, 100)
	check(profile.get("error", "").is_empty() and profile.invulnerable_target == 5 and UnitAbilities.scout_distance(state, 1) == 0, "Shield Dome grants 5+ invulnerable while removing Scouts 6")
	check(choose(state, 0, "ironhail-skytalon-array").is_empty() and "ironhail-skytalon-array" in weapon_ids(state), "Ironhail Skytalon Array enters the ranged weapon inventory")
	check(choose(state, 0, "bellicatus-missile-array").is_empty() and "bellicatus-missile-array" in weapon_ids(state), "Bellicatus Missile Array enters the ranged weapon inventory")
	state.terrain.areas = []
	state.squads[2] = {"owner": 2, "name": "Enemy", "starting_strength": 1, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "objective_control": 1}}
	state.units[200] = {"owner": 2, "squad": 2, "definition_id": "40kdc:11e:test:enemy", "position": Vector2(2, 0), "radius": 0.5, "keywords": ["INFANTRY", "FLY"], "wounds": 2, "max_wounds": 2, "on_battlefield": true}
	var missile_profiles: Array[String] = []
	for option: Dictionary in Equipment.choices(state, 100, false):
		if option.weapon == "bellicatus-missile-array": missile_profiles.append(str(option.profile))
	check(missile_profiles.size() == 3 and "frag" in missile_profiles and "icarus" in missile_profiles and "krak" in missile_profiles, "Bellicatus exposes all three Wahapedia firing profiles through the weapon selector")
	for profile_id: String in ["frag", "icarus", "krak"]:
		var selected := Equipment.select(state, 100, false, "bellicatus-missile-array", profile_id)
		check(not selected.has("error") and not AttackPlan.legal_targets(state, 100, false, "bellicatus-missile-array", profile_id).is_empty(), "Bellicatus %s profile can be selected for a legal ranged target" % profile_id)
		if not selected.has("error"):
			var expected: Dictionary = {"frag": {"attacks": 4, "strength": 4, "ap": -1, "damage": 1}, "icarus": {"attacks": 3, "strength": 6, "ap": -1, "damage": 2}, "krak": {"attacks": 1, "strength": 10, "ap": -2, "damage": "D3+3"}}[profile_id]
			check(selected.stats.attacks == expected.attacks and selected.stats.strength == expected.strength and selected.stats.ap == expected.ap and selected.stats.damage == expected.damage, "Bellicatus %s attack plan uses its extracted local weapon characteristics" % profile_id)
	check(choose(state, 1, "on").is_empty() and "fragstorm-grenade-launchers" in weapon_ids(state) and "storm-bolters" not in weapon_ids(state), "Fragstorm Grenade Launchers replace the Storm Bolters")
	check(choose(state, 2, "on").is_empty() and "ironhail-heavy-stubber" in weapon_ids(state), "Ironhail Heavy Stubber is added to the ranged inventory")
	var orbital_again := UnitActions.choices(state, 1).filter(func(option: Dictionary) -> bool: return option.action == "impulsor-loadout" and option.target == 0 and option.value == "orbital-comms-array")
	if not orbital_again.is_empty():
		state.training_points[1] = 1000
		var rejected := PublicUnitCommand.submit(state, 1, orbital_again[0], Vector2.ZERO, Callable())
		check(not rejected.get("error", "").is_empty() and state.units[100].impulsor_system == "bellicatus-missile-array", "Orbital Comms surcharge is rejected if it exceeds the army points limit")
	print("Impulsor option rules: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
