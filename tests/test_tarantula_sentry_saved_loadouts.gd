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
	check(Adapter.valid(Adapter.TARANTULA_SENTRY_BATTERY, Adapter.defaults(Adapter.TARANTULA_SENTRY_BATTERY), 1), "Default Twin Heavy Bolter is a valid saved package")
	check(Adapter.valid(Adapter.TARANTULA_SENTRY_BATTERY, {"tarantula_sentry_primary": "twin-lascannon"}, 1), "Twin Lascannon is a valid saved replacement")
	check(not Adapter.valid(Adapter.TARANTULA_SENTRY_BATTERY, {"tarantula_sentry_primary": "invalid"}, 1), "Saved schema rejects any weapon outside the local source factory")
	check(not Adapter.valid(Adapter.TARANTULA_SENTRY_BATTERY, {"tarantula_sentry_primary": "twin-lascannon", "extra": true}, 1), "Saved schema rejects extra equipment fields")
	var list := Roster.new_list("11e", "Space Marines", "strike_force", 2000)
	var choice := Catalog.current_catalog_choice({"id": Adapter.TARANTULA_SENTRY_BATTERY, "edition": "11e", "faction": "Space Marines"})
	choice.role = Roster.role(choice.get("keywords", []))
	var option_index := -1
	for candidate_index in range(choice.options.size()):
		if int(choice.options[candidate_index].get("models", 0)) == 3: option_index = candidate_index
	check(option_index >= 0, "Local catalog exposes the three-model Tarantula choice")
	if option_index < 0:
		quit(1)
		return
	var entry := Roster.entry(choice, option_index, 3)
	check(Roster.set_model_equipment(entry, 0, 1, "tarantula_sentry_primary", "twin-lascannon"), "Workshop saves a Twin Lascannon to one model")
	check(Roster.set_model_equipment(entry, 1, 2, "tarantula_sentry_primary", "twin-lascannon"), "A separate unit copy saves an independent model's Twin Lascannon")
	check(Roster.model_equipment(entry, 0, 0).tarantula_sentry_primary == "twin-heavy-bolter" and Roster.model_equipment(entry, 0, 1).tarantula_sentry_primary == "twin-lascannon" and Roster.model_equipment(entry, 1, 2).tarantula_sentry_primary == "twin-lascannon" and Roster.model_equipment(entry, 2, 1).tarantula_sentry_primary == "twin-heavy-bolter", "Model and copy identities preserve separate saved primary weapons")
	list.entries.append(entry)
	check(Roster.validate(list).is_empty(), "Roster validates the 3-copy saved equipment configuration")
	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Current catalog accepts the saved Legends loadouts: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var selections := F.current_marine_selections()
		selections[1] = admitted.selection
		selections[1].category = "custom"
		selections[1].points_limit = 2000
		selections[2].category = "custom"
		selections[2].points_limit = 2000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "The saved weapon package prepares through the match factory: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed := 0
			var editable_model := -1
			for model_id: int in state.units:
				var model: Dictionary = state.units[model_id]
				if int(model.get("owner", -1)) != 1 or C.UnitAbilities.identity(model) != "tarantula-sentry-battery": continue
				observed += 1
				var package_id := str(model.get("tarantula_sentry_primary", ""))
				var weapons := Profiles.tarantula_sentry_battery_weapons(package_id)
				check(not weapons.is_empty() and model.ranged_weapons == weapons.ranged and bool(model.get("tarantula_sentry_loadout_locked", false)), "Each prepared model receives its exact saved weapon and match lock")
				if package_id == "twin-heavy-bolter": editable_model = model_id
			check(observed == 9, "All three 3-model Tarantula copies materialize their per-model choices")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) == "tarantula-sentry-battery-loadout"), "Saved Army Workshop weapon suppresses the duplicate preparation choice")
			if editable_model >= 0:
				var model: Dictionary = state.units[editable_model]
				var before: Array = model.ranged_weapons.duplicate(true)
				var forced := {"action": "tarantula-sentry-battery-loadout", "model": editable_model, "target": int(model.get("squad", -1)), "value": "twin-lascannon"}
				var result: String = C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
				check(not result.is_empty() and state.units[editable_model].ranged_weapons == before, "Forced Army Preparation cannot overwrite saved equipment")

	var panel := Builder.new()
	panel.storage_path = "user://tarantula-sentry-saved-loadouts-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.per_model_equipment_controls.get_child_count() == 3, "Workshop renders one registered equipment row per Tarantula model")
	panel.sergeant_loadout_copy_picker.select(2)
	panel._render_sergeant_loadout_controls(2)
	if panel.per_model_equipment_controls.get_child_count() == 3:
		var model_two_row := panel.per_model_equipment_controls.get_child(2) as HBoxContainer
		var weapon_picker := model_two_row.get_child(2) as OptionButton
		weapon_picker.select(1)
		weapon_picker.item_selected.emit(1)
		check(Roster.model_equipment(panel.draft.entries[0], 2, 2).tarantula_sentry_primary == "twin-lascannon" and Roster.model_equipment(panel.draft.entries[0], 0, 1).tarantula_sentry_primary == "twin-lascannon" and Roster.model_equipment(panel.draft.entries[0], 1, 2).tarantula_sentry_primary == "twin-lascannon" and Roster.model_equipment(panel.draft.entries[0], 2, 0).tarantula_sentry_primary == "twin-heavy-bolter", "Editor signal changes only the selected model and copy while retaining other configurations")
	panel.free()
	print("Tarantula Sentry Battery saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)
