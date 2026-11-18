extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const AttackSequence = preload("res://scripts/edition_11/attack_sequence.gd")
const AttackRollWindow = preload("res://scripts/edition_11/attack_roll_window.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const MONOLITH_ID := "40kdc:11e:necrons:monolith"
const WARRIORS_ID := "40kdc:11e:necrons:necron-warriors"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 6

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 5, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].points_limit = 1000
	result[2].entries = [
		{"definition_id": MONOLITH_ID, "models": 1, "copies": 1},
		{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}]
	return result

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: return model
	return -1

func models_for(state: Dictionary, owner: int, identity: String) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.get("units", {}):
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity: result.append(model)
	result.sort()
	return result

func choice_for(state: Dictionary, player: int, action: String, target: int = -1, model: int = -1) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) != action: continue
		if target >= 0 and int(option.get("target", -1)) != target: continue
		if model >= 0 and int(option.get("model", -1)) != model: continue
		return option
	return {}

func act(state: Dictionary, player: int, selected: Dictionary, point: Vector2 = Vector2.ZERO) -> String:
	return C.unit_action(state, player, selected, point, int(state.get("revision", -1)), Callable(self, "next_die"))

func placement_for(index: int, offset: float = 0.0) -> Vector2:
	return Vector2(-0.6 + float(index % 5) * 1.3 + offset, -5.0 - float(index / 5) * 1.3)

func prepare_state() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if state.has("error"): return state
	state.unit_abilities.setup_players = [1]
	state.unit_abilities.window = {}
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.deployment = {"zones": {1: Rect2(Vector2(-30, -30), Vector2(60, 60)), 2: Rect2(Vector2(-30, -30), Vector2(60, 60))}}
	UnitActions.reconcile(state)
	return state

func run() -> void:
	var profile := Profiles.profile("monolith")
	check(profile.get("source_snapshot_id", "") == "20261031T053336Z" and profile.get("source_book_id", "") == "000000029" and profile.get("source_book_version", "") == "1.2" and profile.get("source_datasheet_id", "") == "000000552", "Monolith uses the verified local Necrons App v1.2 source record")
	check(profile.get("points_by_models", {}) == {1: 420} and profile.get("source_repeat_copy_costs", {}).get("2ND+", {}) == {1: 440} and profile.stats.wounds == 22 and profile.base_size_source_mm == 160, "Monolith keeps its source costs, 22 wounds and 160 mm base")
	check(profile.get("supported_rule_ids", []) == ["deadly-demise-d6", "deep-strike", "reanimation-protocols", "eternity-gate", "damaged-7"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("source_options", [{}])[0].get("implemented", false), "All Monolith abilities and its all-four-weapon option are locally mapped")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": MONOLITH_ID, "models": 1, "copies": 2}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 860, "Construction uses the Monolith's 420 first-copy and 440 second-copy prices: " + str(admitted))
	var invalid_size := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 2000, "entries": [{"definition_id": MONOLITH_ID, "models": 2, "copies": 1}]})
	check(not str(invalid_size.get("error", "")).is_empty(), "Unpriced Monolith model counts remain excluded")

	var death_ray: Dictionary = profile.get("additional_weapon_profiles", {}).get("ranged", [{}])[0].duplicate(true)
	death_ray.count = 4
	var death_ray_profile: Dictionary = death_ray.profiles.standard
	check(death_ray_profile.attacks == 1 and death_ray_profile.keywords.get("sustained-hits", "") == "D3" and str(AttackSequence._validate(death_ray_profile, {"toughness": 5, "save_target": 3, "wounds_per_model": 22, "remaining_wounds": [22], "invulnerable_target": 0}, {"weapon_count": 1, "distance_inches": 12.0, "target_model_count": 1, "target_engaged": false, "heavy_eligible": false, "benefit_of_cover": false})).is_empty(), "Four Death Rays retain D3 Sustained Hits and pass the shared attack validator")
	var defender := {"toughness": 5, "save_target": 3, "wounds_per_model": 22, "remaining_wounds": [22], "invulnerable_target": 0}
	var attack_context := {"weapon_count": 1, "distance_inches": 12.0, "target_model_count": 1, "target_engaged": false, "heavy_eligible": false, "benefit_of_cover": false}
	scripted_dice = [6, 4, 3, 3, 3]
	var pool := AttackSequence.roll_pool(death_ray_profile, defender, attack_context, Callable(self, "next_die"))
	check(str(pool.get("error", "")).is_empty() and pool.hit_outcomes[0].sustained_hits == 2 and pool.wound_rolls.size() == 3, "A critical Death Ray Hit rolls D3 and creates that many additional Wound rolls")
	scripted_dice = [6]
	var checkpoint := AttackRollWindow.begin(death_ray_profile, defender, attack_context, Callable(self, "next_die"))
	scripted_dice = [4, 3, 3, 3]
	var staged := AttackRollWindow.advance(checkpoint, int(checkpoint.revision), Callable(self, "next_die"))
	check(str(staged.get("error", "")).is_empty() and staged.hit_outcomes[0].sustained_hits == 2 and staged.effective_wounds.size() == 3, "Staged attack resolution rolls D3 Sustained Hits through its checkpoint path")

	var state := prepare_state()
	if state.has("error"):
		check(false, "Current Monolith roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	var monolith := model_for(state, 2, "monolith")
	var warrior_models := models_for(state, 2, "necron-warriors")
	var marine_models := models_for(state, 1, "intercessor-squad")
	check(monolith >= 0 and warrior_models.size() == 10 and marine_models.size() == 5, "The current roster materializes one Monolith, ten Warriors and five enemy Intercessors")
	if monolith < 0 or warrior_models.size() != 10 or marine_models.size() != 5:
		quit(1)
		return
	var monolith_squad := int(state.units[monolith].squad)
	check(C.UnitAbilities.deadly_demise_value(state, monolith) == "D6" and C.UnitAbilities.has(state, monolith_squad, "deep-strike"), "The Monolith binds its D6 Deadly Demise and Deep Strike rules")
	var warrior_squad := int(state.units[warrior_models[0]].squad)
	var marine_squad := int(state.units[marine_models[0]].squad)
	for index in range(marine_models.size()):
		state.units[marine_models[index]].position = Vector2(17.0 + float(index), 0.0)
	state.units[monolith].position = Vector2(2.0, 0.0)
	state.units[monolith].on_battlefield = true
	for model: int in marine_models: state.units[model].on_battlefield = true
	state.unit_abilities.reserves[warrior_squad] = {"deep_strike": false}
	for model: int in warrior_models: state.units[model].on_battlefield = false
	state.squads[warrior_squad].moved = false
	state.phase = "deployment"
	state.active = 1

	var death_ray_choice := choice_for(state, 2, "necron-monolith-death-rays", monolith_squad, monolith)
	check(not death_ray_choice.is_empty(), "Army preparation offers the Monolith's all-four Death Ray replacement")
	if not death_ray_choice.is_empty():
		death_ray_choice.value = "death-rays"
		check(act(state, 2, death_ray_choice).is_empty(), "All four Death Rays can replace the four Gauss Flux Arcs")
	var mounted_death_ray: Dictionary = {}
	var mounted_death_ray_count := 0
	var preserved_particle_whip := false
	for weapon: Dictionary in state.units[monolith].get("ranged_weapons", []):
		if str(weapon.get("id", "")).begins_with("death-ray"):
			mounted_death_ray = weapon
			mounted_death_ray_count += 1
		if str(weapon.get("id", "")) == "particle-whip": preserved_particle_whip = true
	check(mounted_death_ray_count == 4 and state.units[monolith].ranged_weapons.size() == 5 and preserved_particle_whip and mounted_death_ray.profiles.standard.keywords.get("sustained-hits", "") == "D3", "The four Death Rays replace the Flux Arcs while preserving the Particle Whip")
	var restore_choice := choice_for(state, 2, "necron-monolith-death-rays", monolith_squad, monolith)
	if not restore_choice.is_empty():
		restore_choice.value = "flux-arcs"
		check(act(state, 2, restore_choice).is_empty(), "Army preparation can restore all four Gauss Flux Arcs")
	check(state.units[monolith].ranged_weapons.size() == 5 and state.units[monolith].ranged_weapons.filter(func(weapon: Dictionary) -> bool: return str(weapon.get("id", "")).begins_with("gauss-flux-arc")).size() == 4, "The default Monolith loadout is restored as four Gauss Flux Arcs")

	state.phase = "movement"
	state.active = 2
	state.round = 1
	state.turn = 3
	check(choice_for(state, 2, "eternity-gate-ingress", warrior_squad, monolith).is_empty(), "Eternity Gate is unavailable during the first battle round")
	state.round = 2
	var non_strategic_reserves := state.duplicate(true)
	non_strategic_reserves.unit_abilities.reserves[warrior_squad].source = "deep-strike"
	check(choice_for(non_strategic_reserves, 2, "eternity-gate-ingress", warrior_squad, monolith).is_empty(), "Eternity Gate does not select a unit in other Reserves")
	var gate_choice := choice_for(state, 2, "eternity-gate-ingress", warrior_squad, monolith)
	check(not gate_choice.is_empty(), "Eternity Gate can select a friendly Necron Infantry unit in Strategic Reserves")
	if gate_choice.is_empty():
		quit(1 if failures > 0 else 0)
		return

	var cancelled := state.duplicate(true)
	var cancel_select := choice_for(cancelled, 2, "eternity-gate-ingress", warrior_squad, monolith)
	check(act(cancelled, 2, cancel_select).is_empty(), "Eternity Gate opens a cancellable ingress placement window")
	var cancel_action := choice_for(cancelled, 2, "ingress-cancel")
	if not cancel_action.is_empty(): check(act(cancelled, 2, cancel_action).is_empty(), "Cancelling Eternity Gate closes its placement window")
	check(cancelled.unit_abilities.reserves.has(warrior_squad) and not cancelled.unit_abilities.used.has("eternity-gate:%d" % monolith) and warrior_models.all(func(model: int) -> bool: return not cancelled.units[model].on_battlefield), "Cancelling leaves the reserve unit and Monolith use unchanged")

	check(act(state, 2, gate_choice).is_empty(), "Eternity Gate starts placement for the selected unit")
	var too_close_choice := choice_for(state, 2, "ingress-place", warrior_squad, warrior_models[0])
	var too_close := act(state, 2, too_close_choice, Vector2(8.5, 0.0))
	check(too_close.contains("more than 8 inches"), "Gate placement still requires more than 8 inches horizontally from enemy models")
	for index in range(warrior_models.size()):
		var model := warrior_models[index]
		var place_choice := choice_for(state, 2, "ingress-place", warrior_squad, model)
		var placed := act(state, 2, place_choice, placement_for(index))
		check(placed.is_empty(), "Eternity Gate accepts legal within-range placement for Warrior %d: %s" % [index, placed])
	var confirm := choice_for(state, 2, "ingress-confirm")
	check(not confirm.is_empty() and act(state, 2, confirm).is_empty(), "Eternity Gate confirms the coherent within-range unit setup")
	check(not state.unit_abilities.reserves.has(warrior_squad) and warrior_models.all(func(model: int) -> bool: return state.units[model].on_battlefield) and state.squads[warrior_squad].moved and state.squads[warrior_squad].set_up_this_turn, "The reserve unit arrives and is marked as moved and set up this turn")
	check(int(state.unit_abilities.used.get("eternity-gate:%d" % monolith, -1)) == int(state.turn) and C.Actions.charge_blocked(state, warrior_squad), "The Monolith use is recorded and the arrived unit cannot Charge this turn")
	check(choice_for(state, 2, "eternity-gate-ingress", warrior_squad, monolith).is_empty(), "The Monolith cannot use Eternity Gate a second time in the same turn")

	state.turn += 1
	state.squads[warrior_squad].moved = true
	var reposition_choice := choice_for(state, 2, "eternity-gate-ingress", warrior_squad, monolith)
	check(not reposition_choice.is_empty() and state.squads[warrior_squad].moved, "A battlefield Necron Infantry unit that already moved remains eligible for a later turn's Gate use")
	if not reposition_choice.is_empty():
		check(act(state, 2, reposition_choice).is_empty(), "Eternity Gate begins a repositioning for a unit that already moved")
		for index in range(warrior_models.size()):
			var model := warrior_models[index]
			var place_choice := choice_for(state, 2, "ingress-place", warrior_squad, model)
			check(act(state, 2, place_choice, placement_for(index, 0.2)).is_empty(), "Repositioning accepts a legal destination for Warrior %d" % index)
		var reposition_confirm := choice_for(state, 2, "ingress-confirm")
		check(not reposition_confirm.is_empty() and act(state, 2, reposition_confirm).is_empty() and C.Actions.charge_blocked(state, warrior_squad), "The repositioned unit remains unable to Charge this turn")

	state.phase = "shooting"
	state.active = 2
	state.squads[warrior_squad].shot = false
	var warrior_weapon: String = str(state.units[warrior_models[0]].ranged_weapons[0].get("id", ""))
	var shooting_plan := AttackPlan.prepare(state, warrior_squad, false, [{"model": warrior_models[0], "target": marine_squad, "amount": 1, "weapon": warrior_weapon, "profile": "standard"}], true)
	check(str(shooting_plan.get("error", "")).is_empty(), "A unit that arrived through Eternity Gate remains eligible to shoot: " + str(shooting_plan))

	state.units[monolith].wounds = 7
	var damaged_plan := AttackPlan.prepare(state, monolith_squad, false, [{"model": monolith, "target": marine_squad, "amount": 1, "weapon": "gauss-flux-arc-1", "profile": "standard"}], true)
	check(str(damaged_plan.get("error", "")).is_empty() and int(damaged_plan.batches[0].context.get("hit_modifier", 0)) == -1 and C.Morale.objective_control(state, monolith) == 4, "Damaged 7 applies -1 to Hit and reduces Monolith Objective Control from 8 to 4: plan=%s oc=%d" % [str(damaged_plan), C.Morale.objective_control(state, monolith)])
	state.units[monolith].wounds = 8
	var healthy_plan := AttackPlan.prepare(state, monolith_squad, false, [{"model": monolith, "target": marine_squad, "amount": 1, "weapon": "gauss-flux-arc-1", "profile": "standard"}], true)
	check(str(healthy_plan.get("error", "")).is_empty() and int(healthy_plan.batches[0].context.get("hit_modifier", 0)) == 0 and C.Morale.objective_control(state, monolith) == 8, "Damaged 7 has no effect at eight remaining wounds: plan=%s oc=%d" % [str(healthy_plan), C.Morale.objective_control(state, monolith)])
	state.units[monolith].wounds = 1
	check(C.Morale.objective_control(state, monolith) == 4, "Damaged 7 remains active at one wound")
	state.units[monolith].wounds = 0
	check(C.Morale.objective_control(state, monolith) == 0, "A destroyed Monolith contributes no Objective Control")
	var no_explosion := state.duplicate(true)
	for index in range(marine_models.size()): no_explosion.units[marine_models[index]].position = Vector2(5.0 + float(index) * 0.2, 0.0)
	scripted_dice = [5]
	var quiet_event := DeadlyDemise.begin(no_explosion, [monolith], Callable(self, "next_die"))
	check(quiet_event.get("error", "").is_empty() and quiet_event.get("complete", false) and no_explosion.last_deadly_demise.events[0].expression == "D6" and not no_explosion.last_deadly_demise.events[0].triggered, "A Monolith Deadly Demise roll below 6 does not trigger")
	var explosion := state.duplicate(true)
	for index in range(marine_models.size()): explosion.units[marine_models[index]].position = Vector2(5.0 + float(index) * 0.2, 0.0)
	scripted_dice = [6, 2, 3]
	var triggered_event := DeadlyDemise.begin(explosion, [monolith], Callable(self, "next_die"))
	var packet_wounds: Array[int] = []
	for packet: Dictionary in explosion.pending_deadly_demise.get("packets", []): packet_wounds.append(int(packet.get("remaining", 0)))
	packet_wounds.sort()
	check(triggered_event.get("error", "").is_empty() and not triggered_event.get("complete", true) and explosion.pending_deadly_demise.events[0].expression == "D6" and explosion.pending_deadly_demise.events[0].triggered and packet_wounds == [2, 3], "A Monolith Deadly Demise 6 opens one separately rolled D6 mortal-wound packet for each unit within 6 inches")

	if failures == 0: print("Necron Monolith local checks: passed")
	else: print("Necron Monolith local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
