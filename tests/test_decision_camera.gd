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
	game.board_feedback_toggle.button_pressed = false
	game.state.phase = "movement"
	for id in game.state.units:
		if game.state.units[id].owner == 1: game.state.units[id].position = Vector2(18, 8 + (id % 100) * 1.2)
	game.selected = 100
	var before := var_to_str(game.state)
	game._refresh()
	for i in 8: await process_frame
	var subject: Dictionary = game._decision_camera_subject()
	check(not subject.get("models", []).is_empty(), "Movement has a camera subject")
	var area: Rect2 = game._camera_board_area().grow(-24)
	for point in game.DecisionCamera.points(game.state, subject.models):
		check(area.has_point(game.camera.unproject_position(point)), "Selected unit fits between panels")
	check(var_to_str(game.state) == before and game.selected == 100, "Framing preserves match and selection")
	var pose: Vector3 = game.pivot.position
	var transform: Transform3D = game.camera.transform
	var plan: Dictionary = game.DecisionCamera.plan(game.camera, game.pivot, game.state, subject.models, game._camera_board_area(), game.angle)
	check(not plan.is_empty() and game.pivot.position == pose and game.camera.transform == transform, "Projection probe restores the original camera")
	game._manual_camera_control()
	game.pivot.position += Vector3(3, 0, 2)
	pose = game.pivot.position
	game._refresh()
	for i in 4: await process_frame
	check(game.pivot.position == pose, "Repeated refresh preserves manual camera ownership")
	game.selected = 101
	game._refresh()
	for i in 4: await process_frame
	check(game.pivot.position == pose, "Selecting another model in the same unit does not reframe")
	game.auto_frame_toggle.button_pressed = false
	game.state.phase = "shooting"
	game._refresh()
	for i in 4: await process_frame
	check(game.pivot.position == pose, "Opt-out preserves camera across decisions")
	game._focus_selected_unit()
	check(game.pivot.position != pose, "Manual focus still works with automatic framing disabled")
	var attacker: int = game.state.units[100].squad
	var defender: int = game.state.units[200].squad
	var attack: Dictionary = game.DecisionCamera.subject(game.state, 100, {"squad": attacker}, {"attack": true, "attack_target": defender})
	check(attack.models.has(100) and attack.models.has(200), "Attack framing includes attacking and defending units")
	game.auto_frame_toggle.button_pressed = true
	game.board_feedback_toggle.button_pressed = true
	game.last_camera_key = ""
	game._refresh_decision_camera()
	game._manual_camera_control()
	pose = game.pivot.position
	await create_timer(0.4).timeout
	check(game.pivot.position == pose, "Manual control cancels an animated focus")
	print("Decision camera checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
