extends SceneTree
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const Gear = Combat.AttackPlan.Equipment
var failures := 0
var calls := 0
var values: Array[int] = []
func supplied() -> int: return values.pop_front() if not values.is_empty() else 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int:
	calls += 1
	return 6
func fixture(melee: bool = false, manual: bool = false) -> Dictionary:
	var state := Combat.initial_state("legacy-solid-v1", Combat.Objectives.TRAINING, 2, manual, true)
	for id: int in state.units:
		if id not in [100, 101, 200, 201, 400]: state.units[id].wounds = 0
	state.units[100].position = Vector2(-12, -8)
	state.units[101].position = Vector2(-10, -8)
	state.units[200].position = Vector2(-2, -8)
	state.units[201].position = Vector2(0, -8)
	state.units[400].position = Vector2(2, -8)
	state.phase = "fight" if melee else "shooting"
	state.fight_step = "attacks"
	state.fight_actor = 1
	state.squads[1].charged = melee
	if melee:
		state.units[100].position = Vector2(-4, -8)
		state.units[101].position = Vector2(-4, -6)
	return state
func row(model: int, target: int, weapon: String, profile: String, amount: int = 1) -> Dictionary:
	return {"model": model, "target": target, "amount": amount, "weapon": weapon, "profile": profile}
func resolve(state: Dictionary, entries: Array, melee: bool = false) -> Dictionary:
	return Combat.resolve_attack_plan(state, 1, 100, entries, state.revision, melee, true, six)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var state := fixture()
	check(not state.has("error") and state.varied_equipment, "Curated varied equipment loads from imported data")
	check(state.pack_hash != Combat.initial_state("legacy-solid-v1", Combat.Objectives.TRAINING, 2).pack_hash, "Equipment mode included in compatibility")
	check(Gear.choices(state, 100, false).size() == 4 and Gear.choices(state, 101, false).size() == 4, "Rifle profiles and an extra launcher only on its equipped model")
	var blast_state := fixture()
	for id in range(200, 210): blast_state.units[id].wounds = 1
	var blast := Combat.AttackPlan.prepare(blast_state, 1, false, [row(101, 2, "launcher", "frag")], true)
	check(blast.error.is_empty() and blast.batches[0].context.attack_sources[0].bonus == 2, "Imported Frag freezes Blast at ten targets")
	for id in range(201, 210): blast_state.units[id].wounds = 0
	var frozen := Combat.Attacks.generate_attacks(blast.batches[0].weapon, blast.batches[0].context, six)
	check(frozen.count == 6, "Later casualties do not reduce declared Blast bonus")
	check(Gear.select(state, 201, false, "reaper", "standard").stats.range_inches == 12 and Gear.select(state, 200, false, "reaper", "standard").has("error"), "Gauss Reaper and Flayer belong to distinct models")
	var plan := [row(100, 2, "rifle", "focused"), row(101, 4, "rifle", "saturation"), row(101, 4, "launcher", "krak")]
	var prepared := Combat.AttackPlan.prepare(state, 1, false, plan, true)
	check(prepared.error.is_empty() and prepared.batches.size() == 3 and prepared.batches[0].weapon.damage == 2 and prepared.batches[0].context.hit_modifier == 1, "Per-model profiles use different damage and Heavy eligibility")
	check(prepared.batches[0].weapon.attacks == 2 and prepared.batches[1].weapon.attacks == 3 and prepared.batches[2].weapon.damage == 3, "Rapid Fire expanded per chosen weapon/range")
	check(resolve(state, plan).error.is_empty() and state.squads[1].shot and state.last_attack.assignments == plan, "Several ranged weapons resolve in one unit activation")
	for bad in [[row(100, 2, "launcher", "krak")], [row(100, 2, "rifle", "saturation"), row(100, 4, "rifle", "focused")], [row(100, 2, "rifle", "saturation"), row(100, 4, "rifle", "saturation")], [row(101, 2, "launcher", "unknown")], [row(101, 2, "plasma", "supercharge")]]:
		state = fixture()
		calls = 0
		var before := var_to_str(state)
		check(not resolve(state, bad).error.is_empty() and calls == 0 and before == var_to_str(state), "Unowned, unsupported, duplicate or multiple-profile weapon rejected before dice")
	state = fixture()
	state.squads[1].advanced = true
	check(not resolve(state, [row(100, 2, "rifle", "focused")]).error.is_empty(), "Non-Assault selected profile cannot shoot after Advance")
	check(resolve(state, [row(100, 2, "rifle", "saturation")]).error.is_empty(), "Assault selected profile may shoot after Advance")
	state = fixture()
	state.squads[1].moved_distance = 4.0
	prepared = Combat.AttackPlan.prepare(state, 1, false, [row(100, 2, "rifle", "focused")], true)
	check(prepared.error.is_empty() and prepared.batches[0].context.hit_modifier == 0, "Heavy bonus absent after moving over 3 inches")
	state = fixture(true)
	plan = [row(100, 2, "chainsword", "standard", 5), row(101, 2, "knives", "standard", 3)]
	prepared = Combat.AttackPlan.prepare(state, 1, true, plan, true)
	check(prepared.error.is_empty() and prepared.batches.size() == 2 and prepared.batches[0].weapon.attacks == 5, "Selected melee weapon determines A, strength and AP")
	check(resolve(state, plan, true).error.is_empty() and state.squads[1].fought, "Mixed melee weapons complete one fight")
	state = fixture(true)
	check(not resolve(state, [row(100, 2, "chainsword", "standard", 3), row(101, 2, "knives", "standard", 3)], true).error.is_empty(), "Cannot underallocate chosen chainsword A")
	check(not resolve(state, [row(100, 2, "chainsword", "standard", 5), row(100, 2, "knives", "standard", 3), row(101, 2, "knives", "standard", 3)], true).error.is_empty(), "Cannot select two ordinary melee weapons")
	state = fixture()
	state.units[101].ranged_weapons = state.units[100].ranged_weapons.duplicate(true)
	state.units[101].ranged_weapons[0].profiles.saturation.attacks = 1
	prepared = Combat.AttackPlan.prepare(state, 1, false, [row(100, 2, "rifle", "saturation"), row(101, 2, "rifle", "saturation")], true)
	check(prepared.error.is_empty() and prepared.batches.size() == 1 and prepared.batches[0].weapon.attacks == 5, "Identical attack properties merge even when weapon A differs")
	state = fixture(false, true)
	values = [6, 6, 6, 6, 1, 1, 6, 6, 6, 6, 1, 1]
	var result := Combat.resolve_attack_plan(state, 1, 100, [row(100, 2, "rifle", "focused"), row(101, 4, "launcher", "krak")], 0, false, true, supplied)
	check(result.error.is_empty() and not state.pending_attack.is_empty(), "Mixed profiles support defender-choice allocation")
	for step in range(20):
		if state.pending_attack.is_empty(): break
		var model: int = Combat.Allocation.eligible(state)[0]
		check(Combat.allocate_damage(state, 2, model, state.revision, supplied).is_empty(), "Allocate mixed-profile damage")
	check(state.pending_attack.is_empty() and state.squads[1].shot and state.last_attack.pools[0].weapon_name.contains("Focused"), "Defender choices preserve declared profile identity")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.equipment_choice.button_pressed = true
	game._start_objectives(2)
	game.state = fixture(true)
	game.selected = 100
	game._refresh()
	game._begin_attack_plan()
	game.plan_weapon.select(1)
	game._refresh()
	game.selected = 101
	game._refresh()
	check(game.plan_weapon.get_selected_id() == 0 and game.plan_target.get_selected_id() == 2 and game.plan_amount.max_value == 3, "Switching to model without prior weapon selects its own valid default and target")
	print("Equipment/profile checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)


