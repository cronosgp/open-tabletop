extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state(identity: String, model: int) -> Dictionary:
	var state := F.fresh()
	state.units.clear()
	state.squads.clear()
	state.phase = "deployment"
	state.active = 1
	state.awakened_dynasty.pending = []
	state.unit_abilities.window = {}
	state.unit_abilities.setup_players = []
	var profile := Profiles.profile(identity)
	state.squads[model] = {"owner": 1, "name": profile.name, "starting_strength": 1, "stats": profile.stats.duplicate(true)}
	state.units[model] = {"owner": 1, "squad": model, "definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "position": Vector2(-12, 0), "radius": profile.base_radius_inches, "keywords": profile.keywords.duplicate(), "wounds": profile.stats.wounds, "max_wounds": profile.stats.wounds, "on_battlefield": true, "ranged_weapons": profile.ranged.duplicate(true), "melee_weapons": profile.melee.duplicate(true), "transport_profile": profile.transport.duplicate(true)}
	return state

func choices(state: Dictionary, player: int = 1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for option: Dictionary in UnitActions.choices(state, player):
		if option.action == "transport-weapon-loadout": result.append(option)
	return result

func apply(state: Dictionary, action: Dictionary) -> Dictionary:
	return PublicUnitCommand.submit(state, 1, action, Vector2.ZERO, Callable())

func contains_weapon(state: Dictionary, model: int, weapon_id: String) -> bool:
	for weapon: Dictionary in state.units[model].ranged_weapons:
		if weapon.id == weapon_id: return true
	return false

func run() -> void:
	var repulsor := make_state("repulsor", 600)
	var repulsor_initial_points := int(repulsor.training_points.get(1, 0))
	var repulsor_profile := Profiles.profile("repulsor")
	var repulsor_options := choices(repulsor)
	check(repulsor_profile.transport.options.replacements.size() == 2 and repulsor_options.size() == 2, "Repulsor preparation exposes both source-listed weapon replacements")
	for pair: Array in [["heavy-onslaught-gatling-cannon", "las-talon"], ["twin-heavy-bolter", "twin-lascannon"]]:
		var base_id: String = pair[0]
		var replacement_id: String = pair[1]
		var option := repulsor_options.filter(func(choice: Dictionary) -> bool: return str(choice.value).begins_with("replace:%s:%s" % [base_id, replacement_id]))
		check(not option.is_empty(), "Repulsor exposes replacement %s" % replacement_id)
		if option.is_empty(): continue
		var applied := apply(repulsor, option[0])
		check(applied.get("error", "").is_empty() and not contains_weapon(repulsor, 600, base_id) and contains_weapon(repulsor, 600, replacement_id), "Repulsor replacement updates the combat inventory for %s" % replacement_id)
		var current_options := choices(repulsor)
		var reverse := current_options.filter(func(choice: Dictionary) -> bool: return str(choice.value) == "replace:%s:%s" % [base_id, base_id])
		check(not reverse.is_empty(), "Repulsor exposes a reversible choice for %s" % replacement_id)
		if not reverse.is_empty():
			var reverted := apply(repulsor, reverse[0])
			check(reverted.get("error", "").is_empty() and contains_weapon(repulsor, 600, base_id) and not contains_weapon(repulsor, 600, replacement_id), "Repulsor can restore its source-listed %s" % base_id)
	check(repulsor.training_points.get(1, 0) == repulsor_initial_points, "Repulsor weapon replacements do not add points absent a source-listed cost")

	var executioner := make_state("repulsor-executioner", 700)
	var profile := Profiles.profile("repulsor-executioner")
	executioner.training_points[1] = int(profile.points) + int(profile.wargear_costs.get("Heavy Laser Destroyer", 0))
	var macro := choices(executioner).filter(func(choice: Dictionary) -> bool: return str(choice.value).ends_with(":macro-plasma-incinerator"))
	check(macro.size() == 1, "Executioner preparation exposes its Macro Plasma Incinerator replacement")
	if not macro.is_empty():
		var selected := apply(executioner, macro[0])
		check(selected.get("error", "").is_empty() and not contains_weapon(executioner, 700, "heavy-laser-destroyer") and contains_weapon(executioner, 700, "macro-plasma-incinerator"), "Executioner replacement installs the local Macro Plasma profile")
		check(executioner.training_points[1] == int(profile.points), "Replacing the +10-point Heavy Laser Destroyer removes its source-listed surcharge")
		var plasma_profiles: Array[String] = []
		for option: Dictionary in Equipment.choices(executioner, 700, false):
			if option.weapon == "macro-plasma-incinerator": plasma_profiles.append(option.profile)
		check("standard" in plasma_profiles and "supercharge" in plasma_profiles, "Both Macro Plasma Incinerator firing profiles enter the attack selector")
		executioner.points_limit = int(profile.points) + 5
		var reject_laser := choices(executioner).filter(func(choice: Dictionary) -> bool: return str(choice.value).ends_with(":heavy-laser-destroyer"))
		if not reject_laser.is_empty():
			var rejected := apply(executioner, reject_laser[0])
			check(not rejected.get("error", "").is_empty() and contains_weapon(executioner, 700, "macro-plasma-incinerator") and executioner.training_points[1] == int(profile.points), "Restoring the +10-point weapon is rejected when it exceeds the army limit")
		executioner.points_limit = 1000
		var restore := choices(executioner).filter(func(choice: Dictionary) -> bool: return str(choice.value).ends_with(":heavy-laser-destroyer"))
		if not restore.is_empty():
			var restored := apply(executioner, restore[0])
			check(restored.get("error", "").is_empty() and contains_weapon(executioner, 700, "heavy-laser-destroyer") and executioner.training_points[1] == int(profile.points) + 10, "Executioner can restore its Heavy Laser Destroyer and surcharge before deployment")
	print("Repulsor transport loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
