extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Combat = F.C
const UnitAbilities = preload("res://scripts/edition_11/unit_abilities.gd")
const Detach = preload("res://scripts/edition_11/detachment_stratagems.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Prevention = preload("res://scripts/edition_11/unit_prevention.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const CoreReactions = preload("res://scripts/edition_11/core_reactions.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const Hammer = preload("res://scripts/edition_11/hammer_of_wrath.gd")
const Incursors = preload("res://scripts/edition_11/incursors.gd")
const TransportRules = preload("res://scripts/edition_11/transport_rules.gd")
const MarineProfiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const WeaponCharacteristics = preload("res://scripts/edition_11/weapon_characteristics.gd")
const Doctrines = preload("res://scripts/edition_11/combat_doctrines.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const ResolutionFrames = preload("res://scripts/edition_11/resolution_frame.gd")
const PhaseCloseGate = preload("res://scripts/edition_11/phase_close_gate.gd")

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var state := F.fresh()
	state.mission.stage = "battle"
	state.awakened_dynasty.pending = []
	state.phase = "shooting"
	state.active = 1
	state.turn = 3
	state.round = 2
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.window = {}
	state.unit_abilities.transport_window = {}
	state.unit_abilities.phase_key = "3:shooting"
	state.stratagems.pending = {}
	state.stratagems.uses = []
	state.stratagems.attack_rerolls = false
	state.stratagems.save_rerolls = false
	state.stratagems.damage_rerolls = false
	state.stratagems.count_rerolls = false
	state.cp = {1: 3, 2: 3}
	Doctrines.enable(state, "ironstorm-spearhead")
	state.combat_doctrines.owners.append(2)
	Detach.enable(state)
	Detach.enable_ironstorm(state)
	return state

func add_lancer(state: Dictionary, owner: int) -> Dictionary:
	var squad_id := 1
	var unit_id := 100
	for existing: int in state.squads: squad_id = maxi(squad_id, existing + 1)
	for existing: int in state.units: unit_id = maxi(unit_id, existing + 1)
	var template_squad: Dictionary = {}
	var template_unit: Dictionary = {}
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner:
			template_squad = state.squads[squad].duplicate(true)
			break
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner:
			template_unit = state.units[model].duplicate(true)
			break
	var profile := F.P.CurrentMarineProfiles.profile("gladiator-lancer")
	template_squad.owner = owner
	template_squad.name = "Ironstorm Test Lancer %d" % owner
	template_squad.starting_strength = 1
	template_squad.stats = profile.stats.duplicate(true)
	template_squad.shot = false
	template_squad.advanced = false
	template_squad.moved_distance = 0.0
	template_squad.battle_shocked = false
	state.squads[squad_id] = template_squad
	template_unit.owner = owner
	template_unit.squad = squad_id
	template_unit.definition_id = "40kdc:11e:adeptus-astartes:gladiator-lancer"
	template_unit.source_role = "Vehicle"
	template_unit.position = Vector2(-10, 0) if owner == 1 else Vector2(0, 0)
	template_unit.radius = profile.base_radius_inches
	template_unit.keywords = profile.keywords.duplicate()
	template_unit.wounds = profile.stats.wounds
	template_unit.max_wounds = profile.stats.wounds
	template_unit.on_battlefield = true
	template_unit.ranged_weapons = profile.ranged.duplicate(true)
	template_unit.melee_weapons = profile.melee.duplicate(true)
	template_unit.transport_profile = profile.get("transport", {}).duplicate(true)
	state.units[unit_id] = template_unit
	return {"model": unit_id, "squad": squad_id}

func entry(state: Dictionary, model: int, target: int, weapon_index: int = 0) -> Dictionary:
	var weapons: Array[Dictionary] = AttackPlan.Equipment.choices(state, model, false)
	return {"model": model, "target": target, "amount": 1, "weapon": weapons[weapon_index].weapon, "profile": weapons[weapon_index].profile}

func roll_six() -> int:
	return 6

func roll_one() -> int:
	return 1

func submit_headhunter_choice(state: Dictionary, player: int, action: String, target: int, value: String = "") -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			projected = option
			break
	if projected.is_empty(): return {"error": "The current Headhunter decision does not offer %s for target %d." % [action, target]}
	var choice: Dictionary = {}
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			choice = option
			break
	if choice.is_empty(): return {"error": "UnitActions no longer offers the projected Headhunter choice."}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": choice}}, Callable(self, "roll_six"))

func submit_unit_choice(state: Dictionary, player: int, action: String, model: int, target: int, value: String = "", roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	var selected: Dictionary = {}
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			selected = option
			break
	if selected.is_empty(): return {"error": "UnitActions no longer offers %s." % action}
	var resolved_roller := roller if roller.is_valid() else Callable(self, "roll_six")
	if decision.is_empty():
		return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": selected}, resolved_roller)
	if int(decision.get("priority_player_id", -1)) != player: return {"error": "No matching UnitActions decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == action and int(option.get("model", -1)) == model and int(option.get("target", -1)) == target and str(option.get("value", "")) == value:
			projected = option
			break
	if projected.is_empty(): return {"error": "The pending decision does not offer %s." % action}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, resolved_roller)

func finish_local_ironstorm_attack(state: Dictionary, player: int) -> bool:
	for _step: int in 8:
		if state.get("pending_attack", {}).is_empty(): return state.has("last_attack") and ResolutionFrames.current(state).is_empty()
		var decision := PendingDecisions.current(state, ["unit-actions"])
		var finish_action := ""
		for option: Dictionary in decision.get("legal_options", []):
			if str(option.get("action", "")) in ["machine-spirit-finish", "hit-finish", "wound-finish"]:
				finish_action = str(option.action)
				break
		if finish_action.is_empty(): return false
		var finished := submit_headhunter_choice(state, player, finish_action, -1)
		if not str(finished.get("error", "")).is_empty(): return false
	return state.get("pending_attack", {}).is_empty() and state.has("last_attack") and ResolutionFrames.current(state).is_empty()

func resolve_layered_mortal_once(state: Dictionary, player: int, target: int, kind: String) -> bool:
	var layered_options: Array = UnitActions.choices(state, player).filter(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == target)
	if layered_options.is_empty(): return false
	var cp_before := int(state.cp[player])
	var layered: Dictionary = layered_options[0]
	var applied := submit_unit_choice(state, player, str(layered.get("action", "")), int(layered.get("model", -1)), int(layered.get("target", -1)), str(layered.get("value", "")))
	if not applied.get("error", "").is_empty() or int(state.cp[player]) != cp_before - 1: return false
	var allocations: Array = CoreReactions.mortal_allocations(state, player, kind)
	if allocations.is_empty(): return false
	var selected: Dictionary = allocations[0]
	var wounds_before := int(state.units[int(selected.model)].wounds)
	var resolved := submit_unit_choice(state, player, str(selected.get("action", "")), int(selected.get("model", -1)), int(selected.get("target", -1)), str(selected.get("value", "")))
	return resolved.get("error", "").is_empty() and int(state.units[int(selected.model)].wounds) == wounds_before and int(CoreReactions._mortal_record(state, kind).get("remaining", 0)) >= 0

func run() -> void:
	var state := make_state()
	var attacker := add_lancer(state, 1)
	var target := add_lancer(state, 2)
	var shot := entry(state, attacker.model, target.squad)
	var result := MatchCommands.execute(state, 1, {"kind": MatchCommands.ATTACK_PLAN, "attacker": attacker.model, "entries": [shot], "revision": int(state.revision), "melee": false, "use_lethal": true}, Callable(self, "roll_one"))
	check(result.get("error", "").is_empty() and result.get("message", "").contains("Headhunter Doctrine"), "Headhunter opens on the eligible Vehicle attack declaration before dice are rolled")
	check(state.unit_abilities.window.get("kind", "") == Detach.HEADHUNTER_WINDOW, "The pending declaration uses the registered Headhunter reaction window kind")
	var declaration := PendingDecisions.current(state, ["unit-actions"])
	var declaration_frame := ResolutionFrames.current(state)
	check(declaration.get("source", "") == "unit-actions" and declaration.get("priority_player_id", -1) == 1 and declaration.get("resume_frame_id", "") == declaration_frame.get("frame_id", ""), "Headhunter's normalized decision belongs to the attacker and links to the suspended attack declaration")
	check(declaration_frame.get("kind", "") == "attack" and declaration_frame.get("status", "") == "suspended" and declaration_frame.get("resume_point", "") == "attack-headhunter-reaction", "Headhunter suspends the real attack before attack dice are rolled")
	check(not PhaseCloseGate.close_request_error(state, 1, state.revision).is_empty(), "The pending Headhunter declaration blocks Shooting close")
	var before_wrong_owner := var_to_bytes(state)
	var wrong_headhunter_owner := submit_headhunter_choice(state, 2, "detachment-stratagem", attacker.squad, Detach.IRONSTORM_HEADHUNTER)
	check(not str(wrong_headhunter_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner, "The opponent cannot submit or mutate the Headhunter declaration")
	var restored_headhunter: Dictionary = bytes_to_var(var_to_bytes(state))
	var restored_decision := PendingDecisions.current(restored_headhunter, ["unit-actions"])
	check(restored_decision.get("decision_id", "") == declaration.get("decision_id", "") and ResolutionFrames.current(restored_headhunter).get("frame_id", "") == declaration_frame.get("frame_id", ""), "Saving and restoring Headhunter preserves its decision and attack frame identities")
	state = restored_headhunter
	var headhunter_applied := submit_headhunter_choice(state, 1, "detachment-stratagem", attacker.squad, Detach.IRONSTORM_HEADHUNTER)
	check(str(headhunter_applied.get("error", "")).is_empty() and state.cp[1] == 2, "The normalized Headhunter choice spends one CP and resumes the attack")
	var headhunter_attack_finished := finish_local_ironstorm_attack(state, 1)
	check(headhunter_attack_finished and state.squads[attacker.squad].shot, "The resumed public attack continues through its remaining local decisions and closes its frame")
	var headhunter_prepared := AttackPlan.prepare(state, attacker.squad, false, [shot], true)
	check(headhunter_prepared.error.is_empty() and headhunter_prepared.batches[0].weapon.keywords.get("lethal-hits", false), "Headhunter adds Lethal Hits against VEHICLE")
	var declined_headhunter := make_state()
	var declined_attacker := add_lancer(declined_headhunter, 1)
	var declined_target := add_lancer(declined_headhunter, 2)
	var declined_entry := entry(declined_headhunter, declined_attacker.model, declined_target.squad)
	var declined_start := MatchCommands.execute(declined_headhunter, 1, {"kind": MatchCommands.ATTACK_PLAN, "attacker": declined_attacker.model, "entries": [declined_entry], "revision": int(declined_headhunter.revision), "melee": false, "use_lethal": true}, Callable(self, "roll_one"))
	var declined := submit_headhunter_choice(declined_headhunter, 1, "head-hunter-pass", declined_attacker.squad)
	var declined_attack_finished := finish_local_ironstorm_attack(declined_headhunter, 1)
	check(str(declined_start.get("error", "")).is_empty() and str(declined.get("error", "")).is_empty() and declined_headhunter.cp[1] == 3 and declined_attack_finished and declined_headhunter.squads[declined_attacker.squad].shot, "Passing Headhunter resumes and completes the same public attack without spending CP")
	var infantry_target := make_state()
	target = add_lancer(infantry_target, 2)
	infantry_target.units[target.model].keywords.erase("VEHICLE")
	infantry_target.units[target.model].keywords.append("INFANTRY")
	var infantry_attacker := add_lancer(infantry_target, 1)
	infantry_target.detachment_stratagems.headhunter[infantry_attacker.squad] = {"phase_key": "%d:%s" % [infantry_target.turn, infantry_target.phase]}
	var infantry_plan := AttackPlan.prepare(infantry_target, infantry_attacker.squad, false, [entry(infantry_target, infantry_attacker.model, target.squad)], true)
	check(infantry_plan.error.is_empty() and not infantry_plan.batches[0].weapon.keywords.get("lethal-hits", false), "Headhunter does not add Lethal Hits against INFANTRY")

	# Might removes modeled hit and wound roll modifiers and expires at the next Command phase.
	state = make_state()
	attacker = add_lancer(state, 1)
	state.phase = "command"
	state.active = 1
	state.unit_abilities.phase_key = "3:command"
	var might: Array = Detach.choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_MIGHT and int(choice.get("target", -1)) == attacker.squad)
	check(not might.is_empty(), "Might is available in the owner's Command phase for the eligible Vehicle")
	if not might.is_empty():
		var applied: Dictionary = Detach.apply(state, 1, might[0])
		check(applied.get("error", "").is_empty() and Detach.might_ignore_active(state, attacker.squad), "Might activates and records the modifier immunity")
		state.phase = "shooting"
		target = add_lancer(state, 2)
		state.unit_abilities.weapon_skill_characteristic_modifiers = {"squads": {attacker.squad: {"BS": -1}}, "models": {}}
		if not state.unit_abilities.has("shrouded_targets"): state.unit_abilities.shrouded_targets = {}
		state.unit_abilities.shrouded_targets[target.squad] = {"phase_key": "%d:%s" % [state.turn, state.phase]}
		var modified := AttackPlan.prepare(state, attacker.squad, false, [entry(state, attacker.model, target.squad)], true)
		var no_might: Dictionary = state.duplicate(true)
		no_might.detachment_stratagems.might_machine_spirit.erase(attacker.squad)
		var direct_bs_penalty := AttackPlan.prepare(no_might, attacker.squad, false, [entry(no_might, attacker.model, target.squad)], true)
		check(modified.error.is_empty() and int(modified.batches[0].weapon.skill) == 3 and int(modified.batches[0].context.hit_modifier) == 0, "Might ignores a direct BS characteristic modifier and a modeled hit-roll penalty")
		check(direct_bs_penalty.error.is_empty() and int(direct_bs_penalty.batches[0].weapon.skill) == 4 and int(direct_bs_penalty.batches[0].context.hit_modifier) == -1, "Without Might, the same direct BS and hit-roll modifiers remain distinct and apply together")
		var legacy_assignment := [{"model": attacker.model, "target": target.squad, "amount": 1}]
		var legacy_with_might := AttackPlan._prepare_legacy(state, attacker.squad, false, legacy_assignment, true)
		var legacy_without_might := AttackPlan._prepare_legacy(no_might, attacker.squad, false, legacy_assignment, true)
		check(legacy_with_might.error.is_empty() and int(legacy_with_might.batches[0].weapon.skill) == 3 and legacy_without_might.error.is_empty() and int(legacy_without_might.batches[0].weapon.skill) == 4, "Legacy attack preparation also applies direct BS modifiers per model and respects Might immunity")
		check(WeaponCharacteristics.apply_skill_modifier(3, 8) == 2 and WeaponCharacteristics.apply_skill_modifier(3, -8) == 6 and WeaponCharacteristics.apply_skill_modifier(4, 2, true) == 4, "Modified BS is capped at 2+–6+, while ignored characteristic modifiers restore the printed skill")
		state.turn = 4
		check(Detach.might_ignore_active(state, attacker.squad), "Might remains active during the following turn")
		state.turn = 5
		check(not Detach.might_ignore_active(state, attacker.squad), "Might expires at the start of the next Command phase")

	# A normal attack with Devastating Wounds must use allocation so Layered Ceramite can react.
	state = make_state()
	attacker = add_lancer(state, 1)
	target = add_lancer(state, 2)
	state.units[attacker.model].ranged_weapons.append({"id": "test-devastating", "profiles": {"standard": {"name": "Test Devastating", "range_inches": 24.0, "attacks": 1, "skill": 2, "strength": 14, "ap": 0, "damage": 1, "keywords": {"devastating-wounds": true}}}})
	var devastating_entry := {"model": attacker.model, "target": target.squad, "amount": 1, "weapon": "test-devastating", "profile": "standard"}
	var prepared := AttackPlan.prepare(state, attacker.squad, false, [devastating_entry], false)
	check(prepared.error.is_empty(), "Synthetic Devastating Wounds attack prepares against the current Vehicle target")
	for batch: Dictionary in prepared.batches:
		for key in ["machine_spirit_power", "machine_spirit_source", "aquilon_optics", "free_hit_reroll", "free_wound_reroll", "free_wound_reroll_source", "free_damage_reroll"]: batch.context.erase(key)
	result = Combat._execute_attack_plan(state, 1, attacker.model, [devastating_entry], false, Callable(self, "roll_six"), prepared)
	check(result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == Detach.LAYERED_CERAMITE_WINDOW, "Devastating Wounds attack pauses for Layered Ceramite before allocation")
	var layered: Array = UnitActions.choices(state, 2).filter(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE)
	check(not layered.is_empty(), "Layered Ceramite is offered to the defending Ironstorm player")
	if not layered.is_empty():
		var layered_applied: Dictionary = Detach.apply(state, 2, layered[0], Callable(self, "roll_six"))
		check(layered_applied.get("error", "").is_empty() and state.cp[2] == 2, "Layered Ceramite resolves and spends one CP")
		var prevention: Array = Prevention.rules(state, target.model)
		check(prevention.any(func(rule: Dictionary) -> bool: return int(rule.get("target", 0)) == 5 and rule.get("against", "") == "mortal"), "Layered Ceramite grants Feel No Pain 5+ against mortal wounds during the phase")
		check(not prevention.any(func(rule: Dictionary) -> bool: return int(rule.get("target", 0)) == 5 and rule.get("against", "") != "mortal"), "Layered Ceramite does not grant Feel No Pain against normal wounds")
		state.phase = "fight"
		check(not Prevention.rules(state, target.model).any(func(rule: Dictionary) -> bool: return int(rule.get("target", 0)) == 5 and rule.get("against", "") == "mortal"), "Layered Ceramite prevention expires at the end of its current phase")

	# Hazardous rolls create the pending pool that offers Layered Ceramite to the Vehicle itself.
	state = make_state()
	attacker = add_lancer(state, 1)
	target = add_lancer(state, 2)
	state.units[attacker.model].ranged_weapons.append({"id": "test-hazardous", "profiles": {"standard": {"name": "Test Hazardous", "range_inches": 24.0, "attacks": 1, "skill": 2, "strength": 10, "ap": -1, "damage": 1, "keywords": {"hazardous": true}}}})
	var hazardous_entry := {"model": attacker.model, "target": target.squad, "amount": 1, "weapon": "test-hazardous", "profile": "standard"}
	var hazardous_plan := AttackPlan.prepare(state, attacker.squad, false, [hazardous_entry], false)
	check(hazardous_plan.error.is_empty() and int(hazardous_plan.hazardous_count) == 1, "Hazardous weapon prepares one hazardous roll")
	var attack_finish := Combat._finish_attack(state, attacker.squad, 1, [hazardous_entry], false, hazardous_plan, {"error": "", "pools": []}, Callable(self, "roll_one"))
	var hazardous_choices: Array = UnitActions.choices(state, 1)
	check(attack_finish.get("error", "").is_empty() and int(state.pending_hazard.get("remaining", 0)) == 3 and hazardous_choices.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == attacker.squad), "Actual Hazardous roll opens Layered Ceramite before mortal-wound allocation to the Vehicle")

	# Desperate Escape rolls its hazard pool on the actual movement path.
	state = make_state()
	attacker = add_lancer(state, 1)
	state.stratagems.escape_rerolls = true
	var enemy_model := -1
	for model: int in state.units:
		if int(state.units[model].owner) == 2:
			enemy_model = model
			break
	for model: int in state.units:
		state.units[model].position = Vector2(20, 20) if int(state.units[model].owner) == 2 else Vector2(-20, -20)
	state.units[attacker.model].position = Vector2.ZERO
	state.units[enemy_model].position = Vector2(3, 0)
	state.phase = "movement"
	state.unit_abilities.phase_key = "3:movement"
	var escape_error := Combat.begin_movement(state, 1, attacker.model, "desperate_escape", state.revision, Callable(self, "roll_one"))
	if escape_error.is_empty() and state.stratagems.pending.get("kind", "") == "after_escape_roll":
		escape_error = Combat.resolve_escape_reaction(state, 1, attacker.squad, "", state.revision, -1, Callable(self, "roll_one"))
	var escape_choices: Array = UnitActions.choices(state, 1)
	check(escape_error.is_empty() and state.pending_move.get("move_type", "") == "desperate_escape" and int(state.pending_move.get("hazard_remaining", 0)) == 3 and escape_choices.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == attacker.squad), "Actual Desperate Escape hazard pool offers Layered Ceramite to the Vehicle before allocation")

	# Tank Shock's post-charge hook generates the mortal packet before allocation.
	state = make_state()
	attacker = add_lancer(state, 1)
	target = add_lancer(state, 2)
	for model: int in state.units:
		if model != attacker.model and model != target.model: state.units[model].position = Vector2(20, 20)
	state.units[attacker.model].position = Vector2.ZERO
	state.units[target.model].position = Vector2(3.5, 0)
	state.phase = "charge"
	state.unit_abilities.phase_key = "3:charge"
	state.squads[attacker.squad].charged = true
	check(CoreReactions.charge_completed(state, 1, attacker.squad), "A completed Vehicle charge opens the Tank Shock reaction")
	var tank_shock_choices: Array = CoreReactions.crushing_choices(state, 1)
	var tank_shock: Dictionary = tank_shock_choices.filter(func(choice: Dictionary) -> bool: return choice.get("value", "") == CoreReactions.CRUSHING and int(choice.get("target", -1)) == target.squad)[0] if tank_shock_choices.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == CoreReactions.CRUSHING and int(choice.get("target", -1)) == target.squad) else {}
	var tank_result: Dictionary = submit_unit_choice(state, 1, str(tank_shock.get("action", "")), int(tank_shock.get("model", -1)), int(tank_shock.get("target", -1)), str(tank_shock.get("value", ""))) if not tank_shock.is_empty() else {"error": "No legal Tank Shock target was prepared."}
	var tank_defense: Array = UnitActions.choices(state, 2)
	check(tank_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == CoreReactions.CRUSHING_MORTAL and tank_defense.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == target.squad), "Actual Tank Shock mortal packet opens Layered Ceramite before allocation")

	# Hammer of Wrath resolves from a completed jump-pack charge into the Vehicle defender choice.
	state = make_state()
	attacker = add_lancer(state, 1)
	target = add_lancer(state, 2)
	state.units[attacker.model].definition_id = "40kdc:11e:adeptus-astartes:assault-intercessors-with-jump-packs"
	for model: int in state.units:
		if model != attacker.model and model != target.model: state.units[model].position = Vector2(20, 20)
	state.units[attacker.model].position = Vector2.ZERO
	state.units[target.model].position = Vector2(3.5, 0)
	state.phase = "charge"
	state.squads[attacker.squad].charged = true
	var hammer_opened := Hammer.charge_completed(state, 1, attacker.squad)
	var hammer_choice: Dictionary = Hammer.choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("value", "") == Hammer.ID and int(choice.get("target", -1)) == target.squad)[0] if Hammer.choices(state, 1).any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Hammer.ID and int(choice.get("target", -1)) == target.squad) else {}
	var hammer_result: Dictionary = submit_unit_choice(state, 1, str(hammer_choice.get("action", "")), int(hammer_choice.get("model", -1)), int(hammer_choice.get("target", -1)), str(hammer_choice.get("value", ""))) if not hammer_choice.is_empty() else {"error": "No Hammer of Wrath target was prepared."}
	var hammer_defense: Array = UnitActions.choices(state, 2)
	check(hammer_opened and hammer_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == Hammer.MORTAL_WINDOW and hammer_defense.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == target.squad), "Actual Hammer of Wrath charge resolution opens Layered Ceramite before Vehicle mortal-wound allocation")
	check(resolve_layered_mortal_once(state, 2, target.squad, Hammer.MORTAL_WINDOW), "Layered Ceramite spends CP and prevents an actually allocated Hammer of Wrath mortal wound")

	# Tigurius's actual psychic action generates the Telepathic Assault packet.
	state = make_state()
	attacker = add_lancer(state, 1)
	target = add_lancer(state, 2)
	state.units[attacker.model].definition_id = "40kdc:11e:adeptus-astartes:chief-librarian-tigurius"
	state.units[attacker.model].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "PSYKER", "CHARACTER", "ULTRAMARINES"]
	for model: int in state.units:
		if model != attacker.model and model != target.model: state.units[model].position = Vector2(20, 20)
	state.units[attacker.model].position = Vector2.ZERO
	state.units[target.model].position = Vector2(5, 0)
	var telepathic_choice: Dictionary = UnitActions.choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.get("action", "") == "tigurius-psychic" and choice.get("value", "") == "telepathic-assault" and int(choice.get("target", -1)) == target.squad)[0] if UnitActions.choices(state, 1).any(func(choice: Dictionary) -> bool: return choice.get("action", "") == "tigurius-psychic" and choice.get("value", "") == "telepathic-assault" and int(choice.get("target", -1)) == target.squad) else {}
	var telepathic_result: Dictionary = submit_unit_choice(state, 1, str(telepathic_choice.get("action", "")), int(telepathic_choice.get("model", -1)), int(telepathic_choice.get("target", -1)), str(telepathic_choice.get("value", ""))) if not telepathic_choice.is_empty() else {"error": "No Telepathic Assault action was prepared."}
	var telepathic_defense: Array = UnitActions.choices(state, 2)
	check(not telepathic_choice.is_empty() and telepathic_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == CoreReactions.TIGURIUS_MORTAL and telepathic_defense.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == target.squad), "Actual Telepathic Assault action opens Layered Ceramite before Vehicle mortal-wound allocation: " + str(telepathic_result.get("error", "")))
	check(resolve_layered_mortal_once(state, 2, target.squad, CoreReactions.TIGURIUS_MORTAL), "Layered Ceramite spends CP and prevents an actually allocated Telepathic Assault mortal wound")

	# Incursor Haywire Mine creates its Vehicle-specific 2D3 packet.
	state = make_state()
	attacker = add_lancer(state, 1)
	target = add_lancer(state, 2)
	state.units[attacker.model].definition_id = "40kdc:11e:adeptus-astartes:incursor-squad"
	state.units[attacker.model].keywords = ["ADEPTUS ASTARTES", "INFANTRY", "PHOBOS"]
	for model: int in state.units:
		if model != attacker.model and model != target.model: state.units[model].position = Vector2(20, 20)
	state.units[attacker.model].position = Vector2.ZERO
	state.units[target.model].position = Vector2(5, 0)
	var mine_choice: Dictionary = Incursors.haywire_choices(state, 1).filter(func(choice: Dictionary) -> bool: return int(choice.get("target", -1)) == target.squad)[0] if Incursors.haywire_choices(state, 1).any(func(choice: Dictionary) -> bool: return int(choice.get("target", -1)) == target.squad) else {}
	var mine_result: Dictionary = submit_unit_choice(state, 1, str(mine_choice.get("action", "")), int(mine_choice.get("model", -1)), int(mine_choice.get("target", -1)), str(mine_choice.get("value", ""))) if not mine_choice.is_empty() else {"error": "No Haywire Mine target was prepared."}
	var mine_defense: Array = UnitActions.choices(state, 2)
	check(not mine_choice.is_empty() and mine_result.get("error", "").is_empty() and int(state.get("last_incursor_haywire_mine", {}).get("mortal_wounds", 0)) == 6 and mine_defense.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == target.squad), "Actual Incursor Haywire Mine 2D3 packet opens Layered Ceramite for the Vehicle defender: " + str(mine_result.get("error", "")))
	check(resolve_layered_mortal_once(state, 2, target.squad, Incursors.MINE_WINDOW), "Layered Ceramite spends CP and prevents an actually allocated Haywire Mine mortal wound")

	# Emergency Disembark is not a legal Layered Ceramite source for the admitted Marine transports.
	state = make_state()
	var vehicle_passenger := add_lancer(state, 1)
	var rhino := add_lancer(state, 1)
	var rhino_profile: Dictionary = MarineProfiles.profile("rhino")
	var marine_transports: Dictionary = MarineProfiles.transport_profiles()
	var marine_transport_count_ok := marine_transports.size() == 8
	for transport_id: String in marine_transports:
		if "INFANTRY" not in marine_transports[transport_id].get("transport", {}).get("required", []): marine_transport_count_ok = false
	state.units[rhino.model].definition_id = "40kdc:11e:adeptus-astartes:rhino"
	state.units[rhino.model].keywords = rhino_profile.keywords.duplicate()
	state.units[rhino.model].transport_profile = rhino_profile.transport.duplicate(true)
	var embark_error := TransportRules.eligibility_error(state, rhino.model, vehicle_passenger.squad)
	check(marine_transport_count_ok and "only models with INFANTRY" in embark_error, "All eight local Marine transport records require Infantry and the runtime rejects a Vehicle passenger; Emergency Hazard cannot target a supported Marine Vehicle")

	# Explosives generates a mortal packet and exposes the defending Ironstorm option.
	state = make_state()
	target = add_lancer(state, 2)
	var explosive_model := -1
	for model: int in state.units:
		if int(state.units[model].owner) == 1 and "EXPLOSIVES" in state.units[model].get("keywords", []):
			explosive_model = model
			break
	for model: int in state.units:
		state.units[model].position = Vector2(-6, 0) if int(state.units[model].owner) == 1 else Vector2(20, 0)
	state.units[target.model].position = Vector2(0, 0)
	var grenade_choice: Dictionary = {}
	for choice: Dictionary in CoreReactions.choices(state, 1):
		if choice.get("action", "") == "explosives" and int(choice.get("target", -1)) == target.squad:
			grenade_choice = choice
			break
	var explosives_result: Dictionary = CoreReactions.throw_explosives(state, 1, grenade_choice, Callable(self, "roll_six")) if explosive_model >= 0 and not grenade_choice.is_empty() else {"error": "No source-eligible Explosives profile or target was prepared."}
	var explosives_defense: Array = UnitActions.choices(state, 2)
	check(explosive_model >= 0 and not grenade_choice.is_empty() and explosives_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == CoreReactions.EXPLOSIVES and explosives_defense.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == target.squad), "Actual Explosives attack opens Layered Ceramite after mortal packet generation")

	# Deadly Demise creates a packet and then offers the same defender reaction.
	state = make_state()
	attacker = add_lancer(state, 1)
	target = add_lancer(state, 2)
	for model: int in state.units:
		if model != attacker.model and model != target.model: state.units[model].position = Vector2(20, 20)
	state.units[attacker.model].position = Vector2.ZERO
	state.units[attacker.model].wounds = 0
	state.units[target.model].position = Vector2(5, 0)
	var demise_started: Dictionary = DeadlyDemise.begin(state, [attacker.model], Callable(self, "roll_six"))
	var demise_choices: Array = UnitActions.choices(state, 2)
	check(demise_started.get("error", "").is_empty() and not state.pending_deadly_demise.get("packets", []).is_empty() and demise_choices.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == target.squad), "Actual Deadly Demise packet opens Layered Ceramite for the Vehicle defender")

	# Verify every other local trigger representation reaches the same defender choice gate.
	var pending_sources := [
		{"name": "Hazardous", "field": "pending_hazard", "value": func(s: Dictionary, squad: int) -> Dictionary: return {"squad": squad, "remaining": 1}},
		{"name": "Desperate Escape", "field": "pending_move", "value": func(s: Dictionary, squad: int) -> Dictionary: return {"squad": squad, "hazard_remaining": 1}},
		{"name": "Deadly Demise", "field": "pending_deadly_demise", "value": func(s: Dictionary, squad: int) -> Dictionary: return {"packet_cursor": 0, "packets": [{"target": squad, "owner": int(s.squads[squad].owner), "remaining": 1}]}}
	]
	for source: Dictionary in pending_sources:
		var source_state := make_state()
		var source_owner := 1 if source.field == "pending_move" else 2
		var source_target := add_lancer(source_state, source_owner)
		var source_state_value: Dictionary = source.value.call(source_state, source_target.squad)
		if source.field == "transport_window": source_state.unit_abilities.transport_window = source_state_value
		else: source_state[source.field] = source_state_value
		if source.field == "pending_deadly_demise": source_state.unit_abilities.window = {"kind": "deadly-demise-mortal", "owners": [source_owner], "target": source_target.squad}
		var source_choices: Array = UnitActions.choices(source_state, source_owner)
		check(Detach.layered_ceramite_triggered(source_state, source_target.squad) and source_choices.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == source_target.squad), "%s pending mortal-wound state exposes Layered Ceramite to its Vehicle defender" % source.name)
	var mortal_windows := ["explosives", "crushing-impact-mortal", "hammer-of-wrath-mortal", "tigurius-telepathic-assault-mortal", "incursor-haywire-mortal"]
	for kind: String in mortal_windows:
		var window_state := make_state()
		var window_target := add_lancer(window_state, 2)
		window_state.unit_abilities.window = {"kind": kind, "owners": [2], "target": window_target.squad}
		var window_choices: Array = UnitActions.choices(window_state, 2)
		check(Detach.layered_ceramite_triggered(window_state, window_target.squad) and window_choices.any(func(choice: Dictionary) -> bool: return choice.get("value", "") == Detach.IRONSTORM_LAYERED_CERAMITE and int(choice.get("target", -1)) == window_target.squad), "%s mortal-wound window exposes Layered Ceramite to its Vehicle defender" % kind)
	var empty_hazard := make_state()
	var empty_target := add_lancer(empty_hazard, 2)
	empty_hazard.pending_hazard = {"squad": empty_target.squad, "remaining": 0}
	check(not Detach.layered_ceramite_triggered(empty_hazard, empty_target.squad), "A completed Hazardous pool cannot reopen Layered Ceramite")
	var wrong_target := make_state()
	var wrong_vehicle := add_lancer(wrong_target, 2)
	wrong_target.pending_hazard = {"squad": wrong_vehicle.squad + 1, "remaining": 1}
	check(not Detach.layered_ceramite_triggered(wrong_target, wrong_vehicle.squad), "Layered Ceramite does not open for a different unit's Hazardous pool")
	print("Ironstorm stratagem checks: %d failures" % failures)
	quit(1 if failures else 0)

func _initialize() -> void:
	call_deferred("run")
