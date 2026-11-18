extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const M = preload("res://scripts/edition_11/mixed_space_wolves_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const R = preload("res://scripts/army_roster.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Mines = preload("res://scripts/edition_11/incursors.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
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
		if int(source.options[i].models) == models:
			if definition == M.HEADTAKERS:
				for composition: Dictionary in P.profile("wolf-guard-headtakers").composition_options:
					if int(composition.models) == models: return R.entry(source, i, copies, composition)
			return R.entry(source, i, copies)
	check(false, "Existing admitted composition found")
	return {}
func army_for(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, M.HEADTAKERS, 6, 2), entry(catalog, M.HEADTAKERS, 12, 1), entry(catalog, M.SCOUTS, 6, 2), entry(catalog, M.SCOUTS, 12, 1)]
	for item: Dictionary in army.entries:
		for copy_index in range(int(item.copies)):
			if item.unit_id == M.HEADTAKERS:
				check(R.set_model_equipment(item, copy_index, copy_index, "wolf_guard_headtaker_storm_shield", true), "Independent Headtaker shield bearer")
			else:
				var first := 3 if int(item.models) == 12 else 2
				check(R.set_model_equipment(item, copy_index, first, "wolf_scouts_loadout", "runic-stave"), "Scout special replacement")
				check(R.set_model_equipment(item, copy_index, first + 1, "wolf_scouts_loadout", "plasma-gun"), "Independent Scout plasma gun")
				if int(item.models) == 12: check(R.set_model_equipment(item, copy_index, first + 2, "wolf_scouts_loadout", "instigator-bolt-carbine"), "Twelve-model carbine")
				check(R.set_model_equipment(item, copy_index, 0, "wolf_scouts_haywire_mine", true), "Pack Leader retains plasma pistol and carries mine")
	return army
func inspect_bank(army: Dictionary) -> void:
	check(army.entries.size() == 4 and R.validate(army).is_empty(), "Mixed-role army remains valid after restart")
	var report := Training.admit_current_catalog(army)
	check(report.error.is_empty() and int(report.get("total", 0)) == 860 and R.summary(army).points == 860, "Existing size/copy tiers total 860 with free equipment")
	for item: Dictionary in army.entries:
		for copy_index in range(int(item.copies)):
			check(E.valid_saved_loadout(str(item.unit_id), R.model_equipment_loadouts(item, copy_index), int(item.models)), "Every reopened copy retains a complete legal record")
func matrices() -> void:
	for models: int in [6, 12]:
		var accepted := 0
		for code in range(1 << models):
			var loadout := records(M.HEADTAKERS, models)
			var legal := true
			for i in range(models):
				loadout[i].wolf_guard_headtaker_storm_shield = (code & (1 << i)) != 0
				if i % 6 >= 3 and loadout[i].wolf_guard_headtaker_storm_shield: legal = false
			check(E.valid_saved_loadout(M.HEADTAKERS, loadout, models) == legal, "All Headtaker shield distributions respect source roles")
			if legal: accepted += 1
		check(accepted == (8 if models == 6 else 64), "Exact legal shield distribution count")
		for i in range(models):
			for package: String in ["default", "bolt-pistol", "runic-stave", "thunderclap", "instigator-bolt-carbine", "plasma-gun"]:
				for mine: bool in [false, true]:
					var loadout := records(M.SCOUTS, models)
					loadout[i] = {"wolf_scouts_loadout": package, "wolf_scouts_haywire_mine": mine}
					var wolf := i == 1 or (models == 12 and i == 2)
					var legal := (package == "default" or (not wolf and i > 0)) and (package != "instigator-bolt-carbine" or models == 12) and (not mine or (not wolf and package == "default"))
					check(E.valid_saved_loadout(M.SCOUTS, loadout, models) == legal, "Every role/package/mine combination at each admitted size")
					if legal:
						var unit := {}
						E.prepare(unit, M.SCOUTS, loadout[i], models, i)
						var expected := P.wolf_scouts_model_loadout(i, models, package)
						check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and unit.max_wounds == expected.stats.wounds and unit.radius == expected.base_radius_inches, "Every valid Scout package uses exact source weapons and role stats")
		var first := 3 if models == 12 else 2
		for field: String in ["special", "plasma", "mine", "carbine"]:
			var loadout := records(M.SCOUTS, models)
			if field == "mine":
				loadout[0].wolf_scouts_haywire_mine = true
				loadout[first].wolf_scouts_haywire_mine = true
			else:
				loadout[first].wolf_scouts_loadout = "bolt-pistol" if field == "special" else "plasma-gun" if field == "plasma" else "instigator-bolt-carbine"
				loadout[first + 1].wolf_scouts_loadout = "runic-stave" if field == "special" else loadout[first].wolf_scouts_loadout
			check(not E.valid_saved_loadout(M.SCOUTS, loadout, models), "Collective special/plasma/carbine/mine caps reject duplicate bearers")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate process opens bank")
		if store.error.is_empty() and store.active().lists.size() == 1: inspect_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	matrices()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Local construction catalog opens offline")
	var army := army_for(catalog)
	inspect_bank(army)
	var before: Dictionary = army.entries[0].duplicate(true)
	check(not R.set_model_equipment(army.entries[0], 0, 3, "wolf_guard_headtaker_storm_shield", true) and before == army.entries[0], "Wolf shield rejection is atomic")
	before = army.entries[2].duplicate(true)
	check(not R.set_model_equipment(army.entries[2], 0, 1, "wolf_scouts_haywire_mine", true) and before == army.entries[2], "Wolf mine rejection is atomic")
	var path := ProjectSettings.globalize_path("user://mixed-wolves-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	check(store.save_list(army).error.is_empty(), "Army saves without visual downloads")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_mixed_space_wolves_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Independent process checks equipment and points: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both armies materialize: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable per-model references resolve: " + str(refs.error))
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 860 and int(state.training_points[owner]) == 860, "Materialized copy tiers preserve canonical total")
					for item: Dictionary in army.entries:
						for copy_index in range(int(item.copies)):
							for i in range(int(item.models)):
								var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, i)]
								var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
								var unit: Dictionary = state.units[model]
								var equipment := R.model_equipment(item, copy_index, i)
								var expected := P.wolf_scouts_model_loadout(i, int(item.models), str(equipment.wolf_scouts_loadout)) if item.unit_id == M.SCOUTS else P.wolf_guard_headtaker_model_loadout(M.role(M.HEADTAKERS, int(item.models), i), bool(equipment.wolf_guard_headtaker_storm_shield))
								check(unit.saved_model_equipment == equipment and unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and unit.defense.invulnerable_target == expected.stats.invulnerable_target and unit.max_wounds == expected.stats.wounds, "Frozen model has exact saved weapons, shield and role wounds")
			state.unit_abilities.setup_players = []
			var locked := ["wolf-scouts-loadout", "wolf-scouts-haywire-mine", "wolf-guard-headtaker-storm-shield"]
			check(not Actions.choices(state, 1).any(func(c: Dictionary) -> bool: return c.action in locked), "Readiness omits saved equipment decisions")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1: continue
				for action: String in locked:
					if (action.begins_with("wolf-scouts") and unit.definition_id != M.SCOUTS) or (action == "wolf-guard-headtaker-storm-shield" and unit.definition_id != M.HEADTAKERS): continue
					before = state.duplicate(true)
					var result := Actions.apply(state, 1, {"action": action, "model": model, "target": int(unit.squad), "value": "on"}, Vector2.ZERO, func() -> int: return 1)
					check(str(result.get("error", "")).contains("Saved mixed Space Wolves") and state == before, "Forced match equipment edit is rejected atomically")
			var split_state := state.duplicate(true)
			for model: int in split_state.units: split_state.units[model].on_battlefield = true
			for squad: int in state.squads:
				var members: Array = state.units.values().filter(func(u: Dictionary) -> bool: return int(u.squad) == squad)
				if members.is_empty(): continue
				if members[0].definition_id == M.HEADTAKERS:
					check(Actions._split_wolf_guard_headtakers(split_state, squad).is_empty(), "Saved shields preserve Let Loose the Wolves")
				else: check(Mines._mine_models(split_state, squad).size() == 1, "Live mine ability sees exactly the saved plasma-pistol bearer")
			for model: int in state.units:
				check(state.units[model].ranged_weapons == split_state.units[model].ranged_weapons and state.units[model].melee_weapons == split_state.units[model].melee_weapons, "Formation split preserves saved equipment")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(4):
		panel._select_entry(index)
		var item: Dictionary = army.entries[index]
		check(panel.per_model_equipment_controls.get_child_count() == int(item.models), "One native equipment row per model")
		for i in range(int(item.models)):
			var row := panel.per_model_equipment_controls.get_child(i)
			var wolf := M.role(str(item.unit_id), int(item.models), i) == "hunting-wolf"
			check((row.get_child(2) as OptionButton).disabled == (wolf or (item.unit_id == M.SCOUTS and i == 0)), "Only fixed role weapon selectors are disabled")
			if wolf and item.unit_id == M.SCOUTS: check((row.get_child(4) as OptionButton).disabled, "Wolf mine selector is disabled")
		check(R.model_equipment_role(item, 0, 0) != R.model_equipment_role(item, 0, 3 if item.unit_id == M.HEADTAKERS else 1), "Appearance matching distinguishes human and wolf roles")
		var similar := panel._similar_visual_model_indices(item, 0, 0)
		for candidate: int in similar: check(M.role(str(item.unit_id), int(item.models), candidate) == M.role(str(item.unit_id), int(item.models), 0), "Actual appearance sharing never crosses roles")
		if item.unit_id == M.SCOUTS: check(R.model_equipment_role(item, 0, 0) != R.model_equipment_role(item, 0, int(item.models) - 1), "Appearance matching distinguishes leader and ordinary Scout")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Mixed Space Wolves saved equipment: %d failures" % failures)
	quit(1 if failures else 0)

