extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const Adapter = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	check_source_schema()
	run_saved_copy_flow()
	print("Shared Captain saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.CAPTAIN
	var controls := Adapter.controls(definition)
	var legal := 0
	for ranged: Dictionary in controls[0].choices:
		for melee: Dictionary in controls[1].choices:
			var equipment := Adapter.defaults(definition)
			equipment.captain_ranged_loadout = ranged.id
			equipment.captain_melee_weapon = melee.id
			var factory := Profiles.captain_weapons(str(ranged.id), str(melee.id) == "power-fist")
			var expected_valid := not factory.is_empty() and not (str(ranged.id) == "relic-shield" and str(melee.id) == "power-fist")
			check(Adapter.valid(definition, equipment, 1) == expected_valid, "Shared Captain admission matches its local weapon factory and Shield/Fist restriction")
			if expected_valid: legal += 1
	check(legal == 7, "Shared Captain schema admits exactly seven legal equipment packages")
	var conflict := Adapter.defaults(definition)
	conflict.captain_ranged_loadout = "relic-shield"
	conflict.captain_melee_weapon = "power-fist"
	check(not Adapter.valid(definition, conflict, 1), "Shared Captain admission rejects Relic Shield + Power Fist")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Shared Captain equipment schema remains one model per unit copy")

func run_saved_copy_flow() -> void:
	var definition := Adapter.CAPTAIN
	var identity := "captain"
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, 3)
	var configured := [
		{"captain_ranged_loadout": "plasma-pistol", "captain_melee_weapon": "power-fist"},
		{"captain_ranged_loadout": "relic-shield", "captain_melee_weapon": "master-crafted-power-weapon"},
		Adapter.defaults(definition),
	]
	for copy_index in range(configured.size()):
		for field: String in configured[copy_index]:
			Roster.set_model_equipment(item, copy_index, 0, field, configured[copy_index][field])
	list.entries.append(item)
	for equipment: Dictionary in configured: check(Adapter.valid(definition, equipment, 1), "Saved Captain copy uses a source-legal combination")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Three source-permitted Captain copies pass current catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var variants: Array = admitted.selection.get("entries", [])
		check(variants.size() == 3 and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), "All Captain copies retain their independent saved profiles")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 3000
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Captain roster materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var editable_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected := Profiles.captain_weapons(str(equipment.get("captain_ranged_loadout", "")), str(equipment.get("captain_melee_weapon", "")) == "power-fist")
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("captain_loadout_locked", false)), "Captain copy materializes its exact saved weapon profiles and lock")
				var shield := bool(expected.get("relic_shield", false))
				check(bool(model.get("relic_shield", false)) == shield and int(model.get("max_wounds", 0)) == (6 if shield else 5), "Captain copy preserves the saved Relic Shield wound adjustment")
				if equipment == configured[0]: editable_model = model_id
			check(observed.size() == 3 and observed.any(func(value: Dictionary) -> bool: return value == configured[0]) and observed.any(func(value: Dictionary) -> bool: return value == configured[1]) and observed.any(func(value: Dictionary) -> bool: return value == configured[2]), "Plasma/Fist, Shield and default loadouts remain on their own Captain copies")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in ["captain-ranged-loadout", "captain-melee-loadout"]), "Saved Captain copies suppress duplicate setup choices")
			if editable_model >= 0:
				var before: Dictionary = state.units[editable_model].duplicate(true)
				var forced := {"action": "captain-ranged-loadout", "model": editable_model, "target": int(before.get("squad", -1)), "value": "default"}
				check(not C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision)).is_empty() and state.units[editable_model].ranged_weapons == before.ranged_weapons and state.units[editable_model].melee_weapons == before.melee_weapons, "Forced setup mutation of saved Captain weapons is rejected")

	var panel := Builder.new()
	panel.storage_path = "user://captain-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, "Workshop renders both Captain equipment controls")
	if panel.per_model_equipment_controls.get_child_count() >= 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(1)
		picker.item_selected.emit(1)
		var edited := Roster.model_equipment(panel.draft.entries[0], 1, 0)
		check(panel.dirty and edited.captain_ranged_loadout == "neo-volkite" and Roster.model_equipment(panel.draft.entries[0], 0, 0) == configured[0] and Roster.model_equipment(panel.draft.entries[0], 2, 0) == configured[2], "Workshop updates only the selected Captain copy and preserves its neighbors")
	panel.free()
