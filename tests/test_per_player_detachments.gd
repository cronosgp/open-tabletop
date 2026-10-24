extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const C = Prepared.Combat
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const Enhancements = preload("res://scripts/edition_11/stormlance_enhancements.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const DetachmentStratagems = C.DetachmentStratagems

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selection(entries: Array) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500, "entries": entries}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and int(unit.get("wounds", 0)) > 0 and str(unit.get("definition_id", "")).ends_with(":" + identity): return int(unit.squad)
	return -1

func find_model(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0: return model
	return -1

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No UnitActions decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current UnitActions projection."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)

func _initialize() -> void:
	var armies := {
		1: selection([
			{"definition_id": "40kdc:11e:adeptus-astartes:captain-on-bike", "models": 1, "copies": 1, "enhancement_id": Enhancements.TEMPERED_IN_BATTLE},
			{"definition_id": "40kdc:11e:adeptus-astartes:outrider-squad", "models": 3, "copies": 1, "enhancement_id": ""}
		]),
		2: selection([
			{"definition_id": "40kdc:11e:adeptus-astartes:redemptor-dreadnought", "models": 1, "copies": 1, "enhancement_id": ""}
		])
	}
	var assignments := {1: Enhancements.WRATH_OF_THE_ROCK, 2: "ironclad-champions"}
	check(Army.admit(armies[1]).error.is_empty(), "Roster admission accepts Tempered in Battle for an eligible Astartes bearer under Wrath of the Rock")
	var state := Prepared.initial_state({"manual_allocation": false, "core_stratagems": true, "unit_abilities": true, "combat_doctrines": true, "marine_detachments": assignments}, armies)
	check(not state.has("error"), "Normal prepared setup accepts separate detachment assignments: " + str(state.get("error", "")))
	if state.has("error"):
		print("Per-player detachment checks: %d failures" % (failures + 1))
		quit(1)
		return

	check(Doctrines.detachment_for(state, 1) == Enhancements.WRATH_OF_THE_ROCK and Doctrines.detachment_for(state, 2) == "ironclad-champions", "The rules state retains each player's detachment independently")
	check(state.combat_doctrines.get("detachment", "") == "", "A divergent match does not publish a misleading shared detachment")
	check(state.match_manifest.get("marine_detachments", {}) == assignments, "The immutable match manifest identifies both detachment assignments")
	check(state.saved_army_setup.get("options", {}).get("marine_detachments", {}) == assignments, "Saved army setup preserves both assignments for resume and LAN agreement")

	var captain := find_squad(state, 1, "captain-on-bike")
	var outriders := find_squad(state, 1, "outrider-squad")
	var dreadnought := find_squad(state, 2, "redemptor-dreadnought")
	check(captain > 0 and outriders > 0 and dreadnought > 0, "The three intended local catalog units materialize for their selected sides")
	check(Enhancements.active_detachment(state, Enhancements.WRATH_OF_THE_ROCK, 1) and not Enhancements.active_detachment(state, Enhancements.WRATH_OF_THE_ROCK, 2), "Wrath effects are active only for Player 1")
	check(Doctrines.enduring_vengeance(state, dreadnought) and not Doctrines.enduring_vengeance(state, captain), "Ironclad Champions effects are active only for Player 2")

	var captain_model := find_model(state, captain)
	var outrider_model := find_model(state, outriders)
	var dreadnought_model := find_model(state, dreadnought)
	state.units[captain_model].position = Vector2(5.0, 0.0)
	state.units[outrider_model].position = Vector2.ZERO
	state.units[dreadnought_model].position = Vector2(1.0, 0.0)
	check(Enhancements.tempered_in_battle_active(state, outriders), "The aura's source is validated against its owner's Wrath detachment in a real prepared match")

	state.terrain.areas = []
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.cp = {1: 3, 2: 3}
	state.phase = "fight"
	state.active = 2
	state.turn = 2
	state.unit_abilities.window = {"kind": "start", "owners": [2]}
	check(not DetachmentStratagems.choices(state, 1).any(func(choice: Dictionary) -> bool: return str(choice.get("value", "")) == DetachmentStratagems.ADAMANTINE_TERROR) and DetachmentStratagems.choices(state, 2).any(func(choice: Dictionary) -> bool: return str(choice.get("value", "")) == DetachmentStratagems.ADAMANTINE_TERROR), "Ironclad stratagem access follows the owning player's detachment")
	var terror_choice: Dictionary = {}
	for choice: Dictionary in DetachmentStratagems.choices(state, 2):
		if str(choice.get("value", "")) == DetachmentStratagems.ADAMANTINE_TERROR and int(choice.get("target", -1)) == dreadnought: terror_choice = choice
	check(not terror_choice.is_empty(), "The Ironclad player receives Adamantine Terror despite the opponent's Wrath detachment")
	if not terror_choice.is_empty():
		var terror_result: Dictionary = DetachmentStratagems.apply(state, 2, terror_choice, func() -> int: return 2)
		check(terror_result.get("error", "").is_empty(), "The per-player Ironclad stratagem resolves: " + str(terror_result.get("error", "")))
		var reroll_choice: Dictionary = {}
		for option: Dictionary in C.unit_choices(state, 1):
			if option.get("action", "") == "adamantine-terror-decision" and option.get("value", "") == "tempered-in-battle": reroll_choice = option
		check(C.UnitActions.actor(state) == 1 and C.UnitActions.pending_decision(state).get("source", "") == "unit-actions" and not reroll_choice.is_empty(), "Tempered Leadership choice is routed to its controller in the normally prepared two-detachment match")
		if not reroll_choice.is_empty():
			var decision_before_reroll := PendingDecisions.current(state, ["unit-actions"])
			var before_wrong_owner := var_to_bytes(state)
			var wrong_owner := submit_projected_choice(state, 2, reroll_choice)
			check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The Dreadnought's player cannot choose the opposing controller's Battle-shock reroll")
			var reroll_result := submit_projected_choice(state, 1, reroll_choice)
			var reroll_error := str(reroll_result.get("error", ""))
			var restored_after_reroll: Dictionary = bytes_to_var(var_to_bytes(state))
			var next_decision := PendingDecisions.current(restored_after_reroll, ["unit-actions"])
			check(decision_before_reroll.get("decision_id", "") != "" and not next_decision.is_empty() and next_decision.get("decision_id", "") != decision_before_reroll.get("decision_id", ""), "The next controller-owned result gets a fresh decision identity after serialization")
			var next_choice: Dictionary = {}
			for option: Dictionary in C.unit_choices(restored_after_reroll, 1):
				if option.get("action", "") == "adamantine-terror-decision" and option.get("value", "") == "tempered-in-battle": next_choice = option
			var next_result: Dictionary = {"error": "missing next result"}
			if not next_choice.is_empty(): next_result = submit_projected_choice(restored_after_reroll, 1, next_choice)
			var next_error := str(next_result.get("error", ""))
			var applied: Array = restored_after_reroll.get("last_adamantine_terror", [])
			check(reroll_error.is_empty() and next_error.is_empty() and applied.size() == 2 and applied.all(func(result: Dictionary) -> bool: return result.get("rerolled_from", []).size() == 2 and result.get("rolls", []) == [6, 6]) and DetachmentStratagems.adamantine_pending(restored_after_reroll).is_empty(), "The controller resolves every engaged Leadership result in sequence: err=%s next=%s results=%s pending=%s" % [reroll_error, next_error, str(applied), str(DetachmentStratagems.adamantine_pending(restored_after_reroll))])

	print("Per-player detachment checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
