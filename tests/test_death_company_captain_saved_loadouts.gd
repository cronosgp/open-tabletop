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
	check_source_schemas()
	run_saved_copy_flow(Adapter.DEATH_COMPANY_CAPTAIN)
	run_saved_copy_flow(Adapter.DEATH_COMPANY_JUMP_CAPTAIN)
	check_blood_angels_captain_schema()
	run_blood_angels_captain_flow()
	print("Death Company Captain saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schemas() -> void:
	var captain_controls := Adapter.controls(Adapter.DEATH_COMPANY_CAPTAIN)
	var captain_legal := 0
	for pistol: Dictionary in captain_controls[0].choices:
		for melee: Dictionary in captain_controls[1].choices:
			var equipment := Adapter.defaults(Adapter.DEATH_COMPANY_CAPTAIN)
			equipment.death_company_captain_pistol = pistol.id
			equipment.death_company_captain_melee = melee.id
			var factory := Profiles.death_company_captain_weapons(str(pistol.id), str(melee.id))
			check(Adapter.valid(Adapter.DEATH_COMPANY_CAPTAIN, equipment, 1) == not factory.is_empty(), "Death Company Captain admission matches its local weapon factory")
			if not factory.is_empty(): captain_legal += 1
	check(captain_legal == 6, "Foot Captain schema admits both pistol and all three melee choices")
	check(not Adapter.valid(Adapter.DEATH_COMPANY_CAPTAIN, Adapter.defaults(Adapter.DEATH_COMPANY_CAPTAIN), 2), "Foot Captain schema is limited to one model per copy")

	var jump_controls := Adapter.controls(Adapter.DEATH_COMPANY_JUMP_CAPTAIN)
	var jump_legal := 0
	for package: Dictionary in jump_controls[0].choices:
		var equipment := Adapter.defaults(Adapter.DEATH_COMPANY_JUMP_CAPTAIN)
		equipment.death_company_jump_captain_loadout = package.id
		var factory := Profiles.death_company_jump_captain_weapons(str(package.id))
		check(Adapter.valid(Adapter.DEATH_COMPANY_JUMP_CAPTAIN, equipment, 1) == not factory.is_empty(), "Jump Pack Captain admission matches its local complete-package factory")
		if not factory.is_empty(): jump_legal += 1
	check(jump_legal == 9, "Jump Pack Captain schema admits the nine source-listed complete weapon packages")
	check(not Adapter.valid(Adapter.DEATH_COMPANY_JUMP_CAPTAIN, Adapter.defaults(Adapter.DEATH_COMPANY_JUMP_CAPTAIN), 2), "Jump Pack Captain schema is limited to one model per copy")

func check_blood_angels_captain_schema() -> void:
	var controls := Adapter.controls(Adapter.BLOOD_ANGELS_CAPTAIN)
	var legal := 0
	for pistol: Dictionary in controls[0].choices:
		for melee: Dictionary in controls[1].choices:
			var equipment := Adapter.defaults(Adapter.BLOOD_ANGELS_CAPTAIN)
			equipment.blood_angels_captain_pistol = pistol.id
			equipment.blood_angels_captain_melee = melee.id
			var factory := Profiles.blood_angels_captain_weapons(str(pistol.id), str(melee.id))
			check(Adapter.valid(Adapter.BLOOD_ANGELS_CAPTAIN, equipment, 1) == not factory.is_empty(), "Blood Angels Captain admission matches its local weapon factory")
			if not factory.is_empty(): legal += 1
	check(legal == 6, "Blood Angels Captain schema admits all six independent pistol/melee choices")
	check(not Adapter.valid(Adapter.BLOOD_ANGELS_CAPTAIN, Adapter.defaults(Adapter.BLOOD_ANGELS_CAPTAIN), 2), "Blood Angels Captain saved schema is limited to one model per unit copy")

func run_blood_angels_captain_flow() -> void:
	var definition := Adapter.BLOOD_ANGELS_CAPTAIN
	var identity := "blood-angels-captain"
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, 1)
	Roster.set_model_equipment(item, 0, 0, "blood_angels_captain_pistol", "inferno-pistol")
	Roster.set_model_equipment(item, 0, 0, "blood_angels_captain_melee", "power-fist")
	list.entries.append(item)
	var configured := Roster.model_equipment(item, 0, 0)
	check(Adapter.valid(definition, configured, 1), "Blood Angels Captain saves its changed source-listed equipment")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Blood Angels Captain passes current local catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 3000
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Blood Angels Captain materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var captain: Dictionary = {}
			var captain_id := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) == 1 and C.UnitAbilities.identity(model) == identity:
					captain = model
					captain_id = model_id
			var expected := Profiles.blood_angels_captain_weapons("inferno-pistol", "power-fist")
			check(not captain.is_empty() and captain.ranged_weapons == expected.ranged and captain.melee_weapons == expected.melee and bool(captain.get("blood_angels_captain_loadout_locked", false)), "Saved Blood Angels Captain weapons materialize exactly and are locked")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in ["blood-angels-captain-ranged-loadout", "blood-angels-captain-melee-loadout"]), "Saved choices suppress duplicate Blood Angels Captain preparation actions")
			if captain_id >= 0:
				var before := captain.duplicate(true)
				var forced := {"action": "blood-angels-captain-ranged-loadout", "model": captain_id, "target": int(captain.get("squad", -1)), "value": "heavy-bolt-pistol"}
				check(not C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision)).is_empty() and state.units[captain_id].ranged_weapons == before.ranged_weapons and state.units[captain_id].melee_weapons == before.melee_weapons, "Forced preparation edits cannot mutate saved Blood Angels Captain weapons")

	var panel := Builder.new()
	panel.storage_path = "user://blood-angels-captain-saved-loadout-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(0)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, "Workshop renders both Blood Angels Captain equipment controls")
	if panel.per_model_equipment_controls.get_child_count() >= 2:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 0, 0)
		check(panel.dirty and edited.blood_angels_captain_pistol == "heavy-bolt-pistol", "Workshop signal updates the Captain's saved draft equipment")
	panel.free()

func run_saved_copy_flow(definition: String) -> void:
	var identity := definition.get_slice(":", 3)
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
	var item: Dictionary = Roster.entry(choice, 0, 2)
	var configured := Adapter.defaults(definition)
	var configured_field := str(Adapter.controls(definition)[0].field)
	var configured_value: Variant
	if definition == Adapter.DEATH_COMPANY_CAPTAIN:
		configured.death_company_captain_pistol = "inferno-pistol"
		configured.death_company_captain_melee = "power-fist"
		configured_value = "inferno-pistol"
	else:
		configured.death_company_jump_captain_loadout = "thunder-hammer-shield"
		configured_value = "thunder-hammer-shield"
	Roster.set_model_equipment(item, 0, 0, configured_field, configured_value)
	if definition == Adapter.DEATH_COMPANY_CAPTAIN:
		Roster.set_model_equipment(item, 0, 0, "death_company_captain_melee", "power-fist")
	list.entries.append(item)
	var defaults := Adapter.defaults(definition)
	configured = Roster.model_equipment(item, 0, 0)
	check(configured != defaults and Adapter.valid(definition, configured, 1), identity + " stores a changed legal loadout on a stable model copy")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), identity + " passes current local catalog admission: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var variants: Array = admitted.selection.get("entries", [])
		check(variants.size() == 2 and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), identity + " retains per-copy equipment records")
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 3000
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "marine_chapters": {1: "BLOOD ANGELS", 2: "BLOOD ANGELS"}}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), identity + " materializes without setup errors: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed: Array[Dictionary] = []
			var configured_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != identity: continue
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				observed.append(equipment.duplicate(true))
				var expected: Dictionary
				var lock_field: String
				if definition == Adapter.DEATH_COMPANY_CAPTAIN:
					expected = Profiles.death_company_captain_weapons(str(equipment.get("death_company_captain_pistol", "")), str(equipment.get("death_company_captain_melee", "")))
					lock_field = "death_company_captain_loadout_locked"
				else:
					expected = Profiles.death_company_jump_captain_weapons(str(equipment.get("death_company_jump_captain_loadout", "")))
					lock_field = "death_company_jump_captain_loadout_locked"
				check(Adapter.valid(definition, equipment, 1) and model.ranged_weapons == expected.ranged and model.melee_weapons == expected.melee and bool(model.get(lock_field, false)), identity + " materializes the exact saved ranged/melee profiles and locks them")
				if definition == Adapter.DEATH_COMPANY_JUMP_CAPTAIN:
					check(bool(model.get("relic_shield", false)) == bool(expected.get("relic_shield", false)) and int(model.get("max_wounds", 0)) == (6 if expected.get("relic_shield", false) else 5), "Jump Pack Captain preserves the saved Relic Shield wound adjustment")
				if equipment == configured: configured_model = model_id
			check(observed.size() == 2 and observed.any(func(value: Dictionary) -> bool: return value == configured) and observed.any(func(value: Dictionary) -> bool: return value == defaults), identity + " materializes configured and default copies independently")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			var suppressed: Array[String] = []
			if definition == Adapter.DEATH_COMPANY_JUMP_CAPTAIN: suppressed.append("death-company-jump-captain-loadout")
			else: suppressed.append_array(["death-company-captain-ranged-loadout", "death-company-captain-melee-loadout"])
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in suppressed), identity + " suppresses duplicate match-preparation choices for saved equipment")
			if configured_model >= 0:
				var configured_unit: Dictionary = state.units[configured_model]
				var before := configured_unit.duplicate(true)
				var action := "death-company-jump-captain-loadout" if definition == Adapter.DEATH_COMPANY_JUMP_CAPTAIN else "death-company-captain-ranged-loadout"
				var forced_value: String = "default" if definition == Adapter.DEATH_COMPANY_JUMP_CAPTAIN else "heavy-bolt-pistol"
				var forced := {"action": action, "model": configured_model, "target": int(configured_unit.get("squad", -1)), "value": forced_value}
				check(not C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision)).is_empty() and state.units[configured_model].ranged_weapons == before.ranged_weapons and state.units[configured_model].melee_weapons == before.melee_weapons, identity + " rejects forced edits without changing saved weapons")

	var panel := Builder.new()
	panel.storage_path = "user://%s-saved-loadout-editor.json" % identity
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	panel._render_sergeant_loadout_controls(1)
	check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, identity + " renders source-listed equipment controls")
	if panel.per_model_equipment_controls.get_child_count() > 0:
		var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
		picker.select(0)
		picker.item_selected.emit(0)
		var edited := Roster.model_equipment(panel.draft.entries[0], 1, 0)
		var first_descriptor: Dictionary = Adapter.controls(definition)[0]
		check(panel.dirty and edited.get(first_descriptor.field) == first_descriptor.choices[0].id and Roster.model_equipment(panel.draft.entries[0], 0, 0) == configured, identity + " editor updates only the selected stable copy")
	panel.free()
