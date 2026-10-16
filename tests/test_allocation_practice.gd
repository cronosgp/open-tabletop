extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_allocation_practice()
	var passed: bool = game.state.get("rules_practice", false) and game.allocation_practice and game.state.phase == "shooting" and game.state.manual_allocation and game.selected == 100
	passed = passed and game.state.pack_hash == game._initial_state().pack_hash and "SYNTHETIC RULES LAB" in game.details.text
	game._begin_attack_plan()
	game._assign_attack()
	passed = passed and not game.plan_confirm.disabled and game.attack_draft.entries[0].weapon == "practice"
	game._start_allocation_practice()
	passed = passed and game.attack_draft.is_empty() and game.state.revision == 0
	game._start_objectives(2)
	passed = passed and not game.allocation_practice and not game.state.get("rules_practice", false)
	print("Allocation practice UI: ", "PASS" if passed else "FAIL")
	quit(0 if passed else 1)
