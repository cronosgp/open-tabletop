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
const UNIT := "40kdc:11e:adeptus-astartes:sword-brethren-squad"
const SAVED_ACTION := "sword-brethren-loadout"
const LOADOUT_IDS: Array[String] = [
	"default", "hand-flamer-chainsword", "hand-flamer-power-weapon", "hand-flamer-thunder-hammer",
	"plasma-pistol-chainsword", "plasma-pistol-power-weapon", "plasma-pistol-thunder-hammer",
	"heavy-pistol-power-weapon", "heavy-pistol-thunder-hammer", "twin-lightning-claws"
]
const LIMIT_ACTIONS: Array = [
	["hand-flamer-chainsword", "hand-flamer-power-weapon"],
	["plasma-pistol-chainsword"],
	["heavy-pistol-thunder-hammer"],
	["twin-lightning-claws"]
]
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

func entry(catalog: Node, models: int, copies: int = 1) -> Dictionary:
	var source: Dictionary = catalog.lookup(UNIT)
	for index in range(source.options.size()):
		if int(source.options[index].models) == models: return R.entry(source, index, copies)
	check(false, "Sword Brethren source size %d is present in the consolidated local catalog" % models)
	return {}

func set_loadout(item: Dictionary, copy_index: int, model_index: int, loadout_id: String, message: String) -> void:
	check(R.set_model_equipment(item, copy_index, model_index, "sword_brethren_loadout", loadout_id), message)

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.name = "Sword Brethren saved equipment review"
	var item := entry(catalog, 4, 3)
	army.entries = [item]
	for model_index in range(4):
		var first_choice := "default"
		if model_index == 0: first_choice = "hand-flamer-chainsword"
		elif model_index == 1: first_choice = "hand-flamer-power-weapon"
		elif model_index == 2: first_choice = "plasma-pistol-thunder-hammer"
		elif model_index == 3: first_choice = "twin-lightning-claws"
		set_loadout(item, 0, model_index, first_choice, "The first four-model copy saves a legal mixed loadout %d" % (model_index + 1))
	set_loadout(item, 1, 0, "heavy-pistol-thunder-hammer", "The second copy saves a different Thunder Hammer bearer")
	set_loadout(item, 1, 1, "twin-lightning-claws", "The second copy saves a separate Twin Lightning Claws bearer")
	set_loadout(item, 1, 2, "hand-flamer-chainsword", "The second copy saves one source-limited Hand Flamer")
	return army

func check_source_options() -> void:
	check(E.supports(UNIT) and E.is_model_scoped(UNIT) and E.uses_stacked_model_controls(UNIT), "Sword Brethren equipment is registered as stable per-model stacked cards")
	check(P.profile("sword-brethren-squad").get("source_snapshot_id", "") == "20261021T130623Z" and P.profile("sword-brethren-squad").get("source_datasheet_id", "") == "000002798", "The saved schema uses the audited Black Templars 11e datasheet")
	for models in [4, 5, 9, 10]:
		var defaults := records(models)
		check(E.valid_saved_loadout(UNIT, defaults, models) and E.points_for_loadout(UNIT, defaults, models) == 0, "%d-model source defaults are complete and add no points" % models)
		for model_index in range(models):
			check(E.model_label(UNIT, models, model_index) == "Sword Brethren %d" % (model_index + 1), "The %d-model inspector gives model %d a stable visible label" % [models, model_index + 1])
			for loadout_id: String in P.sword_brethren_loadout_options(model_index, models):
				var equipment := E.defaults(UNIT)
				equipment.sword_brethren_loadout = loadout_id
				var expected := P.sword_brethren_model_loadout(model_index, models, loadout_id)
				var prepared: Dictionary = {}
				E.prepare(prepared, UNIT, equipment, models, model_index)
				check(E.valid(UNIT, equipment, models) and not expected.is_empty() and prepared.ranged_weapons == expected.ranged and prepared.melee_weapons == expected.melee, "Model %d in a %d-model unit resolves %s through the exact local factory" % [model_index + 1, models, loadout_id])
				check(bool(prepared.get("sword_brethren_saved_model_loadout_locked", false)) and str(prepared.get("sword_brethren_loadout", "")) == loadout_id, "Prepared model %d keeps its saved package and lock" % (model_index + 1))
				var one_choice := records(models)
				one_choice[model_index].sword_brethren_loadout = loadout_id
				check(E.valid_saved_loadout(UNIT, one_choice, models), "Each source package is legal as an independent model choice at size %d" % models)
		check(not E.valid_saved_loadout(UNIT, defaults.slice(0, models - 1), models), "The %d-model schema rejects a short saved array" % models)
	for unsupported_size in [3, 6, 7, 8]:
		check(not E.valid_saved_loadout(UNIT, records(unsupported_size), unsupported_size), "Unpriced %d-model configuration is rejected" % unsupported_size)
	var invalid := records(4)
	invalid[2].sword_brethren_loadout = "invented-package"
	check(not E.valid_saved_loadout(UNIT, invalid, 4), "Unknown Sword Brethren packages are rejected")
	invalid = records(4)
	invalid[0].unexpected = true
	check(not E.valid_saved_loadout(UNIT, invalid, 4), "Unknown saved equipment fields are rejected")
	var four := records(4)
	four[0].sword_brethren_loadout = "hand-flamer-chainsword"
	four[1].sword_brethren_loadout = "hand-flamer-power-weapon"
	check(E.valid_saved_loadout(UNIT, four, 4), "Two Hand Flamers are allowed in a four-model group")
	four[2].sword_brethren_loadout = "hand-flamer-thunder-hammer"
	check(not E.valid_saved_loadout(UNIT, four, 4), "A third Hand Flamer exceeds the source cap")
	four = records(4)
	four[0].sword_brethren_loadout = "plasma-pistol-chainsword"
	four[1].sword_brethren_loadout = "heavy-pistol-thunder-hammer"
	four[2].sword_brethren_loadout = "twin-lightning-claws"
	check(E.valid_saved_loadout(UNIT, four, 4), "Plasma Pistol, Thunder Hammer and Twin Lightning Claws use independent source caps")
	four[3].sword_brethren_loadout = "plasma-pistol-power-weapon"
	check(not E.valid_saved_loadout(UNIT, four, 4), "A second Plasma Pistol exceeds the one-per-four cap")
	var nine_ids: Array[String] = [
		"hand-flamer-chainsword", "hand-flamer-power-weapon", "hand-flamer-thunder-hammer", "hand-flamer-chainsword",
		"plasma-pistol-chainsword", "plasma-pistol-thunder-hammer", "heavy-pistol-power-weapon", "twin-lightning-claws", "default"
	]
	var nine := records(9)
	for index in range(9): nine[index].sword_brethren_loadout = nine_ids[index]
	check(E.valid_saved_loadout(UNIT, nine, 9), "All per-four source caps scale to two groups in a nine-model unit")
	var ten_ids: Array[String] = [
		"hand-flamer-power-weapon", "hand-flamer-thunder-hammer", "hand-flamer-chainsword", "hand-flamer-power-weapon",
		"plasma-pistol-chainsword", "plasma-pistol-thunder-hammer", "heavy-pistol-power-weapon", "heavy-pistol-power-weapon",
		"twin-lightning-claws", "twin-lightning-claws"
	]
	var ten := records(10)
	for index in range(10): ten[index].sword_brethren_loadout = ten_ids[index]
	check(E.valid_saved_loadout(UNIT, ten, 10), "Ten Sword Brethren can use every scaled independent cap exactly")
	ten[9].sword_brethren_loadout = "hand-flamer-chainsword"
	check(not E.valid_saved_loadout(UNIT, ten, 10), "A fifth Hand Flamer exceeds the two-group source cap")

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Sword Brethren list passes roster validation")
	check(R.summary(army).points == 365, "Three four-model copies retain two 115-point prices and the 135-point third-copy price")
	var first := R.model_equipment_loadouts(army.entries[0], 0)
	var second := R.model_equipment_loadouts(army.entries[0], 1)
	var third := R.model_equipment_loadouts(army.entries[0], 2)
	check(first.map(func(item: Dictionary) -> String: return str(item.sword_brethren_loadout)) == ["hand-flamer-chainsword", "hand-flamer-power-weapon", "plasma-pistol-thunder-hammer", "twin-lightning-claws"], "The first copy reopens all four distinct source packages")
	check(second[0].sword_brethren_loadout == "heavy-pistol-thunder-hammer" and second[1].sword_brethren_loadout == "twin-lightning-claws" and second[2].sword_brethren_loadout == "hand-flamer-chainsword", "The second copy keeps independent bearer assignments")
	check(third.all(func(item: Dictionary) -> bool: return str(item.sword_brethren_loadout) == "default"), "The third copy retains its distinct default profile")
	check(E.valid_saved_loadout(UNIT, first, 4) and E.valid_saved_loadout(UNIT, second, 4) and E.valid_saved_loadout(UNIT, third, 4), "Every reopened per-model array passes the whole-unit validator")

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Saved Sword Brethren enters the current consolidated local catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"core_stratagems": true, "combat_doctrines": true, "unit_abilities": true, "official_mission": false, "checked_rosters": false, "marine_chapters": {1: "BLACK TEMPLARS", 2: "BLACK TEMPLARS"}, "marine_detachments": {1: "fist-of-the-god-emperor", 2: "fist-of-the-god-emperor"}}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize all saved Sword Brethren copies: " + str(state.get("error", "")))
	if state.has("error"): return
	for owner: int in [1, 2]:
		var squad_offset := 0
		for selected_entry: Dictionary in admitted.selection.entries:
			for copy_index in range(int(selected_entry.copies)):
				var squad := owner + squad_offset * 2
				var copy_loadout: Array = selected_entry.saved_model_loadouts[copy_index]
				for model_index in range(int(selected_entry.models)):
					var model := find_model_in_squad(state, owner, squad, model_index)
					check(model >= 0, "Materialized %d-model copy contains model %d for player %d" % [int(selected_entry.models), model_index + 1, owner])
					if model < 0: continue
					var unit: Dictionary = state.units[model]
					var equipment: Dictionary = copy_loadout[model_index]
					var loadout_id := str(equipment.sword_brethren_loadout)
					var expected := P.sword_brethren_model_loadout(model_index, int(selected_entry.models), loadout_id)
					check(unit.ranged_weapons == expected.ranged and unit.melee_weapons == expected.melee and unit.get("saved_model_equipment", {}) == equipment and str(unit.get("sword_brethren_loadout", "")) == loadout_id and bool(unit.get("sword_brethren_saved_model_loadout_locked", false)), "Materialized model keeps the exact local weapons, stable saved record and setup lock")
				squad_offset += 1
	var choices: Array = Actions.choices(state, 1)
	check(not choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) == SAVED_ACTION), "Saved Sword Brethren suppresses the duplicate Army Preparation action")
	var target_model := -1
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1 and str(state.units[model].get("definition_id", "")).ends_with("sword-brethren-squad"):
			target_model = model
			break
	if target_model >= 0:
		var before := state.duplicate(true)
		var target_squad := int(state.units[target_model].squad)
		var result := Actions.apply(state, 1, {"action": SAVED_ACTION, "model": target_model, "target": target_squad, "value": "default"}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Forced match-preparation edit is rejected without mutating the saved package")

func picker_index(picker: OptionButton, wanted: String) -> int:
	for index in range(picker.item_count):
		if str(picker.get_item_metadata(index)) == wanted: return index
	return -1

func verify_builder(catalog: Node) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://sword-brethren-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	var army := R.new_list("11e", "Space Marines", "custom", 3000)
	army.name = "Sword Brethren Workshop control review"
	army.entries = [entry(catalog, 10)]
	panel.draft = army
	panel._render_draft()
	panel._select_entry(0)
	var rows: Control = panel.per_model_equipment_controls
	var first_card: Control = rows.get_child(0)
	var heading := first_card.get_child(0) as Label
	var fields: Control = first_card.get_child(1)
	var field_stack: Control = fields.get_child(0)
	var picker := field_stack.get_child(1) as OptionButton
	check(rows.get_child_count() == 10 and heading.text == "Sword Brethren 1" and picker.item_count == LOADOUT_IDS.size(), "Workshop shows ten labelled scrollable cards with all ten source packages")
	var selected := picker_index(picker, "hand-flamer-thunder-hammer")
	picker.select(selected)
	picker.item_selected.emit(selected)
	check(selected >= 0 and panel.dirty and R.model_equipment(panel.draft.entries[0], 0, 0).sword_brethren_loadout == "hand-flamer-thunder-hammer", "The real Workshop selector signal saves the chosen package to the stable model")
	var last_card: Control = rows.get_child(9)
	check((last_card.get_child(0) as Label).text == "Sword Brethren 10", "The tenth model retains its visible identity in the inspector")
	panel.free()
	var path := ProjectSettings.globalize_path("user://sword-brethren-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "A separate Godot process reopens the configured Sword Brethren bank")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "The consolidated local catalog opens without network access")
	var source := catalog.lookup(UNIT)
	check(not source.is_empty(), "The local catalog includes the admitted Black Templars Sword Brethren profile")
	if source.is_empty():
		catalog.free()
		quit(1)
		return
	for item: Dictionary in [
		{"models": 4, "first": 115, "third": 135},
		{"models": 5, "first": 140, "third": 160},
		{"models": 9, "first": 250, "third": 270},
		{"models": 10, "first": 275, "third": 295}
	]:
		var one := R.new_list("11e", "Space Marines", "custom", 3000)
		one.entries = [entry(catalog, int(item.models), 1)]
		var three := R.new_list("11e", "Space Marines", "custom", 3000)
		three.entries = [entry(catalog, int(item.models), 3)]
		check(R.summary(one).points == int(item.first) and R.summary(three).points == int(item.first) * 2 + int(item.third), "%d-model first/second and third-copy prices are unchanged" % int(item.models))
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 365, "Saved packages add no surcharge to existing four-model copy-tier prices")
	var before_invalid: Dictionary = army.entries[0].duplicate(true)
	check(not R.set_model_equipment(army.entries[0], 0, 2, "sword_brethren_loadout", "hand-flamer-thunder-hammer") and army.entries[0] == before_invalid, "An over-cap edit is rejected atomically and preserves other model choices")
	var saved_path := ProjectSettings.globalize_path("user://sword-brethren-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop persists Sword Brethren equipment by stable model and copy IDs")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_sword_brethren_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate process reopens every configured model record: " + str(child_output))
		var reopened := Store.new(saved_path)
		if reopened.error.is_empty() and reopened.active().lists.size() == 1:
			var active_army: Dictionary = reopened.active().lists[0]
			inspect_bank(active_army)
			verify_matches(active_army)
		verify_builder(catalog)
	catalog.free()
	for suffix in ["", ".bak", ".panel", ".panel.bak"]:
		if FileAccess.file_exists(saved_path + suffix): DirAccess.remove_absolute(saved_path + suffix)
	await process_frame
	print("Saved Sword Brethren equipment: %d failures" % failures)
	quit(1 if failures else 0)
