extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const O = C.OathOfMoment
const A = preload("res://scripts/edition_11/attack_sequence.gd")
const W = preload("res://scripts/edition_11/attack_roll_window.gd")
const Save = preload("res://scripts/match_save.gd")
var failures := 0
class Dice:
	extends RefCounted
	var values: Array
	var offset := 0
	func _init(input: Array) -> void: values = input
	func roll() -> int:
		if offset >= values.size(): return 0
		var value: int = values[offset]
		offset += 1
		return value
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture(codex_context: bool = true) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2)
	O.enable(state, codex_context)
	return state
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(P.initial_state().pack_hash == P.initial_state({"oath_of_moment": false}).pack_hash, "Disabled match identity is unchanged")
	check(P.initial_state().pack_hash != P.initial_state({"oath_of_moment": true}).pack_hash and P.initial_state({"oath_of_moment": 1}).has("error"), "Explicit identity and boolean options")
	var state := fixture()
	state.phase = "start_turn"
	check(C.advance_phase(state, 1, state.revision).is_empty() and O.needs_choice(state) and state.cp == {1: 1, 2: 1}, "Selection opens at Command entry after CP gain")
	check(O.targets(state, 1) == [2, 4], "Both living enemy units are eligible without range or visibility requirements")
	var before := var_to_bytes(state)
	check(not C.advance_phase(state, 1, state.revision).is_empty(), "Cannot leave Command before selection")
	check(not C.begin_movement(state, 1, 100, "normal", state.revision).is_empty(), "Other gameplay commands are blocked")
	check(not C.select_oath_target(state, 2, 2, state.revision).is_empty() and not C.select_oath_target(state, 1, 1, state.revision).is_empty(), "Wrong owner and friendly target rejected")
	check(not C.select_oath_target(state, 1, 2, 0).is_empty() and before == var_to_bytes(state), "Stale revision rejected transactionally")
	check(C.select_oath_target(state, 1, 2, state.revision).is_empty() and not O.needs_choice(state), "Choose one target without CP or dice")
	check(state.cp == {1: 1, 2: 1} and O.context(state, 1, 2) == {"hit_reroll": "failed", "wound_modifier": 1}, "Codex-context attacks receive hit rerolls and the conditional wound modifier")
	check(O.context(state, 1, 4).is_empty() and O.context(state, 2, 1).is_empty(), "Other targets and enemy faction do not inherit Oath")
	check(not C.select_oath_target(state, 1, 4, state.revision).is_empty(), "No second selection this Command phase")
	state.phase = "fight"
	state.active = 2
	check(not O.context(state, 1, 2).is_empty(), "Effect lasts during opponent's turn and applies in melee")
	state.active = 1
	state.turn = 3
	state.phase = "start_turn"
	check(C.advance_phase(state, 1, state.revision).is_empty() and O.needs_choice(state) and O.context(state, 1, 2).is_empty(), "Old target expires at next own Command start")
	state = fixture(false)
	state.phase = "command"
	C.select_oath_target(state, 1, 2, state.revision)
	check(O.context(state, 1, 2).wound_modifier == 0, "Non-Codex context gets hit rerolls without the wound bonus")
	state.oath_of_moment.codex_context = true
	state.units[100].keywords.append("BLOOD ANGELS")
	check(O.context(state, 1, 2).wound_modifier == 0, "Excluded chapter anywhere in army removes Codex bonus")
	state.units[100].definition_id = "40kdc:11e:necrons:necron-warriors"
	check(O.context(state, 1, 2).is_empty(), "Mixed or foreign army identities cannot impersonate Space Marines")
	# Fast and staged paths share ordering, modifiers and reroll exclusion.
	var weapon := {"attacks": 2, "skill": 3, "strength": 4, "ap": 0, "damage": 1, "keywords": {}}
	var defender := {"toughness": 4, "save_target": 3, "invulnerable_target": 0, "wounds_per_model": 2, "remaining_wounds": [2, 2]}
	var context := {"hit_reroll": "failed", "wound_modifier": 1, "defer_saves": true}
	var dice := Dice.new([1, 4, 6, 3, 1])
	var staged_dice := Dice.new([1, 4, 6, 3, 1])
	var fast := A.roll_pool(weapon, defender, context, dice.roll)
	var staged := W.begin(weapon, defender, context, staged_dice.roll)
	check(staged.hit_rolls == [6, 4] and staged.rerolled_hits == [0] and W.eligible(staged) == [1], "Automatic hit replacements cannot be Command Re-rolled")
	staged = W.advance(staged, staged.revision, staged_dice.roll)
	staged = W.advance(staged, staged.revision, staged_dice.roll)
	check(fast.error.is_empty() and staged.error.is_empty() and fast.wounds == 1 and staged.result.wounds == 1 and fast.dice_history == staged.result.dice_history, "Both paths preserve dice order and +1 wound effect")
	weapon.keywords = {"lethal-hits": true, "sustained-hits": 1}
	dice = Dice.new([1, 4, 6, 3, 3])
	fast = A.roll_pool(weapon, defender, context, dice.roll)
	check(fast.error.is_empty() and fast.hits == 3 and fast.wounds == 3, "Replacement critical triggers Lethal and Sustained Hits from final dice")
	weapon.keywords = {}
	weapon.attacks = "D3"
	dice = Dice.new([2, 1, 4, 6])
	staged = W.begin(weapon, defender, context, dice.roll, true)
	check(dice.offset == 1 and staged.phase == "generation", "Random attack count still pauses before hits")
	staged = W.advance(staged, staged.revision, dice.roll)
	check(dice.offset == 3 and staged.hit_rolls == [4] and staged.rerolled_hits == [0], "Generation continuation also applies Oath once")
	check(not A._validate(weapon, defender, {"hit_reroll": "invented"}).is_empty(), "Unknown hit policy rejected")
	var marine := P.Training.inspect(P.Training.Capabilities.reference_army("Space Marines").list)
	var necron := P.Training.inspect(P.Training.Capabilities.reference_army("Necrons").list)
	state = P.initial_state({"oath_of_moment": true}, {1: marine.selection, 2: necron.selection})
	check(P.from_setup(state.saved_army_setup).pack_hash == state.pack_hash and state.oath_of_moment.owners == [1], "Mixed army setup freezes the declared profile")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.oath_of_moment_choice.button_pressed = true
	game._start_prepared_match()
	game.state.phase = "start_turn"
	game._reset_history()
	game._request_end()
	check(game.oath_target.visible and not game.oath_confirm.disabled and game.action_groups.oath.container.visible, "Mandatory target selection is prominent in Play")
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match()
	check(game.oath_of_moment and O.needs_choice(game.state) and game.rng.state == rng_state, "Pending faction choice survives save without dice")
	game._request_oath_target()
	check(not O.needs_choice(game.state) and game.state.oath_of_moment.targets[1] == 2 and game.rng.state == rng_state, "UI confirms the faction target without rolling dice")
	game._start_objectives()
	game._save_match()
	var old := Save.read()
	old.config.erase("oath_of_moment")
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	game._load_match()
	check(not game.oath_of_moment and not game.state.has("oath_of_moment"), "Old saves restore disabled")
	old.config.oath_of_moment = true
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	before = var_to_bytes(game.state)
	game._load_match()
	check(var_to_bytes(game.state) == before and "Oath of Moment" in game.status.text, "Conflicting save flag rejected")
	game.queue_free()
	await process_frame
	if failures == 0: print("OATH OF MOMENT: PASS")
	quit(0 if failures == 0 else 1)
