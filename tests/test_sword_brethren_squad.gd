extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const SwordBrethren = preload("res://scripts/edition_11/sword_brethren.gd")
const Links = preload("res://scripts/edition_11/marine_leader_links.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const C = Prepared.Combat
const FIST := "fist-of-the-god-emperor"
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(identity: String, models: int) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}]}

func fresh_state(sword_models: int = 4) -> Dictionary:
	var templar_roster := army("sword-brethren-squad", sword_models)
	templar_roster.entries.append({"definition_id": "40kdc:11e:adeptus-astartes:chaplain-grimaldus", "models": 4, "copies": 1})
	return Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "combat_doctrines": true,
		"unit_abilities": true, "marine_detachments": {1: FIST, 2: "gladius"},
		"marine_chapters": {1: "BLACK TEMPLARS", 2: "ULTRAMARINES"}},
		{1: templar_roster, 2: army("intercessor-squad", 5)})

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.get("squads", {}):
		if int(state.squads[squad].get("owner", -1)) != owner: continue
		for model: int in C.living(state, squad):
			if C.UnitAbilities.identity(state.units[model]) == identity: return squad
	return -1

func model_for_index(state: Dictionary, squad: int, index: int) -> int:
	for model: int in C.living(state, squad):
		if int(state.units[model].get("sword_brethren_model", -1)) == index: return model
	return -1

func choice(state: Dictionary, player: int, action: String, target: int, model: int = -1, value: String = "") -> Dictionary:
	for candidate: Dictionary in C.UnitActions.choices(state, player):
		if str(candidate.get("action", "")) == action and int(candidate.get("target", -1)) == target and int(candidate.get("model", -1)) == model and str(candidate.get("value", "")) == value:
			return candidate
	return {}

func source_weapon(profile: Dictionary, category: String, weapon_id: String, profile_id: String = "standard") -> Dictionary:
	for weapon: Dictionary in profile.get(category, []) + profile.get("additional_weapon_profiles", {}).get(category, []):
		if str(weapon.get("id", "")) == weapon_id: return weapon.get("profiles", {}).get(profile_id, {})
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("sword-brethren-squad")
	check(profile.get("source_snapshot_id", "") == "20261021T130623Z" and profile.get("source_datasheet_id", "") == "000002798", "Sword Brethren points to the verified Black Templars datasheet snapshot")
	check(profile.get("points_by_models", {}) == {4: 115, 5: 140, 9: 250, 10: 275} and profile.get("third_plus_points_by_models", {}) == {4: 135, 5: 160, 9: 270, 10: 295}, "Only the four locally priced sizes and both source cost tiers are admitted")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Sword Brethren characteristics match the local source")
	check(source_weapon(profile, "ranged", "heavy-bolt-pistol") == {"name": "Heavy Bolt Pistol", "range_inches": 18.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}}, "Heavy Bolt Pistol profile matches the local source")
	check(source_weapon(profile, "ranged", "hand-flamer") == {"name": "Hand Flamer", "range_inches": 9.0, "attacks": 3, "skill": 0, "strength": 4, "ap": 0, "damage": 1, "keywords": {"torrent": true, "close-quarters": true}}, "Hand Flamer profile matches the local source")
	check(source_weapon(profile, "ranged", "plasma-pistol", "standard").strength == 7 and source_weapon(profile, "ranged", "plasma-pistol", "supercharge").keywords.hazardous, "Both Plasma Pistol profiles and Hazardous are represented")
	check(source_weapon(profile, "melee", "chainsword").keywords == {"sustained-hits": 1} and source_weapon(profile, "melee", "master-crafted-power-weapon").keywords == {"lethal-hits": true}, "Chainsword and master-crafted weapon traits match the source")
	check(source_weapon(profile, "melee", "thunder-hammer").skill == 3 and source_weapon(profile, "melee", "thunder-hammer").keywords == {"devastating-wounds": true} and source_weapon(profile, "melee", "twin-lightning-claws").keywords == {"twin-linked": true}, "Thunder Hammer and Twin Lightning Claws match the source")
	check(Profiles.sword_brethren_loadout_options(0, 4).size() == 10 and Profiles.sword_brethren_loadout_options(0, 6).is_empty(), "The model loadout catalog exposes all packages only at source-priced sizes")
	var four_defaults: Array[String] = ["default", "default", "default", "default"]
	var two_flames := four_defaults.duplicate()
	two_flames[0] = "hand-flamer-chainsword"
	two_flames[1] = "hand-flamer-power-weapon"
	var three_flames := two_flames.duplicate()
	three_flames[2] = "hand-flamer-thunder-hammer"
	var two_plasma := four_defaults.duplicate()
	two_plasma[0] = "plasma-pistol-chainsword"
	two_plasma[1] = "plasma-pistol-power-weapon"
	var independent_replacements := four_defaults.duplicate()
	independent_replacements[0] = "heavy-pistol-thunder-hammer"
	independent_replacements[1] = "twin-lightning-claws"
	check(Profiles.sword_brethren_loadout_limits_valid(two_flames, 4) and not Profiles.sword_brethren_loadout_limits_valid(three_flames, 4), "Hand Flamers are limited to two for each complete group of four")
	check(Profiles.sword_brethren_loadout_limits_valid(four_defaults, 4) and not Profiles.sword_brethren_loadout_limits_valid(two_plasma, 4), "Plasma Pistols are limited to one for each complete group of four")
	check(Profiles.sword_brethren_loadout_limits_valid(independent_replacements, 4), "Thunder Hammer and Twin Lightning Claws have independent source limits")
	var nine_defaults: Array[String] = ["default", "default", "default", "default", "default", "default", "default", "default", "default"]
	var nine_flames := nine_defaults.duplicate()
	for index in range(4): nine_flames[index] = "hand-flamer-chainsword"
	var five_flames := nine_flames.duplicate()
	five_flames[4] = "hand-flamer-power-weapon"
	var two_plasma_nine := nine_defaults.duplicate()
	two_plasma_nine[0] = "plasma-pistol-chainsword"
	two_plasma_nine[1] = "plasma-pistol-power-weapon"
	check(Profiles.sword_brethren_loadout_limits_valid(nine_flames, 9) and not Profiles.sword_brethren_loadout_limits_valid(five_flames, 9) and Profiles.sword_brethren_loadout_limits_valid(two_plasma_nine, 9), "Per-four replacement limits scale to two complete groups in a nine-model unit")
	var loadouts := ["default", "hand-flamer-power-weapon", "plasma-pistol-thunder-hammer", "twin-lightning-claws"]
	var packages := []
	for index in range(loadouts.size()): packages.append(Profiles.sword_brethren_model_loadout(index, 4, loadouts[index]))
	check(packages[0].ranged[0].id == "heavy-bolt-pistol" and packages[0].melee[0].id == "chainsword" and packages[1].ranged[0].id == "hand-flamer" and packages[1].melee[0].id == "master-crafted-power-weapon", "Default and mixed replacement packages resolve each model's actual weapons")
	check(packages[2].ranged[0].id == "plasma-pistol" and packages[2].melee[0].id == "thunder-hammer" and packages[3].ranged.is_empty() and packages[3].melee[0].id == "twin-lightning-claws", "Combined pistol/melee replacements and Twin Lightning Claws resolve correctly")

	var state := fresh_state()
	check(not state.has("error"), "The current catalog admits Sword Brethren with a current Space Marine opponent")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var sword_squad := find_squad(state, 1, "sword-brethren-squad")
	var enemy_squad := find_squad(state, 2, "intercessor-squad")
	check(sword_squad >= 0 and enemy_squad >= 0 and state.squads[sword_squad].training_cost == 115, "A four-model Sword Brethren unit materializes at its source cost")
	check(C.UnitAbilities.has(state, sword_squad, "combat-doctrines") and C.UnitAbilities.has(state, sword_squad, "exploit-their-cowardice"), "Army-rule and datasheet ability are registered for this unit")
	var grimaldus := find_squad(state, 1, "chaplain-grimaldus")
	var grimaldus_model := C.living(state, grimaldus)[0] if grimaldus >= 0 and not C.living(state, grimaldus).is_empty() else -1
	check(Links.CHAPTER_TARGETS.get("chaplain-grimaldus", []).has("sword-brethren-squad") and grimaldus_model >= 0 and C.UnitActions.attachment_allowed(state, grimaldus_model, sword_squad), "The admitted Sword Brethren endpoint activates Chaplain Grimaldus's source-listed Leader link")
	var sword_model := model_for_index(state, sword_squad, 0)
	var flame_choice := choice(state, 1, "sword-brethren-loadout", sword_squad, sword_model, "hand-flamer-chainsword")
	var flame_result := PublicUnitCommand.submit(state, 1, flame_choice)
	check(not flame_choice.is_empty() and str(flame_result.get("error", "")).is_empty() and state.units[sword_model].ranged_weapons[0].id == "hand-flamer", "The Army Preparation command applies a source-listed Hand Flamer replacement")
	var second_model := model_for_index(state, sword_squad, 1)
	var second_flame := choice(state, 1, "sword-brethren-loadout", sword_squad, second_model, "hand-flamer-power-weapon")
	var second_flame_result := PublicUnitCommand.submit(state, 1, second_flame)
	var third_model := model_for_index(state, sword_squad, 2)
	var third_flame := choice(state, 1, "sword-brethren-loadout", sword_squad, third_model, "hand-flamer-thunder-hammer")
	check(not second_flame.is_empty() and str(second_flame_result.get("error", "")).is_empty() and third_flame.is_empty(), "Army Preparation permits two Hand Flamers and withholds a third at four models")

	var sword_models := C.living(state, sword_squad)
	var enemy_models := C.living(state, enemy_squad)
	var sword_positions := [Vector2(0, 0), Vector2(1.8, 0), Vector2(0, 1.8), Vector2(1.8, 1.8)]
	var enemy_y := [-2.8, -1.4, 0.0, 1.4, 2.8]
	for index in range(sword_models.size()): state.units[sword_models[index]].position = sword_positions[index]
	for index in range(enemy_models.size()): state.units[enemy_models[index]].position = Vector2(3.8, enemy_y[index])
	state.phase = "movement"
	state.active = 2
	state.turn = 1
	state.squads[enemy_squad].moved = false
	var begin_error := C.begin_movement(state, 2, enemy_models[0], "ordered_retreat", int(state.revision))
	check(begin_error.is_empty() and state.pending_move.get("sword_brethren_reaction_squads", []) == [sword_squad], "Fall Back draft records the exact Sword Brethren unit engaged at the start")
	var movement_error := begin_error
	if movement_error.is_empty():
		for model: int in enemy_models:
			movement_error = C.move(state, 2, model, state.units[model].position + Vector2(4, 0), int(state.revision))
			if not movement_error.is_empty(): break
	var finish_error := movement_error if not movement_error.is_empty() else C.finish_movement(state, 2, int(state.revision))
	check(finish_error.is_empty() and state.squads[enemy_squad].fell_back and state.unit_abilities.window.get("kind", "") == SwordBrethren.WINDOW, "An enemy Fall Back that leaves Sword Brethren unengaged opens its reaction")
	var still_engaged := state.duplicate(true)
	still_engaged.squads[1000] = {"owner": 2, "name": "Other Enemy", "starting_strength": 1, "fought": false}
	var blocker: Dictionary = still_engaged.units[enemy_models[0]].duplicate(true)
	blocker.squad = 1000
	blocker.position = Vector2(-2.0, 0.0)
	still_engaged.units[9000] = blocker
	var blocked_choices := SwordBrethren.choices(still_engaged, 1)
	check(blocked_choices.size() == 1 and str(blocked_choices[0].get("action", "")) == "sword-brethren-exploit-pass", "The reaction is unavailable while any enemy still engages the Sword Brethren unit")
	var use_choice := choice(state, 1, "sword-brethren-exploit-use", sword_squad)
	var use_result := PublicUnitCommand.submit(state, 1, use_choice)
	check(not use_choice.is_empty() and str(use_result.get("error", "")).is_empty() and state.unit_abilities.window.get("kind", "") == SwordBrethren.PLACEMENT, "The defender can choose the optional Normal Move through the public decision")
	var moved_brethren := model_for_index(state, sword_squad, 1)
	var origin: Vector2 = state.units[moved_brethren].position
	check(not SwordBrethren.position_error(state, moved_brethren, origin + Vector2(6.1, 0)).is_empty(), "The reaction placement rejects a model moving beyond six inches")
	var place_choice := choice(state, 1, "sword-brethren-exploit-place", sword_squad, moved_brethren)
	var place_result := PublicUnitCommand.submit(state, 1, place_choice, origin + Vector2(1, 0))
	var confirm_choice := choice(state, 1, "sword-brethren-exploit-confirm", sword_squad)
	var confirm_result := PublicUnitCommand.submit(state, 1, confirm_choice)
	check(not place_choice.is_empty() and str(place_result.get("error", "")).is_empty() and not confirm_choice.is_empty() and str(confirm_result.get("error", "")).is_empty(), "The reaction move previews and confirms a legal placement")
	check(state.units[moved_brethren].position.distance_to(origin) <= 6.001 and state.squads[sword_squad].move_type == "normal" and state.unit_abilities.window.is_empty(), "Confirmed reaction records a Normal Move within six inches and resumes the fall-back resolution")
	print("Sword Brethren profile and local rule checks: %d failures" % failures)
	quit(1 if failures else 0)
