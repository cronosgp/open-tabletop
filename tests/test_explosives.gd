extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const R = C.CoreReactions
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func squad(s: Dictionary, identity: String) -> int:
	for model: int in s.units:
		if C.UnitAbilities.identity(s.units[model]) == identity: return s.units[model].squad
	return -1
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, F.selections())
	s.awakened_dynasty.pending = []
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.deployment.complete = true
	s.mission.stage = "battle"
	s.phase = "shooting"
	s.active = 1
	s.round = 2
	s.turn = 3
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.window = {}
	s.cp = {1: 3, 2: 3}
	s.terrain.areas = []
	var source := squad(s, "intercessor-squad")
	var target := squad(s, "necron-warriors")
	for model: int in s.units:
		s.units[model].position = Vector2(-25, -20) if s.units[model].owner == 1 else Vector2(25, 20)
	for model: int in C.living(s, source): s.units[model].position = Vector2.ZERO
	for model: int in C.living(s, target): s.units[model].position = Vector2(7, 0)
	return s
func throw_choice(s: Dictionary) -> Dictionary:
	for item: Dictionary in C.unit_choices(s, 1):
		if item.action == "explosives" and s.units[item.model].squad == squad(s, "intercessor-squad") and item.target == squad(s, "necron-warriors"): return item
	return {}
func use(s: Dictionary, item: Dictionary, player: int, roller: Callable, revision: int = -2147483648) -> String:
	var decision := PendingDecisions.current(s, ["unit-actions"])
	var payload: Dictionary = item
	if not decision.is_empty():
		var projected: Dictionary = {}
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) == str(item.get("action", "")) and int(option.get("model", -1)) == int(item.get("model", -1)) and int(option.get("target", -1)) == int(item.get("target", -1)) and str(option.get("value", "")) == str(item.get("value", "")):
				projected = option
				break
		if projected.is_empty(): return "The current decision does not project the submitted Explosives choice."
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": item}
	return str(MatchCommands.execute(s, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(s.revision) if revision == -2147483648 else revision, "choice": payload}, roller).get("error", ""))
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	var source := squad(s, "intercessor-squad")
	var target := squad(s, "necron-warriors")
	check(C.Capabilities.enabled(s, "explosives") and not throw_choice(s).is_empty(), "Current Marine keyword enables Explosives")
	for flag in ["shot", "advanced", "battle_shocked"]:
		var blocked := fixture()
		blocked.squads[source][flag] = true
		check(throw_choice(blocked).is_empty(), "Explosives blocks " + flag)
	var blocked := fixture()
	blocked.cp[1] = 0
	check(throw_choice(blocked).is_empty(), "Explosives requires CP")
	blocked = fixture()
	blocked.active = 2
	check(throw_choice(blocked).is_empty(), "Explosives is unavailable in the opponent turn")
	blocked = fixture()
	for id: int in C.living(blocked, source): blocked.units[id].keywords.erase("EXPLOSIVES")
	check(throw_choice(blocked).is_empty(), "A unit without a living eligible throwing model cannot use Explosives")
	blocked.units[C.living(blocked, source)[0]].keywords.append("GRENADES")
	check(not throw_choice(blocked).is_empty(), "GRENADES keyword is the same accepted throwing keyword")
	var wrong_model: int = C.living(blocked, source)[1]
	check(not R.error(blocked, 1, source, R.EXPLOSIVES, wrong_model).is_empty(), "The throwing model cannot inherit another model's Explosives keyword")
	blocked = fixture()
	blocked.terrain = {"id": "legacy-solid-v1", "areas": [{"bounds": Rect2(3, -10, 1, 20)}]}
	check(throw_choice(blocked).is_empty(), "A visibility blocker prevents Explosives even inside 8 inches")
	blocked = fixture()
	blocked.squads[source].started_action_turn = blocked.turn
	check(not throw_choice(blocked).is_empty(), "Tactical Mainstay preserves shooting eligibility for Explosives during an action")
	var heavy := squad(blocked, "heavy-intercessor-squad")
	blocked.squads[heavy].started_action_turn = blocked.turn
	check(not R.error(blocked, 1, heavy, R.EXPLOSIVES, C.living(blocked, heavy)[0]).is_empty(), "An action blocks a unit without Tactical Mainstay")
	blocked = fixture()
	for id: int in C.living(blocked, target): blocked.units[id].position = Vector2(1, 0)
	check(throw_choice(blocked).is_empty(), "Engaged source and enemy units cannot use or receive Explosives")
	blocked = fixture()
	var nearby_friend := squad(blocked, "heavy-intercessor-squad")
	for id: int in C.living(blocked, nearby_friend): blocked.units[id].position = Vector2(8, 0)
	check(throw_choice(blocked).is_empty(), "Enemy engaged with another friendly unit is ineligible")
	blocked = fixture()
	blocked.squads[source].fell_back = true
	check(throw_choice(blocked).is_empty(), "Fall Back blocks shooting eligibility without an exception")
	blocked.unit_abilities.doctrines[source] = {"doctrine": "tactical"}
	check(not throw_choice(blocked).is_empty(), "Tactical Doctrine restores shooting eligibility after Fall Back")
	blocked = fixture()
	blocked.stratagems.uses.append({"player": 1, "squad": source, "stratagem": "grenades", "phase_key": R.phase_key(blocked), "turn": blocked.turn})
	check(throw_choice(blocked).is_empty(), "Grenades alias shares the per-phase use cap")
	blocked = fixture()
	blocked.stratagems.uses.append({"player": 1, "squad": source, "stratagem": "other", "phase_key": R.phase_key(blocked), "turn": blocked.turn})
	check(throw_choice(blocked).is_empty(), "Unit cannot receive another stratagem this phase")
	var item := throw_choice(s)
	if item.is_empty():
		check(false, "Explosives choice required for remaining integration checks")
		quit(1)
		return
	var model: int = item.model
	var enemy: int = C.living(s, target)[0]
	var edge: float = 8.0 + s.units[model].radius + s.units[enemy].radius
	for id: int in C.living(s, target): s.units[id].position = Vector2(edge, 0)
	check(R.explosives_target(s, model, target), "Exactly 8 inches between bases is legal")
	for id: int in C.living(s, target): s.units[id].position.x += 0.01
	check(not R.explosives_target(s, model, target), "Beyond 8 inches is rejected")
	s = fixture()
	item = throw_choice(s)
	var before := s.duplicate(true)
	check(not use(s, item, 1, func() -> int: return 7).is_empty() and s == before, "Invalid dice reject atomically without CP or state changes")
	check(not use(s, item, 1, func() -> int: return 6, s.revision - 1).is_empty() and s == before, "Stale revision rejects without mutation through the match command")
	var dice := [1, 2, 3, 4, 5, 6]
	check(use(s, item, 1, func() -> int: return dice.pop_front()).is_empty(), "Host resolves six Explosives dice")
	check(dice.is_empty() and s.last_explosives.mortal_wounds == 3 and s.cp[1] == 2 and not s.squads[source].shot, "4+ causes mortals, costs 1 CP, retains normal shooting")
	check(C.actor(s) == 2 and C.unit_choices(s, 1).is_empty(), "Defender owns mandatory mortal allocation")
	var allocation_decision := PendingDecisions.current(s, ["unit-actions"])
	check(allocation_decision.get("priority_player_id", -1) == 2 and allocation_decision.get("legal_options", []).size() == C.unit_choices(s, 2).size(), "Explosives allocation is exposed as the defender's normalized decision")
	check(not C.advance_phase(s, 1, s.revision).is_empty(), "Cannot advance while mortals are pending")
	# Round-trip the same serialization mechanism used by saved match state.
	s = bytes_to_var(var_to_bytes(s))
	var restored_allocation_decision := PendingDecisions.current(s, ["unit-actions"])
	check(restored_allocation_decision.get("decision_id", "") == allocation_decision.get("decision_id", ""), "Explosives allocation decision identity survives save/restore")
	var allocations := C.unit_choices(s, 2)
	var recipient: int = allocations[0].model
	s.units[recipient].feel_no_pain = [{"target": 5, "against": "mortal"}]
	var before_wrong_owner := var_to_bytes(s)
	check(not use(s, allocations[0], 1, func() -> int: return 6).is_empty() and var_to_bytes(s) == before_wrong_owner, "The attacker cannot submit or mutate the defender's allocation")
	check(use(s, allocations[0], 2, func() -> int: return 6).is_empty() and s.units[recipient].wounds == s.units[recipient].max_wounds, "Feel No Pain prevents a mortal without an armour save")
	while C.actor(s) == 2:
		var available := C.unit_choices(s, 2)
		check(not available.is_empty(), "Allocation remains available after save/resume")
		if available.is_empty(): break
		check(use(s, available[0], 2, func() -> int: return 1).is_empty(), "Remaining mortal allocated")
	check(s.last_explosives.allocations.size() == 3 and C.actor(s) == 1 and throw_choice(s).is_empty(), "All mortals resolve and Explosives cannot repeat this phase")
	s = fixture()
	var living := C.living(s, target)
	# A wounded Character does not take priority over healthy bodyguards.
	s.units[living[0]].keywords.append("CHARACTER")
	s.units[living[0]].max_wounds = 3
	s.units[living[0]].wounds = 1
	s.units[living[1]].max_wounds = 3
	s.units[living[1]].wounds = 2
	check(use(s, throw_choice(s), 1, func() -> int: return 6).is_empty(), "Mortal allocation fixture starts")
	var recipients := C.unit_choices(s, 2)
	check(recipients.size() == 1 and recipients[0].model == living[1], "Wounded non-Character must receive mortals before Character or healthy models")
	check(use(s, recipients[0], 2, Callable()).is_empty() and C.unit_choices(s, 2)[0].model == living[1], "Mortal damage stays on a wounded bodyguard until it is destroyed")
	s = fixture()
	check(use(s, throw_choice(s), 1, func() -> int: return 1).is_empty() and C.actor(s) == 1 and s.unit_abilities.window.is_empty(), "Zero successes spend CP without opening an allocation window")
	s = fixture()
	living = C.living(s, target)
	for id: int in living:
		if id != living[0]: s.units[id].wounds = 0
	s.units[living[0]].wounds = 1
	check(use(s, throw_choice(s), 1, func() -> int: return 6).is_empty(), "Six mortals can target one surviving model")
	check(use(s, C.unit_choices(s, 2)[0], 2, Callable()).is_empty() and s.last_explosives.discarded == 5 and C.actor(s) == 1, "Excess mortals are discarded when the unit is destroyed")
	print("Explosives checks: %d failures" % failures)
	quit(1 if failures else 0)
