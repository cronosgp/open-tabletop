extends SceneTree
## Controlled dice in this regression only. No combat state or terrain is staged.
const Training = preload("res://scripts/edition_11/training_roster.gd")
const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const C = Prepared.Combat
const Commands = preload("res://scripts/edition_11/match_command_service.gd")
const PublicChoice = preload("res://tests/public_unit_command.gd")
const Decisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const Frames = preload("res://scripts/edition_11/resolution_frame.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Bladeguard = preload("res://scripts/edition_11/bladeguard.gd")
var failures := 0
var state: Dictionary
var stance_used := false
var stance_recovered := false
var dice_calls := 0

func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func one() -> int:
	dice_calls += 1
	return 1
func six() -> int:
	dice_calls += 1
	return 6
func command(owner: int, intent: Dictionary, roller: Callable = one) -> Dictionary:
	intent.revision = state.revision
	var result := Commands.execute(state, owner, intent, roller)
	check(str(result.get("error", "")).is_empty(), "Public %s: %s" % [str(intent.kind), str(result)])
	return result
func model_of(owner: int, slug: String) -> int:
	for model: int in state.units:
		if int(state.units[model].owner) == owner and str(state.units[model].definition_id).ends_with(":" + slug) and int(state.units[model].wounds) > 0: return model
	return -1
func raw_choice(owner: int, action: String, model: int = -2, target: int = -2, value: String = "*") -> Dictionary:
	for choice: Dictionary in C.unit_choices(state, owner):
		if str(choice.action) != action: continue
		if model != -2 and int(choice.get("model", -1)) != model: continue
		if target != -2 and int(choice.get("target", -1)) != target: continue
		if value != "*" and str(choice.get("value", "")) != value: continue
		return choice
	return {}
func choose(owner: int, selected: Dictionary) -> void:
	check(not selected.is_empty(), "An expected live unit choice exists")
	if selected.is_empty(): return
	var result := PublicChoice.submit(state, owner, selected, Vector2.ZERO, one)
	check(str(result.get("error", "")).is_empty(), "Public unit choice: " + str(result))

func resolve_one() -> bool:
	var decision := Decisions.current(state, ["unit-actions", "combat-doctrines", "stratagems", "damage-allocation"])
	if decision.is_empty():
		if not state.get("pending_hazard", {}).is_empty():
			var eligible := C.Hazard.eligible(state)
			if not eligible.is_empty():
				command(int(state.pending_hazard.player), {"kind": Commands.ALLOCATE_DAMAGE, "model": eligible[0]})
				return true
		return false
	var owner := int(decision.priority_player_id)
	var selected: Dictionary = {}
	for option: Dictionary in decision.legal_options:
		var action := str(option.action)
		if action == "bladeguard" and str(option.value) == "attack":
			selected = option
			break
		if action in ["pass", "battle-done"] or action.ends_with("-pass") or (str(decision.source) == "stratagems" and str(option.value).is_empty()) or (str(decision.source) == "combat-doctrines" and str(option.value) == "none"):
			selected = option
			break
	if selected.is_empty() and str(decision.source) == "damage-allocation": selected = decision.legal_options[0]
	if selected.is_empty(): return false
	match str(decision.source):
		"unit-actions":
			var raw := raw_choice(owner, str(selected.action), int(selected.model), int(selected.target), str(selected.value))
			if str(selected.action) == "bladeguard":
				var before := var_to_str(state)
				var frame := Frames.current(state).duplicate(true)
				var calls_before := dice_calls
				check(not PublicChoice.error(state, 3 - owner, raw).is_empty() and var_to_str(state) == before, "The opponent cannot choose a Bladeguard stance")
				var envelope := {"_decision_type": Commands.UNIT_CHOICE_ENVELOPE, "decision_id": decision.decision_id, "option_id": selected.id, "choice": raw}
				var stale := Commands.execute(state, owner, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": state.revision - 1, "choice": envelope}, one)
				check(not str(stale.get("error", "")).is_empty() and var_to_str(state) == before, "A stale revision cannot consume the live stance")
				var obsolete := envelope.duplicate(true)
				obsolete.option_id = "obsolete-option"
				var invalid_option := Commands.execute(state, owner, {"kind": Commands.SELECT_UNIT_CHOICE, "revision": state.revision, "choice": obsolete}, one)
				check(not str(invalid_option.get("error", "")).is_empty() and var_to_str(state) == before, "An obsolete option cannot consume the live stance")
				var blocked := Commands.execute(state, owner, {"kind": Commands.ADVANCE_PHASE, "revision": state.revision}, one)
				check(not str(blocked.get("error", "")).is_empty() and var_to_str(state) == before, "Fight cannot advance through its pending stance")
				state = bytes_to_var(var_to_bytes(state))
				stance_recovered = Decisions.current(state, ["unit-actions"]) == decision and Frames.current(state) == frame and not frame.is_empty()
				check(stance_recovered and dice_calls == calls_before, "The live melee decision and attack frame survive serialization before dice")
			choose(owner, raw)
			if str(selected.action) == "bladeguard":
				stance_used = Bladeguard.mode(state, int(selected.target)) == "attack"
				check(stance_used, "The accepted stance activates its offensive mode")
		"combat-doctrines": command(owner, {"kind": Commands.SELECT_DOCTRINE, "doctrine": selected.value, "decision_id": decision.decision_id, "option_id": selected.id})
		"stratagems":
			var choice := {"action": "stratagem-reaction", "model": int(selected.model), "target": int(selected.target), "value": str(selected.value), "die": int(selected.get("details", {}).get("die", -1))}
			var envelope := {"_decision_type": Commands.STRATAGEM_DECISION_ENVELOPE, "decision_id": decision.decision_id, "option_id": selected.id, "choice": choice}
			command(owner, {"kind": Commands.COMMAND_REACTION, "choice": envelope})
		"damage-allocation": command(owner, {"kind": Commands.ALLOCATE_DAMAGE, "model": selected.model, "decision_id": decision.decision_id, "option_id": selected.id})
	return true
func settle() -> void:
	for step in range(80):
		if failures > 0 or not resolve_one(): return
	check(false, "Pending combat work must settle within a bounded number of choices")
func advance() -> void:
	var owner := C.actor(state)
	var selected := -1
	if state.phase == "fight":
		var eligible := C.FightQueue.choices(state, owner)
		if not eligible.is_empty(): selected = C.living(state, int(eligible[0]))[0]
	command(owner, {"kind": Commands.ADVANCE_PHASE, "model": selected})
func move_squad(squad: int, shift: Vector2) -> void:
	var ids := C.living(state, squad)
	var owner := int(state.squads[squad].owner)
	command(owner, {"kind": Commands.BEGIN_MOVEMENT, "model": ids[0], "move_type": "normal"})
	for model: int in ids:
		command(owner, {"kind": Commands.PLACE_MODEL, "model": model, "destination": state.units[model].position + shift})
	command(owner, {"kind": Commands.FINISH_MOVEMENT})

func run() -> void:
	var armies: Dictionary = {}
	for owner: int in [1, 2]:
		var report := Training.admit_current_catalog(Training.Tactical.army(owner == 2).list)
		check(str(report.get("error", "")).is_empty(), "Both combat forces use current catalog admission")
		armies[owner] = report.selection
	state = Prepared.initial_state({"unit_abilities": true, "combat_doctrines": true, "marine_detachment": "gladius", "core_stratagems": true, "movement_rerolls": true, "attack_rerolls": true, "save_rerolls": true, "damage_rerolls": true, "hazard_rerolls": true, "count_rerolls": true, "escape_rerolls": true, "training_scenario_id": Training.Tactical.ID}, armies)
	check(not state.has("error"), "The real tactical prepared-match constructor admits the scenario")
	if failures > 0:
		quit(1)
		return
	for owner: int in [1, 2]:
		var leader := model_of(owner, "captain" if owner == 1 else "chaplain")
		var bodyguard := model_of(owner, "intercessor-squad" if owner == 1 else "assault-intercessor-squad")
		choose(owner, raw_choice(owner, "warlord", leader))
		choose(owner, raw_choice(owner, "attach", leader, int(state.units[bodyguard].squad)))
		choose(owner, raw_choice(owner, "setup-done"))
	for step in range(8):
		var squad := Prepared.Deployment.current(state)
		if squad < 0: break
		var owner := Prepared.Deployment.actor(state)
		var ids := C.living(state, squad)
		var lower := str(state.units[ids[0]].definition_id).ends_with(":hellblaster-squad") or str(state.units[ids[0]].definition_id).ends_with(":bladeguard-veteran-squad")
		for index in range(ids.size()):
			command(owner, {"kind": Commands.PLACE_MODEL, "model": ids[index], "destination": Vector2(-12 if owner == 1 else 12, (-12 if lower else 6) + index * 1.65)})
		command(owner, {"kind": Commands.DEPLOYMENT_CONFIRM})
	check(state.deployment.complete, "Both forces deploy through legal per-model commands")
	var hellblaster := model_of(1, "hellblaster-squad")
	var bladeguard := model_of(2, "bladeguard-veteran-squad")
	var hell_squad := int(state.units[hellblaster].squad)
	var blade_squad := int(state.units[bladeguard].squad)
	var captain_used := false
	for step in range(60):
		if failures > 0: break
		if resolve_one(): continue
		if state.phase == "command" and int(state.active) == 1 and not captain_used:
			var captain := model_of(1, "captain")
			var acumen := raw_choice(1, "acumen", captain, int(state.units[captain].squad), "devastator")
			if not acumen.is_empty():
				choose(1, acumen)
				captain_used = C.Doctrines.has_doctrine(state, int(state.units[captain].squad), "devastator")
				check(captain_used, "The attached Captain's Strategic Acumen activates its real doctrine effect")
				continue
		if state.phase == "shooting" and int(state.active) == 1: break
		if state.phase == "movement" and not state.squads[hell_squad].moved:
			move_squad(hell_squad, Vector2(6, 0))
			continue
		advance()
	check(state.phase == "shooting" and int(state.active) == 1, "Real setup and movement reach the first shooting checkpoint")
	check(captain_used, "The tactical lifecycle exercises a leader ability before shooting")
	check(bool(Training.Tactical.experiment_progress(state).leader), "The tactical checklist records the Captain's real leader ability")
	var shooting_checkpoint := var_to_bytes(state)
	var standard_result := plasma(hell_squad, blade_squad, "standard")
	check(standard_result and C.living(state, hell_squad).size() == 5, "Standard plasma leaves the firing models alive with controlled misses")
	var post_standard := var_to_bytes(state)
	check(bool(state.get("training_experiments", {}).get("standard_plasma", false)), "The tactical checklist records the standard plasma experiment after its real attack resolves")
	state = bytes_to_var(shooting_checkpoint)
	var overloaded_result := plasma(hell_squad, blade_squad, "supercharge")
	check(overloaded_result and C.living(state, hell_squad).size() < 5, "Supercharged plasma resolves actual failed Hazardous tests against its firing unit")
	check(bool(state.get("training_experiments", {}).get("supercharged_plasma", false)) and bool(state.get("training_experiments", {}).get("hazardous", false)), "The tactical checklist records supercharge and Hazardous resolution")
	# Continue the standard-shot branch of the exact legal checkpoint for Charge/Fight.
	state = bytes_to_var(post_standard)
	for step in range(80):
		if failures > 0: break
		if resolve_one(): continue
		if state.phase == "charge" and int(state.active) == 2: break
		if state.phase == "movement" and int(state.active) == 2 and not state.squads[blade_squad].moved:
			move_squad(blade_squad, Vector2(-6, 0))
			continue
		advance()
	command(2, {"kind": Commands.CHARGE_ROLL, "model": bladeguard}, six)
	settle()
	command(2, {"kind": Commands.CHARGE_TARGET, "target": hellblaster})
	command(2, {"kind": Commands.BEGIN_CONTACT, "model": bladeguard, "move_kind": "charge"})
	var plan := Geometry.charge_plan(state, blade_squad, hell_squad, float(state.pending_charge.get("maximum", 0)))
	check(str(plan.get("error", "")).is_empty(), "The normal geometry planner finds a legal charge path")
	for model: int in plan.get("positions", {}): command(2, {"kind": Commands.STAGE_CONTACT, "model": model, "destination": plan.positions[model]})
	command(2, {"kind": Commands.FINISH_CONTACT})
	check(state.squads[blade_squad].charged and state.pending_charge.is_empty(), "The charge commits through target, placement and confirmation")
	var melee_completed := false
	var stance_applied_to_pool := false
	for step in range(80):
		if failures > 0: break
		if resolve_one(): continue
		if state.phase == "fight" and state.fight_step == "complete": break
		if state.phase == "fight" and state.fight_step in ["attacks", "consolidation_reaction"]:
			var owner := C.actor(state)
			for squad: int in C.FightQueue.choices(state, owner):
				var target := hell_squad if owner == 2 else blade_squad
				var entries := C.AttackPlan.single_target(state, squad, target, true)
				if entries.is_empty(): continue
				command(owner, {"kind": Commands.ATTACK_PLAN, "attacker": C.living(state, squad)[0], "entries": entries, "melee": true, "use_lethal": false})
				settle()
				if owner == 2 and bool(state.squads[squad].fought):
					for pool: Dictionary in state.get("last_attack", {}).get("pools", []):
						if int(pool.get("hit_modifier", 0)) == 1: stance_applied_to_pool = true
				if bool(state.squads[squad].fought): melee_completed = true
				break
			if melee_completed and state.squads[blade_squad].fought and state.squads[hell_squad].fought:
				advance()
			continue
		advance()
	check(melee_completed and state.squads[blade_squad].fought and state.squads[hell_squad].fought, "Both actual engaged units resolve melee attacks")
	check(stance_used and stance_recovered, "The live charged Bladeguard attack exercises its persisted stance decision")
	check(bool(Training.Tactical.experiment_progress(state).bladeguard), "The tactical checklist records the accepted Bladeguard stance")
	check(stance_applied_to_pool, "The selected Bladeguard stance actually modifies its resolved attack pool")
	check(state.phase == "fight" and state.fight_step == "complete", "The public Fight sequence reaches consolidation and completion")
	check(Frames.current(state).is_empty() and state.pending_attack.is_empty() and state.pending_contact.is_empty(), "The completed Fight leaves no suspended attack or contact continuation")
	print("Tactical combat flow: %d failures; plasma standard/supercharge, charge and melee exercised" % failures)
	quit(0 if failures == 0 else 1)

func plasma(squad: int, target: int, profile: String) -> bool:
	var entries: Array = []
	for model: int in C.living(state, squad):
		entries.append({"model": model, "target": target, "weapon": "plasma-incinerator", "profile": profile, "amount": 1})
	var result := command(1, {"kind": Commands.ATTACK_PLAN, "attacker": C.living(state, squad)[0], "entries": entries, "melee": false, "use_lethal": false})
	settle()
	return str(result.get("error", "")).is_empty() and state.pending_attack.is_empty() and bool(state.squads[squad].shot) and not state.get("last_attack", {}).is_empty()
