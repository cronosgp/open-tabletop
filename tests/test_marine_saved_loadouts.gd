extends SceneTree

const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const ArmyRoster = preload("res://scripts/army_roster.gd")
const Profiles = preload("res://scripts/army_profiles.gd")
const TrainingRoster = preload("res://scripts/edition_11/training_roster.gd")
const PreparedTraining = preload("res://scripts/edition_11/prepared_training.gd")
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const BuilderPanel = preload("res://scripts/army_builder_panel.gd")
const Fixture = preload("res://tests/all_units_fixture.gd")
var ROOT := ""

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func unit_entry(source_id: String, models: int, copies: int = 1) -> Dictionary:
	var identity := source_id if source_id.begins_with("40kdc:") else "40kdc:11e:adeptus-astartes:" + source_id
	var unit := Catalog.current_catalog_choice({"id": identity, "edition": "11e", "faction": "Space Marines"})
	if unit.is_empty(): return {}
	var option_index := -1
	for index in range(unit.get("options", []).size()):
		if int(unit.options[index].get("models", -1)) == models:
			option_index = index
			break
	if option_index < 0: return {}
	unit.role = ArmyRoster.role(unit.get("keywords", []))
	return ArmyRoster.entry(unit, option_index, copies)

func find_models(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model_id: int in state.get("units", {}):
		var model: Dictionary = state.units[model_id]
		if int(model.get("owner", -1)) == owner and UnitAbilities.identity(model) == identity:
			result.append(model_id)
	result.sort()
	return result

func ranged_ids(model: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for weapon: Dictionary in model.get("ranged_weapons", []): result.append(str(weapon.get("id", "")))
	return result

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	ROOT = "res://.tools/marine-saved-loadout-%d" % OS.get_process_id()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT))
	var list := ArmyRoster.new_list("11e", "Space Marines", "custom", 3000)
	list.name = "Saved marine equipment fixture"

	var scouts := unit_entry("scout-squad", 5)
	var reivers := unit_entry("reiver-squad", 5, 2)
	var atvs := unit_entry("invader-atvs", 2)
	var assault := unit_entry("assault-intercessor-squad", 5, 2)
	var heavy := unit_entry("heavy-intercessor-squad", 10)
	check(not scouts.is_empty() and not reivers.is_empty() and not atvs.is_empty() and not assault.is_empty() and not heavy.is_empty(), "Every option-bearing Space Marine profile is selectable from the consolidated local catalog")
	if scouts.is_empty() or reivers.is_empty() or atvs.is_empty() or assault.is_empty() or heavy.is_empty():
		print("Marine saved-loadout checks: %d failures" % (failures + 1))
		quit(1)
		return

	check(ArmyRoster.set_scout_gun(scouts, 0, 0, "shotgun") and ArmyRoster.set_scout_sergeant_blade(scouts, 0, "chainsword") and ArmyRoster.set_scout_gun(scouts, 0, 1, "sniper-rifle"), "Scout Sergeant and trooper retain independent source-listed choices")
	check(ArmyRoster.set_unit_equipment(reivers, 0, "reiver_grav_chutes", true) and ArmyRoster.set_unit_equipment(reivers, 1, "reiver_grapnel_launchers", true), "Separate Reiver copies retain distinct squad-wide equipment")
	ArmyRoster.set_model_equipment(atvs, 0, 1, "invader_atv_multi_melta", true)
	ArmyRoster.set_model_equipment(assault, 0, 0, "assault_intercessor_sergeant_pistol", "hand-flamer")
	ArmyRoster.set_model_equipment(assault, 0, 0, "assault_intercessor_sergeant_melee", "power-fist")
	ArmyRoster.set_model_equipment(assault, 1, 0, "assault_intercessor_sergeant_pistol", "plasma-pistol")
	ArmyRoster.set_model_equipment(assault, 1, 0, "assault_intercessor_sergeant_melee", "thunder-hammer")
	ArmyRoster.set_model_equipment(heavy, 0, 1, "heavy_intercessor_bolter", true)
	ArmyRoster.set_model_equipment(heavy, 0, 6, "heavy_intercessor_bolter", true)
	list.entries = [scouts, reivers, atvs, assault, heavy]
	check(ArmyRoster.validate(list).is_empty(), "Mixed saved loadouts satisfy each datasheet's local profile limits")
	check(ArmyRoster.summary(list).points == 770, "Army points include the two source-listed Invader ATV Multi-melta surcharges")

	var store := Profiles.new(ROOT.path_join("army-lists.json"))
	var saved := store.save_list(list)
	var reopened := Profiles.new(ROOT.path_join("army-lists.json"))
	var loaded: Dictionary = reopened.active().get("lists", [])[0] if not reopened.active().get("lists", []).is_empty() else {}
	check(saved.get("error", "").is_empty() and reopened.error.is_empty() and not loaded.is_empty(), "The configured army saves and reopens from the local profile bank")
	if loaded.is_empty():
		print("Marine saved-loadout checks: %d failures" % (failures + 1))
		quit(1)
		return
	var loaded_scouts: Dictionary = loaded.entries[0]
	var loaded_reivers: Dictionary = loaded.entries[1]
	var loaded_atvs: Dictionary = loaded.entries[2]
	var loaded_assault: Dictionary = loaded.entries[3]
	var loaded_heavy: Dictionary = loaded.entries[4]
	check(ArmyRoster.model_equipment(loaded_scouts, 0, 0).get("scout_gun", "") == "shotgun" and ArmyRoster.model_equipment(loaded_scouts, 0, 0).get("scout_sergeant_blade", "") == "chainsword" and ArmyRoster.model_equipment(loaded_scouts, 0, 1).get("scout_gun", "") == "sniper-rifle", "Scout model equipment survives save and reload")
	check(ArmyRoster.unit_equipment(loaded_reivers, 0).get("reiver_grav_chutes", false) and ArmyRoster.unit_equipment(loaded_reivers, 1).get("reiver_grapnel_launchers", false), "Reiver copy equipment survives save and reload independently")
	check(ArmyRoster.invader_atv_loadouts(loaded_atvs, 0) == [false, true], "Invader ATV model choices survive save and reload")
	check(ArmyRoster.assault_intercessor_sergeant_loadouts(loaded_assault) == [{"pistol_choice": "hand-flamer", "melee_choice": "power-fist"}, {"pistol_choice": "plasma-pistol", "melee_choice": "thunder-hammer"}], "Assault Intercessor Sergeant choices survive save and reload by copy identity")
	check(ArmyRoster.heavy_intercessor_bolter_loadouts(loaded_heavy, 0) == [false, true, false, false, false, false, true, false, false, false], "Heavy Intercessor weapon choices survive save and reload on distinct models")

	var workshop := BuilderPanel.new()
	workshop.storage_path = ROOT.path_join("workshop-profiles.json")
	workshop.cache_directory = ROOT.path_join("catalogs")
	root.add_child(workshop)
	workshop.draft = loaded.duplicate(true)
	workshop.selected_entry_index = 0
	workshop._render_sergeant_loadout_controls(0)
	var scout_rows := workshop.per_model_equipment_controls.get_children()
	var scout_gun_picker: OptionButton = scout_rows[1].get_child(1) if scout_rows.size() > 1 else null
	check(workshop.sergeant_loadout_heading.text == "SCOUT SQUAD MODEL EQUIPMENT" and scout_gun_picker != null and str(scout_gun_picker.get_item_metadata(scout_gun_picker.selected)) == "shotgun", "The Workshop exposes saved Scout equipment on the corresponding model controls")
	workshop.selected_entry_index = 1
	workshop._render_sergeant_loadout_controls(1)
	var reiver_checks := workshop.per_model_equipment_controls.get_children().filter(func(child: Node) -> bool: return child is CheckBox)
	check(workshop.sergeant_loadout_heading.text == "REIVER SQUAD GEAR" and reiver_checks.size() == 2 and not reiver_checks[0].button_pressed and reiver_checks[1].button_pressed, "The Workshop exposes independent squad gear for the selected Reiver copy")
	workshop.selected_entry_index = 2
	workshop._render_sergeant_loadout_controls(0)
	var atv_checks := workshop.per_model_equipment_controls.get_children().filter(func(child: Node) -> bool: return child is CheckBox)
	check(workshop.sergeant_loadout_heading.text == "INVADER ATV MODEL EQUIPMENT" and atv_checks.size() == 2 and atv_checks[1].button_pressed, "The Workshop exposes each Invader ATV model's selected weapon")
	workshop.selected_entry_index = 3
	workshop._render_sergeant_loadout_controls(1)
	check(workshop.sergeant_rifle_picker.get_item_metadata(workshop.sergeant_rifle_picker.selected) == "plasma-pistol" and workshop.sergeant_melee_picker.get_item_metadata(workshop.sergeant_melee_picker.selected) == "thunder-hammer", "The Workshop restores the selected Assault Intercessor Sergeant package")
	workshop.selected_entry_index = 4
	workshop._render_sergeant_loadout_controls(0)
	var heavy_checks := workshop.per_model_equipment_controls.get_children().filter(func(child: Node) -> bool: return child is CheckBox)
	check(workshop.sergeant_loadout_heading.text == "HEAVY INTERCESSOR MODEL EQUIPMENT" and heavy_checks.size() == 9 and heavy_checks.filter(func(child: CheckBox) -> bool: return child.button_pressed).size() == 2, "The Workshop displays the Heavy Intercessor per-five-model choices")
	workshop.free()

	var admitted := TrainingRoster.inspect(loaded, {}, true)
	check(admitted.get("error", "").is_empty(), "Every reopened loadout passes current local rules admission")
	if admitted.get("error", "").is_empty():
		# Keep both seats on the same category and limit for match admission.
		var selections := Fixture.current_marine_selections()
		selections[1] = admitted.selection.duplicate(true)
		selections[2].category = "custom"
		selections[2].points_limit = 3000
		var options := {"unit_abilities": true, "combat_doctrines": false, "manual_allocation": false}
		var state: Dictionary = PreparedTraining.initial_state(options, selections)
		check(not state.has("error"), "The admitted saved loadouts materialize in a local match: %s" % str(state.get("error", "")))
		if not state.has("error"):
			var scout_models := find_models(state, 1, "scout-squad")
			var reiver_models := find_models(state, 1, "reiver-squad")
			var atv_models := find_models(state, 1, "invader-atvs")
			var assault_models := find_models(state, 1, "assault-intercessor-squad")
			var heavy_models := find_models(state, 1, "heavy-intercessor-squad")
			check(scout_models.size() == 5 and ranged_ids(state.units[scout_models[0]]).has("shotgun") and ranged_ids(state.units[scout_models[1]]).has("sniper-rifle") and bool(state.units[scout_models[0]].get("scout_loadout_locked", false)), "Saved Scout choices materialize and lock before Deployment")
			var reiver_copies: Dictionary = {}
			for model_id: int in reiver_models: reiver_copies[int(state.units[model_id].squad)] = true
			var reiver_equipment: Array[Dictionary] = []
			for squad_id: int in reiver_copies: reiver_equipment.append(state.squads[squad_id])
			check(reiver_equipment.size() == 2 and reiver_equipment.any(func(squad: Dictionary) -> bool: return bool(squad.get("reiver_grav_chutes", false)) and not bool(squad.get("reiver_grapnel_launchers", false))) and reiver_equipment.any(func(squad: Dictionary) -> bool: return not bool(squad.get("reiver_grav_chutes", false)) and bool(squad.get("reiver_grapnel_launchers", false))), "Saved Reiver copies materialize their separate squad packages before Deployment")
			check(atv_models.size() == 2 and ranged_ids(state.units[atv_models[0]]).has("onslaught-gatling-cannon") and ranged_ids(state.units[atv_models[1]]).has("multi-melta") and bool(state.units[atv_models[1]].get("invader_atv_loadout_locked", false)), "Saved Invader ATV packages install per miniature and lock before Deployment")
			var assault_loadouts: Array[String] = []
			for model_id: int in assault_models:
				var model: Dictionary = state.units[model_id]
				if bool(model.get("sergeant", false)):
					var ids := ranged_ids(model)
					var melee_ids: Array = model.get("melee_weapons", []).map(func(weapon: Dictionary) -> String: return str(weapon.get("id", "")))
					if ids.has("hand-flamer") and melee_ids.has("power-fist"): assault_loadouts.append("hand-flamer|power-fist")
					elif ids.has("plasma-pistol") and melee_ids.has("thunder-hammer"): assault_loadouts.append("plasma-pistol|thunder-hammer")
			check(assault_loadouts.size() == 2 and bool(state.units[assault_models[0]].get("assault_intercessor_loadout_locked", false)), "Assault Intercessor Sergeant packages materialize per copy and remain fixed")
			var equipped_heavy_bolters := 0
			for model_id: int in heavy_models:
				var model: Dictionary = state.units[model_id]
				if ranged_ids(model).has("heavy-bolter"): equipped_heavy_bolters += 1
			check(heavy_models.size() == 10 and equipped_heavy_bolters == 2 and heavy_models.any(func(model_id: int) -> bool: return bool(state.units[model_id].get("heavy_intercessor_loadout_locked", false)) and ranged_ids(state.units[model_id]).has("heavy-bolter")), "Saved Heavy Intercessor bolters materialize on the selected models and remain fixed")

	if failures == 0:
		print("Marine saved-loadout checks passed")
		quit()
	else:
		print("Marine saved-loadout checks: %d failures" % failures)
		quit(1)
