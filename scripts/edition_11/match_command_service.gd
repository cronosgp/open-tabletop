extends RefCounted
## Executes gameplay commands without depending on UI or transport state.
const Combat = preload("res://scripts/edition_11/combat_scenario.gd")

const ADVANCE_PHASE := "advance-phase"
const SELECT_DOCTRINE := "select-doctrine"
const SELECT_UNIT_CHOICE := "select-unit-choice"
const BEGIN_MOVEMENT := "begin-movement"
const ABANDON_FALL_BACK := "abandon-fall-back"
const ALLOCATE_ESCAPE_WOUND := "allocate-escape-wound"
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
const RESOLVE_REANIMATION := "resolve-reanimation"
const SELECT_AWAKENED_ATTACHMENT := "select-awakened-attachment"
const STRATAGEM_DECISION_ENVELOPE := "stratagem-decision-v1"
const REANIMATION_DECISION_ENVELOPE := "reanimation-decision-v1"
const Deployment = preload("res://scripts/edition_11/deployment.gd")

static func execute(state: Dictionary, player: int, command: Dictionary, roller: Callable = Callable()) -> Dictionary:
	var kind := str(command.get("kind", ""))
	match kind:
		ADVANCE_PHASE: return _advance_phase(state, player, command, roller)
		SELECT_DOCTRINE: return _select_doctrine(state, player, command)
		SELECT_UNIT_CHOICE: return _select_unit_choice(state, player, command, roller)
		BEGIN_MOVEMENT: return _begin_movement(state, player, command, roller)
		ABANDON_FALL_BACK: return _apply_string_action(Combat.abandon_fall_back(state, player, int(command.get("revision", -1))), "Fall Back not completed. Positions restored; casualties retained and movement selection consumed.")
		ALLOCATE_ESCAPE_WOUND: return _apply_string_action(Combat.allocate_escape_wound(state, player, int(command.get("model", -1)), int(command.get("revision", -1)), roller), "Escape mortal wound allocated.")
		FINISH_MOVEMENT: return _finish_movement(state, player, command, roller)
		CHARGE_ROLL: return _charge_roll(state, player, command, roller)
		CHARGE_TARGET: return _apply_dictionary_action(Combat.select_charge_target(state, player, int(command.get("target", -1)), int(command.get("revision", -1))))
		BEGIN_CONTACT: return _begin_contact(state, player, command)
		STAGE_CONTACT: return _apply_string_action(Combat.stage_contact_move(state, player, int(command.get("model", -1)), command.get("destination", Vector2.ZERO), int(command.get("revision", -1))), "Contact placement staged.")
		FINISH_CONTACT: return _finish_contact(state, player, command)
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
	var decision := Combat.UnitActions.pending_decision(state)
	var selection := _projected_option(decision, player, decision_id, option_id)
	if not selection.error.is_empty(): return selection
	var projected_option: Dictionary = selection.option
	if not projected_option.is_empty() and not _choice_matches_projection(choice, projected_option):
		return _failure("Choose an option from the current decision window.")
	var point: Vector2 = command.get("point", Vector2.ZERO)
	var revision := int(command.get("revision", -1))
	var error := Combat.unit_action(state, player, choice, point, revision, roller)
	if not error.is_empty(): return _failure(error)
	var action := str(choice.get("action", ""))
	return _success("Mission choice saved." if action.begins_with("mission-") else "Unit ability choice saved.")

static func _choice_matches_projection(choice: Dictionary, option: Dictionary) -> bool:
	var matches := (
		str(choice.get("action", "")) == str(option.get("action", ""))
		and int(choice.get("model", -1)) == int(option.get("model", -1))
		and int(choice.get("target", -1)) == int(option.get("target", -1))
		and str(choice.get("value", "")) == str(option.get("value", ""))
	)
	var details: Dictionary = option.get("details", {})
	if details.has("die"): matches = matches and int(choice.get("die", -1)) == int(details.die)
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
	var error: String = Combat.begin_movement(state, player, int(command.get("model", -1)), str(command.get("move_type", "")), int(command.get("revision", -1)), roller, bool(command.get("use_sudden_onslaught", false)))
	if not error.is_empty(): return _failure(error)
	var message := "Roll complete: accept the result or use Command Re-roll before allocation and movement." if not Combat.Stratagems.pending(state).is_empty() else "Movement selected. Allocate any escape wounds, then place models and confirm."
	return _success(message)

static func _finish_movement(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var cancel := bool(command.get("cancel", false))
	var error: String = Combat.finish_movement(state, player, int(command.get("revision", -1)), cancel, roller)
	if not error.is_empty(): return _failure(error)
	var message := "Placement reset; selected move, dice and casualties retained." if cancel and not state.pending_move.is_empty() else "Pending movement cancelled." if cancel else "Squad movement confirmed."
	return _success(message)

static func _charge_roll(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var revision := int(command.get("revision", -1))
	if bool(command.get("decline", false)):
		return _apply_string_action(Combat.decline_charge(state, player, revision), "Charge finished without movement.")
	var result: Dictionary = Combat.declare_charge(state, player, int(command.get("model", -1)), revision, roller)
	return _apply_dictionary_action(result)

static func _begin_contact(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var targets: Array[int] = []
	for target: Variant in command.get("targets", []): targets.append(int(target))
	var error: String = Combat.begin_contact_move(state, player, int(command.get("model", -1)), str(command.get("move_kind", "")), int(command.get("revision", -1)), targets, int(command.get("objective", -1)))
	if not error.is_empty(): return _failure(error)
	var window: Dictionary = state.get("unit_abilities", {}).get("window", {})
	var owners: Array = window.get("owners", [])
	if window.get("kind", "") == Combat.TransportRules.COMBAT_EMBARKATION_WINDOW and not owners.is_empty():
		return _success("Charge placement paused: Player %d must resolve Repulsor Combat Embarkation." % int(owners[0]))
	return _success("Place individual models with right-click, then confirm contact movement.")

static func _finish_contact(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var cancel := bool(command.get("cancel", false))
	var error: String = Combat.finish_contact_move(state, player, int(command.get("revision", -1)), cancel)
	if not error.is_empty(): return _failure(error)
	return _success("Contact placement cancelled; positions restored." if cancel else "Contact movement confirmed.")

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
	var error: String = Deployment.place(state, player, model, destination, revision) if state.phase == "deployment" else Combat.move(state, player, model, destination, revision)
	return _apply_string_action(error, "Deployment position accepted." if state.phase == "deployment" else "Miniature repositioned. Confirm the squad's movement when ready.")

static func _deployment_preset(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var error: String = Deployment.preset(state, player, int(command.get("revision", -1)))
	return _apply_string_action(error, "Preview positions accepted; confirm this unit when ready.")

static func _deployment_confirm(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var error: String = Deployment.confirm(state, player, int(command.get("revision", -1)))
	return _apply_string_action(error, "Unit deployment confirmed.")

static func _allocate_damage(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
	var model := int(command.get("model", -1))
	var revision := int(command.get("revision", -1))
	var pending_attack: Dictionary = state.get("pending_attack", {})
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
	var error: String = Combat.allocate_hazard(state, player, model, revision, roller) if not state.get("pending_hazard", {}).is_empty() else Combat.allocate_damage(state, player, model, revision, roller)
	var message := "Recipient confirmed. The attacker resolves damage before prevention and casualties." if Combat.Stratagems.pending(state).get("kind") == "after_damage_roll" else "Damage choice accepted; continue allocation or the next action window."
	return _apply_string_action(error, message)

static func _remove_coherency(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var model := int(command.get("model", -1))
	var error: String = Combat.remove_for_coherency(state, player, model, int(command.get("revision", -1)))
	return _apply_string_action(error, "Model %d removed for coherency." % model)

static func _command_reaction(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
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
	if kind == "after_escape_roll": error = Combat.resolve_escape_reaction(state, player, squad, stratagem, revision, die, roller)
	elif kind == "after_hazardous_roll": error = Combat.resolve_hazard_reaction(state, player, squad, stratagem, revision, die, roller)
	elif kind in ["after_hit_roll", "after_wound_roll", "after_save_roll", "after_damage_roll", "after_attack_count_roll"]: error = Combat.resolve_attack_reaction(state, player, squad, stratagem, revision, die, roller)
	elif kind == "before_battle_shock": error = Combat.resolve_command_reaction(state, player, squad, stratagem, revision, roller)
	else: error = Combat.resolve_roll_reaction(state, player, squad, stratagem, revision, roller)
	return _apply_string_action(error, "Command reaction resolved.")

static func _select_oath_target(state: Dictionary, player: int, command: Dictionary) -> Dictionary:
	var target := int(command.get("target", -1))
	var error: String = Combat.select_oath_target(state, player, target, int(command.get("revision", -1)))
	return _apply_string_action(error, "Oath of Moment: " + str(state.get("squads", {}).get(target, {}).get("name", "target")) + ". Continue the Command phase.")

static func _resolve_reanimation(state: Dictionary, player: int, command: Dictionary, roller: Callable) -> Dictionary:
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
	var bodyguard := int(command.get("bodyguard", -1))
	var error: String = Combat.select_awakened_attachment(state, player, bodyguard, int(command.get("revision", -1)))
	if not error.is_empty(): return _failure(error)
	var message := "Overlord assignment saved. " + ("Declare the next Overlord." if Combat.Awakened.needs_setup(state) else ("Finish army preparations, then deploy." if Combat.UnitAbilities.enabled(state) else "Review and confirm deployment for every model."))
	return _success(message)

static func _apply_string_action(error: String, message: String) -> Dictionary:
	return _failure(error) if not error.is_empty() else _success(message)

static func _apply_dictionary_action(result: Dictionary) -> Dictionary:
	if not str(result.get("error", "")).is_empty(): return _failure(str(result.error))
	return _success(str(result.get("message", "Command completed.")))

static func _failure(error: String) -> Dictionary:
	return {"error": error, "message": ""}

static func _success(message: String) -> Dictionary:
	return {"error": "", "message": message}
