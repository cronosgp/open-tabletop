extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const ScoutMoves = preload("res://scripts/edition_11/scout_moves.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const DECEIVER_ID := "40kdc:11e:necrons:ctan-shard-of-the-deceiver"
const BARGE_ID := "40kdc:11e:necrons:annihilation-barge"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

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
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[1].category = "custom"
	result[1].points_limit = 750
	result[2].faction = "Necrons"
	result[2].category = "custom"
	result[2].points_limit = 750
	result[2].entries = [
		{"definition_id": DECEIVER_ID, "models": 1, "copies": 1},
		{"definition_id": BARGE_ID, "models": 1, "copies": 1},
		{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}]
	return result

func units_for(state: Dictionary, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		if C.UnitAbilities.identity(state.units[model]) == identity: result.append(model)
	result.sort()
	return result

func squad_for(state: Dictionary, identity: String) -> int:
	for squad: int in state.get("squads", {}):
		var alive := Geometry.alive(state, squad)
		if not alive.is_empty() and C.UnitAbilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func place_all(state: Dictionary) -> void:
	var row_by_owner := {1: 0, 2: 0}
	var squads: Array[int] = []
	for squad: int in state.squads: squads.append(squad)
	squads.sort()
	for squad: int in squads:
		var owner := int(state.squads[squad].owner)
		var zone: Rect2 = state.deployment.zones[owner]
		var origin := zone.position + Vector2(2.0, 2.0 + float(row_by_owner[owner]) * 3.0)
		row_by_owner[owner] += 1
		var models := Geometry.alive(state, squad)
		for index in range(models.size()):
			state.units[models[index]].position = origin + Vector2(float(index % 5) * 1.4, float(index / 5) * 1.4)
			state.units[models[index]].on_battlefield = true

func find_choice(state: Dictionary, player: int, action: String, target: int = -1) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		return option
	return {}

func act(state: Dictionary, player: int, option: Dictionary) -> String:
	return C.unit_action(state, player, option, Vector2.ZERO, int(state.get("revision", -1)), Callable(self, "next_die"))

func run() -> void:
	var profile := Profiles.profile("ctan-shard-of-the-deceiver")
	check(profile.get("source_datasheet_id", "") == "000000542" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "The Deceiver facts come from its verified local App v1.2 export")
	check(profile.get("points_by_models", {}) == {1: 330} and profile.get("base_size_source_mm", 0) == 40 and profile.get("stats", {}) == {"movement_inches": 8, "toughness": 11, "save_target": 3, "wounds": 16, "leadership_target": 6, "objective_control": 4, "invulnerable_target": 4}, "The Deceiver cost, footprint and characteristics match the local source sheet")
	var cosmic: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var fists: Dictionary = profile.get("melee", [{}])[0].get("profiles", {}).get("standard", {})
	check(cosmic == {"name": "Cosmic insanity", "range_inches": 18, "attacks": 6, "skill": 2, "strength": 6, "ap": -2, "damage": 2, "keywords": {"anti-character": 4, "devastating-wounds": true, "precision": true}} and fists == {"name": "Golden fists", "range_inches": 0, "attacks": 8, "skill": 2, "strength": 10, "ap": -3, "damage": 3, "keywords": {}}, "Both fixed Deceiver weapons preserve their source characteristics and keywords")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "deadly-demise-d6", "deep-strike", "feel-no-pain-5", "stealth", "necrodermis", "enslaved-star-god", "grand-illusion"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_options", []).is_empty(), "All listed Deceiver abilities are mapped and its source loadout has no pending choices")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": DECEIVER_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 330, "The one-model Epic Hero enters construction at 330 points: %s" % str(admitted.get("error", "")))
	var duplicate := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": DECEIVER_ID, "models": 1, "copies": 2}]})
	check(not str(duplicate.get("error", "")).is_empty(), "The Epic Hero duplicate cap remains enforced")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": true}, selections())
	if state.has("error"):
		check(false, "Deceiver roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	var deceiver_models := units_for(state, "ctan-shard-of-the-deceiver")
	var deceiver_squad := squad_for(state, "ctan-shard-of-the-deceiver")
	var barge_squad := squad_for(state, "annihilation-barge")
	var warriors_squad := squad_for(state, "necron-warriors")
	var marine_squad := squad_for(state, "intercessor-squad")
	check(deceiver_models.size() == 1 and deceiver_squad >= 0 and barge_squad >= 0 and warriors_squad >= 0 and marine_squad >= 0, "The local fixture materializes the Deceiver, two additional Necron units and the opposing Marine unit")
	if deceiver_models.is_empty() or deceiver_squad < 0 or barge_squad < 0 or warriors_squad < 0 or marine_squad < 0:
		quit(1)
		return
	var deceiver := deceiver_models[0]
	check(Abilities.deadly_demise_value(state, deceiver) == "D6" and Abilities.cannot_be_warlord(state, deceiver) and Abilities.has(state, deceiver_squad, "deep-strike") and Abilities.has(state, deceiver_squad, "feel-no-pain-5") and Abilities.has(state, deceiver_squad, "stealth") and Abilities.has(state, deceiver_squad, "necrodermis"), "Deceiver identity binds Deadly Demise, Deep Strike, Feel No Pain, Stealth, Necrodermis and its Warlord restriction")
	place_all(state)
	var cosmic_weapon_id := str(state.units[deceiver].get("ranged_weapons", [{}])[0].get("id", ""))
	var first_marine := Geometry.alive(state, marine_squad)[0]
	var first_marine_origin: Vector2 = state.units[first_marine].position
	state.units[first_marine].position = state.units[deceiver].position + Vector2(8.0, 0.0)
	var plan := C.AttackPlan.prepare(state, deceiver_squad, false, [{"model": deceiver, "target": marine_squad, "amount": 1, "weapon": cosmic_weapon_id, "profile": "standard"}], true)
	var planned_weapon: Dictionary = plan.get("batches", [{}])[0].get("weapon", {})
	state.units[first_marine].position = first_marine_origin
	check(str(plan.get("error", "")).is_empty() and planned_weapon.get("keywords", {}) == {"anti-character": 4, "devastating-wounds": true, "precision": true} and int(planned_weapon.get("strength", 0)) == 6 and int(planned_weapon.get("damage", 0)) == 2, "The admitted Cosmic insanity weapon enters the shared attack plan with its complete traits")
	state.phase = "pre_battle"
	state.first_player = 2
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	var fake_marine_id := 990001
	state.squads[fake_marine_id] = {"owner": 2, "name": "synthetic allied Astartes check", "training_cost": 50}
	state.units[9900011] = {"owner": 2, "squad": fake_marine_id, "wounds": 1, "on_battlefield": true, "position": state.deployment.zones[2].position + Vector2(2, 26), "radius": 0.5, "keywords": ["ADEPTUS ASTARTES"]}
	ScoutMoves.begin(state)
	check(state.unit_abilities.window.get("kind", "") == "strategium-command" and state.unit_abilities.window.get("source", "") == "grand-illusion" and ScoutMoves.actor(state) == 2, "Grand Illusion opens for the Deceiver owner before Scouts")
	var choices := ScoutMoves.choices(state, 2)
	var listed: Array[int] = []
	for option: Dictionary in choices:
		if str(option.get("action", "")) == "strategium-select": listed.append(int(option.get("target", -1)))
	check(deceiver_squad in listed and barge_squad in listed and warriors_squad in listed and fake_marine_id not in listed, "Grand Illusion offers deployed Necrons units and excludes an allied Astartes unit")
	var before_wrong_owner := state.duplicate(true)
	var wrong_owner_error := act(state, 1, find_choice(state, 1, "strategium-finish"))
	check(not wrong_owner_error.is_empty() and state.unit_abilities.window == before_wrong_owner.unit_abilities.window, "The opposing player cannot operate the Deceiver's pre-battle window")
	var select_barge := find_choice(state, 2, "strategium-select", barge_squad)
	check(not select_barge.is_empty() and act(state, 2, select_barge).is_empty(), "The Deceiver owner can select a Barge for redeployment")
	var begin_move := find_choice(state, 2, "strategium-redeploy", barge_squad)
	check(not begin_move.is_empty() and act(state, 2, begin_move).is_empty(), "Grand Illusion enters the normal redeployment placement flow")
	var barge_model := units_for(state, "annihilation-barge")[0]
	var illegal_point: Vector2 = state.deployment.zones[1].position + Vector2(4, 4)
	var rejected := ScoutMoves.apply(state, "strategium-place", barge_model, barge_squad, illegal_point)
	check(not rejected.is_empty(), "Grand Illusion redeployment rejects placement outside the normal deployment zone")
	var zone: Rect2 = state.deployment.zones[2]
	var legal_point: Vector2 = zone.position + Vector2(zone.size.x * 0.55, zone.size.y * 0.5)
	var legal_error := ScoutMoves.apply(state, "strategium-place", barge_model, barge_squad, legal_point)
	check(legal_error.is_empty(), "A legal normal-zone Barge placement is accepted: " + legal_error)
	var confirm := find_choice(state, 2, "strategium-confirm", barge_squad)
	check(not confirm.is_empty() and act(state, 2, confirm).is_empty() and state.units[barge_model].position == legal_point, "Confirming Grand Illusion keeps the selected unit on the battlefield at its new position")

	var select_warriors := find_choice(state, 2, "strategium-select", warriors_squad)
	check(not select_warriors.is_empty() and act(state, 2, select_warriors).is_empty(), "A second distinct Necrons unit may be selected")
	var reserve_warriors := find_choice(state, 2, "strategium-reserve", warriors_squad)
	check(not reserve_warriors.is_empty() and act(state, 2, reserve_warriors).is_empty(), "Grand Illusion permits the selected unit to enter Strategic Reserves")
	var warrior_reserve: Dictionary = state.unit_abilities.reserves.get(warriors_squad, {})
	check(warrior_reserve.get("source", "") == "grand-illusion" and warrior_reserve.get("bypass_limit", false) and Geometry.alive(state, warriors_squad).all(func(model: int) -> bool: return not state.units[model].on_battlefield), "Reserved Necron models are offboard and carry the ability's reserve-limit exception")
	var select_deceiver := find_choice(state, 2, "strategium-select", deceiver_squad)
	check(not select_deceiver.is_empty() and act(state, 2, select_deceiver).is_empty(), "The Deceiver itself can be the third selected unit")
	var reserve_deceiver := find_choice(state, 2, "strategium-reserve", deceiver_squad)
	check(not reserve_deceiver.is_empty() and act(state, 2, reserve_deceiver).is_empty(), "Grand Illusion permits its own source unit to enter Strategic Reserves")
	var reserved_cost := int(state.unit_abilities.reserves[warriors_squad].cost) + int(state.unit_abilities.reserves[deceiver_squad].cost)
	check(reserved_cost > int(state.points_limit) / 2 and state.unit_abilities.reserves[deceiver_squad].get("deep_strike", false), "The reserve clause accepts the checked points-cap exception and preserves Deep Strike setup status")
	check(int(state.unit_abilities.grand_illusion_count.get(2, 0)) == 3 and state.unit_abilities.grand_illusion_used.get(2, []).size() == 3 and state.unit_abilities.window.get("kind", "") != "strategium-command", "Grand Illusion stops at three distinct units and advances the pre-battle flow")

	state.units[deceiver].on_battlefield = true
	state.units[deceiver].wounds = 0
	state.units[deceiver].position = state.units[Geometry.alive(state, marine_squad)[0]].position + Vector2(2, 0)
	scripted_dice = [6, 5]
	var demise := DeadlyDemise.begin(state, [deceiver], Callable(self, "next_die"))
	var event: Dictionary = state.get("pending_deadly_demise", {}).get("events", [{}])[0] if not state.get("pending_deadly_demise", {}).get("events", []).is_empty() else {}
	check(demise.get("error", "").is_empty() and not demise.get("complete", true) and event.get("expression", "") == "D6" and event.get("triggered", false) and event.get("targets", []).any(func(target: Dictionary) -> bool: return int(target.get("squad", -1)) == marine_squad and int(target.get("mortal_wounds", 0)) == 5), "Deceiver Deadly Demise triggers on a 6 and resolves the source D6 mortal-wound expression")
	while not state.get("pending_deadly_demise", {}).is_empty():
		var pending: Dictionary = state.pending_deadly_demise
		if int(pending.get("packet_cursor", 0)) >= pending.get("packets", []).size(): break
		var packet: Dictionary = pending.packets[pending.packet_cursor]
		var choices_for_packet := DeadlyDemise.choices(state, int(packet.owner))
		if choices_for_packet.is_empty(): break
		var allocation := DeadlyDemise.allocate(state, int(packet.owner), choices_for_packet[0], Callable(self, "next_die"))
		check(allocation.get("error", "").is_empty(), "Deceiver Deadly Demise resolves through defender allocation")
	check(state.get("pending_deadly_demise", {}).is_empty() and state.get("last_deadly_demise", {}).get("events", [{}])[0].get("expression", "") == "D6", "The Deceiver's Deadly Demise event completes and retains its source expression")

	if failures == 0: print("Necron C’tan Shard of the Deceiver local checks: passed")
	else: print("Necron C’tan Shard of the Deceiver local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
