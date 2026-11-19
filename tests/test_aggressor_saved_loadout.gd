extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const ArmyProfiles = preload("res://scripts/army_profiles.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const MainSceneScript = preload("res://scripts/main.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:aggressor-squad"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var unit := Catalog.current_catalog_choice({"id": UNIT_ID, "edition": "11e", "faction": "Space Marines"})
	unit.role = ArmyRoster.role(unit.get("keywords", []))
	var source_list := ArmyRoster.new_list("11e", "Space Marines", "custom", 3000)
	var entry: Dictionary = ArmyRoster.entry(unit, 0, 2)
	var no_saved_model_package := not ArmyRoster.has_model_equipment(entry, 0, 0)
	ArmyRoster.set_model_equipment(entry, 0, 1, "aggressor_boltstorm", true)
	ArmyRoster.set_model_equipment(entry, 1, 0, "aggressor_boltstorm", true)
	ArmyRoster.set_model_equipment(entry, 1, 2, "aggressor_boltstorm", true)
	check(no_saved_model_package
		and bool(ArmyRoster.model_equipment(entry, 0, 1).get("aggressor_boltstorm", false))
		and bool(ArmyRoster.model_equipment(entry, 1, 0).get("aggressor_boltstorm", false))
		and bool(ArmyRoster.model_equipment(entry, 1, 2).get("aggressor_boltstorm", false)),
		"The Builder saves source-listed package replacements independently for stable Aggressor miniatures")
	source_list.entries.append(entry)
	var copy_ids: Array = entry.copy_instance_ids.duplicate(true)
	var saved_model_ids: Array[String] = []
	for copy_index in range(2):
		for model_index in range(3): saved_model_ids.append(ArmyRoster.model_instance_id(entry, copy_index, model_index))
	check(copy_ids.size() == 2 and copy_ids[0] != copy_ids[1] and saved_model_ids.size() == 6
		and saved_model_ids.all(func(model_id: String) -> bool: return not model_id.is_empty())
		and bool(ArmyRoster.model_equipment(entry, 0, 1).get("aggressor_boltstorm", false))
		and bool(ArmyRoster.model_equipment(entry, 1, 0).get("aggressor_boltstorm", false))
		and bool(ArmyRoster.model_equipment(entry, 1, 2).get("aggressor_boltstorm", false))
		and not bool(ArmyRoster.model_equipment(entry, 0, 0).get("aggressor_boltstorm", false))
		and ArmyRoster.validate(source_list).is_empty(), "Unlike model packages persist under stable miniature IDs and pass roster validation")

	var profiles_path := "res://.tools/aggressor-saved-loadout-%d/profiles.json" % OS.get_process_id()
	var profile_store := ArmyProfiles.new(profiles_path)
	var saved_profile := profile_store.save_list(source_list)
	var reopened_profiles := ArmyProfiles.new(profiles_path)
	var reopened_entries: Array = reopened_profiles.active().get("lists", [])
	var reopened_entry: Dictionary = reopened_entries[0].get("entries", [])[0] if not reopened_entries.is_empty() else {}
	var reopened_equipment_ok := true
	for copy_index in range(2):
		for model_index in range(3):
			var expected := (copy_index == 0 and model_index == 1) or (copy_index == 1 and model_index in [0, 2])
			reopened_equipment_ok = reopened_equipment_ok and bool(ArmyRoster.model_equipment(reopened_entry, copy_index, model_index).get("aggressor_boltstorm", false)) == expected
	check(str(saved_profile.get("error", "")).is_empty() and reopened_profiles.error.is_empty()
		and reopened_entry.get("copy_instance_ids", []) == copy_ids and reopened_equipment_ok,
		"Save and reopen retain every per-model package choice and the parent unit-copy identities")
	var legacy_entry: Dictionary = ArmyRoster.entry(unit, 0, 1)
	var legacy_copy_id := str(legacy_entry.copy_instance_ids[0])
	legacy_entry.unit_equipment_by_copy_id = {legacy_copy_id: {"aggressor_boltstorm": true}}
	ArmyRoster.normalize_model_equipment(legacy_entry)
	var legacy_migrated := not legacy_entry.has("unit_equipment_by_copy_id")
	for model_index in range(3): legacy_migrated = legacy_migrated and bool(ArmyRoster.model_equipment(legacy_entry, 0, model_index).get("aggressor_boltstorm", false))
	check(legacy_migrated, "A valid earlier whole-unit Aggressor record migrates without losing its intended package")

	var builder := BuilderPanel.new()
	root.add_child(builder)
	builder.draft = source_list.duplicate(true)
	builder._render_draft()
	builder._select_entry(0)
	var model_one_checkbox := builder.per_model_equipment_controls.get_child(2) as CheckBox if builder.per_model_equipment_controls.get_child_count() > 2 else null
	check(builder.sergeant_loadout_heading.visible and builder.sergeant_loadout_heading.text == "AGGRESSOR MODEL EQUIPMENT"
		and builder.sergeant_loadout_copy_picker.item_count == 2 and builder.per_model_equipment_controls.visible
		and builder.per_model_equipment_controls.get_child_count() == 4 and model_one_checkbox != null
		and model_one_checkbox.text.contains("Aggressor 2") and model_one_checkbox.button_pressed
		and "Equipment varies by unit" in builder._sergeant_loadout_summary(builder.draft.entries[0]),
		"Army Workshop exposes a separate package control for each miniature and summarizes different unit copies")
	var source_entry: Dictionary = source_list.entries[0]
	var sergeant_flame_key := builder._visual_similarity_key(source_entry, 0, 0)
	var aggressor_bolt_key := builder._visual_similarity_key(source_entry, 0, 1)
	var matching_bolt_key := builder._visual_similarity_key(source_entry, 1, 2)
	check(not sergeant_flame_key.is_empty() and sergeant_flame_key != aggressor_bolt_key and aggressor_bolt_key == matching_bolt_key,
		"Visual batch actions distinguish model role and equipment while allowing equal Aggressor miniatures to share a recommendation")
	builder._sergeant_loadout_copy_selected(0)
	builder._set_aggressor_boltstorm_from_controls(true, 0)
	var edited_entry: Dictionary = builder.draft.entries[0]
	check(bool(ArmyRoster.model_equipment(edited_entry, 0, 0).get("aggressor_boltstorm", false))
		and bool(ArmyRoster.model_equipment(edited_entry, 0, 1).get("aggressor_boltstorm", false))
		and not bool(ArmyRoster.model_equipment(edited_entry, 0, 2).get("aggressor_boltstorm", false)),
		"Changing one model's checkbox leaves every other miniature's package unchanged")
	builder.free()

	var admitted := TrainingRoster.inspect(source_list, {}, true)
	var canonical_packages: Array = []
	if str(admitted.get("error", "")).is_empty():
		for canonical_entry: Dictionary in admitted.selection.get("entries", []):
			for copy_loadouts: Variant in canonical_entry.get("aggressor_loadouts", []): canonical_packages.append(copy_loadouts)
	check(str(admitted.get("error", "")).is_empty() and canonical_packages == [[false, true, false], [true, false, true]],
		"Current-catalog admission preserves a mixed model package and groups differently equipped unit copies")
	var stable_refs := TrainingRoster.stable_model_refs(source_list, admitted.get("selection", {})) if str(admitted.get("error", "")).is_empty() else {"error": "Saved-list admission failed."}
	check(str(stable_refs.get("error", "")).is_empty() and stable_refs.get("models", {}).size() == 6 and stable_refs.get("copies", {}).size() == 2,
		"Canonical Aggressor configurations remain bound to six stable models and their source unit-copy IDs")

	var selections := F.current_marine_selections()
	if str(admitted.get("error", "")).is_empty(): selections[1] = admitted.selection
	selections[2].category = "custom"
	selections[2].points_limit = 3000
	var options := {"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": false, "manual_allocation": false}
	var state: Dictionary = F.P.initial_state(options, selections)
	var aggressor_groups: Dictionary = {}
	if not state.has("error"):
		for model_id: int in state.get("units", {}):
			var model: Dictionary = state.units[model_id]
			if int(model.get("owner", -1)) == 1 and F.C.UnitAbilities.identity(model) == "aggressor-squad":
				var squad := int(model.get("squad", -1))
				if not aggressor_groups.has(squad): aggressor_groups[squad] = []
				aggressor_groups[squad].append(model_id)
	var materialized_packages: Array = []
	var all_models_locked := true
	var boltstorm_model := -1
	var boltstorm_squad := -1
	var squad_ids := aggressor_groups.keys()
	squad_ids.sort()
	for squad_id: int in squad_ids:
		var models: Array = aggressor_groups[squad_id]
		models.sort()
		var model_packages: Array[bool] = []
		var every_model_matches := models.size() == 3
		for model_id: int in models:
			var model: Dictionary = state.units[model_id]
			var boltstorm := bool(model.get("aggressor_saved_boltstorm_choice", false))
			var actual_ids: Array = model.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
			actual_ids.sort()
			var expected_ids := ["auto-boltstorm-gauntlets", "fragstorm-grenade-launcher"] if boltstorm else ["flamestorm-gauntlets"]
			model_packages.append(boltstorm)
			every_model_matches = every_model_matches and actual_ids == expected_ids and bool(model.get("aggressor_loadout_locked", false))
			all_models_locked = all_models_locked and bool(model.get("aggressor_loadout_locked", false))
			if boltstorm: boltstorm_model = model_id; boltstorm_squad = squad_id
		materialized_packages.append(model_packages)
		check(every_model_matches, "Each saved Aggressor miniature gets its own complete source package and is locked before Deployment")
	check(not state.has("error") and materialized_packages == [[false, true, false], [true, false, true]] and all_models_locked,
		"The saved-list match materializes Flamestorm and mixed Boltstorm/Fragstorm choices at model granularity")
	var readiness := MainSceneScript._saved_roster_equipment_status_for_state(state, 1)
	check(readiness.contains("2 Flamestorm Gauntlets") and readiness.contains("1 Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher")
		and readiness.contains("1 Flamestorm Gauntlets") and readiness.contains("2 Auto Boltstorm Gauntlets + Fragstorm Grenade Launcher"),
		"Battle Readiness summarizes each unit's per-model package counts")
	if boltstorm_model >= 0:
		var prompts := F.C.UnitActions.choices(state, 1).filter(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) == "aggressor-loadout")
		var forced := PublicUnitCommand.submit(state, 1, {"action": "aggressor-loadout", "model": boltstorm_model, "target": boltstorm_squad, "value": "flame"})
		var unchanged_ids: Array = state.units[boltstorm_model].get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
		check(prompts.is_empty() and not str(forced.get("error", "")).is_empty()
			and unchanged_ids.has("auto-boltstorm-gauntlets") and unchanged_ids.has("fragstorm-grenade-launcher"),
			"Saved Aggressor choices suppress and reject a forced preparation change for a locked model")
	else:
		check(false, "The saved Aggressor match produced a Boltstorm model: %s" % str(state.get("error", "Expected two Aggressor copies.")))

	var default_selection := {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 3000,
		"entries": [{"definition_id": UNIT_ID, "models": 3, "copies": 1}]}
	var default_admission := Catalog.admit(default_selection)
	var standalone_selections := F.current_marine_selections()
	if str(default_admission.get("error", "")).is_empty(): standalone_selections[1] = default_admission.selection
	standalone_selections[2].category = "custom"
	standalone_selections[2].points_limit = 3000
	var standalone_state: Dictionary = F.P.initial_state(options, standalone_selections)
	var standalone_prompts := F.C.UnitActions.choices(standalone_state, 1).filter(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) == "aggressor-loadout") if not standalone_state.has("error") else []
	check(str(default_admission.get("error", "")).is_empty() and not standalone_state.has("error") and standalone_prompts.size() == 3
		and standalone_prompts.all(func(choice: Dictionary) -> bool: return int(choice.get("model", -1)) >= 0),
		"Standalone current-catalog matches keep one Army Preparation choice per Aggressor miniature")

	if failures == 0:
		print("Aggressor saved-loadout checks passed")
		quit()
	else:
		print("Aggressor saved-loadout checks: %d failures" % failures)
		quit(1)
