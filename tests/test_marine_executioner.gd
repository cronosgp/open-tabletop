extends SceneTree
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func run() -> void:
	var profile := Profiles.profile("repulsor-executioner")
	var state := {
		"phase": "shooting", "active": 1, "turn": 1, "round": 1, "board_size": Vector2(48, 36),
		"terrain": {"id": "terrain-11e-v1", "areas": []}, "squads": {}, "units": {},
		"unit_abilities": {}, "points_limit": 2000
	}
	state.squads[1] = {"owner": 1, "name": "Repulsor Executioner", "starting_strength": 1, "stats": profile.stats.duplicate(true), "shot": false, "advanced": false, "moved_distance": 0.0}
	state.units[100] = {"owner": 1, "squad": 1, "definition_id": "40kdc:11e:adeptus-astartes:repulsor-executioner", "position": Vector2(-12, 0), "radius": profile.base_radius_inches, "keywords": profile.keywords.duplicate(), "wounds": profile.stats.wounds, "max_wounds": profile.stats.wounds, "on_battlefield": true, "ranged_weapons": profile.ranged.duplicate(true), "melee_weapons": profile.melee.duplicate(true)}
	state.squads[2] = {"owner": 2, "name": "Enemy at half strength", "starting_strength": 5, "stats": {"toughness": 4, "save_target": 3, "wounds": 2, "objective_control": 1}, "battle_shocked": false}
	for model in range(5):
		state.units[200 + model] = {"owner": 2, "squad": 2, "definition_id": "test:infantry", "position": Vector2(model * 0.5, 0), "radius": 0.1, "keywords": ["INFANTRY"], "wounds": 2, "max_wounds": 2, "on_battlefield": true}
	UnitAbilities.enable(state)
	check(UnitAbilities.has(state, 1, "executioner"), "Local Repulsor Executioner profile registers its source ability")
	check(not Morale.below_half_strength(state, 2), "A five-model unit with three models remaining is not below half-strength")
	var weapons: Array = AttackPlan.Equipment.choices(state, 100, false)
	var assignment: Dictionary = {"model": 100, "target": 2, "amount": 1, "weapon": weapons[0].weapon, "profile": weapons[0].profile}
	var prepared := AttackPlan.prepare(state, 1, false, [assignment], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].context.hit_modifier == 1, "Executioner adds +1 to ranged Hit rolls against a target that is not below half-strength")
	for model in [202, 203, 204]: state.units[model].wounds = 0
	state.squads[2].starting_strength = 4
	check(not Morale.below_half_strength(state, 2), "A four-model unit with two models remaining is exactly half-strength, not below")
	prepared = AttackPlan.prepare(state, 1, false, [assignment], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].context.hit_modifier == 1, "Executioner bonus remains at exactly half-strength")
	state.squads[2].starting_strength = 5
	check(Morale.below_half_strength(state, 2), "A five-model unit with two models remaining is below half-strength")
	prepared = AttackPlan.prepare(state, 1, false, [assignment], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].context.hit_modifier == 0, "Executioner bonus ends below half-strength")
	state.squads[3] = {"owner": 2, "name": "Single model at half wounds", "starting_strength": 1, "stats": {"toughness": 4, "save_target": 3, "wounds": 11, "objective_control": 1}, "battle_shocked": false}
	state.units[300] = {"owner": 2, "squad": 3, "definition_id": "test:vehicle", "position": Vector2(3, 0), "radius": 0.5, "keywords": ["VEHICLE"], "wounds": 6, "max_wounds": 11, "on_battlefield": true}
	check(not Morale.below_half_strength(state, 3), "A single model with six of eleven wounds remaining is not below half-strength")
	assignment.target = 3
	prepared = AttackPlan.prepare(state, 1, false, [assignment], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].context.hit_modifier == 1, "Executioner bonus also applies at the single-model half-wounds boundary")
	state.units[300].wounds = 5
	check(Morale.below_half_strength(state, 3), "A single model with five of eleven wounds remaining is below half-strength")
	prepared = AttackPlan.prepare(state, 1, false, [assignment], false)
	check(prepared.get("error", "").is_empty() and prepared.batches[0].context.hit_modifier == 0, "Executioner bonus ends when a single model falls below half its wounds")
	print("Repulsor Executioner rules: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void: call_deferred("run")
