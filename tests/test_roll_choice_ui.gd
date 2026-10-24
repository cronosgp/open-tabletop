extends SceneTree

# Synthetic weapons exercise presentation/command wiring, not datasheet accuracy.
class ControlledGame:
	extends "res://scripts/main.gd"
	var face := 6
	func _d6() -> int:
		journal.roll(state, face)
		return face

const C = preload("res://scripts/edition_11/combat_scenario.gd")
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0
var seen: Array[String] = []
var game: ControlledGame

func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func fixture(phase: String) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 1, true, false, true)
	C.Stratagems.enable(state, true, true, true, true, true, true, true)
	state.phase = phase
	state.cp = {1: 4, 2: 4}
	for model: int in state.units:
		if model not in [100, 200, 201]: state.units[model].wounds = 0
	state.units[100].position = Vector2(-12, -8)
	state.units[200].position = Vector2(-2, -8)
	state.units[201].position = Vector2(0, -8)
	state.squads[1].weapon = {"name": "Synthetic UI fixture", "attacks": "D3+1", "skill": 2, "strength": 10, "ap": -6, "damage": "D6", "range_inches": 30, "keywords": {"hazardous": true}}
	return state

func install(state: Dictionary) -> void:
	game.state = state.duplicate(true)
	game._reset_history()
	game._spawn_pieces()
	game._sync_gameplay_workspace()
	game._dismiss_home(1)
	game._refresh()

# Invoke the real connected buttons on two copies of the same domain checkpoint.
# Walking onward uses Keep, so paying once does not suppress later phase windows.
func exercise_window() -> void:
	var window: Dictionary = C.Stratagems.pending(game.state).duplicate(true)
	var kind := str(window.get("kind", ""))
	check(not kind.is_empty(), "A real domain reaction must exist")
	if kind.is_empty(): return
	var original: Dictionary = game.state.duplicate(true)
	var owner := int(window.player)
	var cp := int(game.state.cp[owner])
	var revision := int(game.state.revision)
	if game.reaction_die.item_count > 0: game.reaction_die.select(game.reaction_die.item_count - 1)
	check(game._local_player() == owner, kind + ": decision owner receives local controls")
	check(game.reaction_roll.is_visible_in_tree() and not game.reaction_roll.disabled and "0 CP" in game.reaction_roll.text, kind + ": visible free Keep")
	game.reaction_roll.pressed.emit()
	check(int(game.state.revision) > revision and int(game.state.cp[owner]) == cp, kind + ": Keep advances without CP")
	check(game.state.get("last_command_roll", {}).get("kind", "") == kind and game.state.last_command_roll.rolls == window.rolls, kind + ": Keep retains original dice")
	var kept: Dictionary = game.state.duplicate(true)
	install(original)
	game.face = 1
	if game.reaction_die.item_count > 0: game.reaction_die.select(game.reaction_die.item_count - 1)
	var selected_die := game.reaction_die.get_selected_id()
	check(game.reaction_use.is_visible_in_tree() and not game.reaction_use.disabled and "1 CP" in game.reaction_use.text, kind + ": visible paid alternative")
	game.reaction_use.pressed.emit()
	check(int(game.state.revision) > revision and int(game.state.cp[owner]) == cp - 1 and game.state.cp[3 - owner] == original.cp[3 - owner], kind + ": paid choice spends exactly owner's CP")
	check(game.state.get("last_command_roll", {}).get("kind", "") == kind and game.state.last_command_roll.original_rolls == window.rolls and game.state.last_command_roll.rolls != window.rolls, kind + ": replacement is mandatory and recorded")
	var final_rolls: Array = game.state.last_command_roll.rolls
	check(final_rolls.size() == window.rolls.size(), kind + ": replacement retains pool size")
	for index in range(final_rolls.size()):
		var expected_face := 1 if kind in ["after_advance_roll", "after_charge_roll"] or index == selected_die else int(window.rolls[index])
		check(int(final_rolls[index]) == expected_face, kind + ": only the selected die (or full movement roll) is replaced")
	if kind not in seen: seen.append(kind)
	game.face = 6
	install(kept)

func run() -> void:
	game = ControlledGame.new()
	root.add_child(game)
	game.match_save_path = "user://matches/roll-ui-%s.save" % Time.get_ticks_usec()
	game.match_journal_directory = "user://matches/journals/roll-ui-%s" % Time.get_ticks_usec()
	game.combat_enabled = true
	game.manual_allocation = true
	for phase: String in ["movement", "charge", "escape"]:
		var state := fixture("movement" if phase == "escape" else phase)
		if phase == "escape":
			state.units[200].position = Vector2(-10.5, -8)
			state.units[201].position = Vector2(-10.5, -6.5)
		install(state)
		var command := {"kind": Commands.CHARGE_ROLL, "model": 100, "revision": game.state.revision} if phase == "charge" else {"kind": Commands.BEGIN_MOVEMENT, "model": 100, "move_type": "desperate_escape" if phase == "escape" else "advance", "revision": game.state.revision}
		var result := Commands.execute(game.state, 1, command, game._d6)
		check(str(result.get("error", "")).is_empty(), phase + ": domain starts: " + str(result))
		game._refresh()
		exercise_window()
	install(fixture("shooting"))
	var shot := Commands.execute(game.state, 1, {"kind": Commands.SHOOT, "attacker": 100, "target": 200, "revision": game.state.revision, "use_lethal": false}, game._d6)
	check(str(shot.get("error", "")).is_empty(), "Synthetic attack begins: " + str(shot))
	for iteration in range(40):
		game._refresh()
		if not C.Stratagems.pending(game.state).is_empty():
			exercise_window()
		elif not game.state.get("pending_attack", {}).is_empty():
			var recipients: Array = C.Allocation.eligible(game.state)
			if recipients.is_empty(): break
			game.selected = int(recipients[0])
			game._refresh()
			check(not game.allocate_button.disabled, "Defender can allocate through UI")
			game.allocate_button.pressed.emit()
		else: break
	var expected := ["after_advance_roll", "after_charge_roll", "after_escape_roll", "after_attack_count_roll", "after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_hazardous_roll"]
	for kind: String in expected: check(kind in seen, "Both real UI alternatives exercised for " + kind)
	print("ROLL CHOICE UI: ", seen, "; failures=", failures)
	game.queue_free()
	await process_frame
	await process_frame
	quit(1 if failures else 0)
