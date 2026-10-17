extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const D = C.Doctrines
const Save = preload("res://scripts/match_save.gd")
var failures := 0
var calls := 0
func six() -> int:
	calls += 1
	return 6
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture(gladius: bool = true, equipped: bool = false) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 1, false, equipped)
	state.terrain.areas = []
	for id: int in state.units:
		state.units[id].wounds = state.units[id].max_wounds if id in [100, 200] else 0
	state.units[100].position = Vector2(-5, -5)
	state.units[200].position = Vector2(4, -5)
	state.squads[1].weapon.keywords.erase("assault")
	if equipped:
		for instance: Dictionary in state.units[100].ranged_weapons:
			for profile: Dictionary in instance.profiles.values(): profile.keywords.erase("assault")
	D.enable(state, gladius)
	C.advance_phase(state, 1, state.revision)
	return state
func choose(state: Dictionary, doctrine: String) -> String:
	return C.select_combat_doctrine(state, 1, doctrine, state.revision)
func next_command(state: Dictionary) -> void:
	state.turn += 2
	state.active = 1
	state.phase = "start_turn"
	C.advance_phase(state, 1, state.revision)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(P.initial_state().pack_hash == P.initial_state({"combat_doctrines": false}).pack_hash, "Disabled setup identity is unchanged")
	check(P.initial_state().pack_hash != P.initial_state({"combat_doctrines": true}).pack_hash and P.initial_state({"combat_doctrines": 1}).has("error"), "Explicit 11e manifest and strict boolean option")
	check(P.initial_state({"combat_doctrines": true, "oath_of_moment": true}).has("error"), "Current doctrines cannot mix with historical Oath")
	var state := fixture()
	check(D.needs_choice(state) and state.cp == {1: 0, 2: 0} and calls == 0, "Start-of-Command doctrine choice precedes core CP and dice")
	var before := var_to_bytes(state)
	check(not C.advance_phase(state, 1, state.revision, six).is_empty() and not C.begin_movement(state, 1, 100, "advance", state.revision, six).is_empty(), "Mandatory start choice blocks ordinary commands")
	check(not C.select_combat_doctrine(state, 2, "assault", state.revision).is_empty() and not C.select_combat_doctrine(state, 1, "assault", -1).is_empty() and not choose(state, "invented").is_empty(), "Wrong player, stale revision and unknown doctrine rejected")
	check(before == var_to_bytes(state) and calls == 0, "Rejected choices do not mutate state or dice")
	check(choose(state, "none").is_empty() and D.active_for(state, 1).is_empty() and D.available(state, 1).size() == 3 and state.cp == {1: 1, 2: 1}, "Declining preserves all uses and proceeds to core CP once")
	check(not choose(state, "assault").is_empty() and state.cp == {1: 1, 2: 1}, "Cannot change decision or gain CP twice")
	next_command(state)
	check(choose(state, "assault").is_empty() and D.active_for(state, 1) == "assault" and D.active_for(state, 2).is_empty(), "Doctrine applies to admitted Marine army only")
	state.active = 2
	state.phase = "command"
	D.start_command(state)
	check(D.active_for(state, 1) == "assault" and not D.needs_choice(state), "Effect persists through enemy Command without granting enemy a choice")
	next_command(state)
	check(D.active_for(state, 1).is_empty() and D.needs_choice(state), "Old doctrine expires before next own choice")
	check(choose(state, "assault").is_empty() and state.combat_doctrines.extra_used[1], "Gladius can spend its one shared extra use on a repeated doctrine")
	next_command(state)
	check("assault" not in D.available(state, 1) and not choose(state, "assault").is_empty(), "Third use forbidden")
	choose(state, "tactical")
	next_command(state)
	check("tactical" not in D.available(state, 1) and choose(state, "devastator").is_empty(), "Gladius extra use is shared across doctrines, not one extra each")
	next_command(state)
	check(not D.needs_choice(state) and state.cp == {1: 6, 2: 6}, "After all uses are spent, Command gains core CP without a useless choice")
	state = fixture(false)
	choose(state, "devastator")
	next_command(state)
	check("devastator" not in D.available(state, 1) and not state.combat_doctrines.extra_used.get(1, false), "Army rule without Gladius permits each doctrine once")
	# Actual Advance flow: doctrine grants Assault to each server-owned ranged profile.
	for equipped in [false, true]:
		state = fixture(true, equipped)
		choose(state, "devastator")
		C.advance_phase(state, 1, state.revision, six)
		check(C.begin_movement(state, 1, 100, "advance", state.revision, six).is_empty() and C.finish_movement(state, 1, state.revision).is_empty(), "Advance roll and zero-distance confirmation retain move type")
		state.phase = "shooting"
		var choice := C.AttackPlan.Equipment.select(state, 100, false)
		check(not choice.stats.keywords.get("assault", false) and D.weapon(state, 1, choice.stats, false).keywords.assault, "Effective Assault keyword does not mutate source weapon")
		check(2 in C.AttackPlan.legal_targets(state, 100, false), "Devastator allows advanced ranged targeting")
		var plan := C.AttackPlan.single_target(state, 1, 2, false)
		check(C.attack_plan_error(state, 1, 100, plan, state.revision, false).is_empty(), "Legacy and equipped plans accept Devastator shooting")
		check(not C.can_start_action(state, 1), "Doctrine does not waive action restrictions after Advance")
		state.phase = "charge"
		check(not C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Devastator does not allow advance-charge")
		state.squads[1].advanced = false
		state.squads[1].fell_back = true
		state.phase = "shooting"
		check(not C.attack_window_error(state, 1, 100, state.revision, false).is_empty(), "Devastator does not waive Fall Back shooting restriction")
	state = fixture()
	choose(state, "assault")
	C.advance_phase(state, 1, state.revision, six)
	C.begin_movement(state, 1, 100, "advance", state.revision, six)
	C.finish_movement(state, 1, state.revision)
	state.phase = "shooting"
	check(C.AttackPlan.legal_targets(state, 100, false).is_empty(), "Assault Doctrine does not grant the Assault weapon keyword")
	state.phase = "charge"
	check(C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Assault permits a real Advance followed by charge declaration")
	state = fixture()
	choose(state, "tactical")
	C.advance_phase(state, 1, state.revision, six)
	state.units[200].position = Vector2(-3.5, -5)
	check(C.begin_movement(state, 1, 100, "ordered_retreat", state.revision).is_empty(), "Tactical does not bypass requirement to be engaged for Fall Back")
	check(C.move(state, 1, 100, Vector2(-9, -5), state.revision).is_empty() and C.finish_movement(state, 1, state.revision).is_empty(), "Actual Fall Back still needs legal movement and leaving engagement")
	state.phase = "shooting"
	check(C.attack_window_error(state, 1, 100, state.revision, false).is_empty(), "Tactical permits shooting after actual Fall Back")
	check(not C.can_start_action(state, 1), "Tactical does not waive Fall Back action restriction")
	state.phase = "charge"
	check(C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Tactical permits charge after actual Fall Back")
	state = fixture()
	choose(state, "assault")
	state.phase = "charge"
	state.squads[1].advanced = true
	state.squads[1].started_action_turn = state.turn
	check(not C.declare_charge(state, 1, 100, state.revision, six).error.is_empty(), "Doctrine never bypasses action/engagement restrictions")
	state.units[100].definition_id = "40kdc:11e:necrons:necron-warriors"
	check(D.active_for(state, 1).is_empty(), "Foreign or mixed faction cannot inherit doctrine")
	var marine := P.Training.inspect(P.Training.Capabilities.reference_army("Space Marines").list)
	var necron := P.Training.inspect(P.Training.Capabilities.reference_army("Necrons").list)
	state = P.initial_state({"combat_doctrines": true}, {1: marine.selection, 2: necron.selection})
	check(P.from_setup(state.saved_army_setup).pack_hash == state.pack_hash and state.combat_doctrines.gladius, "Saved lists freeze declared Gladius effect and reconstruct identity")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.combat_doctrines_choice.button_pressed = true
	game._start_prepared_match()
	game.state.phase = "start_turn"
	game._reset_history()
	game._request_end()
	check(game.action_groups.doctrine.container.visible and not game.doctrine_confirm.disabled and game.end_button.disabled, "Required doctrine choice is focused in Play")
	var saved_state: Dictionary = game.state.duplicate(true)
	var saved_rng: int = game.rng.state
	game._save_match()
	game._load_match()
	check(game.combat_doctrines and game.state == saved_state and game.rng.state == saved_rng, "Pending start choice survives save before core CP gain")
	game.doctrine_choice.select(game.doctrine_choice.get_item_index(3))
	game._request_combat_doctrine()
	check(D.active_for(game.state, 1) == "assault" and game.state.cp == {1: 1, 2: 1} and game.rng.state == saved_rng, "UI selection applies doctrine without dice or CP cost")
	game.state.phase = "charge"
	game.state.squads[1].advanced = true
	game.selected = 100
	game._refresh()
	check(not game.charge_button.disabled, "Charge UI reflects Assault eligibility")
	game._reset_history()
	game._save_match()
	saved_state = game.state.duplicate(true)
	game._load_match()
	check(game.state == saved_state and game.state.combat_doctrines.used[1] == ["assault"], "Active effect and spent-use record survive save")
	game._start_objectives()
	game._save_match()
	var old := Save.read()
	old.config.erase("combat_doctrines")
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	game._load_match()
	check(not game.combat_doctrines and not game.state.has("combat_doctrines"), "Old saves default to disabled")
	old.config.combat_doctrines = true
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	before = var_to_bytes(game.state)
	game._load_match()
	check(before == var_to_bytes(game.state) and "Combat Doctrines" in game.status.text, "Conflicting save option rejected")
	game.queue_free()
	await process_frame
	print("11E COMBAT DOCTRINES: %d failures" % failures)
	quit(0 if failures == 0 else 1)
