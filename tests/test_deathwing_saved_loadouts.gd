extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const S = preload("res://scripts/edition_11/deathwing_saved_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const A = preload("res://scripts/edition_11/unit_abilities.gd")
const Stratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const REIVER := "40kdc:11e:adeptus-astartes:reiver-squad"
const LOCKED := ["terminator-melee", "terminator-special-weapon", "deathwing-knights-melee", "deathwing-knights-watcher"]
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
	var identity := definition.get_slice(":", 3)
	var profile := P.profile(identity)
	var ranged: Array = profile.ranged.duplicate(true)
	var melee: Array = profile.melee.duplicate(true)
	if definition == S.KNIGHTS:
		var weapon_id := str(equipment.deathwing_knight_melee)
		if weapon_id == "default": weapon_id = "great-weapon-of-the-unforgiven" if index == 0 else "mace-of-absolution"
		melee = [P.deathwing_knight_melee_weapon(weapon_id)]
	else:
		if equipment.terminator_melee_choice != "power-fist": melee = [P.additional_weapon(identity, "melee", equipment.terminator_melee_choice)]
		var special := str(equipment.terminator_special_weapon)
		if not special.is_empty():
			ranged = [P.additional_weapon(identity, "ranged", special)]
			if special == "cyclone-missile-launcher": ranged.push_front(profile.ranged[0].duplicate(true))
	check(unit.ranged_weapons == ranged and unit.melee_weapons == melee and unit.sergeant == (index == 0), "Source weapons, secondary bolters and model roles survive saved preparation")
func matrices() -> void:
	var accepted := 0
	for code in range(243):
		var loadout := records(S.KNIGHTS, 5)
		var remaining := code
		var legal := true
		for i in range(5):
			var digit := remaining % 3
			remaining = int(remaining / 3)
			loadout[i].deathwing_knight_melee = ["default", "relic-weapon", "power-weapon"][digit]
			if (i == 0 and digit == 2) or (i > 0 and digit == 1): legal = false
		check(E.valid_saved_loadout(S.KNIGHTS, loadout, 5) == legal, "Exhaustive Knight Master/ordinary weapon-role matrix")
		if legal: accepted += 1
	check(accepted == 32, "Exactly 32 independent legal five-model Knight packages")
	for models: int in [5, 10]:
		for leader: String in ["power-fist", "chainfist", "power-weapon"]:
			for code in range(1 << (models - 1)):
				var loadout := records(S.TERMINATORS, models)
				loadout[0].terminator_melee_choice = leader
				for i in range(1, models): loadout[i].terminator_melee_choice = "chainfist" if (code & (1 << (i - 1))) != 0 else "power-fist"
				loadout[1].terminator_special_weapon = "plasma-cannon"
				check(E.valid_saved_loadout(S.TERMINATORS, loadout, models), "All melee distributions combine with an ordinary Plasma Cannon")
		var primaries := 1
		for first in range(1, models):
			for weapon: String in ["assault-cannon", "heavy-flamer", "plasma-cannon", "cyclone-missile-launcher"]:
				var loadout := records(S.TERMINATORS, models)
				loadout[first].terminator_special_weapon = weapon
				check(E.valid_saved_loadout(S.TERMINATORS, loadout, models) and E.points_for_loadout(S.TERMINATORS, loadout, models) == (10 if weapon == "cyclone-missile-launcher" else 0), "Every legal single special preserves source price")
				primaries += 1
				if models == 10:
					for second in range(first + 1, models):
						for second_weapon: String in ["assault-cannon", "heavy-flamer", "plasma-cannon", "cyclone-missile-launcher"]:
							loadout = records(S.TERMINATORS, models)
							loadout[first].terminator_special_weapon = weapon
							loadout[second].terminator_special_weapon = second_weapon
							check(E.valid_saved_loadout(S.TERMINATORS, loadout, models) and E.points_for_loadout(S.TERMINATORS, loadout, models) == (10 if weapon == "cyclone-missile-launcher" else 0) + (10 if second_weapon == "cyclone-missile-launcher" else 0), "Every legal primary pair shares the cap and counts each Cyclone")
							primaries += 1
		check(primaries == (17 if models == 5 else 613), "All legal Deathwing primary distributions enumerated")
	for definition: String in [S.TERMINATORS, S.KNIGHTS]:
		for watcher: bool in [false, true]: check(E.valid_unit(definition, {"watcher_in_the_dark": watcher}), "Watcher is one free unit-level boolean")
		for invalid: Variant in [{}, {"watcher_in_the_dark": 1}, {"watcher_in_the_dark": true, "bearer": 0}, [true]]: check(not E.valid_unit(definition, invalid), "No invalid unit shape/type or fictional Watcher bearer")
		for models: int in S.sizes(definition):
			for index in range(models):
				var descriptors := E.controls_for_model(definition, index, models)
				for first: Dictionary in descriptors[0].choices:
					var seconds: Array = descriptors[1].choices if descriptors.size() == 2 else [{"id": "unused"}]
					for second: Dictionary in seconds:
						var equipment := E.defaults(definition)
						equipment[descriptors[0].field] = first.id
						if descriptors.size() == 2: equipment[descriptors[1].field] = second.id
						var unit := {}
						E.prepare(unit, definition, equipment, models, index)
						inspect(unit, definition, equipment, index)
func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, S.TERMINATORS, 5, 3), entry(catalog, S.KNIGHTS, 5, 3), entry(catalog, REIVER, 5, 1)]
	for copy_index in range(3):
		check(R.set_model_equipment(army.entries[0], copy_index, 1, "terminator_special_weapon", "cyclone-missile-launcher"), "Identical model equipment with independently saved unit choices")
		check(R.set_model_equipment(army.entries[1], copy_index, 0, "deathwing_knight_melee", "relic-weapon") and R.set_model_equipment(army.entries[1], copy_index, 1, "deathwing_knight_melee", "power-weapon"), "Independent Knight Master and ordinary replacements")
		if copy_index != 1:
			for i in range(2): check(R.set_unit_equipment(army.entries[i], copy_index, "watcher_in_the_dark", true), "Watcher belongs once to this stable unit copy")
	check(R.set_unit_equipment(army.entries[2], 0, "reiver_grav_chutes", true) and R.set_unit_equipment(army.entries[2], 0, "reiver_grapnel_launchers", true), "Existing Reiver squad gear remains separate and supported")
	return army
func inspect_bank(army: Dictionary) -> void:
	var report := Training.admit_current_catalog(army)
	check(R.validate(army).is_empty() and report.error.is_empty(), "Saved unit/model army passes catalog gates: " + str(report.error))
	check(int(report.get("total", 0)) == 1510 and R.summary(army).points == 1510, "Free Watchers, Cyclones and actual copy tiers total 1510")
	for i in range(2):
		for copy_index in range(3): check(R.unit_equipment(army.entries[i], copy_index).watcher_in_the_dark == (copy_index != 1), "Unit-level Watcher identity survives disk restart")
	check(R.unit_equipment(army.entries[2], 0) == {"reiver_grav_chutes": true, "reiver_grapnel_launchers": true}, "Legacy-supported Reiver unit gear survives restart")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Independent process opens bank")
		if store.error.is_empty() and store.active().lists.size() == 1: inspect_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	matrices()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	var army := make_army(catalog)
	inspect_bank(army)
	var repriced := R.reprice(army, catalog.catalog)
	check(repriced.error.is_empty(), "Current catalog refresh succeeds")
	if repriced.error.is_empty():
		inspect_bank(repriced.list)
		for i in range(3): check(repriced.list.entries[i].unit_equipment_by_copy_id == army.entries[i].unit_equipment_by_copy_id, "Repricing preserves unit records and stable copy keys, including Reiver")
	var split := R.split_copy(army.entries[0], 1)
	check(split.error.is_empty() and not R.unit_equipment(split.selected, 0).watcher_in_the_dark and R.unit_equipment(split.remaining, 0).watcher_in_the_dark and R.unit_equipment(split.remaining, 1).watcher_in_the_dark, "Splitting a copy preserves distinct unit choices")
	for bad: Dictionary in [{"entry": 0, "model": 0, "field": "terminator_special_weapon", "value": "plasma-cannon"}, {"entry": 0, "model": 2, "field": "terminator_special_weapon", "value": "plasma-cannon"}, {"entry": 1, "model": 0, "field": "deathwing_knight_melee", "value": "power-weapon"}, {"entry": 1, "model": 1, "field": "deathwing_knight_melee", "value": "relic-weapon"}]:
		var before: Dictionary = army.entries[bad.entry].duplicate(true)
		check(not R.set_model_equipment(army.entries[bad.entry], 0, bad.model, bad.field, bad.value) and army.entries[bad.entry] == before, "Invalid roles and shared caps reject atomically")
	var path := ProjectSettings.globalize_path("user://deathwing-loadouts-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Unit/model army saves without assets")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_deathwing_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Another process checks independent unit records: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var bad_selection: Dictionary = report.selection.duplicate(true)
		bad_selection.entries[0].saved_unit_loadouts[0] = {"watcher_in_the_dark": 1}
		check(not Training.Capabilities.admit(bad_selection).error.is_empty(), "Malformed canonical unit records cannot be admitted")
		bad_selection = report.selection.duplicate(true)
		bad_selection.entries[0].definition_id = "40kdc:11e:adeptus-astartes:terminator-squad"
		check(not Training.Capabilities.admit(bad_selection).error.is_empty(), "Unit records cannot be applied to an unsupported profile")
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DARK ANGELS", 2: "DARK ANGELS"}}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both armies materialize with saved unit/model gear: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable mapping distinguishes identical models with different Watchers")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1510 and int(state.training_points[owner]) == 1510, "Prepared prices preserve copy tiers and free Watchers")
					for i in range(2):
						var item: Dictionary = army.entries[i]
						for copy_index in range(3):
							var copy_ref: Dictionary = refs.copies[R.normalize_copy_instance_ids(item)[copy_index]]
							var squad := owner + int(copy_ref.unit_index) * 2
							check(A.has(state, squad, "watcher-in-the-dark") == (copy_index != 1) and state.squads[squad].saved_unit_equipment == R.unit_equipment(item, copy_index), "Source ability lookup sees exactly each saved watched unit")
							for j in range(5):
								var model_ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, j)]
								var model := (owner + int(model_ref.unit_index) * 2) * 100 + int(model_ref.model_index)
								inspect(state.units[model], str(item.unit_id), R.model_equipment(item, copy_index, j), j)
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(c: Dictionary) -> bool: return c.action in LOCKED), "Readiness omits both persistent unit and model choices")
			var watched := -1
			for squad: int in state.squads:
				if int(state.squads[squad].owner) != 1 or not state.squads[squad].has("saved_unit_equipment"): continue
				if A.has(state, squad, "watcher-in-the-dark"): watched = squad
				var before := state.duplicate(true)
				var result := Actions.apply(state, 1, {"action": "deathwing-knights-watcher", "model": -1, "target": squad, "value": "off"}, Vector2.ZERO, Callable())
				check(str(result.get("error", "")).contains("Saved Deathwing unit") and state == before, "Forced unit equipment edits preserve entire frozen state")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1 or str(unit.definition_id) not in [S.TERMINATORS, S.KNIGHTS]: continue
				var gear_actions: Array = ["terminator-melee", "terminator-special-weapon"] if unit.definition_id == S.TERMINATORS else ["deathwing-knights-melee"]
				for action: String in gear_actions:
					var before := state.duplicate(true)
					var result := Actions.apply(state, 1, {"action": action, "model": model, "target": int(unit.squad), "value": "invalid"}, Vector2.ZERO, Callable())
					check(str(result.get("error", "")).contains("Saved Deathwing equipment") and state == before, "Forced model gear changes preserve entire frozen state")
			var reaction := state.duplicate(true)
			reaction.phase = "shooting"
			reaction.active = 2
			reaction.pending_attack = {"current": {"phase": "damage", "target": watched, "cursor": 0, "steps": [{"kind": "devastating"}]}}
			reaction.unit_abilities.window = {"kind": Stratagems.LAYERED_CERAMITE_WINDOW, "owners": [1], "squad": watched}
			var watcher_choices: Array = Actions.choices(reaction, 1).filter(func(c: Dictionary) -> bool: return c.action == "watcher-in-dark" and int(c.target) == watched)
			check(watcher_choices.size() == 1, "Saved equipped Watcher remains a live mortal-wound response")
			if watcher_choices.size() == 1:
				var response := Actions.apply(reaction, 1, watcher_choices[0], Vector2.ZERO, Callable())
				check(str(response.get("error", "")).is_empty() and reaction.unit_abilities.watcher_active.get(watched, false), "Saved Watcher activates during the match")
				check(not Actions.choices(reaction, 1).any(func(c: Dictionary) -> bool: return c.action == "watcher-in-dark" and int(c.target) == watched), "Watcher use remains once per battle")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Unit/model match saves")
			check(R.set_unit_equipment(saved.list.entries[0], 0, "watcher_in_the_dark", false) and store.save_list(saved.list).error.is_empty(), "Source unit option can change after match save")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Saved match ignores later source unit/model changes")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for i in range(2):
		panel._select_entry(i)
		check(panel.per_model_equipment_controls.get_child_count() == 6 and panel.per_model_equipment_controls.get_child(0) is CheckBox, "One unit Watcher control followed by five miniature rows")
		var checkbox := panel.per_model_equipment_controls.get_child(0) as CheckBox
		checkbox.set_pressed_no_signal(false)
		checkbox.toggled.emit(false)
		check(not R.unit_equipment(panel.draft.entries[i], 0).watcher_in_the_dark and R.unit_equipment(panel.draft.entries[i], 2).watcher_in_the_dark and R.summary(panel.draft).points == 1510, "Native unit checkbox changes only the selected copy and is free")
		check(panel._similar_visual_model_indices(panel.draft.entries[i], 0, 0).is_empty(), "Appearance sharing preserves leader role independently of unit Watcher")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Saved Deathwing unit/model equipment: %d failures" % failures)
	quit(1 if failures else 0)
