extends SceneTree
const P = preload("res://scripts/edition_11/prepared_training.gd")
const C = P.Combat
const R = C.Reanimation
const Save = preload("res://scripts/match_save.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
var failures := 0
class Dice:
	extends RefCounted
	var calls := 0
	var value := 6
	var sequence: Array[int] = []
	func roll() -> int:
		calls += 1
		if not sequence.is_empty(): return sequence.pop_front()
		return value
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func fixture(stratagems: bool = false) -> Dictionary:
	var state := C.initial_state("legacy-solid-v1", C.Objectives.TRAINING, 2, false, true)
	state.terrain.areas = []
	state.active = 2
	state.turn = 2
	for id: int in state.units:
		state.units[id].position = Vector2(-10 if state.units[id].owner == 1 else 5, -5 if id < 300 else 5) + Vector2((id % 100) / 5, (id % 5) * 1.3)
	R.enable(state)
	if stratagems: C.Stratagems.enable(state)
	C.advance_phase(state, 2, state.revision)
	return state
func decide(state: Dictionary, action: String, squad: int = 2, model: int = -1, point: Vector2 = Vector2.ZERO, roller: Callable = Callable()) -> String:
	return C.resolve_reanimation(state, 2, action, squad, model, point, state.revision, roller)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(P.initial_state().pack_hash == P.initial_state({"reanimation_protocols": false}).pack_hash, "Disabled identity remains compatible")
	check(P.initial_state().pack_hash != P.initial_state({"reanimation_protocols": true}).pack_hash and P.initial_state({"reanimation_protocols": 1}).has("error"), "Explicit boolean option freezes match identity")
	var dice := Dice.new()
	var state := fixture()
	for id in [201, 202, 203]: state.units[id].wounds = 0
	var original: Dictionary = state.units[201].duplicate(true)
	check(C.advance_phase(state, 2, state.revision, dice.roll).is_empty() and dice.calls == 0 and R.pending(state).remaining == [2, 4], "End of own Command queues every living Necron unit after morale")
	var reanimation_decision := R.pending_decision(state)
	var roll_squads: Array[int] = []
	for option: Dictionary in reanimation_decision.get("legal_options", []):
		if option.value == "roll": roll_squads.append(int(option.target))
	check(not reanimation_decision.is_empty() and int(reanimation_decision.priority_player_id) == 2 and roll_squads == [2, 4], "Reanimation projects the eligible remaining units under one decision owner")
	check(not C.advance_phase(state, 2, state.revision).is_empty() and not C.begin_movement(state, 2, 200, "normal", state.revision).is_empty(), "Mandatory window blocks unrelated commands")
	var before := var_to_bytes(state)
	var missing_decision := MatchCommands.execute(state, 2, {"kind": MatchCommands.RESOLVE_REANIMATION, "choice": {"action": "reanimation", "model": -1, "target": 2, "value": "roll"}, "point": Vector2.ZERO, "revision": state.revision}, dice.roll)
	check(not missing_decision.error.is_empty() and before == var_to_bytes(state) and dice.calls == 0, "A Reanimation projection rejects an unidentified roll without mutation or dice")
	var roll_option_id := str(reanimation_decision.legal_options[0].id)
	var invalid_decision := MatchCommands.execute(state, 2, {"kind": MatchCommands.RESOLVE_REANIMATION, "choice": {"_decision_type": MatchCommands.REANIMATION_DECISION_ENVELOPE, "decision_id": reanimation_decision.decision_id, "option_id": "invalid-option", "choice": {"action": "reanimation", "model": -1, "target": 2, "value": "roll"}}, "point": Vector2.ZERO, "revision": state.revision}, dice.roll)
	check(not invalid_decision.error.is_empty() and before == var_to_bytes(state) and dice.calls == 0, "A Reanimation projection rejects an option outside the current window")
	check(not roll_option_id.is_empty(), "Reanimation roll choices have stable option IDs")
	check(not C.resolve_reanimation(state, 1, "roll", 2, -1, Vector2.ZERO, state.revision, dice.roll).is_empty(), "Opponent cannot roll")
	check(not C.resolve_reanimation(state, 2, "roll", 2, -1, Vector2.ZERO, -1, dice.roll).is_empty(), "Stale revision rejected")
	check(not decide(state, "bogus", 2, -1, Vector2.ZERO, dice.roll).is_empty() and not decide(state, "roll", 1, -1, Vector2.ZERO, dice.roll).is_empty(), "Unknown action and foreign unit rejected before dice")
	check(before == var_to_bytes(state) and dice.calls == 0, "Invalid commands leave state and dice untouched")
	check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and dice.calls == 1 and R.pending(state).current.slots == 3, "D6 six becomes D3 three once")
	var placement_decision := R.pending_decision(state)
	var placement_models: Array[int] = []
	for option: Dictionary in placement_decision.get("legal_options", []):
		if option.value == "place": placement_models.append(int(option.model))
	check(not placement_decision.is_empty() and placement_models == [201, 202, 203], "Reanimation exposes destroyed troop placement intents while keeping coordinates rule-validated")
	check(not decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and dice.calls == 1, "Cannot reroll a pending unit")
	check(not decide(state, "confirm").is_empty(), "Cannot confirm unassigned return attempts")
	check(not decide(state, "place", 2, 201, Vector2(INF, 0)).is_empty() and not decide(state, "place", 2, 201, Vector2(16, 0)).is_empty(), "Nonfinite and off-board bases rejected")
	check(not decide(state, "place", 2, 201, state.units[200].position).is_empty(), "Base overlap rejected")
	check(not decide(state, "place", 2, 100, Vector2.ZERO).is_empty(), "Enemy model cannot return")
	check(decide(state, "suggest").is_empty() and R.pending(state).current.placements.size() == 3, "Suggestion stages valid positions")
	check(state.units[201].wounds == 0 and state.units[201].position == original.position and state.cp == {1: 1, 2: 1}, "Preview does not alter wounds, equipment, positions or CP")
	var preview := state.duplicate(true)
	check(decide(state, "reset").is_empty() and R.pending(state).current.raw_roll == 6 and dice.calls == 1, "Reset retains original roll")
	state = preview
	check(decide(state, "confirm").is_empty() and C.living(state, 2).size() == 10 and state.phase == "command", "Confirmation restores models and waits for other units")
	check(state.units[201].ranged_weapons == original.ranged_weapons and state.units[201].definition_id == original.definition_id, "Original model equipment and identity preserved")
	check(decide(state, "roll", 4, -1, Vector2.ZERO, dice.roll).is_empty() and state.phase == "movement" and dice.calls == 2 and state.cp == {1: 1, 2: 1}, "Intact unit still rolls; last activation finishes Command exactly once")
	check(R.pending(state).is_empty() and state.reanimation.last_results.size() == 2 and state.reanimation.last_results[1].discarded == 3, "Reports include unused healing")
	for raw in range(1, 7):
		state = fixture()
		state.units[201].wounds = 0
		C.advance_phase(state, 2, state.revision, dice.roll)
		dice.value = raw
		check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and R.pending(state).current.budget == ceili(raw / 2.0) and R.pending(state).current.slots == 1, "D3 conversion and starting strength cap")
		check(decide(state, "unplaceable", 2, 201).is_empty() and not decide(state, "unplaceable", 2, 201).is_empty(), "Explicit failure declaration consumes one attempt")
		check(decide(state, "confirm").is_empty() and state.units[201].wounds == 0 and R.pending(state).results[0].unplaced == [201], "Unplaceable model remains destroyed and report records declaration")
	dice.value = 6
	state = fixture()
	for id in range(201, 210): state.units[id].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll)
	check(decide(state, "place", 2, 201, state.units[200].position + Vector2(2.5, 0)).is_empty(), "Legal return anchored to phase-entry survivor")
	check(not decide(state, "place", 2, 202, state.units[200].position + Vector2(5, 0)).is_empty(), "Returned model cannot extend original anchor chain")
	state.units[100].position = state.units[200].position + Vector2(4.5, 0)
	check(not R.position_error(state, 201, state.units[200].position + Vector2(2.5, 0)).is_empty(), "Cannot create engagement with a new enemy unit")
	state.units[100].position = state.units[200].position + Vector2(2, 0)
	R.pending(state).current.engaged = [1]
	check(R.position_error(state, 201, state.units[200].position + Vector2(2.5, 1.5)).is_empty(), "Return may engage a unit already engaged before activation")
	state = fixture()
	for id in range(201, 210): state.units[id].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll)
	var destination: Vector2 = state.units[200].position + Vector2(-2, 0)
	state.terrain.areas = [{"category": "legacy", "bounds": Rect2(destination - Vector2.ONE, Vector2(2, 2)), "features": [{"bounds": Rect2(destination - Vector2(0.1, 0.1), Vector2(0.2, 0.2)), "blocks_end": true, "height": 2.0}]}]
	check(not decide(state, "place", 2, 201, destination).is_empty(), "Returned base cannot finish inside terrain")
	state.terrain.areas = [{"category": "legacy", "bounds": Rect2(4, -7, 0.2, 4), "features": [{"bounds": Rect2(4, -7, 0.2, 4), "blocks_end": true, "height": 2.0}]}]
	check(decide(state, "place", 2, 201, destination).is_empty(), "Setup does not require traversing a movement path from corpse position")
	state.terrain.areas = []
	state.units[209].wounds = 1
	state.units[209].position = Vector2(-9, -5)
	check(not R.position_error(state, 201, destination).is_empty(), "Return must be within 9 inches of every living unit member")
	state = fixture()
	for id: int in C.living(state, 2): state.units[id].definition_id = "40kdc:11e:necrons:immortals"
	state.units[201].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and decide(state, "suggest").is_empty() and decide(state, "confirm").is_empty() and state.units[201].wounds == 1, "Pure Immortals use the same one-wound return flow")
	state = fixture()
	for id in range(203, 210): state.units.erase(id)
	for model: int in [200, 201, 202]:
		state.units[model].definition_id = "40kdc:11e:necrons:skorpekh-destroyers"
		state.units[model].max_wounds = 3
		state.units[model].radius = 25.0 / 25.4
		state.units[model].position = Vector2(5.0 + float(model - 200) * 2.1, 1.0)
		state.units[model].wounds = 3
	state.units[200].wounds = 1
	state.units[202].wounds = 0
	state.squads[2].starting_strength = 3
	R.start_command(state)
	check(R.supported_unit(state, 2), "A Skorpekh unit with one wounded survivor is admitted for multi-wound Reanimation")
	C.advance_phase(state, 2, state.revision, dice.roll)
	dice.value = 6
	check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and R.pending(state).current.healed == {200: 2} and R.pending(state).current.slots == 1, "Skorpekh Reanimation heals its wounded survivor before returning a model")
	check(decide(state, "suggest").is_empty() and decide(state, "confirm").is_empty() and state.units[200].wounds == 3 and state.units[202].wounds == 1, "Multi-wound Reanimation restores the survivor and returns one Skorpekh at one wound")
	var scarab_state := fixture()
	for id in range(203, 210): scarab_state.units.erase(id)
	for model: int in [200, 201, 202]:
		scarab_state.units[model].definition_id = "40kdc:11e:necrons:canoptek-scarab-swarms"
		scarab_state.units[model].max_wounds = 4
		scarab_state.units[model].radius = 20.0 / 25.4
		scarab_state.units[model].wounds = 4
	scarab_state.squads[2].starting_strength = 3
	check(R.supported_unit(scarab_state, 2), "Four-wound Scarab Swarms are admitted by the expanded wound-profile gate")
	scarab_state.units[200].wounds = 3
	scarab_state.units[201].wounds = 2
	check(not R.supported_unit(scarab_state, 2), "Multiple wounded survivors remain blocked until healing allocation choices are modeled")
	var additional_wound_profiles := {
		"40kdc:11e:necrons:canoptek-wraiths": 4,
		"40kdc:11e:necrons:lokhust-destroyers": 3,
		"40kdc:11e:necrons:lokhust-heavy-destroyers": 4,
		"40kdc:11e:necrons:ghost-ark": 14,
		"40kdc:11e:necrons:canoptek-doomstalker": 12,
		"40kdc:11e:necrons:doomsday-ark": 14,
		"40kdc:11e:necrons:monolith": 22,
		"40kdc:11e:necrons:catacomb-command-barge": 9,
		"40kdc:11e:necrons:triarch-stalker": 12,
		"40kdc:11e:necrons:hexmark-destroyer": 5,
		"40kdc:11e:necrons:ophydian-destroyers": 3,
		"40kdc:11e:necrons:annihilation-barge": 9,
		"40kdc:11e:necrons:canoptek-macrocytes": 1,
		"40kdc:11e:necrons:canoptek-reanimator": 6,
		"40kdc:11e:necrons:canoptek-spyders": 6,
		"40kdc:11e:necrons:canoptek-tomb-crawlers": 3,
		"40kdc:11e:necrons:doom-scythe": 12,
		"40kdc:11e:necrons:convergence-of-dominion": 7,
		"40kdc:11e:necrons:cryptothralls": 3,
		"40kdc:11e:necrons:night-scythe": 12,
		"40kdc:11e:necrons:obelisk": 24,
		"40kdc:11e:necrons:tesseract-vault": 24,
		"40kdc:11e:necrons:tomb-blades": 2,
		"40kdc:11e:necrons:ctan-shard-of-the-deceiver": 16,
		"40kdc:11e:necrons:ctan-shard-of-the-nightbringer": 16,
		"40kdc:11e:necrons:ctan-shard-of-the-void-dragon": 16,
		"40kdc:11e:necrons:geomancer": 4,
		"40kdc:11e:necrons:nekrosor-ammentar": 9,
		"40kdc:11e:necrons:overlord-with-translocation-shroud": 6,
		"40kdc:11e:necrons:transcendent-ctan": 16,
	}
	var profile_model_counts := {
		"40kdc:11e:necrons:canoptek-wraiths": 3,
		"40kdc:11e:necrons:lokhust-destroyers": 1,
		"40kdc:11e:necrons:lokhust-heavy-destroyers": 1,
		"40kdc:11e:necrons:ghost-ark": 1,
		"40kdc:11e:necrons:canoptek-doomstalker": 1,
		"40kdc:11e:necrons:doomsday-ark": 1,
		"40kdc:11e:necrons:monolith": 1,
		"40kdc:11e:necrons:catacomb-command-barge": 1,
		"40kdc:11e:necrons:triarch-stalker": 1,
		"40kdc:11e:necrons:hexmark-destroyer": 1,
		"40kdc:11e:necrons:ophydian-destroyers": 3,
		"40kdc:11e:necrons:annihilation-barge": 1,
		"40kdc:11e:necrons:canoptek-macrocytes": 5,
		"40kdc:11e:necrons:canoptek-reanimator": 1,
		"40kdc:11e:necrons:canoptek-spyders": 1,
		"40kdc:11e:necrons:canoptek-tomb-crawlers": 2,
		"40kdc:11e:necrons:doom-scythe": 1,
		"40kdc:11e:necrons:convergence-of-dominion": 1,
		"40kdc:11e:necrons:cryptothralls": 2,
		"40kdc:11e:necrons:night-scythe": 1,
		"40kdc:11e:necrons:obelisk": 1,
		"40kdc:11e:necrons:tesseract-vault": 1,
		"40kdc:11e:necrons:tomb-blades": 3,
		"40kdc:11e:necrons:ctan-shard-of-the-deceiver": 1,
		"40kdc:11e:necrons:ctan-shard-of-the-nightbringer": 1,
		"40kdc:11e:necrons:ctan-shard-of-the-void-dragon": 1,
		"40kdc:11e:necrons:geomancer": 1,
		"40kdc:11e:necrons:nekrosor-ammentar": 1,
		"40kdc:11e:necrons:overlord-with-translocation-shroud": 1,
		"40kdc:11e:necrons:transcendent-ctan": 1,
	}
	var exact_profile_sizes := {
		"40kdc:11e:necrons:annihilation-barge": [1], "40kdc:11e:necrons:canoptek-macrocytes": [5],
		"40kdc:11e:necrons:canoptek-spyders": [1, 2], "40kdc:11e:necrons:canoptek-tomb-crawlers": [2],
		"40kdc:11e:necrons:canoptek-reanimator": [1],
		"40kdc:11e:necrons:doom-scythe": [1], "40kdc:11e:necrons:convergence-of-dominion": [1, 2, 3],
		"40kdc:11e:necrons:cryptothralls": [2], "40kdc:11e:necrons:night-scythe": [1],
		"40kdc:11e:necrons:obelisk": [1], "40kdc:11e:necrons:tesseract-vault": [1],
		"40kdc:11e:necrons:tomb-blades": [3, 6],
		"40kdc:11e:necrons:ctan-shard-of-the-deceiver": [1], "40kdc:11e:necrons:ctan-shard-of-the-nightbringer": [1],
		"40kdc:11e:necrons:ctan-shard-of-the-void-dragon": [1], "40kdc:11e:necrons:geomancer": [1],
		"40kdc:11e:necrons:nekrosor-ammentar": [1], "40kdc:11e:necrons:overlord-with-translocation-shroud": [1],
		"40kdc:11e:necrons:transcendent-ctan": [1],
	}
	for identity: String in additional_wound_profiles:
		var profile_state := fixture()
		for model: int in profile_state.units.keys():
			if profile_state.units[model].squad != 2: continue
			if model >= 200 + int(profile_model_counts[identity]): profile_state.units.erase(model)
		for offset in range(int(profile_model_counts[identity])):
			var model := 200 + offset
			profile_state.units[model].definition_id = identity
			profile_state.units[model].max_wounds = int(additional_wound_profiles[identity])
			profile_state.units[model].wounds = int(additional_wound_profiles[identity])
		profile_state.squads[2].starting_strength = int(profile_model_counts[identity])
		check(R.supported_unit(profile_state, 2), "Reanimation recognizes local singleton or multi-wound profile %s" % identity.get_slice(":", 3))
		if exact_profile_sizes.has(identity):
			check(R.PROFILE_MODEL_COUNTS.get(identity, []) == exact_profile_sizes[identity], "Reanimation uses every source-listed size for %s" % identity.get_slice(":", 3))
		if R.CHARACTER_WOUNDS.has(identity):
			for model: int in profile_state.units:
				if profile_state.units[model].squad == 2: profile_state.units[model].wounds = 0
			check(R.returnable(profile_state).is_empty(), "Destroyed Character %s heals only and cannot return" % identity.get_slice(":", 3))
	var aura_state := fixture()
	for model: int in range(201, 204): aura_state.units[model].wounds = 0
	for model: int in range(402, 410): aura_state.units.erase(model)
	aura_state.squads[4].starting_strength = 1
	for model: int in [400, 401]:
		aura_state.units[model].definition_id = "40kdc:11e:necrons:canoptek-reanimator"
		aura_state.units[model].max_wounds = 6
		aura_state.units[model].wounds = 6
		aura_state.units[model].radius = 30.0 / 25.4
		aura_state.units[model].position = aura_state.units[200].position + Vector2(2.0, 0.0)
	aura_state.squads[5] = aura_state.squads[4].duplicate(true)
	aura_state.squads[5].name = "Second Canoptek Reanimator"
	aura_state.squads[5].starting_strength = 1
	aura_state.units[401].squad = 5
	var aura_dice := Dice.new()
	aura_dice.sequence = [1, 6, 1, 6]
	check(R.supported_unit(aura_state, 4) and R.supported_unit(aura_state, 5), "Canoptek Reanimator is admitted as its source-listed one-model, six-wound profile")
	check(R.nanoscarab_aura_applies(aura_state, 2) and R.nanoscarab_aura_applies(aura_state, 4), "Nanoscarab reaches a friendly unit in range and the source is in its own Aura")
	check(C.advance_phase(aura_state, 2, aura_state.revision, aura_dice.roll).is_empty() and R.pending(aura_state).remaining == [2, 4, 5], "Reanimator units join the eligible Reanimation queue")
	check(decide(aura_state, "roll", 2, -1, Vector2.ZERO, aura_dice.roll).is_empty() and aura_dice.calls == 2 and R.pending(aura_state).current.budget == 4 and R.pending(aura_state).current.nanoscarab_bonus == 3 and R.pending(aura_state).current.slots == 3, "Two nearby Reanimators add only one D3 to a Necron unit's Reanimation")
	for model: int in [201, 202, 203]: check(decide(aura_state, "unplaceable", 2, model).is_empty(), "Aura test consumes the return choice for model %d" % model)
	check(decide(aura_state, "confirm").is_empty(), "Aura-enhanced Warrior Reanimation confirms")
	check(decide(aura_state, "roll", 4, -1, Vector2.ZERO, aura_dice.roll).is_empty() and aura_dice.calls == 4 and aura_dice.value == 6, "Reanimator's own Reanimation receives one self-Aura D3")
	var distant_aura_state := fixture()
	for model: int in range(401, 410): distant_aura_state.units.erase(model)
	distant_aura_state.squads[4].starting_strength = 1
	distant_aura_state.units[400].definition_id = "40kdc:11e:necrons:canoptek-reanimator"
	distant_aura_state.units[400].max_wounds = 6
	distant_aura_state.units[400].wounds = 6
	distant_aura_state.units[400].radius = 30.0 / 25.4
	distant_aura_state.units[400].position = distant_aura_state.units[200].position + Vector2(8.0, 0.0)
	distant_aura_state.units[201].wounds = 0
	check(not R.nanoscarab_aura_applies(distant_aura_state, 2), "Nanoscarab does not affect a friendly unit outside 3 inches")
	var distant_dice := Dice.new()
	distant_dice.value = 6
	C.advance_phase(distant_aura_state, 2, distant_aura_state.revision, distant_dice.roll)
	check(decide(distant_aura_state, "roll", 2, -1, Vector2.ZERO, distant_dice.roll).is_empty() and distant_dice.calls == 1 and R.pending(distant_aura_state).current.budget == 3, "An out-of-range unit rolls only its normal D3")
	var multiple_vehicles := fixture()
	for model: int in multiple_vehicles.units.keys():
		if multiple_vehicles.units[model].squad != 2: continue
		if model > 201: multiple_vehicles.units.erase(model)
		else:
			multiple_vehicles.units[model].definition_id = "40kdc:11e:necrons:ghost-ark"
			multiple_vehicles.units[model].max_wounds = 14
			multiple_vehicles.units[model].wounds = 14
	multiple_vehicles.squads[2].starting_strength = 2
	check(not R.supported_unit(multiple_vehicles, 2), "Singleton vehicle datasheets remain blocked when incorrectly grouped as multiple models")
	var undersized_ophydians := fixture()
	for model: int in undersized_ophydians.units.keys():
		if undersized_ophydians.units[model].squad != 2: continue
		if model > 201: undersized_ophydians.units.erase(model)
		else:
			undersized_ophydians.units[model].definition_id = "40kdc:11e:necrons:ophydian-destroyers"
			undersized_ophydians.units[model].max_wounds = 3
			undersized_ophydians.units[model].wounds = 3
	undersized_ophydians.squads[2].starting_strength = 2
	check(not R.supported_unit(undersized_ophydians, 2), "Ophydian Reanimation rejects a model count absent from the local composition rows")
	state = fixture()
	state.units[201].wounds = 0
	C.advance_phase(state, 2, state.revision, dice.roll)
	before = var_to_bytes(state)
	dice.value = 0
	check(not decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and before == var_to_bytes(state), "Invalid D6 provider cannot partially mutate the window")
	dice.value = 6
	state = fixture()
	state.active = 1
	R.start_command(state)
	check(C.advance_phase(state, 1, state.revision).is_empty() and R.pending(state).is_empty(), "Enemy faction's Command does not activate Necron healing")
	state = fixture()
	state.squads[2].attached = true
	before = var_to_bytes(state)
	check(not C.advance_phase(state, 2, state.revision, dice.roll).is_empty() and before == var_to_bytes(state), "Unsupported attachment fails before morale or mutation")
	state = fixture()
	state.units[200].max_wounds = 2
	check(not C.advance_phase(state, 2, state.revision, dice.roll).is_empty(), "Unverified troop wound profile is blocked")
	state = fixture()
	for id: int in C.living(state, 2): state.units[id].wounds = 0
	check(C.advance_phase(state, 2, state.revision).is_empty() and R.pending(state).remaining == [4], "Destroyed unit never activates")
	state = fixture()
	state["unit_abilities"] = {"reserves": {2: {"cost": 100}}}
	check(C.advance_phase(state, 2, state.revision).is_empty() and R.pending(state).remaining == [4], "Core Reanimation skips a living unit in Reserves")
	state = fixture()
	state.squads[2].embarked_in = 999
	for model: int in C.living(state, 2):
		state.units[model].on_battlefield = false
		state.units[model].embarked_transport = 999
	check(C.advance_phase(state, 2, state.revision).is_empty() and R.pending(state).remaining == [4], "Core Reanimation skips a living unit embarked in a Transport")
	state = fixture()
	for id in range(201, 210): state.units.erase(id)
	state.units[200].definition_id = R.OVERLORD
	state.units[200].max_wounds = 6
	state.units[200].wounds = 4
	state.squads[2].starting_strength = 1
	C.advance_phase(state, 2, state.revision, dice.roll)
	check(decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll).is_empty() and state.units[200].wounds == 6 and R.pending(state).results[0].discarded == 1, "Living standalone Overlord heals without exceeding full wounds")
	state = fixture(true)
	for id in range(201, 210): state.units[id].wounds = 0
	check(C.advance_phase(state, 2, state.revision).is_empty() and not C.Stratagems.pending(state).is_empty() and R.pending(state).is_empty(), "Battle-shock decision precedes Reanimation")
	var command_morale_decision := C.Stratagems.pending_decision(state)
	var accept_morale_option: Dictionary = {}
	for option: Dictionary in command_morale_decision.get("legal_options", []):
		if int(option.get("target", -1)) == 2 and str(option.get("value", "")) == "": accept_morale_option = option
	var accept_morale_choice := {"action": "stratagem-reaction", "model": -1, "target": 2, "value": "", "die": -1}
	var accept_morale_envelope := {"_decision_type": MatchCommands.STRATAGEM_DECISION_ENVELOPE, "decision_id": str(command_morale_decision.get("decision_id", "")), "option_id": str(accept_morale_option.get("id", "")), "choice": accept_morale_choice}
	var before_wrong_morale_owner := var_to_bytes(state)
	var wrong_morale_owner := MatchCommands.execute(state, 1, {"kind": MatchCommands.COMMAND_REACTION, "choice": accept_morale_envelope, "revision": state.revision}, dice.roll)
	check(not str(wrong_morale_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_morale_owner, "The opponent cannot accept the Necron Command Battle-shock roll or mutate the pending decision")
	var morale_result := MatchCommands.execute(state, 2, {"kind": MatchCommands.COMMAND_REACTION, "choice": accept_morale_envelope, "revision": state.revision}, dice.roll)
	check(str(morale_result.get("error", "")).is_empty() and not R.pending(state).is_empty(), "Public Command reaction applies Battle-shock and resumes into Reanimation")
	var morale_calls := dice.calls
	decide(state, "roll", 2, -1, Vector2.ZERO, dice.roll)
	decide(state, "suggest")
	decide(state, "confirm")
	decide(state, "roll", 4, -1, Vector2.ZERO, dice.roll)
	check(state.phase == "movement" and dice.calls == morale_calls + 2 and not state.squads[2].battle_shocked, "Morale is not repeated after last activation")
	# Real UI, autosave and preview preservation.
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.auto_models.button_pressed = false
	game.reanimation_protocols_choice.button_pressed = true
	game._start_prepared_match()
	var isolated_save_path := "user://matches/reanimation-test-%s.save" % Time.get_ticks_usec()
	game.state = fixture()
	game.state.units[201].wounds = 0
	game._spawn_pieces()
	game._reset_history()
	game._request_end()
	check(game.action_groups.reanimation.container.visible and game.reanimation_roll.visible and game.end_button.disabled, "Mandatory window has visible focused controls")
	game._request_reanimation("roll")
	game._request_reanimation("suggest")
	check(game.pieces[201].visible and game.state.units[201].wounds == 0, "Preview renders destroyed model without changing its wounds")
	var saved_state: Dictionary = game.state.duplicate(true)
	var saved_rng: int = game.rng.state
	# fixture uses legacy pack identity; save against a genuine prepared initial state instead.
	game._start_prepared_match()
	game.state.phase = "start_turn"
	game.state.active = 2
	game.state.turn = 2
	game.state.terrain.areas = []
	game.state.units[201].wounds = 0
	C.advance_phase(game.state, 2, game.state.revision)
	game._reset_history()
	game._request_end()
	game._request_reanimation("roll")
	game._request_reanimation("suggest")
	saved_state = game.state.duplicate(true)
	saved_rng = game.rng.state
	var pending_save_error := Save.write(game.state, game._save_config(), game.rng.state, game.attack_draft, isolated_save_path, game.host_session, game.journal.checkpoint(), {}, C.MatchActor.player(game.state))
	game._load_match(false, false, Save.read(isolated_save_path))
	check(game.state == saved_state and game.rng.state == saved_rng and game.reanimation_protocols and game.pieces[201].visible, "Pending roll and placements survive save/load without reroll")
	game._start_objectives()
	var save_error := Save.write(game.state, game._save_config(), game.rng.state, game.attack_draft, isolated_save_path, game.host_session, game.journal.checkpoint(), {}, C.MatchActor.player(game.state))
	var old := Save.read(isolated_save_path)
	old.config.erase("reanimation_protocols")
	var legacy_write_error := Save.write(old.state, old.config, old.rng_state, old.attack_draft, isolated_save_path, old.session, old.journal)
	game._load_match(false, false, Save.read(isolated_save_path))
	check(not game.reanimation_protocols and not game.state.has("reanimation"), "Legacy saves default to disabled")
	old.config.reanimation_protocols = true
	var conflicting_save_error := Save.write(old.state, old.config, old.rng_state, old.attack_draft, isolated_save_path, old.session, old.journal)
	before = var_to_bytes(game.state)
	game._load_match(false, false, Save.read(isolated_save_path))
	check(pending_save_error.is_empty() and save_error.is_empty() and legacy_write_error.is_empty() and conflicting_save_error.is_empty() and before == var_to_bytes(game.state) and "Reanimation" in game.status.text, "Conflicting save flag rejected (writes=%s/%s/%s/%s; unchanged=%s; status=%s)" % [pending_save_error, save_error, legacy_write_error, conflicting_save_error, str(before == var_to_bytes(game.state)), game.status.text])
	for suffix: String in ["", ".bak", ".tmp"]:
		var temporary_file := FileAccess.open(isolated_save_path + suffix, FileAccess.READ)
		if temporary_file != null:
			temporary_file.close()
			DirAccess.remove_absolute(ProjectSettings.globalize_path(isolated_save_path + suffix))
	game.queue_free()
	await process_frame
	print("REANIMATION: %d failures" % failures)
	quit(0 if failures == 0 else 1)
