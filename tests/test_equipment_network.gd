extends SceneTree
func _initialize() -> void: call_deferred("run")
func revision(game: Node, wanted: int) -> bool:
	for attempt in range(100):
		if game.state.revision >= wanted: return game.state.revision == wanted
		await create_timer(0.1).timeout
	return false
func assign(game: Node, model: int, weapon: String, profile: String, amount: int) -> void:
	game.selected = model
	game._refresh()
	for index in range(game.plan_weapon.item_count):
		var data: Dictionary = game.plan_weapon.get_item_metadata(index)
		if data.weapon == weapon and data.profile == profile:
			game.plan_weapon.select(index)
			game._refresh()
			break
	game.plan_target.select(game.plan_target.get_item_index(2))
	game.plan_amount.value = amount
	game._assign_attack()
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.equipment_choice.button_pressed = true
	game._start_objectives(2)
	var melee: bool = "--melee-test" in OS.get_cmdline_user_args()
	var vehicle: bool = "--vehicle-test" in OS.get_cmdline_user_args()
	var host: bool = "--host-test" in OS.get_cmdline_user_args()
	if host:
		game._host()
		# Swap the owners of the two primary units: the guest exercises Marine profiles.
		game.state.squads[1].owner = 2
		game.state.squads[2].owner = 1
		for id: int in game.state.units:
			if game.state.units[id].squad == 1: game.state.units[id].owner = 2
			if game.state.units[id].squad == 2: game.state.units[id].owner = 1
			if id not in [100, 101, 200, 201]: game.state.units[id].wounds = 0
		game.state.active = 2
		game.state.phase = "fight" if melee else "shooting"
		game.state.fight_step = "attacks"
		game.state.fight_actor = 2
		game.state.squads[1].charged = melee
		game.state.units[100].position = Vector2(-4, -8) if melee else Vector2(-12, -8)
		game.state.units[101].position = Vector2(-4, -6) if melee else Vector2(-10, -8)
		game.state.units[200].position = Vector2(-2, -8)
		game.state.units[201].position = Vector2(0, -8)
		if vehicle:
			game.state.units[100].keywords = ["Vehicle"]
			game.state.units[100].position = Vector2(-4, -8)
			game.state.units[101].wounds = 0
		game.state.squads[2].stats.wounds = 20
		for id in [200, 201]:
			game.state.units[id].wounds = 20
			game.state.units[id].max_wounds = 20
		game.rng.seed = 42
		for attempt in range(100):
			if game.guest_id != 0: break
			await create_timer(0.1).timeout
		var passed: bool = game.guest_id != 0 and await revision(game, 1)
		await create_timer(0.5).timeout
		passed = passed and game.state.last_attack.pools.size() == (2 if melee or vehicle else 3) and game.state.last_attack.assignments[0].profile == ("standard" if melee else "focused")
		if vehicle: passed = passed and game.state.last_attack.pools[0].hit_modifier == -1 and game.state.last_attack.pools[1].hit_modifier == 0
		print("EQUIPMENT NETWORK HOST ", "MELEE" if melee else "RANGED", ": ", "PASS" if passed else "FAIL")
		quit(0 if passed else 1)
		return
	game._join()
	for attempt in range(100):
		if game.state.active == 2: break
		await create_timer(0.1).timeout
	game.selected = 100
	game._refresh()
	var passed: bool = game.state.varied_equipment and not game.plan_begin.disabled
	game._begin_attack_plan()
	assign(game, 100, "chainsword" if melee else "rifle", "standard" if melee else "focused", 5 if melee else 1)
	if vehicle: assign(game, 100, "plasma", "standard", 1)
	else:
		assign(game, 101, "knives" if melee else "rifle", "standard" if melee else "saturation", 3 if melee else 1)
		if not melee: assign(game, 101, "launcher", "krak", 1)
	passed = passed and not game.plan_confirm.disabled and game.attack_draft.entries.size() == (2 if melee or vehicle else 3)
	var before := var_to_str(game.state)
	game.request_attack_plan.rpc_id(1, 100, [{"model": 100, "target": 2, "amount": 1, "weapon": "rifle", "profile": "supercharge"}], 0, melee, true)
	await create_timer(0.2).timeout
	passed = passed and before == var_to_str(game.state)
	game._confirm_attack_plan()
	passed = await revision(game, 1) and passed
	passed = passed and game.attack_draft.is_empty() and game.state.last_attack.pools.size() == (2 if melee or vehicle else 3) and ("Chainsword" if melee else "Focused Fire") in game.event_log.text
	print("EQUIPMENT NETWORK CLIENT ", "MELEE" if melee else "RANGED", ": ", "PASS" if passed else "FAIL")
	await create_timer(0.8).timeout
	quit(0 if passed else 1)
