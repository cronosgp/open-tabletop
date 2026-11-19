extends SceneTree

const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Fortis = preload("res://scripts/edition_11/fortis_saved_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const UNIT := "40kdc:11e:adeptus-astartes:fortis-kill-team"
const ROCKET := "fortis_kill_team_rocket_launcher"
const SERGEANT_MELEE := "fortis_kill_team_sergeant_melee"
const SERGEANT_RANGED := "fortis_kill_team_sergeant_ranged"
const GRENADE := "fortis_kill_team_grenade_launcher"
const PLASMA_PISTOL := "fortis_kill_team_plasma_pistol"
const ROLES := ["castellan-launcher-intercessor", "sergeant", "plasma-incinerator-intercessor", "plasma-incinerator-intercessor", "deathwatch-bolt-rifle-intercessor", "deathwatch-bolt-rifle-intercessor", "heavy-bolt-pistol-intercessor", "heavy-bolt-pistol-intercessor", "pyreblaster-intercessor", "pyreblaster-intercessor"]

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
	check(false, "The source-bounded ten-model Fortis option exists in the consolidated catalog")
	return {}

func set_equipment(item: Dictionary, copy_index: int, model_index: int, field: String, value: Variant, message: String) -> void:
	check(R.set_model_equipment(item, copy_index, model_index, field, value), message)

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Fortis saved equipment review"
	var item := entry(catalog, 3)
	army.entries = [item]
	set_equipment(item, 0, 0, ROCKET, "vengor", "First copy saves the Castellan Vengor replacement")
	set_equipment(item, 0, 1, SERGEANT_MELEE, "thunder-hammer", "First copy saves the Sergeant Thunder Hammer")
	set_equipment(item, 0, 1, GRENADE, true, "Eligible Sergeant keeps its Deathwatch Bolt Rifle and adds a Grenade Launcher")
	set_equipment(item, 0, 4, GRENADE, true, "First copy saves its second per-five Grenade Launcher")
	set_equipment(item, 0, 2, PLASMA_PISTOL, true, "First copy saves one Plasma Pistol replacement")
	set_equipment(item, 1, 0, ROCKET, "superkrak", "Second copy saves an independent Castellan rocket")
	set_equipment(item, 1, 1, SERGEANT_MELEE, "power-weapon", "Second copy saves an independent Sergeant melee option")
	set_equipment(item, 1, 1, SERGEANT_RANGED, "hand-flamer", "Second copy saves an independent Sergeant ranged replacement")
	set_equipment(item, 1, 3, PLASMA_PISTOL, true, "Second copy independently assigns its one Plasma Pistol")
	set_equipment(item, 1, 4, GRENADE, true, "Second copy saves the first Grenade Launcher")
	set_equipment(item, 1, 5, GRENADE, true, "Second copy saves the second Grenade Launcher")
	return army

func check_source_options() -> void:
	check(Fortis.supports(UNIT) and E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Fortis uses stacked per-model saved-equipment cards")
	check(Fortis.valid_size(10) and not Fortis.valid_size(5), "Only the source-listed ten-model Fortis size is selectable")
	var profile := P.profile("fortis-kill-team")
	check(profile.get("source_book_id") == "000000035" and profile.get("source_datasheet_id") == "000002780", "The Fortis equipment factory remains bound to the Deathwatch App datasheet")
	check(profile.options.get("sergeant_melee_replacements", []) == ["chainsword", "power-fist", "power-weapon", "thunder-hammer"] and profile.options.get("sergeant_ranged_replacements", []) == ["chainsword", "hand-flamer", "plasma-pistol", "power-weapon"], "The local factory exposes the exact four Sergeant replacement options in both slots")
	check(profile.options.get("grenade_launchers_per_five_models", 0) == 1 and profile.options.get("plasma_pistol_limit", 0) == 1 and profile.options.get("rocket_launcher_replacements", []) == ["superkrak", "vengor"], "Grenade, Plasma Pistol and Castellan rocket limits/options match the reviewed export")
	var loadouts: Array = profile.get("model_loadouts", [])
	check(loadouts.size() == 10 and loadouts.map(func(row: Dictionary) -> String: return str(row.get("role", ""))) == ROLES, "Saved model order follows the exact ten-role Fortis source composition")
	var defaults := records()
	check(E.valid_saved_loadout(UNIT, defaults, 10) and E.points_for_loadout(UNIT, defaults, 10) == 0, "Fortis role defaults pass whole-unit validation and add no points")
	check(E.model_label(UNIT, 10, 0) == "Castellan Launcher Intercessor" and E.model_label(UNIT, 10, 1) == "Sergeant" and E.model_label(UNIT, 10, 3) == "Plasma Incinerator Intercessor 2" and E.model_label(UNIT, 10, 9) == "Pyreblaster Intercessor 2", "Workshop labels identify fixed Fortis roles and repeated model ordinals")
	check(E.controls_for_model(UNIT, 0, 10)[0].field == ROCKET and E.controls_for_model(UNIT, 0, 10)[0].choices.size() == 3, "Castellan model exposes Superfrag, Superkrak and Vengor choices")
	check(E.controls_for_model(UNIT, 1, 10).size() == 3 and E.controls_for_model(UNIT, 1, 10)[2].field == GRENADE, "Sergeant controls retain its separate melee, ranged and eligible grenade choices")
	check(E.controls_for_model(UNIT, 2, 10)[0].field == PLASMA_PISTOL and E.controls_for_model(UNIT, 4, 10)[0].field == GRENADE, "Plasma Incinerator and Bolt Rifle models expose only their listed replacements")
	check(E.controls_for_model(UNIT, 6, 10).is_empty() and E.controls_for_model(UNIT, 8, 10).is_empty(), "Fixed Heavy Bolt Pistol and Pyreblaster models do not show invented selectors")
	var allowed := defaults.duplicate(true)
	allowed[0][ROCKET] = "vengor"
	allowed[1][SERGEANT_MELEE] = "thunder-hammer"
	allowed[1][GRENADE] = true
	allowed[2][PLASMA_PISTOL] = true
	allowed[4][GRENADE] = true
	check(E.valid_saved_loadout(UNIT, allowed, 10), "A source-legal mixed Fortis loadout accepts two Grenade Launchers and one Plasma Pistol")
	for model_index in range(10):
		var equipment: Dictionary = allowed[model_index]
		var expected := P.fortis_kill_team_model_loadout(model_index, str(equipment.get(SERGEANT_MELEE, "knives-and-fists")), str(equipment.get(SERGEANT_RANGED, "deathwatch-bolt-rifle")), bool(equipment.get(GRENADE, false)), bool(equipment.get(PLASMA_PISTOL, false)), str(equipment.get(ROCKET, "superfrag")))
		var prepared: Dictionary = {}
		E.prepare(prepared, UNIT, equipment, 10, model_index)
		check(not expected.is_empty() and prepared.get("ranged_weapons", []) == expected.ranged and prepared.get("melee_weapons", []) == expected.melee, "Model %d resolves its saved selections through the existing Fortis factory" % (model_index + 1))
		check(prepared.get("saved_model_equipment", {}) == equipment and bool(prepared.get("fortis_saved_equipment_locked", false)), "Model %d retains the saved record and match lock" % (model_index + 1))
	var wrong_role := defaults.duplicate(true)
	wrong_role[6][PLASMA_PISTOL] = true
	var too_many_grenades := defaults.duplicate(true)
	too_many_grenades[1][GRENADE] = true
	too_many_grenades[4][GRENADE] = true
	too_many_grenades[5][GRENADE] = true
	var too_many_pistols := defaults.duplicate(true)
	too_many_pistols[2][PLASMA_PISTOL] = true
	too_many_pistols[3][PLASMA_PISTOL] = true
	var launcher_without_rifle := defaults[1].duplicate(true)
	launcher_without_rifle[SERGEANT_RANGED] = "hand-flamer"
	launcher_without_rifle[GRENADE] = true
	check(not E.valid_saved_loadout(UNIT, wrong_role, 10) and not E.valid_saved_loadout(UNIT, too_many_grenades, 10) and not E.valid_saved_loadout(UNIT, too_many_pistols, 10), "Out-of-role equipment and whole-unit replacement limits are rejected")
	check(not E.valid_for_model(UNIT, 1, launcher_without_rifle, 10) and not E.valid_for_model(UNIT, 0, {ROCKET: true}, 10) and not E.valid_for_model(UNIT, 8, {GRENADE: "on"}, 10), "Incompatible Sergeant combinations and malformed field types are rejected")
	check(not E.valid_for_model(UNIT, 10, {}, 10) and not E.valid_saved_loadout(UNIT, defaults.slice(0, 9), 10), "Out-of-range model indexes and incomplete squad records are rejected")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Fortis list passes whole-roster validation")
	check(R.summary(army).points == 645, "Three ten-model copies retain 210/210/225 points with no equipment surcharge")
	var item: Dictionary = army.entries[0]
	var first := R.model_equipment_loadouts(item, 0)
	var second := R.model_equipment_loadouts(item, 1)
	var third := R.model_equipment_loadouts(item, 2)
	check(first[0][ROCKET] == "vengor" and first[1][SERGEANT_MELEE] == "thunder-hammer" and first[1][GRENADE] and first[2][PLASMA_PISTOL] and first[4][GRENADE], "First copy reopens its model-specific rocket, Sergeant, grenade and pistol choices")
	check(second[0][ROCKET] == "superkrak" and second[1][SERGEANT_RANGED] == "hand-flamer" and second[3][PLASMA_PISTOL] and second[4][GRENADE] and second[5][GRENADE], "Second copy retains independent model equipment and per-unit caps")
	check(E.valid_saved_loadout(UNIT, first, 10) and E.valid_saved_loadout(UNIT, second, 10) and E.valid_saved_loadout(UNIT, third, 10) and third == records(), "All copies reopen as valid, with untouched defaults preserved")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Configured Fortis copies enter the consolidated local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"core_stratagems": true, "combat_doctrines": true, "unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize their saved Fortis copies: " + str(state.get("error", "")))
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
					var expected := P.fortis_kill_team_model_loadout(model_index, str(equipment.get(SERGEANT_MELEE, "knives-and-fists")), str(equipment.get(SERGEANT_RANGED, "deathwatch-bolt-rifle")), bool(equipment.get(GRENADE, false)), bool(equipment.get(PLASMA_PISTOL, false)), str(equipment.get(ROCKET, "superfrag")))
					check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and int(unit.fortis_kill_team_model) == model_index, "Player %d copy %d model %d materializes its exact saved weapons" % [owner, squad_offset + 1, model_index + 1])
					check(unit.get("saved_model_equipment", {}) == equipment and bool(unit.get("fortis_saved_equipment_locked", false)), "Player %d copy %d model %d retains its saved record and lock" % [owner, squad_offset + 1, model_index + 1])
				squad_offset += 1
	var choices: Array = Actions.choices(state, 1)
	check(not choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")).begins_with("fortis-")), "Saved Fortis models remove duplicate Army Preparation equipment choices")
	var target_model := find_model_in_squad(state, 1, 1, 1)
	if target_model >= 0:
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": "fortis-sergeant-melee", "model": target_model, "target": 1, "value": "knives-and-fists"}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Forced match-time Fortis equipment edit is rejected without mutation")

func find_pickers(node: Node) -> Array[OptionButton]:
	var result: Array[OptionButton] = []
	if node is OptionButton: result.append(node as OptionButton)
	for child: Node in node.get_children(): result.append_array(find_pickers(child))
	return result

func picker_index(picker: OptionButton, wanted: String) -> int:
	for index in range(picker.item_count):
		if str(picker.get_item_metadata(index)) == wanted: return index
	return -1

func verify_builder(catalog: Node) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://fortis-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Fortis Workshop control review"
	army.entries = [entry(catalog)]
	panel.draft = army
	panel._render_draft()
	panel._select_entry(0)
	var cards: Control = panel.per_model_equipment_controls
	check(cards.get_child_count() == 10, "Workshop renders all ten Fortis role cards")
	var castellan := cards.get_child(0)
	var sergeant := cards.get_child(1)
	var plasma := cards.get_child(2)
	var bolt_rifle := cards.get_child(4)
	var fixed := cards.get_child(6)
	var castellan_pickers := find_pickers(castellan)
	var sergeant_pickers := find_pickers(sergeant)
	check((castellan.get_child(0) as Label).text == "Castellan Launcher Intercessor" and castellan_pickers.size() == 1 and castellan_pickers[0].item_count == 3, "Castellan role card clearly distinguishes all three launcher choices")
	check((sergeant.get_child(0) as Label).text == "Sergeant" and sergeant_pickers.size() == 3 and sergeant_pickers[0].item_count == 5 and sergeant_pickers[1].item_count == 5, "Sergeant role card exposes both replacements and its conditional launcher control")
	check((plasma.get_child(0) as Label).text == "Plasma Incinerator Intercessor 1" and find_pickers(plasma).size() == 1 and find_pickers(plasma)[0].item_count == 2, "Plasma Incinerator role card exposes its Bolt Pistol replacement")
	check((bolt_rifle.get_child(0) as Label).text == "Deathwatch Bolt Rifle Intercessor 1" and find_pickers(bolt_rifle).size() == 1 and find_pickers(bolt_rifle)[0].item_count == 2, "Bolt Rifle role card exposes the per-five Grenade Launcher")
	check((fixed.get_child(0) as Label).text == "Heavy Bolt Pistol Intercessor 1" and find_pickers(fixed).is_empty(), "Fixed role card stays legible without an irrelevant selector")
	if not castellan_pickers.is_empty():
		var selected := picker_index(castellan_pickers[0], "vengor")
		castellan_pickers[0].select(selected)
		castellan_pickers[0].item_selected.emit(selected)
		check(selected >= 0 and panel.dirty and str(R.model_equipment(panel.draft.entries[0], 0, 0)[ROCKET]) == "vengor", "Workshop control saves the selection to the stable model record")
	panel.free()
	var path := ProjectSettings.globalize_path("user://fortis-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate Godot process reopens the configured Fortis list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog opens without network access")
	var source: Dictionary = catalog.lookup(UNIT)
	check(not source.is_empty(), "The current catalog admits the source-priced Fortis profile")
	if source.is_empty():
		catalog.free()
		quit(1)
		return
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 645, "Three saved copies pass whole-roster validation with unchanged local prices")
	var item: Dictionary = army.entries[0]
	var before_invalid := item.duplicate(true)
	check(not R.set_model_equipment(item, 0, 6, PLASMA_PISTOL, true) and item == before_invalid, "A Plasma Pistol replacement on a fixed Heavy Bolt Pistol model is rejected atomically")
	check(not R.set_model_equipment(item, 0, 5, GRENADE, true) and item == before_invalid, "A third per-unit Grenade Launcher is rejected atomically")
	check(not R.set_model_equipment(item, 0, 3, PLASMA_PISTOL, true) and item == before_invalid, "A second per-unit Plasma Pistol is rejected atomically")
	check(not R.set_model_equipment(item, 0, 1, SERGEANT_RANGED, "hand-flamer") and item == before_invalid, "Sergeant cannot retain a Grenade Launcher after replacing its Deathwatch Bolt Rifle")
	var saved_path := ProjectSettings.globalize_path("user://fortis-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists Fortis choices by stable copy and model IDs")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_fortis_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
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
	print("Saved Fortis equipment: %d failures" % failures)
	quit(1 if failures else 0)
