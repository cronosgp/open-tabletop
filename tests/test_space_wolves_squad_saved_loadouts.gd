extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const R = preload("res://scripts/army_roster.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Defense = preload("res://scripts/edition_11/defender_groups.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const IDS := [E.THUNDERWOLF, E.WULFEN, E.WULFEN_SHIELDS]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func entry(catalog: Node, definition: String, models: int, copies: int) -> Dictionary:
	var source: Dictionary = catalog.lookup(definition)
	for index in range(source.options.size()):
		if int(source.options[index].models) == models: return R.entry(source, index, copies)
	check(false, "Source-priced model count exists")
	return {}

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	for definition: String in IDS:
		var item := entry(catalog, definition, 6 if definition == E.THUNDERWOLF else 5, 3 if definition == E.THUNDERWOLF else 2)
		for copy_index in range(int(item.copies)):
			for model_index in range(int(item.models)):
				if definition == E.THUNDERWOLF:
					var value := "plasma-pistol" if model_index in [copy_index, copy_index + 1] else "boltgun-storm-shield" if model_index == copy_index + 2 else "default"
					check(R.set_model_equipment(item, copy_index, model_index, "thunderwolf_cavalry_loadout", value), "Independent cavalry choices respect the source plasma cap")
				else:
					check(R.set_model_equipment(item, copy_index, model_index, "wulfen_loadout", "death-totem" if (model_index + copy_index) % 2 == 0 else "stormfrag-auto-launcher"), "Each Wulfen chooses its reusable source package")
		army.entries.append(item)
	return army

func check_bank(army: Dictionary) -> void:
	check(army.entries.size() == 3 and R.validate(army).is_empty(), "Every model record and source count reopens")
	var report := Training.admit_current_catalog(army)
	check(report.error.is_empty() and int(report.get("total", 0)) == 1165 and R.summary(army).points == 1165, "Third-copy prices plus three source shields total exactly 1165 points")
	for copy_index in range(3):
		check(R.model_equipment(army.entries[0], copy_index, copy_index + 2).thunderwolf_cavalry_loadout == "boltgun-storm-shield", "The saved shield remains on its independent stable model")
	for entry_index in [1, 2]:
		check(R.model_equipment(army.entries[entry_index], 0, 0).wulfen_loadout != R.model_equipment(army.entries[entry_index], 1, 0).wulfen_loadout, "Wulfen copies keep independent totem/launcher records")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate Godot process reopens the Space Wolves bank")
		if store.error.is_empty() and store.active().lists.size() == 1: check_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	var distributions := 0
	var legal_distributions := 0
	for definition: String in IDS:
		var sizes := [3, 6] if definition == E.THUNDERWOLF else [5, 10]
		for models: int in sizes:
			var radix := 3 if definition == E.THUNDERWOLF else 2
			var accepted := 0
			for code in range(int(pow(radix, models))):
				var remaining: int = code
				var plasma := 0
				var shields := 0
				var loadout: Array[Dictionary] = []
				for model_index in range(models):
					var digit := remaining % radix
					remaining = int(remaining / radix)
					if definition == E.THUNDERWOLF:
						if digit == 1: plasma += 1
						if digit == 2: shields += 1
						loadout.append({"thunderwolf_cavalry_loadout": ["default", "plasma-pistol", "boltgun-storm-shield"][digit]})
					else: loadout.append({"wulfen_loadout": "death-totem" if digit == 0 else "stormfrag-auto-launcher"})
				var legal := definition != E.THUNDERWOLF or plasma <= int(models / 3)
				check(E.valid_saved_loadout(definition, loadout, models) == legal, "Exhaustive independent source distribution/cap matrix")
				if legal:
					accepted += 1
					check(E.points_for_loadout(definition, loadout, models) == shields * 5, "Per-bearer source shield pricing is exact")
				distributions += 1
			legal_distributions += accepted
			check(accepted == (20 if models == 3 else 496) if definition == E.THUNDERWOLF else accepted == int(pow(2, models)), "Exact legal source distribution count")
		var invalid := E.defaults(definition)
		invalid.unlisted = true
		check(not E.valid(definition, invalid, sizes[0]), "Unknown fields fail closed")
		invalid = E.defaults(definition)
		invalid[invalid.keys()[0]] = true
		check(not E.valid(definition, invalid, sizes[0]) and not E.valid_saved_loadout(definition, [], 0), "Wrong types and empty unit records fail closed")
	check(distributions == 2868 and legal_distributions == 2628, "Full matrix covers every supported source size and legal outcome")
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated current catalog opens offline")
	var army := make_army(catalog)
	check_bank(army)
	var before: Dictionary = army.entries[0].duplicate(true)
	check(not R.set_model_equipment(army.entries[0], 0, 4, "thunderwolf_cavalry_loadout", "plasma-pistol") and army.entries[0] == before, "A third plasma pistol is rejected atomically")
	var budget := R.new_list("11e", "Space Marines", "custom", 230)
	budget.entries.append(entry(catalog, E.THUNDERWOLF, 3, 2))
	check(Training.admit_current_catalog(budget).error.is_empty(), "Two default small units fit the exact source budget")
	check(R.set_model_equipment(budget.entries[0], 0, 0, "thunderwolf_cavalry_loadout", "boltgun-storm-shield") and R.summary(budget).points == 235 and not Training.admit_current_catalog(budget).error.is_empty(), "A saved shield cannot bypass the source budget")
	var path := ProjectSettings.globalize_path("user://space-wolves-squads-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Space Wolves army saves without optional model assets")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_space_wolves_squad_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Another process validates the complete saved army: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both players materialize every saved model: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable model IDs map to frozen positions")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1165 and int(state.training_points[owner]) == 1165, "Every materialized squad preserves canonical shield and copy-tier prices")
					for item: Dictionary in army.entries:
						for copy_index in range(int(item.copies)):
							for model_index in range(int(item.models)):
								var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, model_index)]
								var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
								var unit: Dictionary = state.units[model]
								var equipment := R.model_equipment(item, copy_index, model_index)
								check(unit.saved_model_equipment == equipment and unit.space_wolves_squad_loadout_locked, "Frozen equipment remains bound to its exact model")
								var definition := str(item.unit_id)
								var expected: Dictionary
								var defense := Defense.profile(state, model)
								if definition == E.THUNDERWOLF:
									expected = P.thunderwolf_cavalry_weapons(equipment.thunderwolf_cavalry_loadout)
									check(int(defense.invulnerable_target) == (4 if equipment.thunderwolf_cavalry_loadout == "boltgun-storm-shield" else 0) and int(unit.max_wounds) == 4, "Only the paid shield bearer gains 4+ invulnerable, without an extra Wound")
								else:
									expected = P.wulfen_weapons(equipment.wulfen_loadout) if definition == E.WULFEN else P.wulfen_storm_shields_weapons(equipment.wulfen_loadout)
									check(bool(unit.wulfen_death_totem) == (equipment.wulfen_loadout == "death-totem"), "Totem effect belongs to the selected model")
									check(Abilities.wulfen_death_totem_active(state, int(unit.squad)), "Actual totem ability lookup sees the saved mixed squad")
									check(int(defense.invulnerable_target) == (4 if definition == E.WULFEN_SHIELDS else 0) and int(unit.max_wounds) == 2, "Fixed Wulfen shields and source Wounds remain unchanged")
								check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee, "Exact source weapon package survives materialization")
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(c: Dictionary) -> bool: return c.action in ["thunderwolf-cavalry-loadout", "wulfen-loadout"]), "Readiness omits every saved persistent equipment choice")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1: continue
				before = state.duplicate(true)
				var result := Actions.apply(state, 1, {"action": "thunderwolf-cavalry-loadout" if str(unit.definition_id) == E.THUNDERWOLF else "wulfen-loadout", "model": model, "target": int(unit.squad), "value": "default" if str(unit.definition_id) == E.THUNDERWOLF else "death-totem"}, Vector2.ZERO, func() -> int: return 1)
				check(str(result.get("error", "")).contains("Saved Space Wolves equipment") and state == before, "Forced setup changes cannot mutate the captured state")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Space Wolves match saves")
			check(R.set_model_equipment(saved.list.entries[0], 0, 0, "thunderwolf_cavalry_loadout", "default") and store.save_list(saved.list).error.is_empty(), "Source army can change after match creation")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Later army edits cannot change captured weapons, defense or prices")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(3):
		panel._select_entry(index)
		check(panel.per_model_equipment_controls.get_child_count() == int(army.entries[index].models), "Workshop exposes one independent row per miniature")
	panel._select_entry(0)
	before = panel.draft.duplicate(true)
	var picker := panel.per_model_equipment_controls.get_child(2).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.draft == before and (panel.per_model_equipment_controls.get_child(2).get_child(2) as OptionButton).selected == 2, "Excess plasma reverts the actual shield control without changing the draft or its price")
	picker = panel.per_model_equipment_controls.get_child(5).get_child(2) as OptionButton
	picker.select(2)
	picker.item_selected.emit(2)
	check(panel.dirty and R.summary(panel.draft).points == 1170, "Real shield selector adds exactly five source points")
	for index in [1, 2]:
		panel._select_entry(index)
		picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
		picker.select(1)
		picker.item_selected.emit(1)
		check(R.model_equipment(panel.draft.entries[index], 0, 0).wulfen_loadout == "stormfrag-auto-launcher" and R.summary(panel.draft).points == 1170, "Real Wulfen selector changes only equipment, with no invented surcharge")
	check(Training.admit_current_catalog(panel.draft).total == R.summary(panel.draft).points, "Actual Workshop draft stays in canonical price parity")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Space Wolves saved squad equipment: %d failures; %d distributions, %d legal" % [failures, distributions, legal_distributions])
	quit(1 if failures else 0)
