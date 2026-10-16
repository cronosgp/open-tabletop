extends SceneTree

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game._toggle_combat("legacy-solid-v1")
	check(game.combat_enabled, "Starter data required")
	if not game.combat_enabled:
		quit(1)
		return
	game.state.phase = "movement"
	game.selected = 100
	game._refresh()
	check(is_equal_approx(game.guides.current_range, 6), "Movement range disagrees with unit data")
	check(game.guides.static_vertices > 0, "No guide geometry generated")
	var revision: int = game.state.revision
	game.guides.preview(game.state, 100, true, 1, Vector2(-13, -4))
	check(game.guides.hover_valid and game.state.revision == revision, "Preview mutated match state or rejected a legal step")
	game.guides.preview(game.state, 100, true, 1, Vector2(-22, -4))
	check(not game.guides.hover_valid, "Preview marked off-board movement legal")
	game._apply_move(1, 100, Vector2(-13, -4), game.state.revision)
	check(is_equal_approx(game.guides.current_range, 5) and game.finish_move_button.visible, "Guide/UI did not track draft movement")
	game.selected = 101
	game._refresh()
	check(is_equal_approx(game.guides.current_range, 6), "Guides reused another model's budget")
	game._apply_finish_movement(1, game.state.revision, true)
	game.state.phase = "shooting"
	game.selected = 100
	game._refresh()
	check(is_equal_approx(game.guides.current_range, game.state.squads[1].weapon.range_inches), "Weapon guide uses a hardcoded distance")
	check(game.guides.targets[201].in_range and game.guides.targets[201].clear_line, "Visible in-range target not highlighted")
	check(not game.guides.targets[202].clear_line, "Solid terrain ignored by targeting guide")
	game.guides.preview(game.state, 100, true, 1, game.state.units[201].position)
	check(game.guides.hover_valid and not game.guides.hover_caption.is_empty(), "Target hover has no range/line preview")
	game.guides.preview(game.state, 100, true, 1, game.state.units[202].position)
	check(not game.guides.hover_valid, "Blocked hover target marked clear")
	var vertices: PackedVector3Array = game.guides.static_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var half: Vector2 = game.Rules.half_board(game.state)
	var beyond_legacy := false
	for vertex in vertices:
		check(absf(vertex.x) <= half.x + 0.001 and absf(vertex.z) <= half.y + 0.001, "Guide escaped board clipping")
		beyond_legacy = beyond_legacy or absf(vertex.x) > 15.001 or absf(vertex.z) > 10.001
	check(beyond_legacy, "Incursion guides must reach the expanded board rather than clipping to the legacy demo")
	game.state.phase = "charge"
	game.state.pending_charge = {"squad": 1, "maximum": 7, "rolls": [3, 4]}
	game._refresh()
	check(is_equal_approx(game.guides.current_range, 7), "Charge guide ignored the actual host roll")
	game.state.pending_charge = {}
	game.state.phase = "fight"
	game._refresh()
	check(is_equal_approx(game.guides.current_range, 2), "Engagement guide is incorrect")
	game.guides_toggle.button_pressed = false
	check(not game.guides.visible, "Guide toggle has no effect")
	game.guides_toggle.button_pressed = true
	game.state.units[100].wounds = 0
	game._refresh()
	check(game.guides.static_vertices == 0, "Destroyed model retained range guides")
	game.guides.rebuild(game.Rules.initial_state(), 11, false, 1)
	vertices = game.guides.static_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	for vertex in vertices:
		check(absf(vertex.x) <= 15.001 and absf(vertex.z) <= 10.001, "Legacy demo keeps its original guide bounds")
	print("Tactical guide checks complete: %d failures" % failures)
	quit(1 if failures else 0)
