extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Defenders = preload("res://scripts/edition_11/defender_groups.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
const MatchCommandService = preload("res://scripts/edition_11/match_command_service.gd")
const PendingDecisions = preload("res://scripts/edition_11/pending_decision_registry.gd")
const DatasheetChecks = preload("res://tests/space_marine_datasheet_checks.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures += 1

func entry(faction: String, identity: String, count: int) -> Dictionary:
	return {"definition_id": "40kdc:11e:%s:%s" % [faction, identity], "models": count, "copies": 1}

func find_squad(state: Dictionary, owner: int, identity: String) -> int:
	for squad: int in state.squads:
		if state.squads[squad].owner != owner: continue
		var members: Array[int] = Geometry.alive(state, squad)
		if not members.is_empty() and C.UnitAbilities.identity(state.units[members[0]]) == identity: return squad
	return -1

func find_model(state: Dictionary, owner: int, identity: String) -> int:
	for model: int in state.units:
		if state.units[model].owner == owner and C.UnitAbilities.identity(state.units[model]) == identity: return model
	return -1

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
	var profile := Profiles.profile("darnath-lysander")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002105" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Darnath Lysander profile uses the local shared-book Wahapedia export")
	check(profile.points == 160 and profile.points_by_models == {1: 160} and profile.max_supported_copies == 1 and profile.models == 1 and is_equal_approx(profile.base_radius_inches, 25.0 / 25.4) and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 7, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "One-model price, copy cap, 50 mm base and characteristics match the source")
	check(profile.keywords == ["INFANTRY", "TERMINATOR", "EPIC HERO", "CHARACTER", "CAPTAIN", "IMPERIUM", "ADEPTUS ASTARTES", "IMPERIAL FISTS"] and profile.get("additional_weapon_profiles", {}).is_empty(), "All eight source keywords are present and no equipment-option rows are exposed")
	check(profile.ranged.is_empty() and profile.melee[0].id == "fist-of-dorn" and profile.melee[0].profiles.standard == {"name": "Fist of Dorn", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 10, "ap": -3, "damage": 3, "keywords": {"devastating-wounds": true, "cleave": 1}}, "Fist of Dorn preserves Devastating Wounds and Cleave 1")
	check(Catalog.SPECS.get("darnath-lysander", {}).get("current_reference", false) and Roster.POINTS.get("darnath-lysander", {}).get("sizes", {}) == {1: 160}, "The local catalog admits one 160-point model")
	var catalog_choice := Catalog.current_catalog_choice({"id": "40kdc:11e:adeptus-astartes:darnath-lysander", "edition": "11e", "faction": "Space Marines"})
	check(not catalog_choice.is_empty(), "Darnath resolves through the consolidated local construction catalog")

	var lists := F.current_marine_selections()
	lists[1].entries = [entry("adeptus-astartes", "darnath-lysander", 1), entry("adeptus-astartes", "terminator-squad", 5), entry("adeptus-astartes", "terminator-assault-squad", 5), entry("adeptus-astartes", "intercessor-squad", 5)]
	lists[2].entries = [entry("adeptus-astartes", "assault-intercessor-squad", 5)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Darnath and the source-listed units materialize")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var lysander := find_model(state, 1, "darnath-lysander")
	var lysander_squad := find_squad(state, 1, "darnath-lysander")
	var enemy := find_squad(state, 2, "assault-intercessor-squad")
	check(C.UnitAbilities.has(state, lysander_squad, "deep-strike") and C.UnitAbilities.has(state, lysander_squad, "leader") and C.UnitAbilities.has(state, lysander_squad, "combat-doctrines") and C.UnitAbilities.has(state, lysander_squad, "transhuman-strategist") and C.UnitAbilities.has(state, lysander_squad, "rampart") and C.UnitAbilities.has(state, lysander_squad, "icon-of-obstinacy"), "All source-listed Core, Army and datasheet abilities register")
	for failure: String in DatasheetChecks.fixed_weapon_plan_failures(state, profile, lysander, enemy):
		check(false, "Fist of Dorn source plan: " + failure)
	check(C.UnitActions.attachment_allowed(state, lysander, find_squad(state, 1, "terminator-squad")), "Darnath can lead a Terminator Squad")
	check(C.UnitActions.attachment_allowed(state, lysander, find_squad(state, 1, "terminator-assault-squad")), "Darnath can lead a Terminator Assault Squad")
	check(not C.UnitActions.attachment_allowed(state, lysander, find_squad(state, 1, "intercessor-squad")), "Darnath cannot lead an unlisted unit")

	state.phase = "deployment"
	state.active = 1
	state.unit_abilities.setup_players = [2]
	state.awakened_dynasty.pending = []
	var setup := C.UnitActions.choices(state, 1)
	var warlord_available := false
	for option: Dictionary in setup:
		if option.action == "warlord" and option.model == lysander: warlord_available = true
	check(warlord_available, "Darnath is eligible to be selected as Warlord")
	state.unit_abilities.warlords = {1: lysander}
	state.cp[1] = 0
	state.round = 1
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants its Warlord CP")
	C.UnitActions.start_round(state)
	check(state.cp[1] == 1, "Transhuman Strategist grants the Warlord CP only once per round")

	state.phase = "movement"
	state.active = 1
	state.unit_abilities.phase_key = ""
	state.unit_abilities.window = {}
	C.UnitActions.reconcile(state)
	var choices := C.UnitActions.choices(state, 1)
	var rampart_choice: Dictionary = {}
	for option: Dictionary in choices:
		if option.action == "rampart" and option.model == lysander: rampart_choice = option
	check(not rampart_choice.is_empty() and state.unit_abilities.window.kind == "start", "Rampart is offered at the start of a non-Shooting phase")
	var before_rampart := var_to_bytes(state)
	var wrong_rampart := submit_projected_choice(state, 2, rampart_choice)
	check(not str(wrong_rampart.get("error", "")).is_empty() and var_to_bytes(state) == before_rampart, "Opponent cannot activate Rampart")
	var rampart_result := submit_projected_choice(state, 1, rampart_choice)
	check(str(rampart_result.get("error", "")).is_empty(), "Rampart can be activated through the normalized phase-start decision: " + str(rampart_result.get("error", "")))
	check(C.UnitAbilities.rampart_active(state, lysander) and Defenders.profile(state, lysander).invulnerable_target == 2, "Rampart gives Darnath a 2+ invulnerable save for the current phase")
	choices = C.UnitActions.choices(state, 1)
	check(not choices.any(func(option: Dictionary) -> bool: return option.action == "rampart"), "Rampart is spent for the battle and cannot be activated twice")
	check(C.UnitAbilities.hit_bonus(state, enemy, lysander_squad, false) == -1 and C.UnitAbilities.hit_bonus(state, enemy, lysander_squad, true) == -1, "Icon of Obstinacy subtracts 1 from shooting and melee hit rolls against his unit")
	state.phase = "shooting"
	state.active = 2
	state.terrain.areas = []
	state.units[lysander].position = Vector2.ZERO
	var warrior_squad := find_squad(state, 2, "assault-intercessor-squad")
	var warrior := Geometry.alive(state, warrior_squad)[0]
	state.units[warrior].position = Vector2(10, 0)
	var warrior_weapon: String = state.units[warrior].ranged_weapons[0].id
	var incoming := AttackPlan.prepare(state, warrior_squad, false, [{"model": warrior, "target": lysander_squad, "weapon": warrior_weapon, "profile": "standard", "amount": 1}], false)
	check(incoming.error.is_empty() and incoming.batches.size() == 1 and int(incoming.batches[0].context.hit_modifier) == -1, "Icon of Obstinacy is included in the declared ranged attack context")
	state.phase = "fight"
	check(not C.UnitAbilities.rampart_active(state, lysander) and Defenders.profile(state, lysander).invulnerable_target == 4, "Rampart ends at the phase boundary and the base invulnerable save returns")

	print("Darnath Lysander local checks: %d failures" % failures)
	quit(1 if failures else 0)
