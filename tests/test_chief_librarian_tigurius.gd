extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const Groups = preload("res://scripts/edition_11/defender_groups.gd")
const Abilities = preload("res://scripts/edition_11/unit_abilities.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")

var failures := 0
var dice_queue: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func queued_die() -> int:
	return dice_queue.pop_front() if not dice_queue.is_empty() else 6

func entry(identity: String, models: int = 1) -> Dictionary:
	return {"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": models, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var alive := Geometry.alive(state, squad)
		if not alive.is_empty() and Abilities.identity(state.units[alive[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and Abilities.identity(state.units[model]) == identity: return model
	return -1

func action(state: Dictionary, action_id: String, value: String = "", target: int = -1, player: int = 1) -> Dictionary:
	for option: Dictionary in C.UnitActions.choices(state, player):
		if option.action == action_id and (value.is_empty() or option.value == value) and (target < 0 or option.target == target): return option
	return {}

func submit_action(state: Dictionary, player: int, action_id: String, target: int, value: String = "", model: int = -1) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target and str(option.get("value", "")) == value and (model < 0 or int(option.get("model", -1)) == model):
			projected = option
			break
	var choice_owner := int(decision.get("priority_player_id", player))
	var selected: Dictionary = {}
	for option: Dictionary in C.UnitActions.choices(state, choice_owner):
		if str(option.get("action", "")) == action_id and int(option.get("target", -1)) == target and str(option.get("value", "")) == value and (model < 0 or int(option.get("model", -1)) == model):
			selected = option
			break
	if selected.is_empty(): return {"error": "UnitActions no longer offers %s for target %d." % [action_id, target]}
	var payload: Dictionary = selected
	if not projected.is_empty():
		payload = {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "choice": payload}, Callable(self, "queued_die"))

func make_state() -> Dictionary:
	var lists := F.selections()
	lists[1].entries = [entry("captain"), entry("intercessor-squad", 5), entry("infernus-squad", 5), entry("bladeguard-veteran-squad", 3), entry("heavy-intercessor-squad", 5)]
	lists[2].entries = [
		{"definition_id": "40kdc:11e:necrons:immortals", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	if state.has("error"): return state
	var model := find_model(state, 1, "captain")
	var profile := Profiles.profile("chief-librarian-tigurius")
	state.units[model].definition_id = "40kdc:11e:adeptus-astartes:chief-librarian-tigurius"
	state.units[model].keywords = profile.keywords.duplicate()
	state.units[model].ranged_weapons = profile.ranged.duplicate(true)
	state.units[model].melee_weapons = profile.melee.duplicate(true)
	state.units[model].invulnerable_target = profile.stats.invulnerable_target
	state.units[model].wounds = profile.stats.wounds
	state.units[model].max_wounds = profile.stats.wounds
	Abilities.enable(state)
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = []
	var guard := find_squad(state, 1, "intercessor-squad")
	if guard >= 0: C.UnitActions.attach(state, model, guard)
	state.mission.stage = "battle"
	return state

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("chief-librarian-tigurius")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000001611" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Tigurius profile identifies the exact local Wahapedia shared-book datasheet")
	check(profile.points == 115 and profile.models == 1 and profile.base_size_source_mm == 40 and profile.stats == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 5, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Tigurius source points, base and characteristics match")
	check(profile.keywords == ["INFANTRY", "TACTICUS", "PSYKER", "EXPLOSIVES", "EPIC HERO", "CHARACTER", "ADEPTUS ASTARTES", "ULTRAMARINES"], "Tigurius preserves only the source-exported non-faction and faction keywords")
	check(profile.ranged[0].profiles.standard.keywords == {"close-quarters": true} and profile.ranged[1].profiles.standard.attacks == "D3+6" and profile.ranged[1].profiles.standard.keywords == {"psychic": true, "blast": 1}, "Bolt Pistol and Storm of the Emperor's Wrath preserve extracted weapon traits")
	check(profile.melee[0].profiles.standard.attacks == 5 and profile.melee[0].profiles.standard.strength == 7 and profile.melee[0].profiles.standard.keywords == {"psychic": true}, "Rod of Tigurius matches the local export")
	var state := make_state()
	check(not state.has("error"), "Tigurius fixture materializes from local profiles")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var model := find_model(state, 1, "chief-librarian-tigurius")
	var squad: int = state.units[model].squad
	var intercessors := find_squad(state, 1, "intercessor-squad")
	var infernus := find_squad(state, 1, "infernus-squad")
	var bladeguard := find_squad(state, 1, "bladeguard-veteran-squad")
	var heavy_intercessors := find_squad(state, 1, "heavy-intercessor-squad")
	var immortals := find_squad(state, 2, "immortals")
	var warriors := find_squad(state, 2, "necron-warriors")
	check(Abilities.has(state, squad, "librarius") and Abilities.has(state, squad, "hood-of-hellfire") and Abilities.has(state, squad, "transhuman-strategist"), "Tigurius grants Hood of Hellfire, Librarius and Warlord rule")
	check(Prevention.rules(state, model).has({"target": 4, "against": "psychic"}) and Prevention.rules(state, model).has({"target": 4, "against": "mortal"}), "Hood of Hellfire grants Feel No Pain 4+ against Psychic and mortal damage")
	var attached_bodyguards: Array[int] = Geometry.alive(state, squad).filter(func(bodyguard: int) -> bool: return bodyguard != model)
	check(not attached_bodyguards.is_empty() and Prevention.rules(state, attached_bodyguards[0]).has({"target": 4, "against": "psychic"}) and Prevention.rules(state, attached_bodyguards[0]).has({"target": 4, "against": "mortal"}), "Hood of Hellfire protection extends to Tigurius's attached bodyguards")
	dice_queue = [4, 4]
	var psychic_fnp := C.Attacks.Prevention.resolve(1, 5, Prevention.rules(state, model), "normal", queued_die, "psychic")
	var mortal_fnp := C.Attacks.Prevention.resolve(1, 5, Prevention.rules(state, model), "mortal", queued_die)
	check(psychic_fnp.lost == 0 and mortal_fnp.lost == 0, "Hood of Hellfire prevents Psychic and mortal damage on Feel No Pain rolls of 4+")
	check(infernus >= 0 and bladeguard >= 0 and C.UnitActions.attachment_allowed(state, model, infernus) and C.UnitActions.attachment_allowed(state, model, bladeguard), "Tigurius may lead exact source-listed bodyguard units represented in this fixture")
	check(not C.UnitActions.attachment_allowed(state, model, heavy_intercessors), "Tigurius cannot attach to an unlisted Heavy Intercessor Squad")
	var can_be_warlord := false
	for option: Dictionary in C.UnitActions.choices(state, 1):
		if option.action == "warlord" and option.model == model: can_be_warlord = true
	check(can_be_warlord, "Tigurius is eligible to be declared Warlord")
	var warlord_choice := action(state, "warlord", "", model)
	if not warlord_choice.is_empty():
		var before_wrong_warlord_owner := var_to_bytes(state)
		var wrong_warlord_owner := submit_action(state, 2, "warlord", -1, "", model)
		check(not str(wrong_warlord_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_warlord_owner, "The opponent cannot submit or mutate Tigurius's Warlord choice")
		var warlord_result := submit_action(state, 1, "warlord", -1, "", model)
		check(str(warlord_result.get("error", "")).is_empty(), "Tigurius can be recorded as Warlord through the public command")
		var cp_before: int = state.cp[1]
		state.first_player = 1
		C.UnitActions.start_round(state)
		check(state.cp[1] == cp_before + 1, "Transhuman Strategist grants 1 CP when Tigurius is Warlord")
	state.phase = "movement"
	state.active = 1
	state.turn = 1
	state.round = 1
	var prescience := action(state, "tigurius-psychic", "prescience", squad)
	check(not prescience.is_empty(), "Prescience is offered in the Movement phase")
	dice_queue = [4]
	if not prescience.is_empty():
		var before_wrong_prescience_owner := var_to_bytes(state)
		var wrong_prescience_owner := submit_action(state, 2, "tigurius-psychic", squad, "prescience", model)
		check(not str(wrong_prescience_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_prescience_owner, "The opponent cannot submit or mutate Tigurius's Prescience choice")
		var prescience_result := submit_action(state, 1, "tigurius-psychic", squad, "prescience", model)
		check(str(prescience_result.get("error", "")).is_empty(), "Prescience resolves its psychic test through the common match command")
	check(Abilities.save_bonus(state, squad, Callable(C.Morale, "objective_control")) == 1 and not state.squads[squad].battle_shocked, "Successful Prescience grants +1 to saves")
	state.turn = 2
	Abilities.start_command(state)
	check(Abilities.save_bonus(state, squad, Callable(C.Morale, "objective_control")) == 1, "Prescience lasts through the opponent's turn")
	state.turn = 3
	Abilities.start_command(state)
	check(Abilities.save_bonus(state, squad, Callable(C.Morale, "objective_control")) == 0, "Prescience expires at the start of Tigurius's next turn")
	state.phase = "shooting"
	state.active = 1
	var telepathic := action(state, "tigurius-psychic", "telepathic-assault", immortals)
	check(not telepathic.is_empty(), "Telepathic Assault is offered against a visible enemy in 24 inches")
	dice_queue = [1, 4, 2]
	if not telepathic.is_empty():
		var psychic_result := submit_action(state, 1, "tigurius-psychic", immortals, "telepathic-assault", model)
		check(str(psychic_result.get("error", "")).is_empty(), "Telepathic Assault resolves through the common match command")
	check(state.squads[squad].battle_shocked, "A psychic roll of 1 makes Tigurius's unit Battle-shocked")
	check(state.unit_abilities.get("window", {}).get("kind", "") == C.CoreReactions.TIGURIUS_MORTAL and state.get("last_tigurius_telepathic_assault", {}).get("mortal_wounds", 0) == 3, "Telepathic Assault inflicts 2D3 mortal wounds and opens normal allocation")
	var mortal_decision := PendingDecisions.current(state, ["unit-actions"])
	check(mortal_decision.get("source", "") == "unit-actions" and mortal_decision.get("priority_player_id", -1) == 2 and mortal_decision.get("legal_options", []).size() > 0, "The defending player receives a normalized mortal-wound allocation decision")
	check(not PhaseCloseGate.close_request_error(state, 1, state.revision).is_empty(), "Shooting close remains blocked while Telepathic Assault has mortal wounds to allocate")
	var restored_mortal_state: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_mortal_decision := PendingDecisions.current(restored_mortal_state, ["unit-actions"])
	check(restored_mortal_decision.get("decision_id", "") == mortal_decision.get("decision_id", ""), "Telepathic Assault allocation retains its normalized decision identity through save/restore")
	state = restored_mortal_state
	var first_mortal_model := int(mortal_decision.legal_options[0].model)
	var before_wrong_mortal_owner := var_to_bytes(state)
	var wrong_mortal_owner := submit_action(state, 1, "mortal-allocate", immortals, C.CoreReactions.TIGURIUS_MORTAL, first_mortal_model)
	check(not str(wrong_mortal_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_mortal_owner, "The attacker cannot submit or mutate the defender's mortal allocation")
	var mortal_allocations_ok := true
	for allocation_index in range(3):
		var current_decision := PendingDecisions.current(state, ["unit-actions"])
		var available: Array = current_decision.get("legal_options", [])
		if available.is_empty():
			mortal_allocations_ok = false
			break
		var model_to_wound := int(available[0].model)
		dice_queue = [4]
		var allocation_result := submit_action(state, 2, "mortal-allocate", immortals, C.CoreReactions.TIGURIUS_MORTAL, model_to_wound)
		if not str(allocation_result.get("error", "")).is_empty():
			mortal_allocations_ok = false
			break
	check(mortal_allocations_ok and state.last_tigurius_telepathic_assault.remaining == 0 and state.last_tigurius_telepathic_assault.allocations.size() == 3 and state.unit_abilities.window.is_empty(), "All three mortal wounds resolve through defender-owned normalized choices")
	check(PhaseCloseGate.close_request_error(state, 1, state.revision).is_empty(), "Shooting close can resume after the mortal allocation packet completes")
	var simultaneous := make_state()
	var simultaneous_model := find_model(simultaneous, 1, "chief-librarian-tigurius")
	var simultaneous_squad: int = simultaneous.units[simultaneous_model].squad
	simultaneous.phase = "movement"
	simultaneous.active = 1
	simultaneous.turn = 1
	var simultaneous_prescience := action(simultaneous, "tigurius-psychic", "prescience", simultaneous_squad)
	dice_queue = [6]
	if not simultaneous_prescience.is_empty():
		var simultaneous_prescience_result := submit_action(simultaneous, 1, "tigurius-psychic", simultaneous_squad, "prescience", simultaneous_model)
		check(str(simultaneous_prescience_result.get("error", "")).is_empty(), "Prescience resolves before the Shooting phase through the common match command")
	simultaneous.phase = "shooting"
	var simultaneous_telepathic := action(simultaneous, "tigurius-psychic", "telepathic-assault", find_squad(simultaneous, 2, "immortals"))
	dice_queue = [6, 6, 6]
	if not simultaneous_telepathic.is_empty():
		var simultaneous_telepathic_result := submit_action(simultaneous, 1, "tigurius-psychic", find_squad(simultaneous, 2, "immortals"), "telepathic-assault", simultaneous_model)
		check(str(simultaneous_telepathic_result.get("error", "")).is_empty(), "Telepathic Assault remains available in the same own turn through the common match command")
	check(simultaneous.unit_abilities.used.has("tigurius-prescience:%d:1" % simultaneous_squad) and simultaneous.unit_abilities.used.has("tigurius-telepathic:%d:1" % simultaneous_squad), "Level-2 Prescience and level-1 Telepathic Assault each resolve during one turn")
	print("Chief Librarian Tigurius profile checks: %d failures" % failures)
	quit(1 if failures else 0)
