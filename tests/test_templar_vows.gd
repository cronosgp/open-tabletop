extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const TemplarVows = preload("res://scripts/edition_11/templar_vows.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const C = Prepared.Combat

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func army(identity: String) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:%s" % identity, "models": 1, "copies": 1}]}

func fresh(enemy_identity: String = "librarian") -> Dictionary:
	return Prepared.initial_state({
		"manual_allocation": false,
		"unit_abilities": true,
		"combat_doctrines": true,
		"marine_detachments": {1: "vow-sworn-crusaders", 2: "gladius"},
		"marine_chapters": {1: "BLACK TEMPLARS"}
	}, {1: army("captain"), 2: army(enemy_identity)})

func squad_for(state: Dictionary, owner: int) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner: return squad
	return -1

func model_for(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0: return model
	return -1

func prepare_vow_window(state: Dictionary) -> void:
	state.phase = "start_turn"
	state.active = 1
	state.turn = 1
	state.round = 1
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.setup_done = true
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = []
	state.unit_abilities.phase_key = C.UnitActions.key(state)

func prepare_melee(state: Dictionary, attacker_squad: int, defender_squad: int, charged: bool = true) -> Dictionary:
	var attacker := model_for(state, attacker_squad)
	var defender := model_for(state, defender_squad)
	state.phase = "fight"
	state.active = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.squads[attacker_squad].fight_eligible = true
	state.squads[attacker_squad].charged = charged
	state.units[attacker].position = Vector2(0, 0)
	state.units[defender].position = Vector2(1.5, 0)
	state.pending_attack = {}
	state.resolution_frames = []
	var weapon: Dictionary = state.units[attacker].melee_weapons[0]
	var profile: Dictionary = weapon.profiles.standard
	return C.AttackPlan.prepare(state, attacker_squad, true, [{"model": attacker, "target": defender_squad, "amount": int(profile.attacks), "weapon": str(weapon.id), "profile": "standard"}], true)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var missing_abilities := Prepared.initial_state({"combat_doctrines": true, "marine_detachment": "vow-sworn-crusaders"}, {1: army("captain"), 2: army("librarian")})
	check(missing_abilities.has("error"), "Vow-sworn Crusaders requires current unit abilities and Black Templars context")
	var state := fresh()
	check(not state.has("error"), "Current-reference Captain and Librarian enter bounded Vow-sworn practice: %s" % str(state.get("error", "")))
	if state.has("error"):
		print("Templar Vows checks: %d failures" % (failures + 1))
		quit(1)
		return
	var crusaders := squad_for(state, 1)
	var psyker := squad_for(state, 2)
	prepare_vow_window(state)
	var choices := C.UnitActions.choices(state, 1).filter(func(choice: Dictionary) -> bool: return str(choice.get("action", "")).begins_with("templar-vow"))
	check(choices.size() == 4 and TemplarVows.needs_choice(state, 1), "First-round start offers each Vow and a skip choice")
	var abhor_choice: Dictionary = {}
	for choice: Dictionary in choices:
		if str(choice.get("value", "")) == TemplarVows.ABHOR: abhor_choice = choice
	var abhor_result := PublicUnitCommand.submit(state, 1, abhor_choice, Vector2.ZERO) if not abhor_choice.is_empty() else {"error": "Abhor the Witch choice missing."}
	check(str(abhor_result.get("error", "")).is_empty() and TemplarVows.selected_vow(state, 1) == TemplarVows.ABHOR and not TemplarVows.needs_choice(state, 1), "The public choice selects one Vow for the battle exactly once")
	var abhor_attack := prepare_melee(state, crusaders, psyker)
	var abhor_profile: Dictionary = abhor_attack.get("batches", [{}])[0].get("weapon", {}) if not abhor_attack.get("batches", []).is_empty() else {}
	var abhor_context: Dictionary = abhor_attack.get("batches", [{}])[0].get("context", {}) if not abhor_attack.get("batches", []).is_empty() else {}
	check(abhor_attack.get("error", "").is_empty() and abhor_profile.get("keywords", {}).get("precision", false) and int(abhor_context.get("wound_modifier", 0)) == 1, "Abhor grants Precision and the Lance Wound bonus against the sourced PSYKER profile after a Charge")
	var uncharged_abhor := prepare_melee(state, crusaders, psyker, false)
	var uncharged_context: Dictionary = uncharged_abhor.get("batches", [{}])[0].get("context", {}) if not uncharged_abhor.get("batches", []).is_empty() else {}
	check(int(uncharged_context.get("wound_modifier", 0)) == 0, "Abhor's Lance does not add its Wound modifier without a Charge")

	var challenge_state := fresh("redemptor-dreadnought")
	check(not challenge_state.has("error"), "A current-reference higher-Toughness target is admitted for the Challenge rule")
	if not challenge_state.has("error"):
		var challenge_owner := squad_for(challenge_state, 1)
		var vehicle := squad_for(challenge_state, 2)
		prepare_vow_window(challenge_state)
		check(TemplarVows.apply_choice(challenge_state, 1, {"value": TemplarVows.CHALLENGE}).is_empty(), "Accept Any Challenge can be selected in the first-round window")
		var challenge_attack := prepare_melee(challenge_state, challenge_owner, vehicle)
		var challenge_context: Dictionary = challenge_attack.get("batches", [{}])[0].get("context", {}) if not challenge_attack.get("batches", []).is_empty() else {}
		check(challenge_attack.get("error", "").is_empty() and int(challenge_context.get("wound_modifier", 0)) == 1, "Accept Any Challenge adds +1 to Wound against a sourced tougher Redemptor target")

	var uphold_state := fresh()
	if not uphold_state.has("error"):
		var uphold_squad := squad_for(uphold_state, 1)
		var uphold_model := model_for(uphold_state, uphold_squad)
		prepare_vow_window(uphold_state)
		check(TemplarVows.apply_choice(uphold_state, 1, {"value": TemplarVows.UPHOLD}).is_empty(), "Uphold can be selected")
		uphold_state.phase = "movement"
		uphold_state.active = 1
		uphold_state.squads[uphold_squad].advanced = true
		var eligibility := C.Actions.eligibility_error(uphold_state, uphold_squad)
		var objective: Dictionary = uphold_state.mission.objectives[0]
		uphold_state.units[uphold_model].position = objective.bounds.get_center()
		objective.controller = 1
		objective.secured = 0
		TemplarVows.secure_controlled_objectives(uphold_state, 1, Callable(C.Morale, "objective_control"))
		check(eligibility.is_empty() and int(uphold_state.mission.objectives[0].get("secured", 0)) == 1, "Uphold retains action eligibility after Advancing and secures a controlled objective at Movement end")

	print("Templar Vows checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
