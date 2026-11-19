extends SceneTree

const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Decimus = preload("res://scripts/edition_11/decimus_saved_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const UNIT := "40kdc:11e:adeptus-astartes:decimus-kill-team"
const GRAVIS := "decimus_gravis_weapon"
const SHIELD := "decimus_storm_shield"
const PLASMA := "decimus_plasma_incinerator"
const ROLE_IDS := ["xenophase-veteran", "sergeant", "marksman-veteran", "marksman-veteran", "heavy-veteran", "heavy-veteran", "stalker-veteran", "stalker-veteran", "gravis-veteran", "gravis-veteran"]

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
	check(false, "The reconciled ten-model Decimus option exists in the consolidated catalog")
	return {}

func set_equipment(item: Dictionary, copy_index: int, model_index: int, field: String, value: Variant, message: String) -> void:
	check(R.set_model_equipment(item, copy_index, model_index, field, value), message)

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Decimus saved equipment review"
	var item := entry(catalog, 3)
	army.entries = [item]
	set_equipment(item, 0, 8, GRAVIS, "frag-cannon", "First copy saves the first Gravis replacement")
	set_equipment(item, 0, 9, GRAVIS, "hellstorm-bolt-rifle", "First copy saves the second Gravis replacement")
	set_equipment(item, 0, 4, SHIELD, true, "First copy saves one Heavy Veteran Storm Shield")
	set_equipment(item, 0, 5, SHIELD, true, "First copy saves the second Storm Shield")
	set_equipment(item, 0, 6, PLASMA, true, "First copy saves one Stalker Veteran Plasma Incinerator")
	set_equipment(item, 0, 7, PLASMA, true, "First copy saves the second Plasma Incinerator")
	set_equipment(item, 1, 8, GRAVIS, "hellstorm-bolt-rifle", "Second copy saves an independent Gravis choice")
	set_equipment(item, 1, 4, SHIELD, true, "Second copy saves an independent Storm Shield")
	set_equipment(item, 1, 6, PLASMA, true, "Second copy saves an independent Plasma Incinerator")
	return army

func check_source_options() -> void:
	check(Decimus.supports(UNIT) and E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Decimus uses stacked per-model saved equipment cards")
	check(Decimus.valid_size(10) and not Decimus.valid_size(5) and str(P.profile("decimus-kill-team").get("source_book_id", "")) == "000000035" and str(P.profile("decimus-kill-team").get("source_datasheet_id", "")) == "000004175", "Only the source-compatible ten-model Deathwatch App profile is admitted")
	var source_roles: Array = P.decimus_kill_team_composition_options()[0].roles
	check(source_roles == ROLE_IDS, "Saved model order follows the exact source-defined Decimus composition")
	var defaults := records()
	check(E.valid_saved_loadout(UNIT, defaults, 10) and E.points_for_loadout(UNIT, defaults, 10) == 0, "The ten-model role defaults pass validation and equipment adds no points")
	check(not E.valid_saved_loadout(UNIT, defaults.slice(0, 5), 5) and not E.valid_saved_loadout(UNIT, defaults, 5), "The source-conflicted five-model row remains blocked")
	check(E.defaults_for_model(UNIT, 10, 0).is_empty() and E.defaults_for_model(UNIT, 10, 1).is_empty() and E.defaults_for_model(UNIT, 10, 2).is_empty(), "Fixed Xenophase, Sergeant and Marksman models have no invented choices")
	check(E.model_label(UNIT, 10, 0) == "Xenophase Veteran" and E.model_label(UNIT, 10, 1) == "Sergeant" and E.model_label(UNIT, 10, 2) == "Marksman Veteran 1" and E.model_label(UNIT, 10, 9) == "Gravis Veteran 2", "Workshop labels each role with stable readable ordinals")
	check(E.controls_for_model(UNIT, 0, 10).is_empty() and E.controls_for_model(UNIT, 2, 10).is_empty(), "Fixed-role cards do not expose equipment selectors")
	check(E.controls_for_model(UNIT, 8, 10)[0].field == GRAVIS and E.controls_for_model(UNIT, 8, 10)[0].choices.size() == 3, "Gravis cards expose only the three source-listed weapon choices")
	check(E.controls_for_model(UNIT, 4, 10)[0].field == SHIELD and E.controls_for_model(UNIT, 4, 10)[0].choices.size() == 2 and E.controls_for_model(UNIT, 6, 10)[0].field == PLASMA and E.controls_for_model(UNIT, 6, 10)[0].choices.size() == 2, "Heavy and Stalker cards expose only their respective replacements")
	var all_allowed := defaults.duplicate(true)
	all_allowed[8][GRAVIS] = "frag-cannon"
	all_allowed[9][GRAVIS] = "hellstorm-bolt-rifle"
	all_allowed[4][SHIELD] = true
	all_allowed[5][SHIELD] = true
	all_allowed[6][PLASMA] = true
	all_allowed[7][PLASMA] = true
	check(E.valid_saved_loadout(UNIT, all_allowed, 10), "The 10-model configuration accepts both of each per-five replacement")
	for model_index in range(10):
		var equipment: Dictionary = all_allowed[model_index]
		var role_id := str(ROLE_IDS[model_index])
		var expected := P.decimus_kill_team_model_loadout(role_id, str(equipment.get(GRAVIS, "infernus-heavy-bolter")), bool(equipment.get(SHIELD, false)), bool(equipment.get(PLASMA, false)))
		var prepared: Dictionary = {}
		E.prepare(prepared, UNIT, equipment, 10, model_index)
		check(not expected.is_empty() and prepared.ranged_weapons == expected.ranged and prepared.melee_weapons == expected.melee, "Model %d resolves its exact selected package through the local factory" % (model_index + 1))
		check(prepared.get("saved_model_equipment", {}) == equipment and bool(prepared.get("decimus_saved_equipment_locked", false)), "Model %d retains its saved record and match lock" % (model_index + 1))
		if role_id == "heavy-veteran" and bool(equipment.get(SHIELD, false)):
			check(int(prepared.defense.invulnerable_target) == 4 and prepared.melee_weapons[0].id == "power-weapon", "Storm Shield saves its Power Weapon replacement and bearer-only 4+ invulnerable save")
	check(not E.valid_for_model(UNIT, 2, {GRAVIS: "frag-cannon"}, 10) and not E.valid_for_model(UNIT, 8, {SHIELD: true}, 10) and not E.valid_for_model(UNIT, 4, {PLASMA: true}, 10), "Every replacement is rejected on a model outside its source role")
	check(not E.valid_for_model(UNIT, 8, {GRAVIS: true}, 10) and not E.valid_for_model(UNIT, 4, {SHIELD: "true"}, 10) and not E.valid_for_model(UNIT, 6, {PLASMA: false, SHIELD: false}, 10), "Wrong types, extra fields and malformed per-model records are rejected")
	check(not E.valid_for_model(UNIT, 10, {}, 10) and not E.valid_saved_loadout(UNIT, defaults.slice(0, 9), 10), "Out-of-range model IDs and incomplete records are rejected")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Decimus list passes whole-roster validation")
	check(R.summary(army).points == 630, "Three ten-model copies retain their local Wahapedia 210-point cost")
	var item: Dictionary = army.entries[0]
	var first := R.model_equipment_loadouts(item, 0)
	var second := R.model_equipment_loadouts(item, 1)
	var third := R.model_equipment_loadouts(item, 2)
	check(first[8][GRAVIS] == "frag-cannon" and first[9][GRAVIS] == "hellstorm-bolt-rifle" and first[4][SHIELD] and first[5][SHIELD] and first[6][PLASMA] and first[7][PLASMA], "First copy reopens every role-specific selection")
	check(second[8][GRAVIS] == "hellstorm-bolt-rifle" and second[4][SHIELD] and second[6][PLASMA], "Second copy retains equipment independently")
	check(E.valid_saved_loadout(UNIT, first, 10) and E.valid_saved_loadout(UNIT, second, 10) and E.valid_saved_loadout(UNIT, third, 10), "Each reopened unit copy passes the whole-composition validator")
	check(third == records(), "Untouched third copy retains the source defaults")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Configured Decimus copies enter the consolidated local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"core_stratagems": true, "combat_doctrines": true, "unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize their saved Decimus copies: " + str(state.get("error", "")))
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
					var expected := P.decimus_kill_team_model_loadout(str(ROLE_IDS[model_index]), str(equipment.get(GRAVIS, "infernus-heavy-bolter")), bool(equipment.get(SHIELD, false)), bool(equipment.get(PLASMA, false)))
					check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and unit.decimus_kill_team_role == ROLE_IDS[model_index], "Player %d copy %d model %d materializes its saved role weapons" % [owner, squad_offset + 1, model_index + 1])
					check(unit.get("saved_model_equipment", {}) == equipment and bool(unit.get("decimus_saved_equipment_locked", false)), "Player %d copy %d model %d retains its saved record and lock" % [owner, squad_offset + 1, model_index + 1])
					check(int(unit.defense.invulnerable_target) == (4 if bool(equipment.get(SHIELD, false)) else 0), "Storm Shield benefit applies only to the selected bearer")
				squad_offset += 1
	var choices: Array = Actions.choices(state, 1)
	check(not choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) in ["decimus-gravis-weapon", "decimus-storm-shield", "decimus-plasma-incinerator"]), "Saved Decimus removes duplicate Army Preparation equipment choices")
	var target_model := find_model_in_squad(state, 1, 1, 8)
	if target_model >= 0:
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": "decimus-gravis-weapon", "model": target_model, "target": 1, "value": "infernus-heavy-bolter"}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Forced match-time equipment edit is rejected without mutation")

func find_picker(node: Node) -> OptionButton:
	if node is OptionButton: return node as OptionButton
	for child: Node in node.get_children():
		var found := find_picker(child)
		if found != null: return found
	return null

func picker_index(picker: OptionButton, wanted: String) -> int:
	for index in range(picker.item_count):
		if str(picker.get_item_metadata(index)) == wanted: return index
	return -1

func verify_builder(catalog: Node) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://decimus-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Decimus Workshop control review"
	army.entries = [entry(catalog)]
	panel.draft = army
	panel._render_draft()
	panel._select_entry(0)
	var cards: Control = panel.per_model_equipment_controls
	check(cards.get_child_count() == 10, "Workshop renders all ten source-role model cards")
	var fixed_card: Control = cards.get_child(0)
	var marksman_card: Control = cards.get_child(2)
	var heavy_card: Control = cards.get_child(4)
	var stalker_card: Control = cards.get_child(6)
	var gravis_card: Control = cards.get_child(8)
	check((fixed_card.get_child(0) as Label).text == "Xenophase Veteran" and find_picker(fixed_card) == null, "Fixed Xenophase card stays readable without an irrelevant selector")
	var marksman_picker := find_picker(marksman_card)
	var heavy_picker := find_picker(heavy_card)
	var stalker_picker := find_picker(stalker_card)
	var gravis_picker := find_picker(gravis_card)
	check((marksman_card.get_child(0) as Label).text == "Marksman Veteran 1" and marksman_picker == null, "Fixed Marksman card has its source role and no selector")
	check((heavy_card.get_child(0) as Label).text == "Heavy Veteran 1" and heavy_picker != null and heavy_picker.item_count == 2, "Heavy Veteran card exposes the Storm Shield replacement")
	check((stalker_card.get_child(0) as Label).text == "Stalker Veteran 1" and stalker_picker != null and stalker_picker.item_count == 2, "Stalker card exposes the Plasma Incinerator replacement")
	check((gravis_card.get_child(0) as Label).text == "Gravis Veteran 1" and gravis_picker != null and gravis_picker.item_count == 3 and gravis_picker.get_item_text(2) == "Hellstorm Bolt Rifle + Grenade Launcher", "Gravis card lists the complete Hellstorm replacement package")
	if gravis_picker != null:
		var selected := picker_index(gravis_picker, "hellstorm-bolt-rifle")
		gravis_picker.select(selected)
		gravis_picker.item_selected.emit(selected)
		check(selected >= 0 and panel.dirty and str(R.model_equipment(panel.draft.entries[0], 0, 8)[GRAVIS]) == "hellstorm-bolt-rifle", "Workshop selection persists to the stable Gravis model record")
	panel.free()
	var path := ProjectSettings.globalize_path("user://decimus-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate Godot process reopens the configured Decimus list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog opens without network access")
	var source: Dictionary = catalog.lookup(UNIT)
	check(not source.is_empty(), "The current catalog admits the source-priced Decimus profile")
	if source.is_empty():
		catalog.free()
		quit(1)
		return
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 630, "Three saved copies pass roster validation with unchanged local prices")
	var item: Dictionary = army.entries[0]
	var before_invalid := item.duplicate(true)
	check(not R.set_model_equipment(item, 0, 2, GRAVIS, "frag-cannon") and item == before_invalid, "A Gravis replacement on a Marksman is rejected atomically")
	check(not R.set_model_equipment(item, 0, 4, PLASMA, true) and item == before_invalid, "A Stalker replacement on a Heavy Veteran is rejected atomically")
	var saved_path := ProjectSettings.globalize_path("user://decimus-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists model options by stable copy and model IDs")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_decimus_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
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
	print("Saved Decimus equipment: %d failures" % failures)
	quit(1 if failures else 0)
