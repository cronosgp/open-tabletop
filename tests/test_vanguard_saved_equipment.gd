extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const E = preload("res://scripts/edition_11/saved_equipment_profiles.gd")
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const R = preload("res://scripts/army_roster.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Store = preload("res://scripts/army_profiles.gd")
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Actions = preload("res://scripts/edition_11/unit_actions.gd")
const Builder = preload("res://scripts/army_builder_panel.gd")
const VETERANS := "40kdc:11e:adeptus-astartes:vanguard-veteran-squad"
const JUMP_PACKS := "40kdc:11e:adeptus-astartes:vanguard-veteran-squad-with-jump-packs"
const LOCKED_ACTIONS := ["vanguard-veteran-pistol", "vanguard-veteran-squad-loadout", "vanguard-veteran-melee"]
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
	check(false, "Vanguard Veteran source size is in the local catalog")
	return {}

func make_army(catalog: Node) -> Dictionary:
	var army := R.new_list("11e", "Space Marines", "strike_force", 2000)
	army.entries = [entry(catalog, VETERANS, 5, 3), entry(catalog, JUMP_PACKS, 10, 3)]
	check(R.set_model_equipment(army.entries[0], 0, 1, "vanguard_veteran_squad_loadout", "storm-shield"), "Legends Storm Shield saves to one stable Veteran model")
	check(R.set_model_equipment(army.entries[0], 1, 2, "vanguard_veteran_squad_loadout", "inferno-pistol"), "A second Legends copy keeps its independent Inferno Pistol")
	check(R.set_model_equipment(army.entries[0], 2, 3, "vanguard_veteran_squad_loadout", "plasma-pistol"), "A third Legends copy retains the Plasma Pistol")
	check(R.set_model_equipment(army.entries[1], 0, 0, "vanguard_pistol", "plasma-pistol"), "Jump Sergeant Plasma Pistol uses its separate source allowance")
	check(R.set_model_equipment(army.entries[1], 0, 0, "vanguard_melee", "thunder-hammer"), "Jump Sergeant can save a Thunder Hammer")
	for model_index in [1, 2, 3, 4]:
		check(R.set_model_equipment(army.entries[1], 0, model_index, "vanguard_pistol", "plasma-pistol"), "Ordinary Jump Veteran Plasma choice %d is within cap" % model_index)
	check(R.set_model_equipment(army.entries[1], 0, 5, "vanguard_pistol", "combat-shield"), "Jump Veteran Combat Shield saves with no Plasma cost")
	check(R.set_model_equipment(army.entries[1], 1, 0, "vanguard_pistol", "combat-shield") and R.set_model_equipment(army.entries[1], 1, 1, "vanguard_pistol", "plasma-pistol"), "Another Jump unit copy keeps its own Sergeant Shield and Plasma pistol")
	check(R.set_model_equipment(army.entries[1], 2, 2, "vanguard_pistol", "plasma-pistol"), "Third-plus Jump copy preserves its model choice")
	return army

func check_source_options() -> void:
	check(E.supports(VETERANS) and E.supports(JUMP_PACKS) and E.is_model_scoped(VETERANS) and E.is_model_scoped(JUMP_PACKS), "Both Vanguard profiles use saved model equipment")
	check(E.model_label(VETERANS, 5, 0) == "Vanguard Sergeant" and E.model_label(VETERANS, 5, 1) == "Vanguard Veteran 2" and E.model_label(JUMP_PACKS, 5, 0) == "Vanguard Sergeant", "Workshop model rows distinguish Vanguard roles")
	for definition: String in [VETERANS, JUMP_PACKS]:
		for models: int in [5, 10]:
			var defaults := records(definition, models)
			check(E.valid_saved_loadout(definition, defaults, models) and E.points_for_loadout(definition, defaults, models) == 0, "Source defaults form a valid zero-surcharge %s list" % definition)
			check(not E.valid_saved_loadout(definition, defaults.slice(0, models - 1), models), "Incomplete %s model records are rejected" % definition)
	var invalid := records(VETERANS, 5)
	invalid[1].vanguard_veteran_squad_loadout = "invented-pistol"
	check(not E.valid_saved_loadout(VETERANS, invalid, 5), "Legends records reject unlisted pistol/shield options")
	var jump := records(JUMP_PACKS, 5)
	jump[0].vanguard_pistol = "plasma-pistol"
	jump[0].vanguard_melee = "thunder-hammer"
	jump[1].vanguard_pistol = "plasma-pistol"
	jump[2].vanguard_pistol = "plasma-pistol"
	check(E.valid_saved_loadout(JUMP_PACKS, jump, 5), "The Sergeant's Plasma Pistol is separate from two ordinary pistols per five")
	jump[3].vanguard_pistol = "plasma-pistol"
	check(not E.valid_saved_loadout(JUMP_PACKS, jump, 5), "A third ordinary Plasma Pistol exceeds the five-model limit")
	jump = records(JUMP_PACKS, 10)
	for model_index in [1, 2, 3, 4]: jump[model_index].vanguard_pistol = "plasma-pistol"
	jump[5].vanguard_pistol = "plasma-pistol"
	check(not E.valid_saved_loadout(JUMP_PACKS, jump, 10), "A fifth ordinary Plasma Pistol exceeds the ten-model limit")
	jump[0].vanguard_melee = "thunder-hammer"
	jump[0].vanguard_pistol = "combat-shield"
	check(not E.valid_saved_loadout(JUMP_PACKS, jump, 10), "An over-cap Plasma record remains invalid with a Sergeant shield")
	var controls := E.controls_for_model(JUMP_PACKS, 0, 5)
	var ordinary := E.controls_for_model(JUMP_PACKS, 1, 5)
	check(controls.size() == 2 and controls[1].choices.size() == 3 and ordinary.size() == 2 and ordinary[1].choices.size() == 1 and ordinary[1].choices[0].label == "Master-crafted Power Weapon", "The Workshop allows Sergeant melee replacements and shows ordinary fixed melee")
	for loadout: String in ["bolt-pistol", "storm-shield", "grav-pistol", "hand-flamer", "inferno-pistol", "plasma-pistol"]:
		check(not P.vanguard_veteran_squad_weapons(loadout).is_empty(), "The local Legends factory resolves %s" % loadout)
	for pistol: String in ["heavy-bolt-pistol", "plasma-pistol", "combat-shield"]:
		for melee: String in ["default", "power-fist", "thunder-hammer"]:
			check(not P.vanguard_veteran_weapons(true, pistol, melee, pistol == "combat-shield").is_empty(), "The local Jump Sergeant factory resolves %s + %s" % [pistol, melee])
		check(not P.vanguard_veteran_weapons(false, pistol, "default", pistol == "combat-shield").is_empty(), "The local ordinary Jump Veteran factory resolves %s" % pistol)

func inspect_bank(army: Dictionary) -> void:
	check(R.validate(army).is_empty(), "Saved Vanguard lists pass roster validation")
	check(R.summary(army).points == 1040, "Saved Vanguard options preserve first-two and third-plus copy prices")
	check(R.model_equipment(army.entries[0], 0, 1).vanguard_veteran_squad_loadout == "storm-shield" and R.model_equipment(army.entries[0], 1, 2).vanguard_veteran_squad_loadout == "inferno-pistol", "Vanguard Legends copies retain independent model choices")
	check(R.model_equipment(army.entries[1], 0, 0).vanguard_melee == "thunder-hammer" and R.model_equipment(army.entries[1], 0, 5).vanguard_pistol == "combat-shield" and R.model_equipment(army.entries[1], 1, 1).vanguard_pistol == "plasma-pistol", "Jump unit copies retain role weapons and shields")
	var jump_loadout := R.model_equipment_loadouts(army.entries[1], 0)
	check(E.valid_saved_loadout(JUMP_PACKS, jump_loadout, 10), "The reopened ten-model Jump unit still passes its whole-unit Plasma cap")

func find_model(state: Dictionary, owner: int, definition: String, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and str(unit.get("definition_id", "")).ends_with(definition) and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func find_model_in_squad(state: Dictionary, owner: int, squad: int, model_index: int) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("squad", -1)) == squad and int(unit.get("saved_equipment_model_index", -1)) == model_index: return model
	return -1

func verify_matches(army: Dictionary) -> void:
	var admitted := Training.admit_current_catalog(army)
	check(str(admitted.get("error", "")).is_empty(), "Saved Vanguard options project into the current catalog: " + str(admitted.get("error", "")))
	if not str(admitted.get("error", "")).is_empty(): return
	var state := Prepared.initial_state({"unit_abilities": true, "official_mission": false, "checked_rosters": false}, {1: admitted.selection, 2: admitted.selection})
	check(not state.has("error"), "Both players materialize their saved Vanguard equipment: " + str(state.get("error", "")))
	if state.has("error"): return
	for owner: int in [1, 2]:
		var squad_offset := 0
		for entry_index in range(admitted.selection.entries.size()):
			var selected_entry: Dictionary = admitted.selection.entries[entry_index]
			var definition := str(selected_entry.definition_id)
			for copy_index in range(int(selected_entry.copies)):
				var squad := owner + squad_offset * 2
				var copy_loadout: Array = selected_entry.saved_model_loadouts[copy_index]
				for model_index in range(int(selected_entry.models)):
					var model := find_model_in_squad(state, owner, squad, model_index)
					check(model >= 0, "Prepared %s squad %d contains stable model %d for player %d" % [definition, squad, model_index + 1, owner])
					if model < 0: continue
					var unit: Dictionary = state.units[model]
					var equipment: Dictionary = copy_loadout[model_index]
					var expected: Dictionary = {}
					E.prepare(expected, definition, equipment, int(selected_entry.models), model_index)
					var weapons_match: bool = unit.ranged_weapons == expected.ranged_weapons and unit.melee_weapons == expected.melee_weapons
					var saved_match: bool = unit.get("saved_model_equipment", {}) == equipment
					var locked: bool = bool(unit.get("vanguard_veteran_saved_model_loadout_locked", false))
					check(weapons_match and saved_match and locked, "Prepared %s model %d carries the exact saved record, weapons and lock (weapons=%s saved=%s lock=%s actual=%s/%s expected=%s/%s)" % [definition, model_index + 1, str(weapons_match), str(saved_match), str(locked), str(unit.ranged_weapons), str(unit.melee_weapons), str(expected.get("ranged_weapons", [])), str(expected.get("melee_weapons", []))])
					if definition == VETERANS:
						var expected_invulnerable := 4 if str(equipment.vanguard_veteran_squad_loadout) == "storm-shield" else 0
						check(int(unit.get("defense", {}).get("invulnerable_target", 0)) == expected_invulnerable, "Legends Storm Shield updates only its model's invulnerable save")
					else:
						var expected_invulnerable := 5 if str(equipment.vanguard_pistol) == "combat-shield" else 0
						check(int(unit.get("defense", {}).get("invulnerable_target", 0)) == expected_invulnerable, "Jump Combat Shield updates only its model's invulnerable save")
				squad_offset += 1
	var setup_choices: Array = Actions.choices(state, 1)
	check(not setup_choices.any(func(choice: Dictionary) -> bool: return str(choice.get("action", "")) in LOCKED_ACTIONS), "Saved Vanguard equipment is absent from preparation choices")
	for tuple: Array in [[VETERANS, 0, "vanguard-veteran-squad-loadout", "plasma-pistol"], [JUMP_PACKS, 1, "vanguard-veteran-pistol", "combat-shield"], [JUMP_PACKS, 0, "vanguard-veteran-melee", "power-fist"]]:
		var definition: String = tuple[0]
		var model_index: int = tuple[1]
		var action: String = tuple[2]
		var value: String = tuple[3]
		var target_model := find_model(state, 1, definition.get_slice(":", 3), model_index)
		if target_model < 0: continue
		var before := state.duplicate(true)
		var result := Actions.apply(state, 1, {"action": action, "model": target_model, "target": int(state.units[target_model].squad), "value": value}, Vector2.ZERO, Callable())
		check(not str(result.get("error", "")).is_empty() and state == before, "Saved %s command rejects equipment changes without match mutation" % action)

func picker_index(picker: OptionButton, wanted: String) -> int:
	for index in range(picker.item_count):
		if str(picker.get_item_metadata(index)) == wanted: return index
	return -1

func verify_builder(army: Dictionary) -> void:
	var panel := Builder.new()
	panel.storage_path = ProjectSettings.globalize_path("user://vanguard-builder-%d.json" % OS.get_process_id())
	root.add_child(panel)
	panel.draft = army.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	var legends_rows: Control = panel.per_model_equipment_controls
	check(legends_rows.get_child_count() == 5 and (legends_rows.get_child(0).get_child(0) as Label).text == "Vanguard Sergeant", "Workshop labels the Legends Sergeant and model records")
	var legends_picker := legends_rows.get_child(1).get_child(2) as OptionButton
	check(legends_picker.item_count == 6 and picker_index(legends_picker, "storm-shield") >= 0, "Workshop exposes all six audited Legends pistol/shield choices")
	var changed_index := picker_index(legends_picker, "plasma-pistol")
	legends_picker.select(changed_index)
	legends_picker.item_selected.emit(changed_index)
	check(str(R.model_equipment(panel.draft.entries[0], 0, 1).vanguard_veteran_squad_loadout) == "plasma-pistol", "Legends selector updates the selected stable model in the draft")
	panel._select_entry(1)
	var jump_rows: Control = panel.per_model_equipment_controls
	var sergeant_card: Control = jump_rows.get_child(0)
	var sergeant_heading := sergeant_card.get_child(0) as Label
	var sergeant_fields: Control = sergeant_card.get_child(1)
	var sergeant_pistol := sergeant_fields.get_child(0).get_child(1) as OptionButton
	var sergeant_melee := sergeant_fields.get_child(1).get_child(1) as OptionButton
	var ordinary_fields: Control = jump_rows.get_child(1).get_child(1)
	var ordinary_melee := ordinary_fields.get_child(1).get_child(1) as OptionButton
	check(jump_rows.get_child_count() == int(panel.draft.entries[1].models) and sergeant_heading.text == "Vanguard Sergeant" and sergeant_pistol.item_count == 3 and sergeant_melee.item_count == 3 and ordinary_melee.disabled, "Jump Workshop stacks model names above Sergeant choices and fixed ordinary melee (rows=%d heading=%s pistol=%d melee=%d ordinary_disabled=%s)" % [jump_rows.get_child_count(), sergeant_heading.text, sergeant_pistol.item_count, sergeant_melee.item_count, str(ordinary_melee.disabled)])
	panel.free()
	var path := ProjectSettings.globalize_path("user://vanguard-builder-%d.json" % OS.get_process_id())
	for suffix in ["", ".bak"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)

func run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--reopen":
		var reopened := Store.new(args[1])
		check(reopened.error.is_empty() and reopened.active().lists.size() == 1, "Separate process reopens the saved Vanguard list")
		if reopened.error.is_empty() and reopened.active().lists.size() == 1: inspect_bank(reopened.active().lists[0])
		quit(1 if failures else 0)
		return
	check_source_options()
	var catalog := Catalog.new()
	check(catalog.select_edition("11e").is_empty(), "Consolidated local catalog opens offline")
	var army := make_army(catalog)
	check(R.validate(army).is_empty() and R.summary(army).points == 1040, "Vanguard list preserves exact source-based copy tiers")
	var before_cap: Dictionary = army.entries[1].duplicate(true)
	check(not R.set_model_equipment(army.entries[1], 0, 5, "vanguard_pistol", "plasma-pistol") and army.entries[1] == before_cap, "A fifth ordinary Jump Plasma choice is rejected atomically")
	var saved_path := ProjectSettings.globalize_path("user://vanguard-saved-equipment-%d.json" % OS.get_process_id())
	var store := Store.new(saved_path)
	var saved := store.save_list(army)
	check(saved.error.is_empty(), "Army Workshop saves Vanguard model equipment to disk")
	if saved.error.is_empty():
		var child_output: Array = []
		var child_exit := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_vanguard_saved_equipment.gd", "--", "--reopen", saved_path], child_output, true)
		check(child_exit == 0, "A separate process reopens and validates every Vanguard model record: " + str(child_output))
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
	print("Saved Vanguard Veteran equipment: %d failures" % failures)
	quit(1 if failures else 0)
