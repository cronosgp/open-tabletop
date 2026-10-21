extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func lists() -> Dictionary:
	var result := F.selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:apothecary-biologis", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:aggressor-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:heavy-intercessor-squad", "models": 5, "copies": 1}]
	return result
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, lists())
	if s.has("error"): return s
	s.awakened_dynasty.pending = []
	s.mission.stage = "battle"
	s.terrain.areas = []
	return s
func option(s: Dictionary, action: String, model: int = -2, target: int = -2) -> Dictionary:
	for selected: Dictionary in C.unit_choices(s, 1):
		if selected.action == action and (model == -2 or selected.model == model) and (target == -2 or selected.target == target): return selected
	return {}
func apply(s: Dictionary, selected: Dictionary) -> String:
	return C.unit_action(s, 1, selected, Vector2.ZERO, s.revision)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	check(not s.has("error") and s.training_points[1] == 265, "Biologis and admitted Gravis bodyguards use current profile costs")
	if s.has("error"):
		print(s)
		quit(1)
		return
	check(s.units[300].wounds == 5 and s.units[300].radius == 20.0 / 25.4, "Biologis has current five-wound profile and 40mm base")
	check(C.UnitActions.attachment_allowed(s, 300, 1) and C.UnitActions.attachment_allowed(s, 300, 5), "Biologis can support Aggressors and Heavy Intercessors")
	check(not apply(s, option(s, "setup-done")).is_empty(), "Preparation cannot finish with an unattached Support")
	check(apply(s, option(s, "warlord", 300)).is_empty(), "Eligible Biologis Character can be selected as Warlord")
	check(apply(s, option(s, "attach", 300, 1)).is_empty(), "Actual preparation attaches Biologis as Support")
	check(s.units[300].squad == 1 and s.units[300].attachment_role == "support" and s.squads[1].starting_strength == 4, "Attached composition preserves Support role and starting strength")
	check(apply(s, option(s, "setup-done")).is_empty() and s.roster_validation.armies[1].formations_verified, "Checked formation seals with mandatory Support attached")
	s = bytes_to_var(var_to_bytes(s))
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.deployment.complete = true
	s.phase = "shooting"
	s.active = 1
	s.turn = 3
	s.round = 2
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.window = {}
	for model: int in s.units:
		s.units[model].position = Vector2(-20, -15) if s.units[model].owner == 1 else Vector2(20, 15)
	for model: int in C.living(s, 1): s.units[model].position = Vector2.ZERO
	for model: int in C.living(s, 4): s.units[model].position = Vector2(8, 0)
	var fist: Dictionary = Profiles.profile("aggressor-squad").melee[0].profiles.standard
	check(C.UnitAbilities.weapon(s, 100, 4, fist, true).keywords.get("lethal-hits", false), "Living Support grants Lethal Hits to bodyguard melee")
	var pistol: Dictionary = Profiles.profile("apothecary-biologis").ranged[0].profiles.standard
	check(C.UnitAbilities.weapon(s, 300, 4, pistol, false).strength == 6, "Aggressor unit Strength bonus also applies to attached Support attacks")
	for model: int in C.living(s, 4): s.units[model].keywords.append("MONSTER")
	check(C.UnitAbilities.weapon(s, 100, 4, fist, true).keywords.get("lethal-hits", false), "Monster targets are eligible under non-Vehicle restriction")
	s.units[401].keywords.append("VEHICLE")
	check(not C.UnitAbilities.weapon(s, 100, 4, fist, true).keywords.get("lethal-hits", false), "A Vehicle keyword on any living target model excludes the whole target unit")
	s.units[401].wounds = 0
	check(C.UnitAbilities.weapon(s, 100, 4, fist, true).keywords.get("lethal-hits", false), "Destroyed target models no longer provide their Vehicle keyword")
	# Switch the bodyguards to boltstorm to observe real critical-hit auto wounds.
	for model in [100, 101, 102]: s.units[model].ranged_weapons = Profiles.aggressor_ranged(true)
	var declared := [{"model": 100, "target": 4, "amount": 1, "weapon": "auto-boltstorm-gauntlets", "profile": "standard"}]
	var plan := C.AttackPlan.prepare(s, 1, false, declared, true)
	check(plan.error.is_empty() and plan.batches[0].weapon.keywords.get("lethal-hits", false), "Support propagation reaches the actual attack plan")
	var dice := [6, 2, 2, 1]
	var pool := C.AttackPlan.Attacks.roll_pool(plan.batches[0].weapon, C.AttackPlan.defender(s, 4), plan.batches[0].context, func() -> int: return dice.pop_front())
	check(pool.error.is_empty() and pool.hits == 1 and pool.wounds == 1 and pool.wound_rolls.is_empty(), "Critical bolt hit automatically wounds a Monster without rolling to wound")
	s.units[300].wounds = 0
	check(not C.UnitAbilities.weapon(s, 100, 4, fist, true).keywords.get("lethal-hits", false), "Support loss removes Lethal Hits from future attack declarations")
	s = fixture()
	s.units[500].attachment_role = "support"
	check(not C.UnitActions.attachment_allowed(s, 300, 5), "A bodyguard cannot receive a second Support")
	var invalid := lists()
	invalid[1].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:apothecary-biologis", "models": 1, "copies": 1}, {"definition_id": "40kdc:11e:adeptus-astartes:intercessor-squad", "models": 5, "copies": 1}]
	check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Intercessors cannot satisfy the Biologis Gravis bodyguard requirement")
	invalid[1].entries[1] = {"definition_id": "40kdc:11e:adeptus-astartes:aggressor-squad", "models": 3, "copies": 1}
	invalid[1].entries[0].copies = 2
	check(not C.RosterValidation.admit(invalid[1]).error.is_empty(), "Two Biologis Support units need two separate legal bodyguards")
	print("Biologis checks: %d failures" % failures)
	quit(1 if failures else 0)
