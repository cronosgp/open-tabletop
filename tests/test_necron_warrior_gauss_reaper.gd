extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const WARRIOR_ID := "40kdc:11e:necrons:necron-warriors"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var dice_calls := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func six() -> int:
	dice_calls += 1
	return 6

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].entries = [
		{"definition_id": WARRIOR_ID, "models": 10, "copies": 1},
		{"definition_id": WARRIOR_ID, "models": 20, "copies": 1}]
	return result

func warrior_models(state: Dictionary, strength: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != 2 or C.UnitAbilities.identity(unit) != "necron-warriors": continue
		var squad := int(unit.get("squad", -1))
		if int(state.squads.get(squad, {}).get("starting_strength", -1)) == strength: result.append(model)
	result.sort()
	return result

func loadout_choices(state: Dictionary, owner: int, action: String, value: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for option: Dictionary in C.UnitActions.choices(state, owner):
		if str(option.get("action", "")) != action: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		result.append(option)
	return result

func submit(state: Dictionary, player: int, action: String, model: int, value: String) -> Dictionary:
	for option: Dictionary in loadout_choices(state, player, action, value):
		if int(option.get("model", -1)) == model:
			return PublicUnitCommand.submit(state, player, option)
	return {"error": "No current public choice for %s=%s on Warrior %d." % [action, value, model]}

func weapon_id(state: Dictionary, model: int) -> String:
	var weapons: Array = state.units[model].get("ranged_weapons", [])
	return str(weapons[0].get("id", "")) if weapons.size() == 1 else ""

func weapon_name(state: Dictionary, model: int) -> String:
	var weapons: Array = state.units[model].get("ranged_weapons", [])
	return str(weapons[0].get("profiles", {}).get("standard", {}).get("name", "")) if weapons.size() == 1 else ""

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("necron-warriors")
	check(profile.get("source_datasheet_id", "") == "000000534" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Warrior replacement uses the verified local App v1.2 datasheet profile")
	check(profile.get("source_options", []).size() == 1 and profile.source_options[0].implemented and profile.source_options[0].maximum == "unit_size", "The local per-model Gauss Reaper option is implemented for any number of models")
	var resolved := Army.resolve("Necrons", WARRIOR_ID)
	check(str(resolved.get("error", "")).is_empty() and int(resolved.get("cost", -1)) == 85 and resolved.get("pack_hash", "") == Profiles.digest(), "The source-bounded 10-model Warrior choice resolves from the consolidated local profile")
	var ten := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": WARRIOR_ID, "models": 10, "copies": 1}]})
	var twenty := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": WARRIOR_ID, "models": 20, "copies": 1}]})
	check(str(ten.get("error", "")).is_empty() and int(ten.get("total", -1)) == 85 and str(twenty.get("error", "")).is_empty() and int(twenty.get("total", -1)) == 190, "Both locally priced Warrior sizes are admitted at 85 and 190 points")
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": false, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Current Warrior roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	state.unit_abilities.setup_players = [1]
	if state.has("awakened_dynasty"): state.awakened_dynasty.pending = []
	C.UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		var doctrine_error := C.select_combat_doctrine(state, int(state.active), "none", int(state.revision))
		check(doctrine_error.is_empty(), "Resolve the unrelated doctrine setup before evaluating the Warrior loadout")
	check(C.UnitActions.setup_actor(state) == 2, "Necron player receives its army-preparation window")
	var small := warrior_models(state, 10)
	var large := warrior_models(state, 20)
	check(small.size() == 10 and large.size() == 20, "Both source-priced unit sizes materialize their exact model counts")
	var options := loadout_choices(state, 2, "necron-warrior-gauss-reaper", "reaper")
	check(str(state.get("match_manifest", {}).get("content_hash", "")).contains(Profiles.digest()), "The current match manifest records the same local Necrons profile digest used by the loadout")
	check(options.size() == 30, "Every Warrior in the 10- and 20-model squads can independently replace its flayer")
	for model: int in small + large:
		check(weapon_name(state, model) == "Gauss flayer", "Each Warrior starts with its datasheet default Gauss flayer")
	if not options.is_empty():
		var forged: Dictionary = options[0].duplicate(true)
		forged.value = "unsupported"
		var before := var_to_bytes(state)
		check(not PublicUnitCommand.error(state, 2, forged).is_empty() and before == var_to_bytes(state), "A forged weapon value is rejected without mutating the list")
		check(not PublicUnitCommand.error(state, 1, options[0]).is_empty() and before == var_to_bytes(state), "The opposing player cannot change the Necron player's Warrior equipment")
	for model: int in small:
		var result := submit(state, 2, "necron-warrior-gauss-reaper", model, "reaper")
		check(str(result.get("error", "")).is_empty() and weapon_id(state, model) == "gauss-reaper", "Public preparation equips one Warrior's Gauss reaper independently: %d" % model)
		var selected: Dictionary = Equipment.select(state, model, false, "gauss-reaper", "standard")
		check(str(selected.get("error", "")).is_empty() and selected.stats == profile.additional_weapon_profiles.ranged[0].profiles.standard, "The equipped Reaper resolves through the shared weapon inventory")
	check(loadout_choices(state, 2, "necron-warrior-gauss-reaper", "reaper").filter(func(option: Dictionary) -> bool: return int(option.get("target", -1)) == int(state.units[small[0]].squad)).is_empty(), "The 10-model squad can replace all ten flayers; no one-model cap is applied")
	check(loadout_choices(state, 2, "necron-warrior-gauss-reaper", "flayer").size() == 10, "Each selected Warrior can restore its own default flayer")
	var large_model: int = large[0] if not large.is_empty() else -1
	if large_model >= 0:
		var result := submit(state, 2, "necron-warrior-gauss-reaper", large_model, "reaper")
		check(str(result.get("error", "")).is_empty() and weapon_name(state, large_model) == "Gauss reaper" and weapon_name(state, large[1]) == "Gauss flayer", "The 20-model unit supports the same per-model replacement without changing its neighbours")
		check(submit(state, 2, "necron-warrior-gauss-reaper", large_model, "flayer").get("error", "").is_empty() and weapon_id(state, large_model) == "gauss-flayer", "A Warrior can restore its source default during the same preparation window")
	var legacy_state := F.fresh()
	if not legacy_state.has("error"):
		legacy_state.unit_abilities.setup_players = [1]
		if legacy_state.has("awakened_dynasty"): legacy_state.awakened_dynasty.pending = []
		C.UnitActions.reconcile(legacy_state)
		if C.Doctrines.needs_choice(legacy_state): C.select_combat_doctrine(legacy_state, int(legacy_state.active), "none", int(legacy_state.revision))
		check(loadout_choices(legacy_state, 2, "necron-warrior-gauss-reaper").is_empty(), "Historical starter-backed Warrior profiles do not receive the current Reaper replacement")
	state.unit_abilities.setup_players = [1, 2]
	state.phase = "command"
	state.active = 2
	state.turn = 1
	state.round = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	C.Reanimation.start_command(state)
	check(C.Reanimation.open_end_command(state), "Current Warriors enter their source-linked Reanimation step")
	var reanimation_squad := int(state.units[small[0]].squad) if not small.is_empty() else -1
	var initial_roll := C.Reanimation.roll_unit(state, reanimation_squad, six)
	var legion_choices: Array[Dictionary] = []
	for option: Dictionary in C.UnitActions.choices(state, 2):
		if str(option.get("action", "")) in ["legion-keep", "legion-reroll"]: legion_choices.append(option)
	var reroll: Dictionary = legion_choices.filter(func(option: Dictionary) -> bool: return option.get("action", "") == "legion-reroll")[0] if legion_choices.any(func(option: Dictionary) -> bool: return option.get("action", "") == "legion-reroll") else {}
	var roll_count := dice_calls
	var reroll_result := PublicUnitCommand.submit(state, 2, reroll, Vector2.ZERO, six) if not reroll.is_empty() else {"error": "Their Number is Legion did not expose the re-roll choice."}
	check(str(initial_roll.get("error", "")).is_empty() and legion_choices.size() == 2 and str(reroll_result.get("error", "")).is_empty() and dice_calls == roll_count + 1, "Current Warriors can use Their Number is Legion to re-roll a Reanimation roll through the public choice")
	if failures == 0: print("Necron Warriors Gauss Reaper local checks: passed")
	else: print("Necron Warriors Gauss Reaper local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
