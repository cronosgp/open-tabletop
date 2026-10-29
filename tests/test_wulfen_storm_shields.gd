extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const Morale = preload("res://scripts/edition_11/morale.gd")
const Transport = preload("res://scripts/edition_11/transport_rules.gd")
const HammerBlow = preload("res://scripts/edition_11/wulfen_storm_shields.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const UNIT := "wulfen-with-storm-shields"

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(models: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": models, "copies": 1}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [entry(5), entry(10), entry(5)] if owner == 1 else [entry(5)]
	return result

func fresh() -> Dictionary:
	return F.P.initial_state({
		"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true,
		"core_stratagems": true, "manual_allocation": false,
		"marine_chapters": {1: "SPACE WOLVES", 2: "SPACE WOLVES"}
	}, selections())

func models_for(state: Dictionary, owner: int, squad: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and int(state.units[model].get("squad", -1)) == squad and C.UnitAbilities.identity(state.units[model]) == UNIT: result.append(model)
	result.sort()
	return result

func squads_for(state: Dictionary, owner: int) -> Array[int]:
	var result: Array[int] = []
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == UNIT:
				result.append(squad)
				break
	result.sort()
	return result

func find_loadout_choice(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == "wulfen-loadout" and int(option.get("model", -1)) == model and int(option.get("target", -1)) == squad and str(option.get("value", "")) == value: return option
	return {}

func find_hammer_choice(state: Dictionary, player: int, action: String, target: int = -1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and (target < 0 or int(option.get("target", -1)) == target): return option
	return {}

func choose_loadout(state: Dictionary, player: int, model: int, squad: int, value: String) -> Dictionary:
	return PublicUnitCommand.submit(state, player, find_loadout_choice(state, player, model, squad, value))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile(UNIT)
	check(profile.source_book_id == "000000036" and profile.source_datasheet_id == "000004132" and profile.source_snapshot_id == "20261029T003124Z" and profile.source_slice_manifest_sha256 == "6cc0d72accb62915e6233a42d92a1f8d0da90566a60818597e569b3c562d2ae5", "The profile records the exact Space Wolves sheet and verified local slice")
	check(profile.points_by_models == {5: 125, 10: 250} and profile.third_plus_points_by_models == {5: 155, 10: 280}, "Both unit sizes and third-plus copy prices match the local export")
	check(profile.stats == {"movement_inches": 9, "toughness": 6, "save_target": 4, "wounds": 2, "leadership_target": 7, "objective_control": 0, "invulnerable_target": 4} and profile.base_size_source_mm == 40, "Characteristics, the Storm Shield invulnerable save and the 40 mm base match the sheet")
	var melee: Array = profile.melee
	check(melee.size() == 1 and melee[0].id == "thunder-hammer" and melee[0].physical_weapon_id == "thunder-hammer" and melee[0].profiles.standard.attacks == 2 and melee[0].profiles.hunter.attacks == 3 and melee[0].profiles.hunter.strength == 10, "The Thunder Hammer keeps both source profiles under one physical weapon")
	var default_weapons := Profiles.wulfen_storm_shields_weapons()
	var totem_weapons := Profiles.wulfen_storm_shields_weapons("death-totem")
	check(default_weapons.ranged.size() == 1 and default_weapons.ranged[0].id == "stormfrag-auto-launcher" and default_weapons.melee.size() == 1 and default_weapons.melee[0].id == "thunder-hammer", "The default loadout contains the Stormfrag Auto-launcher and Thunder Hammer")
	check(totem_weapons.ranged.is_empty() and totem_weapons.melee.size() == 1 and Profiles.wulfen_storm_shields_weapons("invalid").is_empty(), "Death Totem replaces the launcher without changing the hammer")
	check("hammer-blow" in C.UnitAbilities.RULES.get(UNIT, []) and "death-totem" in C.UnitAbilities.RULES.get(UNIT, []) and "curse-of-the-wulfen" in C.UnitAbilities.RULES.get(UNIT, []) and "bestial-forms" in C.UnitAbilities.RULES.get(UNIT, []) and "savage-frenzy" not in C.UnitAbilities.RULES.get(UNIT, []), "The profile has its exported abilities and does not inherit Savage Frenzy")
	check(Catalog.Current.profile(UNIT).source_datasheet_id == "000004132", "The consolidated current catalog resolves the exact shield variant")

	var state := fresh()
	check(not state.has("error"), "A Space Wolves current-catalog training match builds")
	if state.has("error"):
		print(str(state.get("error", "")))
		quit(1)
		return
	var owner_squads := squads_for(state, 1)
	var enemy_squads := squads_for(state, 2)
	check(owner_squads.size() == 3 and enemy_squads.size() == 1, "Three priced Wulfen with Storm Shields units and one opposing unit enter construction")
	if owner_squads.size() < 3 or enemy_squads.is_empty():
		quit(1)
		return
	var squad := owner_squads[0]
	var enemy_squad := enemy_squads[0]
	var models := models_for(state, 1, squad)
	var enemy_models := models_for(state, 2, enemy_squad)
	check(models.size() == 5 and enemy_models.size() == 5 and state.squads[squad].stats.invulnerable_target == 4 and models.all(func(model: int) -> bool: return state.units[model].ranged_weapons[0].id == "stormfrag-auto-launcher" and state.units[model].melee_weapons[0].id == "thunder-hammer"), "Prepared models retain their Storm Shield and source-listed default weapons")
	for item: int in owner_squads:
		var expected := int(profile.points_by_models[int(state.squads[item].starting_strength)])
		check(int(state.squads[item].get("training_cost", -1)) == expected, "The roster applies first-two-copy points for both unit sizes")
	check(Transport.capacity_cost(state, squad, {}) == 10, "Bestial Forms counts each living Wulfen with Storm Shield as two transport spaces")

	var starting_cost := int(state.squads[squad].training_cost)
	var totem_change := choose_loadout(state, 1, models[0], squad, "death-totem")
	check(str(totem_change.get("error", "")).is_empty() and state.units[models[0]].ranged_weapons.is_empty() and bool(state.units[models[0]].get("wulfen_death_totem", false)) and int(state.squads[squad].training_cost) == starting_cost, "The public preparation choice replaces one launcher with Death Totem at no points cost")
	check(C.UnitAbilities.wulfen_death_totem_active(state, squad) and C.UnitAbilities.sources(state, squad, "death-totem") == [models[0]], "The variant's Death Totem reroll follows equipped wargear")
	var wrong_owner_choice := find_loadout_choice(state, 2, enemy_models[0], enemy_squad, "death-totem")
	var before_wrong_owner := var_to_bytes(state)
	var wrong_owner := PublicUnitCommand.submit(state, 1, wrong_owner_choice)
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The owner cannot change the opponent's preparation loadout")
	var restore := choose_loadout(state, 1, models[0], squad, "stormfrag-auto-launcher")
	check(str(restore.get("error", "")).is_empty() and state.units[models[0]].ranged_weapons[0].id == "stormfrag-auto-launcher" and not bool(state.units[models[0]].get("wulfen_death_totem", true)) and not C.UnitAbilities.wulfen_death_totem_active(state, squad), "Restoring the launcher removes the unit's last Death Totem reroll source")

	var attack_state: Dictionary = state.duplicate(true)
	attack_state.phase = "fight"
	attack_state.active = 1
	attack_state.unit_abilities.setup_players = []
	attack_state.units[models[0]].position = Vector2.ZERO
	attack_state.units[enemy_models[0]].position = Vector2(1.0, 0.0)
	var hunter_plan := C.AttackPlan.prepare(attack_state, squad, true, [{"model": models[0], "target": enemy_squad, "amount": 3, "weapon": "thunder-hammer", "profile": "hunter"}], true)
	var hunter_batch_ok: bool = str(hunter_plan.get("error", "")).is_empty() and not hunter_plan.get("batches", []).is_empty() and hunter_plan.batches[0].weapon.strength == 10 and hunter_plan.batches[0].weapon.attacks == 3
	check(hunter_batch_ok, "The alternate Hunter profile is usable through the ordinary melee AttackPlan")
	var totem_state: Dictionary = state.duplicate(true)
	totem_state.phase = "fight"
	totem_state.active = 1
	totem_state.unit_abilities.setup_players = []
	totem_state.units[models[0]].wulfen_loadout = "death-totem"
	totem_state.units[models[0]].wulfen_death_totem = true
	totem_state.units[models[0]].ranged_weapons = []
	totem_state.units[models[0]].position = Vector2.ZERO
	totem_state.units[enemy_models[0]].position = Vector2(1.0, 0.0)
	var totem_plan := C.AttackPlan.prepare(totem_state, squad, true, [{"model": models[0], "target": enemy_squad, "amount": 2, "weapon": "thunder-hammer", "profile": "standard"}], true)
	check(str(totem_plan.get("error", "")).is_empty() and totem_plan.batches[0].context.get("hit_reroll", "none") == "ones", "Death Totem Hit rerolls enter the variant's real melee AttackPlan")

	for model: int in models: state.units[model].position = Vector2.ZERO
	state.units[models[1]].position = Vector2(5.0, 0.0)
	state.units[models[1]].keywords = ["ADEPTUS ASTARTES", "SPACE WOLVES", "CHARACTER", "IMPERIUM"]
	check(Morale.objective_control(state, models[0]) == 1, "Curse of the Wulfen adds one Objective Control within six inches of a Space Wolves Character")
	state.squads[squad].battle_shocked = true
	check(Morale.objective_control(state, models[0]) == 0, "Battle-shock still prevents Objective Control")
	state.squads[squad].battle_shocked = false
	state.units[models[1]].keywords = ["ADEPTUS ASTARTES", "IMPERIUM", "INFANTRY", "SPACE WOLVES", "WULFEN"]

	var resolved := {"pools": [{"target_squad": enemy_squad, "hits": 1}]}
	state.phase = "fight"
	state.turn = 1
	state.active = 1
	state.squads[squad].fought = true
	for model: int in enemy_models: state.units[model].keywords.append("MONSTER")
	check(HammerBlow.hit_targets(state, squad, {"pools": [{"target_squad": enemy_squad, "hits": 0}]}).is_empty(), "Hammer Blow ignores attacks that scored no hits")
	check(HammerBlow.hit_targets(state, squad, {"pools": [{"target_squad": enemy_squad, "hits": 1}]}).has(enemy_squad), "Hammer Blow recognizes a hit Monster unit")
	for model: int in enemy_models: state.units[model].keywords.erase("MONSTER")
	check(HammerBlow.hit_targets(state, squad, resolved).is_empty(), "Hammer Blow does not offer non-Monster, non-Vehicle targets")
	for model: int in enemy_models: state.units[model].keywords.append("MONSTER")
	state.unit_abilities.window = {"kind": "counter", "owners": [2], "squad": enemy_squad}
	check(HammerBlow.offer_after_fight(state, squad, resolved, true) and state.unit_abilities.window.kind == HammerBlow.WINDOW and state.unit_abilities.window.resume_window.kind == "counter", "The post-fight choice suspends and preserves an existing Counteroffensive window")
	var suppression_choice := find_hammer_choice(state, 1, HammerBlow.USE, enemy_squad)
	check(not suppression_choice.is_empty(), "The routed public window offers Hammer Blow for the unit actually hit")
	var before_wrong_owner_hammer := var_to_bytes(state)
	var wrong_owner_hammer := HammerBlow.apply(state, 2, suppression_choice)
	check(not str(wrong_owner_hammer.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner_hammer, "Only the Wulfen owner can resolve Hammer Blow")
	var used_hammer := PublicUnitCommand.submit(state, 1, suppression_choice)
	check(str(used_hammer.get("error", "")).is_empty() and state.unit_abilities.window.kind == "counter" and state.detachment_stratagems.suppressed[enemy_squad].source == "wulfen-hammer-blow", "Hammer Blow suppresses the hit unit and resumes the nested fight window")
	check(C.DetachmentStratagems.suppression_hit_modifier(state, enemy_squad) == -1, "The suppressed Monster receives -1 to Hit in its attacks")
	state.turn = 2
	state.active = 2
	state.unit_abilities.window = {}
	state.units[models[0]].position = Vector2.ZERO
	state.units[enemy_models[0]].position = Vector2(1.0, 0.0)
	var suppressed_attack := C.AttackPlan.prepare(state, enemy_squad, true, [{"model": enemy_models[0], "target": squad, "amount": 2, "weapon": "thunder-hammer", "profile": "standard"}], true)
	check(str(suppressed_attack.get("error", "")).is_empty() and suppressed_attack.batches[0].context.get("hit_modifier", 0) == -1, "The real melee AttackPlan applies Hammer Blow's -1 Hit modifier")
	check(C.DetachmentStratagems.suppression_hit_modifier(state, enemy_squad) == -1, "Hammer Blow remains active through the opposing turn")
	state.turn = 3
	check(C.DetachmentStratagems.suppression_hit_modifier(state, enemy_squad) == 0, "Hammer Blow ends at the start of the Wulfen owner's next turn")

	var pass_state: Dictionary = state.duplicate(true)
	pass_state.turn = 1
	pass_state.squads[squad].fought = true
	pass_state.unit_abilities.window = {"kind": "counter", "owners": [2], "squad": enemy_squad}
	pass_state.detachment_stratagems.get("suppressed", {}).erase(enemy_squad)
	check(HammerBlow.offer_after_fight(pass_state, squad, resolved, true), "Hammer Blow can reopen for an unspent qualifying fight")
	var pass_choice := find_hammer_choice(pass_state, 1, HammerBlow.PASS, squad)
	var pass_result := C.UnitActions.apply(pass_state, 1, pass_choice, Vector2.ZERO, Callable())
	check(str(pass_result.get("error", "")).is_empty() and pass_state.unit_abilities.window.kind == "counter" and not pass_state.detachment_stratagems.get("suppressed", {}).has(enemy_squad), "Passing Hammer Blow resumes the previous fight window without applying suppression")

	if failures == 0:
		print("Wulfen with Storm Shields checks passed")
		quit(0)
	else:
		print("Wulfen with Storm Shields checks: %d failures" % failures)
		quit(1)
