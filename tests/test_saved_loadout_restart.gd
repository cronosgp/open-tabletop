extends SceneTree
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Profiles.new(args[1])
		assert(reopened.error.is_empty())
		assert(reopened.active().lists.size() == 1)
		var saved: Dictionary = reopened.active().lists[0]
		assert(Roster.model_equipment(saved.entries[0], 0, 0).predator_destructor_storm_bolter)
		assert(not Roster.model_equipment(saved.entries[0], 1, 0).predator_destructor_storm_bolter)
		assert(saved.entries.size() == 8)
		assert(Roster.model_equipment(saved.entries[1], 0, 0).dreadnought_primary == "heavy-plasma-cannon")
		assert(Roster.model_equipment(saved.entries[1], 0, 0).dreadnought_secondary == "heavy-flamer")
		assert(Roster.model_equipment(saved.entries[1], 1, 0).dreadnought_primary == "assault-cannon")
		assert(Roster.model_equipment(saved.entries[2], 0, 0).sanguinary_guard_inferno_pistol)
		assert(not Roster.model_equipment(saved.entries[2], 0, 1).sanguinary_guard_inferno_pistol)
		assert(not Roster.model_equipment(saved.entries[2], 1, 0).sanguinary_guard_inferno_pistol)
		assert(Roster.model_equipment(saved.entries[2], 1, 1).sanguinary_guard_inferno_pistol)
		assert(Roster.model_equipment(saved.entries[3], 0, 0).death_company_melee_package == "bolt-rifle-fire")
		assert(Roster.model_equipment(saved.entries[3], 0, 0).death_company_pistol_package == "plasma-pistol")
		assert(Roster.model_equipment(saved.entries[3], 0, 0).death_company_grenade_launcher)
		assert(Roster.model_equipment(saved.entries[4], 0, 0).death_company_melee_package == "eviscerator")
		assert(Roster.model_equipment(saved.entries[4], 0, 0).death_company_pistol_package == "inferno-pistol")
		assert(Roster.model_equipment(saved.entries[4], 1, 0).death_company_melee_package == "power-fist")
		assert(Roster.model_equipment(saved.entries[4], 1, 0).death_company_pistol_package == "hand-flamer")
		assert(Roster.model_equipment(saved.entries[5], 0, 0).tarantula_sentry_primary == "twin-heavy-bolter")
		assert(Roster.model_equipment(saved.entries[5], 0, 1).tarantula_sentry_primary == "twin-lascannon")
		assert(Roster.model_equipment(saved.entries[5], 1, 2).tarantula_sentry_primary == "twin-lascannon")
		assert(Roster.model_equipment(saved.entries[5], 2, 0).tarantula_sentry_primary == "twin-heavy-bolter")
		assert(Roster.model_equipment(saved.entries[6], 0, 0).rhino_hunter_killer_missile)
		assert(not Roster.model_equipment(saved.entries[6], 1, 0).rhino_hunter_killer_missile)
		assert(Roster.model_equipment(saved.entries[7], 0, 0).rhino_hunter_killer_missile)
		assert(not Roster.model_equipment(saved.entries[7], 1, 0).rhino_hunter_killer_missile)
		assert(Roster.model_visual_override(saved.entries[0], 0, 0) == "restart-missing-visual")
		assert(Training.admit_current_catalog(saved).error.is_empty())
		var legacy := Profiles.new(args[1] + ".legacy")
		assert(legacy.error.is_empty())
		assert(legacy.active().lists.size() == 4)
		var legacy_list: Dictionary = legacy.active().lists[0]
		var legacy_entry: Dictionary = legacy_list.entries[0]
		assert(legacy_entry.copy_instance_ids.size() == 2)
		assert(str(legacy_entry.copy_instance_ids[0]) != str(legacy_entry.copy_instance_ids[1]))
		assert(Roster.model_visual_override(legacy_entry, 0, 0) == "legacy-restart-sculpt")
		assert(Roster.model_visual_selection_mode(legacy_entry, 0, 0) == "manual")
		assert(Roster.model_visual_selection_mode(legacy_entry, 0, 1) == "auto")
		assert(Roster.unit_visual_variant(legacy_entry, 0) == "legacy-restart-variant")
		assert(Roster.model_visual_override(legacy_entry, 1, 2) == "legacy-second-copy-sculpt")
		assert(Roster.model_visual_selection_mode(legacy_entry, 1, 2) == "manual")
		assert(Roster.model_visual_selection_mode(legacy_entry, 1, 0) == "auto")
		assert(Roster.unit_visual_variant(legacy_entry, 1) == "legacy-second-copy-variant")
		var legacy_necron_list: Dictionary = legacy.active().lists[1]
		assert(legacy_necron_list.faction == "Necrons" and legacy_necron_list.entries.size() == 1)
		var legacy_necron_entry: Dictionary = legacy_necron_list.entries[0]
		assert(legacy_necron_entry.copy_instance_ids.size() == 1)
		assert(Roster.model_visual_override(legacy_necron_entry, 0, 1) == "legacy-necron-sculpt")
		assert(Roster.model_visual_selection_mode(legacy_necron_entry, 0, 1) == "manual")
		assert(Roster.model_visual_selection_mode(legacy_necron_entry, 0, 0) == "auto")
		assert(Roster.unit_visual_variant(legacy_necron_entry, 0) == "legacy-necron-variant")
		var legacy_aggressor_list: Dictionary = legacy.active().lists[2]
		assert(legacy_aggressor_list.faction == "Space Marines" and legacy_aggressor_list.entries.size() == 1)
		var legacy_aggressor_entry: Dictionary = legacy_aggressor_list.entries[0]
		assert(legacy_aggressor_entry.copy_instance_ids.size() == 1)
		assert(Roster.model_visual_override(legacy_aggressor_entry, 0, 1) == "legacy-aggressor-sculpt")
		assert(Roster.model_visual_selection_mode(legacy_aggressor_entry, 0, 1) == "manual")
		assert(Roster.model_visual_selection_mode(legacy_aggressor_entry, 0, 0) == "auto")
		assert(Roster.unit_visual_variant(legacy_aggressor_entry, 0) == "legacy-aggressor-variant")
		var legacy_aggressor_equipment_list: Dictionary = legacy.active().lists[3]
		assert(legacy_aggressor_equipment_list.faction == "Space Marines" and legacy_aggressor_equipment_list.entries.size() == 1)
		var legacy_aggressor_equipment_entry: Dictionary = legacy_aggressor_equipment_list.entries[0]
		assert(str(legacy_aggressor_equipment_entry.copy_instance_ids[0]) == "legacy-aggressor-equipment-copy")
		assert(not legacy_aggressor_equipment_entry.has("unit_equipment_by_copy_id"))
		for model_index in range(3):
			assert(Roster.model_equipment(legacy_aggressor_equipment_entry, 0, model_index).aggressor_boltstorm)
		var migrated_copy_id := str(legacy_entry.copy_instance_ids[0])
		var migrated_second_copy_id := str(legacy_entry.copy_instance_ids[1])
		var migrated_necron_copy_id := str(legacy_necron_entry.copy_instance_ids[0])
		var migrated_aggressor_copy_id := str(legacy_aggressor_entry.copy_instance_ids[0])
		var migrated_aggressor_equipment_copy_id := str(legacy_aggressor_equipment_entry.copy_instance_ids[0])
		assert(legacy.save_list(legacy_list).error.is_empty())
		assert(legacy.save_list(legacy_necron_list).error.is_empty())
		assert(legacy.save_list(legacy_aggressor_list).error.is_empty())
		assert(legacy.save_list(legacy_aggressor_equipment_list).error.is_empty())
		var reopened_legacy := Profiles.new(args[1] + ".legacy")
		assert(reopened_legacy.error.is_empty())
		assert(reopened_legacy.active().lists.size() == 4)
		var reopened_marine_entry: Dictionary = reopened_legacy.active().lists[0].entries[0]
		var reopened_necron_entry: Dictionary = reopened_legacy.active().lists[1].entries[0]
		var reopened_aggressor_entry: Dictionary = reopened_legacy.active().lists[2].entries[0]
		var reopened_aggressor_equipment_entry: Dictionary = reopened_legacy.active().lists[3].entries[0]
		assert(str(reopened_marine_entry.copy_instance_ids[0]) == migrated_copy_id)
		assert(str(reopened_marine_entry.copy_instance_ids[1]) == migrated_second_copy_id)
		assert(Roster.model_visual_override(reopened_marine_entry, 0, 0) == "legacy-restart-sculpt")
		assert(Roster.model_visual_override(reopened_marine_entry, 1, 2) == "legacy-second-copy-sculpt")
		assert(Roster.model_visual_selection_mode(reopened_marine_entry, 1, 2) == "manual")
		assert(Roster.model_visual_selection_mode(reopened_marine_entry, 1, 0) == "auto")
		assert(Roster.unit_visual_variant(reopened_marine_entry, 1) == "legacy-second-copy-variant")
		assert(str(reopened_necron_entry.copy_instance_ids[0]) == migrated_necron_copy_id)
		assert(Roster.model_visual_override(reopened_necron_entry, 0, 1) == "legacy-necron-sculpt")
		assert(Roster.model_visual_selection_mode(reopened_necron_entry, 0, 1) == "manual")
		assert(str(reopened_aggressor_entry.copy_instance_ids[0]) == migrated_aggressor_copy_id)
		assert(Roster.model_visual_override(reopened_aggressor_entry, 0, 1) == "legacy-aggressor-sculpt")
		assert(Roster.model_visual_selection_mode(reopened_aggressor_entry, 0, 1) == "manual")
		assert(Roster.unit_visual_variant(reopened_aggressor_entry, 0) == "legacy-aggressor-variant")
		assert(str(reopened_aggressor_equipment_entry.copy_instance_ids[0]) == migrated_aggressor_equipment_copy_id)
		assert(not reopened_aggressor_equipment_entry.has("unit_equipment_by_copy_id"))
		for model_index in range(3):
			assert(Roster.model_equipment(reopened_aggressor_equipment_entry, 0, model_index).aggressor_boltstorm)
		print("Separate Godot process reopened current mixed equipment and migrated legacy Space Marine multi-copy, Necron, Aggressor and whole-unit Aggressor equipment identities and appearance modes")
		quit()
		return
	var path := ProjectSettings.globalize_path("user://loadout-restart-%d.json" % OS.get_process_id())
	var match_path := path + ".match"
	var catalog := Catalog.new()
	assert(catalog.select_edition("11e").is_empty())
	var list := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	var entry := Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:predator-destructor"), 0, 2)
	Roster.set_model_equipment(entry, 0, 0, "predator_destructor_storm_bolter", true)
	Roster.set_model_visual_override(entry, 0, 0, "restart-missing-visual")
	list.entries.append(entry)
	var dreadnought_entry := Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:dreadnought"), 0, 2)
	Roster.set_model_equipment(dreadnought_entry, 0, 0, "dreadnought_primary", "heavy-plasma-cannon")
	Roster.set_model_equipment(dreadnought_entry, 0, 0, "dreadnought_secondary", "heavy-flamer")
	list.entries.append(dreadnought_entry)
	var guard_choice := catalog.lookup("40kdc:11e:adeptus-astartes:sanguinary-guard")
	var guard_option_index := 0
	for candidate_index in range(guard_choice.options.size()):
		if int(guard_choice.options[candidate_index].get("models", 0)) == 3: guard_option_index = candidate_index
	var guard_entry := Roster.entry(guard_choice, guard_option_index, 2)
	assert(Roster.set_model_equipment(guard_entry, 0, 0, "sanguinary_guard_inferno_pistol", true))
	assert(Roster.set_model_equipment(guard_entry, 1, 1, "sanguinary_guard_inferno_pistol", true))
	list.entries.append(guard_entry)
	var foot_choice := catalog.lookup("40kdc:11e:adeptus-astartes:death-company-marines")
	var foot_option_index := 0
	for candidate_index in range(foot_choice.options.size()):
		if int(foot_choice.options[candidate_index].get("models", 0)) == 5: foot_option_index = candidate_index
	var foot_entry := Roster.entry(foot_choice, foot_option_index, 1)
	assert(Roster.set_model_equipment(foot_entry, 0, 0, "death_company_melee_package", "bolt-rifle-fire"))
	assert(Roster.set_model_equipment(foot_entry, 0, 0, "death_company_pistol_package", "plasma-pistol"))
	assert(Roster.set_model_equipment(foot_entry, 0, 0, "death_company_grenade_launcher", true))
	list.entries.append(foot_entry)
	var jump_choice := catalog.lookup("40kdc:11e:adeptus-astartes:death-company-marines-with-jump-packs")
	var jump_option_index := 0
	for candidate_index in range(jump_choice.options.size()):
		if int(jump_choice.options[candidate_index].get("models", 0)) == 5: jump_option_index = candidate_index
	var jump_entry := Roster.entry(jump_choice, jump_option_index, 2)
	assert(Roster.set_model_equipment(jump_entry, 0, 0, "death_company_melee_package", "eviscerator"))
	assert(Roster.set_model_equipment(jump_entry, 0, 0, "death_company_pistol_package", "inferno-pistol"))
	assert(Roster.set_model_equipment(jump_entry, 1, 0, "death_company_melee_package", "power-fist"))
	assert(Roster.set_model_equipment(jump_entry, 1, 0, "death_company_pistol_package", "hand-flamer"))
	list.entries.append(jump_entry)
	var tarantula_choice := catalog.lookup("40kdc:11e:adeptus-astartes:tarantula-sentry-battery")
	var tarantula_option_index := 0
	for candidate_index in range(tarantula_choice.options.size()):
		if int(tarantula_choice.options[candidate_index].get("models", 0)) == 3: tarantula_option_index = candidate_index
	var tarantula_entry := Roster.entry(tarantula_choice, tarantula_option_index, 3)
	assert(Roster.set_model_equipment(tarantula_entry, 0, 1, "tarantula_sentry_primary", "twin-lascannon"))
	assert(Roster.set_model_equipment(tarantula_entry, 1, 2, "tarantula_sentry_primary", "twin-lascannon"))
	list.entries.append(tarantula_entry)
	var rhino_entry := Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:rhino"), 0, 2)
	assert(Roster.set_model_equipment(rhino_entry, 0, 0, "rhino_hunter_killer_missile", true))
	list.entries.append(rhino_entry)
	var rhino_primaris_entry := Roster.entry(catalog.lookup("40kdc:11e:adeptus-astartes:rhino-primaris"), 0, 2)
	assert(Roster.set_model_equipment(rhino_primaris_entry, 0, 0, "rhino_hunter_killer_missile", true))
	list.entries.append(rhino_primaris_entry)
	var store := Profiles.new(path)
	var written := store.save_list(list)
	assert(written.error.is_empty())
	var legacy_choice := catalog.lookup("40kdc:11e:adeptus-astartes:intercessor-squad")
	var legacy_option_index := 0
	for candidate_index in range(legacy_choice.options.size()):
		if int(legacy_choice.options[candidate_index].get("models", 0)) == 5: legacy_option_index = candidate_index
	var legacy_list := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	legacy_list.id = "legacy-restart-list"
	legacy_list.name = "Legacy restart fixture"
	var legacy_entry := Roster.entry(legacy_choice, legacy_option_index, 2)
	legacy_entry.erase("copy_instance_ids")
	legacy_entry.erase("model_equipment_by_id")
	legacy_entry.erase("visual_model_overrides_by_id")
	legacy_entry.erase("model_visual_selection_modes_by_id")
	legacy_entry.visual_variants = ["legacy-restart-variant", "", "", "", "", "legacy-second-copy-variant", "", "", "", ""]
	legacy_entry.visual_model_overrides = ["legacy-restart-sculpt", "", "", "", "", "", "", "legacy-second-copy-sculpt", "", ""]
	legacy_list.entries.append(legacy_entry)
	var necron_choice := catalog.lookup("40kdc:11e:necrons:necron-warriors")
	var necron_option_index := 0
	for candidate_index in range(necron_choice.options.size()):
		if int(necron_choice.options[candidate_index].get("models", 0)) == 10: necron_option_index = candidate_index
	var legacy_necron_list := Roster.new_list("11e", "Necrons", "strike_force", 2000)
	legacy_necron_list.id = "legacy-necron-restart-list"
	legacy_necron_list.name = "Legacy Necron restart fixture"
	var legacy_necron_entry := Roster.entry(necron_choice, necron_option_index)
	legacy_necron_entry.erase("copy_instance_ids")
	legacy_necron_entry.erase("model_equipment_by_id")
	legacy_necron_entry.erase("visual_model_overrides_by_id")
	legacy_necron_entry.erase("model_visual_selection_modes_by_id")
	legacy_necron_entry.visual_variants = ["legacy-necron-variant", "", "", "", "", "", "", "", "", ""]
	legacy_necron_entry.visual_model_overrides = ["", "legacy-necron-sculpt", "", "", "", "", "", "", "", ""]
	legacy_necron_list.entries.append(legacy_necron_entry)
	var aggressor_choice := catalog.lookup("40kdc:11e:adeptus-astartes:aggressor-squad")
	var aggressor_option_index := 0
	for candidate_index in range(aggressor_choice.options.size()):
		if int(aggressor_choice.options[candidate_index].get("models", 0)) == 3: aggressor_option_index = candidate_index
	var legacy_aggressor_list := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	legacy_aggressor_list.id = "legacy-aggressor-restart-list"
	legacy_aggressor_list.name = "Legacy Aggressor restart fixture"
	var legacy_aggressor_entry := Roster.entry(aggressor_choice, aggressor_option_index)
	legacy_aggressor_entry.erase("copy_instance_ids")
	legacy_aggressor_entry.erase("model_equipment_by_id")
	legacy_aggressor_entry.erase("visual_model_overrides_by_id")
	legacy_aggressor_entry.erase("model_visual_selection_modes_by_id")
	legacy_aggressor_entry.visual_variants = ["legacy-aggressor-variant", "", ""]
	legacy_aggressor_entry.visual_model_overrides = ["", "legacy-aggressor-sculpt", ""]
	legacy_aggressor_list.entries.append(legacy_aggressor_entry)
	var legacy_aggressor_equipment_list := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	legacy_aggressor_equipment_list.id = "legacy-aggressor-equipment-restart-list"
	legacy_aggressor_equipment_list.name = "Legacy Aggressor equipment restart fixture"
	var legacy_aggressor_equipment_entry := Roster.entry(aggressor_choice, aggressor_option_index)
	legacy_aggressor_equipment_entry.copy_instance_ids = ["legacy-aggressor-equipment-copy"]
	legacy_aggressor_equipment_entry.erase("model_equipment_by_id")
	legacy_aggressor_equipment_entry.erase("visual_model_overrides_by_id")
	legacy_aggressor_equipment_entry.erase("model_visual_selection_modes_by_id")
	legacy_aggressor_equipment_entry.visual_variants = ["", "", ""]
	legacy_aggressor_equipment_entry.visual_model_overrides = ["", "", ""]
	legacy_aggressor_equipment_entry.unit_equipment_by_copy_id = {"legacy-aggressor-equipment-copy": {"aggressor_boltstorm": true}}
	legacy_aggressor_equipment_list.entries.append(legacy_aggressor_equipment_entry)
	var legacy_bank := {"schema_version": 1, "active": "local", "profiles": [{"id": "local", "name": "Local Player", "lists": [legacy_list, legacy_necron_list, legacy_aggressor_list, legacy_aggressor_equipment_list]}]}
	assert(Roster.write_json(path + ".legacy", legacy_bank).is_empty())
	var output: Array = []
	var result := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_saved_loadout_restart.gd", "--", "--reopen", path], output, true)
	assert(result == 0, str(output))
	var admitted := Training.admit_current_catalog(written.list)
	assert(admitted.error.is_empty())
	var state := Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, {1: admitted.selection, 2: admitted.selection})
	assert(not state.has("error"))
	var frozen: Dictionary = state.saved_army_setup.duplicate(true)
	var frozen_rhinos: Array = frozen.armies[1].entries.filter(func(selected: Dictionary) -> bool: return str(selected.get("definition_id", "")) == "40kdc:11e:adeptus-astartes:rhino")
	var frozen_primaris: Array = frozen.armies[1].entries.filter(func(selected: Dictionary) -> bool: return str(selected.get("definition_id", "")) == "40kdc:11e:adeptus-astartes:rhino-primaris")
	# Admission may split differently equipped copies into canonical entries.
	# Verify every saved copy, without depending on that grouping or its order.
	for entries: Array in [frozen_rhinos, frozen_primaris]:
		var loadouts: Array = []
		var copy_count := 0
		for selected: Dictionary in entries:
			copy_count += int(selected.copies)
			loadouts.append_array(selected.get("saved_model_loadouts", []))
		if copy_count != 2 or loadouts.size() != 2 or loadouts.count({"rhino_hunter_killer_missile": true}) != 1 or loadouts.count({"rhino_hunter_killer_missile": false}) != 1:
			push_error("Frozen Rhino copies must retain one equipped and one default loadout: %s" % str(entries))
			quit(1)
			return
	assert(Save.write(state, {}, 42, {}, match_path).is_empty())
	Roster.set_model_equipment(written.list.entries[0], 0, 0, "predator_destructor_storm_bolter", false)
	Roster.set_model_equipment(written.list.entries[6], 0, 0, "rhino_hunter_killer_missile", false)
	Roster.set_model_equipment(written.list.entries[7], 0, 0, "rhino_hunter_killer_missile", false)
	assert(store.save_list(written.list).error.is_empty())
	var restored := Save.read(match_path)
	assert(not restored.has("error"))
	assert(restored.state.saved_army_setup == frozen)
	assert(not Prepared.from_setup(restored.state.saved_army_setup).has("error"))
	# Exercise shared editor callbacks as actual signals, including independent copies.
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	var checkbox := panel.per_model_equipment_controls.get_child(0) as CheckBox
	checkbox.button_pressed = true
	assert(Roster.model_equipment(panel.draft.entries[0], 0, 0).predator_destructor_heavy_bolters)
	assert(not Roster.model_equipment(panel.draft.entries[0], 1, 0).predator_destructor_heavy_bolters)
	assert(panel.dirty and "draft" in panel.notice.text)
	panel.free()
	catalog.free()
	for file: String in [path, path + ".bak", path + ".legacy", path + ".legacy.bak", match_path, match_path + ".bak", path + ".panel"]:
		if FileAccess.file_exists(file): DirAccess.remove_absolute(file)
	print("Saved loadout disk/restart, mixed vehicle, Guard, Death Company, Tarantula and both Rhino match snapshots, and shared editor checks passed")
	quit()
