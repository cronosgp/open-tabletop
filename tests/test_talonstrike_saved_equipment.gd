extends SceneTree

const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Talonstrike = preload("res://scripts/edition_11/talonstrike_saved_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const UNIT := "40kdc:11e:adeptus-astartes:talonstrike-kill-team"
const MELEE := "talonstrike_sergeant_melee"
const RANGED := "talonstrike_sergeant_ranged"
const INTERCESSOR_PLASMA := "talonstrike_intercessor_plasma_pistol"
const HEAVY_PLASMA := "talonstrike_plasma_exterminator"
const ROLES := ["sergeant", "heavy-intercessor", "heavy-intercessor", "heavy-intercessor", "heavy-intercessor", "intercessor", "intercessor", "intercessor", "intercessor", "intercessor"]

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
	check(false, "The source-bounded ten-model Talonstrike option exists in the consolidated catalog")
	return {}

func set_equipment(item: Dictionary, copy_index: int, model_index: int, field: String, value: Variant, message: String) -> void:
	check(R.set_model_equipment(item, copy_index, model_index, field, value), message)

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Talonstrike saved equipment review"
	var item := entry(catalog, 3)
	army.entries = [item]
	set_equipment(item, 0, 0, MELEE, "power-fist", "First copy saves the Sergeant Power Fist")
	set_equipment(item, 0, 0, RANGED, "plasma-pistol", "First copy saves the Sergeant Plasma Pistol")
	set_equipment(item, 0, 1, HEAVY_PLASMA, true, "First copy saves an independent Heavy Intercessor Plasma Exterminator")
	set_equipment(item, 0, 2, HEAVY_PLASMA, true, "First copy can equip a second Heavy Intercessor Plasma Exterminator")
	set_equipment(item, 0, 3, HEAVY_PLASMA, true, "First copy can equip a third Heavy Intercessor Plasma Exterminator")
	set_equipment(item, 0, 4, HEAVY_PLASMA, true, "First copy can equip a fourth Heavy Intercessor Plasma Exterminator")
	set_equipment(item, 0, 5, INTERCESSOR_PLASMA, true, "First copy assigns its one per five-model Plasma Pistol")
	set_equipment(item, 0, 6, INTERCESSOR_PLASMA, true, "First copy assigns a second Plasma Pistol for its second five models")
	set_equipment(item, 1, 0, MELEE, "power-weapon", "Second copy independently saves the Sergeant Power Weapon")
	set_equipment(item, 1, 0, RANGED, "hand-flamer", "Second copy independently saves the Sergeant Hand Flamer")
	set_equipment(item, 1, 4, HEAVY_PLASMA, true, "Second copy independently saves a Heavy Intercessor replacement")
	set_equipment(item, 1, 9, INTERCESSOR_PLASMA, true, "Second copy independently assigns its one Plasma Pistol")
	return army

func check_source_options() -> void:
	check(Talonstrike.supports(UNIT) and E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Talonstrike uses stacked per-model saved-equipment cards")
	check(Talonstrike.valid_size(10) and not Talonstrike.valid_size(5), "Only the source-listed ten-model Talonstrike size is selectable")
	var profile := P.profile("talonstrike-kill-team")
	check(profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000003874", "The saved-equipment factory remains bound to the Deathwatch App datasheet")
	check(profile.options.get("sergeant_melee_replacements", []) == ["power-fist", "power-weapon"] and profile.options.get("sergeant_ranged_replacements", []) == ["hand-flamer", "plasma-pistol"] and profile.options.get("intercessor_plasma_pistols_per_five_models", 0) == 1 and profile.options.get("heavy_intercessor_plasma_exterminators", "") == "any", "All four local option rows and their distinct model/unit limits remain represented")
	var loadouts: Array = profile.get("model_loadouts", [])
	check(loadouts.size() == 10 and loadouts.map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ROLES, "Saved model order follows the fixed Sergeant/Heavy Intercessor/Intercessor composition")
	var defaults := records()
	check(E.valid_saved_loadout(UNIT, defaults, 10) and E.points_for_loadout(UNIT, defaults, 10) == 0, "Role defaults pass whole-unit validation and add no points")
	check(E.model_label(UNIT, 10, 0) == "Talonstrike Sergeant" and E.model_label(UNIT, 10, 4) == "Heavy Intercessor 4" and E.model_label(UNIT, 10, 9) == "Intercessor 5", "Workshop labels expose the role and ordinal for each model")
	check(E.controls_for_model(UNIT, 0, 10).size() == 2 and E.controls_for_model(UNIT, 1, 10)[0].field == HEAVY_PLASMA and E.controls_for_model(UNIT, 5, 10)[0].field == INTERCESSOR_PLASMA, "Each role receives only its source-listed controls")
	var legal := defaults.duplicate(true)
	legal[0][MELEE] = "power-fist"
	legal[0][RANGED] = "plasma-pistol"
	for model_index in [1, 2, 3, 4]: legal[model_index][HEAVY_PLASMA] = true
	legal[5][INTERCESSOR_PLASMA] = true
	check(E.valid_saved_loadout(UNIT, legal, 10), "Any number of eligible Heavy Intercessors may select Plasma Exterminators while one Intercessor takes a Plasma Pistol")
	for model_index in range(10):
		var equipment: Dictionary = legal[model_index]
		var expected := P.talonstrike_kill_team_model_loadout(model_index, str(equipment.get(MELEE, "chainsword")), str(equipment.get(RANGED, "heavy-bolt-pistol")), bool(equipment.get(INTERCESSOR_PLASMA, false)), bool(equipment.get(HEAVY_PLASMA, false)))
		var prepared: Dictionary = {}
		E.prepare(prepared, UNIT, equipment, 10, model_index)
		check(not expected.is_empty() and prepared.get("ranged_weapons", []) == expected.ranged and prepared.get("melee_weapons", []) == expected.melee, "Model %d resolves saved choices through the current Talonstrike factory" % (model_index + 1))
		check(prepared.get("saved_model_equipment", {}) == equipment and bool(prepared.get("talonstrike_saved_equipment_locked", false)), "Model %d retains its exact record and match lock" % (model_index + 1))
	var wrong_role := defaults.duplicate(true)
	wrong_role[1][INTERCESSOR_PLASMA] = true
	var too_many_pistols := defaults.duplicate(true)
	too_many_pistols[5][INTERCESSOR_PLASMA] = true
	too_many_pistols[9][INTERCESSOR_PLASMA] = true
	too_many_pistols[7][INTERCESSOR_PLASMA] = true
	var invalid_melee := defaults.duplicate(true)
	invalid_melee[0][MELEE] = "thunder-hammer"
	var two_pistols := defaults.duplicate(true)
	two_pistols[5][INTERCESSOR_PLASMA] = true
	two_pistols[9][INTERCESSOR_PLASMA] = true
	check(E.valid_saved_loadout(UNIT, two_pistols, 10), "A ten-model unit permits two Intercessor Plasma Pistols at one per five models")
	check(not E.valid_saved_loadout(UNIT, wrong_role, 10) and not E.valid_saved_loadout(UNIT, too_many_pistols, 10) and not E.valid_saved_loadout(UNIT, invalid_melee, 10), "Wrong-role choices, a third Plasma Pistol and an unlisted melee weapon are rejected")
	check(not E.valid_for_model(UNIT, 0, {MELEE: "chainsword"}, 10) and not E.valid_for_model(UNIT, 5, {HEAVY_PLASMA: true}, 10) and not E.valid_for_model(UNIT, 10, {}, 10), "Incomplete records, wrong-role fields and invalid indexes are rejected")
	check(not E.valid_saved_loadout(UNIT, defaults.slice(0, 9), 10), "Incomplete ten-model equipment records are rejected")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Talonstrike list passes whole-roster validation")
	check(R.summary(army).points == 860, "Three ten-model copies retain the 280/280/300 source prices with no equipment surcharge")
	var item: Dictionary = army.entries[0]
	var first := R.model_equipment_loadouts(item, 0)
	var second := R.model_equipment_loadouts(item, 1)
	var third := R.model_equipment_loadouts(item, 2)
	check(first[0][MELEE] == "power-fist" and first[0][RANGED] == "plasma-pistol" and first.slice(1, 5).all(func(equipment: Dictionary) -> bool: return bool(equipment[HEAVY_PLASMA])) and first[5][INTERCESSOR_PLASMA] and first[6][INTERCESSOR_PLASMA], "First copy reopens its full Heavy Intercessor mix and both per-five Plasma Pistols")
	check(second[0][MELEE] == "power-weapon" and second[0][RANGED] == "hand-flamer" and second[4][HEAVY_PLASMA] and second[9][INTERCESSOR_PLASMA], "Second copy retains independent equipment choices")
	check(E.valid_saved_loadout(UNIT, first, 10) and E.valid_saved_loadout(UNIT, second, 10) and E.valid_saved_loadout(UNIT, third, 10) and third == records(), "Every copy reopens as valid and untouched defaults remain intact")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Configured Talonstrike copies enter the consolidated local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"core_stratagems": true, "combat_doctrines": true, "unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize saved Talonstrike equipment: " + str(state.get("error", "")))
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
					var expected := P.talonstrike_kill_team_model_loadout(model_index, str(equipment.get(MELEE, "chainsword")), str(equipment.get(RANGED, "heavy-bolt-pistol")), bool(equipment.get(INTERCESSOR_PLASMA, false)), bool(equipment.get(HEAVY_PLASMA, false)))
					check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and int(unit.talonstrike_kill_team_model) == model_index, "Player %d copy %d model %d materializes its exact saved weapons" % [owner, squad_offset + 1, model_index + 1])
					check(unit.get("saved_model_equipment", {}) == equipment and bool(unit.get("talonstrike_saved_equipment_locked", false)), "Player %d copy %d model %d retains its independent record and match lock" % [owner, squad_offset + 1, model_index + 1])
				squad_offset += 1
	var choices: Array = Actions.choices(state, 1)
	check(not choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")).begins_with("talonstrike-")), "Saved Talonstrike models remove duplicate Army Preparation equipment choices")
	var target_model := find_model_in_squad(state, 1, 1, 0)
	if target_model >= 0:
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": "talonstrike-sergeant-melee", "model": target_model, "target": 1, "value": "chainsword"}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "A forced match-time Talonstrike edit is rejected without mutation")
	var frozen_before_source_edit := state.duplicate(true)
	var source_item: Dictionary = army.entries[0]
	check(R.set_model_equipment(source_item, 0, 0, MELEE, "chainsword") and state == frozen_before_source_edit, "A later saved-army equipment edit cannot mutate the already-prepared Talonstrike match snapshot")

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
	panel.storage_path = ProjectSettings.globalize_path("user://talonstrike-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Talonstrike Workshop control review"
	army.entries = [entry(catalog)]
	panel.draft = army
	panel._render_draft()
	panel._select_entry(0)
	var cards: Control = panel.per_model_equipment_controls
	check(cards.get_child_count() == 10, "Workshop renders ten independent Talonstrike model cards")
	var sergeant := find_pickers(cards.get_child(0))
	var heavy := find_pickers(cards.get_child(1))
	var intercessor := find_pickers(cards.get_child(5))
	check((cards.get_child(0).get_child(0) as Label).text == "Talonstrike Sergeant" and sergeant.size() == 2 and picker_index(sergeant[0], "power-fist") >= 0 and picker_index(sergeant[1], "plasma-pistol") >= 0, "Sergeant card exposes its independent melee and ranged choices")
	check((cards.get_child(1).get_child(0) as Label).text == "Heavy Intercessor 1" and heavy.size() == 1 and picker_index(heavy[0], true) >= 0, "Each Heavy Intercessor card exposes its Assault Bolters replacement")
	check((cards.get_child(5).get_child(0) as Label).text == "Intercessor 1" and intercessor.size() == 1 and picker_index(intercessor[0], true) >= 0, "Each Intercessor card exposes the per-five-model Plasma Pistol choice")
	if not heavy.is_empty():
		var selected := picker_index(heavy[0], true)
		heavy[0].select(selected)
		heavy[0].item_selected.emit(selected)
		check(selected >= 0 and panel.dirty and bool(R.model_equipment(panel.draft.entries[0], 0, 1)[HEAVY_PLASMA]), "Workshop equipment control saves to the selected stable model record")
	panel.free()
	var path := ProjectSettings.globalize_path("user://talonstrike-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate Godot process reopens the configured Talonstrike army")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog opens without network access")
	var source: Dictionary = catalog.lookup(UNIT)
	check(not source.is_empty(), "The local catalog admits the source-priced Talonstrike profile")
	if source.is_empty():
		catalog.free()
		quit(1)
		return
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 860, "Three independently configured copies pass roster validation at unchanged copy prices")
	var item: Dictionary = army.entries[0]
	var before_invalid := item.duplicate(true)
	check(not R.set_model_equipment(item, 0, 1, INTERCESSOR_PLASMA, true) and item == before_invalid, "Plasma Pistol on a Heavy Intercessor is rejected atomically")
	check(not R.set_model_equipment(item, 0, 7, INTERCESSOR_PLASMA, true) and item == before_invalid, "A third Intercessor Plasma Pistol over the source limit is rejected atomically")
	var saved_path := ProjectSettings.globalize_path("user://talonstrike-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists Talonstrike choices by stable copy and model IDs")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_talonstrike_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate Godot process reopens all role-scoped records: " + str(child_output))
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
	print("Saved Talonstrike equipment: %d failures" % failures)
	quit(1 if failures else 0)
