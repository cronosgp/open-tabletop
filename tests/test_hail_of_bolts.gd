extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const H = C.HailOfBolts
const Plan = C.AttackPlan
const Save = preload("res://scripts/match_save.gd")
var failures := 0
var count := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func one() -> int:
	count += 1
	return 1
func fixture(varied: bool = false, enabled: bool = true) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, false, varied)
	if enabled: H.enable(state)
	state.phase = "shooting"
	state.terrain.areas = []
	for id: int in state.units:
		if id not in [100, 101, 200, 201, 400, 401]: state.units[id].wounds = 0
		state.units[id].position = Vector2(-12 if state.units[id].owner == 1 else 3, -8 + (id % 100) * 1.5 if id < 300 else 2 + (id % 100) * 1.5)
	return state
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var legacy := P.initial_state()
	check(legacy.pack_hash == P.initial_state({"hail_of_bolts": false}).pack_hash, "Disabled setups retain old identity")
	check(legacy.pack_hash != P.initial_state({"hail_of_bolts": true}).pack_hash and P.initial_state({"hail_of_bolts": 1}).has("error"), "Capability identity and strict public options")
	var state := fixture()
	var base: int = state.squads[1].weapon.attacks
	var rows := [{"model": 100, "target": 2, "amount": 1}, {"model": 101, "target": 4, "amount": 1}]
	var before := var_to_bytes(state)
	var prepared := Plan.prepare(state, 1, false, rows, true, 2)
	check(prepared.error.is_empty() and prepared.batches.size() == 2, "Split declaration is supported")
	check(prepared.batches[0].weapon.attacks == base + 2 and prepared.batches[1].weapon.attacks == base, "Only rifles assigned to selected unit gain attacks")
	check(prepared.batches[0].context.attack_sources[0].bonus == 2 and prepared.hail_of_bolts.target == 2, "Per-weapon bonus and selected target are frozen")
	check(before == var_to_bytes(state), "Preview never changes source profiles or state")
	check(Plan.prepare(state, 1, false, rows, true).batches[0].weapon.attacks == base, "Declining the optional ability preserves default attacks")
	check(not Plan.prepare(state, 1, true, rows, true, 2).error.is_empty(), "Melee cannot use Hail of Bolts")
	check(not Plan.prepare(state, 1, false, rows, true, 1).error.is_empty(), "Friendly target rejected")
	check(not Plan.prepare(state, 1, false, rows, true, 999).error.is_empty(), "Missing target rejected")
	state.active = 2
	check(not Plan.prepare(state, 1, false, rows, true, 2).error.is_empty(), "Opponent turn rejected")
	state = fixture(false, false)
	check(not Plan.prepare(state, 1, false, rows, true, 2).error.is_empty(), "Disabled ability cannot be requested")
	state = fixture()
	state.units[100].definition_id = "renamed-intercessors"
	check(not H.available(state, 1), "Canonical unit identity is required")
	state = fixture()
	state.units[200].wounds = 0
	state.units[201].wounds = 0
	check(2 not in H.targets(state, 1), "Dead models do not establish target visibility")
	state = fixture()
	state.terrain.areas = [{"id": "wall", "name": "Wall", "kind": "solid", "bounds": Rect2(-8, -12, 2, 30), "height": 6.0}]
	check(2 not in H.targets(state, 1), "A blocked target cannot receive the ability")
	# Curated profiles retain weapon identity; other guns do not inherit the bonus.
	state = fixture(true)
	rows = [{"model": 100, "target": 2, "weapon": "rifle", "profile": "focused", "amount": 1}, {"model": 101, "target": 2, "weapon": "launcher", "profile": "krak", "amount": 1}]
	prepared = Plan.prepare(state, 1, false, rows, true, 2)
	check(prepared.error.is_empty(), "Varied equipment remains playable")
	check(prepared.batches[0].context.attack_sources[0].bonus == 2 and prepared.batches[1].context.attack_sources[0].bonus == 0, "Rifle receives bonus; grenade launcher does not")
	# The core command consumes the expanded pool once, without modifying profiles.
	state = fixture()
	rows = [{"model": 100, "target": 2, "amount": 1}]
	var result := C.resolve_attack_plan(state, 1, 100, rows, state.revision, false, true, one, 2)
	check(result.error.is_empty() and result.pools[0].attacks == base + 2 and count == base + 2, "Real attack rolls the expanded pool")
	check(state.squads[1].weapon.attacks == base and state.last_attack.hail_of_bolts.target == 2 and "Hail of Bolts" in state.last_attack.message, "Result and history retain ability without editing weapon")
	before = var_to_bytes(state)
	check(not C.resolve_attack_plan(state, 1, 100, rows, state.revision, false, true, one, 4).error.is_empty() and before == var_to_bytes(state), "Cannot choose a second ability target after shooting")
	var marine := P.Training.inspect(P.Training.Capabilities.reference_army("Space Marines").list)
	var necron := P.Training.inspect(P.Training.Capabilities.reference_army("Necrons").list)
	state = P.initial_state({"unit_abilities": true, "hail_of_bolts": true, "objective_secured": true}, {1: marine.selection, 2: necron.selection})
	check(state.has("error") and "historical" in str(state.error), "Current datasheets fail closed when paired with historical Hail of Bolts and Objective Secured profiles")
	if state.has("error"):
		print("Hail of Bolts local checks: %d failures" % failures)
		quit(0 if failures == 0 else 1)
		return
	check("hail-of-bolts" in state.squads[1].enabled_abilities and "objective-secured" in state.squads[1].enabled_abilities and "target-elimination" not in state.squads[1].disabled_abilities, "Verified ability replaces the provisional slot and composes with Objective Secured")
	C.ObjectiveSecured.enable(state)
	check("hail-of-bolts" in state.squads[1].enabled_abilities, "Enabling the other ability cannot erase Hail of Bolts")
	check(P.from_setup(state.saved_army_setup).pack_hash == state.pack_hash, "Mixed setup reconstructs capability")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.hail_of_bolts_choice.button_pressed = true
	game.attack_reroll_choice.button_pressed = true
	game.defender_choice.button_pressed = false
	game._start_prepared_match()
	game.state.phase = "shooting"
	game.state.cp[1] = 3
	game.state.terrain.areas = []
	for id: int in game.state.units:
		if id not in [100, 200, 300, 400]: game.state.units[id].wounds = 0
		game.state.units[id].position = Vector2(-12 if game.state.units[id].owner == 1 else -2, -8 if id < 300 else 8)
	game._reset_history()
	game.selected = 100
	game._begin_attack_plan()
	check(game.plan_hail.visible and game.plan_hail.item_count == 3, "UI exposes both visible enemies plus decline")
	var index: int = game.plan_hail.get_item_index(2)
	game.plan_hail.select(index)
	game.plan_hail.item_selected.emit(index)
	game._assign_attack()
	check(game.attack_draft.hail_target == 2 and "+2 attacks per bolt rifle" in game.plan_summary.text, "Choice is explicit and previewed")
	game._save_match()
	game._load_match()
	check(game.hail_of_bolts and game.attack_draft.hail_target == 2 and game.plan_hail.get_selected_id() == 2, "Draft selection survives save/resume")
	game._confirm_attack_plan()
	check(C.Stratagems.pending(game.state).kind == "after_hit_roll" and game.state.pending_attack.prepared.hail_of_bolts.target == 2, "Confirmed target is frozen before subsequent attack decisions")
	var snapshot := var_to_bytes(game.state)
	var rng_state: int = game.rng.state
	game._save_match()
	game._load_match()
	check(var_to_bytes(game.state) == snapshot and game.rng.state == rng_state and game.hail_of_bolts, "Pending expanded pool and RNG resume without regeneration")
	game._start_objectives()
	game._save_match()
	var old := Save.read()
	old.config.erase("hail_of_bolts")
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	game._load_match()
	check(not game.hail_of_bolts and not game.state.has("hail_of_bolts"), "Old saves default to disabled")
	old.config.hail_of_bolts = true
	Save.write(old.state, old.config, old.rng_state, old.attack_draft, Save.PATH, old.session, old.journal)
	snapshot = var_to_bytes(game.state)
	game._load_match()
	check(var_to_bytes(game.state) == snapshot and "Hail of Bolts" in game.status.text, "Conflicting save flag rejected")
	game.queue_free()
	await process_frame
	if failures == 0: print("HAIL OF BOLTS: PASS")
	quit(0 if failures == 0 else 1)
