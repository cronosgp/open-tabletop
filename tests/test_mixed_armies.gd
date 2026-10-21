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
	check(a.total == 550 and b.total == 480 and a.unit_count == 4 and b.unit_count == 6, "Reference compositions use canonical local prices and distinct point totals")
	check(Training.admit_current_catalog(marines.list).error.is_empty(), "The local Wahapedia Marine reference is eligible for new match construction")
	check(not Training.admit_current_catalog(necrons.list).error.is_empty(), "Historical Necron references remain inspectable drafts, outside new match construction")
	var private_list: Dictionary = marines.list.duplicate(true)
	private_list.name = "PRIVATE NAME"
	private_list.notes = "PRIVATE NOTES"
	for entry: Dictionary in private_list.entries: entry.cost = 1
	check(Training.inspect(private_list).total == 550, "Saved/API prices cannot alter canonical mixed-list costs")
	var bad: Dictionary = a.selection.duplicate(true)
	for entry: Dictionary in bad.entries:
		if str(entry.definition_id).ends_with(":terminator-squad"): entry.models = 11
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
	var state := Prepared.initial_state({"unit_abilities": true}, {1: a.selection, 2: a.selection})
	check(not state.has("error") and state.units.size() == 40 and state.squads.size() == 8, "Current mirror setup materializes every model from both admitted lists")
	check(Prepared.from_setup(state.saved_army_setup).pack_hash == state.pack_hash and state.match_manifest.capabilities == Capabilities.ID, "Current setup reconstructs with a versioned capability identity")
	check("PRIVATE" not in var_to_str(state) and not state.match_manifest.official_legality_validated, "Private profile fields stay local and legality is not overclaimed")
	check(state.units[500].max_wounds == 3 and is_equal_approx(state.units[500].radius, 40.0 / 50.8), "Terminators use their own wounds and 40mm base")
	var defense := Prepared.Combat.AttackPlan.Groups.profile(state, 500)
	check(defense.save_target == 2 and defense.invulnerable_target == 4, "Terminator defenses reach the combat engine")
	var sergeant := Prepared.Combat.AttackPlan.Equipment.choices(state, 500, true)
	var ordinary := Prepared.Combat.AttackPlan.Equipment.choices(state, 501, true)
	check(sergeant.size() == 1 and ordinary.size() == 1 and sergeant[0].stats.name == "Power Fist" and ordinary[0].stats == sergeant[0].stats, "Current Terminator profile uses its fixed Power Fist loadout for every model")
	check(a.warnings.is_empty(), "Current Marine reference has no unresolved unit-profile warnings")
	for source: String in ["terminator-squad"]:
		var spec: Dictionary = Capabilities.SPECS[source]
		var visual_identity := "40kdc:11e:%s:%s" % [spec.folder, source]
		var entry := {"name": "Terminator", "kind": "CustomMesh", "references": {"MeshURL": "https://example.invalid/mesh"}}
		check(Matcher.choose(visual_identity, [entry]).error.is_empty(), "New unit types participate in automatic visual matching")
		if source == "terminator-squad":
			entry.name = "Terminator Captain"
			check(not Matcher.choose(visual_identity, [entry]).error.is_empty(), "Terminator visual matching excludes characters")
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	var saved_legacy: Dictionary = game.army_builder.store.save_list(necrons.list)
	check(saved_legacy.error.is_empty(), "Historical profile remains preservable in the local library")
	game._refresh_army_choices()
	var picker: OptionButton = game.saved_army_pickers[2]
	for index in range(picker.item_count):
		var candidate: Variant = picker.get_item_metadata(index)
		if candidate is Dictionary and candidate.get("id", "") == necrons.list.id: picker.select(index)
	game._review_saved_armies()
	var state_before_legacy_start := var_to_str(game.state)
	game._start_saved_match()
	check(var_to_str(game.state) == state_before_legacy_start and game.saved_army_review.text.contains("legacy draft"), "Legacy Necron drafts cannot enter a newly constructed current-catalog match")
	print("Current and legacy army boundary checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
