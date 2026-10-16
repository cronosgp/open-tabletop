extends SceneTree
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	push_error("Attack-plan network timeout: " + game.status.text)
	return false
func assign(game: Node, model: int, target: int) -> void:
	game.selected = model
	game._refresh()
	game.plan_target.select(game.plan_target.get_item_index(target))
	game.plan_amount.value = 1
	game._assign_attack()
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives(2)
	var melee: bool = "--ranged-test" not in OS.get_cmdline_user_args()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		game.state.active = 2
		game.state.phase = "fight" if melee else "shooting"
		game.state.fight_step = "attacks"
		game.state.fight_actor = 2
		game.state.squads[2].charged = melee
		for id: int in game.state.units:
			if id not in [100, 300, 200, 201]: game.state.units[id].wounds = 0
		game.state.units[200].position = Vector2(-8, -8) if melee else Vector2(-12, -8)
		game.state.units[201].position = Vector2(-8, -6) if melee else Vector2(-10, -8)
		game.state.units[100].position = Vector2(-6, -8) if melee else Vector2(-2, -8)
		game.state.units[300].position = Vector2(-6, -6) if melee else Vector2(1, -8)
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		var passed: bool = game.guest_id != 0 and await revision(game, 1)
		await create_timer(0.5).timeout
		passed = passed and game.state.last_attack.targets == [1, 3] and game.state.last_attack.assignments.size() == 2 and game.state.last_attack.pools.size() == 2 and game.state.revision == 1
		passed = passed and (game.state.squads[2].fought if melee else game.state.squads[2].shot)
		print("ATTACK PLAN NETWORK HOST ", "MELEE" if melee else "RANGED", ": ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	game.selected = 200
	game._refresh()
	var passed: bool = not game.plan_begin.disabled and game.state.phase == ("fight" if melee else "shooting")
	var before := var_to_str(game.state)
	game._begin_attack_plan()
	assign(game, 200, 1)
	game.plan_cancel.pressed.emit()
	passed = passed and game.attack_draft.is_empty() and before == var_to_str(game.state)
	game._begin_attack_plan()
	assign(game, 200, 1)
	assign(game, 201, 3)
	passed = passed and not game.plan_confirm.disabled and game.end_button.disabled and "Model 201" in game.plan_summary.text
	var draft: Dictionary = game.attack_draft.duplicate(true)
	game.request_attack_plan.rpc_id(1, 200, [{"model": 100, "target": 1, "amount": 1}], 0, melee, true)
	await create_timer(0.2).timeout
	passed = passed and before == var_to_str(game.state)
	game._confirm_attack_plan()
	passed = await revision(game, 1) and passed
	game.request_attack_plan.rpc_id(1, 200, draft.entries, 0, melee, true)
	game.request_attack_plan.rpc_id(1, 200, draft.entries, 1, melee, true)
	await create_timer(0.2).timeout
	passed = passed and game.state.revision == 1 and game.attack_draft.is_empty() and game.state.last_attack.targets == [1, 3] and "Intercessor Squad II" in game.event_log.text
	print("ATTACK PLAN NETWORK CLIENT ", "MELEE" if melee else "RANGED", ": ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
