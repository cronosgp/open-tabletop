extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const PublicUnitCommand = preload("res://tests/public_unit_command.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1
func squad(s: Dictionary, name: String) -> int:
	for model: int in s.units:
		if C.UnitAbilities.identity(s.units[model]) == name: return s.units[model].squad
	return -1
func selections() -> Dictionary:
	var lists := F.selections()
	for name in ["infernus-squad", "hellblaster-squad"]:
		lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": 5, "copies": 1})
	return lists
func fixture() -> Dictionary:
	var s := F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true, "manual_allocation": false}, selections())
	if s.has("error"): return s
	s.awakened_dynasty.pending = []
	s.unit_abilities.setup_players = [1, 2]
	s.unit_abilities.battle_players = [1, 2]
	s.deployment.complete = true
	s.mission.stage = "battle"
	s.phase = "shooting"
	s.turn = 3
	s.round = 2
	s.active = 1
	s.cp = {1: 3, 2: 3}
	s.unit_abilities.phase_key = C.UnitActions.key(s)
	s.unit_abilities.window = {}
	s.terrain.areas = []
	s.stratagems.attack_rerolls = false
	s.stratagems.hazard_rerolls = false
	for model: int in s.units:
		s.units[model].position = Vector2(-20, -15) if s.units[model].owner == 1 else Vector2(20, 15)
	for name in ["infernus-squad", "hellblaster-squad", "intercessor-squad"]:
		for model: int in C.living(s, squad(s, name)): s.units[model].position = Vector2.ZERO
	for name in ["necron-warriors", "immortals"]:
		for model: int in C.living(s, squad(s, name)): s.units[model].position = Vector2(7, 0)
	return s
func entries(s: Dictionary, source: int, target: int, weapon: String, profile: String = "standard") -> Array:
	var result: Array = []
	for model: int in C.living(s, source): result.append({"model": model, "target": target, "amount": 1, "weapon": weapon, "profile": profile})
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
	var s := fixture()
	check(not s.has("error"), "Current Infernus and Hellblaster profiles admit into checked construction")
	if s.has("error"):
		print(s)
		quit(1)
		return
	var infernus := squad(s, "infernus-squad")
	var hellblasters := squad(s, "hellblaster-squad")
	var target := squad(s, "necron-warriors")
	var other := squad(s, "immortals")
	var intercessors := squad(s, "intercessor-squad")
	check(s.training_points[1] == 825 and s.squads[infernus].training_cost == 95 and s.squads[hellblasters].training_cost == 115, "Current source costs enter actual prepared roster")
	check(s.units[infernus * 100].radius == 16.0 / 25.4 and s.units[hellblasters * 100].max_wounds == 2, "Current base and wounds materialize without historical pack")
	check(C.UnitActions.attachment_allowed(s, squad(s, "captain") * 100, infernus) and C.UnitActions.attachment_allowed(s, squad(s, "lieutenant") * 100, hellblasters), "Admitted Captain and Lieutenant pairings include both new units")
	var declared := entries(s, infernus, target, "pyreblaster")
	declared[0].target = other
	var plan := C.AttackPlan.prepare(s, infernus, false, declared, true)
	check(plan.error.is_empty() and plan.driven_from_cover and plan.batches[0].weapon.keywords.torrent and plan.batches[0].context.attack_sources[0].bonus == 1, "Pyreblaster has current fixed A, Torrent and parameterized Blast")
	var result := C.resolve_attack_plan(s, 1, infernus * 100, declared, s.revision, false, true, func() -> int: return 1)
	check(result.error.is_empty() and s.unit_abilities.window.get("kind", "") == "driven-from-cover", "Actual Torrent hits trigger target selection even with no successful wound")
	check(C.unit_choices(s, 1).size() == 2 and C.unit_choices(s, 2).is_empty(), "Only hit enemy units are eligible for the mandatory single mark")
	check(not C.advance_phase(s, 1, s.revision).is_empty(), "Finish Driven from Cover before phase advance")
	var selected: Dictionary = C.unit_choices(s, 1)[0]
	var marked: int = selected.target
	var decision := PendingDecisions.current(s, ["unit-actions"])
	var before_mark := var_to_bytes(s)
	var wrong_owner := submit_projected_choice(s, 2, selected)
	check(not str(wrong_owner.get("error", "")).is_empty() and var_to_bytes(s) == before_mark, "Opponent cannot choose the Driven from Cover mark")
	check(not decision.is_empty() and int(decision.get("priority_player_id", -1)) == 1 and decision.get("legal_options", []).size() == 2, "Driven from Cover projects the owner's exact hit-target choices")
	var mark_result := submit_projected_choice(s, 1, selected)
	check(str(mark_result.get("error", "")).is_empty(), "Owner selects one hit enemy through the normalized decision: " + str(mark_result.get("error", "")))
	var gun: Dictionary = Profiles.profile("intercessor-squad").ranged[0].profiles.saturation
	check(C.UnitAbilities.weapon(s, intercessors * 100, marked, gun, false).keywords.get("ignores-cover", false), "Friendly Marine ranged attacks ignore cover on the marked target")
	s.terrain.areas = [{"name": "Cover probe", "category": "exposed", "bounds": Rect2(5, -2, 4, 4), "features": []}]
	var unmarked := s.duplicate(true)
	unmarked.unit_abilities.cover_marks = {}
	var baseline_plan := C.AttackPlan.prepare(unmarked, intercessors, false, entries(unmarked, intercessors, marked, "bolt-rifle", "saturation"), true)
	var marked_plan := C.AttackPlan.prepare(s, intercessors, false, entries(s, intercessors, marked, "bolt-rifle", "saturation"), true)
	check(baseline_plan.error.is_empty() and baseline_plan.batches[0].context.benefit_of_cover and marked_plan.error.is_empty() and not marked_plan.batches[0].context.benefit_of_cover, "Resolved mark removes real cover from the subsequent attack plan")
	check(not C.UnitAbilities.weapon(s, intercessors * 100, target if marked == other else other, gun, false).keywords.get("ignores-cover", false), "Unselected hit enemy gains no mark")
	check(not C.UnitAbilities.weapon(s, target * 100, marked, gun, false).keywords.get("ignores-cover", false), "Enemy units cannot benefit from the mark")
	check(not C.UnitAbilities.weapon(s, intercessors * 100, marked, gun, true).keywords.get("ignores-cover", false), "Melee attacks do not gain the ranged-only effect")
	s = bytes_to_var(var_to_bytes(s))
	for model: int in C.living(s, infernus): s.units[model].wounds = 0
	check(C.UnitAbilities.ignores_cover_mark(s, intercessors, marked), "Resolved mark survives source loss and state serialization during the phase")
	s.phase = "charge"
	check(not C.UnitAbilities.ignores_cover_mark(s, intercessors, marked), "Mark expires after Shooting")
	s.phase = "shooting"
	s.turn += 2
	check(not C.UnitAbilities.ignores_cover_mark(s, intercessors, marked), "Mark cannot leak into a later Shooting phase")
	s = fixture()
	var probe := {"driven_from_cover": true}
	s.active = 2
	C.UnitAbilities.offer_cover_target(s, infernus, probe, {"pools": [{"target_squad": target, "hits": 2}]}, false)
	check(s.unit_abilities.window.is_empty(), "Out-of-phase opponent-turn shooting does not trigger Driven from Cover")
	s = fixture()
	C.UnitAbilities.offer_cover_target(s, infernus, probe, {"pools": [{"target_squad": target, "hits": 0}]}, false)
	check(s.unit_abilities.window.is_empty(), "Missing all shots creates no target window")
	s = fixture()
	s.manual_allocation = true
	result = C.resolve_attack_plan(s, 1, infernus * 100, entries(s, infernus, target, "pyreblaster"), s.revision, false, true, func() -> int: return 6)
	check(result.error.is_empty(), "Infernus also enters the defender-allocation attack path")
	if not s.pending_attack.is_empty(): check(s.unit_abilities.window.is_empty(), "Driven from Cover waits for all attack allocation choices")
	for step in range(80):
		if s.pending_attack.is_empty(): break
		var roll_window := C.Stratagems.pending(s)
		if not roll_window.is_empty():
			check(C.resolve_attack_reaction(s, roll_window.player, roll_window.squad, "", s.revision, -1, func() -> int: return 6).is_empty(), "Accept the pending attack dice before defender allocation")
			continue
		var recipients := C.Allocation.eligible(s)
		if recipients.is_empty():
			check(false, "Manual attack requires an eligible defender choice")
			break
		check(C.allocate_damage(s, 2, recipients[0], s.revision, func() -> int: return 6).is_empty(), "Defender allocation advances the Infernus shot")
	check(s.pending_attack.is_empty() and s.unit_abilities.window.get("kind", "") == "driven-from-cover", "Manual allocation completion opens exactly the post-shooting mark choice")
	s = fixture()
	var shots := entries(s, hellblasters, target, "plasma-incinerator", "supercharge")
	plan = C.AttackPlan.prepare(s, hellblasters, false, shots, true)
	check(plan.error.is_empty() and plan.hazardous_count == 5 and plan.hazard_modifiers == [1, 1, 1, 1, 1], "One modified Hazard roll per selected supercharged weapon")
	result = C.resolve_attack_plan(s, 1, hellblasters * 100, shots, s.revision, false, true, func() -> int: return 2)
	check(result.error.is_empty() and s.last_attack.hazardous.rolls == [2, 2, 2, 2, 2] and s.last_attack.hazardous.total == 0, "Actual Hellblaster shot turns raw Hazard 2s into successes")
	check(C.UnitAbilities.hazard_modifier(s, hellblasters, "unrelated-plasma") == 0, "No modifier for an unrelated hazardous weapon")
	check(C.Hazard.from_rolls(s, hellblasters, [1, 2], [1, 1]).total == 1, "Raw 1 still fails and raw 2 succeeds with +1")
	check(C.Hazard.from_rolls(s, hellblasters, [2]).total == 1, "Desperate Escape and other unmodified hazards retain their failure threshold")
	s = fixture()
	s.stratagems.hazard_rerolls = true
	result = C.resolve_attack_plan(s, 1, hellblasters * 100, shots, s.revision, false, true, func() -> int: return 1)
	check(result.error.is_empty() and not s.pending_hazard.is_empty(), "Supercharged Hazard failures expose existing Command Re-roll decision")
	check(C.resolve_hazard_reaction(s, 1, hellblasters, "command-re-roll", s.revision, 0, func() -> int: return 2).is_empty() and s.pending_hazard.remaining == 4, "Replacement raw 2 retains its weapon-specific +1 modifier")
	var lists := selections()
	# Replace all Marine entries with a Character and both permitted sizes.
	lists[1].entries = [{"definition_id": "40kdc:11e:adeptus-astartes:captain", "models": 1, "copies": 1}]
	for name in ["infernus-squad", "hellblaster-squad"]:
		for size in [5, 10]: lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:" + name, "models": size, "copies": 1})
	s = F.P.initial_state({"checked_rosters": true, "official_mission": true, "unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "core_stratagems": true}, lists)
	check(not s.has("error") and s.training_points[1] == 720, "Mixed 5/10-model formations retain separate composition and current price")
	if not s.has("error"):
		var found_ten := 0
		for id: int in s.squads:
			if s.squads[id].owner == 1 and s.squads[id].starting_strength == 10:
				found_ten += 1
				check(C.living(s, id).size() == 10 and s.squads[id].training_cost in [190, 230], "Ten-model squads keep the corresponding source price through materialization")
		check(found_ten == 2, "Both new units support ten models")
	lists[1].entries.append({"definition_id": "40kdc:11e:adeptus-astartes:infernus-squad", "models": 5, "copies": 1})
	check(not C.RosterValidation.admit(lists[1]).error.is_empty(), "Different squad sizes share the datasheet repetition limit")
	var alias := F.P.Training.Capabilities.resolve("Space Marines", "openhammer:11e:Space%20Marines:b007-fc7b-8e4a-b017")
	check(alias.error.is_empty() and alias.cost == 95 and alias.unit.stats.toughness == 5, "Builder discovery alias resolves to current rules and prices")
	var api := {"id": "openhammer:11e:Space%20Marines:b007-fc7b-8e4a-b017", "name": "Infernus Squad", "edition": "11e", "faction": "Space Marines", "role": "Infantry", "source_digest": "stale-api", "options": [{"models": 1, "cost": 85}, {"models": 6, "cost": 180}]}
	var approved := F.P.Training.Capabilities.current_catalog_choice(api)
	check(approved.options == [{"models": 5, "cost": 95}, {"models": 10, "cost": 190}] and api.options[0].models == 1, "Current builder choices replace stale API composition without modifying its catalog")
	s = fixture()
	s.phase = "deployment"
	s.unit_abilities.setup_players = []
	var pistol_choice: Dictionary = {}
	for option: Dictionary in C.unit_choices(s, 1):
		if option.action == "hellblaster-pistol": pistol_choice = option
	check(not pistol_choice.is_empty(), "Only the Hellblaster Sergeant receives the optional pistol declaration")
	if not pistol_choice.is_empty():
		var sergeant: int = pistol_choice.model
		check(PublicUnitCommand.error(s, 1, pistol_choice).is_empty(), "Plasma Pistol can replace the Sergeant's Bolt Pistol before battle through the public command")
		check(s.units[sergeant].ranged_weapons[1].id == "plasma-pistol" and s.units[sergeant + 1].ranged_weapons[1].id == "bolt-pistol", "Replacement affects exactly the Sergeant's sidearm")
		s.phase = "shooting"
		s.unit_abilities.setup_players = [1, 2]
		s.unit_abilities.phase_key = C.UnitActions.key(s)
		plan = C.AttackPlan.prepare(s, hellblasters, false, [{"model": sergeant, "target": target, "amount": 1, "weapon": "plasma-pistol", "profile": "supercharge"}], true)
		check(plan.error.is_empty() and plan.hazard_modifiers == [1], "Optional Plasma Pistol uses the same weapon-specific Hazard modifier")
		check(C.unit_choices(s, 1).all(func(option: Dictionary) -> bool: return option.action != "hellblaster-pistol"), "Equipment cannot be changed after setup")
	print("Marine fire support checks: %d failures" % failures)
	quit(1 if failures else 0)
