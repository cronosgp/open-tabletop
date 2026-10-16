extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const Ability = C.ObjectiveSecured
const Save = preload("res://scripts/match_save.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func one() -> int: return 1
func fixture(enabled: bool = true) -> Dictionary:
	var state := P.initial_state({"objective_secured": enabled})
	state.phase = "command"
	for id: int in C.living(state, 1): state.units[id].position = Vector2(-9, 4)
	return state
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var legacy := P.initial_state()
	var state := fixture()
	check(not legacy.has("objective_secured") and legacy.pack_hash != state.pack_hash, "Ability opt-in has its own identity and old setups remain disabled")
	check(P.initial_state({"objective_secured": 1}).has("error"), "The public option accepts only booleans")
	check(state.match_manifest.objective_secured == Ability.ID and "objective-secured" not in state.squads[1].disabled_abilities and "target-elimination" in state.squads[1].disabled_abilities, "Only the implemented Intercessor ability is enabled")
	check(state.mission.objectives[1].secured == 0, "Models in range do not secure before a phase boundary")
	var before := var_to_str(state)
	check(not C.advance_phase(state, 2, state.revision, one).is_empty() and var_to_str(state) == before, "The opponent cannot trigger the active player's Command effect")
	check(not C.advance_phase(state, 1, -1, one).is_empty() and var_to_str(state) == before, "Stale requests cannot secure an objective")
	check(C.advance_phase(state, 1, state.revision, one).is_empty() and state.phase == "movement", "A valid end-Command request advances normally")
	var objective: Dictionary = state.mission.objectives[1]
	check(objective.controller == 1 and objective.secured == 1 and "Objective Secured" in state.events[-1].message, "Command control is resolved before the Intercessor ability, and the effect is logged")
	check(Ability.end_command(state).is_empty(), "Other phases do not activate the ability")
	for id: int in C.living(state, 1): state.units[id].position = Vector2(-15, -12)
	C.Objectives.resolve_control(state)
	check(objective.controller == 1 and objective.secured == 1 and objective.levels == {1: 0, 2: 0}, "Secured control survives leaving an empty objective")
	state.units[200].position = Vector2(-9, 4)
	C.Objectives.resolve_control(state)
	check(objective.controller == 2 and objective.secured == 0, "Greater enemy OC removes secured control at the next control boundary")
	state = fixture(false)
	C.advance_phase(state, 1, state.revision, one)
	check(state.mission.objectives[1].controller == 1 and state.mission.objectives[1].secured == 0, "Disabled setups keep ordinary control without automatic securing")
	state = fixture()
	for id: int in C.living(state, 1).slice(2): state.units[id].wounds = 0
	C.advance_phase(state, 1, state.revision, one)
	check(state.squads[1].battle_shocked and state.mission.objectives[1].secured == 0, "Battle-shock resolves first and zero OC cannot secure")
	state = fixture()
	for id: int in C.living(state, 1):
		state.units[id].definition_id = "40kdc:11e:adeptus-astartes:terminator-squad"
	C.advance_phase(state, 1, state.revision, one)
	check(state.mission.objectives[1].secured == 0, "Renaming or copying an Intercessor squad does not grant its ability to another profile")
	state = P.initial_state({"objective_secured": true, "core_stratagems": true})
	state.phase = "command"
	for id: int in C.living(state, 1): state.units[id].position = Vector2(-9, 4)
	for id: int in C.living(state, 1).slice(2): state.units[id].wounds = 0
	C.advance_phase(state, 1, state.revision, one)
	check(not C.Stratagems.pending(state).is_empty() and state.mission.objectives[1].secured == 0, "Pending Battle-shock decisions block securing")
	check(C.resolve_command_reaction(state, 1, 1, "", state.revision, one).is_empty() and state.phase == "movement" and state.mission.objectives[1].secured == 0, "A failed resolved decision cannot secure with zero OC")
	state = fixture()
	state.mission.objectives = [{"name": "Marker", "kind": "marker", "position": Vector2.ZERO, "controller": 0, "secured": 0, "levels": {1: 0, 2: 0}}]
	for id: int in C.living(state, 1): state.units[id].position = Vector2(1, 0)
	C.advance_phase(state, 1, state.revision, one)
	check(state.mission.objectives[0].secured == 1, "The same ability works with marker-range objectives")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.objective_secured_choice.button_pressed = true
	game._start_prepared_match()
	game.state.phase = "command"
	for id: int in C.living(game.state, 1): game.state.units[id].position = Vector2(-9, 4)
	game._reset_history()
	game._request_end()
	check(game.state.mission.objectives[1].secured == 1 and game.journal.entries.size() > 1, "The real UI phase command publishes the effect into the match journal")
	var identity: String = game.state.pack_hash
	game._save_match()
	game._start_objectives()
	game._load_match()
	check(game.objective_secured and game.objective_secured_choice.button_pressed and game.state.pack_hash == identity and game.state.mission.objectives[1].secured == 1, "Save/resume restores the option, setup identity and secured objective")
	var report := P.Training.inspect(P.Training.Capabilities.reference_army("Space Marines").list)
	var enemy := P.Training.inspect(P.Training.Capabilities.reference_army("Necrons").list)
	state = P.initial_state({"objective_secured": true}, {1: report.selection, 2: enemy.selection})
	check(P.from_setup(state.saved_army_setup).pack_hash == state.pack_hash and state.saved_army_setup.options.objective_secured, "Mixed saved-list setup reconstructs with the option frozen")
	game.auto_models.button_pressed = false
	game._start_saved_match()
	check(game.objective_secured and game.state.has("objective_secured"), "The selected ability also reaches local saved-list matches")
	game.objective_secured_choice.button_pressed = false
	game._start_prepared_match()
	game._save_match()
	var old_save := Save.read()
	old_save.config.erase("objective_secured")
	check(Save.write(old_save.state, old_save.config, old_save.rng_state, old_save.attack_draft, Save.PATH, old_save.session, old_save.journal).is_empty(), "Legacy save fixture omits the new option")
	game.objective_secured_choice.button_pressed = true
	game._start_prepared_match()
	game._load_match()
	check(not game.objective_secured and not game.state.has("objective_secured"), "Saves from before this option restore with the ability disabled")
	old_save.config.objective_secured = true
	Save.write(old_save.state, old_save.config, old_save.rng_state, old_save.attack_draft, Save.PATH, old_save.session, old_save.journal)
	before = var_to_str(game.state)
	game._load_match()
	check(var_to_str(game.state) == before and "Objective Secured" in game.status.text, "A save with a conflicting capability flag cannot replace the current match")
	game.saved_army_mode = true
	game.objective_secured = false
	game.mode = "client"
	game.receive_state(state)
	check(game.mode == "local" and "Objective Secured" in game.status.text, "A client rejects an enabled saved-list setup when its option differs")
	print("Objective Secured checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
