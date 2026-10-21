extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
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

func run() -> void:
	var variants := {
		"land-raider": ["hunter-killer-missile", "multi-melta", "storm-bolter"],
		"land-raider-crusader": ["hunter-killer-missile", "multi-melta", "storm-bolter"],
		"land-raider-redeemer": ["hunter-killer-missile", "multi-melta", "storm-bolter"],
		"rhino": ["hunter-killer-missile"]
	}
	var ordinal := 0
	for identity: String in variants:
		var model := 100 + ordinal
		ordinal += 1
		var state := make_state(identity, model)
		var initial_points := int(state.training_points.get(1, 0))
		var profile := Profiles.profile(identity)
		var expected: Array = variants[identity]
		var actions := UnitActions.choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "transport-weapon-loadout")
		check(profile.transport.options.add.size() == expected.size() and actions.size() == expected.size(), "%s preparation exposes its source-listed optional weapons" % profile.name)
		for weapon_id: String in expected:
			var selected := actions.filter(func(choice: Dictionary) -> bool: return str(choice.value).begins_with(weapon_id + ":on"))
			check(not selected.is_empty(), "%s offers %s from its extracted profile" % [profile.name, weapon_id])
			if selected.is_empty(): continue
			var result := UnitActions.apply(state, 1, selected[0], Vector2.ZERO, Callable())
			check(result.get("error", "").is_empty() and weapon_id in state.units[model].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)), "%s can equip %s in Army Preparation" % [profile.name, weapon_id])
			if weapon_id == "hunter-killer-missile":
				var missile := Equipment.select(state, model, false, weapon_id, "standard")
				check(not missile.has("error") and missile.stats.keywords.get("one-shot", false), "Equipped Hunter-killer Missile retains One Shot from the local export")
		var updated := UnitActions.choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "transport-weapon-loadout")
		check(updated.size() == expected.size() and updated.all(func(choice: Dictionary) -> bool: return str(choice.value).ends_with(":off")), "%s exposes reversible removal for each equipped optional weapon" % profile.name)
		if not updated.is_empty():
			var removed := UnitActions.apply(state, 1, updated[0], Vector2.ZERO, Callable())
			check(removed.get("error", "").is_empty(), "%s optional weapon can be removed before deployment" % profile.name)
		check(state.training_points.get(1, 0) == initial_points, "%s optional weapons add no cost absent from its extracted wargear costs" % profile.name)
	var invalid := make_state("land-raider", 500)
	check(not Transport.configure_optional_transport_weapon(invalid, 500, "unlisted-weapon:on").is_empty(), "Unknown transport option is rejected")
	invalid.phase = "shooting"
	check(not Transport.configure_optional_transport_weapon(invalid, 500, "hunter-killer-missile:on").is_empty(), "Optional transport wargear cannot be changed after army preparation")
	print("Optional transport weapon checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
