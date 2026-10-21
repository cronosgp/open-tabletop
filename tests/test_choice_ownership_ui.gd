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
	game.state = game.PreparedTraining.initial_state({"unit_abilities": true})
	game.combat_enabled = true
	game._reset_history()
	game._spawn_pieces()
	game._dismiss_home(1)
	game.mode = "host"
	game.guest_id = 2
	game._refresh()
	check(game.unit_action_picker.item_count > 0 and game.action_groups.unit.container.visible, "Host sees own preparation choices")
	var before := var_to_str(game.state)
	game.mode = "client"
	game._refresh()
	check(game.unit_action_picker.item_count == 0 and not game.unit_details_button.visible and game.unit_choice_reference.text.is_empty(), "Guest has no stale host options or choice details")
	for group: Dictionary in game.action_groups.values(): check(not group.container.visible, "Opponent choices are hidden while waiting")
	check("Waiting for player 1" in game.decision_label.text and var_to_str(game.state) == before, "Guest retains waiting orientation without state mutation")
	game.state.unit_abilities.setup_players = [1]
	game._refresh()
	check(game.unit_action_picker.item_count > 0 and game.action_groups.unit.container.visible, "Guest sees own choices when preparation transfers")
	game.mode = "host"
	game._refresh()
	check(game.unit_action_picker.item_count == 0 and not game.action_groups.unit.container.visible, "Host does not see guest choices")
	game.mode = "local"
	game._refresh()
	check(game.unit_action_picker.item_count > 0 and game.action_groups.unit.container.visible and game._local_player() == 2, "Local mode exposes player two decisions")
	game.state.unit_abilities.setup_players = []
	game._refresh()
	check(game.unit_action_picker.item_count > 0 and game._local_player() == 1, "Local mode also exposes player one decisions")
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
	print("Choice ownership UI checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
