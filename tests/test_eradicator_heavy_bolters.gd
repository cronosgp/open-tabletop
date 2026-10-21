extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const UNIT := "eradicator-squad-with-heavy-bolters"
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func lists() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:apothecary-biologis", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 6, "copies": 1}]
	return result
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, lists())
	if s.has("error"): return s
	s.awakened_dynasty.pending = []
	s.mission.stage = "battle"
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.deployment.complete = true
	s.phase = "shooting"
	s.turn = 3
	s.round = 2
	s.active = 1
	s.cp = {1: 3, 2: 3}
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.window = {}
	s.terrain.areas = []
	for key in ["attack_rerolls", "save_rerolls", "damage_rerolls", "count_rerolls", "hazard_rerolls"]: s.stratagems[key] = false
	for model: int in s.units:
		s.units[model].position = Vector2(-20, -15) if s.units[model].owner == 1 else Vector2(20, 15)
	for model: int in C.living(s, 3): s.units[model].position = Vector2.ZERO
	for model: int in C.living(s, 4): s.units[model].position = Vector2(8, 0)
	return s
func mark(s: Dictionary, squad: int, target: int) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == "overlap-target" and s.units[selected.model].squad == squad and selected.target == target: return selected
	return {}
func apply(s: Dictionary, selected: Dictionary) -> String:
	return C.unit_action(s, 1, selected, Vector2.ZERO, s.revision)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	check(not s.has("error"), "Current Heavy Bolter Eradicator configurations admit with a legal Biologis bodyguard")
	if s.has("error"):
		print(s)
		quit(1)
		return
	check(s.training_points[1] == 375 and s.squads[3].training_cost == 100 and s.squads[5].training_cost == 215, "3/6 formations preserve non-linear source prices")
	check(C.living(s, 3).size() == 3 and C.living(s, 5).size() == 6 and s.units[300].radius == 20.0 / 25.4, "Current composition and 40mm bases materialize")
	check(C.UnitActions.attachment_allowed(s, 100, 3) and C.UnitActions.attachment_allowed(s, 100, 5), "Biologis support accepts both Heavy Bolter Eradicator configurations")
	var raw: Dictionary = Profiles.profile(UNIT).ranged[0].profiles.standard
	check(not C.UnitAbilities.weapon(s, 300, 4, raw, false).keywords.has("blast"), "Optional ability does not apply without selecting a target")
	check(apply(s, mark(s, 3, 4)).is_empty() and s.cp[1] == 3 and s.stratagems.uses.is_empty(), "Target selection spends no CP and is not a stratagem")
	check(C.UnitAbilities.weapon(s, 300, 4, raw, false).keywords.get("blast", 0) == 1 and not raw.keywords.has("blast"), "Only selected Heavy Bolter gains Blast 1; source profile stays immutable")
	var pistol: Dictionary = Profiles.profile(UNIT).ranged[1].profiles.standard
	check(not C.UnitAbilities.weapon(s, 300, 4, pistol, false).keywords.has("blast") and not C.UnitAbilities.weapon(s, 300, 4, raw, true).keywords.has("blast"), "Pistol and melee are unaffected")
	check(not C.UnitAbilities.weapon(s, 500, 4, raw, false).keywords.has("blast") and not C.UnitAbilities.weapon(s, 300, 2, raw, false).keywords.has("blast"), "Other squads and other targets are unaffected")
	var declaration := [{"model": 300, "target": 4, "amount": 1, "weapon": "heavy-bolter", "profile": "standard"}]
	var plan := C.AttackPlan.prepare(s, 3, false, declaration, true)
	check(plan.error.is_empty() and plan.batches[0].context.attack_sources[0].bonus == 4, "Actual attack combines Rapid Fire 2 and Blast 1 against ten models")
	s.units[409].wounds = 0
	plan = C.AttackPlan.prepare(s, 3, false, declaration, true)
	check(plan.error.is_empty() and plan.batches[0].context.attack_sources[0].bonus == 3, "Blast uses current target size when preparing the attack")
	check(apply(s, mark(s, 3, 2)).is_empty() and not C.UnitAbilities.weapon(s, 300, 4, raw, false).keywords.has("blast"), "Revising an uncommitted choice replaces the previous target rather than accumulating effects")
	check(apply(s, mark(s, 3, 4)).is_empty(), "Target can be restored before committing attacks")
	s = bytes_to_var(var_to_bytes(s))
	check(C.UnitAbilities.weapon(s, 300, 4, raw, false).keywords.get("blast", 0) == 1, "Target selection survives state serialization")
	var attack := C.resolve_attack_plan(s, 1, 300, declaration, s.revision, false, true, func() -> int: return 1)
	check(attack.error.is_empty() and s.last_attack.pools[0].attacks == 6 and mark(s, 3, 4).is_empty(), "Committed shot uses the selected target and closes further target changes")
	s.phase = "charge"
	check(not C.UnitAbilities.weapon(s, 300, 4, raw, false).keywords.has("blast"), "Effect expires after own Shooting")
	s.phase = "shooting"
	s.turn += 2
	check(not C.UnitAbilities.weapon(s, 300, 4, raw, false).keywords.has("blast"), "Selection cannot leak into later turns")
	s = fixture()
	s.active = 2
	check(mark(s, 3, 4).is_empty(), "Ability is unavailable in the opponent turn")
	s = fixture()
	# An engaged Vehicle can be a normal ranged target, but not a Blast target.
	for model: int in C.living(s, 4):
		s.units[model].position = Vector2(5, 0)
		s.units[model].keywords.append("VEHICLE")
	s.units[100].position = Vector2(5, 0)
	check(4 in C.AttackPlan.legal_targets(s, 300, false, "heavy-bolter", "standard"), "Unmarked Heavy Bolter can target an engaged Vehicle under the shared rules")
	check(apply(s, mark(s, 3, 4)).is_empty(), "Ability can select the enemy without inventing a visibility/range eligibility condition")
	check(4 not in C.AttackPlan.legal_targets(s, 300, false, "heavy-bolter", "standard") and not C.AttackPlan.prepare(s, 3, false, declaration, true).error.is_empty(), "Ability-granted Blast also enforces engaged-target restrictions before dice")
	var invalid := lists()
	invalid[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:" + UNIT, "models": 3, "copies": 1})
	check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Both sizes share the Incursion repetition cap")
	var catalog := F.P.Training.Capabilities.current_catalog_choice({"id": "openhammer:11e:Space%20Marines:3bc7-8328-a080-3958", "edition": "11e", "faction": "Space Marines"})
	check(catalog.options == [{"models": 3, "cost": 100}, {"models": 6, "cost": 215}], "Builder alias uses current source sizes and costs")
	print("Heavy Bolter Eradicator checks: %d failures" % failures)
	quit(1 if failures else 0)
