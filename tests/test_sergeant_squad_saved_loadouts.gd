extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const S = preload("res://scripts/edition_11/sergeant_squad_equipment.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const LOCKED := ["jump-pack-sergeant-pistol", "jump-pack-sergeant-melee", "jump-pack-trooper-pistol", "blood-claws-pack-leader-pistol", "blood-claws-pack-leader-melee", "grey-hunters-pack-leader-pistol", "grey-hunters-pack-leader-melee"]
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
	check(false, "Existing admitted size found")
	return {}
func matrices() -> void:
	for models: int in [5, 10]:
		var accepted := 0
		for pistol: String in ["heavy-bolt-pistol", "hand-flamer", "plasma-pistol"]:
			for melee: String in ["chainsword", "power-fist", "power-weapon"]:
				for code in range(1 << (models - 1)):
					var loadout := records(S.JUMP, models)
					loadout[0] = {"jump_intercessor_pistol": pistol, "jump_intercessor_melee": melee}
					var count := 0
					for i in range(1, models):
						if (code & (1 << (i - 1))) != 0:
							loadout[i].jump_intercessor_pistol = "plasma-pistol"
							count += 1
					var legal := count <= int(models / 5)
					check(E.valid_saved_loadout(S.JUMP, loadout, models) == legal, "All Jump Sergeant and trooper Plasma distributions respect the source cap")
					if legal: accepted += 1
		check(accepted == (45 if models == 5 else 414), "Sergeant Plasma is independent of the ordinary-model cap")
	for definition: String in [S.JUMP, S.BLOOD, S.GREY]:
		var descriptors := S.controls(definition)
		for models: int in S.sizes(definition):
			for i in range(models):
				for pistol: Dictionary in descriptors[0].choices:
					for melee: Dictionary in descriptors[1].choices:
						var loadout := records(definition, models)
						loadout[i] = {S.prefix(definition) + "_pistol": pistol.id, S.prefix(definition) + "_melee": melee.id}
						var legal: bool = i == 0 or (melee.id == "chainsword" and (pistol.id in ["heavy-bolt-pistol", "plasma-pistol"] if definition == S.JUMP else pistol.id == "bolt-pistol"))
						check(E.valid_saved_loadout(definition, loadout, models) == legal, "Every package on every model respects its source role")
						if legal:
							var unit := {}
							E.prepare(unit, definition, loadout[i], models, i)
							var expected := {"ranged": [P.jump_pack_pistol(pistol.id)], "melee": [P.jump_pack_sergeant_melee(melee.id)]} if definition == S.JUMP else P.blood_claws_pack_leader_weapons(pistol.id, melee.id) if definition == S.BLOOD else P.grey_hunters_pack_leader_weapons(pistol.id, melee.id)
							check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and bool(unit.sergeant) == (i == 0), "Exact source inventories and stable leader role apply to every valid package")
			var invalid := E.defaults(definition)
			invalid.extra = true
			check(not E.valid(definition, invalid, models), "Extra fields are rejected")
			invalid = E.defaults(definition)
			invalid[S.prefix(definition) + "_pistol"] = true
			check(not E.valid(definition, invalid, models) and not E.valid_saved_loadout(definition, [], models), "Wrong types and incomplete records are rejected")
func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, S.JUMP, 5, 1), entry(catalog, S.JUMP, 10, 1), entry(catalog, S.BLOOD, 10, 2), entry(catalog, S.BLOOD, 20, 1), entry(catalog, S.GREY, 10, 2)]
	for item: Dictionary in army.entries:
		var definition := str(item.unit_id)
		for copy_index in range(int(item.copies)):
			check(R.set_model_equipment(item, copy_index, 0, S.prefix(definition) + "_pistol", "plasma-pistol"), "Each saved leader has an independent pistol")
			check(R.set_model_equipment(item, copy_index, 0, S.prefix(definition) + "_melee", "power-weapon" if definition == S.BLOOD or copy_index == 1 else "power-fist"), "Each saved leader has an independent melee weapon")
			if definition == S.JUMP:
				for i in range(1, int(item.models) / 5 + 1): check(R.set_model_equipment(item, copy_index, i, "jump_intercessor_pistol", "plasma-pistol"), "Ordinary Plasma slots are independent of Sergeant Plasma")
	return army
func inspect_bank(army: Dictionary) -> void:
	var report := Training.admit_current_catalog(army)
	check(R.validate(army).is_empty() and report.error.is_empty(), "Saved mixed squad army passes existing catalog gates")
	check(int(report.get("total", 0)) == 1235 and R.summary(army).points == 1235, "Free source options preserve the exact 1235-point army")
	for item: Dictionary in army.entries:
		for copy_index in range(int(item.copies)):
			check(R.model_equipment(item, copy_index, 0)[S.prefix(str(item.unit_id)) + "_pistol"] == "plasma-pistol", "All leaders retain saved pistols after restart")
			check(E.valid_saved_loadout(str(item.unit_id), R.model_equipment_loadouts(item, copy_index), int(item.models)), "Complete copy records remain legal after restart")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Another process reopens bank")
		if store.error.is_empty() and store.active().lists.size() == 1: inspect_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	matrices()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	var army := make_army(catalog)
	inspect_bank(army)
	var before: Dictionary = army.entries[0].duplicate(true)
	check(not R.set_model_equipment(army.entries[0], 0, 2, "jump_intercessor_pistol", "plasma-pistol") and army.entries[0] == before, "Over-cap Plasma edit is rejected atomically")
	before = army.entries[2].duplicate(true)
	check(not R.set_model_equipment(army.entries[2], 0, 1, "blood_claws_pack_leader_melee", "power-weapon") and army.entries[2] == before, "Ordinary Blood Claw cannot take leader melee")
	var path := ProjectSettings.globalize_path("user://sergeant-squads-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Bank saves without optional assets")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_sergeant_squad_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Second process validates saved packages: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both complete armies materialize: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Saved stable identities resolve")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1235 and int(state.training_points[owner]) == 1235, "Materialized squad prices sum to canonical total")
					for item: Dictionary in army.entries:
						for copy_index in range(int(item.copies)):
							for i in range(int(item.models)):
								var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, i)]
								var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
								var equipment := R.model_equipment(item, copy_index, i)
								var expected := {}
								E.prepare(expected, str(item.unit_id), equipment, int(item.models), i)
								var unit: Dictionary = state.units[model]
								check(unit.saved_model_equipment == equipment and unit.ranged_weapons == expected.ranged_weapons and unit.melee_weapons == expected.melee_weapons and unit.sergeant == (i == 0), "Frozen weapons and leader identity match the stable saved model")
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(c: Dictionary) -> bool: return c.action in LOCKED), "Readiness omits all saved equipment decisions")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1: continue
				var action := "jump-pack-sergeant-melee" if unit.sergeant else "jump-pack-trooper-pistol"
				if unit.definition_id == S.BLOOD: action = "blood-claws-pack-leader-pistol"
				if unit.definition_id == S.GREY: action = "grey-hunters-pack-leader-melee"
				before = state.duplicate(true)
				var result := Actions.apply(state, 1, {"action": action, "model": model, "target": int(unit.squad), "value": "plasma-pistol"}, Vector2.ZERO, func() -> int: return 1)
				check(str(result.get("error", "")).contains("Saved squad equipment") and state == before, "Forced equipment mutation returns saved lock without changing state")
			var split := state.duplicate(true)
			for squad: int in state.squads:
				var selected: Array[int] = []
				for model: int in state.units:
					if int(state.units[model].squad) == squad and state.units[model].definition_id == S.GREY and selected.size() < 5: selected.append(model)
				if selected.size() == 5: check(Actions._split_grey_hunters(split, squad, selected).is_empty(), "Old Greymanes remains a live formation decision")
			for model: int in state.units: check(split.units[model].ranged_weapons == state.units[model].ranged_weapons and split.units[model].melee_weapons == state.units[model].melee_weapons, "Old Greymanes preserves leader and troop saved inventories")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Frozen match saves")
			check(R.set_model_equipment(saved.list.entries[0], 0, 0, "jump_intercessor_pistol", "heavy-bolt-pistol") and store.save_list(saved.list).error.is_empty(), "Source leader can change after match save")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Source army edits cannot change a saved match")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(army.entries.size()):
		panel._select_entry(index)
		var item: Dictionary = army.entries[index]
		check(panel.per_model_equipment_controls.get_child_count() == int(item.models), "Native row for every stable model")
		for i in range(1, int(item.models)):
			var row := panel.per_model_equipment_controls.get_child(i)
			check((row.get_child(4) as OptionButton).disabled, "Troop Chainsword is fixed")
			check((row.get_child(2) as OptionButton).disabled == (item.unit_id != S.JUMP), "Only ordinary Jump Intercessors have pistol choices")
		check(panel._similar_visual_model_indices(item, 0, 0).is_empty(), "Appearance sharing keeps the sole leader separate from ordinary troops")
	panel._select_entry(0)
	before = panel.draft.duplicate(true)
	var picker := panel.per_model_equipment_controls.get_child(2).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.draft == before and (panel.per_model_equipment_controls.get_child(2).get_child(2) as OptionButton).selected == 0, "Real over-cap Plasma signal restores control and preserves draft")
	picker = panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
	picker.select(1)
	picker.item_selected.emit(1)
	check(panel.dirty and R.model_equipment(panel.draft.entries[0], 0, 0).jump_intercessor_pistol == "hand-flamer" and R.summary(panel.draft).points == 1235, "Real Sergeant signal saves free Hand Flamer without changing points")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Sergeant squad saved equipment: %d failures" % failures)
	quit(1 if failures else 0)
