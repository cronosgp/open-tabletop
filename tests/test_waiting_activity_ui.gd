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
	game.state.phase = "movement"
	game.mode = "client"
	game.state.events = []
	game._refresh()
	check(not game.waiting_activity.visible, "No activity cue is invented before an event")
	game.state.events.append({"revision": 1, "message": "Movement selected. Placement pending."})
	var before := var_to_str(game.state)
	var rng_before: int = game.rng.state
	var journal_before := var_to_str(game.journal.checkpoint())
	game._refresh()
	check(game.waiting_activity.visible and game.waiting_activity_text.text == "Movement selected. Placement pending.", "Waiting cue reads public event without implying movement completion")
	game._refresh()
	check(var_to_str(game.state) == before and game.rng.state == rng_before and var_to_str(game.journal.checkpoint()) == journal_before, "Repeated activity refresh preserves state, RNG and journal")
	game._open_waiting_history()
	check(game.tactical_overlay.visible and game.tactical_overlay_content == game.history_scroll and not game.event_log.visible, "Waiting activity opens the dedicated battle log")
	check(var_to_str(game.state) == before, "Reading history does not commit a command")
	game.state.events.append({"revision": 2, "message": "Unit movement confirmed."})
	game._refresh()
	check(game.waiting_activity_text.text == "Unit movement confirmed.", "New recorded event replaces the old activity")
	game.state.events.append({"message": "  "})
	game.state.events.append(7)
	game._refresh_waiting_activity(true)
	check(game.waiting_activity_text.text == "Unit movement confirmed.", "Empty and malformed activity entries are skipped safely")
	game.state.events = []
	game.mode = "local"
	game._refresh()
	check(not game.waiting_activity.visible and game.waiting_activity_text.text.is_empty(), "Local mode clears waiting activity")
	game.mode = "client"
	game.state.active = 2
	game._refresh()
	check(not game.waiting_activity.visible, "Own decision does not show waiting activity")
	print("Waiting activity UI checks: %d failures" % failures)
	game.free()
	await process_frame
	quit(0 if failures == 0 else 1)
