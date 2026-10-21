extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const C = F.C
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func squad(state: Dictionary, identity: String) -> int:
	for model: int in state.units:
		if C.UnitAbilities.identity(state.units[model]) == identity: return int(state.units[model].squad)
	return -1

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("gladiator-lancer")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000002705" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Gladiator Lancer cites the pinned local Wahapedia e11 sheet")
	check(profile.points_by_models == {1: 160} and profile.third_plus_points_by_models == {1: 180} and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 100.0 / 25.4 / 2.0), "100 mm base, one-model composition and tiered source costs are represented")
	check(profile.stats == {"movement_inches": 10, "toughness": 10, "save_target": 3, "wounds": 12, "leadership_target": 6, "objective_control": 3, "invulnerable_target": 0} and profile.keywords.has("VEHICLE") and profile.keywords.has("SMOKE"), "Lancer characteristics and keywords match its local rows")
	check(profile.ranged.map(func(w: Dictionary) -> String: return w.id) == ["defensive-array", "laser-destroyer"] and profile.ranged[1].profiles.standard.damage == "D6+3" and profile.ranged[1].profiles.standard.keywords == {"heavy": true}, "Fixed Lancer ranged weapons, Heavy and D6+3 damage match the extraction")
	check(Catalog.SPECS.has("gladiator-lancer") and Roster.POINTS["gladiator-lancer"].sizes == {1: 160} and Roster.POINTS["gladiator-lancer"].third_plus_sizes == {1: 180}, "Lancer is admitted with its local points tiers")
	var lists := F.selections()
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:gladiator-lancer", "models": 1, "copies": 1})
	var state := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Lancer roster selection materializes in the local runtime")
	if state.has("error"):
		print(state)
		quit(1)
		return
	state.phase = "shooting"
	state.turn = 3
	state.active = 1
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.awakened_dynasty.pending = []
	state.deployment.complete = true
	state.mission.stage = "battle"
	state.unit_abilities.window = {}
	state.stratagems.attack_rerolls = false
	var lancer := squad(state, "gladiator-lancer")
	var target := squad(state, "necron-warriors")
	var model := C.living(state, lancer)[0]
	for id: int in state.units: state.units[id].position = Vector2(-18, -14) if state.units[id].owner == 1 else Vector2(18, 14)
	state.units[model].position = Vector2.ZERO
	for id: int in C.living(state, target):
		state.units[id].position = Vector2(20, 0)
		state.units[id].keywords.append("VEHICLE")
	check(C.UnitAbilities.has(state, lancer, "aquilon-optics") and C.UnitAbilities.has(state, lancer, "damaged-4") and C.UnitAbilities.has(state, lancer, "deadly-demise-d3"), "Aquilon Optics and shared vehicle abilities materialize")
	var ranged := C.AttackPlan.prepare(state, lancer, false, [{"model": model, "target": target, "amount": 1, "weapon": "laser-destroyer", "profile": "standard"}], true)
	check(ranged.error.is_empty() and ranged.batches[0].context.get("aquilon_optics", false) and ranged.batches[0].context.get("free_hit_reroll", false) and ranged.batches[0].context.get("free_wound_reroll", false) and ranged.batches[0].context.get("free_damage_reroll", false), "Aquilon opens one optional hit, wound and damage reroll against VEHICLE")
	var attack_result := C.resolve_attack_plan(state, 1, model, [{"model": model, "target": target, "amount": 1, "weapon": "laser-destroyer", "profile": "standard"}], state.revision, false, true, func() -> int: return 1)
	var hit_choices := C.unit_choices(state, 1)
	check(attack_result.error.is_empty() and state.unit_abilities.window.get("kind", "") == "aquilon-hit" and hit_choices.any(func(choice: Dictionary) -> bool: return choice.action == "hit-reroll") and hit_choices.any(func(choice: Dictionary) -> bool: return choice.action == "hit-finish"), "Combat exposes an optional single hit-die reroll choice")
	if state.unit_abilities.window.get("kind", "") == "aquilon-hit":
		var hit_choice: Dictionary = hit_choices.filter(func(choice: Dictionary) -> bool: return choice.action == "hit-reroll")[0]
		var hit_error := C.unit_action(state, 1, hit_choice, Vector2.ZERO, state.revision, func() -> int: return 6)
		check(hit_error.is_empty() and state.pending_attack.current.checkpoint.phase == "wound" and state.unit_abilities.window.get("kind", "") == "wound" and state.pending_attack.aquilon_used[str(target)].get("hit", false), "Choosing one hit die reroll advances to Aquilon's optional wound reroll window and consumes its hit reroll for this target")
		var wound_choices := C.unit_choices(state, 1)
		var wound_rerolls := wound_choices.filter(func(choice: Dictionary) -> bool: return choice.action == "wound-reroll")
		check(wound_rerolls.size() == 1, "Aquilon offers one eligible wound-die reroll choice")
		if not wound_rerolls.is_empty():
			var dice: Array[int] = [6, 1, 1]
			var wound_error := C.unit_action(state, 1, wound_rerolls[0], Vector2.ZERO, state.revision, func() -> int: return dice.pop_front() if not dice.is_empty() else 1)
			var damage_choices := C.unit_choices(state, 1)
			check(wound_error.is_empty() and state.unit_abilities.window.get("kind", "") == "damage-reroll" and damage_choices.any(func(choice: Dictionary) -> bool: return choice.action == "damage-reroll" and str(choice.label).begins_with("Aquilon Optics")) and state.pending_attack.aquilon_used[str(target)].get("wound", false) and state.pending_attack.aquilon_used[str(target)].get("damage", false), "Aquilon wound reroll resolves once for the target and opens its optional damage reroll")
	for id: int in C.living(state, target): state.units[id].keywords.erase("VEHICLE")
	var normal_target := C.AttackPlan.prepare(state, lancer, false, [{"model": model, "target": target, "amount": 1, "weapon": "laser-destroyer", "profile": "standard"}], true)
	var melee := C.AttackPlan.prepare(state, lancer, true, [{"model": model, "target": target, "amount": 1, "weapon": "armoured-hull", "profile": "standard"}], true)
	for id: int in C.living(state, target): state.units[id].position = Vector2(3, 0)
	melee = C.AttackPlan.prepare(state, lancer, true, [{"model": model, "target": target, "amount": 3, "weapon": "armoured-hull", "profile": "standard"}], true)
	check(normal_target.error.is_empty() and not normal_target.batches[0].context.get("aquilon_optics", false) and melee.error.is_empty() and not melee.batches[0].context.get("aquilon_optics", false), "Aquilon Optics does not affect ordinary targets or melee")
	print("Current Gladiator Lancer checks: %d failures" % failures)
	quit(1 if failures else 0)
