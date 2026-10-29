extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const C = F.C
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const WEAPONS := {
	"stormfury-missile-launcher": {"melee": false, "name": "Stormfury Missile Launcher", "range_inches": 48.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+3", "keywords": {}},
	"thunderstrike-icarus-rocket-pod": {"melee": false, "name": "Thunderstrike Icarus Rocket Pod", "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 6, "ap": -1, "damage": 2, "keywords": {"anti-fly": 2}},
	"thunderstrike-las-talon": {"melee": false, "name": "Thunderstrike Las-talon", "range_inches": 36.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+3", "keywords": {}},
	"armoured-impact": {"melee": true, "name": "Armoured Impact", "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}
}
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func squad(state: Dictionary, name: String, owner: int = -1, occurrence: int = 0) -> int:
	var matches: Array[int] = []
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) != name or (owner >= 0 and int(state.units[model].owner) != owner): continue
		var candidate := int(state.units[model].squad)
		if candidate not in matches: matches.append(candidate)
	return matches[occurrence] if occurrence >= 0 and occurrence < matches.size() else -1

func check_weapon_path(state: Dictionary, squad_id: int, model: int, target: int, weapon_id: String, expected: Dictionary) -> void:
	var melee: bool = expected.melee
	var weapons: Array = state.units[model].melee_weapons if melee else state.units[model].ranged_weapons
	var actual: Dictionary = weapons.filter(func(w: Dictionary) -> bool: return w.id == weapon_id)[0].profiles.standard
	var selected := Equipment.select(state, model, melee, weapon_id, "standard")
	var matches := true
	var selected_stats: Dictionary = selected.get("stats", {})
	for field: String in ["name", "range_inches", "attacks", "skill", "strength", "ap", "damage", "keywords"]:
		if actual.get(field) != expected.get(field) or selected_stats.get(field) != expected.get(field): matches = false
	if actual.get("target_restricted_traits", {}) != expected.get("target_restricted_traits", {}): matches = false
	check(matches, "%s matches every exported weapon field and trait" % weapon_id)
	check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % weapon_id)
	var old_phase: String = state.phase
	var old_active: int = int(state.active)
	var old_positions := {}
	for member: int in C.living(state, squad_id) + C.living(state, target): old_positions[member] = state.units[member].position
	state.phase = "fight" if melee else "shooting"
	state.active = int(state.squads[squad_id].owner)
	for member: int in C.living(state, squad_id): state.units[member].position = Vector2.ZERO
	var target_models: Array[int] = C.living(state, target)
	for index in range(target_models.size()): state.units[target_models[index]].position = Vector2(1, 0) if melee and index == 0 else Vector2(6, index * 3)
	var plan := C.AttackPlan.prepare(state, squad_id, melee, [{"model": model, "target": target, "amount": int(expected.attacks) if melee else 1, "weapon": weapon_id, "profile": "standard"}], true)
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan" % weapon_id)
	state.phase = old_phase
	state.active = old_active
	for member: int in old_positions: state.units[member].position = old_positions[member]

func entries(state: Dictionary, source: int, target: int, weapon: String, profile: String = "standard") -> Array:
	var result: Array = []
	for model: int in C.living(state, source): result.append({"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile})
	return result

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No UnitActions decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current UnitActions projection."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("storm-speeder-thunderstrike")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001610" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Thunderstrike cites its local Wahapedia e11 row")
	check(profile.get("points_by_models", {}) == {1: 140} and profile.get("third_plus_points_by_models", {}) == {1: 150} and profile.get("max_supported_copies") == 3 and is_equal_approx(profile.get("base_radius_inches", 0.0), 45.0 / 25.4), "One-model size, base and tiered costs match the source")
	check(profile.stats == {"movement_inches": 14, "toughness": 9, "save_target": 3, "wounds": 11, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("VEHICLE") and profile.keywords.has("FLY"), "Characteristics and unit keywords match the extraction")
	var keywords: Array = profile.keywords.duplicate(); keywords.sort()
	var expected_keywords := ["ADEPTUS ASTARTES", "FLY", "FRAME", "IMPERIUM", "RAVENWING", "SPEEDER", "VEHICLE"]; expected_keywords.sort()
	check(profile.models == 1 and keywords == expected_keywords, "One-model composition and all exported keywords match the source")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["stormfury-missile-launcher", "thunderstrike-icarus-rocket-pod", "thunderstrike-las-talon"] and profile.melee[0].id == "armoured-impact", "Every fixed weapon is in the local profile")
	check(profile.ranged[1].profiles.standard.keywords == {"anti-fly": 2}, "Icarus rocket pod keeps Anti-Fly 2+")
	check(Catalog.SPECS.has("storm-speeder-thunderstrike") and Roster.POINTS["storm-speeder-thunderstrike"].sizes == {1: 140} and Roster.POINTS["storm-speeder-thunderstrike"].third_plus_sizes == {1: 150}, "Thunderstrike is admitted with source copy tiers")
	var three := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-thunderstrike", "models": 1, "copies": 3}]})
	var four := Catalog.admit({"schema_version": 2, "faction": "Space Marines", "category": "custom", "points_limit": 10000, "entries": [{"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-thunderstrike", "models": 1, "copies": 4}]})
	check(three.get("error", "").is_empty() and three.get("total", -1) == 430 and not four.get("error", "").is_empty(), "Three-copy cap and 140/140/150 source tiers are enforced")

	var lists := F.current_marine_selections()
	for owner in [1, 2]: lists[owner].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:storm-speeder-thunderstrike", "models": 1, "copies": 1})
	lists[2].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:gladiator-reaper", "models": 1, "copies": 1})
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Thunderstrike is materialized by local roster admission")
	if state.has("error"):
		print(state)
		quit(1)
		return
	state.awakened_dynasty.pending = []
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.phase = "shooting"
	state.turn = 3
	state.round = 2
	state.active = 1
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.stratagems.attack_rerolls = false
	state.stratagems.hazard_rerolls = false
	var speeder := squad(state, "storm-speeder-thunderstrike", 1)
	var monster_target := squad(state, "gladiator-reaper", 2)
	var ordinary_target := squad(state, "intercessor-squad", 2, 0)
	var intercessors := squad(state, "intercessor-squad", 1, 0)
	check(squad(state, "storm-speeder-thunderstrike", 2) >= 0, "The enemy roster also admits the current-catalog Thunderstrike")
	for model: int in state.units: state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	for friendly: int in [speeder, intercessors]:
		for model: int in C.living(state, friendly): state.units[model].position = Vector2.ZERO
	for enemy: int in [monster_target, ordinary_target]:
		for model: int in C.living(state, enemy): state.units[model].position = Vector2(7, 0)
	var model := speeder * 100
	check(C.UnitAbilities.identity(state.units[C.living(state, monster_target)[0]]) == "gladiator-reaper", "Thunderstrike tests against an actual Vehicle datasheet")
	for weapon_id: String in WEAPONS: check_weapon_path(state, speeder, model, ordinary_target, weapon_id, WEAPONS[weapon_id])
	check(C.UnitAbilities.has(state, speeder, "thunderstrike") and C.UnitAbilities.has(state, speeder, "shattered-defences") and C.UnitAbilities.has(state, speeder, "deep-strike") and C.UnitAbilities.has(state, speeder, "damaged-4") and C.UnitAbilities.has(state, speeder, "deadly-demise-d3"), "Thunderstrike and shared vehicle abilities are admitted")
	var vehicle_plan := C.AttackPlan.prepare(state, speeder, false, entries(state, speeder, monster_target, "stormfury-missile-launcher"), true)
	var ordinary_plan := C.AttackPlan.prepare(state, speeder, false, entries(state, speeder, ordinary_target, "stormfury-missile-launcher"), true)
	check(vehicle_plan.error.is_empty() and vehicle_plan.batches[0].context.get("wound_modifier", 0) == 1, "Thunderstrike grants +1 to wound against VEHICLE targets")
	check(ordinary_plan.error.is_empty() and ordinary_plan.batches[0].context.get("wound_modifier", 0) == 0, "Thunderstrike does not modify attacks against ordinary targets")
	var melee_state := state.duplicate(true)
	for enemy_model: int in C.living(melee_state, monster_target): melee_state.units[enemy_model].position = Vector2(0.8, 0)
	var melee_entries := entries(melee_state, speeder, monster_target, "armoured-impact")
	melee_entries[0].amount = 3
	var melee_plan := C.AttackPlan.prepare(melee_state, speeder, true, melee_entries, true)
	check(melee_plan.error.is_empty() and melee_plan.batches[0].context.get("wound_modifier", 0) == 0, "Thunderstrike does not modify melee attacks")
	var filter_state := state.duplicate(true)
	C.UnitAbilities.offer_cover_target(filter_state, speeder, {"shattered_defences": true}, {"pools": [{"target_squad": monster_target, "hits": 1}, {"target_squad": ordinary_target, "hits": 1}]}, false)
	check(filter_state.unit_abilities.window.get("kind", "") == "shattered-defences" and filter_state.unit_abilities.window.targets == [monster_target], "Shattered Defences only offers a hit MONSTER or VEHICLE")
	var shot := C.resolve_attack_plan(state, 1, model, entries(state, speeder, monster_target, "stormfury-missile-launcher"), state.revision, false, true, func() -> int: return 6)
	check(shot.error.is_empty() and state.unit_abilities.window.get("kind", "") == "shattered-defences" and state.unit_abilities.window.targets == [monster_target], "After shooting, Thunderstrike offers its hit Vehicle for marking")
	var choices := C.unit_choices(state, 1)
	check(choices.size() == 1 and choices[0].label.begins_with("Shattered Defences:") and choices[0].target == monster_target, "Shattered Defences prompt identifies the effect and valid target")
	if not choices.is_empty():
		var before_mark := var_to_bytes(state)
		var wrong_owner := submit_projected_choice(state, 2, choices[0])
		check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_mark, "Opponent cannot choose the Thunderstrike mark")
		var mark_result := submit_projected_choice(state, 1, choices[0])
		check(str(mark_result.get("error", "")).is_empty(), "Player marks the Vehicle hit by the Thunderstrike through the normalized decision: " + str(mark_result.get("error", "")))
	var marine_gun: Dictionary = Profiles.profile("intercessor-squad").ranged[0].profiles.saturation
	var marked := C.UnitAbilities.weapon(state, intercessors * 100, monster_target, marine_gun, false)
	var unmarked := C.UnitAbilities.weapon(state, intercessors * 100, ordinary_target, marine_gun, false)
	var enemy_attack := C.UnitAbilities.weapon(state, monster_target * 100, monster_target, marine_gun, false)
	var melee := C.UnitAbilities.weapon(state, intercessors * 100, monster_target, Profiles.profile("intercessor-squad").melee[0].profiles.standard, true)
	check(marked.ap == marine_gun.ap - 1 and unmarked.ap == marine_gun.ap and enemy_attack.ap == marine_gun.ap and melee.ap == Profiles.profile("intercessor-squad").melee[0].profiles.standard.ap, "Only friendly Astartes ranged attacks against the mark gain +1 AP")
	state.phase = "charge"
	check(not C.UnitAbilities.shattered_defences_mark(state, intercessors, monster_target), "Shattered Defences mark expires after the Shooting phase")
	print("Current Storm Speeder Thunderstrike checks: %d failures" % failures)
	quit(1 if failures else 0)
