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
const FOOT := "death-company-marines"
const JUMP := "death-company-marines-with-jump-packs"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	check_source_schema()
	run_saved_squad_flow()
	print("Death Company saved-loadout checks: %d failures" % failures)
	quit(1 if failures else 0)

func check_source_schema() -> void:
	for identity: String in [FOOT, JUMP]:
		var definition := _definition(identity)
		var defaults: Array[Dictionary] = []
		for _model in range(5): defaults.append(Adapter.defaults(definition))
		check(Adapter.valid_saved_loadout(definition, defaults, 5), "%s accepts the source default package for five models" % identity)
		if identity == JUMP: check(not defaults[0].has("death_company_grenade_launcher"), "Jump Pack schema does not persist the foot squad's Grenade Launcher field")
		defaults.append(Adapter.defaults(definition))
		defaults.append(Adapter.defaults(definition))
		defaults.append(Adapter.defaults(definition))
		defaults.append(Adapter.defaults(definition))
		defaults.append(Adapter.defaults(definition))
		check(Adapter.valid_saved_loadout(definition, defaults, 10), "%s accepts the source default package for ten models" % identity)
		check(not Adapter.valid_saved_loadout(definition, defaults.slice(0, 5), 6), "%s rejects unsupported six-model compositions" % identity)
	check(not Adapter.valid_saved_loadout(Adapter.DEATH_COMPANY_MARINES, [{"death_company_melee_package": "eviscerator"}], 5), "Saved squad schema requires a record for every model")
	check(not Adapter.valid_saved_loadout(Adapter.DEATH_COMPANY_JUMP_PACK_MARINES, _invalid_jump_loadout(), 5), "Saved schema rejects unit-level equipment limits exceeded across models")
	check(not Adapter.valid(Adapter.DEATH_COMPANY_MARINES, {"death_company_melee_package": "chainsword", "death_company_pistol_package": "heavy-bolt-pistol", "death_company_grenade_launcher": "yes"}, 5), "Saved model schema rejects non-boolean Grenade Launcher values")

func run_saved_squad_flow() -> void:
	var list := Roster.new_list("11e", "Space Marines", "custom", 2000)
	var foot := _entry(FOOT, 10, 1)
	var jump := _entry(JUMP, 5, 2)
	if foot.is_empty() or jump.is_empty():
		check(false, "Local catalog exposes both audited Death Company compositions")
		return
	check(Roster.set_model_equipment(foot, 0, 0, "death_company_melee_package", "bolt-rifle-fire"), "Foot squad saves Bolt Rifle Fire + Combat Blade on a stable model")
	check(Roster.set_model_equipment(foot, 0, 0, "death_company_grenade_launcher", true), "Foot squad saves a Grenade Launcher on a Bolt Rifle carrier")
	check(Roster.set_model_equipment(foot, 0, 0, "death_company_pistol_package", "plasma-pistol"), "Foot squad saves a listed pistol replacement")
	check(Roster.set_model_equipment(foot, 0, 1, "death_company_melee_package", "eviscerator") and Roster.set_model_equipment(foot, 0, 2, "death_company_melee_package", "eviscerator"), "Ten-model foot squad saves both source-allowed Eviscerators")
	check(Roster.set_model_equipment(foot, 0, 3, "death_company_melee_package", "power-weapon"), "Foot squad independently saves its single power-melee replacement")
	check(not Roster.set_model_equipment(foot, 0, 4, "death_company_melee_package", "power-fist"), "Foot squad rejects a second Power Fist/Power Weapon/Thunder Hammer replacement")
	check(not Roster.set_model_equipment(foot, 0, 1, "death_company_grenade_launcher", true), "Foot squad rejects a Grenade Launcher on a non-rifle carrier")
	check(Roster.set_model_equipment(jump, 0, 0, "death_company_melee_package", "eviscerator"), "Jump Pack squad saves an Eviscerator per five models")
	check(Roster.set_model_equipment(jump, 0, 0, "death_company_pistol_package", "inferno-pistol"), "Jump Pack squad saves its separate Inferno Pistol allowance")
	check(Roster.set_model_equipment(jump, 0, 1, "death_company_melee_package", "power-fist"), "Jump Pack squad saves its independent Power Fist allowance")
	check(Roster.set_model_equipment(jump, 0, 1, "death_company_pistol_package", "hand-flamer"), "Jump Pack squad saves the separate Hand Flamer allowance")
	check(Roster.set_model_equipment(jump, 0, 2, "death_company_melee_package", "power-weapon") and Roster.set_model_equipment(jump, 0, 3, "death_company_melee_package", "power-weapon"), "Jump Pack squad saves two Power Weapons per five models")
	check(Roster.set_model_equipment(jump, 0, 2, "death_company_pistol_package", "plasma-pistol") and Roster.set_model_equipment(jump, 0, 3, "death_company_pistol_package", "plasma-pistol"), "Jump Pack squad saves two Plasma Pistols per five models")
	check(not Roster.set_model_equipment(jump, 0, 4, "death_company_pistol_package", "plasma-pistol"), "Jump Pack squad rejects a third Plasma Pistol in a five-model copy")
	check(Roster.set_model_equipment(jump, 1, 0, "death_company_pistol_package", "plasma-pistol"), "A second Jump Pack copy saves a separate legal package")
	list.entries = [foot, jump]
	check(Roster.validate(list).is_empty(), "Roster accepts the legal per-model Death Company loadouts")
	var corrupted := list.duplicate(true)
	var corrupted_model_id := Roster.model_instance_id(corrupted.entries[1], 0, 4)
	corrupted.entries[1].model_equipment_by_id[corrupted_model_id].death_company_pistol_package = "plasma-pistol"
	check(not Roster.validate(corrupted).is_empty(), "Roster revalidation rejects a saved copy over its Plasma Pistol limit")

	var admitted := Training.admit_current_catalog(list)
	check(admitted.error.is_empty(), "Current local catalog accepts the audited Death Company saved equipment: " + str(admitted.get("error", "")))
	if admitted.error.is_empty():
		var selection: Dictionary = admitted.selection
		var selections := F.current_marine_selections()
		selections[1] = selection
		selections[1].category = "custom"
		selections[1].points_limit = 2000
		selections[2].category = "custom"
		selections[2].points_limit = 2000
		var state: Dictionary = Prepared.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true}, selections)
		check(not state.has("error") and str(state.get("setup_error", "")).is_empty(), "Saved per-model loadouts materialize into the match: " + str(state.get("setup_error", state.get("error", ""))))
		if not state.has("error"):
			var observed := 0
			var editable_model := -1
			for instance_id: int in state.units:
				var model: Dictionary = state.units[instance_id]
				var identity := C.UnitAbilities.identity(model)
				if int(model.get("owner", -1)) != 1 or identity not in [FOOT, JUMP]: continue
				observed += 1
				var equipment: Dictionary = model.get("saved_model_equipment", {})
				var weapons := Profiles.death_company_model_weapons(identity, str(equipment.death_company_melee_package), str(equipment.death_company_pistol_package), bool(equipment.get("death_company_grenade_launcher", false)))
				check(not weapons.is_empty() and model.ranged_weapons == weapons.ranged and model.melee_weapons == weapons.melee and bool(model.get("death_company_saved_loadout_locked", false)), "Each materialized Death Company model receives exact saved weapons and match lock")
				if editable_model < 0: editable_model = instance_id
			check(observed == 20, "The foot squad, Jump Pack squad and two separately configured copies materialize")
			state.phase = "deployment"
			state.active = 1
			state.unit_abilities.setup_players = []
			var options := Actions.choices(state, 1)
			check(not options.any(func(option: Dictionary) -> bool: return str(option.get("action", "")) in ["death-company-melee-loadout", "death-company-pistol-loadout", "death-company-grenade-launcher"]), "Saved equipment suppresses all repeated Death Company Army Preparation choices")
			if editable_model >= 0:
				var model: Dictionary = state.units[editable_model]
				var before := model.duplicate(true)
				var forced := {"action": "death-company-melee-loadout", "model": editable_model, "target": int(model.get("squad", -1)), "value": "chainsword"}
				var result: String = C.unit_action(state, 1, forced, Vector2.ZERO, int(state.revision))
				check(not result.is_empty() and state.units[editable_model].ranged_weapons == before.ranged_weapons, "Forced Army Preparation cannot overwrite a saved Death Company package")

	var panel := Builder.new()
	panel.storage_path = "user://death-company-saved-loadouts-editor.json"
	root.add_child(panel)
	panel.draft = list.duplicate(true)
	panel._render_draft()
	panel._select_entry(0)
	check(panel.per_model_equipment_controls.get_child_count() == 10, "Foot Death Company Workshop renders separate rows for all models")
	if panel.per_model_equipment_controls.get_child_count() == 10:
		var second_model_row := panel.per_model_equipment_controls.get_child(1) as HBoxContainer
		var pistol_picker := second_model_row.get_child(4) as OptionButton
		pistol_picker.select(1)
		pistol_picker.item_selected.emit(1)
		check(str(Roster.model_equipment(panel.draft.entries[0], 0, 1).death_company_pistol_package) == "heavy-bolt-pistol" and "limit" in str(panel.notice.text).to_lower(), "Workshop control rejects a second unit-limited pistol and explains the source limit")
	panel._select_entry(1)
	check(panel.per_model_equipment_controls.get_child_count() == 5, "Jump Pack Death Company Workshop renders source-listed per-model controls")
	panel.free()

func _entry(identity: String, models: int, copies: int) -> Dictionary:
	var definition := _definition(identity)
	var choice := Catalog.current_catalog_choice({"id": definition, "edition": "11e", "faction": "Space Marines"})
	if choice.is_empty(): return {}
	choice.role = Roster.role(choice.get("keywords", []))
	for option_index in range(choice.options.size()):
		if int(choice.options[option_index].get("models", 0)) == models: return Roster.entry(choice, option_index, copies)
	return {}

func _definition(identity: String) -> String:
	return Adapter.DEATH_COMPANY_JUMP_PACK_MARINES if identity == JUMP else Adapter.DEATH_COMPANY_MARINES

func _invalid_jump_loadout() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for model_index in range(5):
		var equipment := Adapter.defaults(Adapter.DEATH_COMPANY_JUMP_PACK_MARINES)
		if model_index < 3: equipment.death_company_pistol_package = "plasma-pistol"
		result.append(equipment)
	return result
