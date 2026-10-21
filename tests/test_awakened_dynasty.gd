extends SceneTree
const F = preload("res://tests/awakened_fixture.gd")
const P = F.P
const C = F.C
const A = F.A
const Save = preload("res://scripts/match_save.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func six() -> int: return 6
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(P.initial_state().pack_hash == P.initial_state({"awakened_dynasty": false}).pack_hash, "Disabled identity remains unchanged")
	check(P.initial_state().pack_hash != P.initial_state({"awakened_dynasty": true}).pack_hash and P.initial_state({"awakened_dynasty": 1}).has("error"), "Explicit flag freezes the current detachment effect")
	var state := F.fresh()
	check(A.needs_setup(state) and C.actor(state) == 2 and A.candidates(state) == [2, 4], "Real Overlord lists require pre-deployment choice of supported e11 bodyguards")
	check(P.from_setup(state.saved_army_setup).pack_hash == state.pack_hash, "Saved lists reconstruct frozen options and initial identity")
	var before := var_to_bytes(state)
	check(not C.Deployment.preset(state, 1, 0).is_empty() and not C.advance_phase(state, 2, 0).is_empty(), "Deployment and gameplay cannot skip attachment declaration")
	check(not C.select_awakened_attachment(state, 1, 4, 0).is_empty() and not C.select_awakened_attachment(state, 2, 4, -1).is_empty() and not C.select_awakened_attachment(state, 2, 1, 0).is_empty() and not C.select_awakened_attachment(state, 2, 6, 0).is_empty(), "Wrong owner, stale revision, enemy and self targets rejected")
	check(before == var_to_bytes(state), "Invalid declarations leave the entire setup untouched")
	var identity: String = state.pack_hash
	check(C.select_awakened_attachment(state, 2, 4, 0).is_empty() and not A.needs_setup(state) and state.units[600].squad == 4 and not state.squads.has(6), "Overlord and Warriors become one real unit")
	check(state.pack_hash == identity and state.cp == {1: 0, 2: 0} and state.squads[4].starting_strength == 11 and state.units[600].max_wounds == 6, "Attachment preserves match identity, wounds, weapons and CP")
	check(state.deployment.order == [1, 2, 4] and C.Deployment.confirm(state, 1, state.revision) != "", "Deployment order is rebuilt and still requires model placement")
	check(F.finish_preparations(state).is_empty(), "Both players finish the current-profile army preparations")
	check(C.Deployment.preset(state, 1, state.revision).is_empty() and C.Deployment.confirm(state, 1, state.revision).is_empty(), "Other player deploys normally after declarations")
	C.Deployment.preset(state, 2, state.revision)
	C.Deployment.confirm(state, 2, state.revision)
	check(C.Deployment.current(state) == 4 and C.Deployment.preset(state, 2, state.revision).is_empty() and C.Deployment.confirm(state, 2, state.revision).is_empty(), "Leader preview can be reviewed and committed with all bodyguard models")
	check(A.hit_bonus(state, 4) == 1 and A.hit_bonus(state, 6) == 0 and A.hit_bonus(state, 1) == 0, "Only the actually led Necron unit receives +1")
	F.combat(state)
	var weapon: Dictionary = state.squads[4].weapon.duplicate(true)
	var plan := C.AttackPlan.prepare(state, 4, false, [{"model": 400, "target": 1, "amount": 1}], true)
	check(plan.error.is_empty() and plan.batches[0].context.hit_modifier == 1 and state.squads[4].weapon == weapon, "Ranged plan receives the bonus without modifying its source profile")
	var frozen := plan.duplicate(true)
	state.units[600].wounds = 0
	check(A.hit_bonus(state, 4) == 0 and C.AttackPlan.prepare(state, 4, false, [{"model": 400, "target": 1, "amount": 1}], true).batches[0].context.hit_modifier == 0 and frozen.batches[0].context.hit_modifier == 1, "Leader death removes future bonus while declared attack context remains frozen")
	state.units[600].wounds = 6
	for id in range(400, 410): state.units[id].wounds = 0
	check(A.hit_bonus(state, 4) == 1, "e11 19.04 retains leading abilities after the last bodyguard dies")
	state.units[400].wounds = 1
	state.units[600].attachment_role = "support"
	check(A.hit_bonus(state, 4) == 0, "Support does not impersonate a Leader")
	state.units[600].attachment_role = "leader"
	state.units[600].keywords = state.units[600].keywords.filter(func(keyword): return str(keyword).to_upper() != "CHARACTER")
	check(A.hit_bonus(state, 4) == 0, "Role alone is insufficient without Character identity")
	state = F.fresh()
	check(C.select_awakened_attachment(state, 2, -1, 0).is_empty() and A.hit_bonus(state, 4) == 0 and A.hit_bonus(state, 2) == 0, "Standalone character does not buff itself or nearby units")
	state = F.fresh({"awakened_dynasty": true, "reanimation_protocols": true})
	check(A.candidates(state) == [2, 4] and C.select_awakened_attachment(state, 2, 4, 0).is_empty() and C.Reanimation.supported_unit(state, 4), "Admitted Overlord attachment supports Reanimation before deployment")
	state = F.fresh()
	C.select_awakened_attachment(state, 2, 2, 0)
	check(A.hit_bonus(state, 2) == 1 and A.hit_bonus(state, 4) == 0, "Verified Overlord/Immortal pairing also receives Command Protocols")
	state = F.fresh()
	C.select_awakened_attachment(state, 2, 4, 0)
	F.combat(state)
	for id: int in state.units:
		if id not in [100, 600, 400]: state.units[id].wounds = 0
	state.units[100].position = Vector2(0, 0)
	state.units[400].position = Vector2(1.5, 0)
	state.units[600].position = Vector2(1.5, 1.5)
	plan = C.AttackPlan.prepare(state, 4, true, C.AttackPlan.single_target(state, 4, 1, true), true)
	check(plan.error.is_empty() and not plan.batches.is_empty(), "Mixed Character/bodyguard melee uses owned weapon profiles")
	for batch: Dictionary in plan.get("batches", []): check(batch.context.hit_modifier == 1, "Character and bodyguard melee attacks both benefit")
	# Modifier aggregation: +1 led, +1 Heavy, -1 engaged heavy target => +1 final.
	state = F.fresh()
	C.select_awakened_attachment(state, 2, 4, 0)
	F.combat(state)
	state.units[100].keywords.append("VEHICLE")
	state.units[200].position = state.units[100].position + Vector2(1.5, 0)
	state.squads[4].moved_distance = 0.0
	for item: Dictionary in state.units[400].ranged_weapons:
		for profile: Dictionary in item.profiles.values(): profile.keywords.heavy = true
	plan = C.AttackPlan.prepare(state, 4, false, [{"model": 400, "target": 1, "amount": 1}], true)
	check(plan.error.is_empty() and plan.batches[0].context.hit_modifier == 1, "Modifiers aggregate before final +/-1 cap")
	# Real UI and saves use real inspected lists, not injected client stats.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.awakened_dynasty_choice.button_pressed = true
	game.unit_abilities_choice.button_pressed = true
	F.populate(game, 1)
	F.populate(game, 2)
	game.saved_training_consent.button_pressed = true
	game._start_saved_match(true)
	check(A.needs_setup(game.state) and game.action_groups.awakened.container.visible and not game.awakened_confirm.disabled, "Pre-deployment UI exposes current Overlord assignment")
	var saved: Dictionary = game.state.duplicate(true)
	var rng: int = game.rng.state
	game._save_match()
	game._load_match()
	check(game.awakened_dynasty and game.state == saved and game.rng.state == rng, "Pending declaration survives save without dice")
	game.awakened_target.select(game.awakened_target.get_item_index(4))
	game._request_awakened_attachment()
	check(game.state.units[600].squad == 4 and A.hit_bonus(game.state, 4) == 1 and game.rng.state == rng, "UI assignment preserves models and RNG")
	game._save_match()
	saved = game.state.duplicate(true)
	game._load_match()
	check(game.state == saved and game.state.deployment.order == [1, 2, 4], "Completed assignment restores with rebuilt deployment and led effect")
	game._start_objectives()
	game._save_match()
	var old := Save.read()
	old.config.erase("awakened_dynasty")
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	game._load_match()
	check(not game.awakened_dynasty and not game.state.has("awakened_dynasty"), "Historical saves default to disabled")
	old.config.awakened_dynasty = true
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	before = var_to_bytes(game.state)
	game._load_match()
	check(before == var_to_bytes(game.state) and "Awakened" in game.status.text, "Conflicting saved option rejected")
	game.queue_free()
	await process_frame
	print("11E AWAKENED DYNASTY: %d failures" % failures)
	quit(0 if failures == 0 else 1)
