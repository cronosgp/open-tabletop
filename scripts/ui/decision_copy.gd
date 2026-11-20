extends RefCounted
## Presentation-only instruction and reaction copy for the match HUD.
## Authoritative decision ownership and legality remain in scripts/edition_11/.

const MatchDecisionView = preload("res://scripts/ui/match_decision_view.gd")

static func build_decision(state: Dictionary, actor: int, mode: String, local_player: int, selected: int, combat: Variant, projection: Dictionary, selected_shooting_complete: bool) -> Dictionary:
	var active_player := int(state.get("active", actor))
	var phase := str(state.get("phase", ""))
	var fight_step := str(state.get("fight_step", ""))
	var phase_name := phase.capitalize()
	if phase_name == "Fight" and not fight_step.is_empty():
		phase_name += " · " + fight_step.capitalize()
	var owner_text := "Round %d · %s · Player %d's turn · Player %d decides" % [int(state.get("round", 0)), phase_name, active_player, actor]
	var instruction := ""
	if mode != "local" and actor != local_player:
		owner_text = "Waiting · " + owner_text
		instruction = _waiting_instruction(state, combat, phase)
	else:
		instruction = _active_instruction(state, actor, selected, combat, projection, selected_shooting_complete)
	var view := MatchDecisionView.describe(state, actor, projection, instruction)
	return {"owner_text": owner_text, "view": view}

static func _waiting_instruction(state: Dictionary, combat: Variant, phase: String) -> String:
	var subject := phase.replace("_", " ")
	if combat.Mission.actor(state) > 0: subject = "mission setup"
	elif combat.UnitActions.actor(state) > 0: subject = "a unit ability"
	elif not combat.Reanimation.pending(state).is_empty(): subject = "Reanimation"
	elif not combat.Stratagems.pending(state).is_empty(): subject = "a dice decision"
	elif not state.get("pending_hazard", {}).is_empty(): subject = "Hazardous allocation"
	elif not state.get("pending_attack", {}).is_empty(): subject = "damage allocation"
	elif not state.get("pending_contact", {}).is_empty(): subject = "contact placement"
	elif not state.pending_charge.is_empty(): subject = "charge targets"
	elif not state.pending_move.is_empty(): subject = "movement placement"
	return "Resolving %s." % subject

static func _active_instruction(state: Dictionary, actor: int, selected: int, combat: Variant, projection: Dictionary, selected_shooting_complete: bool) -> String:
	var phase := str(state.get("phase", ""))
	var fight_step := str(state.get("fight_step", ""))
	if combat.Mission.actor(state) > 0:
		return "Mission preparation: use the choice below."
	if combat.Awakened.needs_setup(state):
		return "Required: declare each Overlord standalone or leading a unit before deployment."
	if combat.Doctrines.needs_choice(state):
		return "Required: choose an available Combat Doctrine or no doctrine before continuing Command."
	if combat.UnitActions.actor(state) > 0 and combat.Reanimation.pending(state).is_empty():
		return _unit_action_instruction(state, actor, combat, projection, phase)
	if phase == "deployment":
		return "Place the current unit in its deployment zone."
	if not combat.Reanimation.pending(state).is_empty():
		return "Required: resolve Reanimation for each unit before leaving Command. Positions are previews until confirmed."
	if combat.OathOfMoment.needs_choice(state):
		return "Required: choose one enemy as your Oath of Moment target before continuing Command."
	if not combat.Stratagems.pending(state).is_empty():
		var roll_window: Dictionary = combat.Stratagems.pending(state)
		if roll_window.kind == "before_battle_shock": return "Battle-shock pending: choose a unit and roll, or use Insane Bravery (1 CP)."
		if roll_window.get("honour_vigilance", false): return "Advance pending: accept the roll or use Honour of Vigilance to re-roll it for 0 CP."
		if roll_window.get("valour", false): return "Charge: accept or use Unstoppable Valour to re-roll both dice for 0 CP."
		return "Decision pending: accept the roll or use Command Re-roll (1 CP) to continue."
	if not state.get("pending_hazard", {}).is_empty():
		return "Required: select an eligible model, then allocate Hazardous wounds."
	if not state.get("pending_attack", {}).is_empty():
		match str(state.pending_attack.current.phase):
			"precision": return "Choose a visible character for Precision, or choose Do not use Precision."
			"order": return "Required: select a model from the next defense group, then confirm its allocation group."
			_: return "Required: select an eligible model, then allocate the attack's damage."
	if not state.get("pending_contact", {}).is_empty():
		return "Place the unit's models, then confirm or cancel contact placement."
	if not combat.UnitAbilities.Detection.selection(state).is_empty():
		return "Shoot with the selected Eliminators, or cancel in Unit abilities."
	if phase == "end_turn" and combat.incoherent_squad(state) != -1:
		return "Required: remove models to restore unit coherency before ending the turn."
	if phase == "movement" and state.pending_move.is_empty():
		if state.units.has(selected) and state.squads[state.units[selected].squad].moved:
			return "Move complete. Choose another unit or continue to Shooting."
		return "Choose a move, then Begin move." if state.units.has(selected) and state.units[selected].owner == actor else "Choose a unit above or click a miniature."
	if phase == "movement":
		return "Place the unit, then Confirm move."
	if phase == "shooting" and selected_shooting_complete:
		return "Shooting complete for this unit. Choose another unit or continue to Charge."
	if phase == "shooting":
		return "Select your unit, then Plan attacks."
	if phase == "charge" and state.pending_charge.is_empty():
		return "Select your unit, then Roll charge — or Continue."
	if phase == "charge":
		return "Choose charge targets, then Begin placement."
	if phase == "fight":
		return {"pile_in": "Choose a unit for pile-in, or decline.", "attacks": "Choose a unit, then Plan attacks.", "consolidation_reaction": "Choose a unit for the reaction attacks.", "consolidate": "Choose a unit to consolidate, or decline.", "complete": "Fight complete. Continue to the next step."}.get(fight_step, "Follow the current Fight options.")
	if phase in ["start_turn", "command"]:
		return "Advance the phase."
	return "Use the options below."

static func _unit_action_instruction(state: Dictionary, actor: int, combat: Variant, projection: Dictionary, phase: String) -> String:
	if combat.UnitActions.setup_actor(state) > 0:
		return "Choose Warlord/Support and finish army preparations."
	if combat.UnitActions.battle_actor(state) > 0:
		return "Optional: place or skip Terminator Homers, then finish setup."
	var pending: Dictionary = combat.UnitActions.pending(state)
	var kind := str(pending.get("kind", ""))
	if phase == "shooting" and actor != int(state.active) and pending.has("declaration"):
		return "Attack declared. Resolve the defender's choice before rolling dice."
	if kind in ["healing", "healing-order"]:
		return "Unit healing: resolve wounds and confirm returned-model previews."
	if kind == "ingress":
		return "Required: preview every arriving model, then confirm the coherent unit or cancel ingress."
	if kind == combat.UnitActions.HeresyRetribution.WINDOW:
		return "Heresy Begets Retribution: preview every model's Surge move, follow the selected target's movement rules, then confirm."
	if kind == combat.UnitActions.CrusaderSurge.WINDOW:
		return "Righteous Zeal: choose to make a D6+1-inch Surge move or pass."
	if kind == combat.UnitActions.CrusaderSurge.TARGET_WINDOW:
		return "Righteous Zeal: select a closest enemy target, or a closest objective with Purge and Sanctify."
	if kind == combat.UnitActions.CrusaderSurge.PLACEMENT:
		return "Righteous Zeal: preview every model within the rolled distance, preserve coherency and the target end-position rules, then confirm."
	if kind == "bladeguard":
		return "Bladeguard: choose a stance or decline. Attack dice wait."
	if kind == "wound":
		return "Implacable Eradication: choose free wound rerolls, then keep the remaining dice to continue to saves."
	if actor != int(state.active) and bool(projection.get("pass_allowed", false)):
		return _reaction_instruction(actor, int(state.active), projection)
	return "Required: resolve or decline the current unit ability window."

static func _reaction_instruction(actor: int, active_player: int, projection: Dictionary) -> String:
	var options: Array = projection.get("legal_options", [])
	var reaction_actions: Array[String] = []
	var reaction_label := ""
	for option: Variant in options:
		if not option is Dictionary: continue
		var action := str(option.get("action", ""))
		if action == "pass" or action.ends_with("-pass") or str(option.get("value", "")) == "pass":
			continue
		if action not in reaction_actions:
			reaction_actions.append(action)
		if reaction_label.is_empty():
			reaction_label = str(option.get("label", ""))
	if reaction_actions.size() == 1:
		var action := reaction_actions[0]
		if action == "heroic-intervention":
			return "Player %d: use Heroic Intervention (2 CP) or decline and return to Player %d." % [actor, active_player]
		if action == "fire-overwatch":
			return "Player %d: use Fire Overwatch (1 CP) or decline and return to Player %d." % [actor, active_player]
		if not reaction_label.is_empty():
			return "Player %d: use %s, or decline and return to Player %d." % [actor, reaction_label, active_player]
	return "Player %d: choose an optional reaction or decline and return to Player %d." % [actor, active_player]
