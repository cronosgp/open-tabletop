extends SceneTree
const T = preload("res://scripts/edition_11/training_roster.gd")
const P = preload("res://scripts/edition_11/prepared_training.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var marines := T.template("Space Marines", "training", 500)
	var necrons := T.template("Necrons", "training", 500)
	if not marines.error.is_empty() or not necrons.error.is_empty():
		push_error("Pinned starter data is required")
		quit(1)
		return
	check(T.inspect(marines.list).total == 160 and T.inspect(necrons.list).total == 170, "Runtime points resolve from local pack")
	var bad: Dictionary = marines.list.duplicate(true)
	bad.entries[0].cost = 99999
	check(T.inspect(bad).total == 160, "Saved/API prices cannot override runtime points")
	bad.entries[0].models = 6
	check(not T.inspect(bad).error.is_empty(), "Unsupported API composition is rejected instead of silently corrected")
	bad = marines.list.duplicate(true)
	bad.entries[0].unit_id = "unimplemented:captain"
	bad.entries[0].name = "Intercessor Squad"
	check(not T.inspect(bad).error.is_empty(), "Display-name spoof cannot admit unknown units")
	bad = marines.list.duplicate(true)
	bad.entries[0].copies = 6
	check(not T.inspect(bad).error.is_empty(), "More than six units is outside the core-profile limit")
	bad = marines.list.duplicate(true)
	bad.category = "custom"
	bad.points_limit = 100
	check(not T.inspect(bad).error.is_empty(), "Canonical runtime costs enforce the budget")
	var report := T.inspect(marines.list)
	var selection: Dictionary = report.selection.duplicate(true)
	selection.price = 0
	check(not T.admit(selection).error.is_empty(), "Public selection cannot supply prices or extra fields")
	necrons.list.entries.resize(1)
	necrons.list.name = "PRIVATE PROFILE LIST"
	necrons.list.notes = "PRIVATE NOTES"
	var a := T.inspect(necrons.list)
	var b := T.inspect(marines.list)
	var state := P.initial_state({}, {1: a.selection, 2: b.selection})
	check(not state.has("error") and state.units.size() == 20 and state.squads.size() == 3 and state.deployment.order == [1, 2, 4], "Saved lists create asymmetric army sizes and deployment order")
	check(state.squads[1].faction == "Necrons" and state.squads[2].faction == "Space Marines" and state.training_points == {1: 85, 2: 160}, "Either player may choose either implemented faction")
	check(state.points_limit == 500 and not state.roster_points_validated and state.pack_hash == P.from_setup(state.saved_army_setup).pack_hash, "Setup reconstructs deterministically without claiming official legality")
	check("PRIVATE" not in var_to_str(state), "Profile/list names and notes never enter match state")
	var mirror := P.initial_state({"manual_allocation": false}, {1: a.selection, 2: a.selection})
	for id: int in mirror.units:
		if id not in [100, 200]: mirror.units[id].wounds = 0
	mirror.phase = "shooting"
	var shot: Dictionary = P.Combat.shoot(mirror, 1, 100, 200, mirror.revision, true, func(): return 6)
	check(shot.error.is_empty() and mirror.squads[1].shot and mirror.has("last_attack"), "Inverted/same-faction rosters execute real combat with their own profiles")
	var changed: Dictionary = b.selection.duplicate(true)
	changed.category = "incursion"
	changed.points_limit = 1000
	check(P.initial_state({}, {1: a.selection, 2: changed}).has("error"), "Mismatched point categories/limits cannot start")
	check(P.initial_state({"varied_equipment": true}, {1: a.selection, 2: b.selection}).has("error"), "Saved-list mode cannot silently substitute curated varied equipment")
	var identity: String = state.pack_hash
	for squad in [1, 2, 4]:
		var owner: int = state.squads[squad].owner
		check(P.Deployment.preset(state, owner, state.revision).is_empty() and P.Deployment.confirm(state, owner, state.revision).is_empty(), "Each admitted unit can deploy coherently")
	for step in range(100):
		if state.test_winner != 0: break
		check(P.Combat.advance_phase(state, P.Combat.actor(state), state.revision).is_empty(), "Asymmetric saved armies can complete the mission")
	check(state.test_winner != 0 and state.pack_hash == identity, "Five rounds finish without changing frozen roster identity")
	var editor = load("res://scripts/army_builder_panel.gd").new()
	editor.storage_path = "res://.tools/offline-training-list.json"
	editor.cache_directory = "res://.tools/no-online-catalog"
	root.add_child(editor)
	check(not editor.source.catalog.is_empty() and editor.source.catalog.provider == "Consolidated local runtime", "Consolidated construction choices load offline without the API")
	editor._new_training()
	check(editor._save() and T.inspect(editor.draft).error.is_empty() and editor.catalog_boundary.visible, "Historical training fixture remains storable but is explicitly outside the consolidated construction catalog")
	editor.queue_free()
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.army_builder.store.path = "res://.tools/saved-army-profiles.json"
	var saved_a: Dictionary = game.army_builder.store.save_list(necrons.list)
	var current_marines: Dictionary = T.Capabilities.reference_army("Space Marines")
	var saved_b: Dictionary = game.army_builder.store.save_list(current_marines.list)
	game._refresh_army_choices()
	for owner in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		for index in range(picker.item_count):
			if picker.get_item_metadata(index).get("id", "") == (saved_a.list.id if owner == 1 else saved_b.list.id): picker.select(index)
	var before := var_to_str(game.state)
	game._start_saved_match(false)
	check(var_to_str(game.state) == before, "LAN training requires explicit acceptance")
	game.saved_training_consent.button_pressed = true
	game._start_saved_match()
	check(not game.saved_army_mode and var_to_str(game.state) == before, "Historical Necron drafts remain saved but cannot enter new match construction")
	for owner in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		for index in range(picker.item_count):
			if picker.get_item_metadata(index).get("id", "") == saved_b.list.id: picker.select(index)
	game.unit_abilities_choice.button_pressed = true
	game._start_saved_match()
	check(game.saved_army_mode and game.state.units.size() == 40 and game.state.phase == "deployment", "Current local catalog lists reach actual prepared mirror gameplay")
	var other = load("res://scenes/main.tscn").instantiate()
	root.add_child(other)
	other._start_prepared_match()
	other.saved_army_mode = true
	other.submitted_army = b.selection
	other.mode = "client"
	var wrong := P.initial_state({}, {1: a.selection, 2: a.selection})
	other.receive_state(wrong)
	check(other.mode == "local" and "changed its army selection" in other.status.text, "Client rejects a host changing its submitted army")
	game._start_objectives()
	check(not game.saved_army_mode and not game.state.has("saved_army_setup"), "Existing exercises stay separate")
	print("Saved army admission checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
