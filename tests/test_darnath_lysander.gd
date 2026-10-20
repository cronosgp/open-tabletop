extends SceneTree
const F = preload("res://tests/all_units_fixture.gd")
const C = F.C
const Profiles = preload("res://scripts/edition_11/current_reference_marine_profiles.gd")
const Catalog = preload("res://scripts/edition_11/army_capabilities.gd")
const Roster = preload("res://scripts/edition_11/roster_validation.gd")
const Geometry = preload("res://scripts/edition_11/contact_movement.gd")
const Defenders = preload("res://scripts/edition_11/defender_groups.gd")
const AttackPlan = preload("res://scripts/edition_11/attack_plan.gd")
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

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var profile := Profiles.profile("darnath-lysander")
	check(profile.source_book_id == "000000139" and profile.source_datasheet_id == "000002105" and profile.source_export_updated_at == "2026-10-16T21:03:46+03:00", "Darnath Lysander profile uses the local shared-book Wahapedia export")
	check(profile.points == 160 and profile.models == 1 and profile.stats == {"movement_inches": 5, "toughness": 6, "save_target": 2, "wounds": 7, "leadership_target": 6, "objective_control": 1, "invulnerable_target": 4}, "Characteristics and cost match the source row")
	check(profile.ranged.is_empty() and profile.melee[0].id == "fist-of-dorn" and profile.melee[0].profiles.standard == {"name": "Fist of Dorn", "range_inches": 0.0, "attacks": 5, "skill": 2, "strength": 10, "ap": -3, "damage": 3, "keywords": {"devastating-wounds": true, "cleave": 1}}, "Fist of Dorn preserves Devastating Wounds and Cleave 1")
	check(Catalog.SPECS.get("darnath-lysander", {}).get("current_reference", false) and Roster.POINTS.get("darnath-lysander", {}).get("sizes", {}) == {1: 160}, "The local catalog admits one 160-point model")

	var lists := F.selections()
	lists[1].entries = [entry("adeptus-astartes", "darnath-lysander", 1), entry("adeptus-astartes", "terminator-squad", 5), entry("adeptus-astartes", "terminator-assault-squad", 5), entry("adeptus-astartes", "intercessor-squad", 5)]
	lists[2].entries = [entry("necrons", "immortals", 5), entry("necrons", "necron-warriors", 10)]
	var state: Dictionary = F.P.initial_state({"checked_rosters": false, "official_mission": false, "unit_abilities": true, "combat_doctrines": true, "core_stratagems": true, "reanimation_protocols": true, "awakened_dynasty": true, "manual_allocation": false}, lists)
	check(not state.has("error"), "Darnath and the source-listed units materialize")
	if state.has("error"):
		print(state.error)
		quit(1)
		return
	var lysander := find_model(state, 1, "darnath-lysander")
	var lysander_squad := find_squad(state, 1, "darnath-lysander")
	check(C.UnitAbilities.has(state, lysander_squad, "deep-strike") and C.UnitAbilities.has(state, lysander_squad, "leader") and C.UnitAbilities.has(state, lysander_squad, "rampart") and C.UnitAbilities.has(state, lysander_squad, "icon-of-obstinacy"), "All named datasheet and core abilities are present")
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

	state.phase = "shooting"
	state.active = 1
	state.unit_abilities.phase_key = ""
	state.unit_abilities.window = {}
	C.UnitActions.reconcile(state)
	var choices := C.UnitActions.choices(state, 1)
	var rampart_choice: Dictionary = {}
	for option: Dictionary in choices:
		if option.action == "rampart" and option.model == lysander: rampart_choice = option
	check(not rampart_choice.is_empty() and state.unit_abilities.window.kind == "start", "Rampart is offered only in the start-of-phase decision window")
	check(C.unit_action(state, 1, rampart_choice, Vector2.ZERO, state.revision).is_empty(), "Rampart can be activated at phase start")
	check(C.UnitAbilities.rampart_active(state, lysander) and Defenders.profile(state, lysander).invulnerable_target == 2, "Rampart gives Darnath a 2+ invulnerable save for the current phase")
	choices = C.UnitActions.choices(state, 1)
	check(not choices.any(func(option: Dictionary) -> bool: return option.action == "rampart"), "Rampart is spent for the battle and cannot be activated twice")
	var enemy := find_squad(state, 2, "immortals")
	check(C.UnitAbilities.hit_bonus(state, enemy, lysander_squad, false) == -1 and C.UnitAbilities.hit_bonus(state, enemy, lysander_squad, true) == -1, "Icon of Obstinacy subtracts 1 from shooting and melee hit rolls against his unit")
	state.phase = "shooting"
	state.active = 2
	state.terrain.areas = []
	state.units[lysander].position = Vector2.ZERO
	var warrior_squad := find_squad(state, 2, "necron-warriors")
	var warrior := Geometry.alive(state, warrior_squad)[0]
	state.units[warrior].position = Vector2(10, 0)
	var warrior_weapon: String = state.units[warrior].ranged_weapons[0].id
	var incoming := AttackPlan.prepare(state, warrior_squad, false, [{"model": warrior, "target": lysander_squad, "weapon": warrior_weapon, "profile": "standard", "amount": 1}], false)
	check(incoming.error.is_empty() and incoming.batches.size() == 1 and int(incoming.batches[0].context.hit_modifier) == -1, "Icon of Obstinacy is included in the declared ranged attack context")
	state.phase = "fight"
	check(not C.UnitAbilities.rampart_active(state, lysander) and Defenders.profile(state, lysander).invulnerable_target == 4, "Rampart ends at the phase boundary and the base invulnerable save returns")

	print("Darnath Lysander local checks: %d failures" % failures)
	quit(1 if failures else 0)
