extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const ObjectiveRules = preload("res://scripts/edition_11/objectives.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const IMMORTAL_ID := "40kdc:11e:necrons:immortals"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].entries = [
		{"definition_id": IMMORTAL_ID, "models": 5, "copies": 1},
		{"definition_id": IMMORTAL_ID, "models": 10, "copies": 1}]
	return result

func immortal_models(state: Dictionary, strength: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != 2 or C.UnitAbilities.identity(unit) != "immortals": continue
		if int(state.squads.get(int(unit.get("squad", -1)), {}).get("starting_strength", -1)) == strength: result.append(model)
	result.sort()
	return result

func choices_for(state: Dictionary, player: int, action: String, value: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		result.append(option)
	return result

func submit(state: Dictionary, model: int, value: String) -> Dictionary:
	for option: Dictionary in choices_for(state, 2, "necron-immortal-tesla-carbine", value):
		if int(option.get("model", -1)) == model: return PublicUnitCommand.submit(state, 2, option)
	return {"error": "No current public Tesla carbine choice for Immortal %d." % model}

func weapon_id(state: Dictionary, model: int) -> String:
	var weapons: Array = state.units[model].get("ranged_weapons", [])
	return str(weapons[0].get("id", "")) if weapons.size() == 1 else ""

func weapon_name(state: Dictionary, model: int) -> String:
	var weapons: Array = state.units[model].get("ranged_weapons", [])
	return str(weapons[0].get("profiles", {}).get("standard", {}).get("name", "")) if weapons.size() == 1 else ""

func objective_probe_position(state: Dictionary, model: Dictionary, should_be_in_range: bool) -> Vector2:
	for x in range(-20, 21):
		for y in range(-20, 21):
			var probe := model.duplicate(true)
			probe.position = Vector2(x, y)
			var in_range := false
			for objective: Dictionary in state.mission.objectives:
				if ObjectiveRules.in_range(probe, objective):
					in_range = true
					break
			if in_range == should_be_in_range: return probe.position
	return Vector2(10000, 10000)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("immortals")
	check(profile.get("source_datasheet_id", "") == "000000535" and profile.get("source_snapshot_id", "") == "20261031T053336Z" and profile.get("source_scope", "") == "Necrons App v1.2", "Immortals use the verified local App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {5: 65, 10: 130} and Army.construction_model_sizes("immortals", profile) == [5, 10], "Both source-priced Immortals sizes are exact")
	var gauss: Dictionary = profile.ranged[0].profiles.standard
	var tesla: Dictionary = profile.additional_weapon_profiles.ranged[0].profiles.standard
	check(gauss == {"name": "Gauss blaster", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"lethal-hits": true}}, "Gauss blaster stats match the local weapon row")
	check(tesla == {"name": "Tesla carbine", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {"assault": true, "sustained-hits": 2}}, "Tesla carbine stats and keywords match the local weapon row")
	check(profile.source_options.size() == 1 and profile.source_options[0].implemented and profile.source_options[0].maximum == "unit_size", "The local option allows any number of Immortals to replace their Gauss blaster")
	check(profile.source_ability_names == ["Reanimation Protocols", "Implacable Eradication"] and profile.supported_rule_ids == ["reanimation-protocols", "implacable-eradication"] and profile.unsupported_abilities.is_empty(), "Both local datasheet abilities are explicitly supported")
	for size: int in [5, 10]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": IMMORTAL_ID, "models": size, "copies": 1}]})
		check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == profile.points_by_models[size], "Immortals size %d admits at its local price" % size)
	var resolved := Army.resolve("Necrons", IMMORTAL_ID)
	check(str(resolved.get("error", "")).is_empty() and int(resolved.get("cost", -1)) == 65 and resolved.get("pack_hash", "") == Profiles.digest(), "The consolidated local catalog resolves the five-model profile")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": false, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Current Immortals roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	state.unit_abilities.setup_players = [1]
	if state.has("awakened_dynasty"): state.awakened_dynasty.pending = []
	C.UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		var doctrine_error := C.select_combat_doctrine(state, int(state.active), "none", int(state.revision))
		check(doctrine_error.is_empty(), "Resolve the unrelated doctrine setup before evaluating Immortals")
	check(C.UnitActions.setup_actor(state) == 2 and str(state.match_manifest.content_hash).contains(Profiles.digest()), "Necron preparation uses the current hashed local profile")
	var small := immortal_models(state, 5)
	var large := immortal_models(state, 10)
	check(small.size() == 5 and large.size() == 10, "Both local Immortals configurations materialize their exact model counts")
	var options := choices_for(state, 2, "necron-immortal-tesla-carbine", "tesla")
	check(options.size() == 15, "Every Immortal receives an independent Gauss-to-Tesla choice")
	for model: int in small + large:
		check(weapon_name(state, model).to_lower() == "gauss blaster", "Immortals begin with the source-listed Gauss blaster: " + str(state.units[model].get("ranged_weapons", [])))
	if not options.is_empty():
		var forged: Dictionary = options[0].duplicate(true)
		forged.value = "unsupported"
		var before := var_to_bytes(state)
		check(not PublicUnitCommand.error(state, 2, forged).is_empty() and before == var_to_bytes(state), "Forged weapon values are rejected without mutating the roster")
		check(not PublicUnitCommand.error(state, 1, options[0]).is_empty() and before == var_to_bytes(state), "The opposing player cannot edit Immortals equipment")
	for model: int in small:
		var equipped := submit(state, model, "tesla")
		check(str(equipped.get("error", "")).is_empty() and weapon_id(state, model) == "tesla-carbine", "Army preparation equips one Immortal's Tesla carbine independently: %d" % model)
		var selected := Equipment.select(state, model, false, "tesla-carbine", "standard")
		check(str(selected.get("error", "")).is_empty() and selected.stats == tesla, "The Tesla carbine resolves through the shared equipment inventory")
	check(choices_for(state, 2, "necron-immortal-tesla-carbine", "tesla").filter(func(option: Dictionary) -> bool: return int(option.get("target", -1)) == int(state.units[small[0]].squad)).is_empty(), "The five-model squad can replace every blaster; no artificial unit cap is applied")
	check(choices_for(state, 2, "necron-immortal-tesla-carbine", "gauss").size() == 5, "Each equipped model can restore its Gauss blaster during preparation")
	for model: int in small:
		check(str(submit(state, model, "gauss").get("error", "")).is_empty() and weapon_name(state, model).to_lower() == "gauss blaster", "Immortal %d can restore its default weapon" % model)
	var large_model: int = large[0] if not large.is_empty() else -1
	if large_model >= 0:
		var ten_model_choice := submit(state, large_model, "tesla")
		check(str(ten_model_choice.get("error", "")).is_empty() and weapon_name(state, large_model).to_lower() == "tesla carbine" and weapon_name(state, large[1]).to_lower() == "gauss blaster", "The ten-model unit supports the same individual replacement: " + str(ten_model_choice.get("error", "")) + " / " + str(state.units[large_model].get("ranged_weapons", [])))
		check(str(submit(state, large_model, "gauss").get("error", "")).is_empty(), "The ten-model Immortal can restore its default weapon")

	var small_squad := int(state.units[small[0]].squad) if not small.is_empty() else -1
	var target_model := -1
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == 1 and C.UnitAbilities.identity(state.units[model]) == "intercessor-squad":
			target_model = model
			break
	var target_squad := int(state.units[target_model].squad) if target_model >= 0 else -1
	check(C.UnitAbilities.enabled(state) and C.UnitAbilities.sources(state, small_squad, "implacable-eradication").size() == 5, "Current Immortals source the local Implacable Eradication ability")
	if target_model >= 0 and not state.mission.objectives.is_empty():
		var target_probe: Dictionary = state.units[target_model]
		var outside_position := objective_probe_position(state, target_probe, false)
		for model: int in Geometry.alive(state, target_squad): state.units[model].position = outside_position
		check(C.UnitAbilities.implacable_mode(state, small_squad, target_squad) == "ones", "Implacable Eradication re-rolls wound rolls of 1 outside objective-marker range")
		var inside_position := objective_probe_position(state, target_probe, true)
		for model: int in Geometry.alive(state, target_squad): state.units[model].position = inside_position
		check(C.UnitAbilities.implacable_mode(state, small_squad, target_squad) == "failed", "An enemy in objective range selects the optional full wound re-roll path")
		state.units[small[0]].position = inside_position + Vector2(-4, 0)
		state.terrain.areas = []
		state.phase = "shooting"
		state.active = 2
		scripted_dice = [4, 4, 4, 4]
		var gauss_id := str(state.units[small[0]].ranged_weapons[0].get("id", ""))
		var ranged_attack := C.resolve_attack_plan(state, 2, small[0], [{"model": small[0], "target": target_squad, "amount": 1, "weapon": gauss_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
		var wound_choices := choices_for(state, 2, "wound-reroll")
		check(str(ranged_attack.get("error", "")).is_empty() and C.UnitActions.pending(state).get("kind", "") == "wound" and state.pending_attack.current.checkpoint.effective_wounds == [4, 4] and wound_choices.size() == 2, "The current Immortals attack path pauses with both successful Wound dice available to re-roll: attack=%s pending=%s checkpoint=%s choices=%s" % [str(ranged_attack), str(C.UnitActions.pending(state)), str(state.get("pending_attack", {}).get("current", {}).get("checkpoint", {})), str(wound_choices)])
		if not wound_choices.is_empty():
			scripted_dice = [1]
			var rerolled_success := PublicUnitCommand.submit(state, 2, wound_choices[0], Vector2.ZERO, Callable(self, "next_die"))
			var rerolled_index := int(wound_choices[0].get("target", -1))
			check(str(rerolled_success.get("error", "")).is_empty() and int(state.pending_attack.current.checkpoint.effective_wounds[rerolled_index]) == 1, "Implacable Eradication can re-roll a successful wound die instead of only failed rolls")
	else:
		check(false, "Current Immortals test receives the training battlefield objective markers")
	var legacy_state := F.fresh()
	if not legacy_state.has("error"):
		legacy_state.unit_abilities.setup_players = [1]
		if legacy_state.has("awakened_dynasty"): legacy_state.awakened_dynasty.pending = []
		C.UnitActions.reconcile(legacy_state)
		if C.Doctrines.needs_choice(legacy_state): C.select_combat_doctrine(legacy_state, int(legacy_state.active), "none", int(legacy_state.revision))
		check(choices_for(legacy_state, 2, "necron-immortal-tesla-carbine").is_empty(), "Historical starter-backed Immortals do not receive the current Tesla replacement")
	if failures == 0: print("Necron Immortals local checks: passed")
	else: print("Necron Immortals local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
