extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const P = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Catalog = preload("res://scripts/implemented_army_catalog.gd")
const SOURCE_ID := "vindicator"
const UNIT_ID := "40kdc:11e:adeptus-astartes:vindicator"
var failures := 0
var deadly_demise_rolls: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(identity: String, models: int = 1, copies: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": models, "copies": copies}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner: int in [1, 2]:
		result[owner].category = "custom"
		result[owner].points_limit = 2000
		result[owner].entries = [entry("intercessor-squad", 5)]
	result[1].entries = [entry(SOURCE_ID), entry("intercessor-squad", 5)]
	result[2].entries = [entry("intercessor-squad", 5), entry("intercessor-squad", 5)]
	return result

func battle() -> Dictionary:
	return F.P.initial_state({"checked_rosters": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true}, selections())

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].squad) if model >= 0 else -1

func squads_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if int(state.units[model].owner) != owner or C.UnitAbilities.identity(state.units[model]) != identity: continue
		var squad := int(state.units[model].squad)
		if squad not in result: result.append(squad)
	result.sort()
	return result

func choice_for(state: Dictionary, action: String, model: int, value: String = "") -> Dictionary:
	for choice: Dictionary in C.UnitActions.choices(state, 1):
		if str(choice.get("action", "")) == action and int(choice.get("model", -1)) == model and (value.is_empty() or str(choice.get("value", "")) == value): return choice
	return {}

func attack_plan(state: Dictionary, model: int, squad: int, target: int, weapon: String, profile: String = "standard") -> Dictionary:
	return C.AttackPlan.prepare(state, squad, false, [{"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile}], true)

func set_engaged_positions(state: Dictionary, model: int, target_squad: int, friendly_squad: int = -1) -> void:
	state.units[model].position = Vector2.ZERO
	var enemies: Array[int] = C.living(state, target_squad)
	for index: int in enemies.size(): state.units[enemies[index]].position = Vector2(2.2 + index * 4.0, 0.0)
	if friendly_squad >= 0:
		var friendlies: Array[int] = C.living(state, friendly_squad)
		for index: int in friendlies.size(): state.units[friendlies[index]].position = Vector2(30.0 + index * 4.0, 0.0)

func run() -> void:
	var profile := P.profile(SOURCE_ID)
	check(profile.get("source_book_id", "") == "000000356" and profile.get("source_datasheet_id", "") == "000001188", "Profile uses the current 11e Legends Vindicator source identity")
	check(profile.get("source_verified_against_snapshot_id", "") == P.VERIFIED_EXPORT_SNAPSHOT_ID and profile.get("source_verified_against_manifest_sha256", "") == P.VERIFIED_EXPORT_MANIFEST_SHA256 and profile.get("source_verified_against_slice_manifest_sha256", "") == "d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c", "Profile retains the verified export and exact Legends slice provenance")
	check(profile.get("source_scope", "") == "Warhammer Legends" and profile.get("source_url", "").ends_with("/Vindicator"), "The current sheet and Warhammer Legends scope are explicit")
	check(profile.get("points_by_models", {}) == {1: 185} and profile.get("third_plus_points_by_models", {}) == {1: 200} and profile.get("models", 0) == 1 and profile.get("damaged_threshold", 0) == 4, "One-model composition, first/second and third-plus prices, and Damaged 4 threshold match the source")
	check(profile.get("stats", {}) == {"movement_inches": 9, "toughness": 11, "save_target": 2, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0}, "All model characteristics match the current source")
	check(profile.get("base_size_source", "") == "Use model" and profile.get("base_geometry", "") == "circular-model-footprint-proxy" and str(profile.get("geometry_scope", "")).contains("60 mm") and str(profile.get("geometry_scope", "")).contains("not certified"), "Unspecified vehicle footprint is disclosed as a 60 mm simulation proxy")
	check(profile.get("keywords", []) == ["ADEPTUS ASTARTES", "VEHICLE", "FRAME", "IMPERIUM", "SMOKE"] and profile.get("default_loadout_by_role", {}).get("Vindicator", {}) == {"Armoured Tracks": 1, "Demolisher Cannon": 1}, "All source keywords and default loadout are retained")
	check(profile.get("special_rules", []) == ["Combat Doctrines", "Deadly Demise D3", "Damaged 4", "Siege Shield"] and "siege-shield" in C.UnitAbilities.RULES.get(SOURCE_ID, []), "Army and datasheet abilities are registered")
	check(Army.SPECS.get(SOURCE_ID, {}).get("source_scope", "") == "Warhammer Legends" and Army.SPECS[SOURCE_ID].get("max_supported_copies", 0) == 3, "Vindicator is source-labelled and its local copy ceiling is explicit")
	check(Capabilities.supported("siege-shield"), "Siege Shield is registered in capability metadata")

	var cannon: Dictionary = profile.ranged[0]
	check(cannon.id == "demolisher-cannon" and cannon.profiles.standard == {"name": "Demolisher Cannon", "range_inches": 24.0, "attacks": "D3+3", "skill": 3, "strength": 14, "ap": -3, "damage": 4, "keywords": {"blast": 1}}, "Standard Demolisher Cannon profile matches the source")
	check(cannon.profiles["siege-shield-close-quarters"] == {"name": "Demolisher Cannon - Siege Shield (Close-quarters, No Blast)", "range_inches": 24.0, "attacks": "D3+3", "skill": 3, "strength": 14, "ap": -3, "damage": 4, "keywords": {}}, "The optional Siege Shield fire mode keeps the cannon data and removes only BLAST")
	check(profile.melee[0].profiles.standard == {"name": "Armoured Tracks", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}, "Armoured Tracks melee profile matches the source")
	var expected_optional := {
		"hunter-killer-missile": {"name": "Hunter-killer Missile", "range_inches": 48.0, "attacks": 1, "skill": 2, "strength": 14, "ap": -3, "damage": "D3+3", "keywords": {"one-shot": true}},
		"storm-bolter": {"name": "Storm Bolter", "range_inches": 24.0, "attacks": 2, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 2}}
	}
	for weapon_id: String in expected_optional:
		var weapon := P.additional_weapon(SOURCE_ID, "ranged", weapon_id)
		check(not weapon.is_empty() and weapon.profiles.standard == expected_optional[weapon_id], "%s matches its current source profile and traits" % weapon_id)
	var default_loadout := P.vindicator_weapons()
	check(default_loadout.ranged.size() == 1 and default_loadout.melee.size() == 1 and default_loadout.ranged[0].id == "demolisher-cannon", "Default Vindicator carries only its printed default cannon and tracks")
	var fully_equipped := P.vindicator_weapons(true, true)
	check(fully_equipped.ranged.size() == 3 and fully_equipped.ranged[1].id == "hunter-killer-missile" and fully_equipped.ranged[2].id == "storm-bolter", "Both source-listed optional weapons can be equipped together")

	var provider = Catalog.new()
	check(provider.select_edition("11e").is_empty(), "Vindicator is loaded from the consolidated local catalog")
	var unit := provider.lookup(UNIT_ID)
	check(unit.get("source_scope", "") == "Warhammer Legends" and unit.get("options", []) == [{"models": 1, "cost": 185, "third_plus_cost": 200}] and unit.get("scope", "").contains("competitive events require organiser approval") and unit.get("scope", "").contains("60 mm circle proxy"), "Construction lists the exact model price tiers, Legends condition and geometry boundary")
	var incursion_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	var strike_force_three := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 3}]})
	var strike_force_four := Army.admit({"schema_version": 2, "faction": "Space Marines", "category": "strike_force", "points_limit": 2000, "entries": [{"definition_id": UNIT_ID, "models": 1, "copies": 4}]})
	check(not str(incursion_three.get("error", "")).is_empty() and strike_force_three.get("error", "").is_empty() and strike_force_three.get("total", -1) == 570 and not str(strike_force_four.get("error", "")).is_empty(), "Source prices first two copies at 185, third at 200, and local Incursion/Strike Force copy gates reject excess copies")

	var state := battle()
	if state.has("error"):
		check(false, "Admitted Vindicator builds into a battle: " + str(state.error))
		provider.free()
		quit(1)
		return
	var model := model_for(state, 1, SOURCE_ID)
	var squad := squad_for(state, 1, SOURCE_ID)
	var targets := squads_for(state, 2, "intercessor-squad")
	var target := targets[0] if not targets.is_empty() else -1
	var unengaged_target := targets[1] if targets.size() > 1 else -1
	var friendly := squad_for(state, 1, "intercessor-squad")
	check(model >= 0 and squad >= 0 and target >= 0 and unengaged_target >= 0 and friendly >= 0 and C.UnitAbilities.has(state, squad, "siege-shield"), "Battle roster creates Vindicator with Siege Shield and engaged/unengaged enemy targets")
	if model >= 0 and target >= 0 and unengaged_target >= 0 and friendly >= 0:
		var missile_choice := choice_for(state, "vindicator-loadout", model, "on")
		check(not missile_choice.is_empty() and int(missile_choice.get("target", -1)) == 0, "Preparation exposes the optional Hunter-killer Missile")
		var added_missile := C.UnitActions.apply(state, 1, missile_choice, Vector2.ZERO, Callable()) if not missile_choice.is_empty() else {"error": "No source-listed missile choice was offered."}
		check(added_missile.get("error", "").is_empty() and state.units[model].get("vindicator_hunter_killer_missile", false), "Preparation adds the optional One Shot missile")
		var storm_choice := choice_for(state, "vindicator-loadout", model, "on")
		if not storm_choice.is_empty() and int(storm_choice.target) != 1: storm_choice = {}
		for choice: Dictionary in C.UnitActions.choices(state, 1):
			if choice.get("action", "") == "vindicator-loadout" and int(choice.get("model", -1)) == model and int(choice.get("target", -1)) == 1 and choice.get("value", "") == "on": storm_choice = choice
		var added_bolter := C.UnitActions.apply(state, 1, storm_choice, Vector2.ZERO, Callable()) if not storm_choice.is_empty() else {"error": "No source-listed Storm Bolter choice was offered."}
		check(added_bolter.get("error", "").is_empty() and state.units[model].get("vindicator_storm_bolter", false), "Preparation adds the optional Storm Bolter independently")
		check(Equipment.select(state, model, false, "hunter-killer-missile", "standard").stats.keywords.get("one-shot", false) and Equipment.select(state, model, false, "storm-bolter", "standard").stats.keywords.get("rapid-fire", 0) == 2, "Configured optional weapons retain ONE SHOT and Rapid Fire 2")
		state.phase = "shooting"
		state.active = 1
		state.unit_abilities.window = {}
		set_engaged_positions(state, model, target, friendly)
		var unengaged_models: Array[int] = C.living(state, unengaged_target)
		for index: int in unengaged_models.size(): state.units[unengaged_models[index]].position = Vector2(15.0 + index * 2.0, 0.0)
		state.units[model].wounds = 4
		state.unit_abilities.weapon_skill_characteristic_modifiers.models[model] = {"BS": -1}
		var siege_attack := attack_plan(state, model, squad, target, "demolisher-cannon", "siege-shield-close-quarters")
		check(siege_attack.get("error", "").is_empty() and siege_attack.batches.size() == 1 and not siege_attack.batches[0].weapon.keywords.has("blast") and not siege_attack.batches[0].weapon.keywords.has("close-quarters") and siege_attack.batches[0].context.hit_modifier == 0 and siege_attack.batches[0].weapon.skill == 3, "Siege Shield fires the exact no-BLAST profile at an engaged enemy and ignores Hit/BS modifiers, including Damaged 4")
		var siege_attack_unengaged := attack_plan(state, model, squad, unengaged_target, "demolisher-cannon", "siege-shield-close-quarters")
		check(siege_attack_unengaged.get("error", "").is_empty(), "The no-BLAST profile can also target an unengaged enemy")
		var normal_cannon := attack_plan(state, model, squad, target, "demolisher-cannon", "standard")
		var normal_cannon_unengaged := attack_plan(state, model, squad, unengaged_target, "demolisher-cannon", "standard")
		check(not str(normal_cannon.get("error", "")).is_empty() and normal_cannon_unengaged.get("error", "").is_empty(), "The BLAST cannon cannot target an engaged enemy but can target an unengaged enemy while its Vehicle fires close-quarters")
		var other_friendly := C.living(state, friendly)[0]
		state.units[other_friendly].position = Vector2(3.0, 1.2)
		var blocked_no_blast := attack_plan(state, model, squad, target, "demolisher-cannon", "siege-shield-close-quarters")
		var allowed_no_blast_unengaged := attack_plan(state, model, squad, unengaged_target, "demolisher-cannon", "siege-shield-close-quarters")
		var allowed_bolter := attack_plan(state, model, squad, target, "storm-bolter", "standard")
		check(not str(blocked_no_blast.get("error", "")).is_empty() and allowed_no_blast_unengaged.get("error", "").is_empty() and allowed_bolter.get("error", "").is_empty(), "The no-BLAST profile rejects enemies engaged with another friendly unit but allows an unengaged target; non-BLAST close-quarters fire remains legal")
		state.units[other_friendly].position = Vector2(30.0, 0.0)
		state.phase = "movement"
		var wrong_phase := attack_plan(state, model, squad, target, "demolisher-cannon", "siege-shield-close-quarters")
		state.phase = "shooting"
		state.active = 2
		var out_of_phase := attack_plan(state, model, squad, target, "demolisher-cannon", "siege-shield-close-quarters")
		check(not str(wrong_phase.get("error", "")).is_empty() and not str(out_of_phase.get("error", "")).is_empty(), "The no-BLAST Siege Shield mode is limited to the Vindicator owner's Shooting phase")
		state.units[model].one_shot_weapons_used = {"hunter-killer-missile": true}
		var spent_missile := attack_plan(state, model, squad, target, "hunter-killer-missile")
		check(not str(spent_missile.get("error", "")).is_empty(), "A spent Hunter-killer Missile cannot be declared again")
		check(C.UnitAbilities.deadly_demise_value(state, model) == "D3" and C.UnitAbilities.damaged_attack_penalty(state, model) == -1, "Vindicator registers Deadly Demise D3 and its 1-4 wound attack penalty")
		state.units[model].wounds = 5
		check(C.UnitAbilities.damaged_attack_penalty(state, model) == 0, "Damaged 4 does not apply at five remaining wounds")
		state.units[model].wounds = 4

		var demise := state.duplicate(true)
		for unit_model: int in demise.units:
			demise.units[unit_model].position = Vector2(-20, -20) if int(demise.units[unit_model].owner) == 1 else Vector2(20, 0)
		var affected_models: Array[int] = C.living(demise, unengaged_target)
		for index: int in affected_models.size(): demise.units[affected_models[index]].position = Vector2(5.0 + index * 2.0, 0.0)
		demise.units[model].position = Vector2.ZERO
		demise.units[model].wounds = 0
		var enemy_model := affected_models[0]
		var enemy_wounds := int(demise.units[enemy_model].wounds)
		deadly_demise_rolls = [6, 2]
		var explosion := C.DeadlyDemise.begin(demise, [model], Callable(self, "roll_vindicator_demise"))
		var packet := C.DeadlyDemise.choices(demise, 2)
		var allocated := C.DeadlyDemise.allocate(demise, 2, packet[0], Callable()) if not packet.is_empty() else {"error": "No Vindicator Deadly Demise allocation choice was offered."}
		check(explosion.get("error", "").is_empty() and not explosion.get("complete", true) and allocated.get("error", "").is_empty() and int(demise.units[enemy_model].wounds) == enemy_wounds - 1 and demise.get("last_deadly_demise", {}).get("events", [])[0].get("expression", "") == "D3" and demise.last_deadly_demise.events[0].targets[0].mortal_wounds == 1, "A destroyed Vindicator triggers its D3 through the shared allocation resolver")

	provider.free()
	if failures > 0: quit(1)
	else: quit(0)

func roll_vindicator_demise() -> int:
	return deadly_demise_rolls.pop_front() if not deadly_demise_rolls.is_empty() else 6
