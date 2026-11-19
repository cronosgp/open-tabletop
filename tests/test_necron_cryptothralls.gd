extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Cryptothralls = preload("res://scripts/edition_11/necron_cryptothralls.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const THRALL_ID := "40kdc:11e:necrons:cryptothralls"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const WARDEN_ID := "40kdc:11e:necrons:royal-warden"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const CRYPTEK_ID := "40kdc:11e:necrons:orikan-the-diviner"

var failures := 0
var scripted_dice: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func selections() -> Dictionary:
	return {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [
			{"definition_id": THRALL_ID, "models": 2, "copies": 2},
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
	var profile := Profiles.profile("cryptothralls")
	var eye: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var limbs: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000002111" and profile.get("source_snapshot_id", "") == "20261031T053336Z" and profile.get("points_by_models", {}) == {2: 60} and profile.get("base_size_source_mm", 0) == 32, "Cryptothralls retain the App v1.2 identity, 2-model price and 32 mm base")
	check(eye.get("range_inches") == 6 and eye.get("attacks") == 2 and eye.get("strength") == 5 and limbs.get("attacks") == 4 and limbs.get("strength") == 5, "Scouring eye and Scythed limbs preserve source profiles")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "bound-creation", "systematic-vigour", "cryptek-retinue"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Every Cryptothralls rule is admitted within its locally checked scope")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": THRALL_ID, "models": 2, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 60, "The two-model Cryptothralls unit is admitted at 60 points")
	check(AbilityCatalog.RULES.get("cryptothralls", []) == ["reanimation-protocols", "bound-creation", "systematic-vigour", "cryptek-retinue"], "All four source rules bind to the Cryptothralls identity")

	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "Cryptothralls fixture admits: " + str(state.get("error", "")))
		quit(1)
		return
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = []
	state.active = 1
	state.phase = "deployment"
	state.turn = 1
	var thralls := models_for(state, 1, "cryptothralls")
	var warden := models_for(state, 1, "royal-warden")
	var warriors := models_for(state, 1, "necron-warriors")
	var marines := models_for(state, 2, "intercessor-squad")
	var first_thrall_squad := squad_for(state, 1, "cryptothralls")
	var second_thrall_squad := -1
	for model: int in thralls:
		var candidate := int(state.units[model].get("squad", -1))
		if candidate != first_thrall_squad: second_thrall_squad = candidate
	var warrior_squad := squad_for(state, 1, "necron-warriors")
	var enemy_squad := squad_for(state, 2, "intercessor-squad")
	check(thralls.size() == 4 and warden.size() == 1 and warriors.size() == 10 and first_thrall_squad >= 0 and second_thrall_squad >= 0 and warrior_squad >= 0, "Both Cryptothralls units and supporting fixture materialize")
	if thralls.size() != 4 or warden.is_empty() or warriors.size() != 10 or first_thrall_squad < 0 or second_thrall_squad < 0 or warrior_squad < 0:
		quit(1)
		return

	for index in range(thralls.size()): state.units[thralls[index]].position = Vector2(0.0, float(index) * 1.2)
	for index in range(warriors.size()): state.units[warriors[index]].position = Vector2(-2.0, float(index) * 0.6)
	state.units[warden[0]].definition_id = CRYPTEK_ID
	state.units[warden[0]].name = "Orikan the Diviner"
	state.units[warden[0]].max_wounds = 4
	state.units[warden[0]].wounds = 4
	if "CRYPTEK" not in state.units[warden[0]].keywords: state.units[warden[0]].keywords.append("CRYPTEK")
	state.units[warden[0]].position = Vector2(-3.0, 0.0)
	for index in range(marines.size()): state.units[marines[index]].position = Vector2(8.0, float(index - 2) * 0.8)
	UnitActions.reconcile(state)
	var cryptek_attach := find_choice(state, 1, "attach", warden[0], warrior_squad)
	var cryptek_result := PublicUnitCommand.submit(state, 1, cryptek_attach)
	check(not cryptek_attach.is_empty() and str(cryptek_result.get("error", "")).is_empty() and state.squads[warrior_squad].get("attached", false), "A Cryptek-led bodyguard forms through the public setup choice")

	var retinue_choice := find_choice(state, 1, Cryptothralls.RETINUE_ACTION, thralls[0], warrior_squad)
	check(not retinue_choice.is_empty(), "Declare Battle Formations offers Cryptek Retinue for a Cryptek-led unit")
	var blocked_crawlers: Dictionary = state.duplicate(true)
	var crawler: Dictionary = blocked_crawlers.units[warriors[0]].duplicate(true)
	crawler.definition_id = "40kdc:11e:necrons:canoptek-tomb-crawlers"
	crawler.name = "Canoptek Tomb Crawlers"
	crawler.squad = warrior_squad
	crawler.attachment_role = "support"
	blocked_crawlers.units[900001] = crawler
	check(not Cryptothralls.retinue_error(blocked_crawlers, thralls[0], warrior_squad).is_empty(), "Canoptek Tomb Crawlers prevent adding Cryptothralls to the same unit")
	var retinue_result := PublicUnitCommand.submit(state, 1, retinue_choice)
	check(str(retinue_result.get("error", "")).is_empty() and state.squads[warrior_squad].starting_strength == 13 and state.squads[warrior_squad].components.size() == 3, "Cryptek Retinue adds both Cryptothralls and increases Starting Strength by two")
	check(not Cryptothralls.retinue_error(state, thralls[2], warrior_squad).is_empty(), "A joined unit cannot receive a second Cryptothralls unit")
	check(Reanimation.supported_unit(state, warrior_squad), "Reanimation Protocols accepts the Cryptek, bodyguard and Cryptothralls composition")

	var cryptek_model := warden[0]
	var prevention: Array = Prevention.rules(state, cryptek_model)
	check(prevention.any(func(rule: Dictionary) -> bool: return int(rule.get("target", 0)) == 4 and str(rule.get("against", "")) == "any"), "Bound Creation grants Feel No Pain 4+ to the Cryptek sharing the unit")
	state.units[thralls[0]].wounds = 0
	state.units[thralls[1]].wounds = 0
	check(not Prevention.rules(state, cryptek_model).any(func(rule: Dictionary) -> bool: return int(rule.get("target", 0)) == 4 and str(rule.get("against", "")) == "any"), "Bound Creation ends when no living Cryptothralls remain in the unit")
	state.units[thralls[0]].wounds = 3
	state.units[thralls[1]].wounds = 3

	state.phase = "fight"
	state.active = 2
	state.fight_actor = 2
	state.fight_selected = enemy_squad
	state.fight_step = "attacks"
	state.squads[warrior_squad].fought = false
	state.pending_attack = {"squad": enemy_squad, "melee": true, "player": 2, "ability_saves": {}}
	state.units[thralls[0]].wounds = 0
	scripted_dice = [2]
	var held := DetachmentStratagems.hold_destroyed(state, thralls[0], Callable(self, "next_die"))
	check(bool(held.get("held", false)) and int(held.get("roll", 0)) == 2 and bool(state.units[thralls[0]].get("systematic_vigour_lingering", false)) and int(state.units[thralls[0]].wounds) == 1, "Systematic Vigour keeps a melee-destroyed Cryptothrall on a 2+")
	state.squads[enemy_squad].fought = true
	check(Cryptothralls.after_attacker_fight(state, enemy_squad) and str(state.unit_abilities.window.get("kind", "")) == Cryptothralls.WINDOW, "After the attacking unit finishes, Systematic Vigour opens its fight window")
	var fight_choice := find_choice(state, 1, Cryptothralls.FIGHT_ACTION, thralls[0], enemy_squad)
	var fight_result := PublicUnitCommand.submit(state, 1, fight_choice)
	check(not fight_choice.is_empty() and str(fight_result.get("error", "")).is_empty() and Cryptothralls.active_model(state) == thralls[0] and not bool(state.squads[warrior_squad].get("fought", true)), "Systematic Vigour arms the Cryptothrall to fight immediately")
	state.squads[warrior_squad].fought = true
	Cryptothralls.finish_active_fight(state, warrior_squad)
	check(int(state.units[thralls[0]].wounds) == 0 and not bool(state.units[thralls[0]].get("systematic_vigour_lingering", false)), "After its Systematic Vigour fight, the Cryptothrall is removed")

	if failures == 0:
		print("Cryptothralls scoped local checks: passed")
		quit(0)
	else:
		print("Cryptothralls checks: %d failures" % failures)
		quit(1)
