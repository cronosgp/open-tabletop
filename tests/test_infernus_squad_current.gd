extends SceneTree

const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Equipment = preload("res://scripts/edition_11/equipment.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const LeaderLinks = preload("res://scripts/edition_11/marine_leader_links.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const INFERNUS_ID := "40kdc:11e:adeptus-astartes:infernus-squad"
const CAPTAIN_ID := "40kdc:11e:adeptus-astartes:captain"
const INTERCESSOR_ID := "40kdc:11e:adeptus-astartes:intercessor-squad"
const WEAPONS := {
	"pyreblaster": {"melee": false, "range_inches": 12.0, "attacks": 3, "skill": 0, "strength": 5, "ap": -1, "damage": 1, "keywords": {"torrent": true, "blast": 1}},
	"bolt-pistol": {"melee": false, "range_inches": 12.0, "attacks": 1, "skill": 3, "strength": 5, "ap": -1, "damage": 1, "keywords": {"close-quarters": true}},
	"ceramite-fists": {"melee": true, "range_inches": 0.0, "attacks": 3, "skill": 3, "strength": 5, "ap": 0, "damage": 1, "keywords": {}}
}

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func selections() -> Dictionary:
	var result := F.current_marine_selections()
	result[1].entries = [
		{"definition_id": CAPTAIN_ID, "models": 1, "copies": 1},
		{"definition_id": INFERNUS_ID, "models": 5, "copies": 1},
		{"definition_id": INFERNUS_ID, "models": 10, "copies": 1},
		{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1}]
	result[2].entries = [
		{"definition_id": CAPTAIN_ID, "models": 1, "copies": 1},
		{"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1},
		{"definition_id": INTERCESSOR_ID, "models": 10, "copies": 1}]
	return result

func find_squad(state: Dictionary, owner: int, identity: String, strength: int = -1) -> int:
	for model: int in state.units:
		var unit: Dictionary = state.units[model]
		if int(unit.get("owner", -1)) != owner or C.UnitAbilities.identity(unit) != identity: continue
		var squad := int(unit.get("squad", -1))
		if strength >= 0 and int(state.squads[squad].get("starting_strength", -1)) != strength: continue
		return squad
	return -1

func fixture() -> Dictionary:
	var state := F.P.initial_state({"unit_abilities": true, "combat_doctrines": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, selections())
	if state.has("error"): return state
	state.mission.stage = "battle"
	state.deployment.complete = true
	state.phase = "shooting"
	state.turn = 3
	state.round = 2
	state.active = 1
	state.cp = {1: 3, 2: 3}
	state.unit_abilities.setup_players = [1, 2]
	state.unit_abilities.battle_players = [1, 2]
	state.unit_abilities.phase_key = C.UnitActions.key(state)
	state.unit_abilities.window = {}
	state.terrain.areas = []
	for model: int in state.units:
		state.units[model].position = Vector2(-18, 16) if state.units[model].owner == 1 else Vector2(18, 16)
	for identity in ["infernus-squad", "intercessor-squad"]:
		for model: int in C.living(state, find_squad(state, 1, identity, 5)):
			state.units[model].position = Vector2.ZERO
	for model: int in C.living(state, find_squad(state, 2, "intercessor-squad", 5)):
		state.units[model].position = Vector2(7, 0)
	for model: int in C.living(state, find_squad(state, 2, "intercessor-squad", 10)):
		state.units[model].position = Vector2(10, 0)
	return state

func check_weapon_profile(state: Dictionary, squad: int, model: int, target: int, weapon: String) -> void:
	var expected: Dictionary = WEAPONS[weapon]
	var selected := Equipment.select(state, model, bool(expected.melee), weapon, "standard")
	check(str(selected.get("error", "")).is_empty(), "%s is selectable through Equipment" % weapon)
	if not str(selected.get("error", "")).is_empty(): return
	for field: String in ["range_inches", "attacks", "skill", "strength", "ap", "damage"]:
		check(selected.stats.get(field) == expected[field], "%s %s matches the verified source" % [weapon, field])
	check(selected.stats.get("keywords", {}) == expected.keywords, "%s preserves every source weapon trait" % weapon)
	var old_phase: String = str(state.phase)
	var old_active: int = int(state.active)
	var attackers: Array[int] = C.living(state, squad)
	var targets: Array[int] = C.living(state, target)
	var old_positions := {}
	for member: int in attackers + targets: old_positions[member] = state.units[member].position
	for index in range(attackers.size()): state.units[attackers[index]].position = Vector2.ZERO if attackers[index] == model else Vector2(-10, 4 + index * 3)
	for index in range(targets.size()): state.units[targets[index]].position = Vector2(1, 0) if bool(expected.melee) and index == 0 else Vector2(4, 0) if index == 0 else Vector2(10, 4 + index * 3)
	state.phase = "fight" if bool(expected.melee) else "shooting"
	state.active = int(state.squads[squad].owner)
	var amount := int(selected.stats.attacks) if bool(expected.melee) else 1
	var plan: Dictionary = C.AttackPlan.prepare(state, squad, bool(expected.melee), [{"model": model, "target": target, "amount": amount, "weapon": weapon, "profile": "standard"}], true)
	state.phase = old_phase
	state.active = old_active
	for member: int in old_positions: state.units[member].position = old_positions[member]
	check(str(plan.get("error", "")).is_empty() and plan.get("batches", []).size() == 1, "%s routes through AttackPlan: %s" % [weapon, plan.get("error", "")])
	if plan.get("error", "").is_empty() and plan.get("batches", []).size() == 1:
		var sources: Array = plan.batches[0].context.get("attack_sources", [])
		check(not sources.is_empty() and str(sources[0].get("weapon", "")) == weapon, "AttackPlan retains %s as its weapon source" % weapon)

func submit_projected_choice(state: Dictionary, player: int, selected: Dictionary) -> Dictionary:
	var decision := PendingDecisions.current(state, ["unit-actions"])
	if decision.is_empty() or int(decision.get("priority_player_id", -1)) != player: return {"error": "No UnitActions decision belongs to Player %d." % player}
	var projected: Dictionary = {}
	for option: Dictionary in decision.get("legal_options", []):
		if str(option.get("action", "")) == str(selected.get("action", "")) and int(option.get("model", -1)) == int(selected.get("model", -1)) and int(option.get("target", -1)) == int(selected.get("target", -1)):
			projected = option
			break
	if projected.is_empty(): return {"error": "Selected choice is not in the current projection."}
	return MatchCommandService.execute(state, player, {"kind": MatchCommandService.SELECT_UNIT_CHOICE, "revision": int(state.get("revision", -1)), "choice": {"_decision_type": MatchCommandService.UNIT_CHOICE_ENVELOPE, "decision_id": str(decision.get("decision_id", "")), "option_id": str(projected.get("id", "")), "choice": selected}}, func() -> int: return 6)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile: Dictionary = Profiles.profile("infernus-squad")
	check(profile.get("source_book_id") == "000000139" and profile.get("source_datasheet_id") == "000000126" and profile.get("source_export_updated_at") == "2026-10-16T21:03:46+03:00", "Profile maps to the verified shared-book source identity and retains its source stamp")
	check(profile.get("points_by_models", {}) == {5: 95, 10: 190} and profile.get("third_plus_points_by_models", {}) == {5: 105, 10: 200} and profile.get("models") == 5 and is_equal_approx(profile.get("base_radius_inches", 0.0), 16.0 / 25.4), "Both compositions, cost tiers and 32mm bases match the local export")
	check(profile.get("stats", {}) == {"movement_inches": 6, "toughness": 5, "save_target": 3, "wounds": 2, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 0}, "Characteristics match the source datasheet")
	var keywords: Array = profile.get("keywords", []).duplicate()
	keywords.sort()
	check(keywords == ["ADEPTUS ASTARTES", "EXPLOSIVES", "IMPERIUM", "INFANTRY", "TACTICUS"], "All source keywords are preserved")
	check(profile.get("ranged", []).size() == 2 and profile.ranged[0].id == "pyreblaster" and profile.ranged[1].id == "bolt-pistol" and profile.get("melee", []).size() == 1 and profile.melee[0].id == "ceramite-fists", "Every model's Pyreblaster, Bolt Pistol and Ceramite Fists are fixed loadout")
	var catalog := Catalog.current_catalog_choice({"id": INFERNUS_ID, "edition": "11e", "faction": "Space Marines"})
	check(catalog.get("options", []) == [{"models": 5, "cost": 95, "third_plus_cost": 105}, {"models": 10, "cost": 190, "third_plus_cost": 200}], "Current construction exposes only the sourced unit sizes and costs")
	check(Roster.POINTS["infernus-squad"].get("sizes", {}) == {5: 95, 10: 190} and Roster.POINTS["infernus-squad"].get("third_plus_sizes", {}) == {5: 105, 10: 200}, "Roster pricing retains both source cost tiers")
	check(Catalog.SPECS.get("infernus-squad", {}).get("current_reference", false) and Catalog.SPECS.get("infernus-squad", {}).get("validation_status", "") == "tests_passed_local_targeted", "Infernus remains admitted with targeted validation metadata")
	check("infernus-squad" in LeaderLinks.TARGETS["captain"] and "infernus-squad" in LeaderLinks.TARGETS["lieutenant"], "The local Leader map includes the source-listed Captain and Lieutenant links")

	var state := fixture()
	check(not state.has("error"), "Both players materialize from the current Marine catalog")
	if state.has("error"):
		print("Current Infernus checks: %d failures" % (failures + 1))
		quit(1)
		return
	var small := find_squad(state, 1, "infernus-squad", 5)
	var large := find_squad(state, 1, "infernus-squad", 10)
	var friendly := find_squad(state, 1, "intercessor-squad", 5)
	var target := find_squad(state, 2, "intercessor-squad", 5)
	var other_target := find_squad(state, 2, "intercessor-squad", 10)
	check(small > 0 and large > 0 and friendly > 0 and target > 0 and other_target > 0, "Both player catalogs include the intended unit sizes and target profiles")
	if small < 0 or large < 0 or friendly < 0 or target < 0 or other_target < 0:
		print("Current Infernus checks: %d failures" % (failures + 1))
		quit(1)
		return
	check(state.squads[small].training_cost == 95 and state.squads[large].training_cost == 190 and C.living(state, small).size() == 5 and C.living(state, large).size() == 10, "Materialized squads retain the two source compositions and first-two prices")
	check(state.units[C.living(state, small)[0]].radius == 16.0 / 25.4 and state.units[C.living(state, large)[0]].max_wounds == 2, "Both model groups retain their source base and wound characteristics")
	var small_model: int = C.living(state, small)[0]
	check_weapon_profile(state, small, small_model, target, "pyreblaster")
	check_weapon_profile(state, small, small_model, target, "bolt-pistol")
	check_weapon_profile(state, small, small_model, target, "ceramite-fists")
	check(C.UnitAbilities.has(state, small, "driven-from-cover"), "Current-catalog Infernus materialization carries Driven from Cover")
	var roster := {"schema_version": 2, "faction": "Space Marines", "category": "incursion", "points_limit": 1000, "entries": [{"definition_id": CAPTAIN_ID, "models": 1, "copies": 1}, {"definition_id": INFERNUS_ID, "models": 5, "copies": 1}, {"definition_id": INFERNUS_ID, "models": 10, "copies": 1}, {"definition_id": INTERCESSOR_ID, "models": 5, "copies": 1}]}
	var admitted := C.RosterValidation.admit(roster)
	check(admitted.get("error", "").is_empty() and admitted.get("total", -1) == 460, "Current checked-roster admission accepts the two source sizes and prices: " + str(admitted.get("error", "")) + " total=" + str(admitted.get("total", -1)))
	var third_copy := roster.duplicate(true)
	third_copy.entries.append({"definition_id": INFERNUS_ID, "models": 5, "copies": 1})
	check(not C.RosterValidation.admit(third_copy).get("error", "").is_empty(), "The current checked Incursion roster rejects a third Infernus copy")

	var pyreblaster := [
		{"model": small_model, "target": other_target, "amount": 1, "weapon": "pyreblaster", "profile": "standard"},
		{"model": C.living(state, small)[1], "target": target, "amount": 1, "weapon": "pyreblaster", "profile": "standard"}]
	var prepared := C.AttackPlan.prepare(state, small, false, pyreblaster, true)
	check(prepared.get("error", "").is_empty() and prepared.get("driven_from_cover", false), "Actual Infernus attacks prepare the post-shot Driven from Cover trigger")
	var result := C.resolve_attack_plan(state, 1, small_model, pyreblaster, state.revision, false, true, func() -> int: return 1)
	check(result.get("error", "").is_empty() and state.unit_abilities.window.get("kind", "") == "driven-from-cover", "Shooting opens the mandatory post-shot target choice after Torrent hits")
	var choices: Array = C.unit_choices(state, 1)
	check(choices.size() == 2 and C.unit_choices(state, 2).is_empty(), "Only enemy units hit by the attack are selectable, and the owner gets the choice")
	var selected: Dictionary = {}
	for option: Dictionary in choices:
		if int(option.get("target", -1)) == target:
			selected = option
			break
	check(not selected.is_empty(), "Both hit targets appear in the projected decision")
	var before_choice := var_to_bytes(state)
	var opponent_choice := submit_projected_choice(state, 2, selected)
	check(not str(opponent_choice.get("error", "")).is_empty() and before_choice == var_to_bytes(state), "Opponent cannot submit the Infernus player's target choice")
	var mark := submit_projected_choice(state, 1, selected)
	check(str(mark.get("error", "")).is_empty(), "Owner selects one hit target through MatchCommandService: " + str(mark.get("error", "")))
	var marked_target := int(selected.get("target", -1))
	var saturation: Dictionary = Profiles.profile("intercessor-squad").ranged[0].profiles.saturation
	var friendly_model: int = C.living(state, friendly)[0]
	var enemy_model: int = C.living(state, target)[0]
	check(C.UnitAbilities.weapon(state, friendly_model, marked_target, saturation, false).keywords.get("ignores-cover", false), "Friendly Adeptus Astartes ranged attacks ignore the marked target's cover")
	check(not C.UnitAbilities.weapon(state, friendly_model, target if marked_target == other_target else other_target, saturation, false).keywords.get("ignores-cover", false), "Unselected hit target does not receive the effect")
	check(not C.UnitAbilities.weapon(state, enemy_model, marked_target, saturation, false).keywords.get("ignores-cover", false) and not C.UnitAbilities.weapon(state, friendly_model, marked_target, saturation, true).keywords.get("ignores-cover", false), "Enemy attacks and friendly melee attacks do not gain Ignores Cover")
	state.terrain.areas = [{"name": "Cover probe", "category": "exposed", "bounds": Rect2(5, -2, 4, 4), "features": []}]
	var unmarked := state.duplicate(true)
	unmarked.unit_abilities.cover_marks = {}
	var baseline_plan := C.AttackPlan.prepare(unmarked, friendly, false, [{"model": friendly_model, "target": marked_target, "amount": 1, "weapon": "bolt-rifle", "profile": "saturation"}], true)
	var marked_plan := C.AttackPlan.prepare(state, friendly, false, [{"model": friendly_model, "target": marked_target, "amount": 1, "weapon": "bolt-rifle", "profile": "saturation"}], true)
	check(baseline_plan.get("error", "").is_empty() and baseline_plan.batches[0].context.benefit_of_cover and marked_plan.get("error", "").is_empty() and not marked_plan.batches[0].context.benefit_of_cover, "The selected mark removes the real cover benefit in AttackPlan")
	state = bytes_to_var(var_to_bytes(state))
	for model: int in C.living(state, small): state.units[model].wounds = 0
	check(C.UnitAbilities.ignores_cover_mark(state, friendly, marked_target), "The mark persists through source loss and save/load for the current phase")
	state.phase = "charge"
	check(not C.UnitAbilities.ignores_cover_mark(state, friendly, marked_target), "The mark expires when the Shooting phase ends")
	var probe := {"driven_from_cover": true}
	state = fixture()
	state.active = 2
	small = find_squad(state, 1, "infernus-squad", 5)
	target = find_squad(state, 2, "intercessor-squad", 5)
	C.UnitAbilities.offer_cover_target(state, small, probe, {"pools": [{"target_squad": target, "hits": 2}]}, false)
	check(state.unit_abilities.window.is_empty(), "Out-of-phase opponent-turn shooting cannot trigger Driven from Cover")
	state = fixture()
	small = find_squad(state, 1, "infernus-squad", 5)
	target = find_squad(state, 2, "intercessor-squad", 5)
	C.UnitAbilities.offer_cover_target(state, small, probe, {"pools": [{"target_squad": target, "hits": 0}]}, false)
	check(state.unit_abilities.window.is_empty(), "No hits create no post-shot target choice")
	print("Current Infernus Squad checks: %d failures" % failures)
	quit(1 if failures else 0)
