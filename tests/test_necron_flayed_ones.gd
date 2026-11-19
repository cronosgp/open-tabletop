extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const Attacks = preload("res://scripts/edition_11/attack_sequence.gd")
const Deployment = preload("res://scripts/edition_11/deployment.gd")
const FLAYED_ID := "40kdc:11e:necrons:flayed-ones"
const MARINE_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"

var failures := 0
var scripted_dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func next_die() -> int:
	return scripted_dice.pop_front() if not scripted_dice.is_empty() else 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [{"definition_id": MARINE_ID, "models": 10, "copies": 1}]
	result[2].faction = "Necrons"
	result[2].entries = [
		{"definition_id": FLAYED_ID, "models": 5, "copies": 1},
		{"definition_id": FLAYED_ID, "models": 10, "copies": 1}]
	return result

func models_for(state: Dictionary, owner: int, strength: int) -> Array[int]:
	var result: Array[int] = []
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner: continue
		if C.UnitAbilities.identity(unit) != ("flayed-ones" if owner == 2 else "intercessor-squad"): continue
		if int(state.squads.get(int(unit.get("squad", -1)), {}).get("starting_strength", -1)) == strength: result.append(model)
	result.sort()
	return result

func place(state: Dictionary, models: Array, origin: Vector2) -> void:
	for index in range(models.size()):
		state.units[models[index]].position = origin + Vector2(float(index) * 1.3, 0.0)
		state.units[models[index]].on_battlefield = true
		state.units[models[index]].wounds = int(state.units[models[index]].max_wounds)

func set_living(state: Dictionary, models: Array, living: int) -> void:
	for index in range(models.size()):
		state.units[models[index]].wounds = int(state.units[models[index]].max_wounds) if index < living else 0
		state.units[models[index]].on_battlefield = index < living

func melee_pool(state: Dictionary, attacker: int, target_squad: int) -> Dictionary:
	var weapon_id := str(state.units[attacker].melee_weapons[0].get("id", ""))
	var plan := AttackPlan.prepare(state, int(state.units[attacker].squad), true, [{"model": attacker, "target": target_squad, "amount": 4, "weapon": weapon_id, "profile": "standard"}], true)
	if not str(plan.get("error", "")).is_empty() or plan.get("batches", []).is_empty(): return plan
	var batch: Dictionary = plan.batches[0]
	batch.context.heavy_eligible = false
	batch.context.distance_inches = 0.0
	scripted_dice = [2, 4, 4, 4]
	var pool := Attacks.roll_pool(batch.weapon, AttackPlan.defender(state, target_squad, true), batch.context, Callable(self, "next_die"))
	pool.successful_hits_are_critical = bool(batch.context.get("successful_hits_are_critical", false))
	return pool

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("flayed-ones")
	check(profile.get("source_datasheet_id", "") == "000000538" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Flayed Ones use the verified local App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {5: 55, 10: 100} and not profile.has("third_plus_points_by_models") and profile.get("base_size_source_mm") == 28.5, "Flayed Ones keep both source prices and the 28.5 mm base")
	check(profile.supported_rule_ids == ["infiltrators", "stealth", "reanimation-protocols", "flesh-hunger"] and profile.unsupported_abilities.is_empty() and profile.source_ability_names == ["Infiltrators", "Stealth", "Reanimation Protocols", "Flesh Hunger"], "Infiltrators, Stealth, Reanimation Protocols and Flesh Hunger are the local ability scope")
	for size: int in [5, 10]:
		var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": FLAYED_ID, "models": size, "copies": 1}]})
		check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == int(profile.points_by_models[size]), "Flayed Ones size %d admits at its source price" % size)
	var third := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": FLAYED_ID, "models": 5, "copies": 3}]})
	check(str(third.get("error", "")).is_empty() and int(third.get("total", -1)) == 165, "Later Flayed Ones copies keep the source size price: %s" % str(third))
	var blocked := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 1000, "entries": [{"definition_id": FLAYED_ID, "models": 4, "copies": 1}]})
	check(not str(blocked.get("error", "")).is_empty(), "Unpriced Flayed Ones sizes stay out of construction")

	var state := F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": true, "core_stratagems": false, "manual_allocation": false}, selections())
	if state.has("error"):
		check(false, "Flayed Ones roster fixture is valid: " + str(state.get("error", "")))
		quit(1)
		return
	state.unit_abilities.setup_players = [1, 2]
	if state.has("awakened_dynasty"): state.awakened_dynasty.pending = []
	C.UnitActions.reconcile(state)
	if C.Doctrines.needs_choice(state):
		check(C.select_combat_doctrine(state, int(state.active), "none", int(state.revision)).is_empty(), "Clear the unrelated doctrine choice")
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	var small := models_for(state, 2, 5)
	var large := models_for(state, 2, 10)
	var marines := models_for(state, 1, 10)
	check(small.size() == 5 and large.size() == 10 and marines.size() == 10, "Both Flayed Ones sizes and the Marine squad materialize: %d/%d/%d" % [small.size(), large.size(), marines.size()])
	if small.is_empty() or marines.is_empty():
		quit(1)
		return
	var small_squad := int(state.units[small[0]].squad)
	var marine_squad := int(state.units[marines[0]].squad)
	check(Reanimation.supported_unit(state, small_squad) and Reanimation.supported_unit(state, int(state.units[large[0]].squad)), "Both source-sized Flayed Ones units can activate Reanimation Protocols")
	check(state.units[small[0]].ranged_weapons.is_empty() and str(state.units[small[0]].melee_weapons[0].profiles.standard.name) == "Flayer claws", "Flayed Ones materialize only the local flayer claws")
	check(C.Terrain.Detection.infiltrators(state, small_squad) and C.Terrain.Detection.stealth(state, small_squad), "Every living Flayed One supplies Infiltrators and Stealth")

	Deployment.begin(state)
	state.deployment.index = state.deployment.order.find(small_squad)
	var outside := Deployment.position_error(state, small[0], Vector2(0, 0))
	var too_close := Deployment.position_error(state, small[0], Vector2(-12, 0))
	state.deployment.index = state.deployment.order.find(marine_squad)
	var marine_outside := Deployment.position_error(state, marines[0], Vector2(0, 0))
	check(outside.is_empty() and not too_close.is_empty() and not marine_outside.is_empty(), "Infiltrators can deploy outside their zone while staying more than 8 inches from the enemy zone: outside=%s close=%s marine=%s" % [outside, too_close, marine_outside])

	place(state, small, Vector2(0, 20))
	place(state, large, Vector2(0, 40))
	place(state, marines, Vector2(18, 20))
	state.phase = "shooting"
	state.active = 1
	state.turn = 2
	var rifle_weapon: Dictionary = state.units[marines[0]].ranged_weapons[0]
	var rifle_profile := str(rifle_weapon.profiles.keys()[0])
	var shooting := AttackPlan.prepare(state, marine_squad, false, [{"model": marines[0], "target": small_squad, "amount": 1, "weapon": str(rifle_weapon.get("id", "")), "profile": rifle_profile}], true)
	check(str(shooting.get("error", "")).is_empty() and bool(shooting.batches[0].context.benefit_of_cover), "Stealth gives Flayed Ones the benefit of cover against a ranged attack in the open: %s" % str(shooting.get("error", "")))

	place(state, [small[0]], Vector2(18.8, 20))
	state.phase = "fight"
	state.squads[small_squad].fought = false
	var full := melee_pool(state, small[0], marine_squad)
	set_living(state, marines, 5)
	var exact := melee_pool(state, small[0], marine_squad)
	set_living(state, marines, 4)
	var hungry := melee_pool(state, small[0], marine_squad)
	check(str(full.get("error", "")).is_empty() and not bool(full.get("successful_hits_are_critical", true)) and int(full.get("hits", -1)) == 3, "A full-strength target does not turn successful Flayer claw hits into Critical Hits: %s" % str(full.get("error", full)))
	check(str(exact.get("error", "")).is_empty() and not bool(exact.get("successful_hits_are_critical", true)) and int(exact.get("hits", -1)) == 3, "Exactly half-strength is not Below Half-strength for Flesh Hunger: %s" % str(exact.get("error", exact)))
	var criticals := 0
	for outcome: Dictionary in hungry.get("hit_outcomes", []):
		if bool(outcome.get("critical", false)): criticals += 1
	check(str(hungry.get("error", "")).is_empty() and bool(hungry.get("successful_hits_are_critical", false)) and criticals == 3 and int(hungry.get("hits", -1)) == 6, "Below Half-strength makes each successful melee Hit a Critical Hit and adds Sustained Hits 1: criticals=%d hits=%s error=%s" % [criticals, str(hungry.get("hits", -1)), str(hungry.get("error", ""))])

	if failures == 0: print("Necron Flayed Ones local checks: passed")
	else: print("Necron Flayed Ones local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)
