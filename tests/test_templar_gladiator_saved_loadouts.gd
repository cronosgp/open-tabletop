extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const R = preload("res://scripts/army_roster.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const MULTI := {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func inspect(unit: Dictionary, definition: String, extra: bool) -> void:
	var source := P.profile(definition.get_slice(":", 3))
	var expected: Array = source.ranged.duplicate(true)
	if extra: expected.append({"id": "gladiator-additional-multi-melta", "profiles": {"standard": MULTI}})
	check(unit.ranged_weapons == expected and unit.melee_weapons == source.melee, "Exact default inventory remains and the additional weapon matches every source field")
	var multi := 0
	var ids: Array = []
	for weapon: Dictionary in unit.ranged_weapons:
		check(str(weapon.id) not in ids, "Each equipped weapon has a distinct stable attack-selection ID")
		ids.append(str(weapon.id))
		if weapon.profiles.get("standard", {}).get("name", "") == "Multi-melta": multi += 1
	check(multi == ((2 if definition.ends_with("-valiant") else 0) + (1 if extra else 0)), "Valiant retains both fixed weapons separately from the optional third weapon")
	check(unit.templar_gladiator_loadout_locked and bool(unit.gladiator_extra_multi_melta) == extra, "Saved equipment materializes with its frozen flag")

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	for definition: String in E.TEMPLAR_GLADIATORS:
		var item := R.entry(catalog.lookup(definition), 0, 3)
		for copy_index in [1, 2]: check(R.set_model_equipment(item, copy_index, 0, "gladiator_extra_multi_melta", true), "Each copy can choose an extra weapon independently")
		army.entries.append(item)
	return army

func check_bank(army: Dictionary) -> void:
	check(army.entries.size() == 3 and R.validate(army).is_empty(), "All three Gladiator identities and records reopen")
	var report := Training.admit_current_catalog(army)
	check(report.error.is_empty() and int(report.get("total", 0)) == 1605 and R.summary(army).points == 1605, "Source copy tiers and every equipped Multi-melta total exactly 1605 points")
	for item: Dictionary in army.entries:
		check(not R.model_equipment(item, 0, 0).gladiator_extra_multi_melta and R.model_equipment(item, 1, 0).gladiator_extra_multi_melta and R.model_equipment(item, 2, 0).gladiator_extra_multi_melta, "Configured and default copies survive disk reopen")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Another Godot process reopens the army bank")
		if store.error.is_empty() and store.active().lists.size() == 1: check_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	for definition: String in E.TEMPLAR_GLADIATORS:
		for extra: bool in [false, true]:
			var equipment := {"gladiator_extra_multi_melta": extra}
			check(E.valid(definition, equipment, 1), "Both source-listed packages validate")
			var unit := {}
			E.prepare(unit, definition, equipment)
			inspect(unit, definition, extra)
			check(E.points_for_loadout(definition, equipment, 1) == (20 if definition.ends_with("-valiant") else 0) + (10 if extra else 0), "The per-weapon price counts every fixed and additional Multi-melta")
		check(not E.valid(definition, {"gladiator_extra_multi_melta": "true"}, 1) and not E.valid(definition, {"gladiator_extra_multi_melta": 1}, 1) and not E.valid(definition, {"gladiator_extra_multi_melta": false, "extra": true}, 1), "Wrong types and unlisted equipment fail closed")
		check(not E.valid(definition, E.defaults(definition), 2), "The one-model source composition is mandatory")
	var budget := R.new_list("11e", "Space Marines", "custom", 330)
	budget.entries.append(R.entry(catalog.lookup(E.TEMPLAR_GLADIATORS[2]), 0, 2))
	check(R.summary(budget).points == 330 and Training.admit_current_catalog(budget).error.is_empty(), "Two default Valiants include both fixed weapons in the exact 330-point budget")
	check(R.set_model_equipment(budget.entries[0], 0, 0, "gladiator_extra_multi_melta", true) and R.summary(budget).points == 340 and not Training.admit_current_catalog(budget).error.is_empty(), "The extra weapon cannot bypass the army budget")
	var valiant: Dictionary = catalog.lookup(E.TEMPLAR_GLADIATORS[2])
	var empty := R.new_list("11e", "Space Marines", "strike_force", 2000)
	check(R.addition_cost(empty, str(valiant.id), valiant.options[0], 2) == 330, "Addition preview includes both fixed Multi-meltas per default Valiant")
	empty.entries.append(R.entry(valiant, 0, 1))
	check(R.addition_cost(empty, str(valiant.id), valiant.options[0], 2) == 350, "Addition preview preserves the third-copy tier and every default weapon cost")
	var executioner: Dictionary = catalog.lookup("40kdc:11e:adeptus-astartes:repulsor-executioner")
	check(R.addition_cost(empty, str(executioner.id), executioner.options[0], 1) == 270, "Shared addition preview also retains the existing default Laser surcharge")
	var army := make_army(catalog)
	check_bank(army)
	var path := ProjectSettings.globalize_path("user://templar-gladiators-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Saved Gladiators do not require optional visual assets")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_templar_gladiator_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Separate process validates the complete army bank: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both players materialize saved Gladiators: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable model IDs map to the frozen canonical army")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1605 and int(state.training_points[owner]) == 1605, "Materialized squad prices agree with source admission")
					for item: Dictionary in army.entries:
						for copy_index in range(3):
							var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, 0)]
							var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
							check(state.units[model].saved_model_equipment == R.model_equipment(item, copy_index, 0), "Frozen model keeps its own saved record")
							inspect(state.units[model], str(item.unit_id), copy_index > 0)
							if copy_index > 0:
								var selected := Equipment.select(state, model, false, "gladiator-additional-multi-melta", "standard")
								check(not selected.has("error") and selected.stats == MULTI, "The actual weapon selector resolves the independent additional weapon")
			for model: int in state.units:
				var before := state.duplicate(true)
				check(not Transport.configure_optional_transport_weapon(state, model, "multi-melta:on").is_empty() and state == before, "The generic transport setup endpoint cannot reconfigure non-transport Gladiators")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Gladiator match saves")
			check(R.set_model_equipment(saved.list.entries[0], 0, 0, "gladiator_extra_multi_melta", true) and store.save_list(saved.list).error.is_empty(), "The source army can change after the snapshot")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Later army edits cannot change saved weapons or points")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(3):
		panel._select_entry(index)
		check(panel.per_model_equipment_controls.get_child_count() == 2, "Workshop offers the source-listed additional weapon")
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		var before_points: int = R.summary(panel.draft).points
		picker.select(1)
		picker.item_selected.emit(1)
		check(panel.dirty and R.model_equipment(panel.draft.entries[index], 0, 0).gladiator_extra_multi_melta and R.summary(panel.draft).points == before_points + 10, "Real Workshop signal adds ten points on the selected copy")
		check(Training.admit_current_catalog(panel.draft).total == R.summary(panel.draft).points, "Workshop and canonical source prices remain equal")
	panel.draft = empty.duplicate(true)
	panel._render_draft()
	var found := false
	for index in range(panel.unit_picker.item_count):
		var data: Dictionary = panel.unit_picker.get_item_metadata(index)
		if str(data.get("id", "")) != E.TEMPLAR_GLADIATORS[2]: continue
		panel._select_unit(index)
		panel.copies.value = 2
		panel._refresh_addition_summary()
		check(panel.choice_picker.get_item_text(0).contains("165 pts") and panel.choice_picker.get_item_text(0).contains("3rd+ 185 pts"), "Workshop model-size label includes default equipment on every copy tier")
		# One Valiant is present; the next two additions span the source second/third tiers.
		check(panel.addition_summary.text.contains("350 pts added"), "Actual addition summary includes default equipment after the existing copies")
		found = true
		break
	check(found, "Actual Workshop catalog exposes the selected Chapter Valiant")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Saved Templar Gladiator equipment: %d failures" % failures)
	quit(1 if failures else 0)
