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
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for definition: String in [Adapter.VINDICATOR, Adapter.WHIRLWIND, Adapter.HAMMERFALL, Adapter.NEPHILIM, Adapter.CERBERUS, Adapter.TYPHON, Adapter.FALCHION]:
		var identity := definition.get_slice(":", 3)
		var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
		choice.role = Roster.role(choice.get("keywords", []))
		var list := Roster.new_list("11e", "Space Marines", "custom", 3000)
		var item: Dictionary = Roster.entry(choice, 0, 2)
		for descriptor: Dictionary in Adapter.controls(definition):
			var field := str(descriptor.field)
			Roster.set_model_equipment(item, 0, 0, field, descriptor.choices[1].id)
		list.entries.append(item)
		var admitted := Training.admit_current_catalog(list)
		check(admitted.error.is_empty(), identity + " choices pass local current-catalog admission: " + str(admitted.get("error", "")))
		if admitted.error.is_empty():
			var variants: Array = admitted.selection.get("entries", [])
			check(variants.size() == 2 and variants.all(func(entry: Dictionary) -> bool: return entry.has("saved_model_loadouts")), identity + " keeps independently configured copies separate")
			var selections := F.current_marine_selections()
			selections[1] = admitted.selection
			selections[2].category = "custom"
			selections[2].points_limit = 3000
			var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
			check(not state.has("error"), identity + " materializes: " + str(state.get("error", "")))
			if not state.has("error"):
				var found: Array[Dictionary] = []
				var observed_equipment: Array[Dictionary] = []
				for model_id: int in state.units:
					var model: Dictionary = state.units[model_id]
					if int(model.get("owner", -1)) != 1 or F.C.UnitAbilities.identity(model) != identity: continue
					found.append(model)
					var equipment: Dictionary = model.get("saved_model_equipment", {})
					observed_equipment.append(equipment.duplicate(true))
					check(Adapter.valid(definition, equipment, 1), identity + " carries a valid saved equipment record into match creation")
					var expected: Variant
					if identity == "vindicator": expected = Profiles.vindicator_weapons(bool(equipment.get("vindicator_storm_bolter", false)), bool(equipment.get("vindicator_hunter_killer_missile", false)))
					elif identity == "whirlwind": expected = Profiles.whirlwind_weapons(bool(equipment.get("whirlwind_hunter_killer_missile", false)), bool(equipment.get("whirlwind_storm_bolter", false)))
					elif identity == "hammerfall-bunker": expected = Profiles.hammerfall_weapons(bool(equipment.get("hammerfall_heavy_flamer_array", false)))
					elif identity == "nephilim-jetfighter": expected = Profiles.nephilim_jetfighter_weapons(str(equipment.get("nephilim_lascannon_package", "twin-heavy-bolter")) == "lascannons")
					elif identity == "cerberus": expected = Profiles.cerberus_weapons(str(equipment.get("cerberus_optional_weapon", "none")), str(equipment.get("cerberus_optional_pair", "none")))
					elif identity == "typhon": expected = Profiles.typhon_weapons(str(equipment.get("typhon_sponson_package", "none")), str(equipment.get("typhon_hull_weapon", "none")))
					else: expected = Profiles.falchion_weapons(str(equipment.get("falchion_optional_weapon", "none")), str(equipment.get("falchion_main_armament", "quad-lascannons")), str(equipment.get("falchion_twin_replacement", "twin-heavy-bolter")))
					var expected_ranged: Array = expected.get("ranged", []) if expected is Dictionary else expected
					var actual_weapon_ids: Array[String] = []
					var expected_weapon_ids: Array[String] = []
					for weapon: Dictionary in model.ranged_weapons: actual_weapon_ids.append(str(weapon.get("id", "")))
					for weapon: Dictionary in expected_ranged: expected_weapon_ids.append(str(weapon.get("id", "")))
					var lock_field := identity + "_loadout_locked"
					if identity == "hammerfall-bunker": lock_field = "hammerfall_loadout_locked"
					elif identity == "nephilim-jetfighter": lock_field = "nephilim_loadout_locked"
					check(bool(model.get(lock_field, false)) and model.ranged_weapons == expected_ranged, "%s exact saved weapon package is installed and locked; %s=%s, actual=%s, expected=%s" % [identity, lock_field, str(model.get(lock_field, false)), str(actual_weapon_ids), str(expected_weapon_ids)])
				check(found.size() == 2, identity + " materializes both configured copies")
				var selected_equipment := Roster.model_equipment(item, 0, 0)
				var default_equipment := Adapter.defaults(definition)
				check(observed_equipment.any(func(value: Dictionary) -> bool: return value == selected_equipment) and observed_equipment.any(func(value: Dictionary) -> bool: return value == default_equipment), identity + " keeps distinct saved choices on their separate unit copies")
				state.phase = "deployment"
				state.active = 1
				state.unit_abilities.setup_players = []
				var action_names: Array[String] = [identity + "-loadout"]
				if identity == "cerberus": action_names = ["cerberus-optional-weapon", "cerberus-optional-pair"]
				elif identity == "typhon": action_names = ["typhon-sponsons", "typhon-hull-weapon"]
				elif identity == "falchion": action_names = ["falchion-optional-weapon", "falchion-main-armament", "falchion-twin-replacement"]
				check(not Actions.choices(state, 1).any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in action_names), identity + " saved equipment suppresses its duplicate setup choices")
		var panel := Builder.new()
		panel.storage_path = "user://%s-loadout-editor.json" % identity
		root.add_child(panel)
		panel.draft = list.duplicate(true)
		panel._render_draft()
		panel._select_entry(0)
		panel._render_sergeant_loadout_controls(1)
		check(panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2, identity + " renders the two saved optional weapons")
		if panel.per_model_equipment_controls.get_child_count() == Adapter.controls(definition).size() * 2:
			var picker := panel.per_model_equipment_controls.get_child(1) as OptionButton
			picker.select(0)
			picker.item_selected.emit(0)
			var edited := Roster.model_equipment(panel.draft.entries[0], 1, 0)
			var first_descriptor: Dictionary = Adapter.controls(definition)[0]
			var first_field := str(first_descriptor.field)
			check(panel.dirty and edited[first_field] == first_descriptor.choices[0].id and Roster.model_equipment(panel.draft.entries[0], 0, 0)[first_field] == first_descriptor.choices[1].id, identity + " editor signal updates only the selected stable copy")
		panel.free()
	var invalid := Adapter.defaults(Adapter.VINDICATOR)
	invalid.vindicator_storm_bolter = "true"
	check(not Adapter.valid(Adapter.VINDICATOR, invalid, 1), "Saved optional weapons reject wrong value types")
	print("Optional vehicle saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)
