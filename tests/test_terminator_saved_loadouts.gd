extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const S = preload("res://scripts/edition_11/terminator_saved_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const LOCKED := ["terminator-melee", "terminator-special-weapon", "terminator-assault-loadout", "wolf-guard-terminator-loadout"]
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
	var source := P.profile(identity)
	var ranged: Array = source.ranged.duplicate(true)
	var melee: Array = source.melee.duplicate(true)
	var shield := false
	if definition == S.STANDARD:
		if equipment.terminator_melee_choice != "power-fist": melee = [P.additional_weapon(identity, "melee", equipment.terminator_melee_choice)]
		var special := str(equipment.terminator_special_weapon)
		if not special.is_empty():
			ranged = [P.additional_weapon(identity, "ranged", special)]
			if special == "cyclone-missile-launcher": ranged.push_front(source.ranged[0].duplicate(true))
	elif definition == S.ASSAULT:
		shield = bool(equipment.terminator_assault_storm_shield)
		if shield: melee = [P.additional_weapon(identity, "melee", "thunder-hammer")]
	else:
		var expected := P.wolf_guard_terminator_weapons(equipment.wolf_guard_terminator_loadout)
		ranged = expected.ranged
		melee = expected.melee
		shield = equipment.wolf_guard_terminator_loadout == "storm-shield"
	check(unit.ranged_weapons == ranged and unit.melee_weapons == melee and bool(unit.sergeant) == (index == 0), "Full source inventories and stable leader roles survive preparation")
	check(unit.max_wounds == 3 + (1 if shield else 0) and unit.wounds == unit.max_wounds and unit.defense.invulnerable_target == 4, "Shield adds exactly one bearer Wound and preserves the fixed 4+ invulnerable save")
func check_standard_ranged(loadout: Array[Dictionary], models: int, cost: int) -> void:
	check(E.valid_saved_loadout(S.STANDARD, loadout, models) and E.points_for_loadout(S.STANDARD, loadout, models) == cost, "Every legal primary combination preserves the shared cap and Cyclone surcharge")
func matrices() -> void:
	for models: int in [5, 10]:
		for code in range(1 << models):
			var loadout := records(S.ASSAULT, models)
			var count := 0
			for i in range(models):
				loadout[i].terminator_assault_storm_shield = (code & (1 << i)) != 0
				if loadout[i].terminator_assault_storm_shield: count += 1
			check(E.valid_saved_loadout(S.ASSAULT, loadout, models) and E.points_for_loadout(S.ASSAULT, loadout, models) == count * 5, "Every Assault shield distribution is legal and costs five per bearer")
		var accepted := 0
		for leader: String in ["default", "storm-shield", "relic-greataxe", "twin-lightning-claws"]:
			for code in range(int(pow(3, models - 1))):
				var loadout := records(S.WOLVES, models)
				loadout[0].wolf_guard_terminator_loadout = leader
				var remaining := code
				var cannons := 0
				for i in range(1, models):
					var digit := remaining % 3
					remaining = int(remaining / 3)
					loadout[i].wolf_guard_terminator_loadout = ["default", "storm-shield", "assault-cannon-power-fist"][digit]
					if digit == 2: cannons += 1
				var legal := cannons <= int(models / 5)
				check(E.valid_saved_loadout(S.WOLVES, loadout, models) == legal, "Exhaustive Wolf Guard leader, shield and cannon distributions")
				if legal: accepted += 1
		check(accepted == (192 if models == 5 else 29696), "Exact legal Wolf Guard package count")
		for leader: String in ["power-fist", "chainfist", "power-weapon"]:
			for code in range(1 << (models - 1)):
				var loadout := records(S.STANDARD, models)
				loadout[0].terminator_melee_choice = leader
				for i in range(1, models): loadout[i].terminator_melee_choice = "chainfist" if (code & (1 << (i - 1))) != 0 else "power-fist"
				loadout[1].terminator_special_weapon = ["", "assault-cannon", "heavy-flamer", "cyclone-missile-launcher"][code % 4]
				check(E.valid_saved_loadout(S.STANDARD, loadout, models), "Every standard melee distribution accepts the independent primary slot")
		var ranged_count := 1
		check_standard_ranged(records(S.STANDARD, models), models, 0)
		for first in range(1, models):
			for weapon: String in ["assault-cannon", "heavy-flamer", "cyclone-missile-launcher"]:
				var loadout := records(S.STANDARD, models)
				loadout[first].terminator_special_weapon = weapon
				check_standard_ranged(loadout, models, 10 if weapon == "cyclone-missile-launcher" else 0)
				ranged_count += 1
				if models == 10:
					for second in range(first + 1, models):
						for second_weapon: String in ["assault-cannon", "heavy-flamer", "cyclone-missile-launcher"]:
							loadout = records(S.STANDARD, models)
							loadout[first].terminator_special_weapon = weapon
							loadout[second].terminator_special_weapon = second_weapon
							check_standard_ranged(loadout, models, (10 if weapon == "cyclone-missile-launcher" else 0) + (10 if second_weapon == "cyclone-missile-launcher" else 0))
							ranged_count += 1
		check(ranged_count == (13 if models == 5 else 352), "All legal standard primary distributions enumerated")
		var over_cap := records(S.STANDARD, models)
		for i in range(1, int(models / 5) + 2): over_cap[i].terminator_special_weapon = "cyclone-missile-launcher"
		check(not E.valid_saved_loadout(S.STANDARD, over_cap, models), "Mixed standard special limit cannot be exceeded")
	for definition: String in [S.STANDARD, S.ASSAULT, S.WOLVES]:
		for models: int in [5, 10]:
			for i in range(models):
				var descriptors := E.controls_for_model(definition, i, models)
				for first: Dictionary in descriptors[0].choices:
					var seconds: Array = descriptors[1].choices if descriptors.size() == 2 else [{"id": "unused"}]
					for second: Dictionary in seconds:
						var equipment := E.defaults(definition)
						equipment[descriptors[0].field] = first.id
						if descriptors.size() == 2: equipment[descriptors[1].field] = second.id
						var unit := {}
						E.prepare(unit, definition, equipment, models, i)
						inspect(unit, definition, equipment, i)
						var before := unit.duplicate(true)
						E.prepare(unit, definition, equipment, models, i)
						check(unit == before, "Equipment preparation is idempotent; shield Wounds do not accumulate")
			var invalid := E.defaults(definition)
			invalid.extra = true
			check(not E.valid(definition, invalid, models) and not E.valid_saved_loadout(definition, [], models), "Wrong fields and incomplete unit records fail closed")
func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, S.STANDARD, 5, 3), entry(catalog, S.ASSAULT, 5, 3), entry(catalog, S.WOLVES, 5, 3)]
	for copy_index in range(3):
		check(R.set_model_equipment(army.entries[0], copy_index, 0, "terminator_melee_choice", ["power-fist", "chainfist", "power-weapon"][copy_index]), "Independent Sergeant melee")
		check(R.set_model_equipment(army.entries[0], copy_index, 1, "terminator_special_weapon", "cyclone-missile-launcher") and R.set_model_equipment(army.entries[0], copy_index, 2, "terminator_melee_choice", "chainfist"), "Cyclone with Storm Bolter and independent ordinary Chainfist")
		check(R.set_model_equipment(army.entries[1], copy_index, 0, "terminator_assault_storm_shield", true) and R.set_model_equipment(army.entries[1], copy_index, copy_index + 1, "terminator_assault_storm_shield", true), "Independent Sergeant and ordinary Assault shields")
		check(R.set_model_equipment(army.entries[2], copy_index, 0, "wolf_guard_terminator_loadout", ["relic-greataxe", "twin-lightning-claws", "storm-shield"][copy_index]), "Independent Pack Leader package")
		check(R.set_model_equipment(army.entries[2], copy_index, copy_index + 1, "wolf_guard_terminator_loadout", "assault-cannon-power-fist") and R.set_model_equipment(army.entries[2], copy_index, 4, "wolf_guard_terminator_loadout", "storm-shield"), "Ordinary Wolf Guard special and shield bearers")
	return army
func inspect_bank(army: Dictionary) -> void:
	var report := Training.admit_current_catalog(army)
	check(R.validate(army).is_empty() and report.error.is_empty(), "Saved Terminator army passes existing catalog gates: " + str(report.error))
	check(int(report.get("total", 0)) == 1820 and R.summary(army).points == 1820, "Source copy tiers, Cyclones and shields total exactly 1820 points")
	for item: Dictionary in army.entries:
		for copy_index in range(int(item.copies)): check(E.valid_saved_loadout(str(item.unit_id), R.model_equipment_loadouts(item, copy_index), int(item.models)), "Reopened model records remain complete and legal")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate process reopens bank")
		if store.error.is_empty() and store.active().lists.size() == 1: inspect_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	matrices()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated catalog opens offline")
	var army := make_army(catalog)
	inspect_bank(army)
	for bad: Dictionary in [{"entry": 0, "model": 0, "field": "terminator_special_weapon", "value": "assault-cannon"}, {"entry": 0, "model": 2, "field": "terminator_melee_choice", "value": "power-weapon"}, {"entry": 0, "model": 2, "field": "terminator_special_weapon", "value": "heavy-flamer"}, {"entry": 2, "model": 0, "field": "wolf_guard_terminator_loadout", "value": "assault-cannon-power-fist"}, {"entry": 2, "model": 4, "field": "wolf_guard_terminator_loadout", "value": "relic-greataxe"}, {"entry": 2, "model": 2, "field": "wolf_guard_terminator_loadout", "value": "assault-cannon-power-fist"}]:
		var before: Dictionary = army.entries[bad.entry].duplicate(true)
		check(not R.set_model_equipment(army.entries[bad.entry], 0, bad.model, bad.field, bad.value) and army.entries[bad.entry] == before, "Role/cap rejection preserves draft atomically")
	for definition: String in [S.STANDARD, S.ASSAULT, S.WOLVES]:
		var budget := R.new_list("11e", "Space Marines", "custom", 190 if definition == S.STANDARD else 170 if definition == S.ASSAULT else 180)
		budget.entries.append(entry(catalog, definition, 5, 1))
		check(Training.admit_current_catalog(budget).error.is_empty(), "Default unit fits exact sourced budget")
		var field := "terminator_special_weapon" if definition == S.STANDARD else "terminator_assault_storm_shield" if definition == S.ASSAULT else "wolf_guard_terminator_loadout"
		var value: Variant = "cyclone-missile-launcher" if definition == S.STANDARD else true if definition == S.ASSAULT else "storm-shield"
		check(R.set_model_equipment(budget.entries[0], 0, 1, field, value) and not Training.admit_current_catalog(budget).error.is_empty(), "Each paid option participates in budget admission")
	var path := ProjectSettings.globalize_path("user://terminator-loadouts-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Offline army saves without visual downloads")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_terminator_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Independent process checks source packages and points: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both Terminator armies materialize: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable miniature references resolve")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1820 and int(state.training_points[owner]) == 1820, "Materialized prices preserve all copy tiers and paid gear")
					for item: Dictionary in army.entries:
						for copy_index in range(int(item.copies)):
							for i in range(int(item.models)):
								var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, i)]
								var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
								var equipment := R.model_equipment(item, copy_index, i)
								check(state.units[model].saved_model_equipment == equipment, "Frozen equipment equals saved miniature record")
								inspect(state.units[model], str(item.unit_id), equipment, i)
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(c: Dictionary) -> bool: return c.action in LOCKED), "Readiness omits persistent Terminator equipment")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1: continue
				var actions: Array = ["terminator-melee", "terminator-special-weapon"] if unit.definition_id == S.STANDARD else ["terminator-assault-loadout"] if unit.definition_id == S.ASSAULT else ["wolf-guard-terminator-loadout"]
				for action: String in actions:
					var before := state.duplicate(true)
					var result := Actions.apply(state, 1, {"action": action, "model": model, "target": int(unit.squad), "value": "invalid"}, Vector2.ZERO, func() -> int: return 1)
					check(str(result.get("error", "")).contains("Saved Terminator equipment") and state == before, "Forced saved gear changes preserve entire frozen match")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Terminator match saves")
			check(R.set_model_equipment(saved.list.entries[1], 0, 0, "terminator_assault_storm_shield", false) and store.save_list(saved.list).error.is_empty(), "Source shield can change after saving match")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Source edits cannot alter saved match Wounds, gear or price")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for i in range(3):
		panel._select_entry(i)
		check(panel.per_model_equipment_controls.get_child_count() == 5 and panel._similar_visual_model_indices(army.entries[i], 0, 0).is_empty(), "Native model rows and appearance sharing preserve leader role")
	panel._select_entry(0)
	check((panel.per_model_equipment_controls.get_child(0).get_child(4) as OptionButton).disabled, "Standard Sergeant Storm Bolter is fixed")
	var before := panel.draft.duplicate(true)
	var picker := panel.per_model_equipment_controls.get_child(2).get_child(4) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.draft == before and (panel.per_model_equipment_controls.get_child(2).get_child(4) as OptionButton).selected == 0, "Real over-cap special selector reverts without changing draft")
	panel._select_entry(1)
	picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
	picker.select(0)
	picker.item_selected.emit(0)
	check(R.summary(panel.draft).points == 1815, "Real shield removal subtracts five points")
	picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.dirty and R.summary(panel.draft).points == 1820, "Real shield restoration adds five points once")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Saved Terminator equipment: %d failures" % failures)
	quit(1 if failures else 0)
