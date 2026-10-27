extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Combat = F.C
const PreparedTraining = F.P
const Terrain = Combat.Terrain
const PhaseResolution = preload("res://scripts/edition_11/phase_resolution.gd")
const Capabilities = preload("res://scripts/edition_11/capabilities.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func make_state() -> Dictionary:
	var selections := F.selections()
	selections[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:reiver-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:lieutenant-in-phobos-armour", "models": 1, "copies": 1}]
	selections[2].entries = [{"definition_id": "40kdc:11e:necrons:necron-warriors", "models": 10, "copies": 1}]
	var state := PreparedTraining.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "marine_detachment": "phobos-shock-force", "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections)
	state.mission.stage = "battle"
	state.awakened_dynasty.pending = []
	state.turn = 3
	state.round = 2
	state.active = 1
	state.phase = "movement"
	for model: int in state.units:
		state.units[model].position = Vector2(-14, -8) if state.units[model].owner == 1 else Vector2(12, 8)
	return state

func find(state: Dictionary, identity: String) -> Dictionary:
	for model: int in state.units:
		if Combat.UnitAbilities.identity(state.units[model]) == identity:
			return {"model": model, "squad": int(state.units[model].squad)}
	return {}

func _initialize() -> void:
	var state := make_state()
	check(not state.has("error"), "Current Reiver Squad and target profiles materialize")
	if state.has("error"):
		print("Vanguard Ambushers checks: %d failures" % (failures + 1))
		quit(1)
		return
	var reivers := find(state, "reiver-squad")
	var enemy := find(state, "necron-warriors")
	var reiver_model := int(reivers.model)
	var reiver_squad := int(reivers.squad)
	var enemy_squad := int(enemy.squad)
	check(reiver_model >= 0 and enemy_squad >= 0 and Combat.UnitAbilities.has_target_keyword(state, reiver_squad, "PHOBOS"), "Current local Reiver profile supplies the PHOBOS unit keyword")
	check(Capabilities.supported("vanguard-ambushers") and Capabilities.enabled(state, "vanguard-ambushers"), "Vanguard Ambushers capability is admitted for Phobos Shock Force")
	state.units[reiver_model].position = Vector2(0, 0)
	check(Terrain.hidden(state, reiver_model), "A Reiver model in dense terrain can be Hidden")
	var hidden_reivers := 0
	for model: int in Combat.living(state, reiver_squad):
		if Terrain.hidden(state, model): hidden_reivers += 1
	check(hidden_reivers == 1, "Only one living Reiver model meets the Hidden descriptor")
	PhaseResolution._resolve_vanguard_ambushers(state)
	check(int(state.combat_doctrines.vanguard_ambushers.get(reiver_squad, -1)) == 3, "A Phobos unit is marked when at least one living model is Hidden")
	state.phase = "shooting"
	var ranged_choices: Array[Dictionary] = Combat.AttackPlan.Equipment.choices(state, reiver_model, false)
	var ranged := [{"model": reiver_model, "target": enemy_squad, "amount": 1, "weapon": ranged_choices[0].weapon, "profile": ranged_choices[0].profile}]
	var plan := Combat.AttackPlan.prepare(state, reiver_squad, false, ranged, true)
	check(plan.error.is_empty() and plan.batches[0].context.get("wound_reroll", "none") == "ones", "Marked unit gets Wound re-rolls of 1 in Shooting")
	state.phase = "fight"
	state.units[reiver_model].position = Vector2(0, 0)
	for model: int in Combat.living(state, enemy_squad): state.units[model].position = Vector2(0.9, 0)
	var melee_choice: Dictionary = Combat.AttackPlan.Equipment.choices(state, reiver_model, true)[0]
	var melee := [{"model": reiver_model, "target": enemy_squad, "amount": Combat.UnitAbilities.melee_attack_count(state, reiver_model, melee_choice.stats), "weapon": melee_choice.weapon, "profile": melee_choice.profile}]
	plan = Combat.AttackPlan.prepare(state, reiver_squad, true, melee, true)
	check(plan.error.is_empty() and plan.batches[0].context.get("wound_reroll", "none") == "ones", "Marked unit gets Wound re-rolls of 1 in Fight")
	state.turn = 4
	state.phase = "shooting"
	for model: int in Combat.living(state, enemy_squad): state.units[model].position = Vector2(12, 8)
	plan = Combat.AttackPlan.prepare(state, reiver_squad, false, ranged, true)
	check(plan.error.is_empty() and plan.batches[0].context.get("wound_reroll", "none") == "none", "Vanguard Ambushers expires after the marked turn")
	state = make_state()
	reivers = find(state, "reiver-squad")
	reiver_model = int(reivers.model)
	reiver_squad = int(reivers.squad)
	state.units[reiver_model].position = Vector2(8, -4)
	PhaseResolution._resolve_vanguard_ambushers(state)
	check(int(state.combat_doctrines.vanguard_ambushers.get(reiver_squad, -1)) == 3, "A living model in light terrain is Hidden and can mark its Phobos unit")
	state.combat_doctrines.vanguard_ambushers.erase(reiver_squad)
	state.units[reiver_model].position = Vector2(0, 0)
	state.squads[reiver_squad].last_ranged_turn = 2
	PhaseResolution._resolve_vanguard_ambushers(state)
	check(not state.combat_doctrines.vanguard_ambushers.has(reiver_squad), "A model that fired this or the previous turn cannot enable the mark")
	print("Vanguard Ambushers checks: %d failures" % failures)
	quit(1 if failures else 0)
