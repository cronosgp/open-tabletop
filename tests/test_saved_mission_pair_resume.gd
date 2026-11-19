extends SceneTree

const ArmyCatalog = preload("res://scripts/implemented_army_catalog.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const ArmyProfiles = preload("res://scripts/army_profiles.gd")
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const MatchSave = preload("res://scripts/match_save.gd")
const MainScene = preload("res://scenes/main.tscn")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 3 and args[0] == "--reopen":
		_reopen(int(args[1]), args[2])
		return
	var catalog := ArmyCatalog.new()
	check(catalog.select_edition("11e").is_empty(), "Current local catalog opens")
	var game = MainScene.instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	var profile_path := ProjectSettings.globalize_path("user://mission-pair-profiles-%d.json" % OS.get_process_id())
	game.army_builder.store = ArmyProfiles.new(profile_path)
	game.unit_abilities_choice.button_pressed = true
	game.combat_doctrines_choice.button_pressed = true
	game.awakened_dynasty_choice.button_pressed = true
	game.reanimation_protocols_choice.button_pressed = true
	game.stratagem_choice.button_pressed = true
	game.official_mission_choice.button_pressed = true
	game._select_official_secondary_pair("engage-tempting-target")
	var marines := ArmyRoster.new_list("11e", "Space Marines", "incursion", 1000)
	marines.entries.append(ArmyRoster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:captain"), 0, 1))
	marines.entries.append(ArmyRoster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:intercessor-squad"), 0, 1))
	marines.warlord_model_id = ArmyRoster.model_instance_id(marines.entries[0], 0, 0)
	var necrons := ArmyRoster.new_list("11e", "Necrons", "incursion", 1000)
	necrons.entries.append(ArmyRoster.entry(catalog.lookup("40kdc:11e:necrons:royal-warden"), 0, 1))
	necrons.entries.append(ArmyRoster.entry(catalog.lookup("40kdc:11e:necrons:necron-warriors"), 0, 1))
	necrons.warlord_model_id = ArmyRoster.model_instance_id(necrons.entries[0], 0, 0)
	var saved_marines: Dictionary = game.army_builder.store.save_list(marines)
	var saved_necrons: Dictionary = game.army_builder.store.save_list(necrons)
	check(str(saved_marines.get("error", "")).is_empty() and str(saved_necrons.get("error", "")).is_empty(), "Both configured armies save before the mission-pair match")
	if not str(saved_marines.get("error", "")).is_empty() or not str(saved_necrons.get("error", "")).is_empty():
		_finish(game, catalog, profile_path, "")
		return
	game._refresh_army_choices()
	for owner in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		var wanted_id := str(saved_marines.list.id) if owner == 1 else str(saved_necrons.list.id)
		for index in range(picker.item_count):
			if str(picker.get_item_metadata(index).get("id", "")) == wanted_id: picker.select(index)
	game._start_saved_match()
	var mission: Dictionary = game.state.get("mission", {})
	var started: bool = game.saved_army_mode and not game.state.has("error") and str(game.state.get("phase", "")) == "deployment" \
		and str(mission.get("secondary_pair_id", "")) == "engage-tempting-target" \
		and mission.get("secondary_cards", []) == ["engage-on-all-fronts", "a-tempting-target"] \
		and str(mission.get("stage", "")) == "terrain" and game._selected_official_secondary_pair() == "engage-tempting-target"
	check(started, "A saved-army CA match starts from the UI with the selected non-default secondary pair: " + str(game.status.text))
	if not started:
		_finish(game, catalog, profile_path, "")
		return
	check(int(game.active_save_slot) > 0 and MatchSave.slot_has_file(int(game.active_save_slot)), "The mission-pair match writes its initial checkpoint")
	var saved: Dictionary = MatchSave.read(game.match_save_path)
	check(not saved.has("error") and saved.get("state", {}) == game.state and str(saved.get("state", {}).get("mission", {}).get("secondary_pair_id", "")) == "engage-tempting-target", "The checkpoint freezes the Pair and the mission stage")
	var expected_path := ProjectSettings.globalize_path("user://mission-pair-expected-%d.bin" % OS.get_process_id())
	var expected_file := FileAccess.open(expected_path, FileAccess.WRITE)
	check(expected_file != null, "The mission-pair fixture can write its expected snapshot")
	if expected_file == null:
		_finish(game, catalog, profile_path, "")
		return
	expected_file.store_buffer(var_to_bytes({"state": saved.state, "presentation": saved.get("presentation", {})}))
	expected_file.flush()
	expected_file.close()
	var output: Array = []
	var reopened := OS.execute(OS.get_executable_path(), [
		"--headless",
		"--path",
		ProjectSettings.globalize_path("res://"),
		"--script",
		"res://tests/test_saved_mission_pair_resume.gd",
		"--",
		"--reopen",
		str(game.active_save_slot),
		expected_path,
	], output, true)
	check(reopened == 0, "A separate Godot process resumes the non-default secondary pair before readiness: " + "\n".join(output))
	var terrain_choice := _mission_choice(game.state, 1, "mission-terrain")
	check(not terrain_choice.is_empty(), "The resumed match offers the terrain mission-preparation choice")
	if not terrain_choice.is_empty():
		game._apply_unit_action(1, game._unit_choice_payload(terrain_choice), Vector2.ZERO, int(game.state.revision))
	check(str(game.state.get("mission", {}).get("stage", "")) == "tempting-target-p1" and Combat.Mission.actor(game.state) == 2,
		"Resolving terrain after resume enters the P1 Tempting Target declaration for Player 2")
	var p2_target := _mission_choice(game.state, 2, "mission-tempting-target")
	check(not p2_target.is_empty(), "Player 2 can declare the opposing player's Tempting Target after resume")
	if not p2_target.is_empty():
		game._apply_unit_action(2, game._unit_choice_payload(p2_target), Vector2.ZERO, int(game.state.revision))
	check(str(game.state.get("mission", {}).get("stage", "")) == "tempting-target-p2" and Combat.Mission.actor(game.state) == 1,
		"The resolved declaration passes to Player 1 in opponent order")
	var p1_target := _mission_choice(game.state, 1, "mission-tempting-target")
	check(not p1_target.is_empty(), "Player 1 can declare the opposing player's Tempting Target after resume")
	if not p1_target.is_empty():
		game._apply_unit_action(1, game._unit_choice_payload(p1_target), Vector2.ZERO, int(game.state.revision))
	check(str(game.state.get("mission", {}).get("stage", "")) == "roles-roll" and Combat.Mission.actor(game.state) == 1,
		"Both Tempting Target declarations resolve to the role roll after the separate-process resume")
	_finish(game, catalog, profile_path, expected_path)

func _reopen(slot: int, expected_path: String) -> void:
	var expected_file := FileAccess.open(expected_path, FileAccess.READ)
	check(expected_file != null, "The mission-pair restart process can read its expected snapshot")
	if expected_file == null:
		quit(1)
		return
	var expected: Variant = bytes_to_var(expected_file.get_buffer(expected_file.get_length()))
	expected_file.close()
	check(expected is Dictionary and expected.get("state", null) is Dictionary and expected.get("presentation", null) is Dictionary,
		"The mission-pair fixture contains frozen gameplay and appearance snapshots")
	if not expected is Dictionary:
		quit(1)
		return
	var game = MainScene.instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	var slot_selected: bool = game._set_active_save_slot(slot)
	if slot_selected: game._load_match()
	check(slot_selected and bool(game.resume_succeeded), "The application resumes the saved mission-pair match")
	check(game.state == expected.state, "Restart restores the exact frozen mission-pair state")
	var mission: Dictionary = game.state.get("mission", {})
	check(game.official_mission and game._selected_official_secondary_pair() == "engage-tempting-target" \
		and str(mission.get("secondary_pair_id", "")) == "engage-tempting-target" \
		and mission.get("secondary_cards", []) == ["engage-on-all-fronts", "a-tempting-target"] \
		and str(mission.get("stage", "")) == "terrain" \
		and game._selected_official_terrain_layout() == str(mission.get("terrain_layout", "")),
		"Restart restores the official mission, selected Pair, cards, terrain layout and pending stage from the save")
	game.free()
	for _frame in range(2): await process_frame
	print("Saved mission-pair resume checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

func _mission_choice(state: Dictionary, player: int, action: String) -> Dictionary:
	for choice: Dictionary in Combat.Mission.choices(state, player):
		if str(choice.get("action", "")) == action: return choice
	return {}

func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)

func _finish(game, catalog, profile_path: String, expected_path: String) -> void:
	var match_save_path := str(game.match_save_path)
	if not match_save_path.is_empty():
		var slot_path := ProjectSettings.globalize_path(match_save_path)
		_remove_file(slot_path)
		_remove_file(slot_path + ".bak")
		_remove_file(slot_path + ".tmp")
	if not expected_path.is_empty(): _remove_file(expected_path)
	_remove_file(profile_path)
	game.free()
	catalog.free()
	for _frame in range(2): await process_frame
	print("Saved mission-pair resume checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
