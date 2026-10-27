extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const Ability = preload("res://scripts/edition_11/implacable_eradication.gd")
const A = preload("res://scripts/edition_11/attack_sequence.gd")
const W = preload("res://scripts/edition_11/attack_roll_window.gd")
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
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var necron := P.Training.inspect(P.Training.Capabilities.reference_army("Necrons").list)
	# This rules exercise remains on isolated historical Necron profiles. It does
	# not combine them with current Space Marine datasheets or certify the rule.
	var selections := {1: necron.selection, 2: necron.selection}
	var state := P.initial_state({"implacable_eradication": true}, selections)
	check(not state.has("error"), "Legacy Necron reference lists support the isolated training capability")
	check(Ability.immortals(state, 2) and not Ability.immortals(state, 6), "Only canonical Immortals qualify")
	check("implacable-eradication" in state.squads[2].enabled_abilities and "implacable-eradication" not in state.squads[2].disabled_abilities, "Ability metadata is enabled")
	check(P.from_setup(state.saved_army_setup).pack_hash == state.pack_hash, "Saved army setup reproduces capability identity")
	check(P.initial_state({}, selections).pack_hash != state.pack_hash, "Capability has its own match identity")
	check(P.initial_state({"implacable_eradication": 1}).has("error"), "Options reject non-booleans")
	check(Ability.mode(state, 2, 1) == "ones", "Outside objectives only ones are repeated")
	state.units[100].position = Vector2(-9, 4)
	check(Ability.mode(state, 2, 1) == "failed", "One living target model in objective range enables failed wound rerolls")
	state.units[100].wounds = 0
	check(Ability.mode(state, 2, 1) == "ones", "Dead target models cannot grant the objective bonus")
	check(Ability.mode(state, 2, 4) == "none", "Friendly targets never grant the ability")
	state.units[200].definition_id = "fake-immortals"
	check(Ability.mode(state, 2, 1) == "none", "A name or mixed identity cannot impersonate Immortals")
	var weapon := {"attacks": 3, "skill": 3, "strength": 4, "ap": -1, "damage": 1, "keywords": {}}
	var defender := {"toughness": 4, "save_target": 3, "invulnerable_target": 0, "wounds_per_model": 2, "remaining_wounds": [2, 2]}
	for mode: String in ["ones", "failed"]:
		var values := [3, 3, 3, 1, 2, 4, 1, 6] if mode == "failed" else [3, 3, 3, 1, 2, 4, 6]
		var context := {"wound_reroll": mode, "defer_saves": true}
		var fast_dice := Dice.new(values)
		var staged_dice := Dice.new(values)
		var result := A.roll_pool(weapon, defender, context, fast_dice.roll)
		var staged := W.begin(weapon, defender, context, staged_dice.roll)
		staged = W.advance(staged, staged.revision, staged_dice.roll)
		check(staged.rerolled_wounds == ([0, 1] if mode == "failed" else [0]), "Automatic rerolls mark the original indices")
		check(0 not in W.eligible(staged), "Command Re-roll cannot repeat an ability reroll")
		var completed := W.advance(staged, staged.revision, staged_dice.roll)
		check(result.error.is_empty() and completed.error.is_empty(), "Both resolution paths complete")
		check(result.wounds == 2 and completed.result.wounds == 2, "Effective wound counts agree")
		check(result.dice_history == completed.result.dice_history, "Fast and staged dice ordering agrees")
	weapon.keywords = {"twin-linked": true}
	var dice := Dice.new([3, 3, 3, 1, 2, 4, 1, 1])
	var twin := W.begin(weapon, defender, {"wound_reroll": "ones", "defer_saves": true}, dice.roll)
	twin = W.advance(twin, twin.revision, dice.roll)
	check(twin.rerolled_wounds == [0, 1] and dice.offset == 8, "Twin-linked and ability form one reroll pool; failed replacements stay failed")
	check(not A._validate(weapon, defender, {"wound_reroll": "anything"}).is_empty(), "Unknown reroll policies are rejected")
	# Exercise the real declaration/allocation path, not just the dice helper.
	var exchange := P.initial_state({"manual_allocation": false, "implacable_eradication": true}, selections)
	for id: int in exchange.units:
		if id not in [200, 500]: exchange.units[id].wounds = 0
	exchange.units[200].position = Vector2(0, -8)
	exchange.units[500].position = Vector2(10, -8)
	exchange.terrain.areas = []
	exchange.phase = "shooting"
	exchange.active = 2
	var plan := P.Combat.AttackPlan.prepare(exchange, 2, false, [{"model": 200, "target": 5, "amount": 1}], true)
	check(plan.error.is_empty() and plan.batches[0].context.wound_reroll == "ones", "Ranged declaration freezes the canonical ability")
	var shot_dice := Dice.new([3, 3, 1, 5, 5, 1, 1])
	var shot := P.Combat.shoot(exchange, 2, 200, 500, exchange.revision, true, shot_dice.roll)
	check(shot.error.is_empty() and exchange.units[500].wounds == 0 and shot_dice.offset == 7, "Real Gauss blaster attack rerolls the one and destroys the one-wound legacy target")
	exchange.units[500].wounds = exchange.units[500].max_wounds
	exchange.units[500].position = Vector2(-9, 4)
	exchange.units[200].position = Vector2(-7.5, 4)
	plan = P.Combat.AttackPlan.prepare(exchange, 2, true, [{"model": 200, "target": 5, "amount": 2}], true)
	check(plan.error.is_empty() and plan.batches[0].context.wound_reroll == "failed", "Melee declaration uses the same objective bonus")
	exchange.units[500].wounds = 0
	check(plan.batches[0].context.wound_reroll == "failed", "Casualties do not change an already declared attack's eligibility")
	var game = load("res://scripts/main.gd").new()
	root.add_child(game)
	await process_frame
	game.auto_models.button_pressed = false
	game.implacable_eradication_choice.button_pressed = true
	game._start_prepared_match()
	check(game.implacable_eradication and game.state.has("implacable_eradication"), "UI option reaches the prepared match")
	game._save_match()
	game._start_objectives()
	game._load_match()
	check(game.implacable_eradication and game.implacable_eradication_choice.button_pressed, "Save/resume restores capability and checkbox")
	game.queue_free()
	await process_frame
	if failures == 0: print("PASS: Implacable Eradication identity, objectives, reroll parity, single reroll and persistence")
	quit(0 if failures == 0 else 1)

