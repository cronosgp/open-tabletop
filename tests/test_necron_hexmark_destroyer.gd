extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Hexmark = preload("res://scripts/edition_11/hexmark_destroyer.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const PhaseClose = preload("res://scripts/edition_11/phase_close_gate.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const HEXMARK_ID := "40kdc:11e:necrons:hexmark-destroyer"
const WARRIOR_ID := "40kdc:11e:necrons:necron-warriors"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].entries = [
		{"definition_id": HEXMARK_ID, "models": 1, "copies": 1},
		{"definition_id": WARRIOR_ID, "models": 10, "copies": 1}]
	return result

func models_for(state: Dictionary, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func place(state: Dictionary, models: Array, origin: Vector2) -> void:
	for index in range(models.size()):
		state.units[models[index]].position = origin + Vector2(index * 1.2, 0)
		state.units[models[index]].on_battlefield = true
		state.units[models[index]].wounds = int(state.units[models[index]].max_wounds)

func prepare(state: Dictionary) -> void:
	state.unit_abilities.setup_players = [1]
	if state.has("awakened_dynasty"): state.awakened_dynasty.pending = []
	C.UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		check(C.select_combat_doctrine(state, int(state.active), "none", int(state.revision)).is_empty(), "Clear the unrelated doctrine choice")
	state.phase = "shooting"
	state.active = 1
	state.turn = 2
	state.terrain = {"id": "terrain-11e-v1", "areas": []}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("hexmark-destroyer")
	check(profile.get("source_datasheet_id", "") == "000002355" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Hexmark Destroyer uses the verified local App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {1: 75} and profile.get("third_plus_points_by_models", {}).is_empty(), "Hexmark Destroyer keeps the single 75-point configuration")
	check(profile.stats.movement_inches == 8 and profile.stats.toughness == 5 and profile.stats.save_target == 3 and profile.stats.wounds == 5 and profile.stats.leadership_target == 6 and profile.stats.objective_control == 1 and profile.base_size_source_mm == 50, "Hexmark Destroyer keeps the local characteristics and 50 mm base")
	check(profile.supported_rule_ids == ["deep-strike", "lone-operative", "reanimation-protocols", "inescapable-death", "multi-threat-eliminator"] and profile.unsupported_abilities.is_empty(), "Deep Strike, Lone Operative, Reanimation, Inescapable Death and Multi-threat Eliminator are the local ability scope")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": HEXMARK_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 75, "The one-model Hexmark Destroyer admits at 75 points")
	var copies := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": HEXMARK_ID, "models": 1, "copies": 3}]})
	check(str(copies.get("error", "")).is_empty() and int(copies.get("total", -1)) == 225, "Three Hexmark Destroyers use the 75-point copy price")
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": HEXMARK_ID, "models": 2, "copies": 1}]})
	check(not str(blocked.get("error", "")).is_empty(), "An unpriced Hexmark size stays out of construction")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Hexmark roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	prepare(state)
	var hexmark := models_for(state, "hexmark-destroyer")
	var warriors := models_for(state, "necron-warriors")
	var marines := models_for(state, "intercessor-squad")
	check(hexmark.size() == 1 and warriors.size() == 10 and marines.size() == 5, "The Hexmark, Warriors and Marine squad materialize")
	if hexmark.is_empty() or warriors.is_empty() or marines.is_empty():
		quit(1)
		return
	var hex_squad := int(state.units[hexmark[0]].squad)
	var warrior_squad := int(state.units[warriors[0]].squad)
	var marine_squad := int(state.units[marines[0]].squad)
	check(Reanimation.supported_unit(state, hex_squad), "The one-model Hexmark Destroyer can activate Reanimation Protocols")
	var pistol: Dictionary = state.units[hexmark[0]].ranged_weapons[0]
	check(str(pistol.profiles.standard.name) == "Enmitic disintegrator pistols" and pistol.profiles.standard.keywords.get("close-quarters", false) and pistol.profiles.standard.keywords.get("ignores-cover", false), "The local Pistol profile materializes as close-quarters shooting with Ignores Cover")
	check(C.UnitAbilities.has(state, hex_squad, "deep-strike") and C.UnitAbilities.lone_operative_range(state, hexmark[0]) == 12.0, "Deep Strike is active and Lone Operative uses the 12-inch range")

	place(state, hexmark, Vector2.ZERO)
	place(state, warriors, Vector2(40, 40))
	place(state, marines, Vector2(0, 20))
	var weapon_id := str(pistol.get("id", ""))
	var marine_weapon := str(state.units[marines[0]].ranged_weapons[0].get("id", ""))
	var marine_profile := str(state.units[marines[0]].ranged_weapons[0].profiles.keys()[0])
	check(hex_squad not in AttackPlan.legal_targets(state, marines[0], false, marine_weapon, marine_profile), "Lone Operative blocks an enemy shot from more than 12 inches")
	place(state, marines, Vector2(0, 8))
	check(hex_squad in AttackPlan.legal_targets(state, marines[0], false, marine_weapon, marine_profile), "An enemy within 12 inches can target the Hexmark Destroyer")
	place(state, warriors, Vector2(4.2, 0))
	place(state, marines, Vector2(4.2, 14))
	scripted_dice = [1]
	var enemy_shot := C.resolve_attack_plan(state, 1, marines[0], [{"model": marines[0], "target": warrior_squad, "amount": 1, "weapon": marine_weapon, "profile": marine_profile}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(enemy_shot.get("error", "")).is_empty() and str(state.unit_abilities.window.get("kind", "")) == Hexmark.KIND, "An enemy shot at nearby Necrons opens Multi-threat Eliminator: %s" % str(enemy_shot.get("error", "")))
	check(not PhaseClose.close_request_error(state, 1, int(state.revision)).is_empty(), "The Shooting phase waits for Multi-threat Eliminator")
	var decline_choices: Array = Hexmark.choices(state, 2).filter(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "pass")
	if decline_choices.is_empty():
		check(false, "Multi-threat Eliminator offers a decline")
		quit(1)
		return
	var declined := PublicUnitCommand.submit(state, 2, decline_choices[0])
	check(str(declined.get("error", "")).is_empty() and state.unit_abilities.window.is_empty() and not state.unit_abilities.get("used", {}).has("multi-threat-eliminator:%d" % hex_squad), "Declining does not spend the once-per-turn shot")
	check(Hexmark.offer(state, marine_squad, [warrior_squad]), "The unused reaction can be offered again this turn")
	var selected := PublicUnitCommand.submit(state, 2, Hexmark.choices(state, 2).filter(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "shoot")[0])
	check(str(selected.get("error", "")).is_empty() and Hexmark.active_shooter(state, hex_squad), "Selecting the shot restricts it to the enemy that just shot")
	check(marine_squad in AttackPlan.legal_targets(state, hexmark[0], false, weapon_id, "standard") and warrior_squad not in AttackPlan.legal_targets(state, hexmark[0], false, weapon_id, "standard"), "The reaction can target only the attacking enemy unit")
	scripted_dice = [2, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6, 6, 1, 1, 1, 1, 1, 1]
	var wounds_before := int(state.units[marines[0]].wounds)
	var reaction := C.resolve_attack_plan(state, 2, hexmark[0], [{"model": hexmark[0], "target": marine_squad, "amount": 1, "weapon": weapon_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	check(str(reaction.get("error", "")).is_empty() and int(state.units[marines[0]].wounds) < wounds_before, "An unmodified Hit roll of 2 scores a normal shooting hit: %s" % str(reaction))
	check(int(state.unit_abilities.get("used", {}).get("multi-threat-eliminator:%d" % hex_squad, -1)) == int(state.turn) and state.unit_abilities.window.is_empty(), "A completed Multi-threat Eliminator shot is spent for the turn")
	check(not Hexmark.offer(state, marine_squad, [warrior_squad]), "The same Hexmark cannot use Multi-threat Eliminator again this turn")
	state.unit_abilities.used.erase("multi-threat-eliminator:%d" % hex_squad)
	state.squads[hex_squad].shot = false
	place(state, warriors, Vector2(0, 30))
	check(not Hexmark.offer(state, marine_squad, [warrior_squad]), "A friendly Necrons unit more than 3 inches away does not trigger the reaction")
	check(Hexmark.offer(state, marine_squad, [hex_squad]), "The Hexmark can answer a shot at its own unit")
	var own_pass: Array = Hexmark.choices(state, 2).filter(func(option: Dictionary) -> bool: return str(option.get("value", "")) == "pass")
	check(not own_pass.is_empty() and str(PublicUnitCommand.submit(state, 2, own_pass[0]).get("error", "")).is_empty(), "The self-target reaction can be declined")
	state.active = 2
	check(not Hexmark.offer(state, marine_squad, [hex_squad]), "Multi-threat Eliminator waits for the opponent's Shooting phase")

	state.phase = "movement"
	state.active = 1
	state.turn = 3
	state.cp[2] = 0
	state.unit_abilities.window = {"kind": "end", "owners": [2]}
	state.stratagems.uses.append({"player": 2, "squad": warrior_squad, "stratagem": "fire-overwatch", "phase_key": C.CoreReactions.phase_key(state), "turn": state.turn})
	check(C.CoreReactions.cost_of(state, 2, hex_squad, C.CoreReactions.OVERWATCH) == 0 and C.CoreReactions.error(state, 2, hex_squad, C.CoreReactions.OVERWATCH).is_empty(), "Inescapable Death allows one 0CP Fire Overwatch after another unit has used it this phase")
	var overwatch := C.CoreReactions.apply(state, 2, {"action": "core-stratagem", "model": -1, "target": hex_squad, "value": C.CoreReactions.OVERWATCH})
	check(str(overwatch.get("error", "")).is_empty() and int(state.cp[2]) == 0 and int(state.unit_abilities.used.get("inescapable-death:%d" % 2, -1)) == 3, "The free Overwatch spends the once-per-turn permission without CP: %s" % str(overwatch))
	var overwatch_plan := AttackPlan.prepare(state, hex_squad, false, [{"model": hexmark[0], "target": marine_squad, "amount": 1, "weapon": weapon_id, "profile": "standard"}], true)
	check(str(overwatch_plan.get("error", "")).is_empty() and int(overwatch_plan.batches[0].context.get("snap_hit_threshold", 0)) == 2 and str(overwatch_plan.batches[0].context.get("hit_reroll", "")) == "none", "Hexmark Overwatch hits on unmodified 2+ without hit re-rolls")
	scripted_dice = [2, 2, 2, 2, 2, 2, 6, 6, 6, 6, 6, 6, 1, 1, 1, 1, 1, 1]
	var overwatch_attack := C.resolve_attack_plan(state, 2, hexmark[0], [{"model": hexmark[0], "target": marine_squad, "amount": 1, "weapon": weapon_id, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))
	var overwatch_pool: Dictionary = overwatch_attack.get("pools", [{}])[0]
	check(str(overwatch_attack.get("error", "")).is_empty() and int(overwatch_pool.get("snap_hit_threshold", 0)) == 2 and int(overwatch_pool.get("damage_applied", 0)) > 0 and bool(overwatch_pool.get("hit_outcomes", [{}])[0].get("success", false)), "An Overwatch Hit roll of 2 wounds through the snap-shooting path: %s" % str(overwatch_attack.get("message", overwatch_attack)))
	state.core_reactions.overwatch = {}
	state.unit_abilities.window = {"kind": "end", "owners": [2]}
	check(C.CoreReactions.cost_of(state, 2, hex_squad, C.CoreReactions.OVERWATCH) == 1 and not C.CoreReactions.error(state, 2, hex_squad, C.CoreReactions.OVERWATCH).is_empty(), "After the free use, another Overwatch this phase is no longer available")
	state.stratagems.uses = []
	check(C.CoreReactions.error(state, 2, hex_squad, C.CoreReactions.OVERWATCH) == "This stratagem costs 1 CP.", "A later Overwatch in the turn uses the normal 1CP cost")

	if failures == 0: print("Necron Hexmark Destroyer local checks: passed")
	else: print("Necron Hexmark Destroyer local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
