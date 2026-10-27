extends SceneTree
const C = preload("res://scripts/edition_11/combat_scenario.gd")
const Preset = preload("res://scripts/edition_11/test_battlefield.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var state := C.initial_state()
	var original_hash: String = state.pack_hash
	Preset.apply(state)
	check(state.board_size == Vector2(43, 43) and state.points_limit == 1000 and not state.roster_points_validated, "Preset records requested dimensions and points without claiming roster legality")
	check(state.pack_hash != original_hash, "Scenario dimensions participate in compatibility")
	var new_hash: String = state.pack_hash
	Preset.apply(state)
	check(state.pack_hash == new_hash, "Preset application is idempotent")
	state.units[100].position = Vector2(19, 15)
	var edge: float = 21.5 - state.units[100].radius
	check(C.Contact.clear_path(state, 100, Vector2(edge, 15), 6), "Complete base can finish on the positive X boundary")
	check(not C.Contact.clear_path(state, 100, Vector2(edge + 0.01, 15), 6), "Base cannot extend beyond the X boundary")
	state.units[100].position = Vector2(15, -19)
	check(C.Contact.clear_path(state, 100, Vector2(15, -edge), 6), "Complete base can finish on the negative Y boundary")
	check(not C.Contact.clear_path(state, 100, Vector2(15, -edge - 0.01), 6), "Base cannot extend beyond the Y boundary")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._start_objectives()
	for frame in range(8): await process_frame
	check(game.rendered_board_size == Vector2(43, 43) and "43 × 43" in game.session_label.tooltip_text, "Rendered board and displayed scenario tooltip agree")
	check(game.state.pack_hash == game._initial_state().pack_hash, "Offline and host/rejoin factories use the same preset")
	game._start_allocation_practice()
	check(game.state.board_size == Vector2(43, 43), "Rules lab uses the same initial testing dimensions")
	game._toggle_combat()
	check(game.rendered_board_size == Vector2(30, 20), "Legacy movement demo retains its original fixture")
	print("Incursion battlefield checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
