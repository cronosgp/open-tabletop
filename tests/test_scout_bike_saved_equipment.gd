extends SceneTree

const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const UNIT := "40kdc:11e:adeptus-astartes:scout-bike-squad"
const LOCKED_ACTIONS := ["scout-bike-sergeant-option", "scout-bike-grenade-launcher"]
const SERGEANT_OPTIONS: Array[String] = ["bolt-pistol", "boltgun", "combi-weapon", "chainsword", "grav-pistol", "hand-flamer", "inferno-pistol", "plasma-pistol", "power-fist", "power-weapon", "storm-bolter", "thunder-hammer"]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func records(models: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for _index in range(models): result.append(E.defaults(UNIT).duplicate(true))
	return result

func entry(catalog: Node, models: int, copies: int) -> Dictionary:
	var source: Dictionary = catalog.lookup(UNIT)
	for index in range(source.options.size()):
		if int(source.options[index].models) == models: return R.entry(source, index, copies)
	check(false, "Scout Bike source size is in the consolidated local catalog")
	return {}

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.name = "Scout Bike saved equipment review"
	army.entries = [entry(catalog, 3, 2), entry(catalog, 6, 1)]
	check(R.set_model_equipment(army.entries[0], 0, 0, "scout_bike_sergeant_option", "chainsword"), "The first Sergeant saves its source-listed Chainsword replacement")
	check(R.set_model_equipment(army.entries[0], 0, 1, "scout_bike_grenade_launcher", true), "A regular Biker saves its Grenade Launcher")
	check(R.set_model_equipment(army.entries[0], 1, 0, "scout_bike_sergeant_option", "power-fist"), "A second copy keeps a different Sergeant weapon")
	check(R.set_model_equipment(army.entries[0], 1, 0, "scout_bike_grenade_launcher", true), "The Sergeant may independently take a Grenade Launcher")
	check(R.set_model_equipment(army.entries[0], 1, 2, "scout_bike_grenade_launcher", true), "Any regular Biker may independently take a Grenade Launcher")
	for model_index in range(6):
		check(R.set_model_equipment(army.entries[1], 0, model_index, "scout_bike_grenade_launcher", true), "Six-model copy saves an unrestricted Grenade Launcher on model %d" % (model_index + 1))
	check(R.set_model_equipment(army.entries[1], 0, 0, "scout_bike_sergeant_option", "combi-weapon"), "The six-model Sergeant saves its own Combi-weapon choice")
	return army

func check_source_options() -> void:
	check(E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Scout Bike equipment is saved by stable model in stacked cards")
	for models in [3, 6]:
		check(E.valid_saved_loadout(UNIT, records(models), models) and E.points_for_loadout(UNIT, records(models), models) == 0, "%d-model defaults are valid and add no points" % models)
		check(not E.valid_saved_loadout(UNIT, records(models - 1), models - 1), "Unlisted Scout Bike size is rejected")
	check(E.model_label(UNIT, 3, 0) == "Scout Biker Sergeant" and E.model_label(UNIT, 6, 5) == "Scout Biker 6", "Model labels preserve the fixed Sergeant role")
	var six := records(6)
	for model_index in range(6): six[model_index].scout_bike_grenade_launcher = true
	check(E.valid_saved_loadout(UNIT, six, 6), "The source permits every model, including the Sergeant, to take a Grenade Launcher")
	six[2].scout_bike_sergeant_option = "boltgun"
	check(not E.valid_saved_loadout(UNIT, six, 6), "An ordinary Biker cannot use the Sergeant-only sidearm field")
	var invalid := records(3)
	invalid[0].scout_bike_sergeant_option = "invented-sidearm"
	check(not E.valid_saved_loadout(UNIT, invalid, 3), "Unlisted Sergeant replacements are rejected")
	for option: String in SERGEANT_OPTIONS:
		var equipment := E.defaults(UNIT)
		equipment.scout_bike_sergeant_option = option
		var expected := P.scout_bike_squad_weapons(false, option)
		var prepared: Dictionary = {}
		E.prepare(prepared, UNIT, equipment, 3, 0)
		check(not expected.is_empty() and prepared.ranged_weapons == expected.ranged and prepared.melee_weapons == expected.melee, "Saved Sergeant choice %s resolves through the exact local weapon factory" % option)
		var launcher := P.scout_bike_squad_weapons(true, option)
		check(not launcher.is_empty() and launcher.ranged.any(func(weapon: Dictionary) -> bool: return str(weapon.id) == "grenade-launcher"), "Sergeant choice %s stays independent from its Grenade Launcher" % option)
	var non_sergeant := E.defaults(UNIT)
	var regular: Dictionary = {}
	E.prepare(regular, UNIT, non_sergeant, 3, 1)
	var defaults := P.scout_bike_squad_weapons()
	check(regular.ranged_weapons == defaults.ranged and regular.melee_weapons == defaults.melee and regular.get("scout_bike_saved_model_loadout_locked", false), "Ordinary models use the default factory loadout and receive a saved-choice lock")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Scout Bike list passes roster validation")
	check(R.summary(army).points == 300, "3/6-model copies retain their 75/150-point prices with no equipment surcharge")
	var first := R.model_equipment_loadouts(army.entries[0], 0)
	var second := R.model_equipment_loadouts(army.entries[0], 1)
	var six := R.model_equipment_loadouts(army.entries[1], 0)
	check(first[0].scout_bike_sergeant_option == "chainsword" and bool(first[1].scout_bike_grenade_launcher), "First copy retains its independent Sergeant and Biker records")
	check(second[0].scout_bike_sergeant_option == "power-fist" and bool(second[0].scout_bike_grenade_launcher) and bool(second[2].scout_bike_grenade_launcher), "Second copy preserves both independent model choices")
	check(six.all(func(item: Dictionary) -> bool: return bool(item.scout_bike_grenade_launcher)) and six[0].scout_bike_sergeant_option == "combi-weapon", "Six-model copy reopens all launcher choices and its Sergeant sidearm")
	check(E.valid_saved_loadout(UNIT, first, 3) and E.valid_saved_loadout(UNIT, second, 3) and E.valid_saved_loadout(UNIT, six, 6), "Every reopened model array remains a valid complete source loadout")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Saved Scout Bike equipment enters the current local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize the saved Scout Bike choices: " + str(state.get("error", "")))
	if state.has("error"): return
	for owner: int in [1, 2]:
		var squad_offset := 0
		for selected_entry: Dictionary in admitted.selection.entries:
			for copy_index in range(int(selected_entry.copies)):
				var squad := owner + squad_offset * 2
				var copy_loadout: Array = selected_entry.saved_model_loadouts[copy_index]
				for model_index in range(int(selected_entry.models)):
					var model := find_model_in_squad(state, owner, squad, model_index)
					check(model >= 0, "Prepared %d-model copy %d contains saved model %d for player %d" % [int(selected_entry.models), copy_index + 1, model_index + 1, owner])
					if model < 0: continue
					var unit: Dictionary = state.units[model]
					var equipment: Dictionary = copy_loadout[model_index]
					var option := str(equipment.scout_bike_sergeant_option) if model_index == 0 else "bolt-pistol"
					var expected := P.scout_bike_squad_weapons(bool(equipment.scout_bike_grenade_launcher), option)
					check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and unit.get("saved_model_equipment", {}) == equipment and unit.get("scout_bike_saved_model_loadout_locked", false), "Prepared model keeps exact saved factory output, record and equipment lock")
					check(unit.ranged_weapons.any(func(weapon: Dictionary) -> bool: return str(weapon.id) == "grenade-launcher") == bool(equipment.scout_bike_grenade_launcher), "Prepared model carries its saved Grenade Launcher state")
					if model_index == 0: check(str(unit.get("scout_bike_sergeant_option", "")) == option, "Prepared Sergeant keeps its saved sidearm")
				squad_offset += 1
	var setup_choices: Array = Actions.choices(state, 1)
	check(not setup_choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) in LOCKED_ACTIONS), "Saved Scout Bike equipment is suppressed before Deployment")
	var target_model := -1
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1 and str(state.units[model].get("definition_id", "")).ends_with("scout-bike-squad"):
			target_model = model
			break
	if target_model >= 0:
		for action: String in LOCKED_ACTIONS:
			var before := state.duplicate(true)
			var value := "on" if action == "scout-bike-grenade-launcher" else "thunder-hammer"
			var result := Actions.apply(state, 1, {"action": action, "model": target_model, "target": int(state.units[target_model].squad), "value": value}, Vector2.ZERO, Callable())
			check(not str(result.get("error", "")).is_empty() and state == before, "Saved %s edit is rejected without match mutation" % action)

func picker_index(picker: OptionButton, wanted: String) -> int:
	for index in range(picker.item_count):
		if str(picker.get_item_metadata(index)) == wanted: return index
	return -1

func verify_builder(army: Dictionary) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://scout-bike-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	var rows: Control = panel.per_model_equipment_controls
	var sergeant_card: Control = rows.get_child(0)
	var heading := sergeant_card.get_child(0) as Label
	var fields: Control = sergeant_card.get_child(1)
	var launcher_picker := fields.get_child(0).get_child(1) as OptionButton
	var sidearm_picker := fields.get_child(1).get_child(1) as OptionButton
	check(rows.get_child_count() == 3 and heading.text == "Scout Biker Sergeant" and launcher_picker.item_count == 2 and sidearm_picker.item_count == SERGEANT_OPTIONS.size(), "Workshop shows both Sergeant choices in a labelled model card")
	var sidearm_index := picker_index(sidearm_picker, "storm-bolter")
	sidearm_picker.select(sidearm_index)
	sidearm_picker.item_selected.emit(sidearm_index)
	var launcher_index := picker_index(launcher_picker, "true")
	launcher_picker.select(launcher_index)
	launcher_picker.item_selected.emit(launcher_index)
	check(R.model_equipment(panel.draft.entries[0], 0, 0).scout_bike_sergeant_option == "storm-bolter" and bool(R.model_equipment(panel.draft.entries[0], 0, 0).scout_bike_grenade_launcher), "Sergeant selectors save independent choices to its stable model record")
	panel._select_entry(1)
	var six_rows: Control = panel.per_model_equipment_controls
	var sixth_card: Control = six_rows.get_child(5)
	var sixth_heading := sixth_card.get_child(0) as Label
	check(six_rows.get_child_count() == 6 and sixth_heading.text == "Scout Biker 6", "Six-model inspector retains every stable model name in scrollable cards")
	panel.free()
	var path := ProjectSettings.globalize_path("user://scout-bike-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate process reopens the saved Scout Bike list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local construction catalog opens offline")
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 300, "Two 3-model copies and one 6-model copy preserve their 75/150-point prices")
	var before_invalid: Dictionary = army.entries[0].duplicate(true)
	check(not R.set_model_equipment(army.entries[0], 0, 1, "scout_bike_sergeant_option", "boltgun") and army.entries[0] == before_invalid, "A non-Sergeant sidearm edit is rejected atomically")
	var saved_path := ProjectSettings.globalize_path("user://scout-bike-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists Scout Bike model choices by stable ID")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_scout_bike_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate process reopens every saved model record: " + str(child_output))
		var reopened := Store.new(saved_path)
		if reopened.error.is_empty() and reopened.active().lists.size() == 1:
			var active_army: Dictionary = reopened.active().lists[0]
			inspect_bank(active_army)
			verify_matches(active_army)
			verify_builder(active_army)
	catalog.free()
	for suffix in ["", ".bak", ".panel", ".panel.bak"]:
		if FileAccess.file_exists(saved_path + suffix): DirAccess.remove_absolute(saved_path + suffix)
	await process_frame
	print("Saved Scout Bike equipment: %d failures" % failures)
	quit(1 if failures else 0)
