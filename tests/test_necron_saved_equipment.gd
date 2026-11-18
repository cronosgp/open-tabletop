extends SceneTree

const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const ArmyProfiles = preload("res://scripts/army_profiles.gd")

const LOKHUST_HEAVY := "40kdc:11e:necrons:lokhust-heavy-destroyers"
const PRAETORIANS := "40kdc:11e:necrons:triarch-praetorians"
const STALKER := "40kdc:11e:necrons:triarch-stalker"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		check_reopened_profile(args[1])
		print("Separate process reopened the mixed Necron saved equipment profile")
		quit(1 if failures else 0)
		return
	check_source_schemas()
	var list := _configured_list()
	check(Roster.validate(list).is_empty(), "Source-listed Necron equipment passes saved-roster validation")
	check(_json_round_trip_preserves(list), "Saved Necron per-model records survive the army-list JSON round trip")
	check_disk_reopen(list)
	check_workshop_controls(list)
	check_prepared_match(list)
	print("Necron saved-equipment checks: %d failures" % failures)
	await process_frame
	quit(1 if failures else 0)

func check_source_schemas() -> void:
	check(SavedEquipment.supports(LOKHUST_HEAVY) and SavedEquipment.is_model_scoped(LOKHUST_HEAVY), "Lokhust Heavy Destroyer replacements are saved independently per model")
	check(SavedEquipment.supports(PRAETORIANS) and SavedEquipment.is_model_scoped(PRAETORIANS), "Triarch Praetorian weapon packages are saved independently per model")
	check(SavedEquipment.supports(STALKER) and not SavedEquipment.is_model_scoped(STALKER), "The one-model Triarch Stalker keeps one weapon selection for its copy")
	check(SavedEquipment.controls(LOKHUST_HEAVY)[0].get("choices", []).map(func(choice: Dictionary) -> String: return str(choice.id)) == ["gauss-destructor", "enmitic-exterminator"], "Lokhust Heavy choices match the local source options")
	check(SavedEquipment.controls(PRAETORIANS)[0].get("choices", []).map(func(choice: Dictionary) -> String: return str(choice.id)) == ["rod-of-covenant", "particle-caster-voidblade"], "Praetorian replacements preserve the linked ranged/melee package")
	check(SavedEquipment.controls(STALKER)[0].get("choices", []).map(func(choice: Dictionary) -> String: return str(choice.id)) == ["heat-ray", "particle-shredder", "heavy-gauss-cannon-array"], "Stalker choices match the heat-ray replacement row")
	check(SavedEquipment.valid(LOKHUST_HEAVY, {"lokhust_heavy_weapon": "enmitic-exterminator"}, 3)
		and not SavedEquipment.valid(LOKHUST_HEAVY, {"lokhust_heavy_weapon": "invented"}, 3)
		and not SavedEquipment.valid(PRAETORIANS, {"triarch_praetorian_weapon_package": "particle-caster-voidblade", "extra": true}, 5)
		and not SavedEquipment.valid(STALKER, {"triarch_stalker_weapon": "heat-ray"}, 2), "Saved weapon validation rejects invented fields, choices and unsupported sizes")
	var praetorian_defaults: Array = []
	for model_index in range(5): praetorian_defaults.append(SavedEquipment.defaults_for_model(PRAETORIANS, 5, model_index))
	check(SavedEquipment.valid_saved_loadout(PRAETORIANS, praetorian_defaults, 5), "A complete five-model default package passes model-scoped validation")
	check(not SavedEquipment.valid_saved_loadout(PRAETORIANS, praetorian_defaults.slice(0, 4), 5), "A partial model list cannot pass saved-equipment validation")
	check(Profiles.profile("triarch-praetorians").get("source_options", [])[0].get("implemented", false)
		and Profiles.profile("triarch-stalker").get("source_options", [])[0].get("implemented", false), "The current Necron profile marks both newly saved source choices implemented")

func _configured_list() -> Dictionary:
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local 11th-edition catalog loads")
	var list := Roster.new_list("11e", "Necrons", "custom", 1000)
	var heavy_choice := Army.current_catalog_choice({"id": LOKHUST_HEAVY, "edition": "11e", "faction": "Necrons"})
	heavy_choice.role = Roster.role(heavy_choice.get("keywords", []))
	var heavy_entry: Dictionary = Roster.entry(heavy_choice, _option_index(heavy_choice, 3), 2)
	check(Roster.set_model_equipment(heavy_entry, 0, 0, "lokhust_heavy_weapon", "enmitic-exterminator")
		and Roster.set_model_equipment(heavy_entry, 0, 2, "lokhust_heavy_weapon", "enmitic-exterminator"), "The first Lokhust Heavy copy can mix two per-model replacements")
	list.entries.append(heavy_entry)
	var praetorian_choice := Army.current_catalog_choice({"id": PRAETORIANS, "edition": "11e", "faction": "Necrons"})
	praetorian_choice.role = Roster.role(praetorian_choice.get("keywords", []))
	var praetorian_entry: Dictionary = Roster.entry(praetorian_choice, _option_index(praetorian_choice, 5), 1)
	check(Roster.set_model_equipment(praetorian_entry, 0, 1, "triarch_praetorian_weapon_package", "particle-caster-voidblade"), "A single Praetorian can take the linked replacement package")
	list.entries.append(praetorian_entry)
	var stalker_choice := Army.current_catalog_choice({"id": STALKER, "edition": "11e", "faction": "Necrons"})
	stalker_choice.role = Roster.role(stalker_choice.get("keywords", []))
	var stalker_entry: Dictionary = Roster.entry(stalker_choice, _option_index(stalker_choice, 1), 1)
	check(Roster.set_model_equipment(stalker_entry, 0, 0, "triarch_stalker_weapon", "heavy-gauss-cannon-array"), "The Stalker can save its locally listed weapon replacement")
	list.entries.append(stalker_entry)
	catalog.free()
	return list

func _option_index(choice: Dictionary, models: int) -> int:
	var options: Array = choice.get("options", [])
	for index in range(options.size()):
		if int(options[index].get("models", 0)) == models: return index
	return -1

func _json_round_trip_preserves(list: Dictionary) -> bool:
	var decoded: Variant = JSON.parse_string(JSON.stringify(list))
	return decoded is Dictionary and Roster.validate(decoded).is_empty()

func check_disk_reopen(list: Dictionary) -> void:
	var path := ProjectSettings.globalize_path("user://necron-equipment-restart-%d.json" % OS.get_process_id())
	var store := ArmyProfiles.new(path)
	var saved := store.save_list(list)
	check(saved.get("error", "").is_empty(), "Necron equipment list saves before the separate-process reopen")
	if saved.get("error", "").is_empty():
		var output: Array = []
		var process_result := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"),
			"--script", "res://tests/test_necron_saved_equipment.gd", "--", "--reopen", path], output, true)
		check(process_result == 0, "Necron model equipment survives a separate Godot process reopen: " + "\n".join(output))
	for file_path: String in [path, path + ".bak"]:
		if FileAccess.file_exists(file_path): DirAccess.remove_absolute(file_path)

func check_reopened_profile(path: String) -> void:
	var store := ArmyProfiles.new(path)
	check(store.error.is_empty() and store.active().lists.size() == 1, "The saved Necron list reopens with one complete record")
	if not store.error.is_empty() or store.active().lists.size() != 1: return
	var saved: Dictionary = store.active().lists[0]
	var heavy_entry: Dictionary = saved.entries[0]
	var praetorian_entry: Dictionary = saved.entries[1]
	var stalker_entry: Dictionary = saved.entries[2]
	check(Roster.model_equipment(heavy_entry, 0, 0).get("lokhust_heavy_weapon", "") == "enmitic-exterminator"
		and Roster.model_equipment(heavy_entry, 0, 2).get("lokhust_heavy_weapon", "") == "enmitic-exterminator"
		and Roster.model_equipment(heavy_entry, 1, 0).get("lokhust_heavy_weapon", "") == "gauss-destructor",
		"The reopened Lokhust copies retain their mixed and default per-model choices")
	check(Roster.model_equipment(praetorian_entry, 0, 1).get("triarch_praetorian_weapon_package", "") == "particle-caster-voidblade"
		and Roster.model_equipment(stalker_entry, 0, 0).get("triarch_stalker_weapon", "") == "heavy-gauss-cannon-array",
		"The reopened Praetorian package and Stalker weapon remain independent")
	check(Roster.validate(saved).is_empty() and TrainingRoster.inspect(saved, {}, true).get("error", "").is_empty(),
		"The reopened Necron equipment remains valid for the current local catalog")

func check_workshop_controls(list: Dictionary) -> void:
	var panel := BuilderPanel.new()
	panel.storage_path = "user://necron-saved-equipment-test.json"
	panel.cache_directory = "user://necron-saved-equipment-catalog"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.per_model_equipment_controls.get_child_count() == 3, "The Workshop shows one equipment row for each selected Lokhust Heavy model")
	if panel.per_model_equipment_controls.get_child_count() == 3:
		var first_row := panel.per_model_equipment_controls.get_child(0) as HBoxContainer
		var first_picker := first_row.get_child(2) as OptionButton
		check(first_row.get_child(0).text == "Lokhust Heavy Destroyer 1" and first_picker.get_item_metadata(first_picker.selected) == "enmitic-exterminator", "The selected copy reopens each model row with its saved value and a clear label")
		var second_row := panel.per_model_equipment_controls.get_child(1) as HBoxContainer
		var second_picker := second_row.get_child(2) as OptionButton
		second_picker.select(1)
		second_picker.item_selected.emit(1)
		check(panel.dirty and Roster.model_equipment(panel.draft.entries[0], 0, 1).get("lokhust_heavy_weapon") == "enmitic-exterminator"
			and Roster.model_equipment(panel.draft.entries[0], 0, 2).get("lokhust_heavy_weapon") == "enmitic-exterminator", "The Workshop edits only the selected model and leaves neighboring records unchanged")
		check("Save the army list" in panel.notice.text, "The Workshop explains that a changed draft still needs saving")
	panel._select_entry(1)
	check(panel.per_model_equipment_controls.get_child_count() == 5, "The Workshop presents independent weapon choices for all five Praetorians")
	panel._select_entry(2)
	check(panel.per_model_equipment_controls.get_child_count() == 2
		and panel.per_model_equipment_controls.get_child(1) is OptionButton, "The Stalker presents one saved copy-level weapon control")
	panel.free()

func check_prepared_match(list: Dictionary) -> void:
	var inspected := TrainingRoster.inspect(list, {}, true)
	check(inspected.get("error", "").is_empty(), "Necron equipment records pass current-catalog admission: " + str(inspected.get("error", "")))
	if not inspected.get("error", "").is_empty(): return
	check(int(inspected.get("total", -1)) == 520, "Weapon choices preserve the source-priced total and copy tiers")
	var state: Dictionary = Prepared.initial_state(
		{"checked_rosters": false, "official_mission": false, "unit_abilities": true},
		{1: inspected.selection, 2: inspected.selection})
	check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Both players can prepare from their saved Necron equipment")
	if state.has("error") or not str(state.get("setup_error", "")).is_empty(): return
	var heavy_seen := {0: 0, 1: 0}
	var heavy_alternates_seen := {0: 0, 1: 0}
	var praetorian_seen := {0: 0, 1: 0}
	var stalker_seen := {0: 0, 1: 0}
	for model_id: int in state.units:
		var unit: Dictionary = state.units[model_id]
		var definition := str(unit.get("definition_id", ""))
		var owner := int(unit.get("owner", 0)) - 1
		if owner not in [0, 1]: continue
		if definition == LOKHUST_HEAVY:
			var equipment: Dictionary = unit.get("saved_model_equipment", {})
			var squad_name := str(state.squads[int(unit.get("squad", -1))].get("name", ""))
			var expected := str(equipment.get("lokhust_heavy_weapon", ""))
			var weapon_id := str(unit.get("ranged_weapons", [{}])[0].get("id", ""))
			check(not expected.is_empty() and weapon_id == expected and bool(unit.get("lokhust_heavy_loadout_locked", false)), "Lokhust Heavy saved weapon materializes and locks for " + squad_name)
			if expected == "enmitic-exterminator": heavy_alternates_seen[owner] += 1
			heavy_seen[owner] += 1
		elif definition == PRAETORIANS:
			var equipment: Dictionary = unit.get("saved_model_equipment", {})
			var alternate := str(equipment.get("triarch_praetorian_weapon_package", "")) == "particle-caster-voidblade"
			var ranged_id := str(unit.get("ranged_weapons", [{}])[0].get("id", ""))
			var melee_id := str(unit.get("melee_weapons", [{}])[0].get("id", ""))
			check(ranged_id == ("particle-caster" if alternate else "rod-of-covenant")
				and melee_id == ("voidblade" if alternate else "rod-of-covenant")
				and bool(unit.get("triarch_praetorian_loadout_locked", false)), "Praetorian linked ranged and melee replacements materialize together")
			praetorian_seen[owner] += 1
		elif definition == STALKER:
			var equipment: Dictionary = unit.get("saved_model_equipment", {})
			var weapon_id := str(unit.get("ranged_weapons", [{}])[0].get("id", ""))
			check(weapon_id == str(equipment.get("triarch_stalker_weapon", "")) and bool(unit.get("triarch_stalker_loadout_locked", false)), "The Stalker materializes its saved weapon and locks it for the match")
			stalker_seen[owner] += 1
	check(heavy_seen == {0: 6, 1: 6} and heavy_alternates_seen == {0: 2, 1: 2}
		and praetorian_seen == {0: 5, 1: 5} and stalker_seen == {0: 1, 1: 1}, "Both players receive the complete model inventory with independent saved equipment")
	var frozen_army := JSON.stringify(state.saved_army_setup.armies[1])
	var source_edit_saved := Roster.set_model_equipment(list.entries[0], 0, 0, "lokhust_heavy_weapon", "gauss-destructor")
	var frozen_weapon_preserved := false
	for unit: Dictionary in state.units.values():
		if (
			str(unit.get("definition_id", "")) == LOKHUST_HEAVY
			and int(unit.get("owner", 0)) == 1
			and int(unit.get("saved_equipment_model_index", -1)) == 0
		):
			frozen_weapon_preserved = frozen_weapon_preserved or str(unit.get("ranged_weapons", [{}])[0].get("id", "")) == "enmitic-exterminator"
	check(source_edit_saved and JSON.stringify(state.saved_army_setup.armies[1]) == frozen_army and frozen_weapon_preserved,
		"Editing the source list after match creation leaves the saved Necron setup and applied weapon unchanged")
