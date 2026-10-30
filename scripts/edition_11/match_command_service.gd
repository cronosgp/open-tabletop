extends RefCounted
## Executes gameplay commands without depending on UI or transport state.
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")

const ADVANCE_PHASE := "advance-phase"
const SELECT_DOCTRINE := "select-doctrine"
const SELECT_UNIT_CHOICE := "select-unit-choice"
const BEGIN_MOVEMENT := "begin-movement"
const ABANDON_FALL_BACK := "abandon-fall-back"
const ALLOCATE_ESCAPE_WOUND := "allocate-escape-wound"
const ESCAPE_WOUND_DECISION_ENVELOPE := "escape-wound-decision-v1"
const FINISH_MOVEMENT := "finish-movement"
const CHARGE_ROLL := "charge-roll"
const CHARGE_TARGET := "charge-target"
const BEGIN_CONTACT := "begin-contact"
const STAGE_CONTACT := "stage-contact"
const FINISH_CONTACT := "finish-contact"
const SHOOT := "shoot"
const ATTACK_PLAN := "attack-plan"
const FIGHT := "fight"
const START_ACTION := "start-action"
const UNIT_CHOICE_ENVELOPE := "unit-choice-v1"
const PLACE_MODEL := "place-model"
const DEPLOYMENT_PRESET := "deployment-preset"
const DEPLOYMENT_CONFIRM := "deployment-confirm"
const ALLOCATE_DAMAGE := "allocate-damage"
const REMOVE_COHERENCY := "remove-coherency-model"
const COMMAND_REACTION := "command-reaction"
const SELECT_OATH_TARGET := "select-oath-target"
const SELECT_VOWED_OBJECTIVE := "select-vowed-objective"
const RESOLVE_REANIMATION := "resolve-reanimation"
const SELECT_AWAKENED_ATTACHMENT := "select-awakened-attachment"
const STRATAGEM_DECISION_ENVELOPE := "stratagem-decision-v1"
const REANIMATION_DECISION_ENVELOPE := "reanimation-decision-v1"
const COHERENCY_DECISION_ENVELOPE := "coherency-decision-v1"
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")

static func execute(state: Dictionary, player: int, command: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var kind := str(command.get("kind", ""))
	match kind:
		ADVANCE_PHASE: return _advance_phase(state, player, command, roller)
		SELECT_DOCTRINE: return _select_doctrine(state, player, command)
		SELECT_UNIT_CHOICE: return _select_unit_choice(state, player, command, roller)
		BEGIN_MOVEMENT: return _begin_movement(state, player, command, roller)
		ABANDON_FALL_BACK: return _apply_string_action(Combat.abandon_fall_back(state, player, int(command.get("revision", -1))), "Fall Back not completed. Positions restored; casualties retained and movement selection consumed.")
		ALLOCATE_ESCAPE_WOUND: return _allocate_escape_wound(state, player, command, roller)
		FINISH_MOVEMENT: return _finish_movement(state, player, command, roller)
		CHARGE_ROLL: return _charge_roll(state, player, command, roller)
		CHARGE_TARGET: return _apply_dictionary_action(Combat.select_charge_target(state, player, int(command.get("target", -1)), int(command.get("revision", -1))))
		BEGIN_CONTACT: return _begin_contact(state, player, command, roller)
		STAGE_CONTACT: return _stage_contact(state, player, command)
		FINISH_CONTACT: return _finish_contact(state, player, command, roller)
		SHOOT: return _apply_dictionary_action(Combat.shoot(state, player, int(command.get("attacker", -1)), int(command.get("target", -1)), int(command.get("revision", -1)), bool(command.get("use_lethal", false)), roller))
		ATTACK_PLAN: return _attack_plan(state, player, command, roller)
		FIGHT: return _apply_dictionary_action(Combat.fight(state, player, int(command.get("attacker", -1)), int(command.get("target", -1)), int(command.get("revision", -1)), roller))
		START_ACTION: return _start_action(state, player, command)
		PLACE_MODEL: return _place_model(state, player, command)
		DEPLOYMENT_PRESET: return _deployment_preset(state, player, command)
		DEPLOYMENT_CONFIRM: return _deployment_confirm(state, player, command)
		ALLOCATE_DAMAGE: return _allocate_damage(state, player, command, roller)
		REMOVE_COHERENCY: return _remove_coherency(state, player, command)
		COMMAND_REACTION: return _command_reaction(state, player, command, roller)
		SELECT_OATH_TARGET: return _select_oath_target(state, player, command)
		SELECT_VOWED_OBJECTIVE: return _select_vowed_objective(state, player, command)
		RESOLVE_REANIMATION: return _resolve_reanimation(state, player, command, roller)
		SELECT_AWAKENED_ATTACHMENT: return _select_awakened_attachment(state, player, command)
		_: return _failure("Unsupported phase command.")

static func _advance_phase(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var revision := int(command.get("revision", -1))
	var model := int(command.get("model", -1))
	var selected_squad := -1
	if state.get("units", {}).has(model) and int(state.units[model].get("owner", -1)) == player:
		selected_squad = int(state.units[model].get("squad", -1))
	var error: String = Combat.advance_phase(state, player, revision, roller, selected_squad)
	if not error.is_empty(): return _failure(error)
	if not Combat.Stratagems.pending(state).is_empty():
		return _success("Battle-shock pending: choose a unit and decide before rolling.")
	var guidance := "Right click an enemy to shoot." if state.phase == "shooting" else "Move individual miniatures, then confirm the squad." if state.phase == "movement" else "Advance when ready; unimplemented effects are listed above."
	return _success("Phase: %s. %s" % [state.phase, guidance])

static func _select_doctrine(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var decision_state_error := Combat.PhaseCloseGate.decision_container_error(state, "combat-doctrines")
	if not decision_state_error.is_empty(): return _failure(decision_state_error)
	var doctrine := str(command.get("doctrine", ""))
	var revision := int(command.get("revision", -1))
	var decision := Combat.Doctrines.pending_decision(state)
	var selection := _projected_option(decision, player, str(command.get("decision_id", "")), str(command.get("option_id", "")))
	if not selection.error.is_empty(): return selection
	var projected_option: Dictionary = selection.option
	if not projected_option.is_empty() and (str(projected_option.get("action", "")) != "combat-doctrine" or str(projected_option.get("value", "")) != doctrine):
		return _failure("Choose an option from the current decision window.")
	var error := Combat.select_combat_doctrine(state, player, doctrine, revision)
	if not error.is_empty(): return _failure(error)
	return _success(Combat.Doctrines.NAMES.get(doctrine, doctrine) + ". Continue Command.")

static func _select_unit_choice(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var choice: Variant = command.get("choice", {})
	var decision_id := ""
	var option_id := ""
	if choice is Dictionary and str(choice.get("_decision_type", "")) == UNIT_CHOICE_ENVELOPE:
		decision_id = str(choice.get("decision_id", ""))
		option_id = str(choice.get("option_id", ""))
		choice = choice.get("choice", {})
	if not choice is Dictionary: return _failure("Invalid unit choice.")
	var pending_deadly_value: Variant = state.get("pending_deadly_demise", {})
	if typeof(pending_deadly_value) != TYPE_DICTIONARY: return _failure("Cannot resolve a unit choice while destruction state is invalid.")
	var pending_deadly: Dictionary = pending_deadly_value
	for source: String in ["mission-preparation", "unit-actions"]:
		var decision_state_error := Combat.PhaseCloseGate.decision_container_error(state, source)
		if not decision_state_error.is_empty(): return _failure(decision_state_error)
	var ability_state_error := Combat.PhaseCloseGate.unit_action_state_error(state)
	if not ability_state_error.is_empty(): return _failure(ability_state_error)
	var decision := PendingDecisions.current(state, ["mission-preparation", "unit-actions"])
	if not pending_deadly.is_empty():
		var destruction_choice_available := false
		for option: Dictionary in decision.get("legal_options", []):
			var action := str(option.get("action", ""))
			if action in ["deadly-demise-allocate", "deadly-demise-vengeful-pass"] or action.begins_with("transport-disembark-") or action.begins_with("layered-ceramite-") or (action == "detachment-stratagem" and str(option.get("value", "")) == Combat.DetachmentStratagems.MEDUSA_VENGEFUL_ANIMUS):
				destruction_choice_available = true
				break
		if not destruction_choice_available: return _failure("Resolve pending destruction effects before submitting another unit choice.")
	var selection := _projected_option(decision, player, decision_id, option_id)
	if not selection.error.is_empty(): return selection
	if decision.is_empty():
		var admission_error := Combat.PhaseCloseGate.command_error(state, player, int(command.get("revision", -1)), "", "", true)
		if not admission_error.is_empty(): return _failure(admission_error)
		if player != Combat.MatchActor.player(state) and not _allows_non_actor_unit_choice(state, player, choice):
			return _failure("Wait for your action window.")
	var projected_option: Dictionary = selection.option
	if not projected_option.is_empty() and not _choice_matches_projection(choice, projected_option):
		return _failure("Choose an option from the current decision window.")
	var point: Vector2 = command.get("point", Vector2.ZERO)
	var revision := int(command.get("revision", -1))
	var error := Combat.unit_action(state, player, choice, point, revision, roller, float(command.get("destination_elevation", -1.0)))
	if not error.is_empty(): return _failure(error)
	var action := str(choice.get("action", ""))
	if action == "setup-done":
		var next_owner := Combat.UnitActions.setup_actor(state)
		return _success("Player %d's army is ready. Player %d is preparing next." % [player, next_owner] if next_owner > 0 else "Both armies are prepared. Continue to the next match step.")
	if action.begins_with("mission-"): return _success("Mission choice saved.")
	if action in ["aggressor-loadout", "inceptor-loadout", "land-speeder-cannon", "intercessor-melee", "intercessor-rifle", "intercessor-grenade-launcher", "heavy-intercessor-bolter", "terminator-melee", "deathwatch-terminator-loadout", "wolf-guard-terminator-loadout", "thunderwolf-cavalry-loadout", "wulfen-loadout", "fortis-sergeant-melee", "fortis-sergeant-ranged", "fortis-grenade-launcher", "fortis-plasma-pistol", "fortis-rocket-launcher", "talonstrike-sergeant-melee", "talonstrike-sergeant-ranged", "talonstrike-intercessor-plasma-pistol", "talonstrike-plasma-exterminator", "indomitor-flamestorm-gauntlets", "indomitor-heavy-bolter", "indomitor-multi-melta", "decimus-gravis-weapon", "decimus-storm-shield", "decimus-plasma-incinerator", "terminator-special-weapon", "terminator-assault-loadout", "outrider-melee", "outrider-plasma-pistol", "eliminator-troopers", "eliminator-sergeant", "ancient-loadout", "jump-pack-captain-loadout", "gravis-captain-loadout", "terminator-captain-gun", "terminator-captain-blade", "captain-ranged-loadout", "captain-melee-loadout", "lieutenant-ranged-loadout", "lieutenant-melee-loadout", "lieutenant-storm-shield", "terminator-chaplain-shield", "captain-loadout", "lieutenant-loadout", "impulsor-loadout", "transport-weapon-loadout", "baal-predator-loadout", "death-company-dreadnought-loadout", "death-company-melee-loadout", "death-company-pistol-loadout", "death-company-grenade-launcher", "eliminator-loadout", "phobos-lieutenant-gun", "relic-shield", "apothecary-loadout", "redemptor-loadout", "dreadnought-loadout", "heavy-weapon-loadout", "vanguard-veteran-squad-loadout"]:
		return _success("Equipment updated.")
	return _success("Unit ability choice saved.")

## Protocol of the Hungry Void is available in the Fight phase for either player's eligible unit.
## Keep this exception narrow; ordinary immediate choices still require the current match actor.
static func _allows_non_actor_unit_choice(state: Dictionary, player: int, choice: Dictionary) -> bool:
	if str(choice.get("action", "")) != "detachment-stratagem" or str(choice.get("value", "")) != DetachmentStratagems.HUNGRY: return false
	if str(state.get("phase", "")) != "fight" or player == Combat.MatchActor.player(state): return false
	return Combat.unit_choices(state, player).has(choice)

static func _choice_matches_projection(choice: Dictionary, option: Dictionary) -> bool:
	var matches := (
		str(choice.get("action", "")) == str(option.get("action", ""))
		and int(choice.get("model", -1)) == int(option.get("model", -1))
		and int(choice.get("target", -1)) == int(option.get("target", -1))
		and str(choice.get("value", "")) == str(option.get("value", ""))
	)
	var details: Dictionary = option.get("details", {})
	if details.has("die"): matches = matches and int(choice.get("die", -1)) == int(details.die)
	if details.has("objective"):
		var choice_details: Variant = choice.get("details", {})
		matches = matches and typeof(choice_details) == TYPE_DICTIONARY and int(choice_details.get("objective", -1)) == int(details.objective)
	if details.has("enemy_target"):
		matches = matches and int(choice.get("enemy_target", -1)) == int(details.enemy_target)
	return matches

## Validate the shared decision envelope while leaving rule-specific choice checks to each domain module.
static func _projected_option(decision: Dictionary, player: int, decision_id: String, option_id: String) -> Dictionary:
	if decision.is_empty():
		if not decision_id.is_empty() or not option_id.is_empty(): return _failure("The submitted decision is no longer open.")
		return {"error": "", "option": {}}
	if int(decision.get("priority_player_id", -1)) != player:
		return _failure("This decision belongs to Player %d." % int(decision.priority_player_id))
	if decision_id != str(decision.get("decision_id", "")):
		return _failure("Decision changed; refresh the current options before choosing.")
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("id", "")) == option_id:
			return {"error": "", "option": option}
	return _failure("Choose an option from the current decision window.")

static func _begin_movement(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var error: String = Combat.begin_movement(state, player, int(command.get("model", -1)), str(command.get("move_type", "")), int(command.get("revision", -1)), roller, bool(command.get("use_sudden_onslaught", false)), false, bool(command.get("take_to_skies", false)))
	if not error.is_empty(): return _failure(error)
	var message := "Roll complete: accept the result or use Command Re-roll before allocation and movement." if not Combat.Stratagems.pending(state).is_empty() else "Movement selected. Allocate any escape wounds, then place models and confirm."
	return _success(message)

static func _finish_movement(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var cancel := bool(command.get("cancel", false))
	var validation := Combat.finish_movement_result(state, player, int(command.get("revision", -1)), cancel, roller)
	var message := "Placement reset; selected move, dice and casualties retained." if cancel and not state.pending_move.is_empty() else "Pending movement cancelled." if cancel else "Squad movement confirmed."
	return _apply_validation_action(validation, message)

static func _charge_roll(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var revision := int(command.get("revision", -1))
	if bool(command.get("decline", false)):
		return _apply_string_action(Combat.decline_charge(state, player, revision), "Charge finished without movement.")
	var result: Dictionary = Combat.declare_charge(state, player, int(command.get("model", -1)), revision, roller, false, bool(command.get("take_to_skies", false)))
	return _apply_dictionary_action(result)

static func _begin_contact(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var targets: Array[int] = []
	for target: Variant in command.get("targets", []): targets.append(int(target))
	var error: String = Combat.begin_contact_move(state, player, int(command.get("model", -1)), str(command.get("move_kind", "")), int(command.get("revision", -1)), targets, int(command.get("objective", -1)), roller, bool(command.get("use_tactical_focus", false)), bool(command.get("use_devout_push", false)))
	if not error.is_empty(): return _failure(error)
	var singular_will_roll: Dictionary = state.get("pending_contact", {}).get("singular_will_roll", {})
	if not singular_will_roll.is_empty():
		return _success("Singular Will: D3 rolled %d + 3 = %d inches per model. Place the unit, then confirm consolidation." % [int(singular_will_roll.rolls[0]), int(singular_will_roll.value)])
	var tactical_focus_roll: Dictionary = state.get("pending_contact", {}).get("tactical_focus_roll", {})
	if not tactical_focus_roll.is_empty():
		var retained_text := " Roll retained; no additional CP charged." if bool(state.pending_contact.get("tactical_focus_roll_reused", false)) else ""
		return _success("Tactical Focus:%s D3 rolled %d + 3 = %d inches per model. Place the unit, then confirm consolidation." % [retained_text, int(tactical_focus_roll.rolls[0]), int(tactical_focus_roll.value)])
	var devout_push_roll: Dictionary = state.get("pending_contact", {}).get("devout_push_roll", {})
	if not devout_push_roll.is_empty():
		var devout_retained_text := " Roll retained; no additional CP charged." if bool(state.pending_contact.get("devout_push_roll_reused", false)) else ""
		return _success("Devout Push:%s D3 rolled %d + 3 = %d inches per model. Place the unit, then confirm contact movement." % [devout_retained_text, int(devout_push_roll.rolls[0]), int(devout_push_roll.value)])
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var owners: Array = window.get("owners", [])
	if window.get("kind", "") == Combat.TransportRules.COMBAT_EMBARKATION_WINDOW and not owners.is_empty():
		return _success("Charge placement paused: Player %d must resolve Repulsor Combat Embarkation." % int(owners[0]))
	return _success("Place individual models with right-click, then confirm contact movement.")

static func _finish_contact(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var cancel := bool(command.get("cancel", false))
	var tactical_focus_retained: bool = cancel and not state.get("pending_contact", {}).get("tactical_focus_roll", {}).is_empty()
	var devout_push_retained: bool = cancel and not state.get("pending_contact", {}).get("devout_push_roll", {}).is_empty()
	var validation := Combat.finish_contact_move_result(state, player, int(command.get("revision", -1)), cancel, roller)
	var message := "Contact placement cancelled; positions restored."
	if cancel and tactical_focus_retained: message += " Tactical Focus remains paid and its D3+3 roll is retained."
	if cancel and devout_push_retained: message += " Devout Push remains paid and its D3+3 roll is retained."
	if not cancel: message = "Contact movement confirmed."
	return _apply_validation_action(validation, message)

static func _attack_plan(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var entries: Array = command.get("entries", [])
	var result: Dictionary = Combat.resolve_attack_plan(state, player, int(command.get("attacker", -1)), entries, int(command.get("revision", -1)), bool(command.get("melee", false)), bool(command.get("use_lethal", false)), roller, int(command.get("hail_target", -1)), bool(command.get("indirect_shooting", false)))
	return _apply_dictionary_action(result)

static func _start_action(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var error: String = Combat.start_action(state, player, int(command.get("model", -1)), int(command.get("objective", -1)), int(command.get("revision", -1)))
	return _apply_string_action(error, "Secure Ground started. Shooting and charging remain restricted until turn end.")

static func _place_model(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var model := int(command.get("model", -1))
	var destination: Vector2 = command.get("destination", Vector2.ZERO)
	var revision := int(command.get("revision", -1))
	var destination_elevation := float(command.get("destination_elevation", -1.0))
	if state.phase == "deployment":
		return _apply_string_action(Deployment.place(state, player, model, destination, revision), "Deployment position accepted.")
	return _apply_validation_action(Combat.move_result(state, player, model, destination, revision, destination_elevation), "Miniature repositioned. Confirm the squad's movement when ready.")

static func _stage_contact(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var result := Combat.stage_contact_move_result(state, player, int(command.get("model", -1)), command.get("destination", Vector2.ZERO), int(command.get("revision", -1)), float(command.get("destination_elevation", -1.0)))
	return _apply_validation_action(result, "Contact placement staged.")

static func _deployment_preset(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var error: String = Deployment.preset(state, player, int(command.get("revision", -1)))
	return _apply_string_action(error, "Preview positions accepted; confirm this unit when ready.")

static func _deployment_confirm(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var error: String = Deployment.confirm(state, player, int(command.get("revision", -1)))
	return _apply_string_action(error, "Unit deployment confirmed.")

static func _allocate_damage(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var model := int(command.get("model", -1))
	var revision := int(command.get("revision", -1))
	var pending_deadly_value: Variant = state.get("pending_deadly_demise", {})
	if typeof(pending_deadly_value) != TYPE_DICTIONARY: return _failure("Cannot allocate damage while destruction resolution state is invalid.")
	var pending_deadly: Dictionary = pending_deadly_value
	if not pending_deadly.is_empty(): return _failure("Resolve pending destruction effects before allocating damage.")
	var abilities_value: Variant = state.get("unit_abilities", {})
	if typeof(abilities_value) != TYPE_DICTIONARY: return _failure("Cannot allocate damage while unit ability state is invalid.")
	var abilities: Dictionary = abilities_value
	var transport_window_value: Variant = abilities.get("transport_window", {})
	if typeof(transport_window_value) != TYPE_DICTIONARY: return _failure("Cannot allocate damage while transport resolution state is invalid.")
	var transport_window: Dictionary = transport_window_value
	if not transport_window.is_empty(): return _failure("Resolve transport placement or Hazardous allocation before allocating attack damage.")
	var ability_window_value: Variant = abilities.get("window", {})
	if typeof(ability_window_value) != TYPE_DICTIONARY: return _failure("Cannot allocate damage while unit ability choice state is invalid.")
	var ability_window: Dictionary = ability_window_value
	if not ability_window.is_empty(): return _failure("Resolve the pending unit ability choice before allocating damage.")
	var pending_attack_value: Variant = state.get("pending_attack", {})
	if typeof(pending_attack_value) != TYPE_DICTIONARY: return _failure("Cannot allocate damage while damage allocation state is invalid.")
	var pending_attack: Dictionary = pending_attack_value
	var pending_hazard_value: Variant = state.get("pending_hazard", {})
	if typeof(pending_hazard_value) != TYPE_DICTIONARY: return _failure("Cannot allocate damage while Hazardous allocation state is invalid.")
	var pending_hazard: Dictionary = pending_hazard_value
	if not pending_attack.is_empty():
		var decision := Combat.Allocation.pending_decision(state)
		if decision.is_empty(): return _failure("Resolve the current attack decision before allocating damage.")
		var selection := _projected_option(decision, player, str(command.get("decision_id", "")), str(command.get("option_id", "")))
		if not selection.error.is_empty(): return selection
		var selected_option: Dictionary = selection.option
		var selected_choice := {"action": "damage-allocation", "model": model, "target": int(pending_attack.current.get("target", -1)), "value": str(pending_attack.current.get("phase", ""))}
		if selected_option.is_empty() or not _choice_matches_projection(selected_choice, selected_option): return _failure("Choose an option from the current decision window.")
	else:
		var selection := _projected_option({}, player, str(command.get("decision_id", "")), str(command.get("option_id", "")))
		if not selection.error.is_empty(): return selection
	var error: String = Combat.allocate_hazard(state, player, model, revision, roller) if not pending_hazard.is_empty() else Combat.allocate_damage(state, player, model, revision, roller)
	var message := "Recipient confirmed. The attacker resolves damage before prevention and casualties." if Combat.Stratagems.pending(state).get("kind") == "after_damage_roll" else "Damage choice accepted; continue allocation or the next action window."
	return _apply_string_action(error, message)

static func _remove_coherency(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var model := int(command.get("model", -1))
	var decision := PendingDecisions.current(state, ["coherency"])
	var selection := _projected_option(decision, player, str(command.get("decision_id", "")), str(command.get("option_id", "")))
	if not selection.error.is_empty(): return selection
	var option: Dictionary = selection.option
	if str(option.get("action", "")) != "remove-coherency-model" or int(option.get("model", -1)) != model:
		return _failure("Choose a casualty from the current coherency decision.")
	var error: String = Combat.remove_for_coherency(state, player, model, int(command.get("revision", -1)))
	return _apply_string_action(error, "Model %d removed for coherency." % model)

static func _allocate_escape_wound(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var submitted: Variant = command.get("choice", {})
	var decision_id := str(command.get("decision_id", ""))
	var option_id := str(command.get("option_id", ""))
	if submitted is Dictionary and str(submitted.get("_decision_type", "")) == ESCAPE_WOUND_DECISION_ENVELOPE:
		decision_id = str(submitted.get("decision_id", ""))
		option_id = str(submitted.get("option_id", ""))
		submitted = submitted.get("choice", {})
	if not submitted is Dictionary: return _failure("Invalid escape-wound allocation choice.")
	var decision := PendingDecisions.current(state, ["escape-wounds"])
	var selection := _projected_option(decision, player, decision_id, option_id)
	if not selection.error.is_empty(): return selection
	var model := int(submitted.get("model", -1))
	var projected_option: Dictionary = selection.option
	if projected_option.is_empty() or str(projected_option.get("action", "")) != "allocate-escape-mortal-wound" or int(projected_option.get("model", -1)) != model:
		return _failure("Choose a model from the current escape-wound decision.")
	if int(projected_option.get("target", -1)) != int(state.get("pending_move", {}).get("squad", -1)):
		return _failure("The current escape-wound target changed; refresh the available models.")
	return _apply_string_action(Combat.allocate_escape_wound(state, player, model, int(command.get("revision", -1)), roller), "Escape mortal wound allocated.")

static func _command_reaction(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var stratagem_state_error := Combat.PhaseCloseGate.stratagem_state_error(state)
	if not stratagem_state_error.is_empty(): return _failure(stratagem_state_error)
	var window: Dictionary = Combat.Stratagems.pending(state)
	var decision := Combat.Stratagems.pending_decision(state)
	var submitted: Variant = command.get("choice", {})
	var decision_id := ""
	var option_id := ""
	if submitted is Dictionary and str(submitted.get("_decision_type", "")) == STRATAGEM_DECISION_ENVELOPE:
		decision_id = str(submitted.get("decision_id", ""))
		option_id = str(submitted.get("option_id", ""))
		submitted = submitted.get("choice", {})
	if not submitted is Dictionary: return _failure("Invalid stratagem decision choice.")
	if decision.is_empty() and not window.is_empty():
		return _failure("This reaction window has no supported decision projection.")
	var selection := _projected_option(decision, player, decision_id, option_id)
	if not selection.error.is_empty(): return selection
	var selected_option: Dictionary = selection.option
	if not selected_option.is_empty() and not _choice_matches_projection(submitted, selected_option):
		return _failure("Choose an option from the current decision window.")
	var kind := str(window.get("kind", ""))
	var squad := int(submitted.get("target", -1))
	var stratagem := str(submitted.get("value", ""))
	var revision := int(command.get("revision", -1))
	var die := int(submitted.get("die", -1))
	var error: String
	if kind == "before_battle_shock" and stratagem == "my-will-be-done":
		var discount_choice: Dictionary = {}
		for unit_choice: Dictionary in Combat.unit_choices(state, player):
			if str(unit_choice.get("action", "")) == "discount" and int(unit_choice.get("target", -1)) == squad:
				discount_choice = unit_choice
				break
		if discount_choice.is_empty(): return _failure("My Will Be Done is no longer available for this unit.")
		error = Combat.unit_action(state, player, discount_choice, Vector2.ZERO, revision, roller)
		return _apply_string_action(error, "My Will Be Done discount armed for the selected unit.")
	if kind == "after_escape_roll": error = Combat.resolve_escape_reaction(state, player, squad, stratagem, revision, die, roller)
	elif kind == "after_escape_battle_shock_roll": error = Combat.resolve_escape_morale_reaction(state, player, squad, stratagem, revision, roller)
	elif kind in ["after_hazardous_roll", "after_transport_hazard_roll"]: error = Combat.resolve_hazard_reaction(state, player, squad, stratagem, revision, die, roller)
	elif kind in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_attack_count_roll"]: error = Combat.resolve_attack_reaction(state, player, squad, stratagem, revision, die, roller)
	elif kind in ["before_battle_shock", "after_battle_shock_roll"]: error = Combat.resolve_command_reaction(state, player, squad, stratagem, revision, roller)
	elif kind == "after_deathwatch_terminatus_battle_shock_roll": error = Combat.resolve_deathwatch_terminatus_reaction(state, player, squad, stratagem, revision, roller)
	else: error = Combat.resolve_roll_reaction(state, player, squad, stratagem, revision, roller)
	return _apply_string_action(error, "Command reaction resolved.")

static func _select_oath_target(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var decision_state_error := Combat.PhaseCloseGate.decision_container_error(state, "oath-of-moment")
	if not decision_state_error.is_empty(): return _failure(decision_state_error)
	var target := int(command.get("target", -1))
	var decision := Combat.OathOfMoment.pending_decision(state)
	var selection := _projected_option(decision, player, str(command.get("decision_id", "")), str(command.get("option_id", "")))
	if not selection.error.is_empty(): return selection
	var projected_option: Dictionary = selection.option
	if not projected_option.is_empty() and (str(projected_option.get("action", "")) != "oath-target" or int(projected_option.get("target", -1)) != target):
		return _failure("Choose an option from the current Oath of Moment decision.")
	var error: String = Combat.select_oath_target(state, player, target, int(command.get("revision", -1)))
	return _apply_string_action(error, "Oath of Moment: " + str(state.get("squads", {}).get(target, {}).get("name", "target")) + ". Continue the Command phase.")

static func _select_vowed_objective(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var decision_state_error := Combat.PhaseCloseGate.decision_container_error(state, "vowed-target")
	if not decision_state_error.is_empty(): return _failure(decision_state_error)
	var objective_index := int(command.get("target", -1))
	var decision := Combat.VowedTarget.pending_decision(state)
	var selection := _projected_option(decision, player, str(command.get("decision_id", "")), str(command.get("option_id", "")))
	if not selection.error.is_empty(): return selection
	var projected_option: Dictionary = selection.option
	var expected_action := "vowed-target-pass" if objective_index == -1 else "vowed-target"
	if not projected_option.is_empty() and (str(projected_option.get("action", "")) != expected_action or int(projected_option.get("target", -1)) != objective_index):
		return _failure("Choose an option from the current Vowed Target decision.")
	var error: String = Combat.select_vowed_objective(state, player, objective_index, int(command.get("revision", -1)))
	return _apply_string_action(error, "Vowed Target resolved. Continue the Command phase.")

static func _resolve_reanimation(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var reanimation_state_error := Combat.PhaseCloseGate.reanimation_state_error(state)
	if not reanimation_state_error.is_empty(): return _failure(reanimation_state_error)
	var window := Combat.Reanimation.pending(state)
	var decision := Combat.Reanimation.pending_decision(state)
	var submitted: Variant = command.get("choice", {})
	var decision_id := ""
	var option_id := ""
	if submitted is Dictionary and str(submitted.get("_decision_type", "")) == REANIMATION_DECISION_ENVELOPE:
		decision_id = str(submitted.get("decision_id", ""))
		option_id = str(submitted.get("option_id", ""))
		submitted = submitted.get("choice", {})
	if not submitted is Dictionary: return _failure("Invalid Reanimation decision choice.")
	if decision.is_empty() and not window.is_empty():
		return _failure("This Reanimation window has no supported decision projection.")
	var selection := _projected_option(decision, player, decision_id, option_id)
	if not selection.error.is_empty(): return selection
	var projected_option: Dictionary = selection.option
	if not projected_option.is_empty() and not _choice_matches_projection(submitted, projected_option): return _failure("Choose an option from the current decision window.")
	var error: String = Combat.resolve_reanimation(state, player, str(submitted.get("value", "")), int(submitted.get("target", -1)), int(submitted.get("model", -1)), command.get("point", Vector2.ZERO), int(command.get("revision", -1)), roller)
	if not error.is_empty(): return _failure(error)
	var remaining := not Combat.Reanimation.pending(state).is_empty()
	var healing := Combat.UnitAbilities.enabled(state)
	var message := "Reanimation updated. " + ("Resolve the remaining returns and units." if remaining else ("Healing complete; resolve remaining end-phase choices." if healing else "Command complete."))
	return _success(message)

static func _select_awakened_attachment(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var decision_state_error := Combat.PhaseCloseGate.decision_container_error(state, "awakened-attachment")
	if not decision_state_error.is_empty(): return _failure(decision_state_error)
	var bodyguard := int(command.get("bodyguard", -1))
	var decision := PendingDecisions.current(state, ["awakened-attachment"])
	var selection := _projected_option(decision, player, str(command.get("decision_id", "")), str(command.get("option_id", "")))
	if not selection.error.is_empty(): return selection
	var projected_option: Dictionary = selection.option
	if not projected_option.is_empty() and (str(projected_option.get("action", "")) != "awakened-attachment" or int(projected_option.get("target", -2)) != bodyguard):
		return _failure("Choose an Overlord attachment option from the current decision.")
	var error: String = Combat.select_awakened_attachment(state, player, bodyguard, int(command.get("revision", -1)))
	if not error.is_empty(): return _failure(error)
	var message := "Overlord assignment saved. " + ("Declare the next Overlord." if Combat.Awakened.needs_setup(state) else ("Finish army preparations, then deploy." if Combat.UnitAbilities.enabled(state) else "Review and confirm deployment for every model."))
	return _success(message)

static func _apply_string_action(error: String, message: String) -> Dictionary:
	return _failure(error) if not error.is_empty() else _success(message)

static func _apply_validation_action(result: Dictionary, message: String) -> Dictionary:
	if bool(result.get("valid", false)): return _success(message)
	var error := str(result.get("reason", ""))
	if error.is_empty(): error = "Movement validation did not complete; the move was not applied."
	return _failure(error, str(result.get("code", "movement_blocked")), str(result.get("recovery", "Choose another destination or cancel the move.")), result.get("details", []), int(result.get("primary_model", -1)))

static func _apply_dictionary_action(result: Dictionary) -> Dictionary:
	if not str(result.get("error", "")).is_empty(): return _failure(str(result.error))
	return _success(str(result.get("message", "Command completed.")))

static func _failure(error: String, error_code: String = "", recovery: String = "", details: Array = [], primary_model: int = -1) -> Dictionary:
	var result := {"error": error, "message": ""}
	if not error_code.is_empty(): result["error_code"] = error_code
	if not recovery.is_empty(): result["recovery"] = recovery
	if not details.is_empty(): result["details"] = details.duplicate(true)
	if primary_model >= 0: result["primary_model"] = primary_model
	return result

static func _success(message: String) -> Dictionary:
	return {"error": "", "message": message}
