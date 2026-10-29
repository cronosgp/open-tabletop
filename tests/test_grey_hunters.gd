extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner in [1, 2]:
		result[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:grey-hunters", "models": 10, "copies": 1})
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())

func find_models(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return int(state.units[model].squad)
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value: return option
	return {}

func submit(state: Dictionary, player: int, action: String, model: int, target: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, player, {"action": action, "model": model, "target": target, "value": value})

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("grey-hunters")
	check(profile.get("source_book_id", "") == "000000036" and profile.get("source_datasheet_id", "") == "000000305" and profile.get("source_snapshot_id", "") == "20261029T003124Z", "Grey Hunters is bound to the Space Wolves App datasheet and verified local export")
	check(profile.get("points_by_models", {}) == {10: 180} and profile.get("models", 0) == 10 and profile.get("base_size_source_mm", 0) == 32, "Grey Hunters source composition, 180-point cost and 32 mm base are retained")
	check(profile.get("stats", {}) == {"movement_inches": 7, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "Grey Hunters characteristics match the current datasheet")
	check(profile.get("keywords", []).has("BATTLELINE") and profile.keywords.has("SPACE WOLVES") and profile.keywords.has("TACTICUS"), "Grey Hunters source keywords are published")
	check(profile.options.pack_leader_ranged_packages == ["bolt-pistol", "plasma-pistol"] and profile.options.pack_leader_melee_packages == ["chainsword", "power-fist", "power-weapon"], "The Pack Leader's independent replacements match the source options")
	var leader_weapons := Profiles.grey_hunters_pack_leader_weapons("plasma-pistol", "power-fist")
	check(leader_weapons.ranged.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["bolt-carbine", "plasma-pistol"] and leader_weapons.melee[0].id == "power-fist" and leader_weapons.ranged[1].profiles.supercharge.keywords.hazardous, "Pack Leader helper preserves the carbine and Plasma Pistol Hazardous profile")
	check(Profiles.grey_hunters_pack_leader_weapons("invented", "chainsword").is_empty(), "Unsupported Pack Leader loadouts are rejected")
	var state := fresh()
	check(not state.has("error"), "Grey Hunters prepare from the consolidated local construction catalog")
	if state.has("error"):
		print(str(state.error))
		quit(1)
		return
	var grey_models := find_models(state, 1, "grey-hunters")
	var enemy_squad := find_squad(state, 2, "intercessor-squad")
	var squad := find_squad(state, 1, "grey-hunters")
	check(grey_models.size() == 10 and C.living(state, squad).size() == 10 and int(state.squads[squad].training_cost) == 180, "The selected formation materializes as one ten-model, 180-point Grey Hunters unit")
	if grey_models.size() != 10 or enemy_squad < 0:
		print("Grey Hunters checks: %d failures" % failures)
		quit(1)
		return
	var leader := grey_models[0]
	var regular := grey_models[1]
	check(state.units[leader].get("sergeant", false) and state.units[leader].get("grey_hunters_model", -1) == 0 and state.units[regular].get("grey_hunters_model", -1) == 1, "The role index identifies the single Grey Hunter Pack Leader")
	check(state.units[leader].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["bolt-carbine", "bolt-pistol"] and state.units[leader].melee_weapons[0].id == "chainsword", "Pack Leader and regular models use the exact default Bolt Carbine, Bolt Pistol and Chainsword")
	check(find_choice(state, 1, "grey-hunters-pack-leader-pistol", leader, squad, "plasma-pistol").size() > 0 and find_choice(state, 1, "grey-hunters-pack-leader-melee", leader, squad, "power-weapon").size() > 0 and find_choice(state, 1, "grey-hunters-pack-leader-melee", leader, squad, "power-fist").size() > 0, "Army preparation offers all Pack Leader-only options")
	check(find_choice(state, 1, "grey-hunters-pack-leader-pistol", regular, squad, "plasma-pistol").is_empty() and find_choice(state, 1, "grey-hunters-pack-leader-melee", regular, squad, "power-fist").is_empty(), "Pack Leader equipment is not offered to regular models")
	var bad_loadout := submit(state, 1, "grey-hunters-pack-leader-melee", leader, squad, "thunder-hammer")
	check(not str(bad_loadout.get("error", "")).is_empty(), "Unsupported Pack Leader equipment is rejected")
	var pistol_result := PublicUnitCommand.submit(state, 1, find_choice(state, 1, "grey-hunters-pack-leader-pistol", leader, squad, "plasma-pistol"))
	var fist_result := PublicUnitCommand.submit(state, 1, find_choice(state, 1, "grey-hunters-pack-leader-melee", leader, squad, "power-fist"))
	check(str(pistol_result.get("error", "")).is_empty() and state.units[leader].ranged_weapons.map(func(weapon: Dictionary) -> String: return str(weapon.id)) == ["bolt-carbine", "plasma-pistol"] and str(fist_result.get("error", "")).is_empty() and state.units[leader].melee_weapons[0].id == "power-fist", "Selecting Pack Leader replacements updates only its own loadout")
	check(C.UnitAbilities.has(state, squad, "old-greymanes") and C.UnitAbilities.has(state, squad, "cunning-hunters"), "Both Grey Hunters abilities are registered on the unit")
	check(find_choice(state, 1, "old-greymanes-confirm", -1, squad, "split").is_empty(), "Old Greymanes cannot be confirmed without selecting five models")
	var selected_half: Array[int] = grey_models.slice(0, 5)
	for model: int in selected_half:
		var option := find_choice(state, 1, "grey-hunters-split-toggle", model, squad, "select")
		check(not option.is_empty(), "Each identified Grey Hunter can be chosen for Pack 2")
		var result := PublicUnitCommand.submit(state, 1, option)
		check(str(result.get("error", "")).is_empty(), "A valid Grey Hunter selection is accepted")
	check(find_choice(state, 1, "old-greymanes-confirm", -1, squad, "split").size() > 0, "The formation exposes confirmation only after five distinct models are selected")
	var finish_pending := submit(state, 1, "setup-done", -1, -1, "")
	check(not str(finish_pending.get("error", "")).is_empty(), "Declare Battle Formations cannot finish with an unconfirmed split draft")
	var before_points := int(state.training_points[1])
	var split_result := PublicUnitCommand.submit(state, 1, find_choice(state, 1, "old-greymanes-confirm", -1, squad, "split"))
	check(str(split_result.get("error", "")).is_empty(), "The explicitly confirmed Old Greymanes split is applied")
	var second_squad := int(state.units[selected_half[0]].squad)
	var first_models: Array[int] = []
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == "grey-hunters" and int(state.units[model].get("owner", -1)) == 1 and int(state.units[model].squad) == squad: first_models.append(model)
	first_models.sort()
	var second_models: Array[int] = []
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == "grey-hunters" and int(state.units[model].get("owner", -1)) == 1 and int(state.units[model].squad) == second_squad: second_models.append(model)
	check(first_models.size() == 5 and second_models.size() == 5 and C.living(state, squad).size() == 5 and C.living(state, second_squad).size() == 5, "The formation produces two equal five-model Grey Hunters units")
	check(leader in second_models and leader not in first_models and int(state.squads[squad].training_cost) + int(state.squads[second_squad].training_cost) == 180 and int(state.training_points[1]) == before_points, "Selected model identity and total roster cost are preserved by the split")
	var split_record: Dictionary = state.unit_abilities.old_greymanes_splits[str(squad)]
	check(split_record.first_models.size() == 5 and split_record.second_models.size() == 5 and split_record.first_models == first_models and split_record.second_models == second_models, "The confirmed formation records the exact model membership for both packs")
	check(C.UnitAbilities.has(state, squad, "cunning-hunters") and C.UnitAbilities.has(state, second_squad, "cunning-hunters") and find_choice(state, 1, "old-greymanes-confirm", -1, second_squad, "split").is_empty(), "Each half retains Cunning Hunters and cannot split again")
	var objective := {"name": "Test marker", "kind": "marker", "position": Vector2.ZERO, "elevation": 0.0}
	state.mission.objectives = [objective]
	for model: int in first_models: state.units[model].position = Vector2(20.0, 20.0)
	for model: int in second_models: state.units[model].position = Vector2(20.0, 20.0)
	state.units[first_models[0]].position = Vector2.ZERO
	state.phase = "fight"
	var chainsword: Dictionary = state.units[first_models[1]].melee_weapons[0].profiles.standard
	var attack := AttackPlan._datasheet_weapon(state, first_models[1], enemy_squad, chainsword, true, "chainsword", "standard", false)
	check(int(attack.strength) == 6 and int(attack.ap) == -2, "Cunning Hunters grants +1 Strength and improves AP when any model in the unit is within objective range")
	var other_pack_attack := AttackPlan._datasheet_weapon(state, second_models[1], enemy_squad, state.units[second_models[1]].melee_weapons[0].profiles.standard, true, "chainsword", "standard", false)
	check(int(other_pack_attack.strength) == 5 and int(other_pack_attack.ap) == -1, "The split pack outside objective range does not receive Cunning Hunters")
	state.units[first_models[0]].position = Vector2(5.0, 0.0)
	var distant_attack := AttackPlan._datasheet_weapon(state, first_models[1], enemy_squad, chainsword, true, "chainsword", "standard", false)
	check(int(distant_attack.strength) == 5 and int(distant_attack.ap) == -1, "Cunning Hunters ends when every model is outside objective range")
	state.units[first_models[0]].position = Vector2.ZERO
	state.phase = "shooting"
	var outside_phase := AttackPlan._datasheet_weapon(state, first_models[1], enemy_squad, chainsword, true, "chainsword", "standard", false)
	check(int(outside_phase.strength) == 5 and int(outside_phase.ap) == -1, "Cunning Hunters is restricted to the Fight phase")
	print("Grey Hunters checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
