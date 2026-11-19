extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Adapter = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
var failures := 0
var variants := {
	Adapter.EXECRATOR: [
		{"execrator_pistol_package": "absolvor-bolt-pistol", "execrator_mastercrafted_power_weapon": false},
		{"execrator_pistol_package": "absolvor-bolt-pistol", "execrator_mastercrafted_power_weapon": true},
		{"execrator_pistol_package": "hand-flamer", "execrator_mastercrafted_power_weapon": false}],
	Adapter.PHOBOS_LIEUTENANT: [{"phobos_carbine": false}, {"phobos_carbine": true}],
	Adapter.TERMINATOR_CHAPLAIN: [{"terminator_chaplain_relic_shield": false}, {"terminator_chaplain_relic_shield": true}],
	Adapter.RAPIER_CARRIER: [{"rapier_carrier_primary": "quad-heavy-bolter"}, {"rapier_carrier_primary": "graviton-cannon"}, {"rapier_carrier_primary": "laser-destroyer"}, {"rapier_carrier_primary": "quad-launcher"}]
}
const EQUIPMENT_ACTIONS := ["execrator-pistol-loadout", "execrator-extra-melee", "phobos-lieutenant-gun", "terminator-chaplain-shield", "rapier-carrier-loadout"]

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func expected(definition: String, equipment: Dictionary) -> Dictionary:
	match definition:
		Adapter.EXECRATOR: return Marines.execrator_weapons(str(equipment.execrator_pistol_package), bool(equipment.execrator_mastercrafted_power_weapon))
		Adapter.PHOBOS_LIEUTENANT: return {"ranged": Marines.phobos_lieutenant_gun(bool(equipment.phobos_carbine)), "melee": Marines.profile("lieutenant-in-phobos-armour").melee}
		Adapter.TERMINATOR_CHAPLAIN: return {"ranged": [] if equipment.terminator_chaplain_relic_shield else Marines.profile("chaplain-in-terminator-armour").ranged, "melee": Marines.profile("chaplain-in-terminator-armour").melee}
		Adapter.RAPIER_CARRIER: return Marines.rapier_carrier_weapons(str(equipment.rapier_carrier_primary))
	return {}

func check_weapons(unit: Dictionary, definition: String, equipment: Dictionary) -> void:
	var weapons := expected(definition, equipment)
	check(unit.ranged_weapons == weapons.ranged and unit.melee_weapons == weapons.melee, "Exact saved weapons materialize for " + definition)
	if definition == Adapter.TERMINATOR_CHAPLAIN:
		check(int(unit.max_wounds) == (6 if equipment.terminator_chaplain_relic_shield else 5), "Relic Shield replaces the bolter and adds exactly one Wound")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Profiles.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "Separate process reopens the army bank")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1:
			var army: Dictionary = reopened.active().lists[0]
			check(army.entries.size() == 4 and Training.admit_current_catalog(army).error.is_empty(), "Reopened mixed army retains valid current-catalog choices")
			for entry: Dictionary in army.entries:
				var definition := str(entry.unit_id)
				check(Roster.model_equipment(entry, 0, 0) == variants[definition][0] and Roster.model_equipment(entry, 1, 0) == variants[definition][-1], "Both independent copies survive disk restart: " + definition)
		print("Character/artillery separate-process checks: %d failures" % failures)
		quit(1 if failures else 0)
		return
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Current consolidated catalog opens offline")
	var army := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	for definition: String in variants:
		for equipment: Dictionary in variants[definition]:
			check(Adapter.valid(definition, equipment, 1), "Every source-listed package has a typed saved schema")
			var unit := {"max_wounds": 5, "wounds": 5}
			Adapter.prepare(unit, definition, equipment)
			check_weapons(unit, definition, equipment)
			if definition == Adapter.TERMINATOR_CHAPLAIN:
				Adapter.prepare(unit, definition, equipment)
				check_weapons(unit, definition, equipment)
		var item := Roster.entry(catalog.lookup(definition), 0, 2)
		for field: String in variants[definition][-1]:
			check(Roster.set_model_equipment(item, 1, 0, field, variants[definition][-1][field]), "Second copy stores its independent choice")
		army.entries.append(item)
		var bad: Dictionary = variants[definition][0].duplicate(true)
		bad.unlisted = true
		check(not Adapter.valid(definition, bad, 1), "Unknown saved fields fail closed")
		check(not Adapter.valid(definition, variants[definition][0], 2), "One-model schema cannot be used as a squad-wide choice")
	check(not Adapter.valid(Adapter.EXECRATOR, {"execrator_pistol_package": "hand-flamer", "execrator_mastercrafted_power_weapon": true}, 1), "Hand Flamer cannot coexist with the conditional extra Power Weapon")
	check(not Adapter.valid(Adapter.TERMINATOR_CHAPLAIN, {"terminator_chaplain_relic_shield": "true"}, 1), "Shield requires a boolean")
	check(not Adapter.valid(Adapter.RAPIER_CARRIER, {"rapier_carrier_primary": "unknown"}, 1), "Unknown artillery packages fail closed")
	var path := ProjectSettings.globalize_path("user://character-artillery-%d.json" % OS.get_process_id())
	var store := Profiles.new(path)
	var saved := store.save_list(army)
	check(str(saved.get("error", "")).is_empty(), "Mixed character/artillery list saves without asset preparation")
	if not str(saved.get("error", "")).is_empty():
		catalog.free()
		quit(1)
		return
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_character_artillery_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Another Godot process verifies the saved choices: " + str(output))
	var admission := Training.admit_current_catalog(saved.list)
	check(admission.error.is_empty(), "Mixed saved list passes source-bounded local admission: " + str(admission.error))
	if admission.error.is_empty():
		var state := Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, {1: admission.selection, 2: admission.selection})
		check(not state.has("error"), "Both players materialize all independent saved copies")
		if not state.has("error"):
			var seen := {}
			for model_id: int in state.units:
				var unit: Dictionary = state.units[model_id]
				var definition := str(unit.get("definition_id", ""))
				if not variants.has(definition): continue
				check_weapons(unit, definition, unit.saved_model_equipment)
				var key := str(unit.owner) + ":" + definition
				if not seen.has(key): seen[key] = []
				seen[key].append(unit.saved_model_equipment)
			for owner in [1, 2]:
				for definition: String in variants:
					var loadouts: Array = seen.get(str(owner) + ":" + definition, [])
					check(loadouts.size() == 2 and loadouts.has(variants[definition][0]) and loadouts.has(variants[definition][-1]), "Each player retains one default and one configured copy")
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) in EQUIPMENT_ACTIONS), "Saved loadouts suppress duplicate preparation choices")
			for model_id: int in state.units:
				var unit: Dictionary = state.units[model_id]
				if int(unit.owner) != 1: continue
				var definition := str(unit.get("definition_id", ""))
				var action := "execrator-pistol-loadout" if definition == Adapter.EXECRATOR else "phobos-lieutenant-gun" if definition == Adapter.PHOBOS_LIEUTENANT else "terminator-chaplain-shield" if definition == Adapter.TERMINATOR_CHAPLAIN else "rapier-carrier-loadout"
				var value := "hand-flamer" if definition == Adapter.EXECRATOR else "carbine" if definition == Adapter.PHOBOS_LIEUTENANT else "shield" if definition == Adapter.TERMINATOR_CHAPLAIN else "laser-destroyer"
				var before: Dictionary = state.duplicate(true)
				var result := Actions.apply(state, 1, {"action": action, "model": model_id, "target": 0 if definition == Adapter.RAPIER_CARRIER else int(unit.squad), "value": value}, Vector2.ZERO, func() -> int: return 1)
				check(not str(result.get("error", "")).is_empty() and state == before, "Forced equipment changes fail without mutating frozen rules state")
			var frozen: Dictionary = state.saved_army_setup.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Match snapshot writes independently of its source army")
			Roster.set_model_equipment(saved.list.entries[1], 0, 0, "phobos_carbine", true)
			check(store.save_list(saved.list).error.is_empty(), "Source army may be edited after match creation")
			var restored := Save.read(path + ".match")
			check(not restored.has("error") and restored.state.saved_army_setup == frozen, "Later source edits leave frozen mixed-army equipment unchanged")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for entry_index in range(army.entries.size()):
		panel._select_entry(entry_index)
		var definition := str(army.entries[entry_index].unit_id)
		var descriptors := Adapter.controls(definition)
		check(panel.per_model_equipment_controls.get_child_count() == descriptors.size() * 2, "Workshop exposes every saved option group for " + definition)
		if panel.per_model_equipment_controls.get_child_count() < 2: continue
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		var option_index := picker.item_count - 1
		var field := str(descriptors[0].field)
		var value: Variant = picker.get_item_metadata(option_index)
		picker.select(option_index)
		picker.item_selected.emit(option_index)
		check(panel.dirty and Roster.model_equipment(panel.draft.entries[entry_index], 0, 0).get(field) == value, "Actual Workshop signal edits the selected copy: " + definition)
		if definition == Adapter.EXECRATOR:
			var before: Dictionary = panel.draft.duplicate(true)
			var power_picker := panel.per_model_equipment_controls.get_child(3) as OptionButton
			power_picker.select(1)
			power_picker.item_selected.emit(1)
			check(panel.draft == before and "source-listed limit" in panel.notice.text, "Conflicting Execrator option preserves the draft and explains rejection")
			var restored_picker := panel.per_model_equipment_controls.get_child(3) as OptionButton
			check(restored_picker.get_selected_metadata() == false, "Rejected option returns its control to the actual saved draft value")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Character/artillery saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)
