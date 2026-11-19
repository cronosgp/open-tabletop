extends SceneTree

const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Spectrus = preload("res://scripts/edition_11/spectrus_saved_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const UNIT := "40kdc:11e:adeptus-astartes:spectrus-kill-team"
const SNIPER := "spectrus_sniper_weapon"
const COMBAT_KNIFE := "spectrus_knife_replaced"
const HELIX := "spectrus_helix_gauntlet"
const ROLES := ["sniper-infiltrator", "sniper-infiltrator", "oculus-infiltrator", "oculus-infiltrator", "special-issue-infiltrator", "special-issue-infiltrator", "marksman-infiltrator", "marksman-infiltrator", "marksman-infiltrator", "marksman-infiltrator"]

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func records() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model_index in range(10): result.append(E.defaults_for_model(UNIT, 10, model_index))
	return result

func entry(catalog: Node, copies: int = 1) -> Dictionary:
	var source: Dictionary = catalog.lookup(UNIT)
	for index in range(source.options.size()):
		if int(source.options[index].models) == 10: return R.entry(source, index, copies)
	check(false, "The source-bounded ten-model Spectrus option exists in the consolidated catalog")
	return {}

func set_equipment(item: Dictionary, copy_index: int, model_index: int, field: String, value: Variant, message: String) -> void:
	check(R.set_model_equipment(item, copy_index, model_index, field, value), message)

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Spectrus saved equipment review"
	var item := entry(catalog, 3)
	army.entries = [item]
	set_equipment(item, 0, 0, SNIPER, "las-fusil", "First copy saves a Las Fusil sniper")
	set_equipment(item, 0, 4, COMBAT_KNIFE, true, "First copy saves the special-issue replacement package")
	set_equipment(item, 0, 6, HELIX, true, "First copy assigns one Helix Gauntlet to a Marksman")
	set_equipment(item, 1, 1, SNIPER, "instigator-bolt-carbine", "Second copy independently saves an Instigator Bolt Carbine")
	set_equipment(item, 1, 5, COMBAT_KNIFE, true, "Second copy saves a separate special-issue replacement")
	set_equipment(item, 1, 9, HELIX, true, "Second copy independently assigns its single Helix Gauntlet")
	return army

func check_source_options() -> void:
	check(Spectrus.supports(UNIT) and E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Spectrus uses stacked per-model saved-equipment cards")
	check(Spectrus.valid_size(10) and not Spectrus.valid_size(5), "Only the source-listed ten-model Spectrus size is selectable")
	var profile := P.profile("spectrus-kill-team")
	check(profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000002779", "The Spectrus equipment factory remains bound to the Deathwatch App datasheet")
	check(profile.options.get("sniper_rifle_replacements", []) == ["las-fusil", "instigator-bolt-carbine"] and profile.options.get("combat_knife_replacement", "") == "deathwatch-bolt-carbine-and-ceramite-fists" and profile.options.get("helix_gauntlet_limit", 0) == 1, "All four locally exported option rows and the single Helix limit remain represented")
	var loadouts: Array = profile.get("model_loadouts", [])
	check(loadouts.size() == 10 and loadouts.map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ROLES, "Saved model ordering follows the exact fixed Spectrus role composition")
	var defaults := records()
	check(E.valid_saved_loadout(UNIT, defaults, 10) and E.points_for_loadout(UNIT, defaults, 10) == 0, "Spectrus role defaults pass whole-unit validation and add no points")
	check(E.model_label(UNIT, 10, 0) == "Sniper Infiltrator 1" and E.model_label(UNIT, 10, 3) == "Occulus Infiltrator 2" and E.model_label(UNIT, 10, 5) == "Special-issue Infiltrator 2" and E.model_label(UNIT, 10, 9) == "Marksman Infiltrator 4", "Workshop labels identify each fixed role and repeated model ordinal")
	check(E.controls_for_model(UNIT, 0, 10)[0].field == SNIPER and E.controls_for_model(UNIT, 0, 10)[0].choices.size() == 3, "Sniper role exposes its default and both source-listed replacements")
	check(E.controls_for_model(UNIT, 2, 10).is_empty() and E.controls_for_model(UNIT, 4, 10)[0].field == COMBAT_KNIFE and E.controls_for_model(UNIT, 6, 10)[0].field == HELIX, "Fixed Occulus roles remain selector-free; eligible roles expose their own options")
	var allowed := defaults.duplicate(true)
	allowed[0][SNIPER] = "las-fusil"
	allowed[4][COMBAT_KNIFE] = true
	allowed[6][HELIX] = true
	check(E.valid_saved_loadout(UNIT, allowed, 10), "A source-legal mixed Spectrus loadout passes roster validation")
	for model_index in range(10):
		var equipment: Dictionary = allowed[model_index]
		var expected := P.spectrus_kill_team_model_loadout(model_index, str(equipment.get(SNIPER, "bolt-sniper-rifle")), bool(equipment.get(COMBAT_KNIFE, false)), bool(equipment.get(HELIX, false)))
		var prepared: Dictionary = {}
		E.prepare(prepared, UNIT, equipment, 10, model_index)
		check(not expected.is_empty() and prepared.get("ranged_weapons", []) == expected.ranged and prepared.get("melee_weapons", []) == expected.melee, "Model %d resolves saved choices through the existing Spectrus factory" % (model_index + 1))
		check(prepared.get("saved_model_equipment", {}) == equipment and bool(prepared.get("spectrus_saved_equipment_locked", false)), "Model %d retains its saved record and match lock" % (model_index + 1))
	var wrong_role := defaults.duplicate(true)
	wrong_role[2][SNIPER] = "las-fusil"
	var too_many_helix := defaults.duplicate(true)
	too_many_helix[6][HELIX] = true
	too_many_helix[9][HELIX] = true
	check(not E.valid_saved_loadout(UNIT, wrong_role, 10) and not E.valid_saved_loadout(UNIT, too_many_helix, 10), "Out-of-role choices and a second Helix Gauntlet are rejected")
	check(not E.valid_for_model(UNIT, 0, {SNIPER: true}, 10) and not E.valid_for_model(UNIT, 2, {HELIX: true}, 10) and not E.valid_for_model(UNIT, 10, {}, 10), "Malformed choices, ineligible roles and invalid model indexes are rejected")
	check(not E.valid_saved_loadout(UNIT, defaults.slice(0, 9), 10), "Incomplete ten-model records are rejected")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Spectrus list passes whole-roster validation")
	check(R.summary(army).points == 565, "Three ten-model copies retain 185/185/195 prices with no equipment surcharge")
	var item: Dictionary = army.entries[0]
	var first := R.model_equipment_loadouts(item, 0)
	var second := R.model_equipment_loadouts(item, 1)
	var third := R.model_equipment_loadouts(item, 2)
	check(first[0][SNIPER] == "las-fusil" and first[4][COMBAT_KNIFE] and first[6][HELIX], "First copy reopens its independent sniper, special-issue and Helix choices")
	check(second[1][SNIPER] == "instigator-bolt-carbine" and second[5][COMBAT_KNIFE] and second[9][HELIX], "Second copy retains a different set of per-model choices")
	check(E.valid_saved_loadout(UNIT, first, 10) and E.valid_saved_loadout(UNIT, second, 10) and E.valid_saved_loadout(UNIT, third, 10) and third == records(), "All copies reopen as valid and untouched defaults stay intact")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Configured Spectrus copies enter the consolidated local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"core_stratagems": true, "combat_doctrines": true, "unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize their saved Spectrus copies: " + str(state.get("error", "")))
	if state.has("error"): return
	for owner: int in [1, 2]:
		var squad_offset := 0
		for selected_entry: Dictionary in admitted.selection.entries:
			for copy_index in range(int(selected_entry.copies)):
				var squad := owner + squad_offset * 2
				var copy_loadout: Array = selected_entry.saved_model_loadouts[copy_index]
				for model_index in range(10):
					var model_id := find_model_in_squad(state, owner, squad, model_index)
					check(model_id >= 0, "Player %d copy %d contains model %d" % [owner, squad_offset + 1, model_index + 1])
					if model_id < 0: continue
					var unit: Dictionary = state.units[model_id]
					var equipment: Dictionary = copy_loadout[model_index]
					var expected := P.spectrus_kill_team_model_loadout(model_index, str(equipment.get(SNIPER, "bolt-sniper-rifle")), bool(equipment.get(COMBAT_KNIFE, false)), bool(equipment.get(HELIX, false)))
					check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and int(unit.spectrus_kill_team_model) == model_index, "Player %d copy %d model %d materializes exact saved weapons" % [owner, squad_offset + 1, model_index + 1])
					check(unit.get("saved_model_equipment", {}) == equipment and bool(unit.get("spectrus_saved_equipment_locked", false)), "Player %d copy %d model %d retains its record and match lock" % [owner, squad_offset + 1, model_index + 1])
				squad_offset += 1
	var choices: Array = Actions.choices(state, 1)
	check(not choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")).begins_with("spectrus-sniper") or str(choice.get("action", "")).begins_with("spectrus-combat-knife") or str(choice.get("action", "")).begins_with("spectrus-helix")), "Saved Spectrus models remove duplicate Army Preparation equipment choices")
	var target_model := find_model_in_squad(state, 1, 1, 0)
	if target_model >= 0:
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": "spectrus-sniper-rifle", "model": target_model, "target": 1, "value": "bolt-sniper-rifle"}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Forced match-time Spectrus equipment edit is rejected without mutation")

func find_pickers(node: Node) -> Array[OptionButton]:
	var result: Array[OptionButton] = []
	if node is OptionButton: result.append(node as OptionButton)
	for child: Node in node.get_children(): result.append_array(find_pickers(child))
	return result

func picker_index(picker: OptionButton, wanted: Variant) -> int:
	for index in range(picker.item_count):
		if picker.get_item_metadata(index) == wanted: return index
	return -1

func verify_builder(catalog: Node) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://spectrus-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Spectrus Workshop control review"
	army.entries = [entry(catalog)]
	panel.draft = army
	panel._render_draft()
	panel._select_entry(0)
	var cards: Control = panel.per_model_equipment_controls
	check(cards.get_child_count() == 10, "Workshop renders all ten Spectrus model cards")
	var sniper := cards.get_child(0)
	var fixed := cards.get_child(2)
	var special := cards.get_child(4)
	var marksman := cards.get_child(6)
	var sniper_pickers := find_pickers(sniper)
	var special_pickers := find_pickers(special)
	var marksman_pickers := find_pickers(marksman)
	check((sniper.get_child(0) as Label).text == "Sniper Infiltrator 1" and sniper_pickers.size() == 1 and picker_index(sniper_pickers[0], "las-fusil") >= 0, "Sniper card exposes both sourced replacements above the model label")
	check((fixed.get_child(0) as Label).text == "Occulus Infiltrator 1" and find_pickers(fixed).is_empty(), "Fixed Occulus model card has no irrelevant selector")
	check((special.get_child(0) as Label).text == "Special-issue Infiltrator 1" and special_pickers.size() == 1 and picker_index(special_pickers[0], true) >= 0, "Special-issue card shows the complete Carbine/Fists replacement")
	check((marksman.get_child(0) as Label).text == "Marksman Infiltrator 1" and marksman_pickers.size() == 1 and marksman_pickers[0].item_count == 2, "Marksman card exposes the single-per-unit Helix choice")
	if not sniper_pickers.is_empty():
		var selected := picker_index(sniper_pickers[0], "instigator-bolt-carbine")
		sniper_pickers[0].select(selected)
		sniper_pickers[0].item_selected.emit(selected)
		check(selected >= 0 and panel.dirty and str(R.model_equipment(panel.draft.entries[0], 0, 0)[SNIPER]) == "instigator-bolt-carbine", "Workshop control saves its selection to the stable model record")
	panel.free()
	var path := ProjectSettings.globalize_path("user://spectrus-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate Godot process reopens the configured Spectrus list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog opens without network access")
	var source: Dictionary = catalog.lookup(UNIT)
	check(not source.is_empty(), "The current catalog admits the source-priced Spectrus profile")
	if source.is_empty():
		catalog.free()
		quit(1)
		return
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 565, "Three saved copies pass whole-roster validation with unchanged local prices")
	var item: Dictionary = army.entries[0]
	var before_invalid := item.duplicate(true)
	check(not R.set_model_equipment(item, 0, 2, SNIPER, "las-fusil") and item == before_invalid, "A sniper replacement on a fixed Occulus model is rejected atomically")
	check(not R.set_model_equipment(item, 0, 9, COMBAT_KNIFE, true) and item == before_invalid, "A special-issue replacement on a Marksman model is rejected atomically")
	check(not R.set_model_equipment(item, 0, 9, HELIX, true) and item == before_invalid, "A second Helix Gauntlet on the same copy is rejected atomically")
	var saved_path := ProjectSettings.globalize_path("user://spectrus-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists Spectrus choices by stable copy and model IDs")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_spectrus_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate process reopens the role-scoped equipment records: " + str(child_output))
		var reopened := Store.new(saved_path)
		if reopened.error.is_empty() and reopened.active().lists.size() == 1:
			var active_army: Dictionary = reopened.active().lists[0]
			inspect_bank(active_army)
			verify_matches(active_army)
		verify_builder(catalog)
	catalog.free()
	for suffix in ["", ".bak", ".panel", ".panel.bak"]:
		if FileAccess.file_exists(saved_path + suffix): DirAccess.remove_absolute(saved_path + suffix)
	await process_frame
	print("Saved Spectrus equipment: %d failures" % failures)
	quit(1 if failures else 0)
