extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const VETERANS := "40kdc:11e:adeptus-astartes:deathwatch-veterans"
const TERMINATORS := "40kdc:11e:adeptus-astartes:deathwatch-terminator-squad"
const LOCKED_ACTIONS := ["deathwatch-veteran-loadout", "deathwatch-sergeant-ranged-loadout", "deathwatch-sergeant-melee-loadout", "deathwatch-terminator-loadout", "terminator-special-weapon"]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func records(definition: String, models: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for _index in range(models): result.append(E.defaults(definition).duplicate(true))
	return result

func entry(catalog: Node, definition: String, models: int, copies: int) -> Dictionary:
	var source: Dictionary = catalog.lookup(definition)
	for index in range(source.options.size()):
		if int(source.options[index].models) == models: return R.entry(source, index, copies)
	check(false, "Admitted Deathwatch squad size exists in the local catalog")
	return {}

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, VETERANS, 5, 3), entry(catalog, TERMINATORS, 5, 3)]
	check(R.set_model_equipment(army.entries[0], 0, 1, "deathwatch_veteran_loadout", "stalker-pattern-boltgun"), "Veteran saved equipment edits one stable model in one copy")
	check(R.set_model_equipment(army.entries[0], 1, 1, "deathwatch_veteran_loadout", "frag-cannon"), "Another Veteran copy retains its independent Frag Cannon")
	check(R.set_model_equipment(army.entries[0], 2, 1, "deathwatch_veteran_loadout", "boltgun-storm-shield"), "A third Veteran copy stores its own Storm Shield")
	check(R.set_model_equipment(army.entries[1], 0, 1, "terminator_special_weapon", "cyclone-missile-launcher"), "Deathwatch Cyclone saves with its Storm Bolter")
	check(R.set_model_equipment(army.entries[1], 0, 2, "terminator_special_weapon", "plasma-cannon"), "Deathwatch Plasma Cannon saves as an independent special choice")
	check(R.set_model_equipment(army.entries[1], 0, 3, "terminator_special_weapon", "assault-cannon"), "The third Deathwatch special weapon can be assigned")
	check(R.set_model_equipment(army.entries[1], 1, 1, "terminator_special_weapon", "assault-cannon"), "A second Deathwatch copy can save a different special weapon")
	check(R.set_model_equipment(army.entries[1], 1, 2, "deathwatch_terminator_melee_package", "thunder-hammer-storm-shield"), "Each Deathwatch Shield is priced per model")
	check(R.set_model_equipment(army.entries[1], 1, 3, "deathwatch_terminator_melee_package", "storm-bolter-chainfist"), "Chainfist package can coexist with another model's special weapon")
	check(R.set_model_equipment(army.entries[1], 2, 3, "deathwatch_terminator_melee_package", "thunder-hammer-storm-shield"), "A separate Deathwatch copy saves an independent Storm Shield")
	return army

func check_source_limits() -> void:
	check(E.supports(VETERANS) and E.supports(TERMINATORS) and E.is_model_scoped(VETERANS) and E.is_model_scoped(TERMINATORS), "Both Deathwatch profiles use persisted, per-model equipment")
	check(E.model_label(VETERANS, 5, 0) == "Watch Sergeant" and E.model_label(VETERANS, 5, 1) == "Deathwatch Veteran 2" and E.model_label(TERMINATORS, 5, 0) == "Terminator Sergeant", "Saved model rows name each Deathwatch role")
	for definition: String in [VETERANS, TERMINATORS]:
		for models: int in [5, 10]:
			var defaults := records(definition, models)
			check(E.valid_saved_loadout(definition, defaults, models) and E.points_for_loadout(definition, defaults, models) == 0, "Source defaults form a valid zero-point %s list" % definition)
			check(not E.valid_saved_loadout(definition, defaults.slice(0, models - 1), models), "Incomplete %s model record arrays are rejected" % definition)
	check(not E.valid_saved_loadout(VETERANS, records(VETERANS, 4), 4) and not E.valid_saved_loadout(TERMINATORS, records(TERMINATORS, 6), 6), "Only the source-priced five- and ten-model squad sizes are saved")
	var invalid_shape := E.defaults(VETERANS)
	invalid_shape.extra = false
	check(not E.valid(VETERANS, invalid_shape, 5) and not E.valid(VETERANS, {"deathwatch_veteran_loadout": 1, "deathwatch_sergeant_ranged_loadout": "boltgun", "deathwatch_sergeant_melee_loadout": "power-weapon"}, 5), "Veteran records reject extra fields and wrong types")
	var five := records(VETERANS, 5)
	five[1].deathwatch_veteran_loadout = "stalker-pattern-boltgun"
	check(E.valid_saved_loadout(VETERANS, five, 5), "One Stalker-pattern Boltgun is allowed in five Veterans")
	five[2].deathwatch_veteran_loadout = "stalker-pattern-boltgun"
	check(not E.valid_saved_loadout(VETERANS, five, 5), "A second Stalker-pattern Boltgun exceeds the five-model cap")
	var ten := records(VETERANS, 10)
	for index in [1, 2]: ten[index].deathwatch_veteran_loadout = "stalker-pattern-boltgun"
	check(E.valid_saved_loadout(VETERANS, ten, 10), "Ten Veterans can take two Stalker-pattern Boltgun replacements")
	for index in [3, 4]: ten[index].deathwatch_veteran_loadout = "frag-cannon"
	check(E.valid_saved_loadout(VETERANS, ten, 10), "Ten Veterans can take two Frag Cannons alongside other per-five options")
	ten[5].deathwatch_veteran_loadout = "frag-cannon"
	check(not E.valid_saved_loadout(VETERANS, ten, 10), "A third Frag Cannon exceeds its per-five cap")
	var shield_loadout := records(VETERANS, 5)
	shield_loadout[1].deathwatch_veteran_loadout = "boltgun-storm-shield"
	shield_loadout[2].deathwatch_veteran_loadout = "power-weapon-storm-shield"
	check(E.valid_saved_loadout(VETERANS, shield_loadout, 5), "Both Storm Shield replacement combinations share a two-per-five cap")
	shield_loadout[3].deathwatch_veteran_loadout = "boltgun-storm-shield"
	check(not E.valid_saved_loadout(VETERANS, shield_loadout, 5), "A third Veteran Storm Shield exceeds the combined cap")
	var black_shields := records(VETERANS, 10)
	black_shields[1].deathwatch_veteran_loadout = "black-shield-blades"
	black_shields[2].deathwatch_veteran_loadout = "black-shield-blades"
	check(not E.valid_saved_loadout(VETERANS, black_shields, 10), "Only one Black Shield Blades replacement is allowed in the whole unit")
	var bad_role := records(VETERANS, 5)
	bad_role[0].deathwatch_veteran_loadout = "stalker-pattern-boltgun"
	check(not E.valid_saved_loadout(VETERANS, bad_role, 5), "The Watch Sergeant cannot receive a Veteran-only package")
	bad_role = records(VETERANS, 5)
	bad_role[1].deathwatch_sergeant_ranged_loadout = "combi-weapon"
	check(not E.valid_saved_loadout(VETERANS, bad_role, 5), "A Veteran record cannot store Watch Sergeant-only equipment")
	var term := records(TERMINATORS, 5)
	term[1].terminator_special_weapon = "cyclone-missile-launcher"
	term[2].terminator_special_weapon = "assault-cannon"
	term[3].terminator_special_weapon = "plasma-cannon"
	check(E.valid_saved_loadout(TERMINATORS, term, 5) and E.points_for_loadout(TERMINATORS, term, 5) == 10, "Three different Deathwatch specials are allowed and only Cyclones add ten points")
	term[4].terminator_special_weapon = "heavy-flamer"
	check(not E.valid_saved_loadout(TERMINATORS, term, 5), "The fourth Deathwatch Terminator special is rejected")
	term = records(TERMINATORS, 10)
	term[1].deathwatch_terminator_melee_package = "thunder-hammer-storm-shield"
	term[1].terminator_special_weapon = "plasma-cannon"
	check(not E.valid_saved_loadout(TERMINATORS, term, 10), "A Terminator cannot replace its Storm Bolter twice")
	term[1].terminator_special_weapon = ""
	term[1].deathwatch_terminator_melee_package = "twin-lightning-claws"
	check(E.valid_saved_loadout(TERMINATORS, term, 10), "Twin Lightning Claws replace the Power Fist and Storm Bolter")
	term[1].deathwatch_terminator_melee_package = "thunder-hammer-storm-shield"
	check(E.valid_saved_loadout(TERMINATORS, term, 10) and E.points_for_loadout(TERMINATORS, term, 10) == 5, "A per-model Terminator Storm Shield adds five points")
	term[0].terminator_special_weapon = "assault-cannon"
	check(not E.valid_saved_loadout(TERMINATORS, term, 10), "The Sergeant has no Storm Bolter replacement control")
	var profile := P.profile("deathwatch-terminator-squad")
	check(profile.get("wargear_costs", {}) == {"storm-shield": 5, "cyclone-missile-launcher": 10} and profile.get("options", {}).get("max_special_weapons", 0) == 3, "Saved Deathwatch costs and weapon counts use the local profile values")
	var veteran_profile := P.profile("deathwatch-veterans")
	check(veteran_profile.get("options", {}).get("sergeant_ranged_replacements", []) == ["combi-weapon"] and veteran_profile.get("options", {}).get("sergeant_melee_replacements", []) == ["xenophase-blade"], "Saved Watch Sergeant choices stay on their separate source options")
	var leader_controls := E.controls_for_model(TERMINATORS, 0, 5)
	var ordinary_controls := E.controls_for_model(TERMINATORS, 1, 5)
	check(leader_controls.size() == 2 and leader_controls[1].choices.size() == 1 and ordinary_controls.size() == 2 and ordinary_controls[1].choices.size() == 5, "Only ordinary Deathwatch Terminators can select one of the four ranged replacements")
	var veteran_leader_controls := E.controls_for_model(VETERANS, 0, 5)
	var veteran_controls := E.controls_for_model(VETERANS, 1, 5)
	check(veteran_leader_controls.size() == 2 and veteran_controls.size() == 1 and veteran_controls[0].choices.size() == 9, "Army Workshop exposes role-correct Deathwatch Veterans options")

func check_unit(unit: Dictionary, definition: String, equipment: Dictionary, models: int, model_index: int) -> void:
	var expected := {}
	E.prepare(expected, definition, equipment, models, model_index)
	check(unit.ranged_weapons == expected.ranged_weapons and unit.melee_weapons == expected.melee_weapons, "Prepared %s model %d keeps every saved weapon and profile" % [definition, model_index + 1])
	check(bool(unit.get("deathwatch_saved_model_loadout_locked", false)) and bool(unit.get("sergeant", false)) == (model_index == 0) and str(unit.get("model_role", "")) == E.visual_model_role(definition, models, model_index), "Prepared Deathwatch model keeps its visual role and match lock")
	check(unit.get("saved_model_equipment", {}) == equipment and int(unit.get("saved_equipment_model_index", -1)) == model_index, "Prepared Deathwatch model retains its exact saved record and index")
	if definition == VETERANS:
		var veteran_shield := model_index > 0 and str(equipment.deathwatch_veteran_loadout) in ["boltgun-storm-shield", "power-weapon-storm-shield"]
		check(bool(unit.get("deathwatch_veteran_storm_shield", false)) == veteran_shield, "Saved Veteran Storm Shield preserves its conditional defense flag")
	else:
		var terminator_shield := str(equipment.deathwatch_terminator_melee_package) == "thunder-hammer-storm-shield"
		check(bool(unit.get("deathwatch_terminator_storm_shield", false)) == terminator_shield and int(unit.get("max_wounds", 0)) == int(P.profile("deathwatch-terminator-squad").stats.wounds) + (1 if terminator_shield else 0), "Saved Terminator Shield preserves its Wound increase")

func inspect_bank(army: Dictionary) -> void:
	var validation := R.validate(army)
	var report := Training.admit_current_catalog(army)
	check(validation.is_empty() and report.error.is_empty(), "Saved Deathwatch army opens through the local catalog: " + str(report.error))
	check(int(R.summary(army).get("points", -1)) == 975, "Saved Storm Shield and Cyclone prices preserve duplicate-copy tiers")
	check(R.model_equipment(army.entries[0], 0, 1).deathwatch_veteran_loadout == "stalker-pattern-boltgun" and R.model_equipment(army.entries[0], 1, 1).deathwatch_veteran_loadout == "frag-cannon" and R.model_equipment(army.entries[0], 2, 1).deathwatch_veteran_loadout == "boltgun-storm-shield", "Identical Veteran copies retain distinct per-model equipment")
	check(R.model_equipment(army.entries[1], 0, 1).terminator_special_weapon == "cyclone-missile-launcher" and R.model_equipment(army.entries[1], 0, 3).terminator_special_weapon == "assault-cannon" and R.model_equipment(army.entries[1], 1, 1).terminator_special_weapon == "assault-cannon" and R.model_equipment(army.entries[1], 2, 3).deathwatch_terminator_melee_package == "thunder-hammer-storm-shield", "Identical Terminator copies retain distinct special weapons and Shields")

func verify_prepared_armies(army: Dictionary, selection: Dictionary) -> void:
	var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "DEATHWATCH", 2: "DEATHWATCH"}}, {1: selection, 2: selection})
	check(not state.has("error"), "Both players materialize saved Deathwatch equipment: " + str(state.get("error", "")))
	if state.has("error"): return
	var refs := Training.stable_model_refs(army, selection)
	check(refs.error.is_empty(), "Stable model references survive Deathwatch army canonicalization")
	if not refs.error.is_empty(): return
	for owner: int in [1, 2]:
		var points := 0
		for squad: int in state.squads:
			if int(state.squads[squad].owner) == owner: points += int(state.squads[squad].training_cost)
		check(points == 975 and int(state.training_points.get(owner, 0)) == 975, "Prepared saved options retain exact base tiers and per-model costs")
		for entry_index in range(army.entries.size()):
			var item: Dictionary = army.entries[entry_index]
			var definition := str(item.unit_id)
			var copy_ids := R.normalize_copy_instance_ids(item)
			for copy_index in range(int(item.copies)):
				var copy_ref: Dictionary = refs.copies[str(copy_ids[copy_index])]
				var squad := owner + int(copy_ref.unit_index) * 2
				for model_index in range(int(item.models)):
					var model_ref: Dictionary = refs.models[R.model_instance_id(item, copy_index, model_index)]
					var model := (squad * 100) + int(model_ref.model_index)
					var equipment := R.model_equipment(item, copy_index, model_index)
					check_unit(state.units[model], definition, equipment, int(item.models), model_index)
				if definition == TERMINATORS:
					check(C.UnitActions.has_teleport_homer(state, squad) and C.UnitAbilities.has(state, squad, "deathwatch-terminatus-assault"), "Deathwatch match rules remain attached after saved equipment preparation")
				if definition == VETERANS:
					var shield_model := squad * 100 + 1
					var has_shield := str(R.model_equipment(item, copy_index, 1).deathwatch_veteran_loadout) == "boltgun-storm-shield"
					check(Groups.profile(state, shield_model).invulnerable_target == (4 if has_shield else 0), "Saved Veteran Storm Shield changes only its bearer defense")
	var initial_choices := Actions.choices(state, 1)
	check(not initial_choices.any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in LOCKED_ACTIONS), "Setup choices omit every saved Deathwatch weapon field")
	var veteran_model := -1
	var veteran_squad := -1
	var veteran_sergeant := -1
	var term_model := -1
	var term_squad := -1
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != 1: continue
		if identity_of(unit) == "deathwatch-veterans" and not bool(unit.get("sergeant", false)) and veteran_model < 0:
			veteran_model = model
			veteran_squad = int(unit.squad)
		if identity_of(unit) == "deathwatch-veterans" and bool(unit.get("sergeant", false)): veteran_sergeant = model
		if identity_of(unit) == "deathwatch-terminator-squad" and not bool(unit.get("sergeant", false)) and term_model < 0:
			term_model = model
			term_squad = int(unit.squad)
	for action: String in ["deathwatch-veteran-loadout", "deathwatch-sergeant-ranged-loadout", "deathwatch-sergeant-melee-loadout"]:
		var before := state.duplicate(true)
		var is_sergeant_action := action in ["deathwatch-sergeant-ranged-loadout", "deathwatch-sergeant-melee-loadout"]
		var target_model := veteran_sergeant if is_sergeant_action else veteran_model
		var value := "combi-weapon" if action != "deathwatch-sergeant-melee-loadout" else "xenophase-blade"
		var result := Actions.apply(state, 1, {"action": action, "model": target_model, "target": veteran_squad, "value": value}, Vector2.ZERO, Callable())
		check(str(result.get("error", "")).contains("Saved Deathwatch equipment") and state == before, "Frozen Veteran options reject direct commands without mutation")
	for action: String in ["deathwatch-terminator-loadout", "terminator-special-weapon"]:
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": action, "model": term_model, "target": term_squad, "value": "twin-lightning-claws"}, Vector2.ZERO, Callable())
		check(str(result.get("error", "")).contains("Saved Deathwatch equipment") and state == before, "Frozen Terminator options reject direct commands without mutation")

func identity_of(unit: Dictionary) -> String:
	return C.UnitAbilities.identity(unit)

func check_builder_controls(army: Dictionary) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://deathwatch-controls-%d.json" % OS.get_process_id())
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	var veteran_rows: Control = panel.per_model_equipment_controls
	check(veteran_rows.get_child_count() == 5 and (veteran_rows.get_child(0).get_child(0) as Label).text == "Watch Sergeant" and (veteran_rows.get_child(1).get_child(0) as Label).text == "Deathwatch Veteran 2", "Army Workshop labels the Veteran model rows")
	if veteran_rows.get_child_count() == 5:
		var sergeant_fields := veteran_rows.get_child(0).get_child(1) as GridContainer
		var veteran_fields := veteran_rows.get_child(1).get_child(1) as GridContainer
		var sergeant_ranged := (sergeant_fields.get_child(0) as VBoxContainer).get_child(1) as OptionButton
		var veteran_loadout := (veteran_fields.get_child(0) as VBoxContainer).get_child(1) as OptionButton
		check(sergeant_fields.get_child_count() == 2 and veteran_fields.get_child_count() == 1 and sergeant_ranged.item_count == 2 and veteran_loadout.item_count == 9, "Workshop renders distinct Sergeant and Veteran equipment pickers")
	panel._select_entry(1)
	var terminator_rows: Control = panel.per_model_equipment_controls
	check(terminator_rows.get_child_count() == 5 and (terminator_rows.get_child(0).get_child(0) as Label).text == "Terminator Sergeant", "Army Workshop labels the Deathwatch Terminator Sergeant")
	if terminator_rows.get_child_count() == 5:
		var sergeant_fields := terminator_rows.get_child(0).get_child(1) as GridContainer
		var terminator_fields := terminator_rows.get_child(1).get_child(1) as GridContainer
		var sergeant_ranged := (sergeant_fields.get_child(1) as VBoxContainer).get_child(1) as OptionButton
		var terminator_ranged := (terminator_fields.get_child(1) as VBoxContainer).get_child(1) as OptionButton
		check(sergeant_ranged.item_count == 1 and terminator_ranged.item_count == 5, "Workshop prevents ranged replacements for the Sergeant")
	panel.free()
	var path := ProjectSettings.globalize_path("user://deathwatch-controls-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "Independent process reopens the saved Deathwatch army")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_limits()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	var army := make_army(catalog)
	check(army.entries.size() == 2 and R.validate(army).is_empty(), "Both saved Deathwatch profiles form a valid Workshop list")
	check(R.summary(army).points == 975, "Saved Storm Shields and Cyclone retain per-model cost totals")
	var term_copy := R.model_equipment_loadouts(army.entries[1], 0)
	var before_invalid: Dictionary = army.entries[1].duplicate(true)
	var fourth_added := R.set_model_equipment(army.entries[1], 0, 4, "terminator_special_weapon", "heavy-flamer")
	check(not fourth_added, "The Army Workshop rejects a fourth Deathwatch special weapon")
	check(army.entries[1] == before_invalid, "A rejected fourth special leaves the saved roster unchanged")
	before_invalid = army.entries[1].duplicate(true)
	check(not R.set_model_equipment(army.entries[1], 0, 1, "deathwatch_terminator_melee_package", "twin-lightning-claws") and army.entries[1] == before_invalid, "A melee choice that removes a still-equipped Storm Bolter replacement is rejected atomically")
	check(term_copy.size() == 5, "The saved Terminator roster keeps every model record")
	var repriced := R.reprice(army, catalog.catalog)
	check(repriced.error.is_empty() and R.summary(repriced.list).points == 975, "Current local catalog repricing preserves Deathwatch wargear and copy tiers")
	if repriced.error.is_empty():
		for entry_index in range(army.entries.size()):
			check(repriced.list.entries[entry_index].model_equipment_by_id == army.entries[entry_index].model_equipment_by_id, "Repricing retains each stable Deathwatch model record")
	var split := R.split_copy(army.entries[1], 1)
	check(split.error.is_empty() and R.model_equipment(split.selected, 0, 1).terminator_special_weapon == "assault-cannon" and R.model_equipment(split.remaining, 0, 1).terminator_special_weapon == "cyclone-missile-launcher", "Splitting a copy carries its chosen model loadouts")
	var save_path := ProjectSettings.globalize_path("user://deathwatch-loadouts-%d.json" % OS.get_process_id())
	var store := Store.new(save_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop saves Deathwatch equipment to disk")
	var child_output: Array = []
	var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_deathwatch_saved_loadouts.gd", "--", "--reopen", save_path], child_output, true)
	check(child_exit == 0, "A separate process reopens and verifies every saved Deathwatch copy: " + str(child_output))
	if saved.error.is_empty():
		var reopened := Store.new(save_path)
		if reopened.error.is_empty() and reopened.active().lists.size() == 1:
			var active_army: Dictionary = reopened.active().lists[0]
			inspect_bank(active_army)
			var report := Training.admit_current_catalog(active_army)
			check(report.error.is_empty(), "Saved options project into the current admitted catalog: " + str(report.error))
			if report.error.is_empty(): verify_prepared_armies(active_army, report.selection)
			check_builder_controls(active_army)
	catalog.free()
	for suffix in ["", ".bak", ".panel", ".panel.bak"]:
		if FileAccess.file_exists(save_path + suffix): DirAccess.remove_absolute(save_path + suffix)
	await process_frame
	print("Saved Deathwatch model equipment: %d failures" % failures)
	quit(1 if failures else 0)
