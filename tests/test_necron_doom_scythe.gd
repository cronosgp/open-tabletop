extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_necron_profiles.gd")
const Army = preload("res://scripts/edition_11/army_capabilities.gd")
const Reanimation = preload("res://scripts/edition_11/reanimation_protocols.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const AttackSequence = preload("res://scripts/edition_11/attack_sequence.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const AircraftRules = preload("res://scripts/edition_11/aircraft_rules.gd")
const UnitActions = preload("res://scripts/edition_11/unit_actions.gd")
const DoomScythe = preload("res://scripts/edition_11/necron_doom_scythe.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")

const DOOM_SCYTHE_ID := "40kdc:11e:necrons:doom-scythe"
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
	return {
		1: {"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [
			{"definition_id": DOOM_SCYTHE_ID, "models": 1, "copies": 1},
			{"definition_id": WARRIORS_ID, "models": 10, "copies": 1}]},
		2: {"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 500, "entries": [
			{"definition_id": MARINE_ID, "models": 5, "copies": 1}]}}

func new_state() -> Dictionary:
	var state: Dictionary = F.P.initial_state({"unit_abilities": true, "reanimation_protocols": true, "combat_doctrines": false, "core_stratagems": false, "manual_allocation": false}, selections())
	if state.has("error"): return state
	state.terrain = {"id": "terrain-11e-v1", "areas": []}
	state.unit_abilities.setup_players = [1, 2]
	state.active = 1
	state.phase = "shooting"
	state.turn = 1
	state.round = 1
	C.UnitActions.reconcile(state)
	for model: int in state.units:
		var identity := C.UnitAbilities.identity(state.units[model])
		if identity == "doom-scythe":
			state.units[model].position = Vector2.ZERO
			state.units[model].on_battlefield = true
		elif identity == "necron-warriors":
			state.units[model].position = Vector2(0.0, 8.0 + float(model % 4))
			state.units[model].on_battlefield = true
		elif identity == "intercessor-squad":
			state.units[model].position = Vector2(12.0, float(model % 5) * 1.2)
			state.units[model].on_battlefield = true
	return state

func model_for(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if int(state.units[model].get("owner", -1)) == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

func squad_for(state: Dictionary, owner: int, identity: String) -> int:
	var model := model_for(state, owner, identity)
	return int(state.units[model].get("squad", -1)) if model >= 0 else -1

func weapon_id(unit: Dictionary, name: String) -> String:
	for weapon: Dictionary in unit.get("ranged_weapons", []):
		for profile: Dictionary in weapon.get("profiles", {}).values():
			if str(profile.get("name", "")) == name: return str(weapon.get("id", ""))
	return ""

func decision(state: Dictionary, player: int, value: String) -> Dictionary:
	for option: Dictionary in UnitActions.choices(state, player):
		if str(option.get("action", "")) == DoomScythe.ACTION and str(option.get("value", "")) == value: return option
	return {}

func open_stance(state: Dictionary, doom_model: int, target_squad: int) -> Dictionary:
	var heavy_ray := weapon_id(state.units[doom_model], "Heavy death ray")
	return C.resolve_attack_plan(state, 1, doom_model, [{"model": doom_model, "target": target_squad, "amount": 1, "weapon": heavy_ray, "profile": "standard"}], int(state.revision), false, true, Callable(self, "next_die"))

func run() -> void:
	var profile := Profiles.profile("doom-scythe")
	var ray: Dictionary = profile.get("ranged", [{}])[0].get("profiles", {}).get("standard", {})
	var tesla: Dictionary = profile.get("ranged", [{}, {}])[1].get("profiles", {}).get("standard", {})
	check(profile.get("source_datasheet_id", "") == "000000545" and profile.get("source_snapshot_id", "") == "20261031T053336Z", "Doom Scythe is bound to the verified local Necrons App v1.2 sheet")
	check(profile.get("points_by_models", {}) == {1: 200} and profile.stats.toughness == 9 and profile.stats.save_target == 3 and profile.stats.wounds == 12 and profile.base_size_source == "120 x 92mm flying base", "Doom Scythe retains source cost, characteristics and flying base")
	check(ray.get("range_inches") == 36 and ray.get("attacks") == 3 and ray.get("skill") == 3 and ray.get("strength") == 16 and ray.get("ap") == -4 and ray.get("damage") == "D6+1" and ray.get("keywords", {}) == {"sustained-hits": "D3"}, "Heavy death ray retains its complete profile")
	check(tesla.get("range_inches") == 36 and tesla.get("attacks") == 6 and tesla.get("skill") == 3 and tesla.get("strength") == 8 and tesla.get("ap") == 0 and tesla.get("damage") == 2 and tesla.get("keywords", {}) == {"sustained-hits": 2, "twin-linked": true}, "Twin tesla destructor retains its complete profile")
	check(profile.get("supported_rule_ids", []) == ["reanimation-protocols", "deadly-demise-d3", "damaged-4", "atavistic-instigation"] and profile.get("unsupported_abilities", []).is_empty() and profile.get("pending_source_checks", []).is_empty() and profile.get("source_profile_readiness", "") == "source_bounded_local_scope_passed_2026_11_12", "Every Doom Scythe datasheet rule is admitted within its locally checked scope")
	var admitted := Army.admit({"schema_version": 2, "faction": "Necrons", "category": "custom", "points_limit": 500, "entries": [{"definition_id": DOOM_SCYTHE_ID, "models": 1, "copies": 1}]})
	check(str(admitted.get("error", "")).is_empty() and int(admitted.get("total", -1)) == 200, "The Doom Scythe is admitted at its 200 point source cost")
	check(int(Reanimation.PROFILE_WOUNDS.get(DOOM_SCYTHE_ID, 0)) == 12, "Reanimation keeps the Doom Scythe's source 12-wound profile")

	var stand_state := new_state()
	if stand_state.has("error"):
		check(false, "The local Doom Scythe fixture is valid: " + str(stand_state.get("error", "")))
		quit(1)
		return
	var doom := model_for(stand_state, 1, "doom-scythe")
	var warrior := model_for(stand_state, 1, "necron-warriors")
	var marines: Array[int] = []
	for model: int in stand_state.units:
		if int(stand_state.units[model].get("owner", -1)) == 2 and C.UnitAbilities.identity(stand_state.units[model]) == "intercessor-squad": marines.append(model)
	var target_squad := squad_for(stand_state, 2, "intercessor-squad")
	var doom_squad := int(stand_state.units[doom].squad)
	check(doom >= 0 and warrior >= 0 and marines.size() == 5 and target_squad >= 0 and Reanimation.supported_unit(stand_state, doom_squad) and AircraftRules.is_aircraft(stand_state, doom_squad), "The one-model Doom Scythe is valid for Reanimation, Aircraft rules and the attack fixture materializes")
	if doom < 0 or warrior < 0 or target_squad < 0:
		quit(1)
		return
	var heavy_ray := weapon_id(stand_state.units[doom], "Heavy death ray")
	stand_state.units[doom].wounds = 4
	var damaged_plan := AttackPlan.prepare(stand_state, doom_squad, false, [{"model": doom, "target": target_squad, "amount": 1, "weapon": heavy_ray, "profile": "standard"}], true)
	check(str(damaged_plan.get("error", "")).is_empty() and int(damaged_plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == -1, "Damaged 4 subtracts 1 from the Doom Scythe's attacks at four wounds remaining: " + str(damaged_plan))
	stand_state.units[doom].wounds = 5
	var recovered_plan := AttackPlan.prepare(stand_state, doom_squad, false, [{"model": doom, "target": target_squad, "amount": 1, "weapon": heavy_ray, "profile": "standard"}], true)
	check(str(recovered_plan.get("error", "")).is_empty() and int(recovered_plan.get("batches", [{}])[0].get("context", {}).get("hit_modifier", 0)) == 0, "Damaged 4 stops at five wounds remaining: " + str(recovered_plan))
	stand_state.units[doom].wounds = 12
	var demise_state: Dictionary = stand_state.duplicate(true)
	demise_state.units[doom].wounds = 0
	for index in range(marines.size()): demise_state.units[marines[index]].position = Vector2(4.0, float(index) * 0.5)
	scripted_dice = [6, 1]
	var demise := DeadlyDemise.begin(demise_state, [doom], Callable(self, "next_die"))
	check(str(demise.get("error", "")).is_empty() and not demise.get("complete", true) and demise_state.get("pending_deadly_demise", {}).get("events", [{}])[0].get("expression", "") == "D3" and demise_state.get("pending_deadly_demise", {}).get("packets", []).size() == 2, "The Doom Scythe's Deadly Demise D3 event creates one packet for each nearby enemy unit")
	scripted_dice = [1, 1, 1]
	var opened := open_stance(stand_state, doom, target_squad)
	check(str(opened.get("error", "")).is_empty() and opened.get("pools", []).is_empty() and stand_state.unit_abilities.window.get("kind", "") == DoomScythe.WINDOW, "Heavy death ray opens the mandatory stance decision before rolling attack dice: " + str(opened) + " / " + str(stand_state.unit_abilities.window))
	check(UnitActions.choices(stand_state, 1).is_empty(), "Only the target controller can answer the stance choice")
	var choices := UnitActions.choices(stand_state, 2)
	check(choices.size() == 2 and choices.all(func(option: Dictionary) -> bool: return option.get("action", "") == DoomScythe.ACTION) and choices.all(func(option: Dictionary) -> bool: return option.get("action", "") != "pass"), "The target controller must choose one of the two stances and cannot decline")
	var stand_choice := decision(stand_state, 2, DoomScythe.STAND_FIRM)
	scripted_dice = [5, 1, 1, 1, 1, 1]
	var stood := PublicUnitCommand.submit(stand_state, 2, stand_choice, Vector2.ZERO, Callable(self, "next_die"))
	check(str(stood.get("error", "")).is_empty() and stand_state.unit_abilities.window.is_empty() and stand_state.unit_abilities.atavistic_instigation[target_squad].get("stance", "") == DoomScythe.STAND_FIRM, "Stand firm is recorded and resumes the original attack")
	var warrior_weapon := weapon_id(stand_state.units[warrior], "Gauss flayer")
	var warriors_squad := int(stand_state.units[warrior].squad)
	var other_attack := AttackPlan.prepare(stand_state, warriors_squad, false, [{"model": warrior, "target": target_squad, "amount": 1, "weapon": warrior_weapon, "profile": "standard"}], true)
	check(str(other_attack.get("error", "")).is_empty() and int(other_attack.batches[0].context.get("critical_hit_threshold", 0)) == 5, "Stand firm applies to other friendly ranged attacks against that unit for the current phase")
	if not other_attack.get("batches", []).is_empty():
		scripted_dice = [5, 1, 1]
		var five_is_critical := AttackSequence.roll_pool(other_attack.batches[0].weapon, AttackPlan.defender(stand_state, target_squad, false), other_attack.batches[0].context, Callable(self, "next_die"))
		check(str(five_is_critical.get("error", "")).is_empty() and bool(five_is_critical.get("hit_outcomes", [{}])[0].get("critical", false)), "A successful unmodified Hit roll of 5 scores a Critical Hit against a Stand firm target")
	stand_state.squads[doom_squad].shot = false
	var tesla_id := weapon_id(stand_state.units[doom], "Twin tesla destructor")
	check(stand_state.units[doom].get("ranged_weapons", []).size() == 2 and not tesla_id.is_empty(), "Both fixed ranged weapons materialize as selectable model-owned profiles")
	scripted_dice = [1, 1, 1, 1, 1, 1]
	var tesla_attack := C.resolve_attack_plan(stand_state, 1, doom, [{"model": doom, "target": target_squad, "amount": 1, "weapon": tesla_id, "profile": "standard"}], int(stand_state.revision), false, true, Callable(self, "next_die"))
	check(str(tesla_attack.get("error", "")).is_empty() and stand_state.unit_abilities.window.is_empty(), "Targeting with the Twin tesla destructor does not trigger Atavistic Instigation: " + str(tesla_attack) + " / " + str(stand_state.unit_abilities.window))

	var duck_state := new_state()
	if duck_state.has("error"):
		check(false, "The second Doom Scythe timing fixture is valid: " + str(duck_state.get("error", "")))
		quit(1)
		return
	var duck_doom := model_for(duck_state, 1, "doom-scythe")
	var duck_target := squad_for(duck_state, 2, "intercessor-squad")
	scripted_dice = [1, 1, 1]
	var duck_opened := open_stance(duck_state, duck_doom, duck_target)
	var duck_choice := decision(duck_state, 2, DoomScythe.DUCK_FOR_COVER)
	scripted_dice = [1, 1, 1]
	var ducked := PublicUnitCommand.submit(duck_state, 2, duck_choice, Vector2.ZERO, Callable(self, "next_die"))
	var duck_record: Dictionary = duck_state.unit_abilities.get("atavistic_instigation", {}).get(duck_target, {})
	check(str(duck_opened.get("error", "")).is_empty() and not duck_choice.is_empty() and str(ducked.get("error", "")).is_empty() and duck_record.get("stance", "") == DoomScythe.DUCK_FOR_COVER, "Duck for cover is selected and the original Heavy death ray resumes")
	var attacker_squad := duck_target
	var enemy_squad := int(duck_state.units[duck_doom].squad)
	duck_state.turn = 2
	duck_state.active = 2
	duck_state.phase = "movement"
	check(C.UnitAbilities.hit_bonus(duck_state, attacker_squad, enemy_squad, false) == -1 and C.UnitAbilities.hit_bonus(duck_state, attacker_squad, enemy_squad, true) == -1, "Duck for cover penalizes all ranged and melee Hit rolls before the target's next Shooting phase")
	duck_state.phase = "shooting"
	var no_duck_state: Dictionary = duck_state.duplicate(true)
	no_duck_state.unit_abilities.atavistic_instigation.erase(duck_target)
	check(C.UnitAbilities.hit_bonus(duck_state, attacker_squad, enemy_squad, false) == C.UnitAbilities.hit_bonus(no_duck_state, attacker_squad, enemy_squad, false) and DoomScythe.duck_for_cover_hit_penalty(duck_state, attacker_squad) == 0, "Duck for cover expires at the start of the target controller's next Shooting phase")
	duck_state.turn = 3
	duck_state.active = 1
	duck_state.phase = "shooting"
	check(C.UnitAbilities.hit_bonus(duck_state, attacker_squad, enemy_squad, false) == 0, "Duck for cover remains expired on later turns")

	if failures == 0: print("Necron Doom Scythe local checks: passed")
	else: print("Necron Doom Scythe local checks: %d failures" % failures)
	quit(0 if failures == 0 else 1)

