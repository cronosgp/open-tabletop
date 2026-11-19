extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const S = preload("res://scripts/edition_11/specialist_squad_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const LOCKED := ["eradicator-melta", "desolation-rocket", "sternguard-gun", "sternguard-melee"]
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func _initialize() -> void:
	call_deferred("run")
func records(definition: String, models: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(models): result.append(E.defaults(definition))
	return result
func entry(catalog: Node, definition: String, models: int, copies: int) -> Dictionary:
	var source: Dictionary = catalog.lookup(definition)
	for i in range(source.options.size()):
		if int(source.options[i].models) == models: return R.entry(source, i, copies)
	check(false, "Admitted source size found")
	return {}
func inspect(unit: Dictionary, definition: String, equipment: Dictionary, index: int) -> void:
	var source := P.profile(definition.get_slice(":", 3))
	var ranged: Array = source.ranged.duplicate(true)
	var melee: Array = source.melee.duplicate(true)
	if definition == S.ERADICATORS: ranged[0] = P.eradicator_ranged(bool(equipment.eradicator_multi_melta))
	elif definition == S.DESOLATION: ranged = P.desolation_weapons(str(equipment.desolation_rocket))
	else:
		ranged[0] = P.sternguard_gun(str(equipment.sternguard_gun))
		if index == 0: melee = [P.sternguard_melee("chain" if equipment.sternguard_melee == "default" else str(equipment.sternguard_melee))]
	check(unit.ranged_weapons == ranged and unit.melee_weapons == melee and unit.sergeant == (index == 0), "Exact source inventories retain pistols, secondary weapons and role-specific melee")
	if definition == S.ERADICATORS: check(bool(unit.multi_melta) == bool(equipment.eradicator_multi_melta), "Multi-melta flag identifies exact ordinary bearer")
	if definition == S.STERNGUARD: check(bool(unit.sternguard_special) == (equipment.sternguard_gun != "firearm"), "Special weapon flag matches inventory")
func matrices() -> void:
	for models: int in [3, 6]:
		var accepted := 0
		for code in range(1 << models):
			var loadout := records(S.ERADICATORS, models)
			var count := 0
			for i in range(models):
				loadout[i].eradicator_multi_melta = (code & (1 << i)) != 0
				if loadout[i].eradicator_multi_melta: count += 1
			var legal: bool = not loadout[0].eradicator_multi_melta and count <= int(models / 3)
			check(E.valid_saved_loadout(S.ERADICATORS, loadout, models) == legal, "Exhaustive Multi-melta role and cap matrix")
			if legal: accepted += 1
		check(accepted == (3 if models == 3 else 16), "Only ordinary Eradicators supply the exact legal carrier combinations")
	var accepted := 0
	for code in range(243):
		var loadout := records(S.DESOLATION, 5)
		var remaining := code
		var legal := true
		for i in range(5):
			var digit := remaining % 3
			remaining = int(remaining / 3)
			loadout[i].desolation_rocket = ["superfrag", "superkrak", "vengor"][digit]
			if i > 0 and digit == 2: legal = false
		check(E.valid_saved_loadout(S.DESOLATION, loadout, 5) == legal, "Exhaustive Desolation role distributions")
		if legal:
			accepted += 1
			check(E.points_for_loadout(S.DESOLATION, loadout, 5) == (5 if loadout[0].desolation_rocket == "vengor" else 0), "Each legal Vengor costs five points exactly once")
	check(accepted == 48, "Exact legal five-model Desolation packages")
	for models: int in [5, 10]:
		accepted = 0
		for leader_melee: String in ["default", "fist", "power"]:
			for code in range(int(pow(3, models - 1))):
				var loadout := records(S.STERNGUARD, models)
				loadout[0].sternguard_melee = leader_melee
				var remaining := code
				var special := 0
				for i in range(1, models):
					var digit := remaining % 3
					remaining = int(remaining / 3)
					loadout[i].sternguard_gun = ["firearm", "heavy", "pyre"][digit]
					if digit > 0: special += 1
				var legal := special <= int(models / 5)
				check(E.valid_saved_loadout(S.STERNGUARD, loadout, models) == legal, "Exhaustive independent Sergeant melee and collective heavy/pyre cap")
				if legal: accepted += 1
		check(accepted == (27 if models == 5 else 489), "Exact legal Sternguard distribution count")
	for definition: String in [S.ERADICATORS, S.DESOLATION, S.STERNGUARD]:
		for models: int in S.sizes(definition):
			for index in range(models):
				var descriptors := S.controls_for_model(definition, models, index)
				for first: Dictionary in descriptors[0].choices:
					var second_choices: Array = descriptors[1].choices if descriptors.size() == 2 else [{"id": "unused"}]
					for second: Dictionary in second_choices:
						var equipment := E.defaults(definition)
						equipment[descriptors[0].field] = first.id
						if descriptors.size() == 2: equipment[descriptors[1].field] = second.id
						var unit := {}
						E.prepare(unit, definition, equipment, models, index)
						inspect(unit, definition, equipment, index)
			var invalid := E.defaults(definition)
			invalid.extra = true
			check(not E.valid(definition, invalid, models), "Unknown equipment fields fail closed")
func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, S.ERADICATORS, 6, 3), entry(catalog, S.DESOLATION, 5, 2), entry(catalog, S.STERNGUARD, 10, 3)]
	for copy_index in range(3):
		check(R.set_model_equipment(army.entries[0], copy_index, copy_index + 1, "eradicator_multi_melta", true), "Independent ordinary Eradicator carrier")
		check(R.set_model_equipment(army.entries[0], copy_index, copy_index + 2, "eradicator_multi_melta", true), "Second ordinary Multi-melta at six models")
		check(R.set_model_equipment(army.entries[2], copy_index, 0, "sternguard_melee", ["fist", "power", "default"][copy_index]), "Independent Sergeant melee")
		check(R.set_model_equipment(army.entries[2], copy_index, copy_index + 1, "sternguard_gun", "heavy"), "Heavy Bolter bearer")
		check(R.set_model_equipment(army.entries[2], copy_index, copy_index + 2, "sternguard_gun", "pyre"), "Independent Pyrecannon bearer")
	check(R.set_model_equipment(army.entries[1], 0, 0, "desolation_rocket", "vengor"), "Sergeant Vengor carries source surcharge")
	check(R.set_model_equipment(army.entries[1], 1, 0, "desolation_rocket", "superkrak") and R.set_model_equipment(army.entries[1], 0, 1, "desolation_rocket", "superkrak"), "Independent saved rockets")
	return army
func inspect_bank(army: Dictionary) -> void:
	var report := Training.admit_current_catalog(army)
	check(R.validate(army).is_empty() and report.error.is_empty(), "Whole saved specialist army passes catalog admission")
	check(int(report.get("total", 0)) == 1550 and R.summary(army).points == 1550, "Source third-copy tiers and one Vengor total exactly 1550")
	for item: Dictionary in army.entries:
		for copy_index in range(int(item.copies)): check(E.valid_saved_loadout(str(item.unit_id), R.model_equipment_loadouts(item, copy_index), int(item.models)), "Every persisted copy has a complete legal loadout")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate process reopens saved bank")
		if store.error.is_empty() and store.active().lists.size() == 1: inspect_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	matrices()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	var army := make_army(catalog)
	inspect_bank(army)
	for bad: Dictionary in [{"entry": 0, "model": 0, "field": "eradicator_multi_melta", "value": true}, {"entry": 0, "model": 5, "field": "eradicator_multi_melta", "value": true}, {"entry": 1, "model": 1, "field": "desolation_rocket", "value": "vengor"}, {"entry": 2, "model": 0, "field": "sternguard_gun", "value": "heavy"}, {"entry": 2, "model": 5, "field": "sternguard_gun", "value": "pyre"}, {"entry": 2, "model": 1, "field": "sternguard_melee", "value": "fist"}]:
		var before: Dictionary = army.entries[bad.entry].duplicate(true)
		check(not R.set_model_equipment(army.entries[bad.entry], 0, bad.model, bad.field, bad.value) and army.entries[bad.entry] == before, "Invalid role/cap edit rejects atomically")
	var budget := R.new_list("11e", "Space Marines", "custom", 140)
	budget.entries.append(entry(catalog, S.DESOLATION, 5, 1))
	check(Training.admit_current_catalog(budget).error.is_empty(), "Default Desolation fits exact 140-point budget")
	check(R.set_model_equipment(budget.entries[0], 0, 0, "desolation_rocket", "vengor") and R.summary(budget).points == 145 and not Training.admit_current_catalog(budget).error.is_empty(), "Vengor surcharge cannot bypass saved army budget")
	var path := ProjectSettings.globalize_path("user://specialist-squads-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Offline bank saves without visual assets")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_specialist_squad_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Another process validates saved equipment/points: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both saved specialist armies materialize: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable model references resolve")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1550 and int(state.training_points[owner]) == 1550, "Frozen squad sums retain copy tiers and Vengor pricing")
					for item: Dictionary in army.entries:
						for copy_index in range(int(item.copies)):
							for i in range(int(item.models)):
								var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, i)]
								var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
								var equipment := R.model_equipment(item, copy_index, i)
								check(state.units[model].saved_model_equipment == equipment, "Frozen model retains exact saved record")
								inspect(state.units[model], str(item.unit_id), equipment, i)
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(c: Dictionary) -> bool: return c.action in LOCKED), "Readiness never repeats saved specialist equipment")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1: continue
				var actions: Array = ["eradicator-melta"] if unit.definition_id == S.ERADICATORS else ["desolation-rocket"] if unit.definition_id == S.DESOLATION else ["sternguard-melee", "sternguard-gun"]
				for action: String in actions:
					var before := state.duplicate(true)
					var result := Actions.apply(state, 1, {"action": action, "model": model, "target": int(unit.squad), "value": "invalid"}, Vector2.ZERO, func() -> int: return 1)
					check(str(result.get("error", "")).contains("Saved specialist squad") and state == before, "Direct forced gear edit returns saved lock and preserves entire state")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Specialist match saves")
			check(R.set_model_equipment(saved.list.entries[1], 0, 0, "desolation_rocket", "superfrag") and store.save_list(saved.list).error.is_empty(), "Source Vengor can change after saving match")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Match remains isolated from source equipment/price changes")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(3):
		panel._select_entry(index)
		var item: Dictionary = army.entries[index]
		check(panel.per_model_equipment_controls.get_child_count() == int(item.models), "Native equipment row for every miniature")
		check(panel._similar_visual_model_indices(item, 0, 0).is_empty(), "Leader appearance never batches onto ordinary models")
	panel._select_entry(0)
	check((panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton).disabled, "Eradicator Sergeant's fixed rifle is disabled")
	var before := panel.draft.duplicate(true)
	var picker := panel.per_model_equipment_controls.get_child(5).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.draft == before and (panel.per_model_equipment_controls.get_child(5).get_child(2) as OptionButton).selected == 0, "Real over-cap Multi-melta signal reverts without mutation")
	panel._select_entry(1)
	picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
	picker.select(0)
	picker.item_selected.emit(0)
	check(R.summary(panel.draft).points == 1545, "Real Vengor removal subtracts exactly five points")
	picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
	picker.select(2)
	picker.item_selected.emit(2)
	check(panel.dirty and R.summary(panel.draft).points == 1550, "Real Vengor replacement restores source price")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Specialist squad saved equipment: %d failures" % failures)
	quit(1 if failures else 0)
