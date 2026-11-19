extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Adapter = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const IDS := [Adapter.REDEMPTOR, Adapter.CENTURION_ASSAULT, Adapter.CENTURION_DEVASTATOR, Adapter.WOLF_GUARD_BATTLE_LEADER]
const LOCKED_ACTIONS := ["redemptor-fragstorm", "redemptor-auxiliary", "redemptor-main", "redemptor-icarus", "centurion-assault-loadout", "centurion-devastator-loadout", "wolf-guard-battle-leader-ranged", "wolf-guard-battle-leader-melee"]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func packages(definition: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if definition == Adapter.REDEMPTOR:
		for mask in range(16):
			result.append({"redemptor_fragstorm": (mask & 1) == 0, "redemptor_heavy_flamer": (mask & 2) == 0, "redemptor_macro_plasma": (mask & 4) != 0, "redemptor_icarus": (mask & 8) != 0})
	elif definition == Adapter.CENTURION_ASSAULT:
		for mask in range(4): result.append({"centurion_assault_launcher": (mask & 1) != 0, "centurion_twin_meltagun": (mask & 2) != 0})
	elif definition == Adapter.CENTURION_DEVASTATOR:
		for bolters in ["centurion-bolters", "centurion-missile-launcher"]:
			for support in ["grav-cannon", "twin-heavy-bolter", "twin-lascannon"]:
				result.append({"centurion_devastator_bolters": bolters, "centurion_devastator_support": support})
	else:
		for ranged in ["plasma-pistol", "storm-shield"]:
			for melee in ["master-crafted-power-weapon", "thunder-hammer"]:
				result.append({"wolf_guard_battle_leader_ranged_loadout": ranged, "wolf_guard_battle_leader_melee_loadout": melee})
	return result

func entry(catalog: Node, definition: String, models: int, copies: int) -> Dictionary:
	var choice: Dictionary = catalog.lookup(definition)
	for index in range(choice.options.size()):
		if int(choice.options[index].models) == models: return Roster.entry(choice, index, copies)
	check(false, "Source-priced model count exists for " + definition)
	return {}

func configure(item: Dictionary, copy_index: int, model_index: int, equipment: Dictionary) -> void:
	for field: String in equipment:
		check(Roster.set_model_equipment(item, copy_index, model_index, field, equipment[field]), "Typed saved choice accepts a legal source option")

func inspect_unit(unit: Dictionary, definition: String, equipment: Dictionary) -> void:
	var expected: Dictionary = {}
	match definition:
		Adapter.REDEMPTOR:
			expected = {"ranged": Marines.redemptor_weapons(equipment.redemptor_fragstorm, equipment.redemptor_heavy_flamer, equipment.redemptor_macro_plasma, equipment.redemptor_icarus), "melee": Marines.profile("redemptor-dreadnought").melee}
		Adapter.CENTURION_ASSAULT:
			expected = Marines.centurion_assault_weapons(equipment.centurion_assault_launcher, equipment.centurion_twin_meltagun)
			check(("EXPLOSIVES" in unit.get("keywords", [])) == bool(equipment.centurion_assault_launcher), "Only the launcher bearer gains EXPLOSIVES")
		Adapter.CENTURION_DEVASTATOR:
			expected = Marines.centurion_devastator_weapons(equipment.centurion_devastator_bolters, equipment.centurion_devastator_support)
		Adapter.WOLF_GUARD_BATTLE_LEADER:
			expected = Marines.wolf_guard_battle_leader_weapons(equipment.wolf_guard_battle_leader_ranged_loadout, equipment.wolf_guard_battle_leader_melee_loadout)
			check(int(unit.max_wounds) == (6 if equipment.wolf_guard_battle_leader_ranged_loadout == "storm-shield" else 5), "Storm Shield adds exactly one bearer Wound")
	check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee, "Exact source weapon package survives materialization: " + definition)

func make_army(catalog: Node) -> Dictionary:
	var army := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	for definition: String in IDS:
		var models := 3 if definition == Adapter.CENTURION_ASSAULT else 6 if definition == Adapter.CENTURION_DEVASTATOR else 1
		var copies := 3 if definition == Adapter.REDEMPTOR else 2
		var item := entry(catalog, definition, models, copies)
		var choices := packages(definition)
		for copy_index in range(copies):
			for model_index in range(models):
				var option_index := (copy_index + model_index) % choices.size() if models > 1 else (0 if copy_index == 0 else 4 if definition == Adapter.REDEMPTOR and copy_index == 1 else choices.size() - 1)
				configure(item, copy_index, model_index, choices[option_index])
		army.entries.append(item)
	var atvs := entry(catalog, "40kdc:11e:adeptus-astartes:invader-atvs", 1, 3)
	check(Roster.set_model_equipment(atvs, 0, 0, "invader_atv_multi_melta", true), "Existing ATV surcharge remains selectable")
	army.entries.append(atvs)
	return army

func check_bank(army: Dictionary) -> void:
	check(army.entries.size() == 5, "Mixed army retains every source entry")
	var admitted := Training.admit_current_catalog(army)
	check(admitted.error.is_empty() and int(admitted.get("total", 0)) == 1920 and Roster.summary(army).points == 1920, "Disk round trip preserves tiers, Macro Plasma and existing ATV surcharge")
	for item: Dictionary in army.entries:
		if str(item.unit_id) not in IDS: continue
		check(item.copy_instance_ids[0] != item.copy_instance_ids[1], "Independent stable copies survive")
		if int(item.models) > 1:
			check(Roster.model_equipment(item, 0, 0) != Roster.model_equipment(item, 0, 1) and Roster.model_equipment(item, 0, 1) != Roster.model_equipment(item, 0, 2), "Three models retain independent saved loadout records")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate process reopens the bank")
		if store.error.is_empty() and store.active().lists.size() == 1: check_bank(store.active().lists[0])
		print("Heavy saved-loadout restart: %d failures" % failures)
		quit(1 if failures else 0)
		return
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated current catalog opens offline")
	for definition: String in IDS:
		var models := 3 if Adapter.is_model_scoped(definition) else 1
		for equipment: Dictionary in packages(definition):
			check(Adapter.valid(definition, equipment, models), "All 16/4/6/4 source packages have strict schemas")
			var unit := {"keywords": [], "max_wounds": 5, "wounds": 5}
			Adapter.prepare(unit, definition, equipment)
			inspect_unit(unit, definition, equipment)
			Adapter.prepare(unit, definition, equipment)
			inspect_unit(unit, definition, equipment)
		if Adapter.is_model_scoped(definition):
			for size in [3, 6]:
				var loadout: Array = []
				for model_index in range(size): loadout.append(packages(definition)[model_index % packages(definition).size()])
				check(Adapter.valid_saved_loadout(definition, loadout, size), "Both source-priced Centurion sizes accept mixed model options")
			check(not Adapter.valid_saved_loadout(definition, [], 0) and not Adapter.valid(definition, Adapter.defaults(definition), 4), "Unpriced and empty Centurion compositions fail closed")
	check(not Adapter.valid(Adapter.REDEMPTOR, {"redemptor_fragstorm": true, "redemptor_heavy_flamer": true, "redemptor_macro_plasma": "true", "redemptor_icarus": false}, 1), "Macro Plasma is a typed boolean")
	var army := make_army(catalog)
	check_bank(army)
	var budget_army := Roster.new_list("11e", "Space Marines", "custom", 340)
	budget_army.entries.append(entry(catalog, Adapter.REDEMPTOR, 1, 2))
	check(Training.admit_current_catalog(budget_army).error.is_empty(), "Two default Redemptors fit the exact base-price budget")
	check(Roster.set_model_equipment(budget_army.entries[0], 0, 0, "redemptor_macro_plasma", true), "Priced replacement is a valid option")
	check(Roster.summary(budget_army).points == 350 and not Training.admit_current_catalog(budget_army).error.is_empty(), "Macro Plasma adds ten points and cannot bypass the budget")
	var path := ProjectSettings.globalize_path("user://heavy-loadouts-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(str(saved.get("error", "")).is_empty(), "Mixed saved army writes before optional asset preparation")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_heavy_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Separate Godot process validates the complete saved army: " + str(output))
	var admitted := Training.admit_current_catalog(army)
	if admitted.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}}, {1: admitted.selection, 2: admitted.selection})
		check(not state.has("error"), "Saved mixed army materializes for both players: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, admitted.selection)
			check(refs.error.is_empty(), "Stable model IDs map to frozen canonical positions")
			if refs.error.is_empty():
				for owner in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1920 and int(state.training_points[owner]) == 1920, "Every materialized copy cost sums to the admitted army total")
					for item: Dictionary in army.entries:
						if str(item.unit_id) not in IDS: continue
						for copy_index in range(int(item.copies)):
							for model_index in range(int(item.models)):
								var ref: Dictionary = refs.models[Roster.model_instance_id(item, copy_index, model_index)]
								var unit: Dictionary = state.units[(owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)]
								var equipment := Roster.model_equipment(item, copy_index, model_index)
								check(unit.saved_model_equipment == equipment, "Frozen model identity keeps its exact equipment")
								inspect_unit(unit, str(item.unit_id), equipment)
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in LOCKED_ACTIONS), "No persistent choices repeat during readiness")
			for model_id: int in state.units:
				var unit: Dictionary = state.units[model_id]
				var definition := str(unit.get("definition_id", ""))
				if int(unit.owner) != 1 or definition not in IDS: continue
				var action := "redemptor-main" if definition == Adapter.REDEMPTOR else "centurion-assault-loadout" if definition == Adapter.CENTURION_ASSAULT else "centurion-devastator-loadout" if definition == Adapter.CENTURION_DEVASTATOR else "wolf-guard-battle-leader-ranged"
				var value := "macro-plasma" if not bool(unit.get("redemptor_macro_plasma", false)) else "heavy-onslaught"
				if definition == Adapter.CENTURION_ASSAULT: value = "centurion-bolters" if bool(unit.centurion_assault_launcher) else "centurion-assault-launcher"
				if definition == Adapter.CENTURION_DEVASTATOR: value = "centurion-missile-launcher" if str(unit.centurion_devastator_bolters) == "centurion-bolters" else "centurion-bolters"
				if definition == Adapter.WOLF_GUARD_BATTLE_LEADER: value = "storm-shield" if str(unit.wolf_guard_battle_leader_ranged_loadout) == "plasma-pistol" else "plasma-pistol"
				var before := state.duplicate(true)
				var target := 0 if Adapter.is_model_scoped(definition) else int(unit.squad)
				var rejected := Actions.apply(state, 1, {"action": action, "model": model_id, "target": target, "value": value}, Vector2.ZERO, func() -> int: return 1)
				check(not str(rejected.get("error", "")).is_empty() and state == before, "Forced reconfiguration cannot alter saved weapons, keywords, wounds or costs")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Priced mixed-army match writes")
			check(Roster.set_model_equipment(saved.list.entries[0], 0, 0, "redemptor_macro_plasma", true) and store.save_list(saved.list).error.is_empty(), "Source army may change its priced weapon later")
			var restored := Save.read(path + ".match")
			check(not restored.has("error") and restored.state == frozen, "Match costs and model equipment remain frozen after later source edits")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.per_model_equipment_controls.get_child_count() == 8, "Workshop exposes all four Redemptor controls")
	if panel.per_model_equipment_controls.get_child_count() == 8:
		var picker := panel.per_model_equipment_controls.get_child(5) as OptionButton
		picker.select(1)
		picker.item_selected.emit(1)
		check(panel.dirty and Roster.summary(panel.draft).points == 1930, "Real Macro Plasma selector updates draft points by ten")
	for entry_index in [1, 2]:
		panel._select_entry(entry_index)
		check(panel.per_model_equipment_controls.get_child_count() == int(army.entries[entry_index].models), "Workshop exposes an independent row for every Centurion model")
		for row: Node in panel.per_model_equipment_controls.get_children():
			check(row.get_child_count() == 5 and row.get_child(2) is OptionButton and row.get_child(4) is OptionButton, "Each model row exposes its two source option groups")
		if panel.per_model_equipment_controls.get_child_count() > 0:
			var before := Roster.model_equipment(panel.draft.entries[entry_index], 0, 1).duplicate(true)
			var picker := panel.per_model_equipment_controls.get_child(0).get_child(2) as OptionButton
			var option_index := picker.item_count - 1
			var value: Variant = picker.get_item_metadata(option_index)
			picker.select(option_index)
			picker.item_selected.emit(option_index)
			var field := "centurion_assault_launcher" if entry_index == 1 else "centurion_devastator_bolters"
			check(Roster.model_equipment(panel.draft.entries[entry_index], 0, 0).get(field) == value and Roster.model_equipment(panel.draft.entries[entry_index], 0, 1) == before, "Real model selector updates only its stable miniature")
	panel._select_entry(3)
	if panel.per_model_equipment_controls.get_child_count() == 4:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(1)
		picker.item_selected.emit(1)
		check(Roster.model_equipment(panel.draft.entries[3], 0, 0).wolf_guard_battle_leader_ranged_loadout == "storm-shield" and Roster.summary(panel.draft).points == 1930, "Storm Shield selector retains the source's zero-point replacement cost")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Heavy saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)
