extends SceneTree

const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Roster = preload("res://scripts/army_roster.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const SavedEquipment = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const UNIT_ID := "40kdc:11e:adeptus-astartes:rhino"
const PRIMARIS_ID := "40kdc:11e:adeptus-astartes:rhino-primaris"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local 11th-edition catalog loads")
	var source_unit: Dictionary = catalog.lookup(UNIT_ID)
	var list := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	var entry: Dictionary = Roster.entry(source_unit, 0, 2)
	check(Roster.set_model_equipment(entry, 0, 0, "rhino_hunter_killer_missile", true), "The first Rhino copy accepts its source-listed missile")
	list.entries.append(entry)
	var primaris_entry: Dictionary = Roster.entry(catalog.lookup(PRIMARIS_ID), 0, 2)
	check(Roster.set_model_equipment(primaris_entry, 0, 0, "rhino_hunter_killer_missile", true), "The first Rhino Primaris copy accepts its source-listed missile")
	list.entries.append(primaris_entry)
	check(Roster.model_equipment(entry, 0, 0) == {"rhino_hunter_killer_missile": true}
		and Roster.model_equipment(entry, 1, 0) == {"rhino_hunter_killer_missile": false},
		"The Rhino copies retain independent saved equipment")
	check(Roster.model_equipment(primaris_entry, 0, 0) == {"rhino_hunter_killer_missile": true}
		and Roster.model_equipment(primaris_entry, 1, 0) == {"rhino_hunter_killer_missile": false},
		"The Rhino Primaris copies retain independent saved equipment")
	check(SavedEquipment.valid(UNIT_ID, {"rhino_hunter_killer_missile": true}, 1)
		and not SavedEquipment.valid(UNIT_ID, {"rhino_hunter_killer_missile": "true"}, 1)
		and SavedEquipment.valid(PRIMARIS_ID, {"rhino_hunter_killer_missile": true}, 1)
		and not SavedEquipment.valid(PRIMARIS_ID, {"rhino_hunter_killer_missile": "true"}, 1)
		and not SavedEquipment.valid(UNIT_ID, {"unsupported_option": true}, 1),
		"Both Rhino admissions accept only the typed source-backed field")
	check(Roster.validate(list).is_empty(), "The saved Rhino list passes canonical roster validation")

	var panel := BuilderPanel.new()
	panel.storage_path = "user://rhino-saved-loadout-test.json"
	panel.cache_directory = "user://rhino-saved-loadout-catalog"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.sergeant_loadout_heading.visible and panel.sergeant_loadout_heading.text == "RHINO EQUIPMENT"
		and panel.per_model_equipment_controls.get_child_count() == 2,
		"The Workshop presents one labeled optional equipment control per selected Rhino copy")
	if panel.per_model_equipment_controls.get_child_count() == 2:
		var first_picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		check(first_picker.get_item_metadata(first_picker.selected) == true, "The first copy reopens with its saved missile choice selected")
		panel._render_sergeant_loadout_controls(1)
		var second_picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		check(panel.sergeant_loadout_copy_picker.selected == 1 and second_picker.get_item_metadata(second_picker.selected) == false,
			"The second copy opens with its independent unequipped default")
		second_picker.select(1)
		second_picker.item_selected.emit(1)
		check(bool(Roster.model_equipment(panel.draft.entries[0], 1, 0).get("rhino_hunter_killer_missile", false))
			and panel.dirty and "Save the army list" in panel.notice.text,
			"The Workshop signal updates the selected copy as a draft and explains how to persist it")
		panel._select_entry(1)
		check(panel.sergeant_loadout_heading.visible and panel.sergeant_loadout_heading.text == "RHINO PRIMARIS EQUIPMENT"
			and panel.per_model_equipment_controls.get_child_count() == 2,
			"The Workshop presents the same saved-equipment control for the audited Legends Rhino Primaris")
		if panel.per_model_equipment_controls.get_child_count() == 2:
			var primaris_picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
			check(primaris_picker.get_item_metadata(primaris_picker.selected) == true,
				"The Rhino Primaris copy reopens with its independent missile choice")
	panel.free()

	var admitted := TrainingRoster.inspect(list, {}, true)
	check(admitted.get("error", "").is_empty() and int(admitted.get("total", -1)) == 330,
		"Current-catalog admission preserves both Rhino datasheets' two-copy cost and saved choices: %s" % str(admitted.get("error", "")))
	if admitted.get("error", "").is_empty():
		var state: Dictionary = Prepared.initial_state(
			{"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "manual_allocation": false},
			{1: admitted.selection, 2: admitted.selection})
		check(not state.has("error"), "Both players can prepare from the saved Rhino and Rhino Primaris list")
		if not state.has("error"):
			var standard_missiles := {1: 0, 2: 0}
			var standard_defaults := {1: 0, 2: 0}
			var primaris_missiles := {1: 0, 2: 0}
			var primaris_defaults := {1: 0, 2: 0}
			var missile_models := {UNIT_ID: -1, PRIMARIS_ID: -1}
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				var definition_id := str(unit.get("definition_id", ""))
				if definition_id not in [UNIT_ID, PRIMARIS_ID]: continue
				var equipped := bool(unit.get("rhino_hunter_killer_missile", false))
				var owner := int(unit.owner)
				if equipped:
					if definition_id == UNIT_ID: standard_missiles[owner] += 1
					else: primaris_missiles[owner] += 1
					if owner == 1: missile_models[definition_id] = model
				else:
					if definition_id == UNIT_ID: standard_defaults[owner] += 1
					else: primaris_defaults[owner] += 1
				var weapon_ids: Array = unit.get("ranged_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
				check(("hunter-killer-missile" in weapon_ids) == equipped, "The %s weapon inventory matches its saved missile" % definition_id)
				check(bool(unit.get("transport_loadout_locked", false)), "Saved %s equipment is locked for this match" % definition_id)
			check(standard_missiles == {1: 1, 2: 1} and standard_defaults == {1: 1, 2: 1}
				and primaris_missiles == {1: 1, 2: 1} and primaris_defaults == {1: 1, 2: 1},
				"Both players receive independent saved choices for each Rhino datasheet")
			state.phase = "deployment"
			state.active = 1
			check(TransportRules.transport_weapon_loadout_choices(state, 1).is_empty(), "Saved Rhino copies do not offer duplicate match-preparation edits")
			for definition_id: String in [UNIT_ID, PRIMARIS_ID]:
				var missile_model: int = int(missile_models[definition_id])
				check(missile_model >= 0, "Player one has an equipped copy for %s" % definition_id)
				if missile_model < 0: continue
				var missile_weapon: Dictionary = state.units[missile_model].ranged_weapons.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")) == "hunter-killer-missile")[0]
				check(bool(missile_weapon.get("profiles", {}).get("standard", {}).get("keywords", {}).get("one-shot", false)),
					"The saved %s missile keeps the local profile's One Shot rule" % definition_id)
				var forced_edit := TransportRules.configure_optional_transport_weapon(state, missile_model, "hunter-killer-missile:off")
				check(not forced_edit.is_empty() and bool(state.units[missile_model].get("rhino_hunter_killer_missile", false)),
					"A direct setup edit cannot change the saved %s loadout" % definition_id)

	catalog.free()
	if failures == 0:
		print("Rhino and Rhino Primaris saved-loadout checks passed")
		quit()
	else:
		print("Rhino saved-loadout checks: %d failures" % failures)
		quit(1)
