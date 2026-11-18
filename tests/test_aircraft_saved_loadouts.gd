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
	check_source_option_schemas()
	for definition: String in [Adapter.STORMHAWK, Adapter.STORMTALON]:
		run_saved_copy_flow(definition)
	var invalid := Adapter.defaults(Adapter.STORMHAWK)
	invalid.stormhawk_icarus_stormcannon = "true"
	check(not Adapter.valid(Adapter.STORMHAWK, invalid, 1), "Stormhawk saved equipment rejects a value with the wrong type")
	print("Aircraft saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_option_schemas() -> void:
	var stormhawk_controls := Adapter.controls(Adapter.STORMHAWK)
	var stormhawk_legal := 0
	for primary: Dictionary in stormhawk_controls[0].choices:
		for missile: Dictionary in stormhawk_controls[1].choices:
			var equipment := Adapter.defaults(Adapter.STORMHAWK)
			equipment.stormhawk_icarus_stormcannon = primary.id
			equipment.stormhawk_missile_launcher = missile.id
			var factory := Profiles.stormhawk_interceptor_weapons(bool(primary.id), str(missile.id))
			check(Adapter.valid(Adapter.STORMHAWK, equipment, 1) == not factory.is_empty(), "Stormhawk admission matches the source weapon factory")
			if not factory.is_empty(): stormhawk_legal += 1
	check(stormhawk_legal == 6, "Stormhawk saved schema admits all six source-listed replacement combinations")
	check(not Adapter.valid(Adapter.STORMHAWK, Adapter.defaults(Adapter.STORMHAWK), 2), "Stormhawk saved schema is limited to its one-model copy")

	var stormtalon_controls := Adapter.controls(Adapter.STORMTALON)
	var stormtalon_legal := 0
	for missile: Dictionary in stormtalon_controls[0].choices:
		var equipment := Adapter.defaults(Adapter.STORMTALON)
		equipment.stormtalon_missile_launcher = missile.id
		var factory := Profiles.stormtalon_gunship_weapons(str(missile.id))
		check(Adapter.valid(Adapter.STORMTALON, equipment, 1) == not factory.is_empty(), "Stormtalon admission matches the source weapon factory")
		if not factory.is_empty(): stormtalon_legal += 1
	check(stormtalon_legal == 4, "Stormtalon saved schema admits all four source-listed missile choices")
	check(not Adapter.valid(Adapter.STORMTALON, Adapter.defaults(Adapter.STORMTALON), 2), "Stormtalon saved schema is limited to its one-model copy")

func run_saved_copy_flow(definition: String) -> void:
	var identity := definition.get_slice(":", 3)
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, 2)
	if definition == Adapter.STORMHAWK:
		Roster.set_model_equipment(item, 0, 0, "stormhawk_icarus_stormcannon", true)
		Roster.set_model_equipment(item, 0, 0, "stormhawk_missile_launcher", "twin-heavy-bolter")
	else:
		Roster.set_model_equipment(item, 0, 0, "stormtalon_missile_launcher", "twin-lascannon")
	list.entries.append(item)
	var configured := Roster.model_equipment(item, 0, 0)
	var defaults := Adapter.defaults(definition)
	check(configured != defaults and Adapter.valid(definition, configured, 1), identity + " stores a changed legal loadout on the model copy")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), identity + " passes current local catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var variants: Array = admitted.selection.get("entries", [])
		check(variants.size() == 2 and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), identity + " retains separate saved loadouts for both copies")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), identity + " materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var configured_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected: Array[Dictionary]
				if definition == Adapter.STORMHAWK:
					expected = Profiles.stormhawk_interceptor_weapons(bool(equipment.get("stormhawk_icarus_stormcannon", false)), str(equipment.get("stormhawk_missile_launcher", "skyhammer-missile-launcher")))
				else:
					expected = Profiles.stormtalon_gunship_weapons(str(equipment.get("stormtalon_missile_launcher", "skyhammer-missile-launcher")))
				var lock_field := "stormhawk_loadout_locked" if definition == Adapter.STORMHAWK else "stormtalon_loadout_locked"
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected and bool(model.get(lock_field, false)), identity + " installs the exact saved ranged profiles and locks them")
				if equipment == configured: configured_model = model_id
			check(observed.size() == 2 and observed.any(func(value: Dictionary) -> bool: return value == configured) and observed.any(func(value: Dictionary) -> bool: return value == defaults), identity + " materializes one configured and one default copy independently")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			var suppressed: Array[String] = ["stormtalon-loadout"]
			if definition == Adapter.STORMHAWK: suppressed = ["stormhawk-primary-loadout", "stormhawk-missile-loadout"]
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in suppressed), identity + " suppresses duplicate preparation choices for saved equipment")
			if configured_model >= 0:
				var configured_unit: Dictionary = state.units[configured_model]
				var before: Dictionary = configured_unit.duplicate(true)
				var action := "stormhawk-primary-loadout" if definition == Adapter.STORMHAWK else "stormtalon-loadout"
				var forced := {"action": action, "model": configured_model, "target": int(configured_unit.get("squad", -1)), "value": "las-talon" if definition == Adapter.STORMHAWK else "skyhammer-missile-launcher"}
				check(not C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision)).is_empty() and state.units[configured_model].ranged_weapons == before.ranged_weapons, identity + " rejects a forced match-preparation edit without changing the saved profile")

	var panel := Builder.new()
	panel.storage_path = "user://%s-saved-loadout-editor.json" % identity
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, identity + " renders all equipment controls for both copies")
	if panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 1, 0)
		var descriptor: Dictionary = Adapter.controls(definition)[0]
		var field := str(descriptor.field)
		check(panel.dirty and edited[field] == descriptor.choices[0].id and Roster.model_equipment(panel.draft.entries[0], 0, 0)[field] == configured[field], identity + " editor updates only the selected stable copy")
	panel.free()
