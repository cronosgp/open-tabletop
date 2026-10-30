extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
func roll_die() -> int: return 1
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func lists() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:aggressor-squad", "models": 3, "copies": 1},
		{"definition_id": "40kdc:11e:adeptus-astartes:aggressor-squad", "models": 6, "copies": 1}]
	return result
func fixture() -> Dictionary:
	var s := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists())
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
func submit_preparation_choice(s: Dictionary, player: int, selected: Dictionary, decision_id: String = "", option_id: String = "", roller: Callable = Callable()) -> Dictionary:
	var decision := PendingDecisions.current(s, ["unit-actions"])
	if decision.is_empty(): return {"error": "No current UnitActions preparation decision."}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)) and str(option.get("value", "")) == str(selected.get("value", "")):
			projected = option
			break
	if projected.is_empty(): return {"error": "The loadout is absent from the current UnitActions decision."}
	return MatchCommandService.execute(s, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": decision_id if not decision_id.is_empty() else str(decision.get("decision_id", "")), "option_id": option_id if not option_id.is_empty() else str(projected.get("id", "")), "choice": selected}, "revision": s.revision}, roller)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var s := fixture()
	check(not s.has("error"), "Both Aggressor formations admit with current rules")
	if s.has("error"):
		print(s)
		quit(1)
		return
	var aggressor_profile: Dictionary = Profiles.profile("aggressor-squad")
	check(aggressor_profile.source_datasheet_id == "000002099" and aggressor_profile.source_book_id == "000000139" and aggressor_profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 3, "wounds": 3, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0} and is_equal_approx(aggressor_profile.base_radius_inches, 20.0 / 25.4), "Aggressor characteristics and 40mm base match the identified source sheet")
	check(s.units[100].sergeant and s.units[101].get("sergeant", false) == false and aggressor_profile.keywords.has("GRAVIS") and aggressor_profile.keywords.has("INFANTRY") and not aggressor_profile.keywords.has("EXPLOSIVES"), "The Sergeant role, source unit keywords and absence of an invented EXPLOSIVES keyword are preserved")
	check(s.training_points[1] == 360 and C.living(s, 1).size() == 3 and C.living(s, 3).size() == 6, "3/6 formations retain separate 90/180 point costs")
	check(s.units[100].radius == 20.0 / 25.4 and s.units[100].wounds == 3 and s.squads[1].stats.toughness == 6, "Current Gravis stats and 40mm bases materialize")
	check(not C.UnitActions.attachment_allowed(s, 500, 1), "Regular Captain is not silently allowed to lead Gravis Aggressors")
	check(not C.CoreReactions.keyword(s, 1, "EXPLOSIVES"), "Fragstorm equipment does not invent an EXPLOSIVES keyword")
	var raw: Dictionary = Profiles.profile("aggressor-squad").ranged[0].profiles.ranged
	check(C.UnitAbilities.weapon(s, 100, 4, raw, false).strength == 5 and raw.strength == 4, "Close-quarters Firestorm adds Strength once without changing source data")
	var melee: Dictionary = Profiles.profile("aggressor-squad").melee[0].profiles.standard
	check(C.UnitAbilities.weapon(s, 100, 4, melee, true).strength == 9, "Firestorm applies to melee attacks too")
	var source_flamestorm: Dictionary = aggressor_profile.ranged[0].profiles
	check(source_flamestorm.ranged.range_inches == 12.0 and source_flamestorm.ranged.attacks == 3 and source_flamestorm.ranged.skill == 0 and source_flamestorm.ranged.strength == 4 and source_flamestorm.ranged.ap == -1 and source_flamestorm.ranged.damage == 1 and source_flamestorm.ranged.keywords.get("torrent", false) and source_flamestorm.ranged.keywords.get("twin-linked", false) and source_flamestorm.ranged.keywords.get("blast", 0) == 2, "Default Flamestorm ranged profile retains its exact source statistics and traits")
	check(source_flamestorm.close_quarters.range_inches == 12.0 and source_flamestorm.close_quarters.attacks == 3 and source_flamestorm.close_quarters.skill == 0 and source_flamestorm.close_quarters.strength == 4 and source_flamestorm.close_quarters.ap == -1 and source_flamestorm.close_quarters.damage == 1 and source_flamestorm.close_quarters.keywords.get("close-quarters", false) and source_flamestorm.close_quarters.keywords.get("torrent", false) and source_flamestorm.close_quarters.keywords.get("twin-linked", false) and not source_flamestorm.close_quarters.keywords.has("blast"), "Default Flamestorm Close-quarters profile retains its separate source traits")
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
	check(plan.error.is_empty() and plan.batches[0].weapon.range_inches == 12.0 and plan.batches[0].weapon.attacks == 7 and plan.batches[0].weapon.skill == 0 and plan.batches[0].weapon.strength == 5 and plan.batches[0].weapon.ap == -1 and plan.batches[0].weapon.damage == 1 and plan.batches[0].weapon.keywords.get("torrent", false) and plan.batches[0].weapon.keywords.get("twin-linked", false) and not plan.batches[0].weapon.keywords.has("blast") and plan.batches[0].context.attack_sources[0].expression == 3 and plan.batches[0].context.attack_sources[0].bonus == 4, "Ranged AttackPlan expands Blast 2 against ten models and preserves Flamestorm statistics and Firestorm Strength")
	var close_battle := fixture()
	close_battle.units[400].position = Vector2(1.75, 0)
	var close_declaration := [{"model": 100, "target": 4, "amount": 1, "weapon": "flamestorm-gauntlets", "profile": "close_quarters"}]
	var close_plan := C.AttackPlan.prepare(close_battle, 1, false, close_declaration, true)
	check(close_plan.error.is_empty() and 4 in C.AttackPlan.legal_targets(close_battle, 100, false, "flamestorm-gauntlets", "close_quarters") and close_plan.batches[0].weapon.range_inches == 12.0 and close_plan.batches[0].weapon.attacks == 3 and close_plan.batches[0].weapon.strength == 5 and close_plan.batches[0].weapon.ap == -1 and close_plan.batches[0].weapon.damage == 1 and close_plan.batches[0].weapon.keywords.get("torrent", false) and close_plan.batches[0].weapon.keywords.get("twin-linked", false) and not close_plan.batches[0].weapon.keywords.has("blast"), "Close-quarters Flamestorm mode remains selectable while engaged and reaches AttackPlan with no Blast (%s)" % str(close_plan))
	var melee_battle := fixture()
	melee_battle.phase = "fight"
	melee_battle.units[400].position = Vector2(1.75, 0)
	var melee_entries := C.AttackPlan.single_target(melee_battle, 1, 4, true)
	var melee_plan := C.AttackPlan.prepare(melee_battle, 1, true, melee_entries, true)
	check(melee_plan.error.is_empty() and melee_plan.batches.size() == 1 and melee_plan.batches[0].count == 9 and melee_plan.batches[0].weapon.attacks == 9 and melee_plan.batches[0].weapon.skill == 3 and melee_plan.batches[0].weapon.strength == 9 and melee_plan.batches[0].weapon.ap == -2 and melee_plan.batches[0].weapon.damage == 2 and melee_plan.batches[0].weapon.keywords.get("twin-linked", false) and melee_plan.batches[0].context.attack_sources.size() == 3, "Three Aggressors resolve nine Twin Power Fist attacks through Fight AttackPlan with exact traits and Firestorm Strength")
	var result := C.resolve_attack_plan(s, 1, 100, declaration, s.revision, false, true, func() -> int: return 1)
	if result.get("error", "").is_empty() and not s.has("last_attack"):
		var defensive_pass: Dictionary = {}
		for candidate: Dictionary in C.unit_choices(s, 2):
			if candidate.action == "armour-pass" and candidate.target == 4: defensive_pass = candidate
		result = submit_preparation_choice(s, 2, defensive_pass, "", "", roll_die) if not defensive_pass.is_empty() else {"error": "missing defender Armour of Contempt pass"}
	check(result.get("error", "").is_empty(), "Aggressor attack resolves through the current-catalog fixture: %s" % str(result.get("error", "")))
	if result.get("error", "").is_empty() and s.has("last_attack"): check(s.last_attack.pools[0].hits == 7 and s.last_attack.pools[0].wound_rolls.size() == 14, "Torrent gives seven hits and Twin-linked rerolls failed wound dice")
	else: check(false, "Attack resolution completes without a reaction window or missing attack record")
	s = fixture()
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	var option := choose(s, "aggressor-loadout", 1)
	var loadout_decision := PendingDecisions.current(s, ["unit-actions"])
	var projected_loadout: Dictionary = loadout_decision.get("legal_options", []).filter(func(candidate: Dictionary) -> bool: return str(candidate.get("action", "")) == "aggressor-loadout" and int(candidate.get("target", -1)) == 1)[0]
	var before_loadout := var_to_bytes(s)
	var wrong_owner_loadout := submit_preparation_choice(s, 2, option)
	var stale_loadout := submit_preparation_choice(s, 1, option, str(loadout_decision.decision_id), "stale-option")
	check(not wrong_owner_loadout.get("error", "").is_empty() and not stale_loadout.get("error", "").is_empty() and before_loadout == var_to_bytes(s), "Wrong-owner and stale loadout options are rejected without mutation")
	var accepted_loadout := submit_preparation_choice(s, 1, option, str(loadout_decision.decision_id), str(projected_loadout.id))
	check(not option.is_empty() and accepted_loadout.get("error", "").is_empty(), "Whole-unit alternate loadout uses the public preparation command")
	for model: int in C.living(s, 1):
		check(s.units[model].ranged_weapons.size() == 2 and s.units[model].ranged_weapons[0].id == "auto-boltstorm-gauntlets" and s.units[model].ranged_weapons[1].id == "fragstorm-grenade-launcher", "Every Aggressor receives the complete alternate weapon package")
	check(s.units[300].ranged_weapons[0].id == "flamestorm-gauntlets", "A different Aggressor squad retains its chosen equipment")
	s = bytes_to_var(var_to_bytes(s))
	check(s.units[100].ranged_weapons[1].id == "fragstorm-grenade-launcher", "Declared loadout survives state serialization")
	s.phase = "shooting"
	s.unit_abilities.setup_players = [1, 2]
	var bolt := [{"model": 100, "target": 4, "amount": 1, "weapon": "auto-boltstorm-gauntlets", "profile": "standard"}]
	plan = C.AttackPlan.prepare(s, 1, false, bolt, true)
	check(plan.error.is_empty() and plan.batches[0].weapon.range_inches == 18.0 and plan.batches[0].weapon.attacks == 3 and plan.batches[0].weapon.skill == 3 and plan.batches[0].weapon.strength == 6 and plan.batches[0].weapon.ap == -1 and plan.batches[0].weapon.damage == 1 and plan.batches[0].weapon.keywords.get("twin-linked", false) and s.squads[1].weapon.name == "Auto Boltstorm Gauntlets", "Auto Boltstorm Gauntlets preserve all ranged characteristics and Twin-linked after the Firestorm Strength bonus")
	var fragstorm := [{"model": 100, "target": 4, "amount": 1, "weapon": "fragstorm-grenade-launcher", "profile": "standard"}]
	plan = C.AttackPlan.prepare(s, 1, false, fragstorm, true)
	check(plan.error.is_empty() and plan.batches[0].weapon.range_inches == 18.0 and plan.batches[0].weapon.attacks == 5 and plan.batches[0].weapon.skill == 3 and plan.batches[0].weapon.strength == 5 and plan.batches[0].weapon.ap == -1 and plan.batches[0].weapon.damage == 1 and not plan.batches[0].weapon.keywords.has("blast") and plan.batches[0].context.attack_sources[0].expression == 3 and plan.batches[0].context.attack_sources[0].bonus == 2, "Fragstorm Grenade Launcher expands Blast 1 against the ten-model target and retains its other source characteristics")
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	option = choose(s, "aggressor-loadout", 1)
	var restored_loadout := submit_preparation_choice(s, 1, option)
	check(restored_loadout.get("error", "").is_empty() and s.units[100].ranged_weapons.size() == 1, "Public preparation command can restore Flamestorm as one weapon with two modes")
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
