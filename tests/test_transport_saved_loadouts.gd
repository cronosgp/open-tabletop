extends SceneTree
const Adapter = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const TransportEquipment = preload("res://scripts/edition_11/transport_equipment.gd")
const Marines = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Roster = preload("res://scripts/army_roster.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Save = preload("res://scripts/match_save.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Defense = preload("res://scripts/edition_11/defender_groups.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const PREFIX := "40kdc:11e:adeptus-astartes:"
const COUNTS := {"land-raider": 8, "land-raider-crusader": 8, "land-raider-redeemer": 8, "land-raider-excelsior": 16, "razorback": 8, "relic-razorback": 16, "repulsor": 4, "repulsor-executioner": 2, "black-templars-repulsor": 8, "black-templars-repulsor-executioner": 4, "impulsor": 20, "black-templars-impulsor": 24}
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func packages(id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if id in ["impulsor", "black-templars-impulsor"]:
		var systems := ["none", "bellicatus-missile-array", "orbital-comms-array", "shield-dome"]
		var pintles := ["none", "ironhail-heavy-stubber"]
		if id == "impulsor":
			systems.erase("orbital-comms-array")
			systems.append_array(["ironhail-skytalon-array", "orbital-comms-array"])
		else: pintles.append("multi-melta")
		for system: String in systems:
			for pintle: String in pintles:
				for fragstorm in [false, true]: result.append({"impulsor_system": system, "impulsor_pintle": pintle, "impulsor_fragstorm_launchers": fragstorm})
	elif id.begins_with("land-raider"):
		for mask in range(16 if id == "land-raider-excelsior" else 8):
			var equipment := {"transport_add_hunter_killer_missile": (mask & 1) != 0, "transport_add_multi_melta": (mask & 2) != 0, "transport_add_storm_bolter": (mask & 4) != 0}
			if id == "land-raider-excelsior": equipment.transport_add_combi_weapon = (mask & 8) != 0
			result.append(equipment)
	elif id in ["razorback", "relic-razorback"]:
		var primaries := ["default", "twin-lascannon"]
		if id == "relic-razorback": primaries.append_array(["multi-melta", "twin-assault-cannon"])
		for primary: String in primaries:
			for mask in range(4): result.append({"transport_group_primary_weapon": primary, "transport_add_hunter_killer_missile": (mask & 1) != 0, "transport_add_storm_bolter": (mask & 2) != 0})
	elif id.ends_with("repulsor"):
		for mask in range(8 if id.begins_with("black-templars") else 4):
			var equipment := {"transport_replace_heavy_onslaught_gatling_cannon": "las-talon" if (mask & 1) != 0 else "heavy-onslaught-gatling-cannon", "transport_replace_twin_heavy_bolter": "twin-lascannon" if (mask & 2) != 0 else "twin-heavy-bolter"}
			if id.begins_with("black-templars"): equipment.transport_add_multi_melta = (mask & 4) != 0
			result.append(equipment)
	else:
		for mask in range(4 if id.begins_with("black-templars") else 2):
			var equipment := {"transport_replace_heavy_laser_destroyer": "macro-plasma-incinerator" if (mask & 1) != 0 else "heavy-laser-destroyer"}
			if id.begins_with("black-templars"): equipment.transport_add_multi_melta = (mask & 2) != 0
			result.append(equipment)
	return result

func expected_cost(id: String, equipment: Dictionary) -> int:
	var points := 0
	if id == "repulsor-executioner" and equipment.transport_replace_heavy_laser_destroyer == "heavy-laser-destroyer": points += 10
	if id.begins_with("black-templars") and (bool(equipment.get("transport_add_multi_melta", false)) or equipment.get("impulsor_pintle", "none") == "multi-melta"): points += 10
	if equipment.get("impulsor_system", "none") == "orbital-comms-array": points += 10
	return points

func inspect(unit: Dictionary, id: String, equipment: Dictionary) -> void:
	var profile := Marines.profile(id)
	var expected: Array = profile.ranged.duplicate(true)
	# Independent expected ID set, then compare every weapon profile field.
	var ids: Array = expected.map(func(w: Dictionary) -> String: return str(w.id))
	if equipment.has("impulsor_system"):
		if equipment.impulsor_fragstorm_launchers:
			ids.erase("storm-bolters")
			ids.append("fragstorm-grenade-launchers")
		if equipment.impulsor_system in ["bellicatus-missile-array", "ironhail-skytalon-array"]: ids.append(equipment.impulsor_system)
		if equipment.impulsor_pintle != "none": ids.append(equipment.impulsor_pintle)
	else:
		for field: String in equipment:
			if field.begins_with("transport_add_") and equipment[field]: ids.append(field.trim_prefix("transport_add_").replace("_", "-"))
			if field.begins_with("transport_replace_"):
				ids.erase(field.trim_prefix("transport_replace_").replace("_", "-"))
				ids.append(equipment[field])
			if field == "transport_group_primary_weapon" and equipment[field] != "default":
				ids.erase("twin-heavy-bolter")
				ids.append(equipment[field])
	var actual: Array = unit.ranged_weapons.map(func(w: Dictionary) -> String: return str(w.id))
	ids.sort()
	actual.sort()
	check(ids == actual, id + " has exactly its selected weapons, without duplicate pintles or lost fixed weapons")
	for weapon: Dictionary in unit.ranged_weapons:
		var source: Array = profile.ranged + profile.get("additional_weapon_profiles", {}).get("ranged", [])
		check(source.any(func(w: Dictionary) -> bool: return w == weapon), id + " retains every source weapon profile field")
	check(unit.melee_weapons == profile.melee and unit.transport_loadout_locked, id + " retains melee and its saved lock")

func make_army(catalog: Node) -> Dictionary:
	var army := Roster.new_list("11e", "Space Marines", "custom", 10000)
	for id: String in COUNTS:
		var source: Dictionary = catalog.lookup(PREFIX + id)
		var item := Roster.entry(source, 0, 1 if id == "land-raider-excelsior" else 2)
		var selections := packages(id)
		for copy_index in range(int(item.copies)):
			var equipment: Dictionary = selections[selections.size() - 1] if copy_index == 0 else Adapter.defaults(PREFIX + id)
			for field: String in equipment: check(Roster.set_model_equipment(item, copy_index, 0, field, equipment[field]), "A reviewed transport choice saves on its independent copy")
		army.entries.append(item)
	return army

func check_bank(army: Dictionary) -> void:
	check(army.entries.size() == 12, "All twelve transport identities survive disk reopen")
	var report := Training.admit_current_catalog(army)
	check(report.error.is_empty(), "Saved mixed transport army is admitted: " + str(report.error))
	check(int(report.get("total", -1)) == 4290 and Roster.summary(army).points == 4290, "Builder and admission agree on saved transport prices")
	for item: Dictionary in army.entries:
		var id := str(item.unit_id).get_slice(":", 3)
		check(Roster.model_equipment(item, 0, 0) == packages(id)[COUNTS[id] - 1], "The configured first copy survives reopen: " + id)
		if int(item.copies) > 1:
			check(Roster.model_instance_id(item, 0, 0) != Roster.model_instance_id(item, 1, 0) and Roster.model_equipment(item, 1, 0) == Adapter.defaults(str(item.unit_id)), "Default and configured copies remain independent: " + id)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate process reopens the transport army bank")
		if store.error.is_empty() and store.active().lists.size() == 1: check_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	for id: String in COUNTS:
		var definition := PREFIX + id
		var selections := packages(id)
		check(selections.size() == COUNTS[id], "Independent source package matrix: " + id)
		for equipment: Dictionary in selections:
			check(Adapter.valid(definition, equipment, 1), "Every source package validates: " + id)
			var unit := {}
			Adapter.prepare(unit, definition, equipment)
			if unit.has("ranged_weapons"): inspect(unit, id, equipment)
			else: check(false, "Source package materializes: " + id)
			check(Adapter.points_for_loadout(definition, equipment, 1) == expected_cost(id, equipment), "Independent source surcharge matrix: " + id)
		var invalid := selections[0].duplicate(true)
		invalid.unlisted = true
		check(not Adapter.valid(definition, invalid, 1) and not Adapter.valid(definition, selections[0], 2), "Unknown fields and multi-model transport records fail closed")
		var first_field: String = selections[0].keys()[0]
		invalid = selections[0].duplicate(true)
		invalid[first_field] = 1
		check(not Adapter.valid(definition, invalid, 1), "Wrong saved value types fail closed")
	var forbidden := Adapter.defaults(PREFIX + "black-templars-impulsor")
	forbidden.impulsor_system = "ironhail-skytalon-array"
	check(not Adapter.valid(PREFIX + "black-templars-impulsor", forbidden, 1), "Black Templars cannot inherit the shared-book Skytalon option")
	var multi_melta_source := {"name": "Multi-melta", "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}}
	for id in ["black-templars-impulsor", "black-templars-repulsor", "black-templars-repulsor-executioner"]:
		var weapon := Marines.additional_weapon(id, "ranged", "multi-melta")
		check(not weapon.is_empty() and weapon.profiles.standard == multi_melta_source, "BT Multi-melta matches every field in its own verified source sheet")
	var budget := Roster.new_list("11e", "Space Marines", "custom", 140)
	budget.entries.append(Roster.entry(catalog.lookup(PREFIX + "impulsor"), 0, 2))
	check(Training.admit_current_catalog(budget).error.is_empty(), "Default transport copies fit the exact source base budget")
	check(Roster.set_model_equipment(budget.entries[0], 0, 0, "impulsor_system", "orbital-comms-array") and Roster.summary(budget).points == 150 and not Training.admit_current_catalog(budget).error.is_empty(), "Orbital surcharge cannot bypass the saved army budget")
	var army := make_army(catalog)
	check_bank(army)
	var path := ProjectSettings.globalize_path("user://transport-loadouts-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Transport army saves without downloaded miniatures")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_transport_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Separate process validates transport army: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "All twelve saved transport profiles enter a frozen match: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Transport stable IDs map to canonical snapshot positions")
			if refs.error.is_empty():
				for owner in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == int(report.total) and int(state.training_points[owner]) == total, "Prepared squad prices sum to canonical admission")
					for item: Dictionary in army.entries:
						for copy_index in range(int(item.copies)):
							var ref: Dictionary = refs.models[Roster.model_instance_id(item, copy_index, 0)]
							var model: int = (int(owner) + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
							var equipment := Roster.model_equipment(item, copy_index, 0)
							check(state.units[model].saved_model_equipment == equipment, "Snapshot retains each model's exact transport equipment")
							inspect(state.units[model], str(item.unit_id).get_slice(":", 3), equipment)
			state.unit_abilities.setup_players = []
			check(Transport.impulsor_loadout_choices(state, 1).is_empty() and Transport.transport_weapon_loadout_choices(state, 1).is_empty(), "Saved transport equipment is absent from readiness choices")
			for model: int in state.units:
				var unit: Dictionary = state.units[model]
				if int(unit.owner) != 1: continue
				var before := state.duplicate(true)
				var error := Transport.configure_impulsor(state, model, 0, "shield-dome") if TransportEquipment.is_impulsor(str(unit.definition_id)) else Transport.configure_optional_transport_weapon(state, model, "hunter-killer-missile:on")
				check(not error.is_empty() and before == state, "Direct forced setup cannot mutate saved transport equipment or points")
				if unit.get("impulsor_system", "") == "shield-dome": check(int(Defense.profile(state, model).invulnerable_target) == 5, "Saved Shield Dome grants its actual defensive effect")
				if unit.get("impulsor_system", "") == "orbital-comms-array": check(Abilities.scout_distance(state, int(unit.squad)) == 6 and Transport.datasheet_has_ability(state, model, "Orbital Comms Array"), "Saved Orbital system grants Scouts 6 through the actual rules path")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Frozen transport match saves")
			check(Roster.set_model_equipment(saved.list.entries[0], 0, 0, "transport_add_storm_bolter", false) and store.save_list(saved.list).error.is_empty(), "Source army can change after match creation")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Later army edits cannot change saved match weapons or prices")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(army.entries.size()):
		panel._select_entry(index)
		var definition := str(army.entries[index].unit_id)
		var descriptors := Adapter.controls(definition)
		check(panel.per_model_equipment_controls.get_child_count() == descriptors.size() * 2, "Workshop exposes all transport option groups")
		for field_index in range(descriptors.size()):
			var descriptor: Dictionary = descriptors[field_index]
			var picker := panel.per_model_equipment_controls.get_child(field_index * 2 + 1) as OptionButton
			var selected := 0 if picker.selected != 0 else picker.item_count - 1
			var value: Variant = picker.get_item_metadata(selected)
			var other := Roster.model_equipment(panel.draft.entries[index], 1, 0).duplicate(true) if int(army.entries[index].copies) > 1 else {}
			picker.select(selected)
			picker.item_selected.emit(selected)
			check(panel.dirty and Roster.model_equipment(panel.draft.entries[index], 0, 0)[descriptor.field] == value, "Real Workshop signal updates the selected copy")
			if not other.is_empty(): check(other == Roster.model_equipment(panel.draft.entries[index], 1, 0), "Workshop edit leaves the other copy untouched")
		check(Training.admit_current_catalog(panel.draft).total == Roster.summary(panel.draft).points, "Live Workshop prices match canonical admission after source option changes")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Saved transport equipment: %d failures" % failures)
	quit(1 if failures else 0)
