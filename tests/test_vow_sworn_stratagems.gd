extends SceneTree

const Prepared = preload("res://scripts/edition_11/prepared_training.gd")
const DetachmentStratagems = preload("res://scripts/edition_11/detachment_stratagems.gd")
const HeresyRetribution = preload("res://scripts/edition_11/heresy_retribution.gd")
const C = Prepared.Combat

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_six() -> int:
	return 6

func roll_one() -> int:
	return 1

func army(identity: String, model_count: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "training", "points_limit": 500,
		"entries": [{"definition_id": "40kdc:11e:adeptus-astartes:" + identity, "models": model_count, "copies": 1}]}

func fresh(owner_identity: String = "chaplain", enemy_identity: String = "redemptor-dreadnought", owner_count: int = 1, enemy_count: int = 1) -> Dictionary:
	return Prepared.initial_state({
		"manual_allocation": false,
		"core_stratagems": true,
		"unit_abilities": true,
		"combat_doctrines": true,
		"marine_detachments": {1: "vow-sworn-crusaders", 2: "gladius"},
		"marine_chapters": {1: "BLACK TEMPLARS"}
	}, {1: army(owner_identity, owner_count), 2: army(enemy_identity, enemy_count)})

func squad_for(state: Dictionary, owner: int) -> int:
	for squad: int in state.squads:
		if int(state.squads[squad].get("owner", -1)) == owner: return squad
	return -1

func model_for(state: Dictionary, squad: int) -> int:
	for model: int in state.units:
		if int(state.units[model].get("squad", -1)) == squad and int(state.units[model].get("wounds", 0)) > 0: return model
	return -1

func alive_models(state: Dictionary, squad: int) -> Array[int]:
	return C.living(state, squad)

func set_fight_attack_window(state: Dictionary, squad: int, window_kind: String) -> int:
	var target_squad := squad_for(state, 2)
	var attacker := model_for(state, squad)
	var target := model_for(state, target_squad)
	state.phase = "fight"
	state.active = 1
	state.turn = 1
	state.fight_actor = 1
	state.fight_step = "attacks"
	state.fight_selected = squad
	state.squads[squad].fight_eligible = true
	state.squads[squad].fought = false
	state.units[attacker].position = Vector2.ZERO
	state.units[target].position = Vector2(1.5, 0)
	state.unit_abilities.setup_done = true
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.window = {"kind": window_kind, "owners": [1], "squad": squad,
		"declaration": {"kind": "attack", "player": 1, "squad": squad, "melee": true}}
	return target_squad

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var pious_state := fresh()
	check(not pious_state.has("error"), "Chaplain and Redemptor enter the local Vow-sworn Pious Enmity scenario: %s" % str(pious_state.get("error", "")))
	if not pious_state.has("error"):
		var pious_squad := squad_for(pious_state, 1)
		var target_squad := set_fight_attack_window(pious_state, pious_squad, DetachmentStratagems.PIOUS_ENMITY_WINDOW)
		pious_state.cp[1] = 5
		var choices := DetachmentStratagems.pious_enmity_choices(pious_state, 1)
		var selected: Dictionary = {}
		for candidate: Dictionary in choices:
			if str(candidate.get("mode", "")) == "monster-vehicle-ones": selected = candidate
		check(choices.size() == 2 and not selected.is_empty(), "Pious Enmity offers both modes at the Chaplain's Fight selection")
		if not selected.is_empty():
			var before_cp: int = pious_state.cp[1]
			var result := DetachmentStratagems.apply(pious_state, 1, selected)
			var attacker := model_for(pious_state, pious_squad)
			var weapon: Dictionary = pious_state.units[attacker].melee_weapons[0]
			var plan := C.AttackPlan.prepare(pious_state, pious_squad, true, [{"model": attacker, "target": target_squad, "amount": int(weapon.profiles.standard.attacks), "weapon": str(weapon.id), "profile": "standard"}], false)
			var context: Dictionary = plan.get("batches", [{}])[0].get("context", {}) if not plan.get("batches", []).is_empty() else {}
			check(str(result.get("error", "")).is_empty() and pious_state.cp[1] == before_cp - 1 and context.get("hit_reroll", "") == "ones" and context.get("wound_reroll", "") == "ones", "Pious Enmity spends 1 CP and grants Hit/Wound rerolls of 1 against the Redemptor")

	var honour_state := fresh("chaplain", "redemptor-dreadnought")
	if not honour_state.has("error"):
		var honour_squad := squad_for(honour_state, 1)
		var target_squad := set_fight_attack_window(honour_state, honour_squad, DetachmentStratagems.FOR_THE_EMPERORS_HONOUR_WINDOW)
		honour_state.cp[1] = 5
		var options := DetachmentStratagems.for_emperors_honour_choices(honour_state, 1)
		var used := DetachmentStratagems.apply(honour_state, 1, options[0]) if not options.is_empty() else {"error": "For the Emperor's Honour! choice missing."}
		var attacker := model_for(honour_state, honour_squad)
		var weapon: Dictionary = honour_state.units[attacker].melee_weapons[0]
		var plan := C.AttackPlan.prepare(honour_state, honour_squad, true, [{"model": attacker, "target": target_squad, "amount": int(weapon.profiles.standard.attacks), "weapon": str(weapon.id), "profile": "standard"}], false)
		var profile: Dictionary = plan.get("batches", [{}])[0].get("weapon", {}) if not plan.get("batches", []).is_empty() else {}
		check(str(used.get("error", "")).is_empty() and bool(profile.get("keywords", {}).get("precision", false)), "For the Emperor's Honour! adds Precision to the unit's melee AttackPlan")
	else:
		check(false, "Chaplain and Redemptor enter the For the Emperor's Honour! scenario: %s" % str(honour_state.get("error", "")))

	var spoor_state := fresh("intercessor-squad", "intercessor-squad", 5, 5)
	check(not spoor_state.has("error"), "Both five-model Intercessor units enter the Spoor scenario: %s" % str(spoor_state.get("error", "")))
	if not spoor_state.has("error"):
		var spoor_squad := squad_for(spoor_state, 1)
		var target_squad := squad_for(spoor_state, 2)
		var attacker := model_for(spoor_state, spoor_squad)
		for model: int in alive_models(spoor_state, target_squad): spoor_state.units[model].position = Vector2(10, float(model - model_for(spoor_state, target_squad)) * 3.0)
		spoor_state.units[attacker].position = Vector2.ZERO
		spoor_state.phase = "shooting"
		spoor_state.active = 1
		spoor_state.turn = 1
		spoor_state.squads[spoor_squad].set_up_this_turn = false
		spoor_state.squads[spoor_squad].moved_distance = 0.0
		spoor_state.unit_abilities.window = {"kind": DetachmentStratagems.SPOOR_OF_THE_UNHOLY_WINDOW, "owners": [1], "squad": spoor_squad,
			"declaration": {"kind": "attack", "player": 1, "squad": spoor_squad, "melee": false}}
		var weapon: Dictionary = spoor_state.units[attacker].ranged_weapons[0]
		var entry := {"model": attacker, "target": target_squad, "amount": 1, "weapon": str(weapon.id), "profile": "focused_fire"}
		var before := C.AttackPlan.prepare(spoor_state, spoor_squad, false, [entry], false)
		spoor_state.cp[1] = 5
		var options := DetachmentStratagems.spoor_of_the_unholy_choices(spoor_state, 1)
		var used := DetachmentStratagems.apply(spoor_state, 1, options[0]) if not options.is_empty() else {"error": "Spoor of the Unholy choice missing."}
		var after := C.AttackPlan.prepare(spoor_state, spoor_squad, false, [entry], false)
		var before_context: Dictionary = before.get("batches", [{}])[0].get("context", {}) if not before.get("batches", []).is_empty() else {}
		var after_context: Dictionary = after.get("batches", [{}])[0].get("context", {}) if not after.get("batches", []).is_empty() else {}
		check(before.get("error", "").is_empty() and int(before_context.get("hit_modifier", 0)) == 1, "A stationary focused Bolt Rifle receives Heavy's +1 Hit modifier before Spoor")
		check(str(used.get("error", "")).is_empty() and after.get("error", "").is_empty() and int(after_context.get("hit_modifier", 1)) == 0, "Spoor of the Unholy removes the Hit modifier from the ranged AttackPlan")

	var dread_state := fresh("chaplain", "librarian")
	if not dread_state.has("error"):
		var target_squad := squad_for(dread_state, 1)
		var charging_squad := squad_for(dread_state, 2)
		dread_state.phase = "charge"
		dread_state.active = 2
		dread_state.turn = 1
		dread_state.cp[1] = 5
		dread_state.pending_charge = {"squad": charging_squad, "targets": [target_squad]}
		var opened := DetachmentStratagems.open_dread_crusaders_reaction(dread_state, charging_squad, target_squad, "charge-frame-test")
		var options := DetachmentStratagems.dread_crusaders_choices(dread_state, 1)
		var before_cp: int = dread_state.cp[1]
		var result := DetachmentStratagems.apply(dread_state, 1, options[0], Callable(self, "roll_one")) if not options.is_empty() else {"error": "Dread Crusaders choice missing."}
		var morale: Dictionary = dread_state.get("last_morale", [{}])[0] if not dread_state.get("last_morale", []).is_empty() else {}
		check(opened and not options.is_empty() and str(result.get("error", "")).is_empty() and dread_state.cp[1] == before_cp - 1, "Dread Crusaders opens for the selected friendly Infantry charge target and spends 1 CP")
		check(int(morale.get("modifier", 0)) == -1 and int(morale.get("modified_total", 0)) == 1 and bool(dread_state.squads[charging_squad].battle_shocked), "Dread Crusaders applies -1 to the charging unit's Battle-shock roll")
	else:
		check(false, "Chaplain and Librarian enter the Dread Crusaders scenario: %s" % str(dread_state.get("error", "")))

	var push_state := fresh("chaplain", "librarian")
	if not push_state.has("error"):
		var push_squad := squad_for(push_state, 1)
		var enemy_squad := squad_for(push_state, 2)
		var push_model := model_for(push_state, push_squad)
		push_state.phase = "fight"
		push_state.active = 1
		push_state.turn = 1
		push_state.fight_actor = 1
		push_state.fight_step = "pile_in"
		push_state.squads[push_squad].charged = true
		push_state.squads[push_squad].fight_eligible = true
		push_state.units[push_model].position = Vector2.ZERO
		push_state.units[model_for(push_state, enemy_squad)].position = Vector2(3.5, 0)
		push_state.cp[1] = 5
		var before_cp: int = push_state.cp[1]
		var begin_error := C.begin_contact_move(push_state, 1, push_model, "pile_in", push_state.revision, [], -1, Callable(self, "roll_six"), false, true)
		var first_roll := DetachmentStratagems.devout_push_roll(push_state, 1, push_squad)
		var first_maximum := float(push_state.get("pending_contact", {}).get("maximum", 0.0))
		var cancel_error := C.finish_contact_move(push_state, 1, push_state.revision, true)
		var retained_roll := DetachmentStratagems.devout_push_roll(push_state, 1, push_squad)
		var retry_error := C.begin_contact_move(push_state, 1, push_model, "pile_in", push_state.revision, [], -1, Callable(self, "roll_six"), false, true)
		var retry_maximum := float(push_state.get("pending_contact", {}).get("maximum", 0.0))
		check(begin_error.is_empty() and int(first_roll.get("value", 0)) == 6 and is_equal_approx(first_maximum, 6.0) and push_state.cp[1] == before_cp - 1, "Devout Push rolls D3+3, raises the pile-in limit, and spends 1 CP")
		check(cancel_error.is_empty() and int(retained_roll.get("value", 0)) == 6 and retry_error.is_empty() and is_equal_approx(retry_maximum, 6.0) and push_state.cp[1] == before_cp - 1, "Canceled Devout Push placement keeps its roll and paid CP when resumed")
		C.finish_contact_move(push_state, 1, push_state.revision, true)
	else:
		check(false, "Chaplain and Librarian enter the Devout Push scenario: %s" % str(push_state.get("error", "")))

	var heresy_state := fresh("chaplain", "librarian")
	if not heresy_state.has("error"):
		var mover_squad := squad_for(heresy_state, 1)
		var trigger_squad := squad_for(heresy_state, 2)
		var mover := model_for(heresy_state, mover_squad)
		heresy_state.phase = "movement"
		heresy_state.active = 2
		heresy_state.turn = 1
		heresy_state.units[mover].position = Vector2.ZERO
		heresy_state.units[model_for(heresy_state, trigger_squad)].position = Vector2(4.5, 0)
		heresy_state.cp[1] = 5
		DetachmentStratagems.record_move(heresy_state, trigger_squad)
		var opened := DetachmentStratagems.open_movement_reaction(heresy_state, trigger_squad)
		var choices := DetachmentStratagems.movement_reaction_choices(heresy_state, 1)
		var selected: Dictionary = {}
		for candidate: Dictionary in choices:
			if str(candidate.get("value", "")) == DetachmentStratagems.VOW_HERESY_BEGETS_RETRIBUTION: selected = candidate
		var before_cp: int = heresy_state.cp[1]
		var result := DetachmentStratagems.apply(heresy_state, 1, selected, Callable(self, "roll_six")) if not selected.is_empty() else {"error": "Heresy Begets Retribution choice missing."}
		var roll: Dictionary = heresy_state.get("last_command_roll", {})
		var position_result := HeresyRetribution.apply(heresy_state, 1, {"action": "heresy-retribution-place", "model": mover, "target": mover_squad}, Vector2(2.4, 0)) if str(result.get("error", "")).is_empty() else {"error": "Surge placement did not open."}
		var confirm_result := HeresyRetribution.apply(heresy_state, 1, {"action": "heresy-retribution-confirm", "model": -1, "target": mover_squad}, Vector2.ZERO) if str(position_result.get("error", "")).is_empty() else {"error": "Surge placement failed."}
		check(opened and not selected.is_empty() and str(result.get("error", "")).is_empty() and heresy_state.cp[1] == before_cp - 1 and roll.get("source", "") == "Heresy Begets Retribution" and int(roll.get("value", 0)) == 6, "Heresy Begets Retribution opens on the opposing post-move trigger, rolls D6 and spends 1 CP")
		check(str(position_result.get("error", "")).is_empty() and bool(confirm_result.get("completed", false)) and heresy_state.squads[mover_squad].move_type == "surge" and is_equal_approx(float(heresy_state.units[mover].position.x), 2.4), "Heresy Begets Retribution completes a legal Surge placement toward the closest enemy")
	else:
		check(false, "Chaplain and Librarian enter the Heresy Begets Retribution scenario: %s" % str(heresy_state.get("error", "")))

	print("Vow-sworn stratagem checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
