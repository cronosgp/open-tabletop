extends SceneTree
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.state = game.PreparedTraining.initial_state({"unit_abilities": true})
	game.combat_enabled = true
	game._reset_history()
	game._spawn_pieces()
	game._dismiss_home(1)
	game.mode = "host"
	game.guest_id = 2
	game._refresh()
	check(game.setup_finish_button.visible and game.action_groups.unit.container.visible, "Host sees own army preparation controls")
	check(game.setup_preparation_status.visible and "PLAYER 1" in game.setup_preparation_status.text and not game.setup_equipment_open, "Preparation identifies its owner and keeps optional equipment collapsed")
	check(not game.setup_finish_button.disabled, "Optional equipment can stay at the default while preparation finishes")
	check(game.end_button.disabled and not game.action_groups.phase.container.visible, "Phase advance cannot bypass army preparation")
	game.mode = "local"
	var setup_before := var_to_str(game.state)
	game.setup_equipment_toggle.pressed.emit()
	var grouped_current_loadout := false
	for row: Node in game.setup_equipment_list.get_children():
		if row is Label and "Current:" in row.text: grouped_current_loadout = true
	check(game.setup_equipment_open and game.setup_equipment_list.visible and grouped_current_loadout and var_to_str(game.state) == setup_before, "Equipment is grouped with current loadout details and opening it is read-only")
	var none_current_loadout := false
	for row: Node in game.setup_equipment_list.get_children():
		if row is Label and "Current: None" in row.text: none_current_loadout = true
	check(not none_current_loadout, "Optional equipment rows name the current loadout instead of showing None")
	var equipment_clicked := false
	var equipment_changed := false
	for row_index in range(game.setup_equipment_list.get_child_count() - 1):
		var picker: OptionButton = game.setup_equipment_list.get_child(row_index) as OptionButton
		if picker == null: continue
		for option_index in range(picker.item_count):
			var option: Variant = picker.get_item_metadata(option_index)
			if not option is Dictionary or str(option.get("action", "")) != "intercessor-grenade-launcher" or str(option.get("value", "")) != "on": continue
			var model_id := int(option.get("model", -1))
			picker.select(option_index)
			var confirm: Button = game.setup_equipment_list.get_child(row_index + 1) as Button
			if confirm == null: continue
			confirm.pressed.emit()
			equipment_clicked = true
			equipment_changed = bool(game.state.units.get(model_id, {}).get("intercessor_grenade_launcher", false))
			break
		if equipment_clicked: break
	check(equipment_clicked and equipment_changed, "Confirm change applies the selected equipment option through the existing rules command")
	check("Equipment updated." in game.status.text, "Equipment confirmation reports a visible result")
	game.setup_equipment_toggle.pressed.emit()
	var character_model := -1
	for model: int in game.state.units:
		if int(game.state.units[model].owner) == 1:
			character_model = model
			break
	if character_model >= 0:
		game.state.units[character_model].keywords.append("CHARACTER")
		game._refresh()
		check(game.setup_finish_button.disabled and "Warlord" in game.setup_required_status.text, "Existing setup validation blocks finishing while the required Warlord is missing")
		game.state.units[character_model].keywords.erase("CHARACTER")
		game._refresh()
	game.setup_finish_button.pressed.emit()
	check(UnitActions.setup_actor(game.state) == 2, "Finish army preparations commits the current army and transfers preparation to Player 2")
	check("army is ready" in game.status.text, "Finishing preparation reports a visible result")
	check(game.setup_feedback_status.visible and "army is ready" in game.setup_feedback_status.text, "Preparation handoff feedback remains visible beside Player 2's controls")
	game.state.unit_abilities.setup_players = [2]
	game._refresh()
	var before := var_to_str(game.state)
	game.mode = "client"
	game._refresh()
	check(not game.action_groups.unit.container.visible and game.unit_choice_reference.text.is_empty(), "Guest has no visible host choices or stale details")
	for group: Dictionary in game.action_groups.values(): check(not group.container.visible, "Opponent choices are hidden while waiting")
	check(not game.action_groups.unit.container.visible and var_to_str(game.state) == before, "Guest retains waiting orientation without state mutation")
	game.state.unit_abilities.setup_players = [1]
	game._refresh()
	check(game.setup_finish_button.visible and game.action_groups.unit.container.visible and "PLAYER 2" in game.setup_preparation_status.text, "Guest sees own preparation when it transfers")
	game.mode = "host"
	game._refresh()
	check(not game.action_groups.unit.container.visible, "Host does not see guest choices")
	game.mode = "local"
	game._refresh()
	check(game.setup_finish_button.visible and game.action_groups.unit.container.visible and game._local_player() == 2, "Local mode exposes player two decisions")
	game.state.unit_abilities.setup_players = []
	game._refresh()
	check(game.setup_finish_button.visible and game._local_player() == 1, "Local mode also exposes player one decisions")
	game._start_objectives()
	game.state.phase = "shooting"
	game.mode = "client"
	game._refresh()
	check(not game.action_groups.attack.container.visible and not game.action_groups.phase.container.visible and not game.action_unit_picker.visible, "Waiting guest sees no opponent shooting or phase controls")
	check(game.waiting_unit_picker.visible and game.waiting_unit_picker.item_count > 1, "Waiting guest can inspect own units")
	for i in range(1, game.waiting_unit_picker.item_count):
		check(game.state.units[game.waiting_unit_picker.get_item_id(i)].owner == 2, "Inspection picker contains only guest units")
	before = var_to_str(game.state)
	var rng_before: int = game.rng.state
	game.waiting_unit_picker.item_selected.emit(1)
	check(game.state.units[game.selected].owner == 2 and game.selection_card.get_parent().visible, "Inspection selects a friendly model and shows its card")
	check(var_to_str(game.state) == before and game.rng.state == rng_before, "Waiting inspection preserves state and RNG")
	check(not game.action_groups.attack.container.visible and game.waiting_unit_picker.selected == 1, "Inspection keeps opponent controls hidden and selection stable")
	game.state.active = 2
	game._refresh()
	check(not game.waiting_unit_picker.visible and game.waiting_unit_picker.item_count == 0, "Own turn clears waiting inspection entries")
	game.state.active = 1
	game.mode = "local"
	game._refresh()
	check(not game.waiting_unit_picker.visible, "Local mode uses ordinary controls for both sides")
	check(game.action_groups.attack.container.visible and game.action_groups.phase.container.visible, "Returning local restores controls")
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(false)
	game.mode = "host"
	game.guest_id = 0
	game.saved_army_pickers[1].select(0)
	game._refresh()
	check(game.state.phase == "army_selection" and game.action_groups.army_selection.container.visible and game.network_army_picker.visible, "LAN army selection stays available in the in-match command panel")
	var network_choice: Variant = game.network_army_picker.get_selected_metadata()
	check(game.state.ready_armies.is_empty() and network_choice is Dictionary and network_choice.is_empty(), "Starting LAN does not silently submit the host's previously selected list")
	game._network_army_selected(1)
	game._submit_saved_army()
	check(1 in game.state.ready_armies and "Player 1 list submitted" in game.network_army_status.text, "LAN list submission reports host readiness and the next expected player")
	print("Choice ownership UI checks: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
