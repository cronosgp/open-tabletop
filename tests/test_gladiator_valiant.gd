extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const AbilityCatalog = preload("res://scripts/edition_11/unit_ability_catalog.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const DeadlyDemise = preload("res://scripts/edition_11/deadly_demise.gd")
const VALIANT_ID := "40kdc:11e:adeptus-astartes:gladiator-valiant"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const WEAPONS := {
	"defensive-array": {"melee": false, "range_inches": 24.0, "attacks": 6, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"rapid-fire": 6}},
	"multi-melta-left": {"melee": false, "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}},
	"multi-melta-right": {"melee": false, "range_inches": 18.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+2", "keywords": {"melta": 3}},
	"twin-las-talon": {"melee": false, "range_inches": 36.0, "attacks": 2, "skill": 3, "strength": 10, "ap": -3, "damage": "D3+3", "keywords": {"twin-linked": true}},
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

func selection(copies: int = 1, category: String = "incursion") -> Dictionary:
	return {"schema_version": 2, "faction": "Space Marines", "category": category, "points_limit": 2000 if category == "strike_force" else 1000,
		"entries": [{"definition_id": VALIANT_ID, "models": 1, "copies": copies}]}

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	for owner in [1, 2]:
		result[owner].entries = [
			{"definition_id": VALIANT_ID, "models": 1, "copies": 1},
			{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1}]
	return result

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) == owner and C.UnitAbilities.identity(unit) == identity:
			return int(unit.get("squad", -1))
	return -1

func fixture() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true,
		"combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true,
		"core_stratagems": true, "manual_allocation": false}, selections())
	if state.has("error"): return state
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
	for model: int in state.units:
		state.units[model].position = Vector2(-20, -15) if state.units[model].owner == 1 else Vector2(20, 15)
	var friendly := find_squad(state, 1, "gladiator-valiant")
	for model: int in C.living(state, friendly): state.units[model].position = Vector2.ZERO
	var enemy := find_squad(state, 2, "intercessor-squad")
	for index in range(C.living(state, enemy).size()):
		state.units[C.living(state, enemy)[index]].position = Vector2(6, index * 3)
	return state

func prepare_plan(state: Dictionary, squad: int, model: int, target: int, weapon: String, melee: bool = false) -> Dictionary:
	var previous_phase: String = str(state.phase)
	var previous_active: int = int(state.active)
	var previous_positions := {}
	for member: int in C.living(state, squad) + C.living(state, target):
		previous_positions[member] = state.units[member].position
	state.phase = "fight" if melee else "shooting"
	state.active = int(state.squads[squad].owner)
	state.units[model].position = Vector2.ZERO
	var targets: Array[int] = C.living(state, target)
	for index in range(targets.size()):
		state.units[targets[index]].position = Vector2(1, 0) if melee and index == 0 else Vector2(6, index * 3)
	var expected: Dictionary = WEAPONS[weapon]
	var plan := C.AttackPlan.prepare(state, squad, melee,
		[{"model": model, "target": target, "amount": int(expected.attacks) if melee else 1, "weapon": weapon, "profile": "standard"}], true)
	state.phase = previous_phase
	state.active = previous_active
	for member: int in previous_positions: state.units[member].position = previous_positions[member]
	return plan

func check_weapon_profile(state: Dictionary, squad: int, model: int, target: int, weapon: String) -> void:
	var expected: Dictionary = WEAPONS[weapon]
	var selected := Equipment.select(state, model, bool(expected.melee), weapon, "standard")
	check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % weapon)
	if not str(selected.get("error", "")).is_empty(): return
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s %s matches the verified export" % [weapon, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s preserves every exported weapon trait" % weapon)
	var plan := prepare_plan(state, squad, model, target, weapon, bool(expected.melee))
	var expected_strength := int(expected.strength) + (0 if bool(expected.melee) else 1)
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1
		and int(plan.batches[0].weapon.strength) == expected_strength,
		"%s routes through AttackPlan with its source strength/effect: %s" % [weapon, plan.get("error", "")])

func check_deadly_demise() -> void:
	var model := {"definition_id": VALIANT_ID, "owner": 1, "squad": 1, "wounds": 0, "max_wounds": 12,
		"position": Vector2.ZERO, "radius": 50.0 / 25.4, "keywords": ["VEHICLE"]}
	var enemy := {"definition_id": INTERCESSOR_ID, "owner": 2, "squad": 2, "wounds": 5, "max_wounds": 5,
		"position": Vector2(5, 0), "radius": 0.5, "keywords": ["INFANTRY"]}
	var state := {"units": {100: model, 200: enemy}, "squads": {1: {"owner": 1, "name": "Destroyed Valiant"}, 2: {"owner": 2, "name": "Intercessors"}},
		"unit_abilities": {"implementation": C.UnitAbilities.ID, "window": {}}, "pending_attack": {},
		"awakened_dynasty": {"owners": []}, "detachment_stratagems": {"destroyed": [], "revived": []}}
	dice = [5]
	var quiet := DeadlyDemise.begin(state, [100], roll_die)
	var triggered_state: Dictionary = state.duplicate(true)
	dice = [6, 1]
	var triggered := DeadlyDemise.begin(triggered_state, [100], roll_die)
	var packet: Dictionary = triggered_state.get("pending_deadly_demise", {}).get("packets", [{}])[0]
	check(quiet.get("error", "").is_empty() and quiet.complete and state.last_deadly_demise.events[0].expression == "D3"
		and not state.last_deadly_demise.events[0].triggered, "Valiant Deadly Demise uses its exported D3 trigger and does not trigger on 5")
	check(triggered.get("error", "").is_empty() and not triggered.complete and triggered_state.pending_deadly_demise.events[0].triggered
		and packet.get("owner", -1) == 2 and packet.get("target", -1) == 2 and packet.get("remaining", -1) == 1,
		"Valiant Deadly Demise triggers on 6 and queues the nearby enemy's mortal-wound packet")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("gladiator-valiant")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000001825"
		and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00",
		"Gladiator Valiant cites its pinned local Wahapedia 11e identity and source stamp")
	check(profile.models == 1 and profile.points_by_models == {1: 165} and profile.third_plus_points_by_models == {1: 185}
		and profile.max_supported_copies == 3 and is_equal_approx(profile.base_radius_inches, 50.0 / 25.4),
		"One-model composition, 100 mm base and first/third-copy costs match export")
	check(profile.stats == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12,
		"leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.damaged_threshold == 4,
		"All Valiant characteristics and Damaged 4 match export")
	var expected_keywords := ["ADEPTUS ASTARTES", "FRAME", "IMPERIUM", "SMOKE", "VEHICLE"]
	var actual_keywords: Array = profile.keywords.duplicate()
	expected_keywords.sort()
	actual_keywords.sort()
	check(actual_keywords == expected_keywords, "All five exported keywords are retained")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id)
		== ["defensive-array", "multi-melta-left", "multi-melta-right", "twin-las-talon"]
		and profile.melee.map(func(w: Dictionary) -> String: return w.id) == ["armoured-hull"],
		"Fixed loadout preserves both physical Multi-meltas and the Armoured Hull")
	check(AbilityCatalog.RULES.get("gladiator-valiant", [])
		== ["damaged-4", "deadly-demise-d3", "priority-target-acquisition"],
		"All source-linked Valiant abilities are registered on its runtime profile")
	check(Catalog.SPECS.has("gladiator-valiant") and Catalog.SPECS["gladiator-valiant"].current_reference
		and Roster.POINTS["gladiator-valiant"].sizes == {1: 165}
		and Roster.POINTS["gladiator-valiant"].third_plus_sizes == {1: 185},
		"Current construction catalog and roster pricing match both source cost tiers")
	var catalog_choice := Catalog.current_catalog_choice({"id": VALIANT_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog_choice.get("options", []) == [{"models": 1, "cost": 165, "third_plus_cost": 185}],
		"Current construction exposes the source model count and copy-price tiers")
	var one_copy := Catalog.admit(selection(1))
	var three_copies := Catalog.admit(selection(3, "strike_force"))
	var four_copies := Catalog.admit(selection(4, "strike_force"))
	check(one_copy.error.is_empty() and one_copy.total == 165 and three_copies.error.is_empty()
		and three_copies.total == 515 and not four_copies.error.is_empty(),
		"Current Strike Force construction applies first/third-copy costs and the three-copy cap: %s / %d; %s / %d; %s"
		% [one_copy.get("error", ""), one_copy.get("total", -1), three_copies.get("error", ""), three_copies.get("total", -1), four_copies.get("error", "")])

	var state := fixture()
	check(not state.has("error"), "Valiant rosters materialize from the consolidated current catalog for both players: %s" % state.get("error", ""))
	if state.has("error"):
		print(state)
		quit(1)
		return
	var valiant := find_squad(state, 1, "gladiator-valiant")
	var enemy := find_squad(state, 2, "intercessor-squad")
	if valiant < 0 or enemy < 0:
		check(false, "The current catalogs resolve the Valiant and target squads")
		quit(1)
		return
	var model: int = C.living(state, valiant)[0]
	check(C.UnitAbilities.has(state, valiant, "priority-target-acquisition")
		and C.UnitAbilities.has(state, valiant, "damaged-4")
		and C.UnitAbilities.has(state, valiant, "deadly-demise-d3"),
		"Priority Target Acquisition and shared vehicle abilities materialize")
	check(state.units[model].ranged_weapons.map(func(w: Dictionary) -> String: return w.id)
		== ["defensive-array", "multi-melta-left", "multi-melta-right", "twin-las-talon"],
		"The model receives both physical Multi-meltas as separate ranged weapon instances")
	for weapon in WEAPONS:
		check_weapon_profile(state, valiant, model, enemy, weapon)

	var near_weapon: Dictionary = profile.ranged[0].profiles.standard
	var near_range_result := C.UnitAbilities.weapon(state, model, enemy, near_weapon, false)
	for weapon in profile.ranged:
		var source_weapon: Dictionary = weapon.profiles.standard
		var within_range := C.UnitAbilities.weapon(state, model, enemy, source_weapon, false)
		check(within_range.strength == source_weapon.strength + 1, "%s gains +1 Strength against the nearby target" % weapon.id)
		check(source_weapon.strength == weapon.profiles.standard.strength, "Range bonus does not mutate the source profile")
	check(near_range_result.strength == near_weapon.strength + 1, "Priority Target Acquisition applies to ranged attacks within 12 inches")

	var far_model: int = C.living(state, enemy)[0]
	var base_edges := float(state.units[model].radius) + float(state.units[far_model].radius)
	for target_model: int in C.living(state, enemy): state.units[target_model].position = Vector2(12.0 + base_edges, 0)
	for adjustment in range(2):
		var correction := 12.0 - Geometry.distance_to_target(state, state.units[model], enemy)
		for target_model: int in C.living(state, enemy): state.units[target_model].position.x += correction
	var boundary_distance := Geometry.distance_to_target(state, state.units[model], enemy)
	var boundary := C.UnitAbilities.weapon(state, model, enemy, profile.ranged[3].profiles.standard, false)
	check(boundary_distance >= 11.999 and boundary_distance <= 12.001 and boundary.strength == 11,
		"The bonus applies at the 12-inch base-edge boundary")
	state.phase = "shooting"
	state.active = 1
	var boundary_plan := C.AttackPlan.prepare(state, valiant, false,
		[{"model": model, "target": enemy, "amount": 1, "weapon": "twin-las-talon", "profile": "standard"}], true)
	check(boundary_plan.error.is_empty() and boundary_plan.batches[0].weapon.strength == 11,
		"Prepared ranged attacks carry +1 Strength at the 12-inch boundary")
	for target_model: int in C.living(state, enemy): state.units[target_model].position.x += 0.02
	var beyond := C.UnitAbilities.weapon(state, model, enemy, profile.ranged[3].profiles.standard, false)
	var beyond_plan := C.AttackPlan.prepare(state, valiant, false,
		[{"model": model, "target": enemy, "amount": 1, "weapon": "twin-las-talon", "profile": "standard"}], true)
	check(beyond.strength == 10 and beyond_plan.error.is_empty() and beyond_plan.batches[0].weapon.strength == 10,
		"The Strength bonus stops immediately beyond 12 inches in the profile and AttackPlan")
	var melee_source: Dictionary = profile.melee[0].profiles.standard
	var melee_weapon := C.UnitAbilities.weapon(state, model, enemy, melee_source, true)
	check(melee_weapon.strength == melee_source.strength, "Priority Target Acquisition does not modify melee attacks")
	for index in range(C.living(state, enemy).size()):
		state.units[C.living(state, enemy)[index]].position = Vector2(1, 0) if index == 0 else Vector2(6, index * 3)
	state.phase = "fight"
	var melee_plan := C.AttackPlan.prepare(state, valiant, true,
		[{"model": model, "target": enemy, "amount": 3, "weapon": "armoured-hull", "profile": "standard"}], true)
	check(melee_plan.error.is_empty() and melee_plan.batches[0].weapon.strength == 6,
		"Prepared Armoured Hull attacks retain their source Strength")

	var damaged_state := fixture()
	var damaged_lancer := find_squad(damaged_state, 1, "gladiator-valiant")
	var damaged_model: int = C.living(damaged_state, damaged_lancer)[0]
	var damaged_target := find_squad(damaged_state, 2, "intercessor-squad")
	damaged_state.units[damaged_model].wounds = 5
	var healthy_boundary := C.AttackPlan.prepare(damaged_state, damaged_lancer, false,
		[{"model": damaged_model, "target": damaged_target, "amount": 1, "weapon": "defensive-array", "profile": "standard"}], true)
	damaged_state.units[damaged_model].wounds = 4
	var damaged_boundary := C.AttackPlan.prepare(damaged_state, damaged_lancer, false,
		[{"model": damaged_model, "target": damaged_target, "amount": 1, "weapon": "defensive-array", "profile": "standard"}], true)
	check(healthy_boundary.error.is_empty() and healthy_boundary.batches[0].context.hit_modifier == 0
		and damaged_boundary.error.is_empty() and damaged_boundary.batches[0].context.hit_modifier == -1,
		"Damaged 4 applies its -1 hit modifier at the four-wound boundary only")
	check_deadly_demise()

	print("Current Gladiator Valiant checks: %d failures" % failures)
	quit(1 if failures else 0)
