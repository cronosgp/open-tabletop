extends SceneTree
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const R = preload("res://scripts/army_roster.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const Save = preload("res://scripts/match_save.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const PREFIX := "40kdc:11e:adeptus-astartes:"
const IDS := ["corvus-blackstar", "mastodon"]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func packages(id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if id == "corvus-blackstar":
		for mask in range(8):
			result.append({"transport_add_hurricane_bolter": (mask & 1) != 0, "transport_replace_twin_assault_cannon": "twin-lascannon" if (mask & 2) != 0 else "twin-assault-cannon", "transport_group_blackstar_rocket_launchers": (mask & 4) != 0})
	else:
		for flamers in ["default", "heavy-bolters", "lascannons", "volkite-culverins"]:
			for lascannons in ["default", "heavy-bolters", "heavy-flamers", "volkite-culverins"]:
				result.append({"transport_group_heavy_flamers": flamers, "transport_group_lascannons": lascannons})
	return result

func inspect(unit: Dictionary, id: String, equipment: Dictionary) -> void:
	var profile := P.profile(id)
	var expected: Array = []
	if id == "corvus-blackstar":
		expected = ["stormstrike-missile-launcher-left", "stormstrike-missile-launcher-right"] if equipment.transport_group_blackstar_rocket_launchers else ["blackstar-rocket-launcher-left", "blackstar-rocket-launcher-right"]
		expected.append(str(equipment.transport_replace_twin_assault_cannon))
		if bool(equipment.transport_add_hurricane_bolter): expected.append("hurricane-bolter")
		for weapon: Dictionary in unit.ranged_weapons:
			for stats: Dictionary in weapon.profiles.values(): check(bool(stats.keywords.get("ignores-cover", false)), "Corvus retains the source Auspex effect on every equipped ranged profile")
	else:
		expected = ["siege-melta-array", "skyreaper-battery"]
		var flamers := {"default": "mastodon-heavy-flamer", "heavy-bolters": "mastodon-hb-for-flamers", "lascannons": "mastodon-las-for-flamers", "volkite-culverins": "mastodon-volkite-for-flamers"}
		var lascannons := {"default": "mastodon-lascannon", "heavy-bolters": "mastodon-hb-for-lascannons", "heavy-flamers": "mastodon-flamer-for-lascannons", "volkite-culverins": "mastodon-volkite-for-lascannons"}
		for side in ["left", "right"]:
			expected.append(str(flamers[equipment.transport_group_heavy_flamers]) + "-" + side)
			expected.append(str(lascannons[equipment.transport_group_lascannons]) + "-" + side)
	var actual: Array = unit.ranged_weapons.map(func(w: Dictionary) -> String: return str(w.id))
	expected.sort()
	actual.sort()
	check(actual == expected, "Both source pairs and fixed main weapons materialize exactly: " + id)
	var source_weapons: Array = profile.ranged + profile.additional_weapon_profiles.ranged
	for weapon: Dictionary in unit.ranged_weapons: check(source_weapons.any(func(w: Dictionary) -> bool: return w == weapon), "Every equipped weapon preserves all source profile fields")
	check(unit.melee_weapons == profile.melee and unit.transport_loadout_locked, "Melee and saved transport lock are retained")

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	for id: String in IDS:
		var item := R.entry(catalog.lookup(PREFIX + id), 0, 2)
		var options := packages(id)
		for field: String in options[-1]: check(R.set_model_equipment(item, 0, 0, field, options[-1][field]), "Each reviewed source group saves on its own copy")
		army.entries.append(item)
	return army

func check_bank(army: Dictionary) -> void:
	check(army.entries.size() == 2 and R.validate(army).is_empty(), "Both transport records and source types reopen")
	var report := Training.admit_current_catalog(army)
	check(report.error.is_empty() and int(report.get("total", 0)) == 1440 and R.summary(army).points == 1440, "Saved armies preserve the source total of 1440 points")
	for item: Dictionary in army.entries:
		var id := str(item.unit_id).get_slice(":", 3)
		check(R.model_equipment(item, 0, 0) == packages(id)[-1] and R.model_equipment(item, 1, 0) == E.defaults(str(item.unit_id)), "Configured and default stable copies remain independent")

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var store := Store.new(args[1])
		check(store.error.is_empty() and store.active().lists.size() == 1, "Separate Godot process reopens the transport bank")
		if store.error.is_empty() and store.active().lists.size() == 1: check_bank(store.active().lists[0])
		quit(1 if failures else 0)
		return
	for id: String in IDS:
		var definition := PREFIX + id
		var options := packages(id)
		check(options.size() == (8 if id == "corvus-blackstar" else 16), "Independent source package matrix has the exact count")
		for equipment: Dictionary in options:
			check(E.valid(definition, equipment, 1), "All source-listed combinations have strict saved schemas")
			var unit := {}
			E.prepare(unit, definition, equipment)
			inspect(unit, id, equipment)
			check(E.points_for_loadout(definition, equipment, 1) == 0, "No absent equipment surcharge is invented")
		var invalid := options[0].duplicate(true)
		invalid.unlisted = true
		check(not E.valid(definition, invalid, 1) and not E.valid(definition, options[0], 2), "Unknown fields and multi-model transport records fail closed")
		invalid = options[0].duplicate(true)
		invalid[invalid.keys()[0]] = 1
		check(not E.valid(definition, invalid, 1), "Wrong saved value types fail closed")
	var invalid_pair := E.defaults(PREFIX + "corvus-blackstar")
	invalid_pair.transport_group_blackstar_rocket_launchers = "on"
	check(not E.valid(PREFIX + "corvus-blackstar", invalid_pair, 1), "Paired boolean equipment cannot be confused with legacy command strings")
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated current catalog opens offline")
	var army := make_army(catalog)
	check_bank(army)
	var path := ProjectSettings.globalize_path("user://large-transports-%d.json" % OS.get_process_id())
	var store := Store.new(path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Transport list saves without optional downloads")
	var output: Array = []
	check(OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_large_transport_saved_loadouts.gd", "--", "--reopen", path], output, true) == 0, "Second process validates typed equipment and costs: " + str(output))
	var report := Training.admit_current_catalog(army)
	if report.error.is_empty():
		var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, {1: report.selection, 2: report.selection})
		check(not state.has("error"), "Both players materialize the saved aircraft/Legends army: " + str(state.get("error", "")))
		if not state.has("error"):
			var refs := Training.stable_model_refs(army, report.selection)
			check(refs.error.is_empty(), "Stable copy IDs map to frozen canonical positions")
			if refs.error.is_empty():
				for owner: int in [1, 2]:
					var total := 0
					for squad: Dictionary in state.squads.values():
						if int(squad.owner) == owner: total += int(squad.training_cost)
					check(total == 1440 and int(state.training_points[owner]) == 1440, "Prepared squad costs agree with source admission")
					for item: Dictionary in army.entries:
						for copy_index in range(2):
							var ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, 0)]
							var model := (owner + int(ref.unit_index) * 2) * 100 + int(ref.model_index)
							var equipment := R.model_equipment(item, copy_index, 0)
							check(state.units[model].saved_model_equipment == equipment, "Frozen model retains exact boolean and enum group records")
							inspect(state.units[model], str(item.unit_id).get_slice(":", 3), equipment)
			check(Transport.transport_weapon_loadout_choices(state, 1).is_empty(), "No saved transport weapons are offered again during readiness")
			for model: int in state.units:
				var before := state.duplicate(true)
				check(not Transport.configure_optional_transport_weapon(state, model, "group:blackstar-rocket-launchers:on").is_empty() and state == before, "Forced group changes cannot mutate saved match equipment")
			var frozen := state.duplicate(true)
			check(Save.write(state, {}, 42, {}, path + ".match").is_empty(), "Transport match saves")
			check(R.set_model_equipment(saved.list.entries[0], 0, 0, "transport_group_blackstar_rocket_launchers", false) and store.save_list(saved.list).error.is_empty(), "Source army can change the launcher pair later")
			var loaded := Save.read(path + ".match")
			check(not loaded.has("error") and loaded.state == frozen, "Later source edits cannot alter the captured match")
	var panel := Builder.new()
	panel.storage_path = path + ".panel"
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	for index in range(2):
		panel._select_entry(index)
		var descriptors := E.controls(PREFIX + IDS[index])
		check(panel.per_model_equipment_controls.get_child_count() == descriptors.size() * 2, "Workshop exposes every source group")
		for field_index in range(descriptors.size()):
			var picker := panel.per_model_equipment_controls.get_child(field_index * 2 + 1) as OptionButton
			var value: Variant = picker.get_item_metadata(0)
			picker.select(0)
			picker.item_selected.emit(0)
			check(panel.dirty and R.model_equipment(panel.draft.entries[index], 0, 0)[descriptors[field_index].field] == value, "Real Workshop selector persists its source-typed choice")
			check(R.model_equipment(panel.draft.entries[index], 1, 0) == E.defaults(PREFIX + IDS[index]), "Workshop edit preserves the other copy")
		check(R.summary(panel.draft).points == 1440 and Training.admit_current_catalog(panel.draft).total == 1440, "Every group edit preserves source points")
	panel.free()
	catalog.free()
	for suffix in ["", ".bak", ".match", ".match.bak", ".panel"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	await process_frame
	print("Saved large transport equipment: %d failures" % failures)
	quit(1 if failures else 0)
