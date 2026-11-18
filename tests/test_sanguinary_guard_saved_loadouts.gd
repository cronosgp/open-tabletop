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
	run_saved_squad_flow()
	print("Sanguinary Guard saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.SANGUINARY_GUARD
	for model_count in [3, 6]:
		var defaults: Array[Dictionary] = []
		for _model in range(model_count): defaults.append(Adapter.defaults(definition))
		check(Adapter.valid_saved_loadout(definition, defaults, model_count), "A default %d-model Sanguinary Guard unit is valid" % model_count)
		var quota := Profiles.sanguinary_guard_inferno_limit(model_count)
		for model_index in range(quota): defaults[model_index].sanguinary_guard_inferno_pistol = true
		check(Adapter.valid_saved_loadout(definition, defaults, model_count), "Saved model schema accepts the source limit of %d Inferno Pistols" % quota)
		if quota > 0:
			defaults[quota].sanguinary_guard_inferno_pistol = true
			check(not Adapter.valid_saved_loadout(definition, defaults, model_count), "Saved model schema rejects one Inferno Pistol above the source limit")
	check(not Adapter.valid_saved_loadout(definition, [Adapter.defaults(definition)], 3), "Saved Sanguinary Guard loadout requires one record per model")
	check(not Adapter.valid(Adapter.SANGUINARY_GUARD, {"sanguinary_guard_inferno_pistol": "yes"}, 3), "Saved model schema rejects non-boolean replacement values")
	check(not Adapter.valid_saved_loadout(definition, [Adapter.defaults(definition)], 1), "Sanguinary Guard schema does not admit unsupported one-model squads")

func run_saved_squad_flow() -> void:
	var definition := Adapter.SANGUINARY_GUARD
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 2000)
	var option_index := 0
	for candidate_index in range(choice.options.size()):
		if int(choice.options[candidate_index].get("models", 0)) == 3: option_index = candidate_index
	var item: Dictionary = Roster.entry(choice, option_index, 2)
	check(Roster.model_equipment_loadouts(item, 0).size() == 3 and Roster.model_equipment(item, 0, 2) == Adapter.defaults(definition), "Army Workshop seeds a stable equipment record for every Sanguinary Guard miniature")
	check(Roster.set_model_equipment(item, 0, 0, "sanguinary_guard_inferno_pistol", true), "Workshop accepts one source-legal Inferno Pistol in a three-model unit")
	check(not Roster.set_model_equipment(item, 0, 1, "sanguinary_guard_inferno_pistol", true), "Workshop rejects a second Inferno Pistol in a three-model unit")
	check(Roster.set_model_equipment(item, 1, 1, "sanguinary_guard_inferno_pistol", true), "A separate unit copy can save its own legal model choice")
	list.entries.append(item)
	check(Roster.validate(list).is_empty(), "The saved roster accepts independent legal equipment on separate Sanguinary Guard copies")
	var corrupted := list.duplicate(true)
	var over_limit_id := Roster.model_instance_id(corrupted.entries[0], 0, 1)
	corrupted.entries[0].model_equipment_by_id[over_limit_id].sanguinary_guard_inferno_pistol = true
	check(not Roster.validate(corrupted).is_empty(), "Roster validation rejects a saved copy that exceeds the per-three-model source limit")
	check(Roster.model_equipment_role(item, 0, 0) != Roster.model_equipment_role(item, 0, 1), "Model identity and visual matching distinguish the configured Inferno Pistol bearer")

	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Current local catalog admission accepts source-validated Sanguinary Guard equipment: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var entries: Array = admitted.selection.get("entries", [])
		var observed_configs := 0
		for canonical_entry: Dictionary in entries:
			for saved_copy: Variant in canonical_entry.get("saved_model_loadouts", []):
				check(saved_copy is Array and saved_copy.size() == int(canonical_entry.models) and Adapter.valid_saved_loadout(definition, saved_copy, int(canonical_entry.models)), "Canonical admission carries a legal loadout record for every model")
				if saved_copy is Array and saved_copy.size() == 3 and saved_copy.any(func(equipment: Dictionary) -> bool: return bool(equipment.get("sanguinary_guard_inferno_pistol", false))): observed_configs += 1
		check(observed_configs == 2, "Both separately configured unit copies survive canonical admission")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 2000
		selections[2].category = "custom"
		selections[2].points_limit = 2000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved per-model equipment materializes into the match: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed := 0
			var editable_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != "sanguinary-guard": continue
				observed += 1
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				var inferno := bool(equipment.get("sanguinary_guard_inferno_pistol", false))
				var expected := Profiles.sanguinary_guard_weapons(inferno)
				check(model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("sanguinary_guard_loadout_locked", false)), "Each saved Guard model receives its exact source weapon profile and match lock")
				if not inferno: editable_model = model_id
			check(observed == 6, "Both 3-model Guard copies materialize their individual equipment")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "sanguinary-guard-inferno-pistol"), "Saved equipment suppresses repeated match-preparation changes")
			if editable_model >= 0:
				var before: Dictionary = state.units[editable_model].duplicate(true)
				var forced := {"action": "sanguinary-guard-inferno-pistol", "model": editable_model, "target": int(before.get("squad", -1)), "value": "on"}
				var result: String = C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
				check(not result.is_empty() and state.units[editable_model].ranged_weapons == before.ranged_weapons, "A forced setup command cannot overwrite saved model equipment")

	var panel := Builder.new()
	panel.storage_path = "user://sanguinary-guard-saved-loadouts-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel.sergeant_loadout_copy_picker.select(1)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == 3, "Workshop renders a separate equipment row for every miniature")
	if panel.per_model_equipment_controls.get_child_count() == 3:
		var model_two_row := panel.per_model_equipment_controls.get_child(1) as HBoxContainer
		var picker := model_two_row.get_child(2) as OptionButton
		picker.select(1)
		picker.item_selected.emit(1)
		check(panel.dirty and bool(Roster.model_equipment(panel.draft.entries[0], 1, 1).get("sanguinary_guard_inferno_pistol", false)) and bool(Roster.model_equipment(panel.draft.entries[0], 0, 0).get("sanguinary_guard_inferno_pistol", false)), "Workshop saves a selected model's option without changing another model or unit copy")
	panel.free()
