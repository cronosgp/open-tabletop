extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives()
	game._dismiss_home(1)
	game.state.phase = "shooting"
	game.selected = 100
	game.state.squads[game.state.units[100].squad].shot = true
	var before := var_to_str(game.state)
	game._refresh()
	check(game.shooting_complete.visible and not game.plan_begin.visible and not game.lethal_choice.visible, "Spent unit gets a completion instead of attack controls")
	check("continue to Charge" in game.decision_label.text and game.action_unit_picker.visible, "Completion points to phase progression and preserves picker")
	check(var_to_str(game.state) == before, "Completion presentation preserves authoritative state")
	game.state.squads[game.state.units[100].squad].shot = false
	game._refresh()
	check(not game.shooting_complete.visible and game.plan_begin.visible and game.lethal_choice.visible, "Unused unit restores normal controls")
	game.selected = 200
	game._refresh()
	check(not game.shooting_complete.visible, "Enemy selection is not called a local shooting completion")
	game.selected = 100
	game.state.squads[game.state.units[100].squad].shot = true
	game.state.phase = "charge"
	game._refresh()
	check(not game.shooting_complete.visible and "Shooting complete" not in game.decision_label.text, "Next phase removes stale completion")
	print("Shooting completion UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
