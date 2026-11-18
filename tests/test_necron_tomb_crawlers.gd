extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const TombCrawlers = preload("res://scripts/edition_11/canoptek_tomb_crawlers.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const CRAWLER_ID := "40kdc:11e:necrons:canoptek-tomb-crawlers"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const WARDEN_ID := "40kdc:11e:necrons:royal-warden"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const CRYPTEK_ID := "40kdc:11e:necrons:orikan-the-diviner"
const BJORN_ID := "40kdc:11e:adeptus-astartes:bjorn-the-fell-handed"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [
			{"definition_id": CRAWLER_ID, "models": 2, "copies": 2},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1},
			{"definition_id": WARDEN_ID, "models": 1, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 500, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}]}}

func models_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and Abilities.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, owner: int, identity: String, skip: int = -1) -> int:
	for squad: int in state.get("squads", {}):
		if squad == skip or int(state.squads[squad].get("owner", -1)) != owner: continue
		var alive := Geometry.alive(state, squad)
		if not alive.is_empty() and Abilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func find_choice(state: Dictionary, player: int, action: String, model: int = -1, target: int = -1, value: String = "") -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if not value.is_empty() and str(option.get("value", "")) != value: continue
		return option
	return {}

func run() -> void:
	var profile := Profiles.profile("canoptek-tomb-crawlers")
	var reaper: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var isolator: Dictionary = profile.get("additional_weapon_profiles", {}).get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var claws: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000004177" and profile.get("source_snapshot_id", "") == "20261031T053336Z" and profile.get("points_by_models", {}) == {2: 60} and profile.get("construction_model_sizes", []) == [2] and profile.get("base_size_source_mm", 0) == 50, "Canoptek Tomb Crawlers retain the App v1.2 identity, 2-model price and 50 mm base")
	check(profile.get("stats", {}) == {"movement_inches": 5, "toughness": 4, "save_target": 3, "wounds": 3, "leadership_target": 8, "objective_control": 1, "invulnerable_target": 0}, "Canoptek Tomb Crawlers retain their source characteristics")
	check(reaper.get("range_inches") == 12 and reaper.get("attacks") == 2 and reaper.get("skill") == 4 and reaper.get("strength") == 4 and reaper.get("ap") == -1 and reaper.get("damage") == 1 and reaper.get("keywords", {}) == {"lethal-hits": true, "twin-linked": true}, "Twin gauss reaper preserves all source characteristics and traits")
	check(isolator.get("range_inches") == 12 and isolator.get("attacks") == 2 and isolator.get("skill") == 4 and isolator.get("strength") == 4 and isolator.get("ap") == -2 and isolator.get("damage") == 2 and isolator.get("keywords", {}).is_empty(), "Transdimensional isolator preserves its replacement profile")
	check(claws.get("attacks") == 4 and claws.get("skill") == 4 and claws.get("strength") == 6 and claws.get("ap") == -1 and claws.get("damage") == 1, "Claws preserve their complete melee profile")
	check(profile.get("source_options", []).size() == 1 and profile.source_options[0].get("implemented", false) and profile.get("supported_rule_ids", []) == ["reanimation-protocols", "weapon-sentinels", "canoptek-retinue"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "The profile records its single replacement option and only the source-bounded rules scope")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": CRAWLER_ID, "models": 2, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 60, "The source-priced two-model unit is admitted at 60 points")
	check(AbilityCatalog.RULES.get("canoptek-tomb-crawlers", []) == ["weapon-sentinels", "canoptek-retinue"], "Both source rules are bound to the Tomb Crawlers identity")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "The local Tomb Crawlers fixture materializes: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	state.active = 1
	state.phase = "deployment"
	state.turn = 1
	var crawlers := models_for(state, 1, "canoptek-tomb-crawlers")
	var warden := models_for(state, 1, "royal-warden")
	var warriors := models_for(state, 1, "necron-warriors")
	var marines := models_for(state, 2, "intercessor-squad")
	var first_crawler_squad := squad_for(state, 1, "canoptek-tomb-crawlers")
	var second_crawler_squad := -1
	for model: int in crawlers:
		var candidate := int(state.units[model].get("squad", -1))
		if candidate != first_crawler_squad: second_crawler_squad = candidate
	var warrior_squad := squad_for(state, 1, "necron-warriors")
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	check(crawlers.size() == 4 and warden.size() == 1 and warriors.size() == 10 and marines.size() == 5 and first_crawler_squad >= 0 and second_crawler_squad >= 0 and warrior_squad >= 0 and enemy_squad >= 0, "Both source-sized Tomb Crawlers units and the supporting fixture materialize")
	if crawlers.size() != 4 or warden.size() != 1 or warriors.size() != 10 or marines.size() != 5 or first_crawler_squad < 0 or second_crawler_squad < 0 or warrior_squad < 0 or enemy_squad < 0:
		quit(1)
		return

	for index in range(crawlers.size()): state.units[crawlers[index]].position = Vector2(0.0, float(index) * 1.6)
	for index in range(warriors.size()): state.units[warriors[index]].position = Vector2(-2.0, float(index) * 0.6)
	state.units[warden[0]].definition_id = CRYPTEK_ID
	state.units[warden[0]].name = "Orikan the Diviner"
	state.units[warden[0]].max_wounds = 4
	state.units[warden[0]].wounds = 4
	if "CRYPTEK" not in state.units[warden[0]].keywords: state.units[warden[0]].keywords.append("CRYPTEK")
	state.units[warden[0]].position = Vector2(-3.0, 0.0)
	for index in range(marines.size()): state.units[marines[index]].position = Vector2(8.0, float(index - 2) * 0.8)
	UnitActions.reconcile(state)
	check(UnitActions.attachment_allowed(state, warden[0], warrior_squad), "A source-listed Cryptek can lead the selected bodyguard unit")
	var cryptek_attach := find_choice(state, 1, "attach", warden[0], warrior_squad)
	var cryptek_result := PublicUnitCommand.submit(state, 1, cryptek_attach)
	check(not cryptek_attach.is_empty() and str(cryptek_result.get("error", "")).is_empty() and state.squads[warrior_squad].get("attached", false), "The existing Cryptek-led unit is formed through the public setup choice")

	var loadout_choice := find_choice(state, 1, TombCrawlers.LOADOUT_ACTION, crawlers[0], first_crawler_squad, TombCrawlers.ISOLATOR)
	var loadout_result := PublicUnitCommand.submit(state, 1, loadout_choice)
	check(not loadout_choice.is_empty() and str(loadout_result.get("error", "")).is_empty() and state.units[crawlers[0]].ranged_weapons[0].get("id", "") == "source-ranged-1" and state.units[crawlers[0]].ranged_weapons[0].profiles.standard.ap == -2 and state.units[crawlers[0]].melee_weapons.size() == 1, "One model can replace its reaper with the isolator while retaining Claws")
	check(find_choice(state, 1, TombCrawlers.LOADOUT_ACTION, crawlers[1], first_crawler_squad, TombCrawlers.ISOLATOR).is_empty(), "A second isolator is not offered for the same two-model unit")
	check(state.units[crawlers[1]].ranged_weapons[0].get("id", "") == "source-ranged-2", "The other model retains its twin gauss reaper")

	var retinue_choice := find_choice(state, 1, TombCrawlers.RETINUE_ACTION, crawlers[0], warrior_squad)
	check(not retinue_choice.is_empty(), "Declare Battle Formations offers the optional Retinue for a unit already led by a Cryptek")
	var blocked_cryptothralls: Dictionary = state.duplicate(true)
	var thrall: Dictionary = blocked_cryptothralls.units[warriors[0]].duplicate(true)
	thrall.definition_id = "40kdc:11e:necrons:cryptothralls"
	thrall.name = "Cryptothralls"
	thrall.squad = warrior_squad
	thrall.attachment_role = "support"
	blocked_cryptothralls.units[900001] = thrall
	check(not TombCrawlers.retinue_error(blocked_cryptothralls, crawlers[0], warrior_squad).is_empty(), "Cryptothralls prevent adding Canoptek Tomb Crawlers to the same unit")
	var retinue_result := PublicUnitCommand.submit(state, 1, retinue_choice)
	check(str(retinue_result.get("error", "")).is_empty() and state.squads[warrior_squad].starting_strength == 13 and state.squads[warrior_squad].components.size() == 3, "Retinue adds both Tomb Crawlers to the Cryptek-led unit and increases Starting Strength by two")
	check(not TombCrawlers.retinue_error(state, crawlers[2], warrior_squad).is_empty() and find_choice(state, 1, TombCrawlers.RETINUE_ACTION, crawlers[2], warrior_squad).is_empty(), "A joined unit cannot receive a second Tomb Crawlers unit")
	check(Reanimation.supported_unit(state, warrior_squad), "Reanimation Protocols accepts the source-sized Cryptek, bodyguard and Tomb Crawlers composition")

	state.phase = "shooting"
	state.active = 1
	state.turn = 1
	state.unit_abilities.shrouded_targets = {enemy_squad: {"phase_key": "1:shooting"}}
	state.unit_abilities.weapon_skill_characteristic_modifiers = {"squads": {warrior_squad: {"BS": -1}}, "models": {}}
	state.squads[enemy_squad].stats.toughness = 3
	state.units[marines[0]].definition_id = BJORN_ID
	var crawler_model := crawlers[0]
	var crawler_attack := C.AttackPlan.prepare(state, warrior_squad, false, [{"model": crawler_model, "target": enemy_squad, "amount": 1, "weapon": "source-ranged-1", "profile": "standard"}], true)
	check(str(crawler_attack.get("error", "")).is_empty() and crawler_attack.get("batches", []).size() == 1, "The isolator attack plan resolves against a visible enemy within range (%s)" % str(crawler_attack.get("error", "no batches")))
	if not crawler_attack.get("batches", []).is_empty():
		var crawler_context: Dictionary = crawler_attack.batches[0].context
		check(crawler_attack.batches[0].weapon.skill == 4 and crawler_context.hit_modifier == 0 and crawler_context.wound_modifier == 0, "Weapon Sentinels ignores BS, Hit and Wound modifiers for this model's ranged attack")
	var warrior_weapon: Dictionary = Equipment.choices(state, warriors[0], false)[0]
	var warrior_attack := C.AttackPlan.prepare(state, warrior_squad, false, [{"model": warriors[0], "target": enemy_squad, "amount": 1, "weapon": warrior_weapon.weapon, "profile": warrior_weapon.profile}], true)
	check(str(warrior_attack.get("error", "")).is_empty() and warrior_attack.get("batches", []).size() == 1, "The attached bodyguard control attack resolves against the same target (%s)" % str(warrior_attack.get("error", "no batches")))
	if not warrior_attack.get("batches", []).is_empty():
		var warrior_context: Dictionary = warrior_attack.batches[0].context
		check(warrior_attack.batches[0].weapon.skill == 5 and warrior_context.hit_modifier == -1 and warrior_context.wound_modifier == -1, "Weapon Sentinels does not extend to the other models in the attached unit")
	var boundary_position: Vector2 = state.units[crawler_model].position + Vector2(12.0 + float(state.units[crawler_model].radius) + float(state.units[marines[0]].radius), 0.0)
	for model: int in marines: state.units[model].position = boundary_position
	check(absf(Geometry.distance_to_target(state, state.units[crawler_model], enemy_squad) - 12.0) < 0.001 and TombCrawlers.weapon_sentinels_applies(state, crawler_model, enemy_squad), "Weapon Sentinels includes targets exactly 12 inches away base-to-base")
	for model: int in marines: state.units[model].position = boundary_position + Vector2(0.01, 0.0)
	check(not TombCrawlers.weapon_sentinels_applies(state, crawler_model, enemy_squad) and not TombCrawlers.weapon_sentinels_applies(state, crawler_model, enemy_squad, true), "Weapon Sentinels ends beyond 12 inches and never applies to melee attacks")

	if failures == 0:
		print("Canoptek Tomb Crawlers: source profile, admission, loadout, Retinue restrictions, per-model attack modifiers and attached Reanimation scope passed.")
		quit(0)
	else:
		quit(1)
