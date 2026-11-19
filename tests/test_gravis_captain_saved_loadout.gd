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
	print("Gravis Captain saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	var definition := Adapter.GRAVIS_CAPTAIN
	var controls := Adapter.controls(definition)
	var legal := 0
	for package: Dictionary in controls[0].choices:
		var equipment := Adapter.defaults(definition)
		equipment.gravis_loadout = package.id
		var factory := Profiles.gravis_captain_weapons(str(package.id))
		check(Adapter.valid(definition, equipment, 1) == not factory.is_empty(), "Gravis Captain saved schema agrees with the local complete weapon package factory")
		if not factory.is_empty(): legal += 1
	check(legal == 4, "Saved Gravis Captain schema accepts the default and three source-listed replacement packages")
	check(not Adapter.valid(definition, Adapter.defaults(definition), 2), "Gravis Captain equipment stays scoped to its one model")
	var unknown := Adapter.defaults(definition)
	unknown.gravis_loadout = "power-fist"
	check(not Adapter.valid(definition, unknown, 1), "Gravis Captain rejects a package from a different datasheet")

func run_saved_copy_flow() -> void:
	var definition := Adapter.GRAVIS_CAPTAIN
	var identity := "captain-in-gravis-armour"
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, 3)
	var configured := [
		{"gravis_loadout": "rifle"},
		{"gravis_loadout": "blade"},
		{"gravis_loadout": "chainsword"},
	]
	for copy_index in range(configured.size()):
		Roster.set_model_equipment(item, copy_index, 0, "gravis_loadout", configured[copy_index].gravis_loadout)
	list.entries.append(item)
	for equipment: Dictionary in configured: check(Adapter.valid(definition, equipment, 1), "Saved Gravis Captain copy uses a source-legal package")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Three permitted Gravis Captain copies pass local catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var variants: Array = admitted.selection.get("entries", [])
		check(variants.size() == 3 and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), "All Captain copies retain their individual equipment package")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 3000
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved Gravis Captain roster materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var editable_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected := Profiles.gravis_captain_weapons(str(equipment.get("gravis_loadout", "")))
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get("gravis_loadout_locked", false)), "Saved Captain copy materializes exact weapon profiles and locks them")
				if equipment == configured[0]: editable_model = model_id
			check(observed.size() == 3 and observed.any(func(value: Dictionary) -> bool: return value == configured[0]) and observed.any(func(value: Dictionary) -> bool: return value == configured[1]) and observed.any(func(value: Dictionary) -> bool: return value == configured[2]), "Rifle, relic blade and relic chainsword stay on their own copies")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "gravis-captain-loadout"), "Saved Gravis Captain copies suppress match-setup loadout choices")
			if editable_model >= 0:
				var before: Dictionary = state.units[editable_model].duplicate(true)
				var forced := {"action": "gravis-captain-loadout", "model": editable_model, "target": int(before.get("squad", -1)), "value": "fist"}
				var result: String = C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
				check(not result.is_empty() and state.units[editable_model].ranged_weapons == before.ranged_weapons and state.units[editable_model].melee_weapons == before.melee_weapons, "Forced match-setup edit cannot replace saved Captain weapons")

	var panel := Builder.new()
	panel.storage_path = "user://gravis-captain-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == 2, "Workshop renders the saved Gravis Captain package selector")
	if panel.per_model_equipment_controls.get_child_count() >= 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(3)
		picker.item_selected.emit(3)
		var edited := Roster.model_equipment(panel.draft.entries[0], 1, 0)
		check(panel.dirty and edited.gravis_loadout == "fist" and Roster.model_equipment(panel.draft.entries[0], 0, 0) == configured[0] and Roster.model_equipment(panel.draft.entries[0], 2, 0) == configured[2], "Workshop edits only the selected Captain copy and preserves neighboring copies")
	panel.free()
