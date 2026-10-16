extends SceneTree
const F = preload("res://tests/fixtures/weapon_selection_fixture.gd")
func _initialize() -> void: call_deferred("run")
func at_revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	return false
func assign(game: Node, weapon: String, profile: String, amount: int, target: int) -> void:
	for index in range(game.plan_weapon.item_count):
		var option: Dictionary = game.plan_weapon.get_item_metadata(index)
		if option.weapon == weapon and option.profile == profile:
			game.plan_weapon.select(index)
			game._refresh()
			break
	game.plan_target.select(game.plan_target.get_item_index(target))
	game.plan_amount.value = amount
	game._assign_attack()
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	var manual: bool = "--allocation-test" in OS.get_cmdline_user_args()
	game.equipment_choice.button_pressed = true
	game.defender_choice.button_pressed = manual
	game._start_objectives(2)
	if "--host-test" in OS.get_cmdline_user_args():
		game._host()
		F.configure(game.state)
		if "--random-test" in OS.get_cmdline_user_args(): F.instance(game.state, "chain").profiles.hunter.attacks = "D3"
		for squad: int in game.state.squads: game.state.squads[squad].owner = 3 - game.state.squads[squad].owner
		for model: Dictionary in game.state.units.values(): model.owner = game.state.squads[model.squad].owner
		game.state.active = 2
		game.state.fight_actor = 2
		if manual:
			game.state.squads[2].stats.save_target = 7
			game.state.squads[4].stats.save_target = 7
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		var passed: bool = game.guest_id != 0 and await at_revision(game, 1)
		if manual:
			passed = passed and not game.state.pending_attack.is_empty() and game.Combat.actor(game.state) == 1
			for step in range(20):
				if game.state.pending_attack.is_empty(): break
				var eligible: Array[int] = game.Combat.Allocation.eligible(game.state)
				game._apply_allocate_damage(1, eligible[0], game.state.revision)
				await create_timer(0.1).timeout
		passed = passed and game.state.squads[1].fought and game.state.last_attack.assignments.size() == 3 and game.state.last_attack.pools.size() == 2
		print("WEAPON SELECTION HOST ", "MANUAL" if manual else "AUTO", ": ", "PASS" if passed else "FAIL")
		await create_timer(0.7).timeout
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	game.selected = 100
	game._refresh()
	game._begin_attack_plan()
	assign(game, "servo", "standard", 1, 2)
	var passed: bool = game.attack_draft.entries.size() == 1 and game.plan_confirm.disabled
	assign(game, "chain", "hunter", 3, 4)
	if "--random-test" in OS.get_cmdline_user_args(): passed = passed and not game.plan_amount.visible and "A D3 generated" in game.plan_summary.text
	passed = passed and game.plan_target.item_count == 1 and game.plan_target.get_item_id(0) == 4
	assign(game, "servo-two", "standard", 1, 2)
	passed = passed and game.attack_draft.entries.size() == 3 and not game.plan_confirm.disabled and "Extra Attacks" in game.plan_summary.text
	assign(game, "chain", "standard", 2, 2)
	passed = passed and game.attack_draft.entries.size() == 3 and not game.plan_confirm.disabled
	assign(game, "knives", "standard", 3, 2)
	passed = passed and game.attack_draft.entries.size() == 3 and not game.plan_confirm.disabled
	assign(game, "chain", "hunter", 3, 4)
	var before := var_to_str(game.state)
	var forged := F.plan()
	forged[0].target = 2
	game.request_attack_plan.rpc_id(1, 100, forged, 0, true, true)
	game.request_attack_plan.rpc_id(1, 100, [F.row("chain", "hunter", 3, 4)], 0, true, true)
	await create_timer(0.2).timeout
	passed = passed and before == var_to_str(game.state)
	game._confirm_attack_plan()
	for attempt in range(100):
		if game.state.squads[1].fought: break
		await create_timer(0.1).timeout
	passed = passed and game.state.squads[1].fought and game.attack_draft.is_empty() and game.state.last_attack.assignments.size() == 3 and "Hunter" in game.event_log.text and "Extra Attacks" in game.event_log.text
	print("WEAPON SELECTION CLIENT ", "MANUAL" if manual else "AUTO", ": ", "PASS" if passed else "FAIL")
	await create_timer(0.3).timeout
	quit(0 if passed else 1)
