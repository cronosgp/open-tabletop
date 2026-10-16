extends SceneTree
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Capabilities = Training.Capabilities
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Matcher = preload("res://scripts/forceorg_matcher.gd")
const Save = preload("res://scripts/match_save.gd")
var failures := 0
var rolls: Array[int] = []
func supplied() -> int: return rolls.pop_front() if not rolls.is_empty() else 1
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var marines := Capabilities.reference_army("Space Marines")
	var necrons := Capabilities.reference_army("Necrons")
	var a := Training.inspect(marines.list)
	var b := Training.inspect(necrons.list)
	check(a.error.is_empty() and b.error.is_empty(), "Both reference armies pass canonical admission")
	if not a.error.is_empty() or not b.error.is_empty():
		quit(1)
		return
	check(a.total == 480 and b.total == 480 and a.unit_count == 4 and b.unit_count == 6, "Reference forces use equal 480-point budgets with different compositions")
	var private_list: Dictionary = marines.list.duplicate(true)
	private_list.name = "PRIVATE NAME"
	private_list.notes = "PRIVATE NOTES"
	for entry: Dictionary in private_list.entries: entry.cost = 1
	check(Training.inspect(private_list).total == 480, "Saved/API prices cannot alter canonical mixed-list costs")
	var bad: Dictionary = a.selection.duplicate(true)
	bad.entries[0].models = 10
	check(not Training.admit(bad).error.is_empty(), "Unsupported model counts reject without automatic resizing")
	bad = a.selection.duplicate(true)
	bad.entries[0].cost = 0
	check(not Training.admit(bad).error.is_empty(), "Public entries reject extra client fields")
	bad = a.selection.duplicate(true)
	bad.entries[0].definition_id = b.selection.entries[0].definition_id
	check(not Training.admit(bad).error.is_empty(), "Cross-faction entries cannot enter the match")
	bad = a.selection.duplicate(true)
	bad.entries.reverse()
	check(Training.digest(bad) == Training.digest(a.selection), "Entry order cannot change a canonical army identity")
	bad = a.selection.duplicate(true)
	bad.entries[0].copies = 5
	bad.entries[1].copies = 2
	check(not Training.admit(bad).error.is_empty(), "Seven squads reject before constructing any pieces")
	bad = a.selection.duplicate(true)
	bad.category = "custom"
	bad.points_limit = 479
	check(not Training.admit(bad).error.is_empty(), "Mixed lists enforce the shared canonical budget")
	var alias: Dictionary = marines.list.duplicate(true)
	alias.entries[1].unit_id = "openhammer:11e:Space%20Marines:4808-a80b-309a-7933"
	check(Training.digest(Training.inspect(alias).selection) == Training.digest(a.selection), "Verified API aliases resolve to canonical Terminators")
	var state := Prepared.initial_state({}, {1: a.selection, 2: b.selection})
	check(not state.has("error") and state.units.size() == 70 and state.squads.size() == 10, "Mixed setup creates every model of all ten squads")
	check(Prepared.from_setup(state.saved_army_setup).pack_hash == state.pack_hash and state.match_manifest.capabilities == Capabilities.ID, "Mixed setup reconstructs with a versioned capability identity")
	check("PRIVATE" not in var_to_str(state) and not state.match_manifest.official_legality_validated, "Private profile fields stay local and legality is not overclaimed")
	check(state.units[500].max_wounds == 3 and is_equal_approx(state.units[500].radius, 40.0 / 50.8), "Terminators use their own wounds and 40mm base")
	var defense := Prepared.Combat.AttackPlan.Groups.profile(state, 500)
	check(defense.save_target == 2 and defense.invulnerable_target == 4, "Terminator defenses reach the combat engine")
	var sergeant := Prepared.Combat.AttackPlan.Equipment.choices(state, 500, true)
	var ordinary := Prepared.Combat.AttackPlan.Equipment.choices(state, 501, true)
	check(sergeant[0].stats.attacks == 5 and ordinary[0].stats.attacks == 3 and ordinary[0].stats.damage == 2, "Sergeant power weapon and ordinary power fists are distinct")
	check(state.squads[2].weapon.strength == 5 and state.squads[2].weapon.keywords.has("lethal-hits"), "Immortal Gauss blasters retain their own stats and traits")
	var exchange := Prepared.initial_state({"manual_allocation": false}, {1: a.selection, 2: b.selection})
	for id: int in exchange.units:
		if id not in [200, 500]: exchange.units[id].wounds = 0
	exchange.units[200].position = Vector2(0, -8)
	exchange.units[500].position = Vector2(10, -8)
	exchange.terrain.areas = []
	exchange.phase = "shooting"
	exchange.active = 2
	rolls = [6, 6, 1, 1]
	var shot := Prepared.Combat.shoot(exchange, 2, 200, 500, exchange.revision, true, supplied)
	check(shot.error.is_empty() and exchange.units[500].wounds == 1, "Immortal Gauss blasters inflict wounds on a real Terminator through the attack engine")
	exchange = Prepared.initial_state({"manual_allocation": false}, {1: a.selection, 2: b.selection})
	for id: int in exchange.units:
		if id not in [200, 500]: exchange.units[id].wounds = 0
	exchange.units[200].position = Vector2(0, -8)
	exchange.units[500].position = Vector2(10, -8)
	exchange.terrain.areas = []
	exchange.phase = "shooting"
	rolls = [6, 6, 6, 6, 6, 6, 6, 6, 1, 1, 1, 1]
	shot = Prepared.Combat.shoot(exchange, 1, 500, 200, exchange.revision, true, supplied)
	check(shot.error.is_empty() and exchange.units[200].wounds == 0 and exchange.squads[5].shot, "A Terminator's storm bolter executes Rapid Fire and removes an Immortal")
	check(a.warnings.size() == 2 and b.warnings.size() == 2, "Each reference army declares the unimplemented unit abilities")
	for step in range(10):
		var owner := Prepared.Deployment.actor(state)
		check(Prepared.Deployment.preset(state, owner, state.revision).is_empty(), "Every mixed squad preview fits its deployment zone without base overlap")
		check(Prepared.Deployment.confirm(state, owner, state.revision).is_empty(), "Every mixed squad can confirm coherent deployment")
	check(state.phase == "start_turn" and state.deployment.complete, "Mixed armies finish alternating deployment")
	var identity: String = state.pack_hash
	for step in range(100):
		if state.test_winner != 0: break
		check(Prepared.Combat.advance_phase(state, Prepared.Combat.actor(state), state.revision).is_empty(), "Mixed armies advance through the complete objective mission")
	check(state.test_winner != 0 and state.pack_hash == identity, "Five rounds finish with a stable roster identity")
	var legacy := Training.inspect(Training.template("Necrons", "training", 500).list)
	check(not Prepared.initial_state({}, {1: a.selection, 2: legacy.selection}).has("error"), "Mixed and legacy selections can play against one another")
	var priced := Training.reprice(private_list)
	check(priced.error.is_empty() and Training.Roster.summary(priced.list).points == 480, "Mixed-list repricing uses each unit's own canonical cost")
	for source: String in ["terminator-squad", "immortals"]:
		var spec: Dictionary = Capabilities.SPECS[source]
		var visual_identity := "40kdc:11e:%s:%s" % [spec.folder, source]
		var entry := {"name": "Terminator" if source == "terminator-squad" else "Immortal", "kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/mesh"}}
		check(Matcher.choose(visual_identity, [entry]).error.is_empty(), "New unit types participate in automatic visual matching")
		if source == "terminator-squad":
			entry.name = "Terminator Captain"
			check(not Matcher.choose(visual_identity, [entry]).error.is_empty(), "Terminator visual matching excludes characters")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	for owner in [1, 2]:
		var picker: OptionButton = game.saved_army_pickers[owner]
		for index in range(picker.item_count):
			if picker.get_item_metadata(index).get("id", "") == (marines.list.id if owner == 1 else necrons.list.id): picker.select(index)
	game._review_saved_armies()
	game._start_saved_match()
	check(game.state.units.size() == 70 and game.pieces.size() == 70 and "teleport-homer" in game.saved_army_review.text, "Actual setup exposes mixed armies, limitations and all rendered pieces")
	game._save_match()
	var saved := Save.read()
	check(saved.get("error", "").is_empty() and saved.state.units.size() == 70, "A mixed match saves all model profiles")
	game._start_objectives()
	game._load_match()
	check(game.saved_army_mode and game.state.units.size() == 70 and game.state.phase == "deployment", "The real resume flow restores mixed armies and deployment")
	print("Mixed army checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
