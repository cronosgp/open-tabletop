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
		{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:aggressor-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:aggressor-squad", "models": 6, "copies": 1}]
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
	for model: int in C.living(s, 1): s.units[model].position = Vector2.ZERO
	for model: int in C.living(s, 4): s.units[model].position = Vector2(8, 0)
	return s
func choose(s: Dictionary, action: String, target: int) -> Dictionary:
	for option: Dictionary in C.unit_choices(s, 1):
		if option.action == action and option.target == target: return option
	return {}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	check(not s.has("error"), "Both Aggressor formations admit with current rules")
	if s.has("error"):
		print(s)
		quit(1)
		return
	check(s.training_points[1] == 360 and C.living(s, 1).size() == 3 and C.living(s, 3).size() == 6, "3/6 formations retain separate 90/180 point costs")
	check(s.units[100].radius == 20.0 / 25.4 and s.units[100].wounds == 3 and s.squads[1].stats.toughness == 6, "Current Gravis stats and 40mm bases materialize")
	check(not C.UnitActions.attachment_allowed(s, 500, 1), "Regular Captain is not silently allowed to lead Gravis Aggressors")
	check(not C.CoreReactions.keyword(s, 1, "EXPLOSIVES"), "Fragstorm equipment does not invent an EXPLOSIVES keyword")
	var raw: Dictionary = Profiles.profile("aggressor-squad").ranged[0].profiles.ranged
	check(C.UnitAbilities.weapon(s, 100, 4, raw, false).strength == 5 and raw.strength == 4, "Close-quarters Firestorm adds Strength once without changing source data")
	var melee: Dictionary = Profiles.profile("aggressor-squad").melee[0].profiles.standard
	check(C.UnitAbilities.weapon(s, 100, 4, melee, true).strength == 9, "Firestorm applies to melee attacks too")
	var edge: float = 9.0 + s.units[100].radius + s.units[400].radius
	for model: int in C.living(s, 4): s.units[model].position = Vector2(edge, 0)
	check(C.UnitAbilities.weapon(s, 100, 4, raw, false).strength == 5, "Exactly 9 inches between bases receives the unit bonus")
	for model: int in C.living(s, 4): s.units[model].position.x += 0.01
	check(C.UnitAbilities.weapon(s, 100, 4, raw, false).strength == 4, "Beyond 9 inches receives no bonus")
	s.units[101].position = Vector2(2, 0)
	check(C.UnitAbilities.weapon(s, 100, 4, raw, false).strength == 5, "A nearby squadmate enables the distant firing model's bonus")
	s.units[101].wounds = 0
	check(C.UnitAbilities.weapon(s, 100, 4, raw, false).strength == 4, "A destroyed nearby model cannot provide unit range")
	s = fixture()
	var declaration := [{"model": 100, "target": 4, "amount": 1, "weapon": "flamestorm-gauntlets", "profile": "ranged"}]
	var plan := C.AttackPlan.prepare(s, 1, false, declaration, true)
	check(plan.error.is_empty() and plan.batches[0].weapon.strength == 5 and plan.batches[0].context.attack_sources[0].bonus == 4, "Actual plan combines +1 S with Blast 2 against ten models")
	var result := C.resolve_attack_plan(s, 1, 100, declaration, s.revision, false, true, func() -> int: return 1)
	check(result.error.is_empty() and s.last_attack.pools[0].hits == 7 and s.last_attack.pools[0].wound_rolls.size() == 14, "Torrent gives seven hits and Twin-linked rerolls failed wound dice")
	s = fixture()
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	var option := choose(s, "aggressor-loadout", 1)
	check(not option.is_empty() and C.unit_action(s, 1, option, Vector2.ZERO, s.revision).is_empty(), "Whole-unit alternate loadout can be declared in preparation")
	for model: int in C.living(s, 1):
		check(s.units[model].ranged_weapons.size() == 2 and s.units[model].ranged_weapons[0].id == "auto-boltstorm-gauntlets" and s.units[model].ranged_weapons[1].id == "fragstorm-grenade-launcher", "Every Aggressor receives the complete alternate weapon package")
	check(s.units[300].ranged_weapons[0].id == "flamestorm-gauntlets", "A different Aggressor squad retains its chosen equipment")
	s = bytes_to_var(var_to_bytes(s))
	check(s.units[100].ranged_weapons[1].id == "fragstorm-grenade-launcher", "Declared loadout survives state serialization")
	s.phase = "shooting"
	s.unit_abilities.setup_players = [1, 2]
	var bolt := [{"model": 100, "target": 4, "amount": 1, "weapon": "auto-boltstorm-gauntlets", "profile": "standard"}]
	plan = C.AttackPlan.prepare(s, 1, false, bolt, true)
	check(plan.error.is_empty() and plan.batches[0].weapon.strength == 6 and s.squads[1].weapon.name == "Auto Boltstorm Gauntlets", "Alternate weapon package reaches the actual attack plan and squad display profile")
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	option = choose(s, "aggressor-loadout", 1)
	check(C.unit_action(s, 1, option, Vector2.ZERO, s.revision).is_empty() and s.units[100].ranged_weapons.size() == 1, "Preparation can restore Flamestorm as one weapon with two modes")
	s.phase = "shooting"
	s.unit_abilities.setup_players = [1, 2]
	check(choose(s, "aggressor-loadout", 1).is_empty(), "Loadout cannot be changed after preparation")
	for model: int in C.living(s, 4): s.units[model].position = Vector2(1, 0)
	check(4 not in C.AttackPlan.legal_targets(s, 100, false, "flamestorm-gauntlets", "ranged") and 4 in C.AttackPlan.legal_targets(s, 100, false, "flamestorm-gauntlets", "close_quarters"), "Flamestorm modes enforce Blast restrictions and Close-quarters eligibility against engaged targets")
	var invalid: Dictionary = lists()[1]
	invalid.entries.append({"definition_id": "40kdc:11e:adeptus-astartes:aggressor-squad", "models": 3, "copies": 1})
	check(not C.RosterValidation.admit(invalid).error.is_empty(), "3/6-model formations share the per-datasheet repetition cap")
	invalid = lists()[1]
	invalid.entries[1].models = 4
	check(not C.RosterValidation.admit(invalid).error.is_empty(), "Unimplemented intermediate composition is rejected")
	var catalog := F.P.Training.Capabilities.current_catalog_choice({"id": "openhammer:11e:Space%20Marines:129d-2da5-66f3-f4ec", "edition": "11e", "faction": "Space Marines"})
	check(catalog.options == [{"models": 3, "cost": 90}, {"models": 6, "cost": 180}], "List builder uses the current 3/6-model formations and prices")
	print("Aggressor checks: %d failures" % failures)
	quit(1 if failures else 0)
