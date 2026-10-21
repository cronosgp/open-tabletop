extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
var failures := 0

func six() -> int:
	return 6

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var state := F.fresh()
	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.terrain.areas = []
	state.units.clear()
	state.squads.clear()
	state.awakened_dynasty.pending = []
	state.stratagems.attack_rerolls = false
	state.stratagems.save_rerolls = false
	state.stratagems.damage_rerolls = false
	state.stratagems.count_rerolls = false
	state.manual_allocation = false
	var profile := Profiles.profile("land-raider")
	var weapons: Array = profile.ranged.duplicate(true)
	var first_missile: Dictionary = profile.additional_weapon_profiles.ranged[0].duplicate(true)
	var second_missile: Dictionary = first_missile.duplicate(true)
	second_missile.id = "second-one-shot-missile"
	weapons.append(first_missile)
	weapons.append(second_missile)
	state.squads[1] = {"owner": 1, "name": "Marine vehicle", "starting_strength": 1, "stats": profile.stats.duplicate(true), "shot": false, "advanced": false, "fell_back": false, "moved_distance": 0.0, "battle_shocked": false}
	state.units[100] = {"owner": 1, "squad": 1, "definition_id": "40kdc:11e:test:one-shot-platform", "position": Vector2(-12, 0), "radius": profile.base_radius_inches, "keywords": ["ADEPTUS ASTARTES", "VEHICLE"], "wounds": profile.stats.wounds, "max_wounds": profile.stats.wounds, "on_battlefield": true, "ranged_weapons": weapons, "melee_weapons": profile.melee.duplicate(true)}
	state.squads[2] = {"owner": 2, "name": "Durable target", "starting_strength": 1, "stats": {"toughness": 4, "save_target": 7, "wounds": 20, "objective_control": 1}, "battle_shocked": false}
	state.units[200] = {"owner": 2, "squad": 2, "definition_id": "test:target", "position": Vector2(0, 0), "radius": 0.5, "keywords": ["INFANTRY"], "wounds": 20, "max_wounds": 20, "on_battlefield": true}
	UnitAbilities.enable(state)
	state.unit_abilities.window = {}
	return state

func run() -> void:
	var state := make_state()
	var options := AttackPlan.Equipment.choices(state, 100, false).filter(func(option: Dictionary) -> bool: return option.weapon == "hunter-killer-missile")
	check(options.size() == 1 and options[0].stats.keywords.get("one-shot", false), "Local Land Raider export identifies the Hunter-killer Missile as One Shot")
	if options.is_empty():
		print("Marine One Shot checks: %d failures" % (failures + 1))
		quit(1)
		return
	var entry := {"model": 100, "target": 2, "amount": 1, "weapon": "hunter-killer-missile", "profile": "standard"}
	check(2 in AttackPlan.legal_targets(state, 100, false, entry.weapon, entry.profile), "Unused One Shot weapon can target an in-range visible enemy")
	state.unit_abilities.window = {"kind": "test-reaction", "owners": [1], "declaration": {"kind": "attack"}}
	check(not Combat.attack_plan_error(state, 1, 100, [entry], state.revision, false).is_empty(), "A paused attack declaration cannot be duplicated while its optional reaction is pending")
	state.unit_abilities.window = {}
	var plan_error := Combat.attack_plan_error(state, 1, 100, [entry], state.revision, false)
	check(plan_error.is_empty(), "Unused One Shot weapon passes attack-plan validation")
	var result := Combat.resolve_attack_plan(state, 1, 100, [entry], state.revision, false, false, six)
	check(result.get("error", "").is_empty(), "One Shot weapon resolves through the normal attack sequence")
	check(state.units[100].get("one_shot_weapons_used", {}).get("hunter-killer-missile", false), "Firing consumes this model's One Shot weapon at declaration")
	check(AttackPlan.legal_targets(state, 100, false, entry.weapon, entry.profile).is_empty(), "Spent One Shot weapon no longer offers attack targets")
	check(2 in AttackPlan.legal_targets(state, 100, false, "second-one-shot-missile", "standard"), "A different One Shot weapon on the same model retains its own use")
	state.squads[1].shot = false
	state.turn += 1
	var second_entry := {"model": 100, "target": 2, "amount": 1, "weapon": "second-one-shot-missile", "profile": "standard"}
	check(not AttackPlan.prepare(state, 1, false, [entry], false).get("error", "").is_empty(), "A spent One Shot weapon cannot be declared again even if its normal shooting flag is reset")
	check(AttackPlan.prepare(state, 1, false, [second_entry], false).get("error", "").is_empty(), "A separate One Shot weapon can be declared in a later shooting phase")
	print("Marine One Shot checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
