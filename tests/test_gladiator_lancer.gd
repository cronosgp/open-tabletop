extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const MatchCommands = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const LANCER_ID := "40kdc:11e:adeptus-astartes:gladiator-lancer"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const WEAPONS := {
	"defensive-array": {"melee": false, "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 6}},
	"laser-destroyer": {"melee": false, "range_inches": 72.0, "attacks": 2, "skill": 3, "strength": 14, "ap": -3, "damage": "D6+3", "keywords": {"heavy": true}},
	"armoured-hull": {"melee": true, "range_inches": 0.0, "attacks": 3, "skill": 4, "strength": 6, "ap": 0, "damage": 1, "keywords": {}}
}

var failures := 0
var dice: Array[int] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func roll_die() -> int:
	return dice.pop_front() if not dice.is_empty() else 1

func selection(copies: int = 1) -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000,
		"entries": [{"definition_id": LANCER_ID, "models": 1, "copies": copies}]}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner in [1, 2]:
		result[owner].entries = [
			{"definition_id": LANCER_ID, "models": 1, "copies": 1},
			{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1}]
	return result

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity:
			return int(unit.get("squad", -1))
	return -1

func fixture() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true,
		"reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if state.has("error"): return state
	state.mission.stage = "battle"
	state.deployment.complete = true
	state.phase = "shooting"
	state.turn = 3
	state.round = 2
	state.active = 1
	state.cp = {1: 3, 2: 0}
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-18, 16) if state.units[model].owner == 1 else Vector2(18, 16)
	var target := find_squad(state, 2, "intercessor-squad")
	for index in range(C.living(state, target).size()):
		state.units[C.living(state, target)[index]].position = Vector2(6, index * 3)
	return state

func set_squad_keyword(state: Dictionary, squad: int, keyword: String, enabled: bool) -> void:
	for model: int in C.living(state, squad):
		var keywords: Array = state.units[model].keywords
		if enabled and keyword not in keywords:
			keywords.append(keyword)
		elif not enabled:
			keywords.erase(keyword)

func prepare_plan(state: Dictionary, squad: int, model: int, target: int, weapon: String, melee: bool = false) -> Dictionary:
	state.phase = "fight" if melee else "shooting"
	state.active = int(state.squads[squad].owner)
	state.units[model].position = Vector2.ZERO
	var targets: Array[int] = C.living(state, target)
	for index in range(targets.size()):
		state.units[targets[index]].position = Vector2(1, 0) if melee and index == 0 else Vector2(6, index * 3)
	return C.AttackPlan.prepare(state, squad, melee,
		[{"model": model, "target": target, "amount": int(WEAPONS[weapon].attacks) if melee else 1, "weapon": weapon, "profile": "standard"}], true)

func check_weapon_profile(state: Dictionary, squad: int, model: int, target: int, weapon: String) -> void:
	var expected: Dictionary = WEAPONS[weapon]
	var selected := Equipment.select(state, model, bool(expected.melee), weapon, "standard")
	check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % weapon)
	if not str(selected.get("error", "")).is_empty(): return
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s %s matches the verified export" % [weapon, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s preserves every exported weapon trait" % weapon)
	var old_phase: String = str(state.phase)
	var old_active: int = int(state.active)
	var old_positions := {}
	for member: int in C.living(state, squad) + C.living(state, target):
		old_positions[member] = state.units[member].position
	var plan := prepare_plan(state, squad, model, target, weapon, bool(expected.melee))
	state.phase = old_phase
	state.active = old_active
	for member: int in old_positions: state.units[member].position = old_positions[member]
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1,
		"%s routes through AttackPlan: %s" % [weapon, plan.get("error", "")])

func submit_choice(state: Dictionary, player: int, selected: Dictionary, roller: Callable) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty(): return {"error": "No pending UnitActions decision."}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) != str(selected.get("action", "")) or int(option.get("model", -1)) != int(selected.get("model", -1)) or int(option.get("target", -1)) != int(selected.get("target", -1)) or str(option.get("value", "")) != str(selected.get("value", "")): continue
		var details: Dictionary = option.get("details", {})
		if details.has("die") and int(selected.get("die", -1)) != int(details.get("die", -2)): continue
		projected = option
		break
	if projected.is_empty(): return {"error": "The choice is not in the current decision projection."}
	return MatchCommands.execute(state, player, {"kind": MatchCommands.SELECT_UNIT_CHOICE, "revision": int(state.revision), "point": Vector2.ZERO,
		"choice": {"_decision_type": MatchCommands.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")),
			"option_id": str(projected.get("id", "")), "choice": selected}}, roller)

func check_deadly_demise() -> void:
	var model := {"definition_id": LANCER_ID, "owner": 1, "squad": 1, "wounds": 0, "max_wounds": 12,
		"position": Vector2.ZERO, "radius": 50.0 / 25.4, "keywords": ["VEHICLE"]}
	var enemy := {"definition_id": INTERCESSOR_ID, "owner": 2, "squad": 2, "wounds": 5, "max_wounds": 5,
		"position": Vector2(5, 0), "radius": 0.5, "keywords": ["INFANTRY"]}
	var state := {"units": {100: model, 200: enemy}, "squads": {1: {"owner": 1, "name": "Destroyed Lancer"}, 2: {"owner": 2, "name": "Intercessors"}},
		"unit_abilities": {"implementation": C.UnitAbilities.ID, "window": {}}, "pending_attack": {},
		"awakened_dynasty": {"owners": []}, "detachment_stratagems": {"destroyed": [], "revived": []}}
	dice = [5]
	var quiet := DeadlyDemise.begin(state, [100], roll_die)
	var triggered_state: Dictionary = state.duplicate(true)
	dice = [6, 1]
	var triggered := DeadlyDemise.begin(triggered_state, [100], roll_die)
	var packet: Dictionary = triggered_state.get("pending_deadly_demise", {}).get("packets", [{}])[0]
	check(quiet.get("error", "").is_empty() and quiet.complete and state.last_deadly_demise.events[0].expression == "D3"
		and not state.last_deadly_demise.events[0].triggered, "Lancer Deadly Demise uses its exported D3 trigger and does not trigger on 5")
	check(triggered.get("error", "").is_empty() and not triggered.complete and triggered_state.pending_deadly_demise.events[0].triggered
		and packet.get("owner", -1) == 2 and packet.get("target", -1) == 2 and packet.get("remaining", -1) == 1,
		"Lancer Deadly Demise triggers on 6 and queues its D3 mortal-wound packet to the nearby enemy")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("gladiator-lancer")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002705"
		and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00",
		"Gladiator Lancer cites its pinned local Wahapedia 11e identity and original runtime stamp")
	check(profile.models == 1 and profile.points_by_models == {1: 160} and profile.third_plus_points_by_models == {1: 180}
		and profile.max_supported_copies == 3 and is_equal_approx(profile.base_radius_inches, 50.0 / 25.4),
		"One-model composition, 100 mm base and first/third-copy costs match export")
	check(profile.stats == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12,
		"leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.damaged_threshold == 4,
		"All Lancer characteristics and Damaged 4 match export")
	var expected_keywords := ["ADEPTUS ASTARTES", "FRAME", "IMPERIUM", "SMOKE", "VEHICLE"]
	var actual_keywords: Array = profile.keywords.duplicate()
	expected_keywords.sort()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All five exported keywords are retained")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["defensive-array", "laser-destroyer"]
		and profile.melee.map(func(w: Dictionary) -> String: return w.id) == ["armoured-hull"],
		"Fixed ranged and melee loadout matches source; no equipment-option rows are present")
	check(AbilityCatalog.RULES.get("gladiator-lancer", []) == ["damaged-4", "deadly-demise-d3", "aquilon-optics"],
		"All source-linked Lancer abilities are registered on its runtime profile")
	check(Catalog.SPECS.has("gladiator-lancer") and Catalog.SPECS["gladiator-lancer"].current_reference
		and Roster.POINTS["gladiator-lancer"].sizes == {1: 160}
		and Roster.POINTS["gladiator-lancer"].third_plus_sizes == {1: 180},
		"Current construction catalog and roster pricing match all source cost tiers")
	var catalog_choice := Catalog.current_catalog_choice({"id": LANCER_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 160, "third_plus_cost": 180}],
		"Current construction exposes the source composition and first/third-copy costs")
	var one_copy := Catalog.admit(selection(1))
	var three_copies := Catalog.admit(selection(3))
	var four_copies := Catalog.admit(selection(4))
	check(one_copy.error.is_empty() and one_copy.total == 160 and three_copies.error.is_empty() and three_copies.total == 500
		and not four_copies.error.is_empty(),
		"Current Incursion construction applies first/third-copy prices and the three-copy cap: %s / %d; %s / %d; %s"
		% [one_copy.get("error", ""), one_copy.get("total", -1), three_copies.get("error", ""), three_copies.get("total", -1), four_copies.get("error", "")])

	var state := fixture()
	check(not state.has("error"), "Lancer roster materializes from the consolidated current catalog on both players: %s" % state.get("error", ""))
	if state.has("error"):
		print(state)
		quit(1)
		return
	var lancer := find_squad(state, 1, "gladiator-lancer")
	var enemy_intercessors := find_squad(state, 2, "intercessor-squad")
	var model: int = C.living(state, lancer)[0]
	check(lancer > 0 and find_squad(state, 2, "gladiator-lancer") > 0
		and C.UnitAbilities.has(state, lancer, "aquilon-optics")
		and C.UnitAbilities.has(state, lancer, "damaged-4") and C.UnitAbilities.has(state, lancer, "deadly-demise-d3"),
		"Both current-catalog Lancers materialize with Aquilon Optics, Damaged 4 and Deadly Demise")
	for weapon in WEAPONS:
		check_weapon_profile(state, lancer, model, enemy_intercessors, weapon)

	set_squad_keyword(state, enemy_intercessors, "VEHICLE", true)
	var vehicle_plan := prepare_plan(state, lancer, model, enemy_intercessors, "laser-destroyer")
	check(vehicle_plan.error.is_empty() and vehicle_plan.batches[0].context.get("aquilon_optics", false)
		and vehicle_plan.batches[0].context.get("free_hit_reroll", false)
		and vehicle_plan.batches[0].context.get("free_wound_reroll", false)
		and vehicle_plan.batches[0].context.get("free_damage_reroll", false),
		"Aquilon Optics offers one optional hit, wound and damage re-roll against VEHICLE")
	set_squad_keyword(state, enemy_intercessors, "VEHICLE", false)
	set_squad_keyword(state, enemy_intercessors, "MONSTER", true)
	var monster_plan := prepare_plan(state, lancer, model, enemy_intercessors, "laser-destroyer")
	check(monster_plan.error.is_empty() and monster_plan.batches[0].context.get("aquilon_optics", false),
		"Aquilon Optics also applies against MONSTER")
	set_squad_keyword(state, enemy_intercessors, "MONSTER", false)
	var ordinary_plan := prepare_plan(state, lancer, model, enemy_intercessors, "laser-destroyer")
	var melee_plan := prepare_plan(state, lancer, model, enemy_intercessors, "armoured-hull", true)
	check(ordinary_plan.error.is_empty() and not ordinary_plan.batches[0].context.get("aquilon_optics", false)
		and melee_plan.error.is_empty() and not melee_plan.batches[0].context.get("aquilon_optics", false),
		"Aquilon Optics excludes targets without its keywords and all melee attacks")

	# Resolve each optional Aquilon decision through the owner-projected public command route.
	set_squad_keyword(state, enemy_intercessors, "VEHICLE", true)
	state.phase = "shooting"
	state.active = 1
	var attack_result := C.resolve_attack_plan(state, 1, model,
		[{"model": model, "target": enemy_intercessors, "amount": 1, "weapon": "laser-destroyer", "profile": "standard"}],
		state.revision, false, true, func() -> int: return 1)
	var hit_choices := C.unit_choices(state, 1)
	check(attack_result.error.is_empty() and state.unit_abilities.window.get("kind", "") == "aquilon-hit"
		and hit_choices.any(func(choice: Dictionary) -> bool: return choice.action == "hit-reroll")
		and hit_choices.any(func(choice: Dictionary) -> bool: return choice.action == "hit-finish"),
		"Combat projects Aquilon's optional hit re-roll or continue decision")
	if state.unit_abilities.window.get("kind", "") == "aquilon-hit":
		var hit_choice: Dictionary = hit_choices.filter(func(choice: Dictionary) -> bool: return choice.action == "hit-reroll")[0]
		var before_wrong_owner := var_to_bytes(state)
		var wrong_owner := submit_choice(state, 2, hit_choice, func() -> int: return 6)
		check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(state) == before_wrong_owner,
			"Opponent cannot submit the Lancer's projected reroll")
		var hit_result := submit_choice(state, 1, hit_choice, func() -> int: return 6)
		var wound_choices := C.unit_choices(state, 1).filter(func(choice: Dictionary) -> bool: return choice.action == "wound-reroll")
		check(hit_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == "wound"
			and state.pending_attack.aquilon_used[str(enemy_intercessors)].get("hit", false) and wound_choices.size() == 1,
			"Using the hit reroll advances to exactly one target-specific Aquilon wound reroll")
		if not wound_choices.is_empty():
			dice = [6, 1, 1]
			var wound_result := submit_choice(state, 1, wound_choices[0], roll_die)
			var damage_choices := C.unit_choices(state, 1)
			check(wound_result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == "damage-reroll"
				and damage_choices.any(func(choice: Dictionary) -> bool: return choice.action == "damage-reroll" and str(choice.label).begins_with("Aquilon Optics"))
				and state.pending_attack.aquilon_used[str(enemy_intercessors)].get("wound", false)
				and state.pending_attack.aquilon_used[str(enemy_intercessors)].get("damage", false),
				"Wound reroll resolves once and offers the optional Aquilon damage reroll")

	var damaged_state := fixture()
	var damaged_lancer := find_squad(damaged_state, 1, "gladiator-lancer")
	var damaged_model: int = C.living(damaged_state, damaged_lancer)[0]
	var damaged_target := find_squad(damaged_state, 2, "intercessor-squad")
	damaged_state.units[damaged_model].wounds = 5
	var healthy_boundary := prepare_plan(damaged_state, damaged_lancer, damaged_model, damaged_target, "defensive-array")
	damaged_state.units[damaged_model].wounds = 4
	var damaged_boundary := prepare_plan(damaged_state, damaged_lancer, damaged_model, damaged_target, "defensive-array")
	check(healthy_boundary.error.is_empty() and healthy_boundary.batches[0].context.hit_modifier == 0
		and damaged_boundary.error.is_empty() and damaged_boundary.batches[0].context.hit_modifier == -1,
		"Damaged 4 applies its -1 hit modifier at the exported four-wound boundary only")
	check_deadly_demise()

	print("Current Gladiator Lancer checks: %d failures" % failures)
	quit(1 if failures else 0)
