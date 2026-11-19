extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const R = preload("res://scripts/army_roster.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const IDS := [E.FIRESTRIKE, E.INFILTRATORS, E.BLADEGUARD]
const LOCKED := ["firestrike-gun", "helix-bearer", "bladeguard-pistol"]
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
	check(false, "Source model count exists")
	return {}

func inspect(unit: Dictionary, definition: String, equipment: Dictionary, model_index: int) -> void:
	var profile := P.profile(definition.get_slice(":", 3))
	var expected: Array = profile.ranged.duplicate(true)
	if definition == E.FIRESTRIKE: expected = [P.firestrike_autocannon()] if bool(equipment.firestrike_autocannon) else expected
	if definition == E.BLADEGUARD:
		expected = [P.bladeguard_pistol(str(equipment.bladeguard_pistol))]
		check(bool(unit.get("sergeant", false)) == (model_index == 0), "Stable model zero remains the Bladeguard Sergeant")
	if definition == E.INFILTRATORS: check(bool(unit.helix_gauntlet) == bool(equipment.helix_gauntlet), "Helix belongs to the selected stable bearer")
	check(unit.ranged_weapons == expected and unit.melee_weapons == profile.melee, "Exact source weapons and melee survive saved materialization")

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, E.FIRESTRIKE, 2, 2), entry(catalog, E.INFILTRATORS, 10, 2), entry(catalog, E.BLADEGUARD, 6, 3)]
	for copy_index in range(2):
		check(R.set_model_equipment(army.entries[0], copy_index, copy_index, "firestrike_autocannon", true), "Each Firestrike copy can carry a different mixed pair")
		check(R.set_model_equipment(army.entries[1], copy_index, copy_index + 2, "helix_gauntlet", true), "Each Infiltrator copy chooses its own single bearer")
	for copy_index in range(3): check(R.set_model_equipment(army.entries[2], copy_index, 0, "bladeguard_pistol", ["plasma", "volkite", "heavy"][copy_index]), "Each Sergeant has an independent pistol")
	return army

func check_bank(army: Dictionary) -> void:
	check(army.entries.size() == 3 and R.validate(army).is_empty(), "All specialist entries and source limits survive reopen")
	var report := Training.admit_current_catalog(army)
	check(report.error.is_empty() and int(report.get("total", 0)) == 1180 and R.summary(army).points == 1180, "Saved source copy tiers total exactly 1180 points")
	for copy_index in range(2):
		check(R.model_equipment(army.entries[0], copy_index, copy_index).firestrike_autocannon and not R.model_equipment(army.entries[0], copy_index, 1 - copy_index).firestrike_autocannon, "Firestrike copies retain independent model records")
		check(R.model_equipment(army.entries[1], copy_index, copy_index + 2).helix_gauntlet, "Helix bearer survives a separate process")
	for copy_index in range(3): check(R.model_equipment(army.entries[2], copy_index, 0).bladeguard_pistol == ["plasma", "volkite", "heavy"][copy_index], "Sergeant pistol survives disk reopen")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate Godot process reopens the specialist bank")
		if store.error.is_empty() and store.active().lists.size() == 1: check_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	for definition: String in IDS:
		var sizes := [1, 2] if definition == E.FIRESTRIKE else [5, 10] if definition == E.INFILTRATORS else [3, 6]
		for models: int in sizes:
			var radix := 3 if definition == E.BLADEGUARD else 2
			var accepted := 0
			for code in range(int(pow(radix, models))):
				var loadout: Array[Dictionary] = []
				var remaining: int = code
				var selected := 0
				var non_sergeant_alt := false
				for index in range(models):
					var digit := remaining % radix
					remaining = int(remaining / radix)
					if digit > 0: selected += 1
					if index > 0 and digit > 0: non_sergeant_alt = true
					loadout.append({"firestrike_autocannon": digit == 1} if definition == E.FIRESTRIKE else {"helix_gauntlet": digit == 1} if definition == E.INFILTRATORS else {"bladeguard_pistol": ["heavy", "volkite", "plasma"][digit]})
				var legal := (selected <= 1) if definition == E.INFILTRATORS else (not non_sergeant_alt) if definition == E.BLADEGUARD else true
				check(E.valid_saved_loadout(definition, loadout, models) == legal, "Exhaustive source cap/role matrix")
				if legal: accepted += 1
			check(accepted == (models + 1 if definition == E.INFILTRATORS else 3 if definition == E.BLADEGUARD else int(pow(2, models))), "Exact legal package count at each source model size")
		var invalid := E.defaults(definition)
		invalid.unlisted = true
		check(not E.valid(definition, invalid, sizes[0]), "Unknown equipment fields fail closed")
		invalid = E.defaults(definition)
		invalid[invalid.keys()[0]] = 1
		check(not E.valid(definition, invalid, sizes[0]) and not E.valid_saved_loadout(definition, [], 0), "Wrong value types and unsupported sizes fail closed")
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	var army := make_army(catalog)
	check_bank(army)
	var before: Dictionary = army.entries[1].duplicate(true)
	check(not R.set_model_equipment(army.entries[1], 0, 5, "helix_gauntlet", true) and army.entries[1] == before, "Second Helix bearer is rejected without altering the army")
	before = army.entries[2].duplicate(true)
	check(not R.set_model_equipment(army.entries[2], 0, 1, "bladeguard_pistol", "plasma") and army.entries[2] == before, "Ordinary Bladeguard cannot take the Sergeant replacement")
	var path := ProjectSettings.globalize_path("user://specialist-loadouts-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Specialist army saves without optional assets")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_squad_specialist_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Second process validates saved source roles and caps: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Specialist army materializes for both players: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable specialist model IDs map to frozen positions")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1180 and int(state.training_points[owner]) == 1180, "Materialized copy costs preserve the third Bladeguard tier")
					for item: Dictionary in army.entries:
						for copy_index in range(int(item.copies)):
							for model_index in range(int(item.models)):
								var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, model_index)]
								var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
								var equipment := R.model_equipment(item, copy_index, model_index)
								check(state.units[model].saved_model_equipment == equipment, "Frozen model retains its exact saved record")
								inspect(state.units[model], str(item.unit_id), equipment, model_index)
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(c: Dictionary) -> bool: return c.action in LOCKED), "Readiness never repeats the three saved equipment decisions")
			check(Actions.models(state, 1, "helix-gauntlet").size() == 2, "Actual Helix ability source lookup sees only the two saved bearers")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1: continue
				var definition := str(unit.definition_id)
				var action := "firestrike-gun" if definition == E.FIRESTRIKE else "helix-bearer" if definition == E.INFILTRATORS else "bladeguard-pistol"
				var value := "autocannon" if definition == E.FIRESTRIKE else "on" if definition == E.INFILTRATORS else "plasma"
				before = state.duplicate(true)
				var result := Actions.apply(state, 1, {"action": action, "model": model, "target": int(unit.squad), "value": value}, Vector2.ZERO, func() -> int: return 1)
				check(not str(result.get("error", "")).is_empty() and state == before, "Direct forced equipment changes fail without mutating the frozen army")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Specialist match saves")
			check(R.set_model_equipment(saved.list.entries[2], 0, 0, "bladeguard_pistol", "heavy") and store.save_list(saved.list).error.is_empty(), "Source Sergeant can change after the match was saved")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Source edits cannot alter the saved match")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(3):
		panel._select_entry(index)
		check(panel.per_model_equipment_controls.get_child_count() == int(army.entries[index].models), "Workshop shows one independent row per miniature")
	panel._select_entry(0)
	var picker := panel.per_model_equipment_controls.get_child(1).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(R.model_equipment(panel.draft.entries[0], 0, 1).firestrike_autocannon and R.model_equipment(panel.draft.entries[0], 1, 0).firestrike_autocannon == false, "Real turret signal preserves the other copy")
	panel._select_entry(1)
	before = panel.draft.duplicate(true)
	picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.draft == before and (panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton).selected == 0, "Second Helix selection restores the actual control and retains the draft")
	panel._select_entry(2)
	check((panel.per_model_equipment_controls.get_child(0).get_child(0) as Label).text == "Sergeant", "Workshop names the Sergeant role")
	for index in range(1, 6): check((panel.per_model_equipment_controls.get_child(index).get_child(2) as OptionButton).disabled, "Ordinary Bladeguard show fixed pistols")
	picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.dirty and R.model_equipment(panel.draft.entries[2], 0, 0).bladeguard_pistol == "volkite" and R.summary(panel.draft).points == 1180, "Real Sergeant signal updates its pistol without adding an invented cost")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Saved squad specialist equipment: %d failures" % failures)
	quit(1 if failures else 0)
